import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DialogSizes extends StatelessWidget {
  const DialogSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final NebaSize size in NebaSize.values)
          NebaDialog(
            size: size,
            triggerBuilder: (BuildContext context, VoidCallback open) {
              return NebaButton(
                onPressed: open,
                size: NebaSize.sm,
                variant: NebaVariant.outline,
                color: NebaColor.secondary,
                child: Text(size.name),
              );
            },
            title: Text('A ${size.name} dialog'),
            description: const Text(
              'The size sets the type scale, the padding and the width it is allowed to reach.',
            ),
            actions: <Widget>[
              NebaDialogClose(
                builder: (BuildContext context, VoidCallback close) {
                  return NebaButton(
                    onPressed: close,
                    size: NebaSize.sm,
                    child: const Text('Close'),
                  );
                },
              ),
            ],
            child: const Text(
              'One axis rather than two: there is no separate maxWidth to keep in step with size.',
            ),
          ),
      ],
    );
  }
}
