import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class OtpFieldStates extends StatelessWidget {
  const OtpFieldStates({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 6,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaOtpField(label: Text('Masked'), mask: true, length: 4, defaultValue: '8421'),
        NebaOtpField(
          label: Text('Expired'),
          length: 4,
          defaultValue: '1234',
          error: Text('That code has expired.'),
        ),
        NebaOtpField(label: Text('Read-only'), length: 4, defaultValue: '1234', readOnly: true),
        NebaOtpField(label: Text('Unavailable'), length: 4, defaultValue: '1234', disabled: true),
      ],
    );
  }
}
