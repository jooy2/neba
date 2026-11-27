import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ReasoningVariant extends StatelessWidget {
  const ReasoningVariant({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          for (final NebaVariant variant in <NebaVariant>[
            NebaVariant.text,
            NebaVariant.outline,
            NebaVariant.solid,
          ])
            NebaReasoning(
              variant: variant,
              duration: const Duration(milliseconds: 2400),
              defaultOpen: true,
              child: Text(
                'Drawn as ${variant.name}. The rule down the inside edge is the panel, whichever '
                'weight the header is on.',
              ),
            ),
        ],
      ),
    );
  }
}
