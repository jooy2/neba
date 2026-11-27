import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class OtpFieldCharsets extends StatelessWidget {
  const OtpFieldCharsets({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 6,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaOtpField(
          label: Text('Numeric'),
          charset: NebaOtpCharset.numeric,
          length: 4,
          defaultValue: '1234',
        ),
        NebaOtpField(
          label: Text('Alpha'),
          charset: NebaOtpCharset.alpha,
          length: 4,
          defaultValue: 'beta',
        ),
        NebaOtpField(
          label: Text('Alphanumeric'),
          charset: NebaOtpCharset.alphanumeric,
          length: 4,
          defaultValue: 'a1b2',
        ),
      ],
    );
  }
}
