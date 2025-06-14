import 'dart:io';

import 'package:another_network_tool/widget/network_info/connectivity_info_tiles.dart';
import 'package:another_network_tool/widget/network_info/connectivity_stats.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

void main() {
  group('ConnectivityInfoTiles Tests', () {
    testWidgets('with platform', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: ConnectivityInfoTiles(
            isAndroid: () => Platform.isAndroid,
            isLinux: () => Platform.isLinux,
            conductivities: [
              ConnectivityResult.wifi,
              ConnectivityResult.mobile,
              ConnectivityResult.ethernet,
            ],
          ),
        ),
      );

      expect(find.text("Wi-Fi"), findsOneWidget);
      expect(find.text("Cellular"), findsNothing);
      expect(find.text("Ethernet"), findsOneWidget);
    });

    testWidgets('unknown platform', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: ConnectivityInfoTiles(
            isAndroid: () => false,
            isLinux: () => false,
            conductivities: [],
          ),
        ),
      );

      expect(find.text("Wi-Fi"), findsOneWidget);
      expect(find.text("Cellular"), findsNothing);
      expect(find.text("Ethernet"), findsNothing);

      final iconFinder = find.byIcon(FIcons.wifiOff);
      expect(iconFinder, findsOneWidget);

      final iconWidget = t.widget<Icon>(iconFinder);
      expect(iconWidget.color, isSameColorAs(Colors.red));
    });

    testWidgets('unknown platform with wifi', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: ConnectivityInfoTiles(
            isAndroid: () => false,
            isLinux: () => false,
            conductivities: [ConnectivityResult.wifi],
          ),
        ),
      );

      expect(find.text("Wi-Fi"), findsOneWidget);
      expect(find.text("Cellular"), findsNothing);
      expect(find.text("Ethernet"), findsNothing);

      final iconFinder = find.byIcon(FIcons.wifi);
      expect(iconFinder, findsOneWidget);

      final iconWidget = t.widget<Icon>(iconFinder);
      expect(iconWidget.color, isSameColorAs(Colors.green));

      expect(find.byType(ConnectivityStats), findsOneWidget);
    });

    testWidgets('Android without mobile', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: ConnectivityInfoTiles(
            isAndroid: () => true,
            isLinux: () => false,
            conductivities: [],
          ),
        ),
      );

      expect(find.text("Wi-Fi"), findsOneWidget);
      expect(find.text("Cellular"), findsNothing);
      expect(find.text("Ethernet"), findsNothing);

      expect(find.byIcon(FIcons.signal), findsNothing);
    });

    testWidgets('Android with mobile', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: ConnectivityInfoTiles(
            isAndroid: () => true,
            isLinux: () => false,
            conductivities: [ConnectivityResult.mobile],
          ),
        ),
      );

      expect(find.text("Wi-Fi"), findsOneWidget);
      expect(find.text("Cellular"), findsOneWidget);
      expect(find.text("Ethernet"), findsNothing);

      final iconFinder = find.byIcon(FIcons.signal);
      expect(iconFinder, findsOneWidget);

      final iconWidget = t.widget<Icon>(iconFinder);
      expect(iconWidget.color, isSameColorAs(Colors.green));
    });

    testWidgets('Linux without ethernet', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: ConnectivityInfoTiles(
            isAndroid: () => false,
            isLinux: () => true,
            conductivities: [],
          ),
        ),
      );

      expect(find.text("Wi-Fi"), findsOneWidget);
      expect(find.text("Cellular"), findsNothing);
      expect(find.text("Ethernet"), findsOneWidget);

      final iconFinder = find.byIcon(FIcons.unplug);
      expect(iconFinder, findsOneWidget);

      final iconWidget = t.widget<Icon>(iconFinder);
      expect(iconWidget.color, isSameColorAs(Colors.red));
    });

    testWidgets('Linux with ethernet', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: ConnectivityInfoTiles(
            isAndroid: () => false,
            isLinux: () => true,
            conductivities: [ConnectivityResult.ethernet],
          ),
        ),
      );

      expect(find.text("Wi-Fi"), findsOneWidget);
      expect(find.text("Cellular"), findsNothing);
      expect(find.text("Ethernet"), findsOneWidget);

      final iconFinder = find.byIcon(FIcons.ethernetPort);
      expect(iconFinder, findsOneWidget);

      final iconWidget = t.widget<Icon>(iconFinder);
      expect(iconWidget.color, isSameColorAs(Colors.green));
    });
  });
}
