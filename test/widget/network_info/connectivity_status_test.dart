import 'package:another_network_tool/widget/network_info/connectivity_stats.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:network_tools/network_tools.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

@GenerateNiceMocks([MockSpec<NetworkInfo>()])
import './connectivity_status_test.mocks.dart';

void main() {
  late MockNetworkInfo networkInfo;

  setUp(() {
    networkInfo = MockNetworkInfo();
  });

  void setupNetworkInfo() {
    when(networkInfo.getWifiName()).thenAnswer((_) => Future.value("WifiName"));
    when(
      networkInfo.getWifiBSSID(),
    ).thenAnswer((_) => Future.value("WifiBSSID"));
    when(networkInfo.getWifiIP()).thenAnswer((_) => Future.value("WifiIP"));
    when(networkInfo.getWifiIPv6()).thenAnswer((_) => Future.value("WifiIPv6"));
    when(
      networkInfo.getWifiGatewayIP(),
    ).thenAnswer((_) => Future.value("WifiGatewayIP"));
    when(
      networkInfo.getWifiBroadcast(),
    ).thenAnswer((_) => Future.value("WifiBroadcast"));
    when(
      networkInfo.getWifiSubmask(),
    ).thenAnswer((_) => Future.value("WifiSubmask"));
  }

  void setupNetworkInfoErrors() {
    when(networkInfo.getWifiName()).thenAnswer((_) => Future.error(0));
    when(networkInfo.getWifiBSSID()).thenAnswer((_) => Future.error(0));
    when(networkInfo.getWifiIP()).thenAnswer((_) => Future.error(0));
    when(networkInfo.getWifiIPv6()).thenAnswer((_) => Future.error(0));
    when(networkInfo.getWifiGatewayIP()).thenAnswer((_) => Future.error(0));
    when(networkInfo.getWifiBroadcast()).thenAnswer((_) => Future.error(0));
    when(networkInfo.getWifiSubmask()).thenAnswer((_) => Future.error(0));
  }

  group('ConnectivityStats Tests', () {
    testWidgets('on desktop', (WidgetTester t) async {
      setupNetworkInfo();

      await t.pumpWidget(
        MaterialApp(
          home: ConnectivityStats(
            networkInfo: networkInfo,
            isMobile: false,
            locationWhenInUse: PermissionHelper(
              isGranted: () => Future.value(false),
              request: () => Future.value(PermissionStatus.denied),
            ),
          ),
        ),
      );

      await t.pumpAndSettle();

      expect(find.text("WifiName"), findsOneWidget);
      expect(find.text("WifiBSSID"), findsOneWidget);
      expect(find.text("WifiIP"), findsOneWidget);
      expect(find.text("WifiIPv6"), findsOneWidget);
      expect(find.text("WifiGatewayIP"), findsOneWidget);
      expect(find.text("WifiBroadcast"), findsOneWidget);
      expect(find.text("WifiSubmask"), findsOneWidget);
    });

    testWidgets('on mobile', (WidgetTester t) async {
      setupNetworkInfo();

      await t.pumpWidget(
        MaterialApp(
          home: ConnectivityStats(
            networkInfo: networkInfo,
            isMobile: true,
            locationWhenInUse: PermissionHelper(
              isGranted: () => Future.value(true),
              request: () => Future.value(PermissionStatus.granted),
            ),
          ),
        ),
      );

      await t.pumpAndSettle();

      expect(find.text("WifiName"), findsOneWidget);
      expect(find.text("WifiBSSID"), findsOneWidget);
      expect(find.text("WifiIP"), findsOneWidget);
      expect(find.text("WifiIPv6"), findsOneWidget);
      expect(find.text("WifiGatewayIP"), findsOneWidget);
      expect(find.text("WifiBroadcast"), findsOneWidget);
      expect(find.text("WifiSubmask"), findsOneWidget);
    });

    testWidgets('on mobile deny permissions', (WidgetTester t) async {
      setupNetworkInfo();

      await t.pumpWidget(
        MaterialApp(
          home: ConnectivityStats(
            networkInfo: networkInfo,
            isMobile: true,
            locationWhenInUse: PermissionHelper(
              isGranted: () => Future.value(false),
              request: () => Future.value(PermissionStatus.restricted),
            ),
          ),
        ),
      );

      await t.pumpAndSettle();

      expect(find.text("Unauthorized to get Wifi Name"), findsOneWidget);
      expect(find.text("Unauthorized to get Wifi BSSID"), findsOneWidget);
      expect(find.text("WifiIP"), findsOneWidget);
      expect(find.text("WifiIPv6"), findsOneWidget);
      expect(find.text("WifiGatewayIP"), findsOneWidget);
      expect(find.text("WifiBroadcast"), findsOneWidget);
      expect(find.text("WifiSubmask"), findsOneWidget);
    });

    testWidgets('error texts', (WidgetTester t) async {
      setupNetworkInfoErrors();

      await t.pumpWidget(
        MaterialApp(
          home: ConnectivityStats(
            networkInfo: networkInfo,
            isMobile: false,
            locationWhenInUse: PermissionHelper(
              isGranted: () => Future.value(false),
              request: () => Future.value(PermissionStatus.denied),
            ),
          ),
        ),
      );

      await t.pumpAndSettle();

      expect(find.text("Failed to get Wifi Name"), findsOneWidget);
      expect(find.text("Failed to get Wifi BSSID"), findsOneWidget);
      expect(find.text("Failed to get Wifi IPv4"), findsOneWidget);
      expect(find.text("Failed to get Wifi IPv6"), findsOneWidget);
      expect(find.text("Failed to get Wifi gateway address"), findsOneWidget);
      expect(find.text("Failed to get Wifi broadcast"), findsOneWidget);
      expect(find.text("Failed to get Wifi submask address"), findsOneWidget);
    });
  });
}
