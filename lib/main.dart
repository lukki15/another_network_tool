import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:network_tools/network_tools.dart';
import 'package:path_provider/path_provider.dart';

import 'package:network_info_app/pages/main_scaffold.dart';

Future<void> _setupNetworkTools() async {
  WidgetsFlutterBinding.ensureInitialized();
  // It's necessary to pass correct path to be able to use this library.
  final tempDirectory = await getTemporaryDirectory();
  return configureNetworkTools(tempDirectory.path);
}

Future<void> main() async {
  await _setupNetworkTools();
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
