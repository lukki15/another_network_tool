import 'dart:async';

import 'package:another_network_tool/provider/config.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:network_tools/network_tools.dart';

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
    return FTileGroup(
      label: const Text("Open Ports"),
      children: getPortTilesList(),
    );
  }

  List<FTile> getPortTilesList() {
    if (openPorts.isEmpty && isDone) {
      return [
        generatePortTile(
          false,
          PortScannerService.defaultStartPort,
          PortScannerService.defaultEndPort,
        ),
      ];
    }

    List<FTile> tiles = [];
    openPorts.sort();
    final sortedPorts = openPorts;

    if (sortedPorts.isNotEmpty &&
        sortedPorts.first > PortScannerService.defaultStartPort) {
      tiles.add(
        generatePortTile(
          false,
          PortScannerService.defaultStartPort,
          sortedPorts.first - 1,
        ),
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

    if (isDone && sortedPorts.last != PortScannerService.defaultEndPort) {
      if (sortedPorts.last + 1 == PortScannerService.defaultEndPort) {
        tiles.add(generatePortTile(false, sortedPorts.last + 1, null));
      } else {
        tiles.add(
          generatePortTile(
            false,
            sortedPorts.last + 1,
            PortScannerService.defaultEndPort,
          ),
        );
      }
    }

    return tiles;
  }

  FTile _generatePortTile(int port) {
    return generatePortTile(true, port, null);
  }

  static FTile generatePortTile(bool isOpen, int port, int? nextPort) {
    return FTile(
      prefix: isOpen
          ? Icon(FIcons.circleDot, color: Colors.green)
          : Icon(FIcons.circleDashed, color: Colors.red),
      title: nextPort == null ? Text("$port") : Text("$port - $nextPort"),
      subtitle: isOpen && nextPort == null && portMap.containsKey(port)
          ? Text(portMap[port]!)
          : null,
    );
  }
}
