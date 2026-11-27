import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _steps = <String>['One', 'Two', 'Three', 'Four'];

class AnimateAppearDirection extends StatefulWidget {
  const AnimateAppearDirection({super.key});

  @override
  State<AnimateAppearDirection> createState() => _AnimateAppearDirectionState();
}

class _AnimateAppearDirectionState extends State<AnimateAppearDirection> {
  int _run = 0;

  static Widget _row(List<Widget> children) {
    return NebaFlex(wrap: true, spacing: 2, children: children);
  }

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaButton(
          onPressed: () => setState(() => _run += 1),
          size: NebaSize.sm,
          variant: NebaVariant.outline,
          child: const Text('Play again'),
        ),
        NebaAnimateAppear(
          key: ValueKey<String>('forward-$_run'),
          from: NebaSide.left,
          layoutBuilder: _row,
          children: <Widget>[
            for (final String step in _steps)
              NebaChip(key: ValueKey<String>(step), color: NebaColor.info, child: Text(step)),
          ],
        ),
        NebaAnimateAppear(
          key: ValueKey<String>('reverse-$_run'),
          from: NebaSide.left,
          reverse: true,
          layoutBuilder: _row,
          children: <Widget>[
            for (final String step in _steps)
              NebaChip(key: ValueKey<String>(step), color: NebaColor.secondary, child: Text(step)),
          ],
        ),
      ],
    );
  }
}
