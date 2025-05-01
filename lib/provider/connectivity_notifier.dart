import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityNotifier with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  List<ConnectivityResult> _connectionStatus = [];
  late StreamSubscription<List<ConnectivityResult>> _streamSubscription;

  List<ConnectivityResult> get connectionStatus => _connectionStatus;

  ConnectivityNotifier() {
    _initConnectivity();
    _streamSubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      _connectionStatus = result;
      notifyListeners();
    });
  }

  Future<void> _initConnectivity() async {
    try {
      _connectionStatus = await _connectivity.checkConnectivity();
    } catch (e) {
      _connectionStatus = [];
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}
