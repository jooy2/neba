import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

typedef _Channel = ({String id, String name, String detail});

const List<_Channel> _channels = <_Channel>[
  (id: 'deploys', name: 'Deploys', detail: 'Every push to a tracked branch'),
  (id: 'failures', name: 'Failures', detail: 'Builds and health checks'),
  (id: 'digest', name: 'Weekly digest', detail: 'Sent on Monday morning'),
];

/// A row that both navigates and holds a control has two things to press,
/// which is why `action` sits outside the pressable area rather than inside
/// it.
class ListInteractive extends StatefulWidget {
  const ListInteractive({super.key});

  @override
  State<ListInteractive> createState() => _ListInteractiveState();
}

class _ListInteractiveState extends State<ListInteractive> {
  final Set<String> _on = <String>{'deploys', 'failures'};
  String _open = 'deploys';

  void _toggle(String id) {
    setState(() {
      if (!_on.remove(id)) {
        _on.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaList(
        dividers: true,
        children: <Widget>[
          for (final _Channel channel in _channels)
            NebaListItem(
              key: ValueKey<String>(channel.id),
              description: Text(channel.detail),
              selected: _open == channel.id,
              onPressed: () => setState(() => _open = channel.id),
              action: NebaSwitch(
                size: NebaSize.sm,
                semanticLabel: 'Turn ${channel.name} on',
                checked: _on.contains(channel.id),
                onCheckedChange: (bool _) => _toggle(channel.id),
              ),
              child: Text(channel.name),
            ),
        ],
      ),
    );
  }
}
