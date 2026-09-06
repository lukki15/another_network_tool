import 'package:another_network_tool/utils/subnet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Subnet.firstHostInt and lastHostInt', () {
    test('/30 excludes network and broadcast addresses', () {
      final subnet = Subnet('192.168.1.0', 30);

      expect(subnet.firstHostInt(), _ipToInt('192.168.1.1'));
      expect(subnet.lastHostInt(), _ipToInt('192.168.1.2'));
    });

    test('/31 returns both addresses', () {
      final subnet = Subnet('192.168.1.0', 31);

      expect(subnet.firstHostInt(), _ipToInt('192.168.1.0'));
      expect(subnet.lastHostInt(), _ipToInt('192.168.1.1'));
    });

    test('/32 returns the single address', () {
      final subnet = Subnet('192.168.1.42', 32);

      expect(subnet.firstHostInt(), _ipToInt('192.168.1.42'));
      expect(subnet.lastHostInt(), _ipToInt('192.168.1.42'));
    });

    test('/0 covers the entire IPv4 range', () {
      final subnet = Subnet('0.0.0.0', 0);

      expect(subnet.firstHostInt(), _ipToInt('0.0.0.1'));
      expect(subnet.lastHostInt(), _ipToInt('255.255.255.254'));
    });
  });

  group('Subnet.fromIpAndMask validation', () {
    test('rejects invalid IPv4 address with too few octets', () {
      expect(
        () => Subnet.fromIpAndMask('192.168.1', '255.255.255.0'),
        throwsFormatException,
      );
    });

    test('rejects invalid IPv4 address with too many octets', () {
      expect(
        () => Subnet.fromIpAndMask('192.168.1.1.1', '255.255.255.0'),
        throwsFormatException,
      );
    });

    test('rejects IPv4 octet greater than 255', () {
      expect(
        () => Subnet.fromIpAndMask('192.168.1.256', '255.255.255.0'),
        throwsFormatException,
      );
    });

    test('rejects negative IPv4 octet', () {
      expect(
        () => Subnet.fromIpAndMask('192.168.-1.1', '255.255.255.0'),
        throwsFormatException,
      );
    });

    test('rejects mask octet greater than 255', () {
      expect(
        () => Subnet.fromIpAndMask('192.168.1.1', '255.255.255.256'),
        throwsFormatException,
      );
    });

    test('accepts /0 mask', () {
      final subnet = Subnet.fromIpAndMask('192.168.1.42', '0.0.0.0');

      expect(subnet.networkAddress, '0.0.0.0');
      expect(subnet.prefixLength, 0);
    });

    test('accepts /32 mask', () {
      final subnet = Subnet.fromIpAndMask('192.168.1.42', '255.255.255.255');

      expect(subnet.networkAddress, '192.168.1.42');
      expect(subnet.prefixLength, 32);
    });
  });

  group('Subnet.toString', () {
    test('returns CIDR representation', () {
      final subnet = Subnet('192.168.1.0', 24);

      expect(subnet.toString(), '192.168.1.0/24');
    });
  });
}

int _ipToInt(String ip) {
  final parts = ip.split('.').map(int.parse).toList();

  return (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8) | parts[3];
}
