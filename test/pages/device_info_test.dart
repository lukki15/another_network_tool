import 'package:another_network_tool/pages/device_info.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:network_tools/network_tools.dart';

@GenerateNiceMocks([MockSpec<ActiveHost>()])
@GenerateNiceMocks([MockSpec<PortScannerService>()])
import './device_info_test.mocks.dart';

void main() {
  late MockActiveHost mockActiveHost;
  late MockPortScannerService mockPortScannerService;

  setUp(() {
    mockActiveHost = MockActiveHost();
    mockPortScannerService = MockPortScannerService();
  });

  group('DeviceInfo', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      // Setup mock behavior
      when(mockActiveHost.address).thenReturn('192.168.1.100');
      when(
        mockActiveHost.deviceName,
      ).thenAnswer((_) => Future.value('Test Device'));
      when(mockActiveHost.vendor).thenAnswer(
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

      await tester.pumpWidget(
        MaterialApp(
          home: DeviceInfo(
            activeHost: mockActiveHost,
            portScannerService: mockPortScannerService,
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
      expect(find.text('MAC Address'), findsOneWidget);
      expect(find.text('vendorName'), findsOneWidget);
    });

    testWidgets('handles loading states', (WidgetTester tester) async {
      // Setup mock with delayed response
      when(mockActiveHost.deviceName).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 500),
          () => 'Loaded Device',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DeviceInfo(
            activeHost: mockActiveHost,
            portScannerService: mockPortScannerService,
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
      when(mockActiveHost.address).thenReturn('192.168.1.100');
      when(
        mockActiveHost.getMacAddress(),
      ).thenAnswer((_) => Future.value('00:11:22:33:44:55'));
      when(mockActiveHost.vendor).thenAnswer(
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

      await tester.pumpWidget(
        MaterialApp(
          home: DeviceInfo(
            activeHost: mockActiveHost,
            portScannerService: mockPortScannerService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test IP address copy
      final ipAddressTile = find.text('IP Address').first;
      await tester.longPress(ipAddressTile);
      // TODO: check copied ip address

      // Test MAC address copy
      final macAddressTile = find.text('MAC Address').first;
      await tester.longPress(macAddressTile);
      // TODO: check copied mac address

      // Test vendor copy
      final vendorTile = find.text('Vendor Name').first;
      await tester.longPress(vendorTile);
      // TODO: check copied vendor name

      await tester.pumpAndSettle();
    });
  });
}
