import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AlertHero extends StatelessWidget {
  const AlertHero({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      children: <Widget>[
        const NebaAlert(color: NebaColor.success, child: Text('Your changes have been saved.')),
        NebaAlert(
          color: NebaColor.danger,
          title: const Text('Deploy failed'),
          action: NebaButton(
            onPressed: () {},
            size: NebaSize.xs,
            variant: NebaVariant.outline,
            color: NebaColor.danger,
            child: const Text('Retry'),
          ),
          onClose: () {},
          child: const Text('The build exited with code 1. Check the logs for the failing step.'),
        ),
      ],
    );
  }
}
