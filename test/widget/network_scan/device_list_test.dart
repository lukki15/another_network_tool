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
      expect(find.text("Scanning devices"), findsOneWidget);
      expect(find.text("on your network"), findsOneWidget);
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
      expect(find.text("Scanning devices"), findsOneWidget);
      expect(find.text("on 192.0.0.0/24"), findsOneWidget);
      expect(find.text("scanning 1 / 254"), findsOneWidget);

      await controller.close();
      await t.pumpAndSettle();
      expect(controller.isClosed, true);
      expect(find.text("Scan complete"), findsOneWidget);
      expect(find.text("Scanning devices"), findsNothing);
    });

    const testCases = [
      // prefix, IP, mask, expected network
      (0, '10.20.30.40', '0.0.0.0', '0.0.0.0'),
      (1, '10.20.30.40', '128.0.0.0', '0.0.0.0'),
      (2, '10.20.30.40', '192.0.0.0', '0.0.0.0'),
      (3, '10.20.30.40', '224.0.0.0', '0.0.0.0'),
      (4, '10.20.30.40', '240.0.0.0', '0.0.0.0'),
      (5, '10.20.30.40', '248.0.0.0', '8.0.0.0'),
      (6, '10.20.30.40', '252.0.0.0', '8.0.0.0'),
      (7, '10.20.30.40', '254.0.0.0', '10.0.0.0'),
      (8, '10.20.30.40', '255.0.0.0', '10.0.0.0'),
      (9, '10.20.30.40', '255.128.0.0', '10.0.0.0'),
      (10, '10.20.30.40', '255.192.0.0', '10.0.0.0'),
      (11, '10.20.30.40', '255.224.0.0', '10.0.0.0'),
      (12, '10.20.30.40', '255.240.0.0', '10.16.0.0'),
      (13, '10.20.30.40', '255.248.0.0', '10.16.0.0'),
      (14, '10.20.30.40', '255.252.0.0', '10.20.0.0'),
      (15, '10.20.30.40', '255.254.0.0', '10.20.0.0'),
      (16, '10.20.30.40', '255.255.0.0', '10.20.0.0'),
      (17, '10.20.30.40', '255.255.128.0', '10.20.0.0'),
      (18, '10.20.30.40', '255.255.192.0', '10.20.0.0'),
      (19, '10.20.30.40', '255.255.224.0', '10.20.0.0'),
      (20, '10.20.30.40', '255.255.240.0', '10.20.16.0'),
      (21, '10.20.30.40', '255.255.248.0', '10.20.24.0'),
      (22, '10.20.30.40', '255.255.252.0', '10.20.28.0'),
      (23, '10.20.30.40', '255.255.254.0', '10.20.30.0'),
      (24, '10.20.30.40', '255.255.255.0', '10.20.30.0'),
      (25, '10.20.30.40', '255.255.255.128', '10.20.30.0'),
      (26, '10.20.30.40', '255.255.255.192', '10.20.30.0'),
      (27, '10.20.30.40', '255.255.255.224', '10.20.30.32'),
      (28, '10.20.30.40', '255.255.255.240', '10.20.30.32'),
      (29, '10.20.30.40', '255.255.255.248', '10.20.30.40'),
      (30, '10.20.30.40', '255.255.255.252', '10.20.30.40'),
      (31, '10.20.30.40', '255.255.255.254', '10.20.30.40'),
      (32, '10.20.30.40', '255.255.255.255', '10.20.30.40'),
    ];

    int expectedHostCount(int prefix) {
      switch (prefix) {
        case 31:
          return 2; // /31 has 2 usable addresses
        case 32:
          return 1; // /32 has 1 usable address
        default:
          return (1 << (32 - prefix)) - 2;
      }
    }

    for (final (prefix, ip, mask, expectedNetwork) in testCases) {
      testWidgets('subnet /$prefix', (WidgetTester t) async {
        final controller = StreamController<AddressInfo>();

        when(config.pingSubnet(any)).thenAnswer((_) => controller.stream);

        final subnet = Subnet.fromIpAndMask(ip, mask);

        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DeviceList(
                hasWifi: true,
                wifiSubnet: Future.value(subnet),
                config: config,
              ),
            ),
          ),
        );

        controller.add(MockAddressInfo());
        await t.pumpAndSettle();

        expect(controller.isClosed, false);
        expect(find.text('Scanning devices'), findsOneWidget);

        expect(find.text('on $expectedNetwork/$prefix'), findsOneWidget);

        expect(
          find.text('scanning 1 / ${expectedHostCount(prefix)}'),
          findsOneWidget,
        );

        await controller.close();
        await t.pumpAndSettle();
      });
    }

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
