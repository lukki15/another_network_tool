import 'dart:async';

import 'package:flutter/material.dart';

import 'package:another_network_tool/widget/network_scan/device_list_header.dart';
import 'package:another_network_tool/provider/address_info.dart';
import 'package:another_network_tool/provider/config.dart';
import 'package:another_network_tool/widget/network_scan/active_hosts_group.dart';
import 'package:another_network_tool/utils/subnet.dart';

class DeviceList extends StatefulWidget {
  final bool hasWifi;
  final Future<Subnet?> wifiSubnet;
  final Config config;
  const DeviceList({
    super.key,
    required this.hasWifi,
    required this.wifiSubnet,
    required this.config,
  });

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  StreamSubscription<AddressInfo>? streamSubscription;
  Subnet? _subnet;
  int _totalHosts = (Config.defaultLastHostId - Config.defaultFirstHostId) + 1;
  String? _subnetError;

  int progressCount = 0;
  Set<AddressInfo> activeHosts = {};
  bool isDone = false;

  void _init() {
    if (!widget.hasWifi) {
      return;
    }

    () async {
      try {
        final s = await widget.wifiSubnet;
        _initStream(s);
      } catch (e) {
        setState(() {
          _subnetError = e?.toString() ?? 'Unknown subnet error';
          isDone = true;
        });
      }
    }();
  }

  void _initStream(Subnet? subnet) {
    if (subnet == null) {
      setState(() {
        isDone = true;
      });
      return;
    }

    _subnet = subnet;
    try {
      final first = subnet.firstHostInt();
      final last = subnet.lastHostInt();
      final total = (last - first) + 1;
      if (total > 0) {
        _totalHosts = total;
      }
    } catch (_) {}

    final Stream<AddressInfo> stream = widget.config.pingSubnet(subnet);

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
    final double maxCount = _totalHosts.toDouble();
    final progressPercent = progressCount / maxCount;
    final int currentIndex = 1 + ((_totalHosts - 1) * progressPercent).floor();
    final percentText = ((progressPercent * 100).clamp(0, 100).round())
        .toString();

    return Column(
      children: [
        if (_subnetError != null)
          ListTile(
            title: const Text('Network error'),
            subtitle: Text(_subnetError!),
          )
        else if (widget.hasWifi)
          Card.outlined(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: DeviceListHeader(
              isDone: isDone,
              progressPercent: progressPercent,
              percentText: percentText,
              currentIP: currentIndex,
              discoveredCount: activeHosts.length,
              totalHosts: _totalHosts,
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
