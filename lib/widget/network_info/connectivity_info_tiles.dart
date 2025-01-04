import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:network_info_app/widget/network_info/connectivity_stats.dart';

class ConnectivityInfoTiles extends StatelessWidget {
  const ConnectivityInfoTiles({super.key, required this.conductivities});

  final List<ConnectivityResult> conductivities;

  List<Widget> _generateTiles() {
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
      tiles.add(ConnectivityStats());
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
    return Column(
      spacing: 10,
      children: _generateTiles(),
    );
  }
}
