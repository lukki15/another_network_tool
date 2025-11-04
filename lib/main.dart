import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:network_tools/network_tools.dart';

import 'package:another_network_tool/setup_network_tools.dart';
import 'package:another_network_tool/pages/main_scaffold.dart';
import 'package:another_network_tool/widget/loading_future_builder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Application());
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    builder: (context, child) => FTheme(
      data: FThemes.zinc.light,
      child: SafeArea(child: child!),
    ),
    home: LoadingFutureBuilder<Directory>(
      future: getDirectory(),
      loadingMessage: "get directory",
      onData: (directory) => SetupNetworkTools(directory: directory),
    ),
  );
}

class SetupNetworkTools extends StatelessWidget {
  const SetupNetworkTools({super.key, required this.directory});
  final Directory directory;

  @override
  Widget build(BuildContext context) {
    return LoadingFutureBuilder<void>(
      future: setupNetworkTools(directory),
      loadingMessage: "setup network tools",
      onData: (_) => MainScaffold(
        hostScannerService: HostScannerService.instance,
        portScannerService: PortScannerService.instance,
      ),
    );
  }
}
