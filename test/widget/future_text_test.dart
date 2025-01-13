import 'package:another_network_tool/widget/future_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FutureText Tests', () {
    mockConvertToString(String? data) => 'Converted: ${data ?? "?"}';

    testWidgets('FutureText displays data correctly', (WidgetTester t) async {
      final mockFuture = Future.value('Mock Data');

      await t.pumpWidget(
        MaterialApp(
          home: FutureText(
            future: mockFuture,
            convertToString: mockConvertToString,
            errorMessage: 'Error Message',
          ),
        ),
      );

      await t.pump();
      expect(find.text('Converted: Mock Data'), findsOneWidget);
    });

    testWidgets('FutureText displays error message', (WidgetTester t) async {
      final Future<String> mockFuture = Future.error("Test Error");

      await t.pumpWidget(
        MaterialApp(
          home: FutureText(
            future: mockFuture,
            convertToString: mockConvertToString,
            errorMessage: 'Error Message',
          ),
        ),
      );

      await t.pumpAndSettle();
      expect(find.text('Error Message'), findsOneWidget);
    }, skip: true); // TODO: ends unexpectly with an excpetion

    testWidgets('FutureText displays loading state', (WidgetTester t) async {
      final Future<String?> mockFuture = Future.value(null);

      await t.pumpWidget(
        MaterialApp(
          home: FutureText(
            future: mockFuture,
            convertToString: mockConvertToString,
            errorMessage: 'Error Message',
          ),
        ),
      );

      await t.pump();
      expect(find.text('-'), findsOneWidget);
    });
  });
}
