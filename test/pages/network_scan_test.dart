import 'dart:async';

import 'package:another_network_tool/pages/network_scan.dart';
import 'package:another_network_tool/provider/address_info.dart';
import 'package:another_network_tool/provider/config.dart';
import 'package:another_network_tool/provider/connectivity_notifier.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';

import 'network_scan_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<Config>(),
  MockSpec<Connectivity>(),
  MockSpec<NetworkInfo>(),
])
void main() {
  late MockConfig config;
  late MockConnectivity connectivity;
  late MockNetworkInfo networkInfo;

  setUp(() {
    config = MockConfig();
    connectivity = MockConnectivity();
    networkInfo = MockNetworkInfo();

    when(connectivity.onConnectivityChanged)
        .thenAnswer((_) => const Stream<List<ConnectivityResult>>.empty());
  });

  Future<void> pumpNetworkScan(
    WidgetTester tester, {
    List<ConnectivityResult> connectionStatus = const [],
  }) async {
    when(connectivity.checkConnectivity())
        .thenAnswer((_) async => connectionStatus);

    final notifier = ConnectivityNotifier.withConnectivity(connectivity);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<ConnectivityNotifier>.value(
            value: notifier,
            child: NetworkScan(config: config, networkInfo: networkInfo),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    notifier.dispose();
  }

  group('NetworkScan', () {
    testWidgets('shows Wi-Fi unavailable when not connected to Wi-Fi', (
      tester,
    ) async {
      when(networkInfo.getWifiIP()).thenAnswer((_) async => null);
      when(networkInfo.getWifiSubmask()).thenAnswer((_) async => null);

      await pumpNetworkScan(tester);

      expect(find.text('Wi-Fi Unavailable'), findsOneWidget);
    });

    testWidgets('shows scan UI when connected to Wi-Fi', (tester) async {
      when(networkInfo.getWifiIP()).thenAnswer((_) async => null);
      when(networkInfo.getWifiSubmask()).thenAnswer((_) async => null);

      await pumpNetworkScan(
        tester,
        connectionStatus: [ConnectivityResult.wifi],
      );

      expect(find.text('Wi-Fi Unavailable'), findsNothing);
    });

    testWidgets('handles missing Wi-Fi IP', (tester) async {
      when(networkInfo.getWifiIP()).thenAnswer((_) async => null);
      when(networkInfo.getWifiSubmask()).thenAnswer((_) async => null);

      await pumpNetworkScan(
        tester,
        connectionStatus: [ConnectivityResult.wifi],
      );

      verify(networkInfo.getWifiIP()).called(1);
      verify(networkInfo.getWifiSubmask()).called(1);

      expect(find.text('Wi-Fi Unavailable'), findsNothing);
    });

    testWidgets('handles missing Wi-Fi subnet mask', (tester) async {
      when(networkInfo.getWifiIP()).thenAnswer((_) async => '192.168.1.10');
      when(networkInfo.getWifiSubmask()).thenAnswer((_) async => null);

      await pumpNetworkScan(
        tester,
        connectionStatus: [ConnectivityResult.wifi],
      );

      verify(networkInfo.getWifiIP()).called(1);
      verify(networkInfo.getWifiSubmask()).called(1);

      expect(find.byType(NetworkScan), findsOneWidget);
    });

    testWidgets('creates subnet from Wi-Fi IP and subnet mask', (tester) async {
      final scanController = StreamController<AddressInfo>();

      when(networkInfo.getWifiIP()).thenAnswer((_) async => '192.168.1.10');
      when(networkInfo.getWifiSubmask())
          .thenAnswer((_) async => '255.255.255.0');

      when(config.pingSubnet(any, any))
          .thenAnswer((_) => scanController.stream);

      await pumpNetworkScan(
        tester,
        connectionStatus: [ConnectivityResult.wifi],
      );

      verify(networkInfo.getWifiIP()).called(1);
      verify(networkInfo.getWifiSubmask()).called(1);

      final captured = verify(config.pingSubnet(captureAny, captureAny))
          .captured;

      expect(captured, hasLength(2));

      final subnet = captured.first;

      expect(subnet.toString(), '192.168.1.0/24');

      await scanController.close();
    });

    testWidgets('does not scan when IP is unavailable', (tester) async {
      when(networkInfo.getWifiIP()).thenAnswer((_) async => null);
      when(networkInfo.getWifiSubmask())
          .thenAnswer((_) async => '255.255.255.0');

      await pumpNetworkScan(
        tester,
        connectionStatus: [ConnectivityResult.wifi],
      );

      verify(networkInfo.getWifiIP()).called(1);
      verify(networkInfo.getWifiSubmask()).called(1);
      verifyNever(config.pingSubnet(any, any));
    });

    testWidgets('does not scan when subnet mask is unavailable', (
      tester,
    ) async {
      when(networkInfo.getWifiIP()).thenAnswer((_) async => '192.168.1.10');
      when(networkInfo.getWifiSubmask()).thenAnswer((_) async => null);

      await pumpNetworkScan(
        tester,
        connectionStatus: [ConnectivityResult.wifi],
      );

      verify(networkInfo.getWifiIP()).called(1);
      verify(networkInfo.getWifiSubmask()).called(1);
      verifyNever(config.pingSubnet(any, any));
    });
  });
}
