import 'dart:io';

import 'package:another_network_tool/provider/port_scanner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('scanPortsForSingleDevice', () {
    test('empty target IP throws ArgumentError', () {
      expect(() => scanPortsForSingleDevice(''), throwsArgumentError);
    });

    test('returns open ports in ascending order', () async {
      final server1 = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final server2 = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final openPorts = [server1.port, server2.port]..sort();
      final startPort = openPorts.first > 1
          ? openPorts.first - 1
          : openPorts.first;
      final endPort = openPorts.last + 1;

      final ports = await scanPortsForSingleDevice(
        InternetAddress.loopbackIPv4.address,
        startPort: startPort,
        endPort: endPort,
      ).toList();

      expect(ports, containsAll(openPorts));

      await server1.close();
      await server2.close();
    });

    test('returns empty stream when no ports are open in range', () async {
      const startPort = 62000;
      const endPort = 62005;

      final ports = await scanPortsForSingleDevice(
        InternetAddress.loopbackIPv4.address,
        startPort: startPort,
        endPort: endPort,
      ).toList();

      expect(ports, isEmpty);
    });

    test('throws for invalid port arguments', () {
      expect(
        () => scanPortsForSingleDevice('127.0.0.1', startPort: 0, endPort: 100),
        throwsArgumentError,
      );

      expect(
        () => scanPortsForSingleDevice(
          '127.0.0.1',
          startPort: 100,
          endPort: 99999,
        ),
        throwsArgumentError,
      );

      expect(
        () => scanPortsForSingleDevice('127.0.0.1', startPort: 10, endPort: 5),
        throwsArgumentError,
      );
    });
  });
}
