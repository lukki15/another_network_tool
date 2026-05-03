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
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: getPortTilesList(),
        ),
      ],
    );
  }

  List<ListTile> getPortTilesList() {
    if (openPorts.isEmpty && isDone) {
      return [
        generatePortTile(false, Config.defaultStartPort, Config.defaultEndPort),
      ];
    }

    List<ListTile> tiles = [];
    openPorts.sort();
    final sortedPorts = openPorts;

    if (sortedPorts.isNotEmpty && sortedPorts.first > Config.defaultStartPort) {
      tiles.add(
        generatePortTile(false, Config.defaultStartPort, sortedPorts.first - 1),
      );
    }

    for (var i = 0; i < sortedPorts.length; i++) {
      tiles.add(_generatePortTile(sortedPorts[i]));
      if (i + 1 < sortedPorts.length &&
          sortedPorts[i] + 1 != sortedPorts[i + 1]) {
        if (sortedPorts[i] + 1 == sortedPorts[i + 1] - 1) {
          tiles.add(generatePortTile(false, sortedPorts[i] + 1, null));
        } else {
          tiles.add(
            generatePortTile(false, sortedPorts[i] + 1, sortedPorts[i + 1] - 1),
          );
        }
      }
    }

    if (isDone && sortedPorts.last != Config.defaultEndPort) {
      if (sortedPorts.last + 1 == Config.defaultEndPort) {
        tiles.add(generatePortTile(false, sortedPorts.last + 1, null));
      } else {
        tiles.add(
          generatePortTile(false, sortedPorts.last + 1, Config.defaultEndPort),
        );
      }
    }

    return tiles;
  }

  ListTile _generatePortTile(int port) {
    return generatePortTile(true, port, null);
  }

  static ListTile generatePortTile(bool isOpen, int port, int? nextPort) {
    return ListTile(
      leading: isOpen
          ? Icon(Icons.fiber_manual_record, color: Colors.green)
          : Icon(Icons.radio_button_unchecked, color: Colors.red),
      title: nextPort == null ? Text("$port") : Text("$port - $nextPort"),
      subtitle: isOpen && nextPort == null && portMap.containsKey(port)
          ? Text(portMap[port]!)
          : null,
    );
  }
}
