import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:another_network_tool/setup_network_tools.dart';
import 'package:another_network_tool/pages/main_scaffold.dart';

Future<void> main() async {
  await setupNetworkTools();
  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        builder: (context, child) => FTheme(
          data: FThemes.zinc.light,
          child: child!,
        ),
        home: const MainScaffold(),
      );
}
