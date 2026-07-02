import 'dart:async';

import 'package:flutter/material.dart';

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

  int progressCount = 0;
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
    final Stream<AddressInfo> stream = widget.config.pingHosts(subnet);

    streamSubscription = stream.listen(
      (host) {
        setState(() {
          progressCount++;
          if (host.isReachable) {
            activeHosts.add(host);
          }
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
        progressCount = 0;
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
    const maxCount = 1.0  + Config.defaultLastHostId - Config.defaultFirstHostId;
    final progressPercent = progressCount / maxCount;
    final int currentIP =
        Config.defaultFirstHostId +
        ((Config.defaultLastHostId - Config.defaultFirstHostId) *
                progressPercent)
            .floor();

    return Column(
      children: [
        widget.hasWifi
            ? ListTile(
                title: LinearProgressIndicator(
                  value: isDone ? 1.0 : progressPercent,
                  minHeight: 8,
                ),
                subtitle: isDone
                    ? const Text("scanning done")
                    : Text("scanning $currentIP / ${Config.defaultLastHostId}"),
              )
            : ListTile(
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
