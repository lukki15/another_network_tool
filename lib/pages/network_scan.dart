import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:network_tools/network_tools.dart';

import 'package:another_network_tool/provider/connectivity_notifier.dart';
import 'package:another_network_tool/widget/network_scan/device_list.dart';

class NetworkScan extends StatelessWidget {
  const NetworkScan({
    super.key,
    required this.hostScannerService,
    required this.portScannerService,
  });

  final HostScannerService hostScannerService;
  final PortScannerService portScannerService;

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityNotifier>(
      builder:
          (context, myNotifier, child) => DeviceList(
            hasWifi: myNotifier.connectionStatus.contains(
              ConnectivityResult.wifi,
            ),
            hostScannerService: hostScannerService,
            portScannerService: portScannerService,
          ),
    );
  }
}
