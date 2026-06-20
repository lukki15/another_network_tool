import 'package:flutter/material.dart';

class ConductivityCard extends StatelessWidget {
  const ConductivityCard({
    super.key,
    required this.isConnected,
    required this.isConnectedIcon,
    required this.isDisconnectedIcon,
    required this.networkName,
  });

  final bool isConnected;
  final IconData isConnectedIcon;
  final IconData isDisconnectedIcon;
  final String networkName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card.outlined(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Icon(
              isConnected ? isConnectedIcon : isDisconnectedIcon,
              size: 72,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              networkName,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (isConnected) ...[
              const SizedBox(height: 8),
              Text(
                'Connected',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
