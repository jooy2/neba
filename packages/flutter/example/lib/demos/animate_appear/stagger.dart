import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _tags = <String>['design', 'frontend', 'infra', 'docs', 'billing', 'search'];

class AnimateAppearStagger extends StatefulWidget {
  const AnimateAppearStagger({super.key});

  @override
  State<AnimateAppearStagger> createState() => _AnimateAppearStaggerState();
}

class _AnimateAppearStaggerState extends State<AnimateAppearStagger> {
  int _run = 0;

  static Widget _wrap(List<Widget> children) {
    return NebaFlex(
      wrap: true,
      spacing: 2,
      justifyContent: NebaJustifyContent.center,
      children: children,
    );
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
          key: ValueKey<int>(_run),
          stagger: const Duration(milliseconds: 140),
          layoutBuilder: _wrap,
          children: <Widget>[
            for (final String tag in _tags) NebaChip(key: ValueKey<String>(tag), child: Text(tag)),
          ],
        ),
      ],
    );
  }
}
