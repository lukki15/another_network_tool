import 'package:another_network_tool/provider/config.dart';
import 'package:another_network_tool/widget/port_lists/port_group.dart';
import 'package:another_network_tool/widget/port_lists/port_map.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<Config>()])
import './port_group_test.mocks.dart';

void main() {
  group('PortGroup', () {
    late MockConfig mockConfig;

    setUp(() {
      mockConfig = MockConfig();
    });

    void setupPortScanExpectation(Stream<int> portStream) {
      when(mockConfig.scanPort('127.0.0.1')).thenAnswer((_) => portStream);
    }

    Future<void> pumpPortGroup(WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortGroup(address: '127.0.0.1', config: mockConfig),
          ),
        ),
      );
      await t.pumpAndSettle();
    }

    void assertBasicLayout(WidgetTester t) {
      expect(find.text('Open Ports'), findsOneWidget);
      expect(find.text('Port Range'), findsOneWidget);
      expect(find.text('Default scan range'), findsOneWidget);
    }

    testWidgets('shows empty state initially', (WidgetTester t) async {
      setupPortScanExpectation(Stream<int>.empty());

      await pumpPortGroup(t);
      assertBasicLayout(t);

      expect(find.text('DISCOVERED PORTS (0)'), findsOneWidget);
      expect(find.text('No open ports found'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('shows discovered ports at start port', (WidgetTester t) async {
      setupPortScanExpectation(Stream.fromIterable([Config.defaultStartPort]));

      await pumpPortGroup(t);
      assertBasicLayout(t);

      expect(find.text('DISCOVERED PORTS (1)'), findsOneWidget);
      expect(
        find.text(
          portMap[Config.defaultStartPort] ?? 'Port ${Config.defaultStartPort}',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Port ${Config.defaultStartPort} • Open'),
        findsOneWidget,
      );
      expect(find.text('No open ports found'), findsNothing);
    });

    testWidgets(
      'shows discovered ports even when they start later in the range',
      (WidgetTester t) async {
        final firstPort = Config.defaultStartPort + 10;
        setupPortScanExpectation(Stream.fromIterable([firstPort]));

        await pumpPortGroup(t);
        assertBasicLayout(t);

        expect(find.text('DISCOVERED PORTS (1)'), findsOneWidget);
        expect(
          find.text(portMap[firstPort] ?? 'Port $firstPort'),
          findsOneWidget,
        );
        expect(find.text('Port $firstPort • Open'), findsOneWidget);
        expect(find.byType(ListTile), findsOneWidget);
      },
    );

    testWidgets('shows multiple discovered ports', (WidgetTester t) async {
      setupPortScanExpectation(Stream.fromIterable([80, 443]));

      await pumpPortGroup(t);
      assertBasicLayout(t);

      expect(find.text('DISCOVERED PORTS (2)'), findsOneWidget);
      expect(find.text('http'), findsOneWidget);
      expect(find.text('https'), findsOneWidget);
      expect(find.text('Port 80 • Open'), findsOneWidget);
      expect(find.text('Port 443 • Open'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('shows single gapped discovered ports', (WidgetTester t) async {
      setupPortScanExpectation(
        Stream.fromIterable([80, 82, Config.defaultEndPort - 1]),
      );

      await pumpPortGroup(t);
      assertBasicLayout(t);

      expect(find.text('DISCOVERED PORTS (3)'), findsOneWidget);
      expect(find.text('Port 80 • Open'), findsOneWidget);
      expect(find.text('Port 82 • Open'), findsOneWidget);
      expect(
        find.text('Port ${Config.defaultEndPort - 1} • Open'),
        findsOneWidget,
      );
      expect(find.byType(ListTile), findsNWidgets(3));
    });
  });
}
