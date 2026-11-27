import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class SkeletonSwapping extends StatefulWidget {
  const SkeletonSwapping({super.key});

  @override
  State<SkeletonSwapping> createState() => _SkeletonSwappingState();
}

class _SkeletonSwappingState extends State<SkeletonSwapping> {
  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 3,
        alignItems: NebaAlignItems.stretch,
        children: <Widget>[
          NebaCard(
            child: _loading
                ? const NebaSkeleton(
                    shape: NebaSkeletonShape.rect,
                    height: 64,
                    semanticLabel: "Loading this month's usage",
                  )
                : const NebaStatistic(
                    label: Text('Requests this month'),
                    value: 1284910,
                    previousValue: 1142380,
                  ),
          ),
          NebaButton(
            size: NebaSize.sm,
            variant: NebaVariant.outline,
            onPressed: () => setState(() => _loading = !_loading),
            child: Text(_loading ? 'Finish loading' : 'Load again'),
          ),
        ],
      ),
    );
  }
}
