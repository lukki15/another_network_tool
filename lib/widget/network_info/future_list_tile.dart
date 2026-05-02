import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:another_network_tool/widget/future_text.dart';

class FutureListTile extends StatelessWidget {
  final String title;
  final Future<String?> future;
  final String errorMessage;

  const FutureListTile({
    super.key,
    required this.title,
    required this.future,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: FutureText(
        future: future,
        convertToString: (String? s) => s ?? "N/A",
        errorMessage: errorMessage,
      ),
      onLongPress: () => _setClipboardData(future),
    );
  }

  static void _setClipboardData(Future<String?> future) async {
    try {
      String? text = await future;
      if (text != null) {
        Clipboard.setData(ClipboardData(text: text));
      }
    } catch (e) {
      // nothing to copy
    }
  }
}
