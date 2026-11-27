import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const NebaSliderMarks _sizes = NebaSliderMarks(<NebaSliderMark>[
  NebaSliderMark(value: 1, label: Text('1')),
  NebaSliderMark(value: 100, label: Text('100')),
  NebaSliderMark(value: 250, label: Text('250')),
  NebaSliderMark(value: 500, label: Text('500')),
]);

const NebaSliderMarks _styles = NebaSliderMarks(<NebaSliderMark>[
  NebaSliderMark(value: 0, label: Text('Realistic')),
  NebaSliderMark(value: 100, label: Text('Abstract')),
]);

class SliderMarks extends StatelessWidget {
  const SliderMarks({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 8,
        children: <Widget>[
          NebaSlider(
            label: Text('Batch size'),
            min: 1,
            max: 500,
            defaultValue: 100,
            marks: _sizes,
            showValue: true,
          ),
          NebaSlider(label: Text('Style'), defaultValue: 50, marks: _styles),
          // `NebaSliderMarks.steps` is a tick at every step, which is worth
          // pairing with a step you chose.
          NebaSlider(
            label: Text('Strength'),
            step: 20,
            defaultValue: 40,
            marks: NebaSliderMarks.steps,
            showValue: true,
          ),
        ],
      ),
    );
  }
}
