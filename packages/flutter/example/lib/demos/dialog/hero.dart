import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DialogHero extends StatelessWidget {
  const DialogHero({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaDialog(
      triggerBuilder: (BuildContext context, VoidCallback open) {
        return NebaButton(
          onPressed: open,
          color: NebaColor.danger,
          child: const Text('Delete workspace'),
        );
      },
      title: const Text('Delete this workspace?'),
      description: const Text('Every project, deploy and log inside it goes with it.'),
      actions: <Widget>[
        NebaDialogClose(
          builder: (BuildContext context, VoidCallback close) {
            return NebaButton(
              onPressed: close,
              variant: NebaVariant.text,
              color: NebaColor.secondary,
              child: const Text('Cancel'),
            );
          },
        ),
        NebaDialogClose(
          builder: (BuildContext context, VoidCallback close) {
            return NebaButton(
              onPressed: close,
              color: NebaColor.danger,
              child: const Text('Delete'),
            );
          },
        ),
      ],
      child: const Text('This cannot be undone. Members will lose access immediately.'),
    );
  }
}
