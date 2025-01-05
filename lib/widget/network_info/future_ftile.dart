import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

import 'package:another_network_tool/widget/future_text.dart';

class FutureFTile extends FTile {
  FutureFTile({
    super.key,
    required String title,
    required Future<String?> future,
    required String errorMessage,
  }) : super(
          title: Text(title),
          details: FutureText(
            future: future,
            convertToString: (String? s) => s ?? "N/A",
            errorMessage: errorMessage,
          ),
          onLongPress: () => _setClipboardData(future),
        );

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
