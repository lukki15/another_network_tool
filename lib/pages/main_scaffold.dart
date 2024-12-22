import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:network_info_app/pages/network_info/network_info.dart';
import 'package:network_info_app/pages/network_scan/network_scan.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int index = 0;
  static const headers = [
    FHeader(title: Text('Network Info')),
    FHeader(title: Text('Network Scan')),
  ];
  static const contents = [
    NetworkInfo(),
    NetworkScan(),
  ];
  final footers = [
    FBottomNavigationBarItem(
      icon: FIcon(FAssets.icons.calendarRange),
      label: Text('Info'),
    ),
    FBottomNavigationBarItem(
      icon: FIcon(FAssets.icons.textSearch),
      label: Text('List'),
    ),
  ];

  @override
  Widget build(BuildContext context) => FScaffold(
        header: headers[index],
        content: contents[index],
        footer: FBottomNavigationBar(
          index: index,
          onChange: (index) => setState(() => this.index = index),
          children: footers,
        ),
      );
}
