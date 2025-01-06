// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:another_network_tool/pages/main_scaffold.dart';
import 'package:another_network_tool/setup_network_tools.dart';

void main() {
  testWidgets('Switch pages', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    setupNetworkTools();
    await tester.pumpWidget(const MaterialApp(home: MainScaffold()));

    // Check if the Network Info screen is visible
    expect(find.text('Network Info'), findsOneWidget);

    // Tap the List button
    await tester.tap(find.text("List"));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Check if the Network Scan page is visible
    expect(find.text('Network Scan'), findsOneWidget);
  });
}
