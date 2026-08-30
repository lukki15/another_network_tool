import 'package:another_network_tool/provider/config.dart';
import 'package:flutter/material.dart';

class DeviceListHeader extends StatelessWidget {
  const DeviceListHeader({
    super.key,
    required this.isDone,
    required this.progressPercent,
    required this.percentText,
    required this.currentIP,
    required this.discoveredCount,
  });

  final bool isDone;
  final double progressPercent;
  final String percentText;
  final int currentIP;
  final int discoveredCount;

  @override
  Widget build(BuildContext context) {
    if (isDone) {
      return _HeaderIsDone(discoveredCount: discoveredCount);
    }

    return _HeaderInProgress(
      progressPercent: progressPercent,
      percentText: percentText,
      currentIP: currentIP,
    );
  }
}

class _HeaderIsDone extends StatelessWidget {
  const new({required this.discoveredCount});

  final int discoveredCount;

  @override
  Widget build(BuildContext context) {
    final deviceText = discoveredCount == 1 ? 'device' : 'devices';
    return ListTile(
      leading: Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
      horizontalTitleGap: 32,
      title: Text(
        'Scan complete',
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '$discoveredCount $deviceText found',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _HeaderInProgress extends StatelessWidget {
  const new({
    required this.progressPercent,
    required this.percentText,
    required this.currentIP,
  });

  final double progressPercent;
  final String percentText;
  final int currentIP;

  @override
  Widget build(BuildContext context) {
    const boxSize = 72.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 32, 0),
      child: Row(
        children: [
          SizedBox(
            width: boxSize,
            height: boxSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: boxSize,
                  height: boxSize,
                  child: CircularProgressIndicator(
                    value: progressPercent,
                    strokeWidth: 8,
                  ),
                ),
                Text(
                  '$percentText%',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scanning devices',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Checking nearby devices on your network',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progressPercent,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(999),
                ),
                const SizedBox(height: 6),
                Text(
                  'scanning $currentIP / ${Config.defaultLastHostId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
