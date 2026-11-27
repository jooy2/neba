import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class SkeletonLines extends StatelessWidget {
  const SkeletonLines({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 6,
        children: <Widget>[
          NebaSkeleton(size: NebaSize.sm, lines: 2),
          NebaSkeleton(lines: 4),
          NebaSkeleton(size: NebaSize.lg, lines: 3),
        ],
      ),
    );
  }
}
