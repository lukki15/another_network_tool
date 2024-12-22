import 'package:flutter/material.dart';
import 'package:network_tools/network_tools.dart';

class NetworkScan extends StatefulWidget {
  const NetworkScan({super.key});

  @override
  State<NetworkScan> createState() => _NetworkScanState();
}

class _NetworkScanState extends State<NetworkScan> {
  final String address = '192.168.178.1'; // TODO
  late Stream<ActiveHost> stream;

  double progress = 0;
  Set<ActiveHost> activeHosts = {};
  bool isDone = false;

  @override
  void initState() {
    super.initState();

    final String subnet = address.substring(0, address.lastIndexOf('.'));
    stream = HostScannerService.instance.getAllPingableDevicesAsync(
      subnet,
      progressCallback: (p) {
        setState(() {
          progress = p;
        });
      },
    );

    stream.listen((host) {
      //Same host can be emitted multiple times
      setState(() {
        activeHosts.add(host);
      });
    }, onDone: () {
      setState(() {
        isDone = true;
      });
    }); // Don't forget to cancel the stream when not in use.
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('progress: $progress'),
        Text('isDone: $isDone'),
        Column(
          children: [
            for (var item in activeHosts)
              FutureBuilder(
                  future: item.deviceName,
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    return Text(
                      "${snapshot.hasData ? snapshot.data! : "N/A"} ${item.address}",
                    );
                  })
          ],
        ),
      ],
    );
  }
}
