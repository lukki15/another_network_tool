import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

const int _defaultStartPort = 1;
const int _defaultEndPort = 65535;
const int _defaultScanTimeoutMillis = 300;
const int _defaultScanConcurrency = 100;

/// Scans for open ports on a target host.
///
/// Returns a stream that emits open port numbers in ascending order.
/// Scans are performed concurrently with a limit of [_defaultScanConcurrency]
/// concurrent tasks to avoid overwhelming the system.
///
/// Parameters:
/// - [target]: The host address or IP to scan (required, must not be empty)
/// - [startPort]: The first port to scan
/// - [endPort]: The last port to scan
///
/// Throws:
/// - [ArgumentError] if ports are invalid or out of range
/// - [ArgumentError] if target is empty
Stream<int> scanPortsForSingleDevice(
  String target, {
  int startPort = _defaultStartPort,
  int endPort = _defaultEndPort,
}) {
  if (target.isEmpty) {
    throw ArgumentError.value(target, 'target', 'Target cannot be empty.');
  }
  if (startPort < 1 || startPort > 65535) {
    throw ArgumentError.value(
      startPort,
      'startPort',
      'Port must be between 1 and 65535.',
    );
  }
  if (endPort < 1 || endPort > 65535) {
    throw ArgumentError.value(
      endPort,
      'endPort',
      'Port must be between 1 and 65535.',
    );
  }
  if (startPort > endPort) {
    throw ArgumentError.value(
      endPort,
      'endPort',
      'endPort must be greater than or equal to startPort.',
    );
  }

  final controller = StreamController<int>();
  final results = <int, bool>{};
  int nextPortToLaunch = startPort;
  int nextPortToEmit = startPort;
  int activeTasks = 0;
  bool isClosing = false;
  bool isCancelled = false;

  void emitAvailablePorts() {
    while (results.containsKey(nextPortToEmit)) {
      final isOpen = results.remove(nextPortToEmit)!;
      if (isOpen) {
        controller.add(nextPortToEmit);
      }
      nextPortToEmit++;
    }
  }

  void tryClose() {
    if (!isClosing && activeTasks == 0 && nextPortToEmit > endPort) {
      isClosing = true;
      controller.close();
    }
  }

  // Declare the function variable early to allow mutual recursion
  late final Future<void> Function(int) scanPort;

  void scheduleNext() {
    while (!controller.isClosed &&
        !isCancelled &&
        activeTasks < _defaultScanConcurrency &&
        nextPortToLaunch <= endPort) {
      final port = nextPortToLaunch++;
      activeTasks++;
      scanPort(port);
    }
  }

  // Define the async function and assign it
  scanPort = (int port) async {
    bool isOpen = false;

    try {
      final socket = await Socket.connect(
        target,
        port,
        timeout: const Duration(milliseconds: _defaultScanTimeoutMillis),
      );
      isOpen = true;
      // Ensure socket is always destroyed to free resources
      try {
        socket.destroy();
      } catch (_) {
        // Ignore errors during cleanup
      }
    } on SocketException {
      // Port is closed or unreachable (expected behavior)
      isOpen = false;
    } catch (e) {
      // Unexpected error - log but don't propagate
      if (kDebugMode) {
        print('Warning: Unexpected error scanning port $port on $target: $e');
      }
      isOpen = false;
    }

    if (controller.isClosed || isCancelled) {
      return;
    }

    results[port] = isOpen;
    activeTasks--;
    emitAvailablePorts();
    scheduleNext();
    tryClose();
  };

  controller.onListen = () {
    scheduleNext();
    tryClose();
  };

  controller.onCancel = () {
    // Stop scheduling new scans when the consumer cancels
    isCancelled = true;
  };

  return controller.stream;
}
