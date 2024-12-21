import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo extends StatelessWidget {
  const NetworkInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return _ConnectivityBuilder();
  }
}

class _Connectivity extends StatelessWidget {
  final List<ConnectivityResult> conductivities;
  const _Connectivity({required this.conductivities});

  @override
  Widget build(BuildContext context) {
    List<FTile> tiles = [
      FTile(
        prefixIcon: FIcon(conductivities.contains(ConnectivityResult.wifi)
            ? FAssets.icons.wifi
            : FAssets.icons.wifiOff),
        title: const Text('Wi-Fi'),
      )
    ];

    if (Platform.isAndroid) {
      tiles.add(FTile(
        prefixIcon: FIcon(conductivities.contains(ConnectivityResult.mobile)
            ? FAssets.icons.signal
            : FAssets.icons.signalLow),
        title: const Text('Cellular'),
      ));
    }

    if (Platform.isLinux) {
      tiles.add(FTile(
        prefixIcon: FIcon(conductivities.contains(ConnectivityResult.ethernet)
            ? FAssets.icons.ethernetPort
            : FAssets.icons.unplug),
        title: const Text('Ethernet'),
      ));
    }

    return Column(
      spacing: 20,
      children: tiles,
    );
  }
}

class _ConnectivityBuilder extends StatefulWidget {
  const _ConnectivityBuilder();

  @override
  State<_ConnectivityBuilder> createState() => _ConnectivityBuilderState();
}

class _ConnectivityBuilderState extends State<_ConnectivityBuilder> {
  final Future<List<ConnectivityResult>> connectivityResult =
      Connectivity().checkConnectivity();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ConnectivityResult>>(
        future: connectivityResult,
        builder: (BuildContext context,
            AsyncSnapshot<List<ConnectivityResult>> snapshot) {
          if (snapshot.hasData) {
            return _Connectivity(conductivities: snapshot.data!);
          }
          return _Connectivity(conductivities: []);
        });
  }
}
