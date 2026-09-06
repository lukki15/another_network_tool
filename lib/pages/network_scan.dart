import 'package:another_network_tool/provider/config.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:another_network_tool/utils/subnet.dart';

import 'package:another_network_tool/provider/connectivity_notifier.dart';
import 'package:another_network_tool/widget/network_scan/device_list.dart';

class NetworkScan extends StatelessWidget {
  NetworkScan({super.key, required this.config, NetworkInfo? networkInfo})
    : networkInfo = networkInfo ?? NetworkInfo();

  final Config config;
  final NetworkInfo networkInfo;

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityNotifier>(
      builder: (context, myNotifier, child) => DeviceList(
        hasWifi: myNotifier.connectionStatus.contains(ConnectivityResult.wifi),
        wifiSubnet: () async {
          final ip = await networkInfo.getWifiIP();
          final mask = await networkInfo.getWifiSubmask();

          if (ip == null || mask == null) return null;

          return Subnet.fromIpAndMask(ip, mask);
        }(),
        config: config,
      ),
    );
  }
}
