import 'dart:io';

import 'package:another_network_tool/widget/network_info/conductivity_card.dart';
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

  List<Widget> _generateTiles(BuildContext context) {
    List<Widget> tiles = [
      ConductivityCard(
        isConnected: conductivities.contains(ConnectivityResult.wifi),
        isConnectedIcon: Icons.wifi,
        isDisconnectedIcon: Icons.wifi_off,
        networkName: 'Wi-Fi',
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

    tiles.addAll([
      ConductivityCard(
        isConnected: conductivities.contains(ConnectivityResult.mobile),
        isConnectedIcon: Icons.signal_cellular_alt,
        isDisconnectedIcon: Icons.signal_cellular_0_bar,
        networkName: 'Cellular',
      ),
      ConductivityCard(
        isConnected: conductivities.contains(ConnectivityResult.ethernet),
        isConnectedIcon: Icons.cable,
        isDisconnectedIcon: Icons.power_off,
        networkName: 'Ethernet',
      ),
      SizedBox(height: 8),
    ]);

    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(spacing: 10, children: _generateTiles(context)),
    );
  }
}
