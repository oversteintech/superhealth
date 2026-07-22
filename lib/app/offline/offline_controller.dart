import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { online, offline }

final connectivityStatusProvider =
    NotifierProvider<ConnectivityController, ConnectivityStatus>(
  ConnectivityController.new,
);

class ConnectivityController extends Notifier<ConnectivityStatus> {
  StreamSubscription<List<ConnectivityResult>>? _sub;

  @override
  ConnectivityStatus build() {
    _sub = Connectivity().onConnectivityChanged.listen(_onChange);
    ref.onDispose(() => _sub?.cancel());
    unawaited(_refresh());
    return ConnectivityStatus.online;
  }

  Future<void> _refresh() async {
    final results = await Connectivity().checkConnectivity();
    _onChange(results);
  }

  void _onChange(List<ConnectivityResult> results) {
    final offline = results.isEmpty ||
        results.every((r) => r == ConnectivityResult.none);
    state = offline ? ConnectivityStatus.offline : ConnectivityStatus.online;
  }
}