import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:another_network_tool/provider/address_info.dart';
import 'package:another_network_tool/provider/config.dart';
import 'package:another_network_tool/pages/device_info.dart';
import 'package:another_network_tool/widget/future_text.dart';

class ActiveHostsGroup extends StatelessWidget {
  const ActiveHostsGroup({
    super.key,
    required this.activeHosts,
    required this.config,
  });

  final Set<AddressInfo> activeHosts;
  final Config config;

  @override
  Widget build(BuildContext context) {
    if (activeHosts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            'No devices discovered yet',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activeHosts.length,
      separatorBuilder: (_, _) => const Divider(height: 0),
      itemBuilder: (context, index) {
        final item = activeHosts.elementAt(index);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      DeviceInfo(activeHost: item, config: config),
                ),
              );
            },
            onLongPress: () =>
                Clipboard.setData(ClipboardData(text: item.address)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.devices,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              title: FutureText(
                future: item.getHostName(),
                convertToString: (String s) => s,
                textStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(item.address),
            ),
          ),
        );
      },
    );
  }
}
