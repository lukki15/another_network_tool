import 'package:another_network_tool/provider/config.dart';
import 'package:flutter/material.dart';
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
  int currentPageIndex = 0;
  static final headers = [
    AppBar(title: const Text('Network Info')),
    AppBar(title: const Text('Network Scan')),
  ];
  static const destinations = [
    NavigationDestination(
      selectedIcon: Icon(Icons.info),
      icon: Icon(Icons.info_outlined),
      label: 'Info',
    ),
    NavigationDestination(
      selectedIcon: Icon(Icons.wifi_find),
      icon: Icon(Icons.wifi_find_outlined),
      label: 'Scan',
    ),
  ];
  late final contents = [NetworkInfo(), NetworkScan(config: widget.config)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: destinations,
      ),
      appBar: headers[currentPageIndex],
      body: ChangeNotifierProvider(
        create: (_) => ConnectivityNotifier(),
        child: contents[currentPageIndex],
      ),
    );
  }
}
