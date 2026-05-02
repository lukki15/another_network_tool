import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:another_network_tool/provider/address_info.dart';
import 'package:another_network_tool/provider/config.dart';
import 'package:another_network_tool/pages/device_info.dart';
import 'package:another_network_tool/widget/future_text.dart';

class ActiveHostsGroup extends StatelessWidget {
  const ActiveHostsGroup({
    super.key,
    required this.activeHosts,
    required this.config,
  });

  final Set<AddressInfo> activeHosts;
  final Config config;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var item in activeHosts)
          ListTile(
            leading: Icon(Icons.devices),
            title: FutureText(
              future: item.getHostName(),
              convertToString: (String s) => s,
            ),
            subtitle: Text(item.address),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      DeviceInfo(activeHost: item, config: config),
                ),
              );
            },
            onLongPress: () =>
                Clipboard.setData(ClipboardData(text: item.address)),
          ),
      ],
    );
  }
}
