import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:another_network_tool/widget/network_scan/active_hosts_group.dart';
import 'package:another_network_tool/provider/address_info.dart';
import 'package:another_network_tool/provider/config.dart';

class TestAddressInfo extends AddressInfo {
  TestAddressInfo(String address) : super(address: address, isReachable: true);

  @override
  Future<String> getHostName() => Future.value('host-$address');
}

void main() {
  testWidgets('inserts new host without losing existing tiles', (tester) async {
    final a = TestAddressInfo('192.168.1.2');
    final b = TestAddressInfo('192.168.1.3');

    await tester.pumpWidget(
      MaterialApp(
        home: ActiveHostsGroup(activeHosts: {a}, config: Config()),
      ),
    );

    // initial assertions
    await tester.pumpAndSettle();
    expect(find.text('host-192.168.1.2'), findsOneWidget);

    // Rebuild with an additional host
    await tester.pumpWidget(
      MaterialApp(
        home: ActiveHostsGroup(activeHosts: {a, b}, config: Config()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('host-192.168.1.2'), findsOneWidget);
    expect(find.text('host-192.168.1.3'), findsOneWidget);
  });

  testWidgets('removes host and animates out', (tester) async {
    final a = TestAddressInfo('192.168.1.2');
    final b = TestAddressInfo('192.168.1.3');

    await tester.pumpWidget(
      MaterialApp(
        home: ActiveHostsGroup(activeHosts: {a, b}, config: Config()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('host-192.168.1.2'), findsOneWidget);
    expect(find.text('host-192.168.1.3'), findsOneWidget);

    // Rebuild with one removed
    await tester.pumpWidget(
      MaterialApp(
        home: ActiveHostsGroup(activeHosts: {a}, config: Config()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('host-192.168.1.3'), findsNothing);
    expect(find.text('host-192.168.1.2'), findsOneWidget);
  });
}
