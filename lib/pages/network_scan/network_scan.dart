import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:network_tools/network_tools.dart';

import 'package:network_info_app/pages/network_scan/device_info.dart';
import 'package:network_info_app/pages/network_scan/future_text.dart';
import 'package:network_info_app/pages/connectivity_manager.dart';

class NetworkScan extends StatefulWidget {
  const NetworkScan({super.key});

  @override
  State<NetworkScan> createState() => _NetworkScanState();
}

class _NetworkScanState extends State<NetworkScan> {
  late Stream<ActiveHost> stream;

  double progress = 0;
  Set<ActiveHost> activeHosts = {};
  bool isDone = false;

  List<ConnectivityResult> connectivityResult = [];
  final ConnectivityManager connectivityManager = ConnectivityManager();

  void _connectivityUpdate(List<ConnectivityResult> connectivity) {
    if (!connectivity.contains(ConnectivityResult.wifi)) {
      setState(() {
        connectivityResult = connectivity;
      });
      return;
    }

    setState(() {
      connectivityResult = connectivity;
      progress = 0;
      activeHosts.clear();
      isDone = false;
    });

    final wifiIP = NetworkInfo().getWifiIP();

    wifiIP.then((ip) {
      if (ip == null) {
        setState(() {
          isDone = true;
        });
        return;
      }

      final String subnet = ip.substring(0, ip.lastIndexOf('.'));
      stream = HostScannerService.instance.getAllPingableDevicesAsync(
        subnet,
        progressCallback: (p) {
          setState(() {
            progress = p;
          });
        },
      );

      stream.listen((host) {
        //Same host can be emitted multiple times
        setState(() {
          activeHosts.add(host);
        });
      }, onDone: () {
        setState(() {
          isDone = true;
        });
      }); // TODO: Don't forget to cancel the stream when not in use.
    });
  }

  @override
  void initState() {
    super.initState();

    connectivityManager.listen(_connectivityUpdate);
  }

  @override
  void dispose() {
    connectivityManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressPercent = progress / 100.0;
    final int currentIP = HostScannerService.defaultFirstHostId +
        ((HostScannerService.defaultLastHostId -
                    HostScannerService.defaultFirstHostId) *
                progressPercent)
            .floor();

    return Column(
      children: [
        connectivityResult.contains(ConnectivityResult.wifi)
            ? FTile(
                title: FProgress(value: isDone ? 1.0 : progressPercent),
                subtitle: isDone
                    ? const Text("scanning done")
                    : Text(
                        "scanning $currentIP / ${HostScannerService.defaultLastHostId}"),
              )
            : FTile(
                title: const Text("Wi-Fi Unavailable"),
                subtitle: const Text(
                    "Network scanning will commence upon availability")),
        SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _ActiveHostsGroup(activeHosts: activeHosts),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveHostsGroup extends StatelessWidget {
  const _ActiveHostsGroup({
    required this.activeHosts,
  });

  final Set<ActiveHost> activeHosts;

  @override
  Widget build(BuildContext context) {
    return FTileGroup(
      children: [
        for (var item in activeHosts)
          FTile(
            prefixIcon: FIcon(FAssets.icons.monitorSmartphone),
            title: FutureText(
                future: item.deviceName, convertToString: (String s) => s),
            subtitle: Text(item.address),
            details: Platform.isAndroid
                // Since Android SDK 32, apps are no longer allowed to access the MAC address.
                ? Text("")
                : FutureText(
                    future: item.vendor,
                    convertToString: (Vendor? v) =>
                        v == null ? "" : v.vendorName,
                  ),
            onPress: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DeviceInfo(
                        activeHost: item,
                      )));
            },
          )
      ],
    );
  }
}
