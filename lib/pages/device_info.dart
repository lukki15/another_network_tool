import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:network_tools/network_tools.dart';

import 'package:network_info_app/widget/future_text.dart';
import 'package:network_info_app/widget/port_lists/port_group.dart';

class DeviceInfo extends StatelessWidget {
  const DeviceInfo({
    super.key,
    required this.activeHost,
  });

  final ActiveHost activeHost;

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: FutureText(
            future: activeHost.deviceName, convertToString: (String s) => s),
        prefixActions: [
          FHeaderAction.back(onPress: () => Navigator.pop(context)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          spacing: 20,
          children: [
            _DeviceInfoDetail(
              activeHost: activeHost,
            ),
            PortGroup(
              address: activeHost.address,
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _DeviceInfoDetail extends StatelessWidget {
  const _DeviceInfoDetail({required this.activeHost});

  final ActiveHost activeHost;

  static void _futureClipboard(Future<String?> future) {
    future.then((value) {
      if (value != null) {
        Clipboard.setData(ClipboardData(text: value));
      }
    });
  }

  static void _futureClipboardVendor(Future<Vendor?> future) {
    future.then((value) {
      if (value != null) {
        Clipboard.setData(ClipboardData(text: value.vendorName));
      }
    });
  }

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
        FTile(
          title: const Text('MAC Address'),
          details: FutureText(
              future: activeHost.getMacAddress(),
              convertToString: (String? s) => s ?? "N/A"),
          onLongPress: () => _futureClipboard(activeHost.getMacAddress()),
        ),
        FTile(
          title: const Text('Vendor Name'),
          details: FutureText(
              future: activeHost.vendor,
              convertToString: (Vendor? v) => v == null ? "N/A" : v.vendorName),
          onLongPress: () => _futureClipboardVendor(activeHost.vendor),
        ),
      ],
    );
  }
}
