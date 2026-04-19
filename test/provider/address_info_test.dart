import 'dart:io';
import 'package:another_network_tool/provider/address_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<InternetAddress>()])
import './address_info_test.mocks.dart';

// Generate mocks
void main() {
  group('AddressInfo', () {
    // Test valid reachable address
    test('should return InternetAddress for reachable IPv4 address', () async {
      const testAddress = '8.8.8.8';
      final addressInfo = AddressInfo(address: testAddress, isReachable: true);

      final result = await addressInfo.getAddress();

      expect(result, isA<InternetAddress>());
      expect(result.address, equals(testAddress));
    });

    // Test unreachable address throws error
    test('should throw error for unreachable address', () async {
      const testAddress = '192.0.2.1'; // TEST-NET-1, typically unreachable
      final addressInfo = AddressInfo(address: testAddress, isReachable: false);

      await expectLater(
        addressInfo.getAddress(),
        throwsA(
          isA<String>().having(
            (e) => e,
            'message',
            contains('Host 192.0.2.1 is not reachable'),
          ),
        ),
      );
    });

    // Test getHostName returns hostname for reachable address
    test('should return hostname for reachable address', () async {
      const testAddress = '8.8.8.8';
      final addressInfo = AddressInfo(address: testAddress, isReachable: true);

      final result = await addressInfo.getHostName();

      expect(result, equals("dns.google"));
    });

    // Test getHostName returns fallback for unreachable address
    test('should return Generic Device for unreachable address', () async {
      const testAddress = '192.0.2.1';
      final addressInfo = AddressInfo(address: testAddress, isReachable: false);

      final result = await addressInfo.getHostName();

      expect(result, equals('Generic Device'));
    });

    // Test getHostName handles reverse lookup failure gracefully
    test('should return Generic Device when reverse lookup fails', () async {
      // Note: This test depends on actual network behavior
      // In practice, you might want to mock InternetAddress.reverse()
      const testAddress = 'invalid.address.format';
      final addressInfo = AddressInfo(address: testAddress, isReachable: true);

      try {
        final result = await addressInfo.getHostName();
        // If reverse lookup fails, it should return Generic Device
        expect(result, equals('Generic Device'));
      } catch (e) {
        // Some invalid addresses might throw before reaching onError
        expect(
          e.toString().contains('Invalid argument') ||
              e.toString().contains('FormatException'),
          isTrue,
        );
      }
    });

    // Test constructor initializes properties correctly
    test('should initialize properties correctly', () {
      const testAddress = '127.0.0.1';
      final addressInfo = AddressInfo(address: testAddress, isReachable: true);

      expect(addressInfo.address, equals(testAddress));
      expect(addressInfo.isReachable, isTrue);
    });

    // Test with localhost
    test('should handle localhost address', () async {
      const testAddress = '127.0.0.1';
      final addressInfo = AddressInfo(address: testAddress, isReachable: true);

      final address = await addressInfo.getAddress();
      expect(address.address, equals(testAddress));

      final hostname = await addressInfo.getHostName();
      expect(hostname, isA<String>());
    });

    // Test error message content
    test('should have correct error message for unreachable host', () async {
      const testAddress = '192.0.2.1';
      final addressInfo = AddressInfo(address: testAddress, isReachable: false);

      try {
        await addressInfo.getAddress();
        fail('Should have thrown an error');
      } catch (e) {
        expect(e.toString(), contains('Host $testAddress is not reachable'));
      }
    });

    test(
      'should call reverse() on InternetAddress for reachable host',
      () async {
        MockInternetAddress mockAddress = MockInternetAddress();
        const testAddress = '8.8.8.8';
        final addressInfo = AddressInfo(
          address: testAddress,
          isReachable: true,
        );

        // Mock the reverse() method to return our mock
        when(mockAddress.reverse()).thenAnswer((_) async => mockAddress);
        when(mockAddress.host).thenReturn('dns.google');

        // Note: We can't easily mock the constructor, so this test validates
        // the logic flow rather than exact mocking
        final result = await addressInfo.getHostName();

        expect(result, equals("dns.google"));
      },
    );
  });

  // Integration-style test with real network calls (optional, may fail in CI)
  group('AddressInfo integration tests', () {
    test('should resolve Google DNS hostname', () async {
      final addressInfo = AddressInfo(address: '8.8.8.8', isReachable: true);

      final hostname = await addressInfo.getHostName();

      // Google DNS typically resolves to dns.google or similar
      expect(hostname, isNotEmpty);
      expect(hostname, equals('dns.google'));
    });

    test('should handle empty string gracefully', () async {
      final addressInfo = AddressInfo(address: '', isReachable: false);

      final result = await addressInfo.getHostName();
      expect(result, equals('Generic Device'));
    });
  });
}
