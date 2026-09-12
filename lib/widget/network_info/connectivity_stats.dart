import 'package:another_network_tool/widget/network_info/connectivity_stats_state_list_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  final Future<bool> Function() isGranted;
  final Future<PermissionStatus> Function() request;

  PermissionHelper({required this.isGranted, required this.request});
}

const _locationPermissionMessage = 'Enable precise location permission';

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
  bool _permissionRequestInProgress = false;

  Future<String?> _initWifiName() {
    if (!kIsWeb && widget.isMobile) {
      return Future<String?>.value(_locationPermissionMessage);
    }

    return widget.networkInfo.getWifiName();
  }

  Future<String?> _initWifiBSSID() {
    if (!kIsWeb && widget.isMobile) {
      return Future<String?>.value(_locationPermissionMessage);
    }

    return widget.networkInfo.getWifiBSSID();
  }

  Future<void> _requestLocationPermission() async {
    if (_permissionRequestInProgress) return;

    setState(() => _permissionRequestInProgress = true);

    try {
      await widget.locationWhenInUse.request();
      final locationGranted = await widget.locationWhenInUse.isGranted();

      if (!mounted || !locationGranted) return;

      setState(() {
        _wifiName = widget.networkInfo.getWifiName();
        _wifiBSSID = widget.networkInfo.getWifiBSSID();
      });
    } finally {
      if (mounted) {
        setState(() => _permissionRequestInProgress = false);
      }
    }
  }

  void _init() {
    _wifiName = _initWifiName();
    _wifiBSSID = _initWifiBSSID();
    _wifiIPv4 = widget.networkInfo.getWifiIP();
    _wifiIPv6 = widget.networkInfo.getWifiIPv6();
    _wifiGatewayIP = widget.networkInfo.getWifiGatewayIP();
    _wifiBroadcast = widget.networkInfo.getWifiBroadcast();
    _wifiSubMask = widget.networkInfo.getWifiSubmask();
  }

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Network Details", style: Theme.of(context).textTheme.titleMedium),
        _generateWifiDetails(context),

        Text(
          "IP Configuration",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        _generateIpConfiguration(context),
      ],
    );
  }

  Widget _generateWifiDetails(BuildContext context) {
    final wifiDetails = [
      {'SSID': _wifiName},
      // {'Security': Future<String?>.value('N/A')},
      // {'Frequency': Future<String?>.value('N/A')},
      // {'Channel': Future<String?>.value('N/A')},
      // {'Link Speed': Future<String?>.value('N/A')},
      // {'Signal Strength': Future<String?>.value('N/A')},
      {'BSSID': _wifiBSSID},
    ];

    return ConnectivityStatsStateListView(
      context: context,
      details: wifiDetails,
      onTapByLabel: _permissionRequestInProgress || kIsWeb || !widget.isMobile
          ? const {}
          : {
              'SSID': _requestLocationPermission,
              'BSSID': _requestLocationPermission,
            },
    );
  }

  Widget _generateIpConfiguration(BuildContext context) {
    final ipDetails = [
      {'IP4 Address': _wifiIPv4},
      {'IP6 Address': _wifiIPv6},
      {'Broadcast': _wifiBroadcast},
      {'Subnet Mask': _wifiSubMask},
      {'Default Gateway': _wifiGatewayIP},
      // {'DNS Server': Future<String?>.value('N/A')},
    ];

    return ConnectivityStatsStateListView(context: context, details: ipDetails);
  }
}
