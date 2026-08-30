import 'package:flutter_test/flutter_test.dart';
import 'package:another_network_tool/utils/subnet.dart';

void main() {
  test('192.168.1.42 + 255.255.255.0 => 192.168.1.0/24', () {
    final s = Subnet.fromIpAndMask('192.168.1.42', '255.255.255.0');
    expect(s.networkAddress, '192.168.1.0');
    expect(s.prefixLength, 24);
  });

  test('192.168.1.42 + 255.255.254.0 => 192.168.0.0/23', () {
    final s = Subnet.fromIpAndMask('192.168.1.42', '255.255.254.0');
    expect(s.networkAddress, '192.168.0.0');
    expect(s.prefixLength, 23);
  });

  test('10.10.42.15 + 255.255.0.0 => 10.10.0.0/16', () {
    final s = Subnet.fromIpAndMask('10.10.42.15', '255.255.0.0');
    expect(s.networkAddress, '10.10.0.0');
    expect(s.prefixLength, 16);
  });

  test('10.10.42.15 + 255.255.255.240 => 10.10.42.0/28', () {
    final s = Subnet.fromIpAndMask('10.10.42.15', '255.255.255.240');
    expect(s.networkAddress, '10.10.42.0');
    expect(s.prefixLength, 28);
  });

  test('invalid mask throws', () {
    expect(
      () => Subnet.fromIpAndMask('10.0.0.1', '255.0.255.0'),
      throwsFormatException,
    );
  });
}
