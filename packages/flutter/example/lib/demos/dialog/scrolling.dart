import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DialogScrolling extends StatelessWidget {
  const DialogScrolling({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return NebaDialog(
      dividers: true,
      size: NebaSize.lg,
      triggerBuilder: (BuildContext context, VoidCallback open) {
        return NebaButton(
          onPressed: open,
          variant: NebaVariant.outline,
          child: const Text('Read the terms'),
        );
      },
      title: const Text('Terms of service'),
      description: const Text('Last updated 2 March'),
      actions: <Widget>[
        NebaDialogClose(
          builder: (BuildContext context, VoidCallback close) {
            return NebaButton(
              onPressed: close,
              variant: NebaVariant.text,
              color: NebaColor.secondary,
              child: const Text('Decline'),
            );
          },
        ),
        NebaDialogClose(
          builder: (BuildContext context, VoidCallback close) {
            return NebaButton(onPressed: close, child: const Text('Accept'));
          },
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          for (int index = 1; index <= 12; index++)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: <Widget>[
                Text('$index. Clause $index', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  'The header and the actions stay put while this part scrolls, which is what '
                  'the hairlines are there to say.',
                  style: TextStyle(color: tokens.mutedFg),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
