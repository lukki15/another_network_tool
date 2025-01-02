import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';

import 'package:network_info_app/pages/network_info/network_stats.dart';
import 'package:network_info_app/provider/connectivity_notifier.dart';

class NetworkInfo extends StatelessWidget {
  const NetworkInfo({super.key});

  List<Widget> _getTiles(List<ConnectivityResult> conductivities) {
    List<Widget> tiles = [
      FTile(
        prefixIcon: FIcon(
          conductivities.contains(ConnectivityResult.wifi)
              ? FAssets.icons.wifi
              : FAssets.icons.wifiOff,
          color: conductivities.contains(ConnectivityResult.wifi)
              ? Colors.green
              : Colors.red,
        ),
        title: const Text('Wi-Fi'),
      )
    ];

    if (conductivities.contains(ConnectivityResult.wifi)) {
      tiles.add(NetworkStats());
    }

    if (Platform.isAndroid &&
        conductivities.contains(ConnectivityResult.mobile)) {
      tiles.add(SizedBox(height: 10));
      tiles.add(FTile(
        prefixIcon: FIcon(
          FAssets.icons.signal,
          color: Colors.green,
        ),
        title: const Text('Cellular'),
      ));
    }

    if (Platform.isLinux) {
      tiles.add(SizedBox(height: 10));
      tiles.add(FTile(
        prefixIcon: FIcon(
          conductivities.contains(ConnectivityResult.ethernet)
              ? FAssets.icons.ethernetPort
              : FAssets.icons.unplug,
          color: conductivities.contains(ConnectivityResult.ethernet)
              ? Colors.green
              : Colors.red,
        ),
        title: const Text('Ethernet'),
      ));
    }

    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityNotifier>(
      builder: (context, myNotifier, child) => Column(
        spacing: 10,
        children: _getTiles(myNotifier.connectionStatus),
      ),
    );
  }
}
