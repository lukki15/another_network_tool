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
void main() {
  late MockHostScannerService mockHostScannerService;
  late Config config;

  setUp(() {
    mockHostScannerService = MockHostScannerService();
    config = Config(hostScannerService: mockHostScannerService);
  });

  group('Config Constructor', () {
    test('creates Config with required services', () {
      expect(config.hostScannerService, equals(mockHostScannerService));
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
}
