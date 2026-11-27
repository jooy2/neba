import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _all = <String>['bug', 'docs', 'good first issue', 'help wanted'];

class ChipInteractive extends StatefulWidget {
  const ChipInteractive({super.key});

  @override
  State<ChipInteractive> createState() => _ChipInteractiveState();
}

class _ChipInteractiveState extends State<ChipInteractive> {
  final Set<String> _selected = <String>{'bug'};
  final List<String> _tags = <String>['react', 'tailwind', 'base-ui'];

  void _toggle(String label) {
    setState(() {
      if (!_selected.remove(label)) {
        _selected.add(label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      children: <Widget>[
        NebaFlex(
          wrap: true,
          spacing: 2,
          alignItems: NebaAlignItems.center,
          children: <Widget>[
            for (final String label in _all)
              NebaChip(
                selected: _selected.contains(label),
                onPressed: () => _toggle(label),
                child: Text(label),
              ),
          ],
        ),
        NebaFlex(
          wrap: true,
          spacing: 2,
          alignItems: NebaAlignItems.center,
          children: <Widget>[
            for (final String tag in _tags)
              NebaChip(
                key: ValueKey<String>(tag),
                variant: NebaVariant.text,
                color: NebaColor.secondary,
                onDelete: () => setState(() => _tags.remove(tag)),
                child: Text(tag),
              ),
            if (_tags.isEmpty)
              Text('No tags left.', style: TextStyle(fontSize: 12, color: tokens.mutedFg)),
          ],
        ),
      ],
    );
  }
}
