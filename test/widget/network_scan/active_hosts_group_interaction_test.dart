import 'package:another_network_tool/pages/device_info.dart';
import 'package:another_network_tool/provider/address_info.dart';
import 'package:another_network_tool/provider/config.dart';
import 'package:another_network_tool/widget/network_scan/active_hosts_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class TestAddressInfo extends AddressInfo {
  TestAddressInfo(String address) : super(address: address, isReachable: true);

  @override
  Future<String> getHostName() => Future.value('host-$address');
}

void main() {
  group('ActiveHostsGroup interactions', () {
    testWidgets('shows empty state when there are no hosts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ActiveHostsGroup(
            activeHosts: const <AddressInfo>{},
            config: Config(),
          ),
        ),
      );

      expect(find.text('No devices discovered yet'), findsOneWidget);
    });

    testWidgets('tapping a host opens DeviceInfo', (tester) async {
      final host = TestAddressInfo('192.168.1.10');

      await tester.pumpWidget(
        MaterialApp(
          home: ActiveHostsGroup(
            activeHosts: {host},
            config: Config(
              portScanner: (
                String target, {
                int startPort = 1,
                int endPort = 1024,
              }) => Stream<int>.empty(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('192.168.1.10'), findsOneWidget);

      await tester.tap(find.text('192.168.1.10'));
      await tester.pumpAndSettle();

      expect(find.byType(DeviceInfo), findsOneWidget);
      expect(find.text('Device Details'), findsOneWidget);
      expect(find.text('192.168.1.10'), findsOneWidget);
    });

    testWidgets('long press copies host address', (tester) async {
      final host = TestAddressInfo('192.168.1.20');

      String? copiedText;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              final arguments = Map<String, dynamic>.from(
                call.arguments as Map,
              );
              copiedText = arguments['text'] as String?;
            }
            return null;
          });

      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ActiveHostsGroup(activeHosts: {host}, config: Config()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.longPress(find.text('192.168.1.20'));
      await tester.pump();

      expect(copiedText, '192.168.1.20');
    });

    testWidgets('retains existing host when another host is inserted', (
      tester,
    ) async {
      final first = TestAddressInfo('192.168.1.10');
      final second = TestAddressInfo('192.168.1.11');

      await tester.pumpWidget(
        MaterialApp(
          home: ActiveHostsGroup(activeHosts: {first}, config: Config()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: ActiveHostsGroup(
            activeHosts: {first, second},
            config: Config(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('host-192.168.1.10'), findsOneWidget);
      expect(find.text('host-192.168.1.11'), findsOneWidget);
    });

    testWidgets('removes host when it disappears from activeHosts', (
      tester,
    ) async {
      final first = TestAddressInfo('192.168.1.10');
      final second = TestAddressInfo('192.168.1.11');

      await tester.pumpWidget(
        MaterialApp(
          home: ActiveHostsGroup(
            activeHosts: {first, second},
            config: Config(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: ActiveHostsGroup(activeHosts: {first}, config: Config()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('host-192.168.1.10'), findsOneWidget);
      expect(find.text('host-192.168.1.11'), findsNothing);
    });
  });
}
