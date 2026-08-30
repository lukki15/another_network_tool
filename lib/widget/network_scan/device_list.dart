import 'dart:async';

import 'package:flutter/material.dart';

import 'package:another_network_tool/widget/network_scan/device_list_header.dart';
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
    const maxCount = 1.0 + Config.defaultLastHostId - Config.defaultFirstHostId;
    final progressPercent = progressCount / maxCount;
    final int currentIP =
        Config.defaultFirstHostId +
        ((Config.defaultLastHostId - Config.defaultFirstHostId) *
                progressPercent)
            .floor();
    final percentText = ((progressPercent * 100).clamp(0, 100).round())
        .toString();

    return Column(
      children: [
        if (widget.hasWifi)
          Card.outlined(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: DeviceListHeader(
              isDone: isDone,
              progressPercent: progressPercent,
              percentText: percentText,
              currentIP: currentIP,
              discoveredCount: activeHosts.length,
            ),
          )
        else
          ListTile(
            title: const Text("Wi-Fi Unavailable"),
            subtitle: const Text(
              "Network scanning will commence upon availability",
            ),
          ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'DISCOVERED DEVICES',
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ActiveHostsGroup(
                    activeHosts: activeHosts,
                    config: widget.config,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
