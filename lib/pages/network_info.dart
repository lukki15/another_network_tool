import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:another_network_tool/provider/connectivity_notifier.dart';
import 'package:another_network_tool/widget/network_info/connectivity_info_tiles.dart';

class NetworkInfo extends StatelessWidget {
  const NetworkInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityNotifier>(
      builder:
          (context, myNotifier, child) => ConnectivityInfoTiles(
            conductivities: myNotifier.connectionStatus,
          ),
    );
  }
}
