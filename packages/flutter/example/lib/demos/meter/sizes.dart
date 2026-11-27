import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class MeterSizes extends StatelessWidget {
  const MeterSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 5,
        children: <Widget>[
          for (final NebaSize size in NebaSize.values)
            NebaMeter(size: size, value: 62, label: Text(size.name), showValue: true),
        ],
      ),
    );
  }
}
