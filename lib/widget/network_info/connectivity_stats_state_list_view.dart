import 'package:another_network_tool/widget/future_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConnectivityStatsStateListView extends StatelessWidget {
  const ConnectivityStatsStateListView({
    super.key,
    required this.context,
    required this.details,
  });

  final BuildContext context;
  final List<Map<String, Future<String?>>> details;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: details.length,
        separatorBuilder: (_, _) => const Divider(height: 0),
        itemBuilder: (context, index) {
          final entry = details[index].entries.first;
          final label = entry.key;
          final future = entry.value;

          return InkWell(
            onLongPress: () => _setClipboardData(future),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label),
                  FutureText<String?>(
                    future: future,
                    convertToString: (s) => s ?? '—',
                    errorMessage: 'Error',
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
