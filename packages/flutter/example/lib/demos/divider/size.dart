import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DividerSize extends StatelessWidget {
  const DividerSize({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 4,
        children: <Widget>[
          NebaTypography('Full width, 1 pixel: the default', level: NebaTypographyLevel.caption),
          NebaDivider(),
          NebaTypography('Half the width', level: NebaTypographyLevel.caption),
          FractionallySizedBox(
            widthFactor: 0.5,
            alignment: AlignmentDirectional.centerStart,
            child: NebaDivider(),
          ),
          NebaTypography('length: 120, thickness: 2', level: NebaTypographyLevel.caption),
          NebaDivider(length: 120, thickness: 2, color: NebaColor.success),
          NebaTypography('thickness: 4', level: NebaTypographyLevel.caption),
          NebaDivider(thickness: 4, color: NebaColor.danger),
          NebaTypography('Vertical, length: 48', level: NebaTypographyLevel.caption),
          Row(
            spacing: 16,
            children: <Widget>[
              NebaTypography('before', level: NebaTypographyLevel.caption),
              NebaDivider(
                orientation: NebaOrientation.vertical,
                length: 48,
                thickness: 2,
                color: NebaColor.info,
              ),
              NebaTypography('after', level: NebaTypographyLevel.caption),
            ],
          ),
        ],
      ),
    );
  }
}
