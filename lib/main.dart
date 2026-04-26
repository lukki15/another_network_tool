import 'package:another_network_tool/provider/config.dart';
import 'package:flutter/material.dart';
import 'package:another_network_tool/pages/main_scaffold.dart';

void main() => runApp(const Application());

class Application extends StatelessWidget {
  const Application({super.key});

  @override
    Widget build(BuildContext context) {
    return MaterialApp(home: MainScaffold(config: Config()));
  }
}
