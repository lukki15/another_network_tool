import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:network_info_app/pages/main_scaffold.dart';

void main() {
  runApp(const _Application());
}

class _Application extends StatelessWidget {
  const _Application();

  @override
  Widget build(BuildContext context) => MaterialApp(
        builder: (context, child) => FTheme(
          data: FThemes.zinc.light,
          child: child!,
        ),
        home: const MainScaffold(),
      );
}
