import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _stories = <String>[
  'Markets close higher for the third day running',
  'Storm warning lifted across the north coast',
  'Transit strike suspended pending talks',
];

class AnimateHeadlineBreaking extends StatelessWidget {
  const AnimateHeadlineBreaking({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaFlex(
        spacing: 3,
        alignItems: NebaAlignItems.center,
        children: <Widget>[
          const NebaChip(
            color: NebaColor.danger,
            variant: NebaVariant.solid,
            size: NebaSize.sm,
            child: Text('Live'),
          ),
          Expanded(
            child: NebaAnimateHeadline(
              interval: const Duration(milliseconds: 2200),
              duration: const Duration(milliseconds: 420),
              children: <Widget>[
                for (final String story in _stories)
                  Text(
                    story,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
