import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class LoadingFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final String loadingMessage;
  final Widget Function(T data) onData;
  final Widget? errorWidget;

  const LoadingFutureBuilder({
    super.key,
    required this.future,
    required this.loadingMessage,
    required this.onData,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        Widget child = FProgress.circularIcon();

        if (snapshot.hasData) {
          return onData(snapshot.data!);
        } else if (snapshot.hasError) {
          child = errorWidget ?? Text('Error: ${snapshot.error}');
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(loadingMessage), child],
          ),
        );
      },
    );
  }
}
