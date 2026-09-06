import 'package:another_network_tool/provider/address_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddressInfo failure handling', () {
    test('getAddress fails for unreachable host', () async {
      final address = AddressInfo(address: '192.168.1.99', isReachable: false);

      await expectLater(
        address.getAddress(),
        throwsA(
          predicate(
            (Object error) =>
                error.toString() == 'Host 192.168.1.99 is not reachable',
          ),
        ),
      );
    });

    test('getHostName returns generic device for unreachable host', () async {
      final address = AddressInfo(address: '192.168.1.99', isReachable: false);

      expect(await address.getHostName(), 'Generic Device');
    });

    test('getHostName returns generic device when reverse DNS fails', () async {
      final address = AddressInfo(address: '0.0.0.0', isReachable: true);

      expect(await address.getHostName(), 'Generic Device');
    });
  });
}
