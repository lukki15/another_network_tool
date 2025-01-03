import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:network_info_app/provider/connectivity_notifier.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:network_tools/network_tools.dart';
import 'package:provider/provider.dart';

import 'package:network_info_app/pages/network_scan/device_info.dart';
import 'package:network_info_app/pages/network_scan/future_text.dart';

class NetworkScan extends StatelessWidget {
  const NetworkScan({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityNotifier>(
        builder: (context, myNotifier, child) => _Scan(
              hasWifi:
                  myNotifier.connectionStatus.contains(ConnectivityResult.wifi),
            ));
  }
}

class _Scan extends StatefulWidget {
  final bool hasWifi;
  const _Scan({required this.hasWifi});

  @override
  State<_Scan> createState() => _ScanState();
}

class _ScanState extends State<_Scan> {
  late StreamSubscription<ActiveHost> streamSubscription;

  double progress = 0;
  Set<ActiveHost> activeHosts = {};
  bool isDone = false;

  void _init() {
    if (!widget.hasWifi) {
      return;
    }

    final wifiIP = NetworkInfo().getWifiIP();

    wifiIP.then((ip) {
      if (ip == null) {
        setState(() {
          isDone = true;
        });
        return;
      }

      final String subnet = ip.substring(0, ip.lastIndexOf('.'));
      final Stream<ActiveHost> stream =
          HostScannerService.instance.getAllPingableDevicesAsync(
        subnet,
        progressCallback: (p) {
          setState(() {
            progress = p;
          });
        },
      );

      streamSubscription = stream.listen((host) {
        //Same host can be emitted multiple times
        setState(() {
          activeHosts.add(host);
        });
      }, onDone: () {
        setState(() {
          isDone = true;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(_Scan oldWidget) {
    super.didUpdateWidget(oldWidget);
    streamSubscription.cancel();
    if (widget.hasWifi) {
      setState(() {
        progress = 0;
        activeHosts.clear();
        isDone = false;
      });
    }
    _init();
  }

  @override
  void dispose() {
    streamSubscription.cancel();
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
        widget.hasWifi
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
            onLongPress: () =>
                Clipboard.setData(ClipboardData(text: item.address)),
          )
      ],
    );
  }
}
