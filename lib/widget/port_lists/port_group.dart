import 'dart:async';

import 'package:another_network_tool/provider/config.dart';
import 'package:flutter/material.dart';

import 'package:another_network_tool/widget/port_lists/port_map.dart';

class PortGroup extends StatefulWidget {
  const PortGroup({super.key, required this.address, required this.config});

  final String address;
  final Config config;

  @override
  State<PortGroup> createState() => _PortGroupState();
}

class _PortGroupState extends State<PortGroup> {
  List<int> openPorts = [];
  late StreamSubscription<int> streamSubscription;
  bool isDone = false;

  @override
  void initState() {
    super.initState();

    final Stream<int> stream = widget.config.scanPort(widget.address);

    streamSubscription = stream.listen(
      (port) {
        //Same host can be emitted multiple times
        setState(() {
          openPorts.add(port);
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
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortedPorts = openPorts.toSet().toList()..sort();
    final discoveredCount = sortedPorts.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: const Text(
            "Open Ports",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card.outlined(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Port Range',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${Config.defaultStartPort} - ${Config.defaultEndPort}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Default scan range',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'DISCOVERED PORTS ($discoveredCount)',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card.outlined(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: discoveredCount == 0 && isDone ? 1 : discoveredCount,
              separatorBuilder: (context, index) => const Divider(height: 0),
              itemBuilder: (context, index) {
                if (discoveredCount == 0 && isDone) {
                  return _buildEmptyPortRow(context);
                }
                return _buildPortRow(context, sortedPorts[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPortRow(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      title: Text(
        'No open ports found',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildPortRow(BuildContext context, int port) {
    final title = portMap[port] ?? 'Port $port';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          '$port',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text('Port $port • Open'),
    );
  }
}
