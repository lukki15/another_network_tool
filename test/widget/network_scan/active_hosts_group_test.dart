import 'package:another_network_tool/widget/network_scan/active_hosts_group.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_tools/network_tools.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:forui/forui.dart';

@GenerateNiceMocks([MockSpec<ActiveHost>()])
@GenerateNiceMocks([MockSpec<NavigatorObserver>()])
@GenerateNiceMocks([MockSpec<PortScannerService>()])
import './active_hosts_group_test.mocks.dart';

void main() {
  late MockPortScannerService portScannerService;

  setUp(() {
    portScannerService = MockPortScannerService();
  });

  group('ActiveHostsGroup Tests', () {
    Future<MockNavigatorObserver> pumpActiveHostsGroup(
      WidgetTester t,
      Set<ActiveHost> activeHosts,
    ) async {
      final mockObserver = MockNavigatorObserver();
      await t.pumpWidget(
        MaterialApp(
          navigatorObservers: [mockObserver],
          home: ActiveHostsGroup(
            activeHosts: activeHosts,
            portScannerService: portScannerService,
          ),
        ),
      );

      await t.pumpAndSettle();
      return mockObserver;
    }

    MockActiveHost makeMockActiveHost() {
      var activeHost = MockActiveHost();
      when(activeHost.deviceName).thenAnswer((_) => Future.value("deviceName"));
      when(activeHost.address).thenAnswer((_) => "address");
      when(activeHost.vendor).thenAnswer(
        (_) => Future.value(
          Vendor(
            macPrefix: "macPrefix",
            vendorName: "vendorName",
            private: "private",
            blockType: "blockType",
            lastUpdate: "lastUpdate",
          ),
        ),
      );

      return activeHost;
    }

    testWidgets('without active hosts', (WidgetTester t) async {
      await pumpActiveHostsGroup(t, {});

      expect(find.byType(FTile), findsNothing);
    });

    testWidgets('with one active host', (WidgetTester t) async {
      await pumpActiveHostsGroup(t, {makeMockActiveHost()});

      expect(find.byType(FTile), findsOneWidget);
      expect(find.text("deviceName"), findsOneWidget);
      expect(find.text("address"), findsOneWidget);
      expect(find.text("vendorName"), findsOneWidget);
    });

    testWidgets('with two active host', (WidgetTester t) async {
      await pumpActiveHostsGroup(t, {
        makeMockActiveHost(),
        makeMockActiveHost(),
      });

      expect(find.byType(FTile), findsNWidgets(2));
      expect(find.text("deviceName"), findsNWidgets(2));
      expect(find.text("address"), findsNWidgets(2));
      expect(find.text("vendorName"), findsNWidgets(2));
    });

    testWidgets('on press', (WidgetTester t) async {
      var mockObserver = await pumpActiveHostsGroup(t, {makeMockActiveHost()});

      var tile = find.byType(FTile);
      expect(tile, findsOneWidget);

      await t.tap(tile);
      await t.pumpAndSettle();

      verify(mockObserver.didPush(any, any)).called(2);
    });

    testWidgets('on long press', (WidgetTester t) async {
      await pumpActiveHostsGroup(t, {makeMockActiveHost()});

      var tile = find.byType(FTile);
      expect(tile, findsOneWidget);

      await t.longPress(tile);
      await t.pumpAndSettle();

      // TODO: extend test
      // expect(await Clipboard.hasStrings(), true);
      // var clipBoardData = await Clipboard.getData(Clipboard.kTextPlain);
      // expect(clipBoardData!.text!, "address");
    });
  });
}
