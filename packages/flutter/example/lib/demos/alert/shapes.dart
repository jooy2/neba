import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AlertShapes extends StatelessWidget {
  const AlertShapes({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      children: <Widget>[
        // A bare line: no glyph, nothing but the sentence.
        NebaAlert(showIcon: false, child: Text('Scheduled maintenance on Sunday at 02:00 UTC.')),

        // The default: a glyph and a line.
        NebaAlert(
          color: NebaColor.info,
          child: Text('Scheduled maintenance on Sunday at 02:00 UTC.'),
        ),

        // A headline with the detail under it.
        NebaAlert(
          color: NebaColor.info,
          title: Text('Scheduled maintenance'),
          child: Text('The API will be read-only on Sunday between 02:00 and 03:00 UTC.'),
        ),
      ],
    );
  }
}
