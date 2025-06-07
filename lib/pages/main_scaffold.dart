import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import 'package:network_tools/network_tools.dart';

import 'package:another_network_tool/pages/network_info.dart';
import 'package:another_network_tool/pages/network_scan.dart';
import 'package:another_network_tool/provider/connectivity_notifier.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({
    super.key,
    required this.hostScannerService,
    required this.portScannerService,
  });

  final HostScannerService hostScannerService;
  final PortScannerService portScannerService;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int index = 0;
  static const headers = [
    FHeader(title: Text('Network Info')),
    FHeader(title: Text('Network Scan')),
  ];
  final footers = [
    FBottomNavigationBarItem(
      icon: Icon(FIcons.calendarRange),
      label: Text('Info'),
    ),
    FBottomNavigationBarItem(
      icon: Icon(FIcons.textSearch),
      label: Text('List'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final contents = [
      NetworkInfo(),
      NetworkScan(
        hostScannerService: widget.hostScannerService,
        portScannerService: widget.portScannerService,
      ),
    ];

    return FScaffold(
      header: headers[index],
      footer: FBottomNavigationBar(
        index: index,
        onChange: (index) => setState(() => this.index = index),
        children: footers,
      ),
      child: ChangeNotifierProvider(
        create: (_) => ConnectivityNotifier(),
        child: contents[index],
      ),
    );
  }
}
