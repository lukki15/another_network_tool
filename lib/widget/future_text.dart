import 'package:flutter/material.dart';

class FutureText<T> extends StatelessWidget {
  const FutureText({
    super.key,
    required this.future,
    required this.convertToString,
    this.errorMessage = "Error",
    this.textStyle,
  });

  final Future<T> future;
  final String Function(T) convertToString;
  final String errorMessage;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('No future set.', style: textStyle);
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          case ConnectionState.active:
            return Text('N/A', style: textStyle);
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text(errorMessage, style: textStyle);
            }
            if (snapshot.data != null) {
              return Text(
                convertToString(snapshot.data as T),
                style: textStyle,
              );
            }
            return Text("-", style: textStyle);
        }
      },
    );
  }
}
