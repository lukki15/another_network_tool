import 'package:network_tools/network_tools.dart';

class Config {
  final HostScannerService hostScannerService;
  final PortScannerService portScannerService;

  Config({required this.hostScannerService, required this.portScannerService});
}
