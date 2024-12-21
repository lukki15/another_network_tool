import 'dart:async';
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

    if (Platform.isAndroid &&
        conductivities.contains(ConnectivityResult.mobile)) {
      tiles.add(FTile(
        prefixIcon: FIcon(FAssets.icons.signal),
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
  List<ConnectivityResult> _connectionStatus = [];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      // Could not check connectivity status
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _Connectivity(conductivities: _connectionStatus);
  }
}
