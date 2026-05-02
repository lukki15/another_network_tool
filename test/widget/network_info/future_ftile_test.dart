import 'package:another_network_tool/widget/network_info/future_list_tile.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FutureListTile Tests', () {
    testWidgets('future text', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                FutureListTile(
                  title: "test title",
                  future: Future<String?>.value("future"),
                  errorMessage: "error",
                ),
              ],
            ),
          ),
        ),
      );
      await t.pumpAndSettle();

      expect(find.text("test title"), findsOneWidget);
      expect(find.text("future"), findsOneWidget);
    });

    testWidgets('future text null', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                FutureListTile(
                  title: "test title",
                  future: Future<String?>.value(null),
                  errorMessage: "error",
                ),
              ],
            ),
          ),
        ),
      );
      await t.pumpAndSettle();

      expect(find.text("test title"), findsOneWidget);
      expect(find.text("-"), findsOneWidget);
    });

    testWidgets('future error', (WidgetTester t) async {
      final Future<String> mockFuture = Future.delayed(
        Duration.zero,
        () => throw Exception("Test Error"),
      );

      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                FutureListTile(
                  title: "test title",
                  future: mockFuture,
                  errorMessage: "error",
                ),
              ],
            ),
          ),
        ),
      );
      await t.pumpAndSettle();

      expect(find.text("test title"), findsOneWidget);
      expect(find.text("error"), findsOneWidget);
    });

    testWidgets('long press', (WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                FutureListTile(
                  title: "test title",
                  future: Future<String?>.value("future"),
                  errorMessage: "error",
                ),
              ],
            ),
          ),
        ),
      );
      await t.pumpAndSettle();

      var tile = find.byType(FutureListTile);
      expect(tile, findsOneWidget);

      await t.longPress(tile);
      await t.pumpAndSettle();

      // TODO: extend test
    });
  });
}
