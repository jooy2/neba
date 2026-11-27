import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _faces = <String>['Ada', 'Bo', 'Cai', 'Dana'];

class AnimateFloatDistance extends StatelessWidget {
  const AnimateFloatDistance({super.key});

  static Widget _row(List<Widget> children) {
    return NebaFlex(spacing: 3, children: children);
  }

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 6,
      children: <Widget>[
        NebaFlex(
          direction: NebaOrientation.vertical,
          spacing: 2,
          children: <Widget>[
            const NebaTypography(
              'stagger: 400 ms, the same drift out of step',
              level: NebaTypographyLevel.caption,
              color: NebaColor.secondary,
            ),
            NebaAnimateFloat(
              stagger: const Duration(milliseconds: 400),
              distance: 10,
              layoutBuilder: _row,
              children: <Widget>[
                for (final String name in _faces)
                  NebaAvatar(key: ValueKey<String>(name), name: name, size: NebaSize.lg),
              ],
            ),
          ],
        ),
        const NebaFlex(
          direction: NebaOrientation.vertical,
          spacing: 2,
          children: <Widget>[
            NebaTypography(
              'from: left · distance: 14 · duration: 2200 ms',
              level: NebaTypographyLevel.caption,
              color: NebaColor.secondary,
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: NebaAnimateFloat(
                from: NebaSide.left,
                distance: 14,
                duration: Duration(milliseconds: 2200),
                child: NebaAvatar(name: 'Eun', size: NebaSize.lg, color: NebaColor.success),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
