import 'dart:async';

import 'package:flutter/material.dart';

class StreamControl extends ChangeNotifier {
  bool _cancelled = false;
  Completer<void>? _resumeCompleter;
  final Completer<void> _cancelCompleter = Completer<void>();

  bool get isCancelled => _cancelled;
  bool get isPaused => _resumeCompleter != null;

  Future<void> get cancelled => _cancelCompleter.future;

  void pause() {
    if (_cancelled) return;

    if (_resumeCompleter == null) {
      _resumeCompleter = Completer<void>();
      notifyListeners();
    }
  }

  void resume() {
    final completer = _resumeCompleter;
    _resumeCompleter = null;

    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }

    notifyListeners();
  }

  void cancel() {
    if (_cancelled) return;

    _cancelled = true;

    resume();

    if (!_cancelCompleter.isCompleted) {
      _cancelCompleter.complete();
    }

    notifyListeners();
  }

  Future<void> waitIfPaused() async {
    if (_cancelled) return;

    final resumeFuture = _resumeCompleter?.future;

    if (resumeFuture == null) return;

    await Future.any([resumeFuture, _cancelCompleter.future]);
  }
}
