import 'dart:async';

import 'package:another_network_tool/provider/address_info.dart';
import 'package:another_network_tool/provider/config.dart';
import 'package:another_network_tool/widget/network_scan/device_list.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_info_plus/network_info_plus.dart';
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
          home: DeviceList(
            hasWifi: false,
            wifiIP: Future.value(),
            config: Config(),
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
            config: Config(),
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
            config: Config(),
          ),
        ),
      );

      await t.pumpAndSettle();
      expect(find.text("scanning 1 / 254"), findsOneWidget);
    });

    testWidgets('with wifi', (WidgetTester t) async {
      var controller = StreamController<AddressInfo>();
      when(
        config.pingHosts(
          "192.0.0",
          progressCallback: anyNamed('progressCallback'),
        ),
      ).thenAnswer((_) => controller.stream);

      await t.pumpWidget(
        MaterialApp(
          home: DeviceList(
            hasWifi: true,
            wifiIP: Future.value("192.0.0.1"),
            config: config,
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
      expect(find.text("scanning done"), findsOneWidget);
    });
  });
}
