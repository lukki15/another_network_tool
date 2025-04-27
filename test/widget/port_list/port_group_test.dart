import 'dart:io';

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

    testWidgets('shows empty state initially', (WidgetTester t) async {
      // Arrange
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
      ).thenAnswer((_) => Stream<ActiveHost>.empty());

      // Act
      await t.pumpWidget(
        MaterialApp(
          home: PortGroup(
            address: '127.0.0.1',
            portScannerService: portScannerService,
          ),
        ),
      );
      await t.pump();

      // Assert
      expect(find.byType(FTileGroup), findsOneWidget);
      expect(find.text("Open Ports"), findsOneWidget);

      // Verify the default range tile
      expect(
        find.text(
          '${PortScannerService.defaultStartPort} - ${PortScannerService.defaultEndPort}',
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) => widget is FIcon && widget.color == Colors.red,
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows discovered ports', (WidgetTester t) async {
      // Arrange
      var activeHost = MockActiveHost();
      when(
        activeHost.openPorts,
      ).thenAnswer((_) => [OpenPort(80, isOpen: true)]);

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
      ).thenAnswer((_) => Stream.fromIterable([activeHost]));

      // Act
      await t.pumpWidget(
        MaterialApp(
          home: PortGroup(
            address: '127.0.0.1',
            portScannerService: portScannerService,
          ),
        ),
      );

      // Wait for the stream to complete
      await t.pumpAndSettle();

      // Assert
      expect(find.byType(FTileGroup), findsOneWidget);
      expect(find.text("Open Ports"), findsOneWidget);

      // Verify the open port tile
      // expect(find.byIcon(FAssets.icons.circleDot), findsOneWidget);
      expect(find.text('80'), findsOneWidget);
      expect(find.text('http'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is FIcon && widget.color == Colors.green,
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows multiple discovered ports', (WidgetTester t) async {
      // Arrange
      var activeHost = MockActiveHost();
      when(activeHost.openPorts).thenAnswer(
        (_) => [OpenPort(80, isOpen: true), OpenPort(443, isOpen: true)],
      );

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
      ).thenAnswer((_) => Stream.fromIterable([activeHost]));

      // Act
      await t.pumpWidget(
        MaterialApp(
          home: PortGroup(
            address: '127.0.0.1',
            portScannerService: portScannerService,
          ),
        ),
      );

      // Wait for the stream to complete
      await t.pumpAndSettle();

      // Assert
      expect(find.byType(FTileGroup), findsOneWidget);
      expect(find.text("Open Ports"), findsOneWidget);

      // Verify the open port tiles
      expect(find.text('80'), findsOneWidget);
      expect(find.text('http'), findsOneWidget);
      expect(find.text('443'), findsOneWidget);
      expect(find.text('https'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is FIcon && widget.color == Colors.green,
        ),
        findsNWidgets(2),
      );

      // Verify the closed port ranges
      expect(find.text('81 - 442'), findsOneWidget);
      expect(
        find.text('444 - ${PortScannerService.defaultEndPort}'),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) => widget is FIcon && widget.color == Colors.red,
        ),
        findsNWidgets(2),
      );
    });
  });
}
