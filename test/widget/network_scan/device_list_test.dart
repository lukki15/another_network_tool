import 'dart:async';

import 'package:another_network_tool/widget/network_scan/device_list.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:network_tools/network_tools.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<ActiveHost>()])
@GenerateNiceMocks([MockSpec<HostScannerService>()])
@GenerateNiceMocks([MockSpec<PortScannerService>()])
import './device_list_test.mocks.dart';

void main() {
  late MockHostScannerService hostScannerService;
  late MockPortScannerService portScannerService;

  setUp(() {
    hostScannerService = MockHostScannerService();
    portScannerService = MockPortScannerService();
  });

  group('DeviceList Tests', () {
    testWidgets('without wifi', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: DeviceList(
            hasWifi: false,
            wifiIP: Future.value(),
            hostScannerService: hostScannerService,
            portScannerService: portScannerService,
          ),
        ),
      );

      await t.pumpAndSettle();

      expect(find.text("Wi-Fi Unavailable"), findsOneWidget);
    });

    testWidgets('without wifiIP', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: DeviceList(
            hasWifi: true,
            wifiIP: Future.value(),
            hostScannerService: hostScannerService,
            portScannerService: portScannerService,
          ),
        ),
      );

      await t.pumpAndSettle();
      expect(find.text("scanning done"), findsOneWidget);
    });

    testWidgets('wait for wifiIP', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: DeviceList(
            hasWifi: true,
            wifiIP: NetworkInfo().getWifiIP(),
            hostScannerService: hostScannerService,
            portScannerService: portScannerService,
          ),
        ),
      );

      await t.pumpAndSettle();
      expect(find.text("scanning 1 / 254"), findsOneWidget);
    });

    testWidgets('with wifi', (WidgetTester t) async {
      var controller = StreamController<ActiveHost>();
      when(
        hostScannerService.getAllPingableDevicesAsync(
          any,
          firstHostId: anyNamed('firstHostId'),
          lastHostId: anyNamed('lastHostId'),
          hostIds: anyNamed('hostIds'),
          timeoutInSeconds: anyNamed('timeoutInSeconds'),
          progressCallback: anyNamed('progressCallback'),
          resultsInAddressAscendingOrder: anyNamed(
            'resultsInAddressAscendingOrder',
          ),
        ),
      ).thenAnswer((_) => controller.stream);

      await t.pumpWidget(
        MaterialApp(
          home: DeviceList(
            hasWifi: true,
            wifiIP: Future.value("192.0.0.1"),
            hostScannerService: hostScannerService,
            portScannerService: portScannerService,
          ),
        ),
      );

      controller.add(MockActiveHost());
      await t.pumpAndSettle();
      expect(controller.isClosed, false);
      expect(find.text("scanning 1 / 254"), findsOneWidget);

      await controller.close();
      await t.pumpAndSettle();
      expect(controller.isClosed, true);
      expect(find.text("scanning done"), findsOneWidget);
    });
  });
}
