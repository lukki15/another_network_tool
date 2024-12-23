import 'package:flutter/material.dart';

class FutureText<T> extends StatelessWidget {
  const FutureText({
    super.key,
    required this.future,
    required this.convertToString,
  });

  final Future<T> future;
  final String Function(T) convertToString;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
          return Text(
            snapshot.hasData && snapshot.data != null
                ? convertToString(snapshot
                    .data!) // ignore: null_check_on_nullable_type_parameter
                : "N/A",
          );
        });
  }
}
