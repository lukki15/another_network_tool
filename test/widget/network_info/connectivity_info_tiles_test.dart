import 'dart:io';

import 'package:another_network_tool/widget/network_info/connectivity_info_tiles.dart';
import 'package:another_network_tool/widget/network_info/connectivity_stats.dart';
import 'package:another_network_tool/widget/network_info/conductivity_card.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConnectivityInfoTiles Tests', () {
    testWidgets('with platform', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConnectivityInfoTiles(
              isAndroid: () => Platform.isAndroid,
              isLinux: () => Platform.isLinux,
              conductivities: [
                ConnectivityResult.wifi,
                ConnectivityResult.mobile,
                ConnectivityResult.ethernet,
              ],
            ),
          ),
        ),
      );

      expect(find.text("Wi-Fi"), findsOneWidget);
      expect(find.text("Cellular"), findsOneWidget);
      expect(find.text("Ethernet"), findsOneWidget);
    });

    testWidgets('unknown platform', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConnectivityInfoTiles(
              isAndroid: () => false,
              isLinux: () => false,
              conductivities: [],
            ),
          ),
        ),
      );

      expect(find.text("Wi-Fi"), findsOneWidget);
      expect(find.text("Cellular"), findsOneWidget);
      expect(find.text("Ethernet"), findsOneWidget);

      final iconFinder = find.byIcon(Icons.wifi_off);
      expect(iconFinder, findsOneWidget);

      expect(
        find.descendant(
          of: find.widgetWithText(ConductivityCard, 'Wi-Fi'),
          matching: find.text('Connected'),
        ),
        findsNothing,
      );
    });

    testWidgets('unknown platform with wifi', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConnectivityInfoTiles(
              isAndroid: () => false,
              isLinux: () => false,
              conductivities: [ConnectivityResult.wifi],
            ),
          ),
        ),
      );

      expect(find.text("Wi-Fi"), findsOneWidget);
      expect(find.text("Cellular"), findsOneWidget);
      expect(find.text("Ethernet"), findsOneWidget);

      final iconFinder = find.byIcon(Icons.wifi);
      expect(iconFinder, findsOneWidget);

      expect(
        find.descendant(
          of: find.widgetWithText(ConductivityCard, 'Wi-Fi'),
          matching: find.text('Connected'),
        ),
        findsOneWidget,
      );

      expect(find.byType(ConnectivityStats), findsOneWidget);
    });

    testWidgets('Android without mobile', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConnectivityInfoTiles(
              isAndroid: () => true,
              isLinux: () => false,
              conductivities: [],
            ),
          ),
        ),
      );

      expect(find.text("Wi-Fi"), findsOneWidget);
      expect(find.text("Cellular"), findsOneWidget);
      expect(find.text("Ethernet"), findsOneWidget);

      expect(find.byIcon(Icons.signal_cellular_alt), findsNothing);
    });

    testWidgets('Android with mobile', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConnectivityInfoTiles(
              isAndroid: () => true,
              isLinux: () => false,
              conductivities: [ConnectivityResult.mobile],
            ),
          ),
        ),
      );

      expect(find.text("Wi-Fi"), findsOneWidget);
      expect(find.text("Cellular"), findsOneWidget);
      expect(find.text("Ethernet"), findsOneWidget);

      final iconFinder = find.byIcon(Icons.signal_cellular_alt);
      expect(iconFinder, findsOneWidget);

      expect(
        find.descendant(
          of: find.widgetWithText(ConductivityCard, 'Cellular'),
          matching: find.text('Connected'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Linux without ethernet', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConnectivityInfoTiles(
              isAndroid: () => false,
              isLinux: () => true,
              conductivities: [],
            ),
          ),
        ),
      );

      expect(find.text("Wi-Fi"), findsOneWidget);
      expect(find.text("Cellular"), findsOneWidget);
      expect(find.text("Ethernet"), findsOneWidget);

      final iconFinder = find.byIcon(Icons.power_off);
      expect(iconFinder, findsOneWidget);

      expect(
        find.descendant(
          of: find.widgetWithText(ConductivityCard, 'Ethernet'),
          matching: find.text('Connected'),
        ),
        findsNothing,
      );
    });

    testWidgets('Linux with ethernet', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConnectivityInfoTiles(
              isAndroid: () => false,
              isLinux: () => true,
              conductivities: [ConnectivityResult.ethernet],
            ),
          ),
        ),
      );

      expect(find.text("Wi-Fi"), findsOneWidget);
      expect(find.text("Cellular"), findsOneWidget);
      expect(find.text("Ethernet"), findsOneWidget);

      final iconFinder = find.byIcon(Icons.cable);
      expect(iconFinder, findsOneWidget);

      expect(
        find.descendant(
          of: find.widgetWithText(ConductivityCard, 'Ethernet'),
          matching: find.text('Connected'),
        ),
        findsOneWidget,
      );
    });
  });
}
