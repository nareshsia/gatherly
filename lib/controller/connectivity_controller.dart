import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityController with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _subscription;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;

  ConnectivityController() {
    _initializeConnectivity();
  }

  ConnectivityResult get connectionStatus => _connectionStatus;

  Future<void> _initializeConnectivity() async {
    try {
      _connectionStatus = await _connectivity.checkConnectivity();
    } catch (e) {
      _connectionStatus = ConnectivityResult.none;
    }
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    notifyListeners();
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    _connectionStatus = result;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<bool> checkConnection() async {
    var result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      return false;
    }
    return true;
  }
}
