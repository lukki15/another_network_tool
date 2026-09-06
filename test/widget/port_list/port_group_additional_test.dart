import 'dart:async';

import 'package:another_network_tool/provider/config.dart';
import 'package:another_network_tool/widget/port_lists/port_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Config configWithPorts(Stream<int> Function() streamFactory) {
    return Config(
      portScanner: (
        String target, {
        int startPort = Config.defaultStartPort,
        int endPort = Config.defaultEndPort,
      }) => streamFactory(),
    );
  }

  Future<void> pumpPortGroup(WidgetTester tester, Config config) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PortGroup(address: '192.168.1.10', config: config),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  group('PortGroup additional behavior', () {
    testWidgets('deduplicates repeated ports', (tester) async {
      final config = configWithPorts(
        () => Stream.fromIterable([80, 443, 80, 443, 80]),
      );

      await pumpPortGroup(tester, config);

      expect(find.text('DISCOVERED PORTS (2)'), findsOneWidget);
      expect(find.text('Port 80 • Open'), findsOneWidget);
      expect(find.text('Port 443 • Open'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('sorts discovered ports numerically', (tester) async {
      final config = configWithPorts(
        () => Stream.fromIterable([443, 22, 8080, 80]),
      );

      await pumpPortGroup(tester, config);

      final portTexts = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data)
          .whereType<String>()
          .where((text) => text.contains('• Open'))
          .toList();

      expect(portTexts, <String>[
        'Port 22 • Open',
        'Port 80 • Open',
        'Port 443 • Open',
        'Port 8080 • Open',
      ]);
    });

    testWidgets('uses port number when service name is unknown', (
      tester,
    ) async {
      const unknownPort = 54321;

      final config = configWithPorts(() => Stream.value(unknownPort));

      await pumpPortGroup(tester, config);

      expect(find.text('Port $unknownPort'), findsOneWidget);
      expect(find.text('Port $unknownPort • Open'), findsOneWidget);
    });

    testWidgets('shows empty state only after stream completes', (
      tester,
    ) async {
      final config = configWithPorts(() => Stream<int>.empty());

      await pumpPortGroup(tester, config);

      expect(find.text('No open ports found'), findsOneWidget);
      expect(find.text('DISCOVERED PORTS (0)'), findsOneWidget);
    });

    testWidgets('does not show empty state while ports are still scanning', (
      tester,
    ) async {
      final onListen = Completer<void>();
      final controller = StreamController<int>(onListen: onListen.complete);

      final config = Config(
        portScanner: (
          String target, {
          int startPort = Config.defaultStartPort,
          int endPort = Config.defaultEndPort,
        }) => controller.stream,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortGroup(address: '192.168.1.10', config: config),
          ),
        ),
      );

      await onListen.future;

      expect(find.text('DISCOVERED PORTS (0)'), findsOneWidget);
      expect(find.text('No open ports found'), findsNothing);

      controller.add(80);
      await tester.pump();

      expect(find.text('DISCOVERED PORTS (1)'), findsOneWidget);
      expect(find.text('Port 80 • Open'), findsOneWidget);
      expect(find.text('No open ports found'), findsNothing);

      // Complete the scan while PortGroup is still mounted.
      controller.close();

      await tester.pump();

      expect(find.text('Port 80 • Open'), findsOneWidget);
      expect(find.text('No open ports found'), findsNothing);

      // Dispose the widget so PortGroup cancels its subscription.
      await tester.pumpWidget(const SizedBox());

      // Now the controller can finish closing.
      await controller.done;
    });
  });
}
