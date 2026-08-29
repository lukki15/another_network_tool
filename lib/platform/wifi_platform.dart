import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:another_network_tool/platform/models/wifi_info.dart';

class WifiPlatform {
  static const MethodChannel _channel = MethodChannel(
    'another_network_tool/wifi',
  );

  /// Returns WifiInfo on Android; returns an empty `WifiInfo` on other
  /// platforms or on error so callers always receive a non-null value.
  static Future<WifiInfo> getWifiInfo() async {
    if (!Platform.isAndroid) {
      // Linux and other platforms: prepared but not implemented yet
      // Return an already-completed Future with an empty WifiInfo.
      return Future<WifiInfo>.value(WifiInfo());
    }

    try {
      final Map<dynamic, dynamic>? result = await _channel
          .invokeMethod<Map<dynamic, dynamic>>('getWifiInfo');
      return WifiInfo.fromMap(result);
    } on PlatformException {
      return WifiInfo();
    }
  }
}
