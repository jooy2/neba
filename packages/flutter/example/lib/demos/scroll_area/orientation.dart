import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _tags = <String>[
  'react',
  'typescript',
  'tailwind',
  'base-ui',
  'design-system',
  'components',
  'accessibility',
  'esm',
  'tree-shaking',
  'dark-mode',
];

class ScrollAreaOrientation extends StatelessWidget {
  const ScrollAreaOrientation({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaBox(
        child: NebaScrollArea(
          orientation: NebaScrollAreaOrientation.horizontal,
          fade: true,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NebaFlex(
              spacing: 2,
              alignItems: NebaAlignItems.center,
              children: <Widget>[
                for (final String tag in _tags) NebaChip(size: NebaSize.sm, child: Text(tag)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
