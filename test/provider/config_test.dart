// test/config_test.dart
import 'dart:async';

import 'package:another_network_tool/provider/address_info.dart';
import 'package:another_network_tool/provider/config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_tools/network_tools.dart' hide ProgressCallback;

import 'config_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ActiveHost>()])
@GenerateNiceMocks([MockSpec<HostScannerService>()])
@GenerateNiceMocks([MockSpec<PortScannerService>()])
void main() {
  late MockHostScannerService mockHostScannerService;
  late MockPortScannerService mockPortScannerService;
  late Config config;

  setUp(() {
    mockHostScannerService = MockHostScannerService();
    mockPortScannerService = MockPortScannerService();
    config = Config(
      hostScannerService: mockHostScannerService,
      portScannerService: mockPortScannerService,
    );
  });

  group('Config Constructor', () {
    test('creates Config with required services', () {
      expect(config.hostScannerService, equals(mockHostScannerService));
      expect(config.portScannerService, equals(mockPortScannerService));
    });

    test('defaultFirstHostId is 1', () {
      expect(Config.defaultFirstHostId, equals(1));
    });

    test('defaultLastHostId is 254', () {
      expect(Config.defaultLastHostId, equals(254));
    });
  });

  group('pingHosts', () {
    late StreamController<ActiveHost> controller;

    setUp(() {
      controller = StreamController<ActiveHost>();
    });

    tearDown(() {
      controller.close();
    });

    test('delegates to hostScannerService.getAllPingableDevicesAsync', () {
      // Arrange
      when(
        mockHostScannerService.getAllPingableDevicesAsync(
          '192.168.1.0/24',
          progressCallback: anyNamed('progressCallback'),
        ),
      ).thenAnswer((_) => controller.stream);

      // Act
      final result = config.pingHosts('192.168.1.0/24');

      // Assert
      verify(
        mockHostScannerService.getAllPingableDevicesAsync(
          '192.168.1.0/24',
          progressCallback: anyNamed('progressCallback'),
        ),
      ).called(1);
      expect(result, isA<Stream<AddressInfo>>());
    });

    test('passes progressCallback when provided', () {
      // Arrange
      ProgressCallback? capturedCallback;
      when(
        mockHostScannerService.getAllPingableDevicesAsync(
          '192.168.1.0/24',
          progressCallback: anyNamed('progressCallback'),
        ),
      ).thenAnswer((invocation) {
        capturedCallback = invocation.namedArguments[#progressCallback];
        return controller.stream;
      });

      // Act
      void progressCallback(double progress) {}
      config.pingHosts('192.168.1.0/24', progressCallback: progressCallback);

      // Assert
      expect(capturedCallback, equals(progressCallback));
    });

    test(
      'transforms HostScanResult to AddressInfo with isReachable=true',
      () async {
        // Arrange
        var activeHost1 = MockActiveHost();
        when(activeHost1.address).thenReturn('192.168.1.1');
        controller.add(activeHost1);
        var activeHost2 = MockActiveHost();
        when(activeHost2.address).thenReturn('192.168.1.2');
        controller.add(activeHost2);
        controller.close();

        when(
          mockHostScannerService.getAllPingableDevicesAsync(
            '192.168.1.0/24',
            progressCallback: anyNamed('progressCallback'),
          ),
        ).thenAnswer((_) => controller.stream);

        // Act
        final result = config.pingHosts('192.168.1.0/24');

        // Assert
        final addresses = await result.toList();
        expect(addresses.length, equals(2));
        expect(addresses[0].address, equals('192.168.1.1'));
        expect(addresses[0].isReachable, isTrue);
        expect(addresses[1].address, equals('192.168.1.2'));
        expect(addresses[1].isReachable, isTrue);
      },
    );

    test('handles empty stream correctly', () async {
      // Arrange
      when(
        mockHostScannerService.getAllPingableDevicesAsync(
          '192.168.1.0/24',
          progressCallback: anyNamed('progressCallback'),
        ),
      ).thenAnswer((_) => Stream.empty());

      // Act
      final result = config.pingHosts('192.168.1.0/24');

      // Assert
      final addresses = await result.toList();
      expect(addresses.isEmpty, isTrue);
    });

    test('emits errors from underlying stream', () async {
      // Arrange
      when(
        mockHostScannerService.getAllPingableDevicesAsync(
          '192.168.1.0/24',
          progressCallback: anyNamed('progressCallback'),
        ),
      ).thenAnswer((_) => Stream.error(Exception('Network error')));

      // Act & Assert
      final result = config.pingHosts('192.168.1.0/24');
      await expectLater(result, emitsError(isA<Exception>()));
    });
  });

  group('Integration-style tests', () {
    test('full flow with mock data', () async {
      // Arrange
      final mockResults = [
        MockActiveHost(), // TODO: add specific address data to the mock
        MockActiveHost(),
        MockActiveHost(),
      ];
      when(mockResults[0].address).thenReturn('192.168.1.1');
      when(mockResults[1].address).thenReturn('192.168.1.10');
      when(mockResults[2].address).thenReturn('192.168.1.100');

      when(
        mockHostScannerService.getAllPingableDevicesAsync(
          '192.168.1.0/24',
          progressCallback: anyNamed('progressCallback'),
        ),
      ).thenAnswer((_) => Stream.fromIterable(mockResults));

      // Act
      final result = config.pingHosts('192.168.1.0/24');

      // Assert
      final addresses = await result.toList();
      expect(addresses.length, equals(3));
      expect(
        addresses.map((a) => a.address).toList(),
        equals(['192.168.1.1', '192.168.1.10', '192.168.1.100']),
      );
      expect(addresses.every((a) => a.isReachable == true), isTrue);
    });
  });

  group('scanPort', () {
    late StreamController<ActiveHost> controller;

    setUp(() {
      controller = StreamController<ActiveHost>();
    });

    tearDown(() {
      controller.close();
    });

    test('delegates to portScannerService.scanPortsForSingleDevice', () {
      // Arrange
      when(
        mockPortScannerService.scanPortsForSingleDevice('192.168.1.1'),
      ).thenAnswer((_) => controller.stream);

      // Act
      final result = config.scanPort('192.168.1.1');

      // Assert
      verify(
        mockPortScannerService.scanPortsForSingleDevice('192.168.1.1'),
      ).called(1);
      expect(result, isA<Stream<int>>());
    });

    test('extracts and returns port numbers from openPorts', () async {
      // Arrange
      final mockHost = MockActiveHost();
      when(mockHost.address).thenReturn('192.168.1.1');
      when(mockHost.openPorts).thenReturn([
        OpenPort(80, isOpen: true),
        OpenPort(443, isOpen: true),
        OpenPort(8080, isOpen: true),
      ]);
      controller.add(mockHost);
      controller.close();

      when(
        mockPortScannerService.scanPortsForSingleDevice('192.168.1.1'),
      ).thenAnswer((_) => controller.stream);

      // Act
      final result = config.scanPort('192.168.1.1');

      // Assert
      final ports = await result.toList();
      expect(ports.length, equals(3));
      expect(ports, equals([80, 443, 8080]));
    });

    test('handles multiple hosts with multiple open ports', () async {
      // Arrange
      final mockHost1 = MockActiveHost();
      when(mockHost1.address).thenReturn('192.168.1.1');
      when(
        mockHost1.openPorts,
      ).thenReturn([OpenPort(80, isOpen: true), OpenPort(443, isOpen: true)]);

      final mockHost2 = MockActiveHost();
      when(mockHost2.address).thenReturn('192.168.1.1');
      when(mockHost2.openPorts).thenReturn([
        OpenPort(3306, isOpen: true),
        OpenPort(5432, isOpen: true),
      ]);

      controller.add(mockHost1);
      controller.add(mockHost2);
      controller.close();

      when(
        mockPortScannerService.scanPortsForSingleDevice('192.168.1.1'),
      ).thenAnswer((_) => controller.stream);

      // Act
      final result = config.scanPort('192.168.1.1');

      // Assert
      final ports = await result.toList();
      expect(ports.length, equals(4));
      expect(ports, equals([80, 443, 3306, 5432]));
    });

    test('handles host with single open port', () async {
      // Arrange
      final mockHost = MockActiveHost();
      when(mockHost.address).thenReturn('192.168.1.1');
      when(mockHost.openPorts).thenReturn([OpenPort(22, isOpen: true)]);
      controller.add(mockHost);
      controller.close();

      when(
        mockPortScannerService.scanPortsForSingleDevice('192.168.1.1'),
      ).thenAnswer((_) => controller.stream);

      // Act
      final result = config.scanPort('192.168.1.1');

      // Assert
      final ports = await result.toList();
      expect(ports.length, equals(1));
      expect(ports[0], equals(22));
    });

    test('handles host with no open ports', () async {
      // Arrange
      final mockHost = MockActiveHost();
      when(mockHost.address).thenReturn('192.168.1.1');
      when(mockHost.openPorts).thenReturn([]);
      controller.add(mockHost);
      controller.close();

      when(
        mockPortScannerService.scanPortsForSingleDevice('192.168.1.1'),
      ).thenAnswer((_) => controller.stream);

      // Act
      final result = config.scanPort('192.168.1.1');

      // Assert
      final ports = await result.toList();
      expect(ports.isEmpty, isTrue);
    });

    test('handles empty stream correctly', () async {
      // Arrange
      when(
        mockPortScannerService.scanPortsForSingleDevice('192.168.1.1'),
      ).thenAnswer((_) => Stream.empty());

      // Act
      final result = config.scanPort('192.168.1.1');

      // Assert
      final ports = await result.toList();
      expect(ports.isEmpty, isTrue);
    });

    test('emits errors from underlying stream', () async {
      // Arrange
      when(
        mockPortScannerService.scanPortsForSingleDevice('192.168.1.1'),
      ).thenAnswer((_) => Stream.error(Exception('Port scan error')));

      // Act & Assert
      final result = config.scanPort('192.168.1.1');
      await expectLater(result, emitsError(isA<Exception>()));
    });
  });
}
