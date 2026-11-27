import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class OtpFieldLengths extends StatelessWidget {
  const OtpFieldLengths({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 6,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaOtpField(label: Text('Four digit PIN'), length: 4, size: NebaSize.sm),
        NebaOtpField(label: Text('Six digit code, in two blocks'), length: 6, groupSize: 3),
        // Nine cells are wider than a small phone, so they scroll there.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: NebaOtpField(
            label: Text('Nine character key, in three'),
            length: 9,
            groupSize: 3,
            charset: NebaOtpCharset.alphanumeric,
            size: NebaSize.sm,
          ),
        ),
      ],
    );
  }
}
