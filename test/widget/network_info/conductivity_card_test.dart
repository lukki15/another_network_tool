import 'package:another_network_tool/widget/network_info/conductivity_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConductivityCard', () {
    testWidgets('shows network name and connected state when connected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(primaryColor: Colors.purple),
          home: Scaffold(
            body: ConductivityCard(
              isConnected: true,
              isConnectedIcon: Icons.wifi,
              isDisconnectedIcon: Icons.wifi_off,
              networkName: 'Wi-Fi',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Wi-Fi'), findsOneWidget);
      expect(find.text('Connected'), findsOneWidget);

      final iconFinder = find.byIcon(Icons.wifi);
      expect(iconFinder, findsOneWidget);

      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.size, 72);
      expect(iconWidget.color, Colors.purple);
    });

    testWidgets(
      'shows disconnected icon and no Connected text when not connected',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(primaryColor: Colors.orange),
            home: Scaffold(
              body: ConductivityCard(
                isConnected: false,
                isConnectedIcon: Icons.cable,
                isDisconnectedIcon: Icons.power_off,
                networkName: 'Ethernet',
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Ethernet'), findsOneWidget);
        expect(find.text('Connected'), findsNothing);

        final iconFinder = find.byIcon(Icons.power_off);
        expect(iconFinder, findsOneWidget);

        final iconWidget = tester.widget<Icon>(iconFinder);
        expect(iconWidget.size, 72);
        expect(iconWidget.color, Colors.orange);
      },
    );
  });
}
