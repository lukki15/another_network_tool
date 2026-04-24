import 'package:another_network_tool/provider/address_info.dart';
import 'package:another_network_tool/provider/port_scanner.dart';
import 'package:network_tools/network_tools.dart';

typedef ProgressCallback = void Function(double progress);
typedef PortScanner =
    Stream<int> Function(String target, {int startPort, int endPort});

class Config {
  static const int defaultFirstHostId = 1; // Devices scan will start
  static const int defaultLastHostId = 254; // Devices scan will stop

  static const int defaultStartPort = 1; // Port scan will start
  static const int defaultEndPort = 1024; // Port scan will stop

  final HostScannerService hostScannerService;
  final PortScanner portScanner;

  Config({
    required this.hostScannerService,
    this.portScanner = scanPortsForSingleDevice,
  });

  Stream<AddressInfo> pingHosts(
    String subnet, {
    ProgressCallback? progressCallback,
  }) {
    return hostScannerService
        .getAllPingableDevicesAsync(
          subnet,
          progressCallback: progressCallback,
          firstHostId: defaultFirstHostId,
          lastHostId: defaultLastHostId,
        )
        .asyncMap((activeHost) {
          return AddressInfo(address: activeHost.address, isReachable: true);
        });
  }

  Stream<int> scanPort(String target) {
    return portScanner(
      target,
      startPort: defaultStartPort,
      endPort: defaultEndPort,
    );
  }
}
