import 'package:another_network_tool/pages/device_info_summary_card.dart';
import 'package:another_network_tool/provider/address_info.dart';
import 'package:another_network_tool/provider/config.dart';
import 'package:flutter/material.dart';

import 'package:another_network_tool/widget/future_text.dart';
import 'package:another_network_tool/widget/port_lists/port_group.dart';

class DeviceInfo extends StatelessWidget {
  const DeviceInfo({super.key, required this.activeHost, required this.config});

  final AddressInfo activeHost;
  final Config config;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureText(
          future: activeHost.getHostName(),
          convertToString: (String s) => s,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DeviceInfoSummaryCard(activeHost: activeHost),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PortGroup(address: activeHost.address, config: config),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
