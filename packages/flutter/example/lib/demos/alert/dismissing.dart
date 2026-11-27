import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AlertDismissing extends StatefulWidget {
  const AlertDismissing({super.key});

  @override
  State<AlertDismissing> createState() => _AlertDismissingState();
}

class _AlertDismissingState extends State<AlertDismissing> {
  bool _shown = true;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      alignItems: NebaAlignItems.start,
      spacing: 3,
      children: <Widget>[
        if (_shown)
          NebaAlert(
            color: NebaColor.info,
            title: const Text('A new version is available'),
            action: NebaButton(
              onPressed: () {},
              size: NebaSize.xs,
              variant: NebaVariant.outline,
              color: NebaColor.info,
              child: const Text('Reload'),
            ),
            closeLabel: 'Dismiss the update notice',
            onClose: () => setState(() => _shown = false),
            child: const Text('Version 2.4 fixes the deploy log ordering.'),
          )
        else
          NebaButton(
            onPressed: () => setState(() => _shown = true),
            size: NebaSize.sm,
            variant: NebaVariant.text,
            child: const Text('Bring it back'),
          ),
      ],
    );
  }
}
