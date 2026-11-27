import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ContextWindowCompact extends StatelessWidget {
  const ContextWindowCompact({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: const NebaToolbar(
        density: NebaDensity.compact,
        // The middle of the bar rather than its start, so the gauge has a
        // width to shrink within on a narrow screen.
        children: <Widget>[
          Flexible(
            child: NebaContextWindow(
              size: NebaSize.xs,
              max: 200000,
              used: 124000,
              breakdown: false,
              cost: 0.42,
            ),
          ),
        ],
      ),
    );
  }
}
