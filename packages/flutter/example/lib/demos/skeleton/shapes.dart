import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class SkeletonShapes extends StatelessWidget {
  const SkeletonShapes({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    Widget labelled(String name, Widget skeleton) {
      return NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 2,
        children: <Widget>[
          Text(name, style: TextStyle(fontSize: 12, color: tokens.mutedFg)),
          skeleton,
        ],
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 5,
        children: <Widget>[
          labelled('line', const NebaSkeleton()),
          labelled('rect', const NebaSkeleton(shape: NebaSkeletonShape.rect)),
          labelled(
            'circle',
            const NebaSkeleton(shape: NebaSkeletonShape.circle, size: NebaSize.xl),
          ),
        ],
      ),
    );
  }
}
