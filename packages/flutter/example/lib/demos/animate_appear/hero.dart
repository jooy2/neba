import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<({String title, String body})> _rows = <({String title, String body})>[
  (title: 'Design review', body: 'Thursday, 14:00'),
  (title: 'Sprint planning', body: 'Friday, 10:00'),
  (title: 'Retrospective', body: 'Friday, 16:30'),
];

class AnimateAppearHero extends StatefulWidget {
  const AnimateAppearHero({super.key});

  @override
  State<AnimateAppearHero> createState() => _AnimateAppearHeroState();
}

class _AnimateAppearHeroState extends State<AnimateAppearHero> {
  int _run = 0;

  static Widget _column(List<Widget> children) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 2,
      alignItems: NebaAlignItems.stretch,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: NebaFlex(
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
            layoutBuilder: _column,
            children: <Widget>[
              for (final ({String title, String body}) row in _rows)
                NebaCard(
                  key: ValueKey<String>(row.title),
                  size: NebaSize.sm,
                  title: Text(row.title),
                  child: Text(row.body),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
