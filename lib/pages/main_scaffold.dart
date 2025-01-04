import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';

import 'package:network_info_app/pages/network_info.dart';
import 'package:network_info_app/pages/network_scan/network_scan.dart';
import 'package:network_info_app/provider/connectivity_notifier.dart';

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
        content: ChangeNotifierProvider(
          create: (_) => ConnectivityNotifier(),
          child: contents[index],
        ),
        footer: FBottomNavigationBar(
          index: index,
          onChange: (index) => setState(() => this.index = index),
          children: footers,
        ),
      );
}
