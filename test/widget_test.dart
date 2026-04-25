// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:another_network_tool/provider/config.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:another_network_tool/pages/main_scaffold.dart';

void main() {
  Future<PingData> mockPingDataProvider(String host) async {
    return PingData();
  }

  testWidgets('Application smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: MainScaffold(
          config: Config(pingDataProvider: mockPingDataProvider),
        ),
      ),
    );

    // starts with the network info screen
    expect(find.text('Network Info'), findsOneWidget);
    expect(find.text('Wi-Fi'), findsOneWidget);

    // Action buttons
    expect(find.text('Info'), findsOneWidget);
    expect(find.text('List'), findsOneWidget);
  });
}
