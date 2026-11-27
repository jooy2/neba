import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ProgressLinearSizes extends StatelessWidget {
  const ProgressLinearSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 4,
        children: <Widget>[
          for (final NebaSize size in NebaSize.values)
            NebaProgressLinear(size: size, value: 45, label: Text(size.name), showValue: true),
        ],
      ),
    );
  }
}
