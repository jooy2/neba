import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class SliderHero extends StatelessWidget {
  const SliderHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 8,
        children: <Widget>[
          NebaSlider(label: Text('Volume'), defaultValue: 65, showValue: true),
          NebaSlider.range(
            label: Text('Budget'),
            defaultValues: <double>[20, 80],
            showValue: true,
            color: NebaColor.success,
          ),
        ],
      ),
    );
  }
}
