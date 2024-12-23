import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityManager {
  void listen(void Function(List<ConnectivityResult>) callback) async {
    await _initConnectivity(callback);

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(callback);
  }

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  void dispose() {
    _connectivitySubscription.cancel();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _initConnectivity(
      void Function(List<ConnectivityResult>) callback) async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      // Could not check connectivity status
      return;
    }

    return callback(result);
  }
}
