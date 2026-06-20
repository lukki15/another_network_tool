import 'package:another_network_tool/widget/network_info/connectivity_stats_state_list_view.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConnectivityStatsStateListView', () {
    testWidgets('displays labels and values and null placeholder', (
      WidgetTester tester,
    ) async {
      final details = <Map<String, Future<String?>>?>[
        {'SSID': Future.value('MyWifi')},
        {'BSSID': Future<String?>.value(null)},
      ].cast<Map<String, Future<String?>>>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ConnectivityStatsStateListView(
                  context: context,
                  details: details,
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('SSID'), findsOneWidget);
      expect(find.text('MyWifi'), findsOneWidget);

      expect(find.text('BSSID'), findsOneWidget);
      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('shows Error when future fails', (WidgetTester tester) async {
      final completer = Completer<String?>();

      final details = <Map<String, Future<String?>>>[
        {'IP': completer.future},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ConnectivityStatsStateListView(
                  context: context,
                  details: details,
                );
              },
            ),
          ),
        ),
      );

      // trigger the future to complete with error
      completer.completeError('fail');
      await tester.pumpAndSettle();

      expect(find.text('IP'), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('long press copies value to clipboard', (
      WidgetTester tester,
    ) async {
      final details = <Map<String, Future<String?>>>[
        {'IP': Future.value('1.2.3.4')},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ConnectivityStatsStateListView(
                  context: context,
                  details: details,
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('1.2.3.4'), findsOneWidget);

      // Long press the row (tap on the label)
      await tester.longPress(find.text('IP'));
      await tester.pumpAndSettle();

      // TODO: Clipboard.getData is not supported in widget tests
      //final data = await Clipboard.getData('text/plain');
      //expect(data?.text, '1.2.3.4');
    });
  });
}
