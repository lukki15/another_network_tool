import 'dart:async';

import 'package:another_network_tool/utils/stream_control.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StreamControl', () {
    test('initial state is running and not cancelled', () async {
      final control = StreamControl();

      expect(control.isCancelled, isFalse);
      expect(control.isPaused, isFalse);
      expect(control.cancelled, doesNotComplete);
    });

    test('pause changes state', () {
      final control = StreamControl();

      control.pause();

      expect(control.isPaused, isTrue);
      expect(control.isCancelled, isFalse);
    });

    test('pause is idempotent', () {
      final control = StreamControl();

      control.pause();
      control.pause();
      control.pause();

      expect(control.isPaused, isTrue);
      expect(control.isCancelled, isFalse);
    });

    test('resume changes state', () {
      final control = StreamControl();
      control.pause();

      control.resume();

      expect(control.isPaused, isFalse);
      expect(control.isCancelled, isFalse);
    });

    test('resume while not paused is safe', () {
      final control = StreamControl();

      control.resume();
      control.resume();

      expect(control.isPaused, isFalse);
      expect(control.isCancelled, isFalse);
    });

    test('waitIfPaused completes immediately when running', () async {
      final control = StreamControl();

      await control.waitIfPaused();
    });

    test('waitIfPaused waits while paused and resumes when released', () async {
      final control = StreamControl();
      final completed = Completer<void>();

      control.pause();
      final waiting = control.waitIfPaused().then((_) => completed.complete());

      expect(completed.isCompleted, isFalse);

      control.resume();
      await waiting;
      await completed.future;

      expect(control.isPaused, isFalse);
    });

    test('resume releases waitIfPaused', () async {
      final control = StreamControl();
      control.pause();

      final waiting = control.waitIfPaused();

      control.resume();

      await waiting;
      expect(control.isPaused, isFalse);
    });

    test('cancel releases waitIfPaused', () async {
      final control = StreamControl();
      control.pause();

      final waiting = control.waitIfPaused();

      control.cancel();

      await waiting;
      expect(control.isCancelled, isTrue);
      expect(control.isPaused, isFalse);
    });

    test('cancel changes state', () {
      final control = StreamControl();

      control.cancel();

      expect(control.isCancelled, isTrue);
      expect(control.isPaused, isFalse);
    });

    test('cancelled future completes after cancel', () async {
      final control = StreamControl();

      control.cancel();

      await control.cancelled;
      expect(control.isCancelled, isTrue);
    });

    test('cancel is idempotent', () async {
      final control = StreamControl();

      control.cancel();
      control.cancel();
      control.cancel();

      await control.cancelled;
      expect(control.isCancelled, isTrue);
      expect(control.isPaused, isFalse);
    });

    test('cancel while paused clears pause and releases wait', () async {
      final control = StreamControl();
      control.pause();

      final waiting = control.waitIfPaused();
      control.cancel();

      await waiting;
      expect(control.isCancelled, isTrue);
      expect(control.isPaused, isFalse);
    });

    test('pause after cancel does nothing', () {
      final control = StreamControl();

      control.cancel();
      control.pause();

      expect(control.isCancelled, isTrue);
      expect(control.isPaused, isFalse);
    });

    test('resume after cancel does not revive controller', () {
      final control = StreamControl();

      control.cancel();
      control.resume();

      expect(control.isCancelled, isTrue);
      expect(control.isPaused, isFalse);
    });

    test('pause and resume notify listeners when state changes', () {
      final control = StreamControl();
      var notifications = 0;
      control.addListener(() => notifications++);

      control.pause();
      expect(notifications, greaterThanOrEqualTo(1));
      expect(control.isPaused, isTrue);

      control.resume();
      expect(notifications, greaterThanOrEqualTo(2));
      expect(control.isPaused, isFalse);

      control.cancel();
      expect(notifications, greaterThanOrEqualTo(3));
      expect(control.isCancelled, isTrue);
    });
  });
}
