import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class SkeletonHero extends StatelessWidget {
  const SkeletonHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      // A card's body is one block of copy, so the rows it holds bring their
      // own rhythm.
      child: const NebaCard(
        child: NebaFlex(
          direction: NebaOrientation.vertical,
          spacing: 4,
          children: <Widget>[
            Row(
              spacing: 12,
              children: <Widget>[
                NebaSkeleton(shape: NebaSkeletonShape.circle, size: NebaSize.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: <Widget>[
                      FractionallySizedBox(
                        widthFactor: 0.45,
                        alignment: AlignmentDirectional.centerStart,
                        child: NebaSkeleton(),
                      ),
                      FractionallySizedBox(
                        widthFactor: 0.3,
                        alignment: AlignmentDirectional.centerStart,
                        child: NebaSkeleton(size: NebaSize.sm),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            NebaSkeleton(shape: NebaSkeletonShape.rect, height: 120),
            NebaSkeleton(lines: 3),
          ],
        ),
      ),
    );
  }
}
