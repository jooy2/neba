import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class OtpFieldSizes extends StatelessWidget {
  const OtpFieldSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        for (final NebaSize size in NebaSize.values)
          NebaOtpField(size: size, length: 4, label: Text(size.name), defaultValue: '42'),
      ],
    );
  }
}
