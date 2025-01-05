import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:network_tools/network_tools.dart';

import 'package:network_info_app/widget/port_lists/port_map.dart';

class PortGroup extends StatefulWidget {
  const PortGroup({super.key, required this.address});

  final String address;

  @override
  State<PortGroup> createState() => _PortGroupState();
}

class _PortGroupState extends State<PortGroup> {
  late List<OpenPort> openPorts = [];
  late StreamSubscription<ActiveHost> streamSubscription;
  bool isDone = false;

  @override
  void initState() {
    super.initState();

    final Stream<ActiveHost> stream =
        PortScannerService.instance.scanPortsForSingleDevice(
      widget.address,
    );

    streamSubscription = stream.listen((host) {
      //Same host can be emitted multiple times
      setState(() {
        openPorts = [...openPorts, ...host.openPorts];
      });
    }, onDone: () {
      setState(() {
        isDone = true;
      });
    });
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FTileGroup(
        label: const Text("Open Ports"), children: getPortTilesList());
  }

  List<FTile> getPortTilesList() {
    if (openPorts.isEmpty && isDone) {
      return [
        generatePortTile(false, PortScannerService.defaultStartPort,
            PortScannerService.defaultEndPort)
      ];
    }

    List<FTile> tiles = [];
    for (var i = 0; i < openPorts.length; i++) {
      tiles.add(_generatePortTile(i));
      if (i + 1 < openPorts.length &&
          openPorts[i].port + 1 != openPorts[i + 1].port) {
        if (openPorts[i].port + 1 == openPorts[i + 1].port - 1) {
          tiles.add(generatePortTile(false, openPorts[i].port + 1, null));
        } else {
          tiles.add(generatePortTile(
              false, openPorts[i].port + 1, openPorts[i + 1].port - 1));
        }
      }
    }

    if (isDone &&
        openPorts[openPorts.length - 1].port !=
            PortScannerService.defaultEndPort) {
      if (openPorts[openPorts.length - 1].port + 1 ==
          PortScannerService.defaultEndPort) {
        tiles.add(generatePortTile(
            false, openPorts[openPorts.length - 1].port + 1, null));
      } else {
        tiles.add(generatePortTile(
            false,
            openPorts[openPorts.length - 1].port + 1,
            PortScannerService.defaultEndPort));
      }
    }

    return tiles;
  }

  FTile _generatePortTile(int i) {
    return generatePortTile(openPorts[i].isOpen, openPorts[i].port, null);
  }

  static FTile generatePortTile(bool isOpen, int port, int? nextPort) {
    return FTile(
      prefixIcon: isOpen
          ? FIcon(FAssets.icons.circleDot, color: Colors.green)
          : FIcon(FAssets.icons.circleDashed, color: Colors.red),
      title: nextPort == null ? Text("$port") : Text("$port - $nextPort"),
      subtitle: isOpen && nextPort == null && portMap.containsKey(port)
          ? Text(portMap[port]!)
          : null,
    );
  }
}
