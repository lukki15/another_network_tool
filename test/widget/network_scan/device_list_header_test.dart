import 'package:another_network_tool/provider/config.dart';
import 'package:another_network_tool/widget/network_scan/device_list_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeviceListHeader', () {
    testWidgets('shows completed scan state and pluralized device count', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeviceListHeader(
              isDone: true,
              progressPercent: 1.0,
              percentText: '100',
              currentIP: 42,
              discoveredCount: 2,
            ),
          ),
        ),
      );

      expect(find.text('Scan complete'), findsOneWidget);
      expect(find.text('2 devices found'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows in-progress scan state with metrics and indicators', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeviceListHeader(
              isDone: false,
              progressPercent: 0.5,
              percentText: '50',
              currentIP: 42,
              discoveredCount: 0,
            ),
          ),
        ),
      );

      expect(find.text('Scanning devices'), findsOneWidget);
      expect(
        find.text('Checking nearby devices on your network'),
        findsOneWidget,
      );
      expect(find.text('50%'), findsOneWidget);
      expect(
        find.text('scanning 42 / ${Config.defaultLastHostId}'),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
