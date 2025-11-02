import 'package:another_network_tool/widget/port_lists/port_group.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:network_tools/network_tools.dart';
import 'package:forui/forui.dart';

@GenerateNiceMocks([MockSpec<ActiveHost>()])
@GenerateNiceMocks([MockSpec<PortScannerService>()])
import './port_group_test.mocks.dart';

void main() {
  group('PortGroup', () {
    late MockPortScannerService portScannerService;

    setUp(() {
      portScannerService = MockPortScannerService();
    });

    void setupPortScanExpectation(Stream<ActiveHost> hostStream) {
      when(
        portScannerService.scanPortsForSingleDevice(
          any,
          startPort: anyNamed('startPort'),
          endPort: anyNamed('endPort'),
          progressCallback: anyNamed('progressCallback'),
          timeout: anyNamed('timeout'),
          resultsInAddressAscendingOrder: anyNamed(
            'resultsInAddressAscendingOrder',
          ),
          async: anyNamed('async'),
        ),
      ).thenAnswer((_) => hostStream);
    }

    Future<void> pumpPortGroup(WidgetTester t) async {
      await t.pumpWidget(
        MaterialApp(
          home: PortGroup(
            address: '127.0.0.1',
            portScannerService: portScannerService,
          ),
        ),
      );
      await t.pumpAndSettle();
    }

    void assertBasicLayout(WidgetTester t) {
      expect(find.byType(FTileGroup), findsOneWidget);
      expect(find.text("Open Ports"), findsOneWidget);
    }

    testWidgets('shows empty state initially', (WidgetTester t) async {
      // Arrange
      setupPortScanExpectation(Stream<ActiveHost>.empty());

      // Act & Assert
      await pumpPortGroup(t);
      assertBasicLayout(t);

      // Expected port tiles
      expect(
        find.text(
          '${PortScannerService.defaultStartPort} - ${PortScannerService.defaultEndPort}',
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon && widget.color == Colors.red,
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows discovered ports at start port', (WidgetTester t) async {
      // Arrange
      final activeHost = MockActiveHost();
      when(activeHost.openPorts).thenAnswer(
        (_) => [OpenPort(PortScannerService.defaultStartPort, isOpen: true)],
      );
      setupPortScanExpectation(Stream.fromIterable([activeHost]));

      // Act & Assert
      await pumpPortGroup(t);
      assertBasicLayout(t);

      expect(
        find.text('${PortScannerService.defaultStartPort}'),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon && widget.color == Colors.green,
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows empty ports before first found port', (
      WidgetTester t,
    ) async {
      // Arrange: first found port is not the start port
      final firstPort = PortScannerService.defaultStartPort + 10;
      final activeHost = MockActiveHost();
      when(
        activeHost.openPorts,
      ).thenAnswer((_) => [OpenPort(firstPort, isOpen: true)]);
      setupPortScanExpectation(Stream.fromIterable([activeHost]));

      // Act & Assert
      await pumpPortGroup(t);
      assertBasicLayout(t);

      // Should show empty ports before first found port
      expect(
        find.text('${PortScannerService.defaultStartPort} - ${firstPort - 1}'),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon && widget.color == Colors.red,
        ),
        findsNWidgets(2),
      );
      // Should show the found port
      expect(find.text('$firstPort'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon && widget.color == Colors.green,
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows multiple discovered ports', (WidgetTester t) async {
      // Arrange
      final activeHost = MockActiveHost();
      when(activeHost.openPorts).thenAnswer(
        (_) => [OpenPort(80, isOpen: true), OpenPort(443, isOpen: true)],
      );
      setupPortScanExpectation(Stream.fromIterable([activeHost]));

      // Act & Assert
      await pumpPortGroup(t);
      assertBasicLayout(t);

      expect(find.text('80'), findsOneWidget);
      expect(find.text('http'), findsOneWidget);
      expect(find.text('443'), findsOneWidget);
      expect(find.text('https'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon && widget.color == Colors.green,
        ),
        findsNWidgets(2),
      );

      expect(find.text('81 - 442'), findsOneWidget);
      expect(
        find.text('444 - ${PortScannerService.defaultEndPort}'),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon && widget.color == Colors.red,
        ),
        findsNWidgets(3),
      );
    });

    testWidgets('show single gapped discovered ports', (WidgetTester t) async {
      // Arrange
      final activeHost = MockActiveHost();
      when(activeHost.openPorts).thenAnswer(
        (_) => [
          OpenPort(80, isOpen: true),
          OpenPort(82, isOpen: true),
          OpenPort(PortScannerService.defaultEndPort - 1, isOpen: true),
        ],
      );
      setupPortScanExpectation(Stream.fromIterable([activeHost]));

      // Act & Assert
      await pumpPortGroup(t);
      assertBasicLayout(t);

      expect(find.text('80'), findsOneWidget);
      expect(find.text('82'), findsOneWidget);
      expect(
        find.text("${PortScannerService.defaultEndPort - 1}"),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon && widget.color == Colors.green,
        ),
        findsNWidgets(3),
      );

      expect(find.text('81'), findsOneWidget);
      expect(
        find.text('83 - ${PortScannerService.defaultEndPort - 2}'),
        findsOneWidget,
      );
      expect(find.text("${PortScannerService.defaultEndPort}"), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon && widget.color == Colors.red,
        ),
        findsNWidgets(4),
      );
    });
  });
}
