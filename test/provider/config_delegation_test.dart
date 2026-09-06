import 'package:another_network_tool/provider/config.dart';
import 'package:another_network_tool/utils/subnet.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Config.pingSubnet', () {
    test('uses the configured ping data provider', () async {
      final calls = <String>[];

      final config = Config(
        pingDataProvider: (host) async {
          calls.add(host);
          return PingResponse(ip: host);
        },
      );

      final subnet = Subnet('192.168.1.0', 30);

      final results = await config.pingSubnet(subnet).toList();

      expect(calls, containsAll(<String>['192.168.1.1', '192.168.1.2']));

      expect(results, hasLength(2));
      expect(results.every((result) => result.isReachable), isTrue);
    });

    test('returns unreachable hosts when the provider fails', () async {
      final config = Config(
        pingDataProvider: (host) async {
          return PingError(ErrorType.requestTimedOut, message: 'timeout');
        },
      );

      final subnet = Subnet('10.0.0.0', 30);

      final results = await config.pingSubnet(subnet).toList();

      expect(results, hasLength(2));
      expect(results.every((result) => !result.isReachable), isTrue);
    });
  });

  group('Config.scanPort', () {
    test('delegates to the configured port scanner', () async {
      String? receivedTarget;
      int? receivedStartPort;
      int? receivedEndPort;

      final config = Config(
        portScanner: (String target, {int startPort = 1, int endPort = 1024}) {
          receivedTarget = target;
          receivedStartPort = startPort;
          receivedEndPort = endPort;

          return Stream<int>.fromIterable([22, 80, 443]);
        },
      );

      final results = await config.scanPort('192.168.1.10').toList();

      expect(results, [22, 80, 443]);
      expect(receivedTarget, '192.168.1.10');
      expect(receivedStartPort, Config.defaultStartPort);
      expect(receivedEndPort, Config.defaultEndPort);
    });

    test('propagates the configured scanner stream', () async {
      final config = Config(
        portScanner:
            (String target, {int startPort = 1, int endPort = 1024}) async* {
              yield startPort;
              yield endPort;
            },
      );

      final results = await config.scanPort('10.0.0.5').toList();

      expect(results, [Config.defaultStartPort, Config.defaultEndPort]);
    });
  });

  group('Config defaults', () {
    test('uses the expected default port range', () {
      expect(Config.defaultStartPort, 1);
      expect(Config.defaultEndPort, 1024);
    });

    test('uses the expected default host range', () {
      expect(Config.defaultFirstHostId, 1);
      expect(Config.defaultLastHostId, 254);
    });
  });
}
