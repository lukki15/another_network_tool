import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:network_tools/network_tools.dart';

import 'package:another_network_tool/setup_network_tools.dart';
import 'package:another_network_tool/pages/main_scaffold.dart';

Future<void> main() async {
  await setupNetworkTools();
  runApp(Application(portScannerService: PortScannerService.instance));
}

class Application extends StatelessWidget {
  const Application({super.key, required this.portScannerService});

  final PortScannerService portScannerService;

  @override
  Widget build(BuildContext context) => MaterialApp(
        builder: (context, child) => FTheme(
          data: FThemes.zinc.light,
          child: child!,
        ),
        home: MainScaffold(portScannerService: portScannerService),
      );
}
