import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ProgressBoxHero extends StatelessWidget {
  const ProgressBoxHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 8,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaProgressBox(),
        NebaProgressBox(
          value: 62,
          label: Text('Migrating'),
          showValue: true,
          color: NebaColor.info,
        ),
      ],
    );
  }
}
