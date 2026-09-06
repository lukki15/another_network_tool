import 'package:another_network_tool/pages/device_info_summary_card.dart';
import 'package:another_network_tool/provider/address_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeviceInfoSummaryCard', () {
    testWidgets('renders device information', (tester) async {
      const address = '192.168.1.42';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceInfoSummaryCard(
              activeHost: AddressInfo(address: address, isReachable: true),
            ),
          ),
        ),
      );

      expect(find.text('Device Details'), findsOneWidget);
      expect(find.text('IP Address'), findsOneWidget);
      expect(find.text(address), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);
      expect(find.byIcon(Icons.devices), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('copy button copies the device IP address', (tester) async {
      const address = '10.0.0.42';
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
          home: Scaffold(
            body: DeviceInfoSummaryCard(
              activeHost: AddressInfo(address: address, isReachable: true),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();

      expect(copiedText, address);
    });

    testWidgets('renders correctly for another reachable address', (
      tester,
    ) async {
      const address = '127.0.0.1';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceInfoSummaryCard(
              activeHost: AddressInfo(address: address, isReachable: true),
            ),
          ),
        ),
      );

      expect(find.text(address), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);
    });
  });
}
