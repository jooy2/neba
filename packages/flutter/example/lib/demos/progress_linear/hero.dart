import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ProgressLinearHero extends StatelessWidget {
  const ProgressLinearHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 5,
        children: <Widget>[
          NebaProgressLinear(value: 64, label: Text('Uploading assets'), showValue: true),
          NebaProgressLinear(color: NebaColor.secondary),
        ],
      ),
    );
  }
}
