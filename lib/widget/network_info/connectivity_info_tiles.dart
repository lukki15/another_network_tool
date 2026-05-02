import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';

import 'package:another_network_tool/widget/network_info/connectivity_stats.dart';
import 'package:permission_handler/permission_handler.dart';

class ConnectivityInfoTiles extends StatelessWidget {
  const ConnectivityInfoTiles({
    super.key,
    required this.isAndroid,
    required this.isLinux,
    required this.conductivities,
  });

  final bool Function() isAndroid;
  final bool Function() isLinux;
  final List<ConnectivityResult> conductivities;

  List<Widget> _generateTiles() {
    List<Widget> tiles = [
      ListTile(
        leading: Icon(
          conductivities.contains(ConnectivityResult.wifi)
              ? Icons.wifi
              : Icons.wifi_off,
          color: conductivities.contains(ConnectivityResult.wifi)
              ? Colors.green
              : Colors.red,
        ),
        title: const Text('Wi-Fi'),
      ),
    ];

    if (conductivities.contains(ConnectivityResult.wifi)) {
      tiles.add(
        ConnectivityStats(
          networkInfo: NetworkInfo(),
          isMobile: Platform.isAndroid || Platform.isIOS,
          locationWhenInUse: PermissionHelper(
            isGranted: () => Permission.locationWhenInUse.isGranted,
            request: Permission.locationWhenInUse.request,
          ),
        ),
      );
    }

    if (isAndroid() && conductivities.contains(ConnectivityResult.mobile)) {
      tiles.add(SizedBox(height: 10));
      tiles.add(
        ListTile(
          leading: Icon(Icons.signal_cellular_alt, color: Colors.green),
          title: const Text('Cellular'),
        ),
      );
    }

    if (isLinux()) {
      tiles.add(SizedBox(height: 10));
      tiles.add(
        ListTile(
          leading: Icon(
            conductivities.contains(ConnectivityResult.ethernet)
                ? Icons.cable
                : Icons.power_off,
            color: conductivities.contains(ConnectivityResult.ethernet)
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
    return SingleChildScrollView(
      child: Column(spacing: 10, children: _generateTiles()),
    );
  }
}
