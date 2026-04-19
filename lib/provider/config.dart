import 'package:another_network_tool/provider/address_info.dart';
import 'package:network_tools/network_tools.dart';

typedef ProgressCallback = void Function(double progress);

class Config {
  static const int defaultFirstHostId =
      1; // Devices scan will start from this integer Id
  static const int defaultLastHostId =
      254; // Devices scan will stop at this integer id

  final HostScannerService hostScannerService;
  final PortScannerService portScannerService;

  Config({required this.hostScannerService, required this.portScannerService});

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
}
