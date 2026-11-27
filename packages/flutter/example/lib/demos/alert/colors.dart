import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<(NebaColor, String)> _messages = <(NebaColor, String)>[
  (NebaColor.info, 'Two review apps are still building.'),
  (NebaColor.success, 'Deployed to production.'),
  (NebaColor.warning, 'This region is at 90% of its quota.'),
  (NebaColor.danger, 'The database is unreachable.'),
];

class AlertColors extends StatelessWidget {
  const AlertColors({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      children: <Widget>[
        for (final (NebaColor color, String text) in _messages)
          NebaAlert(color: color, child: Text(text)),
      ],
    );
  }
}
