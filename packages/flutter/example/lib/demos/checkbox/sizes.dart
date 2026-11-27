import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class CheckboxSizes extends StatelessWidget {
  const CheckboxSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      children: <Widget>[
        for (final NebaSize size in NebaSize.values)
          NebaCheckbox(size: size, label: Text(size.name), defaultChecked: true),
      ],
    );
  }
}
