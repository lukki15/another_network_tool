import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:another_network_tool/widget/network_info/connectivity_stats.dart';

class ConnectivityInfoTiles extends StatelessWidget {
  const ConnectivityInfoTiles({super.key, required this.conductivities});

  final List<ConnectivityResult> conductivities;

  List<Widget> _generateTiles() {
    List<Widget> tiles = [
      FTile(
        prefixIcon: Icon(
          conductivities.contains(ConnectivityResult.wifi)
              ? FIcons.wifi
              : FIcons.wifiOff,
          color:
              conductivities.contains(ConnectivityResult.wifi)
                  ? Colors.green
                  : Colors.red,
        ),
        title: const Text('Wi-Fi'),
      ),
    ];

    if (conductivities.contains(ConnectivityResult.wifi)) {
      tiles.add(ConnectivityStats());
    }

    if (Platform.isAndroid &&
        conductivities.contains(ConnectivityResult.mobile)) {
      tiles.add(SizedBox(height: 10));
      tiles.add(
        FTile(
          prefixIcon: Icon(FIcons.signal, color: Colors.green),
          title: const Text('Cellular'),
        ),
      );
    }

    if (Platform.isLinux) {
      tiles.add(SizedBox(height: 10));
      tiles.add(
        FTile(
          prefixIcon: Icon(
            conductivities.contains(ConnectivityResult.ethernet)
                ? FIcons.ethernetPort
                : FIcons.unplug,
            color:
                conductivities.contains(ConnectivityResult.ethernet)
                    ? Colors.green
                    : Colors.red,
          ),
          title: const Text('Ethernet'),
        ),
      );
    }

    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return Column(spacing: 10, children: _generateTiles());
  }
}
