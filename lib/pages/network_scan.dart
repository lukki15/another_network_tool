import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:network_info_app/provider/connectivity_notifier.dart';
import 'package:network_info_app/widget/network_scan/device_list.dart';

class NetworkScan extends StatelessWidget {
  const NetworkScan({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityNotifier>(
        builder: (context, myNotifier, child) => DeviceList(
              hasWifi:
                  myNotifier.connectionStatus.contains(ConnectivityResult.wifi),
            ));
  }
}
