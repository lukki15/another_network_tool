import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:network_info_app/network_info.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int index = 0;
  final headers = [
    const FHeader(title: Text('Network Info')),
    const FHeader(title: Text('Network Scan')),
  ];
  final contents = [
    const NetworkInfo(),
    const Center(child: Text('Network Scan Placeholder')),
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
