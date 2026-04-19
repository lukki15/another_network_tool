import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:another_network_tool/provider/address_info.dart';
import 'package:another_network_tool/provider/config.dart';
import 'package:another_network_tool/widget/network_scan/active_hosts_group.dart';

class DeviceList extends StatefulWidget {
  final bool hasWifi;
  final Future<String?> wifiIP;
  final Config config;
  const DeviceList({
    super.key,
    required this.hasWifi,
    required this.wifiIP,
    required this.config,
  });

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  StreamSubscription<AddressInfo>? streamSubscription;

  double progress = 0;
  Set<AddressInfo> activeHosts = {};
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
    final Stream<AddressInfo> stream = widget.config.pingHosts(
      subnet,
      progressCallback: (p) {
        setState(() {
          progress = p;
        });
      },
    );

    streamSubscription = stream.listen(
      (host) {
        if (host.isReachable) {
          setState(() {
            activeHosts.add(host);
          });
        }
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
        Config.defaultFirstHostId +
        ((Config.defaultLastHostId - Config.defaultFirstHostId) *
                progressPercent)
            .floor();

    return Column(
      children: [
        widget.hasWifi
            ? FTile(
                title: FDeterminateProgress(
                  value: isDone ? 1.0 : progressPercent,
                ),
                subtitle: isDone
                    ? const Text("scanning done")
                    : Text("scanning $currentIP / ${Config.defaultLastHostId}"),
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
                  config: widget.config,
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
