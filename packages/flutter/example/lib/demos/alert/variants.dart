import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AlertVariants extends StatelessWidget {
  const AlertVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      children: <Widget>[
        NebaAlert(
          variant: NebaVariant.solid,
          color: NebaColor.warning,
          title: Text('Card expiring'),
          child: Text('Your card ends in 4242 and expires next month.'),
        ),
        NebaAlert(
          variant: NebaVariant.outline,
          color: NebaColor.warning,
          title: Text('Card expiring'),
          child: Text('Your card ends in 4242 and expires next month.'),
        ),
        NebaAlert(
          variant: NebaVariant.text,
          color: NebaColor.warning,
          title: Text('Card expiring'),
          child: Text('Your card ends in 4242 and expires next month.'),
        ),
      ],
    );
  }
}
