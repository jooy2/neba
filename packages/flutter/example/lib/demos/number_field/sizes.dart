import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class NumberFieldSizes extends StatelessWidget {
  const NumberFieldSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 3,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        for (final NebaSize size in NebaSize.values)
          SizedBox(
            width: 128,
            child: NebaNumberField(size: size, defaultValue: 8, min: 0, fullWidth: true),
          ),
      ],
    );
  }
}
