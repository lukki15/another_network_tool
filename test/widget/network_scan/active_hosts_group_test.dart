import 'package:another_network_tool/provider/address_info.dart';
import 'package:another_network_tool/provider/config.dart';
import 'package:another_network_tool/widget/network_scan/active_hosts_group.dart';
import 'package:dart_ping/dart_ping.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<AddressInfo>()])
@GenerateNiceMocks([MockSpec<NavigatorObserver>()])
import './active_hosts_group_test.mocks.dart';

void main() {
  group('ActiveHostsGroup Tests', () {
    Future<PingData> mockPingDataProvider(String host) async {
      return PingData();
    }

    Stream<int> mockPortScanner(
      String target, {
      int startPort = Config.defaultStartPort,
      int endPort = Config.defaultEndPort,
    }) {
      return Stream.empty();
    }

    Future<MockNavigatorObserver> pumpActiveHostsGroup(
      WidgetTester t,
      Set<AddressInfo> activeHosts,
    ) async {
      final mockObserver = MockNavigatorObserver();
      await t.pumpWidget(
        MaterialApp(
          navigatorObservers: [mockObserver],
          home: Scaffold(
            body: ActiveHostsGroup(
              activeHosts: activeHosts,
              config: Config(
                pingDataProvider: mockPingDataProvider,
                portScanner: mockPortScanner,
              ),
            ),
          ),
        ),
      );

      await t.pumpAndSettle();
      return mockObserver;
    }

    MockAddressInfo makeMockAddressInfo() {
      var addressInfo = MockAddressInfo();
      when(
        addressInfo.getHostName(),
      ).thenAnswer((_) => Future.value("deviceName"));
      when(addressInfo.address).thenAnswer((_) => "address");

      return addressInfo;
    }

    testWidgets('without active hosts', (WidgetTester t) async {
      await pumpActiveHostsGroup(t, {});

      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('with one active host', (WidgetTester t) async {
      await pumpActiveHostsGroup(t, {makeMockAddressInfo()});

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text("deviceName"), findsOneWidget);
      expect(find.text("address"), findsOneWidget);
    });

    testWidgets('with two active host', (WidgetTester t) async {
      await pumpActiveHostsGroup(t, {
        makeMockAddressInfo(),
        makeMockAddressInfo(),
      });

      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.text("deviceName"), findsNWidgets(2));
      expect(find.text("address"), findsNWidgets(2));
    });

    testWidgets('on press', (WidgetTester t) async {
      var mockObserver = await pumpActiveHostsGroup(t, {makeMockAddressInfo()});

      var tile = find.byType(ListTile);
      expect(tile, findsOneWidget);

      await t.tap(tile);
      await t.pumpAndSettle();

      verify(mockObserver.didPush(any, any)).called(2);
    });

    testWidgets('on long press', (WidgetTester t) async {
      await pumpActiveHostsGroup(t, {makeMockAddressInfo()});

      var tile = find.byType(ListTile);
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
