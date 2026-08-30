import 'dart:async';

import 'package:another_network_tool/provider/address_info.dart';
import 'package:another_network_tool/provider/config.dart';
import 'package:another_network_tool/widget/network_scan/device_list.dart';
import 'package:another_network_tool/utils/subnet.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<Config>()])
@GenerateNiceMocks([MockSpec<AddressInfo>()])
import './device_list_test.mocks.dart';

void main() {
  late MockConfig config;

  setUp(() {
    config = MockConfig();
  });

  group('DeviceList Tests', () {
    testWidgets('without wifi', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceList(
              hasWifi: false,
              wifiSubnet: Future.value(),
              config: Config(),
            ),
          ),
        ),
      );

      await t.pumpAndSettle();

      expect(find.text("Wi-Fi Unavailable"), findsOneWidget);
    });

    testWidgets('without wifiIP', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceList(
              hasWifi: true,
              wifiSubnet: Future.value(),
              config: Config(),
            ),
          ),
        ),
      );

      await t.pumpAndSettle();
      expect(find.text("Scan complete"), findsOneWidget);
    });

    testWidgets('wait for wifiIP', (WidgetTester t) async {
      final controller = StreamController<AddressInfo>();
      when(config.pingSubnet(any)).thenAnswer((_) => controller.stream);

      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceList(
              hasWifi: true,
              wifiSubnet: Future.value(
                Subnet.fromIpAndMask('192.0.0.1', '255.255.255.0'),
              ),
              config: config,
            ),
          ),
        ),
      );

      await t.pumpAndSettle();
      expect(find.text("scanning 1 / 254"), findsOneWidget);
      await controller.close();
    });

    testWidgets('shows the circular scan progress card', (
      WidgetTester t,
    ) async {
      final controller = StreamController<AddressInfo>();
      when(config.pingSubnet(any)).thenAnswer((_) => controller.stream);

      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceList(
              hasWifi: true,
              wifiSubnet: Future.value(
                Subnet.fromIpAndMask('192.0.0.1', '255.255.255.0'),
              ),
              config: config,
            ),
          ),
        ),
      );

      await t.pump();

      expect(find.text("Scanning devices"), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await controller.close();
    });

    testWidgets('with wifi', (WidgetTester t) async {
      var controller = StreamController<AddressInfo>();
      when(config.pingSubnet(any)).thenAnswer((_) => controller.stream);

      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceList(
              hasWifi: true,
              wifiSubnet: Future.value(
                Subnet.fromIpAndMask('192.0.0.1', '255.255.255.0'),
              ),
              config: config,
            ),
          ),
        ),
      );

      controller.add(MockAddressInfo());
      await t.pumpAndSettle();
      expect(controller.isClosed, false);
      expect(find.text("scanning 1 / 254"), findsOneWidget);

      await controller.close();
      await t.pumpAndSettle();
      expect(controller.isClosed, true);
      expect(find.text("Scan complete"), findsOneWidget);
      expect(find.text("Scanning devices"), findsNothing);
    });

    testWidgets('shows subnet parse error', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceList(
              hasWifi: true,
              wifiSubnet: Future<Subnet?>.delayed(
                Duration.zero,
                () => throw FormatException('Non-contiguous subnet mask'),
              ),
              config: Config(),
            ),
          ),
        ),
      );

      await t.pumpAndSettle();
      expect(find.text('Network error'), findsOneWidget);
      expect(find.textContaining('Non-contiguous subnet mask'), findsOneWidget);
    });
  });
}
