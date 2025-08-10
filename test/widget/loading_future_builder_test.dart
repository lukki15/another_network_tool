import 'package:another_network_tool/widget/loading_future_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'dart:io';

void main() {
  group('LoadingFutureBuilder', () {
    testWidgets('displays loading state initially', (
      WidgetTester tester,
    ) async {
      final future = Future.delayed(
        const Duration(milliseconds: 50),
        () => Directory("."),
      );
      final widget = MaterialApp(
        home: LoadingFutureBuilder<Directory>(
          future: future,
          loadingMessage: 'loading...',
          onData: (_) => Text("done"),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('loading...'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('done'), findsOneWidget);
    });

    testWidgets('displays data when future completes successfully', (
      WidgetTester tester,
    ) async {
      final future = Future.value(Directory("."));
      final widget = MaterialApp(
        home: LoadingFutureBuilder<Directory>(
          future: future,
          loadingMessage: 'Loading...',
          onData: (data) => Text('Data loaded: ${data.path}'),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      expect(find.text('Data loaded: .'), findsOneWidget);
    });

    testWidgets('displays error message when future fails', (
      WidgetTester tester,
    ) async {
      final future = Future.delayed(
        Duration.zero,
        () => Future.error(Exception('Test error')),
      );
      final widget = MaterialApp(
        home: LoadingFutureBuilder<dynamic>(
          future: future,
          loadingMessage: 'Loading...',
          onData: (_) => const SizedBox(),
          errorWidget: Text('Custom error message'),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      expect(find.text('Custom error message'), findsOneWidget);
    });

    testWidgets('uses default error widget when none provided', (
      WidgetTester tester,
    ) async {
      final future = Future.delayed(
        Duration.zero,
        () => Future.error(Exception('Test error')),
      );
      final widget = MaterialApp(
        home: LoadingFutureBuilder<dynamic>(
          future: future,
          loadingMessage: 'Loading...',
          onData: (_) => const SizedBox(),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      expect(find.text('Error: Exception: Test error'), findsOneWidget);
    });

    testWidgets('maintains type safety with different data types', (
      WidgetTester tester,
    ) async {
      // Test with boolean type
      final voidFuture = Future.value(true);
      final voidWidget = MaterialApp(
        home: LoadingFutureBuilder<void>(
          future: voidFuture,
          loadingMessage: 'Loading...',
          onData: (_) => const Text('Boolean data'),
        ),
      );

      await tester.pumpWidget(voidWidget);
      await tester.pumpAndSettle();
      expect(find.text('Boolean data'), findsOneWidget);
    });
  });
}
