import 'dart:async';

import 'package:another_network_tool/provider/connectivity_notifier.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'connectivity_notifier_test.mocks.dart';

void main() {
  group('ConnectivityNotifier lifecycle', () {
    late MockConnectivity connectivity;
    late StreamController<List<ConnectivityResult>> controller;

    setUp(() {
      connectivity = MockConnectivity();
      controller = StreamController<List<ConnectivityResult>>();

      when(connectivity.onConnectivityChanged)
          .thenAnswer((_) => controller.stream);
      when(connectivity.checkConnectivity())
          .thenAnswer((_) async => <ConnectivityResult>[]);
    });

    tearDown(() async {
      await controller.close();
    });

    test('notifies listeners when connectivity changes', () async {
      final notifier = ConnectivityNotifier.withConnectivity(connectivity);

      var notifications = 0;
      notifier.addListener(() {
        notifications++;
      });

      await Future<void>.delayed(Duration.zero);

      controller.add(<ConnectivityResult>[ConnectivityResult.wifi]);
      await Future<void>.delayed(Duration.zero);

      expect(notifier.connectionStatus, <ConnectivityResult>[
        ConnectivityResult.wifi,
      ]);
      expect(notifications, greaterThanOrEqualTo(1));

      notifier.dispose();
    });

    test('does not react to stream events after dispose', () async {
      final notifier = ConnectivityNotifier.withConnectivity(connectivity);

      var notifications = 0;
      notifier.addListener(() {
        notifications++;
      });

      await Future<void>.delayed(Duration.zero);

      notifier.dispose();

      final notificationCountAfterDispose = notifications;

      controller.add(<ConnectivityResult>[ConnectivityResult.mobile]);
      await Future<void>.delayed(Duration.zero);

      expect(notifications, notificationCountAfterDispose);
      expect(notifier.connectionStatus, isEmpty);
    });

    test('initial connectivity result is applied asynchronously', () async {
      when(connectivity.checkConnectivity()).thenAnswer(
        (_) async => <ConnectivityResult>[ConnectivityResult.ethernet],
      );

      final notifier = ConnectivityNotifier.withConnectivity(connectivity);

      expect(notifier.connectionStatus, isEmpty);

      await Future<void>.delayed(Duration.zero);

      expect(notifier.connectionStatus, <ConnectivityResult>[
        ConnectivityResult.ethernet,
      ]);

      notifier.dispose();
    });
  });
}
