import 'package:flutter/material.dart';

class FutureText<T> extends StatelessWidget {
  const FutureText({
    super.key,
    required this.future,
    required this.convertToString,
    this.errorMessage = "Error",
  });

  final Future<T> future;
  final String Function(T) convertToString;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('No future set.');
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          case ConnectionState.active:
            return Text('N/A');
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text(errorMessage);
            }
            if (snapshot.data != null) {
              return Text(convertToString(snapshot.data as T));
            }
            return Text("-");
        }
      },
    );
  }
}
