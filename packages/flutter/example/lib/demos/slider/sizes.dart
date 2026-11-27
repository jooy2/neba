import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class SliderSizes extends StatelessWidget {
  const SliderSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 6,
        children: <Widget>[
          for (final NebaSize size in NebaSize.values)
            NebaSlider(size: size, label: Text(size.name), defaultValue: 50),
        ],
      ),
    );
  }
}
