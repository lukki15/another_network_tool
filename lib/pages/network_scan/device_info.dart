import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:network_info_app/pages/network_scan/future_text.dart';
import 'package:network_tools/network_tools.dart';

import 'package:network_info_app/pages/network_scan/port_map.dart';

class DeviceInfo extends StatelessWidget {
  const DeviceInfo({
    super.key,
    required this.activeHost,
  });

  final ActiveHost activeHost;

  static void _futureClipboard(Future<String?> future) {
    future.then((value) {
      if (value != null) {
        Clipboard.setData(ClipboardData(text: value));
      }
    });
  }

  static void _futureClipboardVendor(Future<Vendor?> future) {
    future.then((value) {
      if (value != null) {
        Clipboard.setData(ClipboardData(text: value.vendorName));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: FutureText(
            future: activeHost.deviceName, convertToString: (String s) => s),
        prefixActions: [
          FHeaderAction.back(onPress: () => Navigator.pop(context)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          spacing: 20,
          children: [
            FTileGroup(
              label: const Text('Device Info'),
              children: [
                FTile(
                  title: const Text('IP Address'),
                  details: Text(activeHost.address),
                  onLongPress: () => Clipboard.setData(
                      ClipboardData(text: activeHost.address)),
                ),
                FTile(
                  title: const Text('MAC Address'),
                  details: FutureText(
                      future: activeHost.getMacAddress(),
                      convertToString: (String? s) => s ?? "N/A"),
                  onLongPress: () =>
                      _futureClipboard(activeHost.getMacAddress()),
                ),
                FTile(
                  title: const Text('Vendor Name'),
                  details: FutureText(
                      future: activeHost.vendor,
                      convertToString: (Vendor? v) =>
                          v == null ? "N/A" : v.vendorName),
                  onLongPress: () => _futureClipboardVendor(activeHost.vendor),
                ),
              ],
            ),
            _PortGroup(
              address: activeHost.address,
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _PortGroup extends StatefulWidget {
  const _PortGroup({required this.address});

  final String address;

  @override
  State<_PortGroup> createState() => __PortGroupState();
}

class __PortGroupState extends State<_PortGroup> {
  late List<OpenPort> openPorts = [];
  late Stream<ActiveHost> stream;
  bool isDone = false;

  @override
  void initState() {
    super.initState();

    stream = PortScannerService.instance.scanPortsForSingleDevice(
      widget.address,
    );

    stream.listen((host) {
      //Same host can be emitted multiple times
      setState(() {
        openPorts = [...openPorts, ...host.openPorts];
      });
    }, onDone: () {
      setState(() {
        isDone = true;
      });
    }); // TODO: Don't forget to cancel the stream when not in use.
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
