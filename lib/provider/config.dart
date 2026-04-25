import 'package:another_network_tool/provider/address_info.dart';
import 'package:another_network_tool/provider/host_scanner.dart';
import 'package:another_network_tool/provider/port_scanner.dart';

typedef ProgressCallback = void Function(double progress);
typedef PortScanner =
    Stream<int> Function(String target, {int startPort, int endPort});

class Config {
  static const int defaultFirstHostId = 1; // Devices scan will start
  static const int defaultLastHostId = 254; // Devices scan will stop

  static const int defaultStartPort = 1; // Port scan will start
  static const int defaultEndPort = 1024; // Port scan will stop

  final PingDataProvider pingDataProvider;
  final PortScanner portScanner;

  Config({
    this.pingDataProvider = defaultPingDataProvider,
    this.portScanner = scanPortsForSingleDevice,
  });

  Stream<AddressInfo> pingHosts(
    String subnet, {
    ProgressCallback? progressCallback,
  }) {
    return pingHostsPatch(
      subnet,
      pingDataProvider: pingDataProvider,
      start: defaultFirstHostId,
      end: defaultLastHostId,
    );
  }

  Stream<int> scanPort(String target) {
    return portScanner(
      target,
      startPort: defaultStartPort,
      endPort: defaultEndPort,
    );
  }
}
