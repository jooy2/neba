import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _days = <String>['Today', 'Tomorrow', 'Thursday', 'Friday'];

class StackDepth extends StatelessWidget {
  const StackDepth({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 10,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        for (final NebaStackFront front in NebaStackFront.values)
          NebaFlex(
            direction: NebaOrientation.vertical,
            spacing: 2,
            children: <Widget>[
              NebaTypography(
                front == NebaStackFront.first
                    ? 'scaleStep: 0.94 · opacityStep: 0.75'
                    : 'front: NebaStackFront.last',
                level: NebaTypographyLevel.caption,
                color: NebaColor.secondary,
              ),
              NebaStack(
                direction: NebaStackDirection.diagonal,
                overlap: 64,
                drop: 10,
                scaleStep: 0.94,
                opacityStep: 0.75,
                front: front,
                children: <Widget>[
                  for (final String day in _days)
                    SizedBox(
                      width: 144,
                      child: NebaCard(size: NebaSize.sm, elevation: 1, title: Text(day)),
                    ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
