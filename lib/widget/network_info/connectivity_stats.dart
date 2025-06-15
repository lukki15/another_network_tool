import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:another_network_tool/widget/network_info/future_ftile.dart';

class PermissionHelper {
  final Future<bool> Function() isGranted;
  final Future<PermissionStatus> Function() request;

  PermissionHelper({required this.isGranted, required this.request});
}

class ConnectivityStats extends StatefulWidget {
  final NetworkInfo networkInfo;
  final bool isMobile;
  final PermissionHelper locationWhenInUse;

  const ConnectivityStats({
    super.key,
    required this.networkInfo,
    required this.isMobile,
    required this.locationWhenInUse,
  });

  @override
  State<ConnectivityStats> createState() => _ConnectivityStatsState();
}

class _ConnectivityStatsState extends State<ConnectivityStats> {
  Future<String?> _wifiName = Future<String?>.value(null);
  Future<String?> _wifiBSSID = Future<String?>.value(null);
  Future<String?> _wifiIPv4 = Future<String?>.value(null);
  Future<String?> _wifiIPv6 = Future<String?>.value(null);
  Future<String?> _wifiGatewayIP = Future<String?>.value(null);
  Future<String?> _wifiBroadcast = Future<String?>.value(null);
  Future<String?> _wifiSubMask = Future<String?>.value(null);

  Future<String?> _initWifiName() async {
    if (!kIsWeb && widget.isMobile) {
      // Request permissions as recommended by the plugin documentation:
      // https://github.com/fluttercommunity/plus_plugins/tree/main/packages/network_info_plus/network_info_plus
      if (await widget.locationWhenInUse.isGranted()) {
        return widget.networkInfo.getWifiName();
      } else {
        return 'Unauthorized to get Wifi Name';
      }
    } else {
      return widget.networkInfo.getWifiName();
    }
  }

  Future<String?> _initWifiBSSID() async {
    if (!kIsWeb && widget.isMobile) {
      // Request permissions as recommended by the plugin documentation:
      // https://github.com/fluttercommunity/plus_plugins/tree/main/packages/network_info_plus/network_info_plus
      if (await widget.locationWhenInUse.isGranted()) {
        return widget.networkInfo.getWifiBSSID();
      } else {
        return 'Unauthorized to get Wifi BSSID';
      }
    } else {
      return widget.networkInfo.getWifiBSSID();
    }
  }

  void _init() async {
    if (!kIsWeb && widget.isMobile) {
      await widget.locationWhenInUse.request();
    }

    setState(() {
      _wifiName = _initWifiName();
      _wifiBSSID = _initWifiBSSID();
      _wifiIPv4 = widget.networkInfo.getWifiIP();
      _wifiIPv6 = widget.networkInfo.getWifiIPv6();
      _wifiGatewayIP = widget.networkInfo.getWifiGatewayIP();
      _wifiBroadcast = widget.networkInfo.getWifiBroadcast();
      _wifiSubMask = widget.networkInfo.getWifiSubmask();
    });
  }

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  Widget build(BuildContext context) {
    return FTileGroup(
      children: [
        FutureFTile(
          title: 'Wifi Name',
          future: _wifiName,
          errorMessage: 'Failed to get Wifi Name',
        ),
        FutureFTile(
          title: 'Wifi BSSID',
          future: _wifiBSSID,
          errorMessage: 'Failed to get Wifi BSSID',
        ),
        FutureFTile(
          title: 'Wifi IPv4',
          future: _wifiIPv4,
          errorMessage: 'Failed to get Wifi IPv4',
        ),
        FutureFTile(
          title: 'Wifi IPv6',
          future: _wifiIPv6,
          errorMessage: 'Failed to get Wifi IPv6',
        ),
        FutureFTile(
          title: 'Wifi Gateway',
          future: _wifiGatewayIP,
          errorMessage: 'Failed to get Wifi gateway address',
        ),
        FutureFTile(
          title: 'Wifi Broadcast',
          future: _wifiBroadcast,
          errorMessage: 'Failed to get Wifi broadcast',
        ),
        FutureFTile(
          title: 'Wifi Submask',
          future: _wifiSubMask,
          errorMessage: 'Failed to get Wifi submask address',
        ),
      ],
    );
  }
}
