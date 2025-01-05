import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:network_tools/network_tools.dart';

import 'package:another_network_tool/pages/device_info.dart';
import 'package:another_network_tool/widget/future_text.dart';

class ActiveHostsGroup extends StatelessWidget {
  const ActiveHostsGroup({
    super.key,
    required this.activeHosts,
  });

  final Set<ActiveHost> activeHosts;

  @override
  Widget build(BuildContext context) {
    return FTileGroup(
      children: [
        for (var item in activeHosts)
          FTile(
            prefixIcon: FIcon(FAssets.icons.monitorSmartphone),
            title: FutureText(
                future: item.deviceName, convertToString: (String s) => s),
            subtitle: Text(item.address),
            details: Platform.isAndroid
                // Since Android SDK 32, apps are no longer allowed to access the MAC address.
                ? Text("")
                : FutureText(
                    future: item.vendor,
                    convertToString: (Vendor? v) =>
                        v == null ? "" : v.vendorName,
                  ),
            onPress: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DeviceInfo(
                        activeHost: item,
                      )));
            },
            onLongPress: () =>
                Clipboard.setData(ClipboardData(text: item.address)),
          )
      ],
    );
  }
}
