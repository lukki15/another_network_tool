import 'dart:async';

import 'package:another_network_tool/provider/address_info.dart';
import 'package:another_network_tool/utils/stream_control.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:synchronized/synchronized.dart';
import 'package:another_network_tool/utils/subnet.dart';

typedef PingDataProvider = Future<PingEvent> Function(String host);

Future<PingEvent> defaultPingDataProvider(String host) =>
    Ping(host, count: 1, timeout: 1, ipVersion: IpVersion.ipv4).stream.first;

class PingTask {
  final Future<PingEvent> future;
  final String ip;

  PingTask(this.future, this.ip);
}

String _intToIp(int value) {
  return '${(value >> 24) & 0xFF}.'
      '${(value >> 16) & 0xFF}.'
      '${(value >> 8) & 0xFF}.'
      '${value & 0xFF}';
}

Stream<AddressInfo> pingSubnetPatch(
  Subnet subnet,
  StreamControl streamControl, {
  PingDataProvider pingDataProvider = defaultPingDataProvider,
  int patchSize = 10,
}) async* {
  final startInt = subnet.firstHostInt();
  final endInt = subnet.lastHostInt();

  final resultController = StreamController<AddressInfo>();
  final lock = Lock();

  int activeTaskCount = 0;
  int nextIpInt = startInt;

  void closeController() {
    if (!resultController.isClosed) {
      resultController.close();
    }
  }

  void addResult(AddressInfo result) {
    if (streamControl.isCancelled) return;

    if (!resultController.isClosed) {
      resultController.add(result);
    }
  }

  late Future<void> Function(PingTask) processPingTask;

  Future<void> startAvailableTasks() async {
    await streamControl.waitIfPaused();

    if (streamControl.isCancelled) return;

    while (activeTaskCount < patchSize && nextIpInt <= endInt) {
      if (streamControl.isCancelled) return;

      final newIp = _intToIp(nextIpInt);
      nextIpInt++;

      try {
        final newFuture = pingDataProvider(newIp);
        final newTask = PingTask(newFuture, newIp);

        activeTaskCount++;
        unawaited(processPingTask(newTask));
      } catch (_) {
        addResult(AddressInfo(address: newIp, isReachable: false));
      }
    }
  }

  processPingTask = (PingTask task) async {
    if (streamControl.isCancelled) return;

    try {
      final results = await Future.wait<Object?>([
        task.future,

        // If paused, wait here before processing the result.
        // Cancellation also wakes this wait.
        streamControl.waitIfPaused(),
      ]);

      if (streamControl.isCancelled) return;

      final pingEvent = results[0] as PingEvent;

      switch (pingEvent) {
        case PingResponse response:
          addResult(
            AddressInfo(
              address: response.ip ?? task.ip,
              isReachable: response.ip != null,
            ),
          );

        case PingError():
          addResult(AddressInfo(address: task.ip, isReachable: false));

        case PingSummary():
          addResult(AddressInfo(address: task.ip, isReachable: false));
      }
    } catch (_) {
      addResult(AddressInfo(address: task.ip, isReachable: false));
    } finally {
      await lock.synchronized(() async {
        activeTaskCount--;

        // Don't schedule anything after cancellation.
        if (streamControl.isCancelled) {
          if (activeTaskCount == 0) {
            closeController();
          }
          return;
        }

        await startAvailableTasks();

        if (activeTaskCount == 0 && nextIpInt > endInt) {
          closeController();
        }
      });
    }
  };

  // Close if cancelled from the outside.
  streamControl.cancelled.then((_) {
    closeController();
  });

  // Fill initial tasks.
  await lock.synchronized(() async {
    await startAvailableTasks();
  });

  // No tasks were created.
  if (activeTaskCount == 0) {
    closeController();
  }

  yield* resultController.stream;
}
