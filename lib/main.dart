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
  Widget build(BuildContext context) {
    /// Try changing this and hot reloading the application.
    ///
    /// To create a custom theme:
    /// ```shell
    /// dart forui theme create [theme template].
    /// ```
    final theme = FThemes.zinc.light;
    return MaterialApp(
      // TODO: replace with your application's supported locales.
      supportedLocales: FLocalizations.supportedLocales,
      // TODO: add your application's localizations delegates.
      localizationsDelegates: const [...FLocalizations.localizationsDelegates],
      // MaterialApp's theme is also animated by default with the same duration and curve.
      // See https://api.flutter.dev/flutter/material/MaterialApp/themeAnimationStyle.html
      // for how to configure this.
      //
      // There is a known issue with implicitly animated widgets where their transition
      // occurs AFTER the theme's. See https://github.com/duobaseio/forui/issues/670.
      theme: theme.toApproximateMaterialTheme(),
      builder: (_, child) => FTheme(
        data: theme,
        child: FToaster(child: FTooltipGroup(child: child!)),
      ),
      // You can also replace FScaffold with Material Scaffold.
      home: LoadingFutureBuilder<Directory>(
        future: getDirectory(),
        loadingMessage: "get directory",
        onData: (directory) => SetupNetworkTools(directory: directory),
      ),
    );
  }
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
