import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityNotifier with ChangeNotifier {
  final Connectivity _connectivity;
  List<ConnectivityResult> _connectionStatus = [];
  late StreamSubscription<List<ConnectivityResult>> _streamSubscription;

  bool _isDisposed = false;

  List<ConnectivityResult> get connectionStatus => _connectionStatus;

  ConnectivityNotifier.withConnectivity(this._connectivity) {
    _initConnectivity();
    _streamSubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      _connectionStatus = result;
      _notifyIfNotDisposed();
    });
  }

  factory ConnectivityNotifier() {
    return ConnectivityNotifier.withConnectivity(Connectivity());
  }

  Future<void> _initConnectivity() async {
    try {
      _connectionStatus = await _connectivity.checkConnectivity();
    } catch (e) {
      _connectionStatus = [];
    }
    _notifyIfNotDisposed();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _streamSubscription.cancel();
    super.dispose();
  }

  void _notifyIfNotDisposed() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
