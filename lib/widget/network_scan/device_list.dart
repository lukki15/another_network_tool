import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:network_tools/network_tools.dart';

import 'package:another_network_tool/widget/network_scan/active_hosts_group.dart';

class DeviceList extends StatefulWidget {
  final bool hasWifi;
  final Future<String?> wifiIP;
  final HostScannerService hostScannerService;
  final PortScannerService portScannerService;
  const DeviceList({
    super.key,
    required this.hasWifi,
    required this.wifiIP,
    required this.hostScannerService,
    required this.portScannerService,
  });

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  StreamSubscription<ActiveHost>? streamSubscription;

  double progress = 0;
  Set<ActiveHost> activeHosts = {};
  bool isDone = false;

  void _init() {
    if (!widget.hasWifi) {
      return;
    }

    widget.wifiIP.then(_initStream);
  }

  void _initStream(String? ip) {
    if (ip == null) {
      setState(() {
        isDone = true;
      });
      return;
    }

    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    final Stream<ActiveHost> stream = widget.hostScannerService
        .getAllPingableDevicesAsync(
          subnet,
          progressCallback: (p) {
            setState(() {
              progress = p;
            });
          },
        );

    streamSubscription = stream.listen(
      (host) {
        //Same host can be emitted multiple times
        setState(() {
          activeHosts.add(host);
        });
      },
      onDone: () {
        setState(() {
          isDone = true;
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(DeviceList oldWidget) {
    super.didUpdateWidget(oldWidget);
    streamSubscription?.cancel();
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
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressPercent = progress / 100.0;
    final int currentIP =
        HostScannerService.defaultFirstHostId +
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
                        "scanning $currentIP / ${HostScannerService.defaultLastHostId}",
                      ),
              )
            : FTile(
                title: const Text("Wi-Fi Unavailable"),
                subtitle: const Text(
                  "Network scanning will commence upon availability",
                ),
              ),
        SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ActiveHostsGroup(
                  activeHosts: activeHosts,
                  portScannerService: widget.portScannerService,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
