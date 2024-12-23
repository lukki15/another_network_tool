import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_app/pages/connectivity_manager.dart';

import 'package:network_info_app/pages/network_info/network_stats.dart';

class NetworkInfo extends StatelessWidget {
  const NetworkInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return _Connectivity();
  }
}

class _Connectivity extends StatefulWidget {
  const _Connectivity();

  @override
  State<_Connectivity> createState() => _ConnectivityState();
}

class _ConnectivityState extends State<_Connectivity> {
  List<ConnectivityResult> _conductivities = [];
  final ConnectivityManager _connectivityManager = ConnectivityManager();

  @override
  void initState() {
    super.initState();
    _connectivityManager.listen((conductivitiesResult) {
      setState(() {
        _conductivities = conductivitiesResult;
      });
    });
  }

  @override
  void dispose() {
    _connectivityManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tiles = [
      FTile(
        prefixIcon: FIcon(
          _conductivities.contains(ConnectivityResult.wifi)
              ? FAssets.icons.wifi
              : FAssets.icons.wifiOff,
          color: _conductivities.contains(ConnectivityResult.wifi)
              ? Colors.green
              : Colors.red,
        ),
        title: const Text('Wi-Fi'),
      )
    ];

    if (_conductivities.contains(ConnectivityResult.wifi)) {
      tiles.add(NetworkStats());
    }

    if (Platform.isAndroid &&
        _conductivities.contains(ConnectivityResult.mobile)) {
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
          _conductivities.contains(ConnectivityResult.ethernet)
              ? FAssets.icons.ethernetPort
              : FAssets.icons.unplug,
          color: _conductivities.contains(ConnectivityResult.ethernet)
              ? Colors.green
              : Colors.red,
        ),
        title: const Text('Ethernet'),
      ));
    }

    return Column(
      spacing: 10,
      children: tiles,
    );
  }
}
