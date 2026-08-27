import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:another_network_tool/provider/address_info.dart';
import 'package:another_network_tool/provider/config.dart';
import 'package:another_network_tool/pages/device_info.dart';
import 'package:another_network_tool/widget/future_text.dart';

class ActiveHostsGroup extends StatefulWidget {
  const ActiveHostsGroup({
    super.key,
    required this.activeHosts,
    required this.config,
  });

  final Set<AddressInfo> activeHosts;
  final Config config;

  @override
  State<ActiveHostsGroup> createState() => _ActiveHostsGroupState();
}

class _ActiveHostsGroupState extends State<ActiveHostsGroup> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  late List<AddressInfo> _hosts;
  final Map<String, Future<String>> _nameFutures = {};

  @override
  void initState() {
    super.initState();
    _hosts = widget.activeHosts.toList();
    for (final h in _hosts) {
      _nameFutures[h.address] = h.getHostName();
    }
  }

  @override
  void didUpdateWidget(covariant ActiveHostsGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newList = widget.activeHosts.toList();

    // Use address sets for quick membership checks.
    final oldAddresses = _hosts.map((h) => h.address).toSet();
    final newAddresses = newList.map((h) => h.address).toSet();

    // Remove items that disappeared (iterate backwards to preserve indices).
    for (var i = _hosts.length - 1; i >= 0; i--) {
      final existing = _hosts[i];
      if (!newAddresses.contains(existing.address)) {
        final removed = _hosts.removeAt(i);
        _removeAt(i, removed);
      }
    }

    // Insert items that are new, at the correct index from newList.
    for (var i = 0; i < newList.length; i++) {
      final item = newList[i];
      if (!oldAddresses.contains(item.address)) {
        _hosts.insert(i, item);
        _insertAt(i, item);
      }
    }
  }

  void _insertAt(int index, AddressInfo item) {
    _nameFutures[item.address] = item.getHostName();
    _listKey.currentState?.insertItem(index);
  }

  void _removeAt(int index, AddressInfo removed) {
    _nameFutures.remove(removed.address);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildItem(context, index, animation, removed),
    );
  }

  Widget _buildTile(BuildContext context, AddressInfo item) {
    return Material(
      key: ValueKey(item.address),
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  DeviceInfo(activeHost: item, config: widget.config),
            ),
          );
        },
        onLongPress: () => Clipboard.setData(ClipboardData(text: item.address)),
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
            future: _nameFutures[item.address] ??= item.getHostName(),
            convertToString: (String s) => s,
            textStyle: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(item.address),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    Animation<double> animation,
    AddressInfo item,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTile(context, item),
          if (index != _hosts.length - 1) const Divider(height: 0),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hosts.isEmpty) {
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

    return AnimatedList(
      key: _listKey,
      initialItemCount: _hosts.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index, animation) {
        final item = _hosts[index];
        return _buildItem(context, index, animation, item);
      },
    );
  }
}
