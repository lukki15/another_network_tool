import 'package:another_network_tool/pages/device_info.dart';
import 'package:another_network_tool/provider/address_info.dart';
import 'package:another_network_tool/provider/config.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:network_tools/network_tools.dart';

@GenerateNiceMocks([MockSpec<AddressInfo>()])
@GenerateNiceMocks([MockSpec<HostScannerService>()])
@GenerateNiceMocks([MockSpec<PortScannerService>()])
import './device_info_test.mocks.dart';

void main() {
  late MockAddressInfo addressInfo;
  late MockHostScannerService hostScannerService;
  late MockPortScannerService portScannerService;

  setUp(() {
    addressInfo = MockAddressInfo();
    hostScannerService = MockHostScannerService();
    portScannerService = MockPortScannerService();
  });

  group('DeviceInfo', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      // Setup mock behavior
      when(addressInfo.address).thenReturn('192.168.1.100');
      when(
        addressInfo.getHostName(),
      ).thenAnswer((_) => Future.value('Test Device'));

      await tester.pumpWidget(
        MaterialApp(
          home: DeviceInfo(
            activeHost: addressInfo,
            config: Config(
              hostScannerService: hostScannerService,
              portScannerService: portScannerService,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify basic widget structure
      expect(find.byType(DeviceInfo), findsOneWidget);
      expect(find.text('Test Device'), findsOneWidget);

      // Verify device information tiles
      expect(find.text('IP Address'), findsOneWidget);
      expect(find.text('192.168.1.100'), findsOneWidget);
    });

    testWidgets('handles loading states', (WidgetTester tester) async {
      // Setup mock with delayed response
      when(addressInfo.getHostName()).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 500),
          () => 'Loaded Device',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DeviceInfo(
            activeHost: addressInfo,
            config: Config(
              hostScannerService: hostScannerService,
              portScannerService: portScannerService,
            ),
          ),
        ),
      );

      // Initial pump should show loading
      expect(find.byType(CircularProgressIndicator), findsAtLeast(1));

      // Wait for data to load
      await tester.pumpAndSettle();

      // Verify loaded content
      expect(find.text('Loaded Device'), findsOneWidget);
    });

    testWidgets('copy operations work', (WidgetTester tester) async {
      // Setup mock behaviors
      when(addressInfo.address).thenReturn('192.168.1.100');

      await tester.pumpWidget(
        MaterialApp(
          home: DeviceInfo(
            activeHost: addressInfo,
            config: Config(
              hostScannerService: hostScannerService,
              portScannerService: portScannerService,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test IP address copy
      final ipAddressTile = find.text('IP Address').first;
      await tester.longPress(ipAddressTile);
      // TODO: check copied ip address

      await tester.pumpAndSettle();
    });
  });
}
