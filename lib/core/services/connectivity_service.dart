import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  bool _lastConnectionState = true;

  Stream<bool> get isOnline async* {
    _lastConnectionState = await _isConnected();
    yield _lastConnectionState;
    
    await for (final result in _connectivity.onConnectivityChanged) {
      final hasInterface = result != ConnectivityResult.none;
      var isConnected = hasInterface && await _hasInternetLoose();

      if (!isConnected && hasInterface) {
        await Future.delayed(const Duration(seconds: 2));
        final retryConnected = await _hasInternetLoose();
        if (retryConnected != isConnected) {
          isConnected = retryConnected;
        }
      }

      if (isConnected != _lastConnectionState) {
        await Future.delayed(const Duration(milliseconds: 200));
        _lastConnectionState = isConnected;
        yield isConnected;
      }
    }
  }

  Future<bool> _isConnected() async {
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) return false;
    return _hasInternet();
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com').timeout(const Duration(seconds: 2));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _hasInternetLoose() async {
    try {
      final result = await InternetAddress.lookup('example.com').timeout(const Duration(seconds: 2));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.read(connectivityServiceProvider);
  return service.isOnline;
});
