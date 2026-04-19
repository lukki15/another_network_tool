import 'package:another_network_tool/provider/address_info.dart';
import 'package:another_network_tool/provider/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

import 'package:another_network_tool/widget/future_text.dart';
import 'package:another_network_tool/widget/port_lists/port_group.dart';

class DeviceInfo extends StatelessWidget {
  const DeviceInfo({super.key, required this.activeHost, required this.config});

  final AddressInfo activeHost;
  final Config config;

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: FutureText(
          future: activeHost.getHostName(),
          convertToString: (String s) => s,
        ),
        prefixes: [FHeaderAction.back(onPress: () => Navigator.pop(context))],
      ),
      child: SingleChildScrollView(
        child: Column(
          spacing: 20,
          children: [
            _DeviceInfoDetail(activeHost: activeHost),
            PortGroup(address: activeHost.address, config: config),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _DeviceInfoDetail extends StatelessWidget {
  const _DeviceInfoDetail({required this.activeHost});

  final AddressInfo activeHost;

  @override
  Widget build(BuildContext context) {
    return FTileGroup(
      label: const Text('Device Info'),
      children: [
        FTile(
          title: const Text('IP Address'),
          details: Text(activeHost.address),
          onLongPress: () =>
              Clipboard.setData(ClipboardData(text: activeHost.address)),
        ),
      ],
    );
  }
}
