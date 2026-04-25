import 'dart:async';

import 'package:another_network_tool/provider/address_info.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:synchronized/synchronized.dart';

typedef PingDataProvider = Future<PingData> Function(String host);

Future<PingData> defaultPingDataProvider(String host) =>
    Ping(host, count: 1, timeout: 1).stream.first;

class PingTask {
  final Future<PingData> future;
  final String ip;

  PingTask(this.future, this.ip);
}

Stream<AddressInfo> pingHostsPatch(
  String subnet, {
  PingDataProvider pingDataProvider = defaultPingDataProvider,
  int start = 1,
  int end = 254,
  int patchSize = 10,
}) async* {
  StreamController<AddressInfo> resultController =
      StreamController<AddressInfo>();
  Lock lock = Lock();
  int activeTaskCount = 0;
  int nextIp = start;

  void processPingTask(PingTask task) {
    task.future
        .then((PingData pingData) {
          if (pingData.error == null &&
              pingData.response != null &&
              pingData.response!.ip != null) {
            resultController.add(
              AddressInfo(address: pingData.response!.ip!, isReachable: true),
            );
          } else {
            resultController.add(
              AddressInfo(address: task.ip, isReachable: false),
            );
          }
        })
        .catchError((error) {
          resultController.add(
            AddressInfo(address: task.ip, isReachable: false),
          );
        })
        .whenComplete(() {
          lock.synchronized(() {
            activeTaskCount--;
            if (nextIp <= end) {
              String newIp = '$subnet.$nextIp';
              nextIp++;
              Future<PingData> newFuture = pingDataProvider(newIp);
              PingTask newTask = PingTask(newFuture, newIp);
              activeTaskCount++;
              processPingTask(newTask);
            }
            if (activeTaskCount == 0 && nextIp > end) {
              resultController.close();
            }
          });
        });
  }

  // Fill initial tasks
  lock.synchronized(() {
    for (int i = 0; i < patchSize && nextIp <= end; i++) {
      String ip = '$subnet.$nextIp';
      nextIp++;
      Future<PingData> future = pingDataProvider(ip);
      PingTask task = PingTask(future, ip);
      activeTaskCount++;
      processPingTask(task);
    }
  });

  // Close immediately if no tasks were created (e.g., start > end)
  if (activeTaskCount == 0) {
    resultController.close();
  }

  yield* resultController.stream;
}
