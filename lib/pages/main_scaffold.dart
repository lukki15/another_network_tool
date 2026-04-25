import 'package:another_network_tool/provider/config.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';

import 'package:another_network_tool/pages/network_info.dart';
import 'package:another_network_tool/pages/network_scan.dart';
import 'package:another_network_tool/provider/connectivity_notifier.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key, required this.config});

  final Config config;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int index = 0;
  static const headers = [
    FHeader(title: Text('Network Info')),
    FHeader(title: Text('Network Scan')),
  ];
  static const footers = [
    FBottomNavigationBarItem(
      icon: Icon(FIcons.calendarRange),
      label: Text('Info'),
    ),
    FBottomNavigationBarItem(
      icon: Icon(FIcons.textSearch),
      label: Text('List'),
    ),
  ];
  late final contents = [NetworkInfo(), NetworkScan(config: widget.config)];

  @override
  Widget build(BuildContext context) {
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
