import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _sheets = <String>['Invoice', 'Receipt', 'Contract'];

class StackDirection extends StatelessWidget {
  const StackDirection({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 10,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        for (final NebaStackDirection direction in NebaStackDirection.values)
          NebaFlex(
            direction: NebaOrientation.vertical,
            spacing: 2,
            children: <Widget>[
              NebaTypography(
                direction.name,
                level: NebaTypographyLevel.caption,
                color: NebaColor.secondary,
              ),
              NebaStack(
                direction: direction,
                overlap: 28,
                drop: 14,
                children: <Widget>[for (final String sheet in _sheets) _Sheet(label: sheet)],
              ),
            ],
          ),
      ],
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      child: NebaCard(
        size: NebaSize.sm,
        child: NebaTypography(label, level: NebaTypographyLevel.caption),
      ),
    );
  }
}
