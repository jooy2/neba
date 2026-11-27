import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _items = <String>['alpha', 'beta', 'gamma', 'delta', 'epsilon'];

class AnimateMarqueeSpeed extends StatelessWidget {
  const AnimateMarqueeSpeed({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 3,
        alignItems: NebaAlignItems.stretch,
        children: <Widget>[
          for (final int speed in const <int>[30, 90])
            NebaAnimateMarquee(
              key: ValueKey<int>(speed),
              speed: speed.toDouble(),
              gap: 16,
              children: <Widget>[
                for (final String item in _items)
                  NebaChip(
                    key: ValueKey<String>(item),
                    size: NebaSize.sm,
                    child: Text('$item · ${speed}px/s'),
                  ),
              ],
            ),
          NebaAnimateMarquee(
            speed: 45,
            gap: 16,
            reverse: true,
            children: <Widget>[
              for (final String item in _items)
                NebaChip(
                  key: ValueKey<String>(item),
                  size: NebaSize.sm,
                  color: NebaColor.secondary,
                  child: Text('$item · reverse'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
