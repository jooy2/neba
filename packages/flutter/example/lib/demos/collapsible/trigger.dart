import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class CollapsibleTrigger extends StatelessWidget {
  const CollapsibleTrigger({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: NebaCollapsible(
        variant: NebaVariant.text,
        padded: false,
        triggerBuilder: (BuildContext context, bool open, VoidCallback? onToggle) {
          return NebaButton(
            onPressed: onToggle,
            variant: NebaVariant.text,
            size: NebaSize.sm,
            child: const Text('Show the full changelog'),
          );
        },
        child: const Padding(
          padding: EdgeInsets.only(top: 12),
          child: NebaTypography(
            '1.4.0 added nine chart components and a shared data model behind them. 1.3.0 was '
            'the date pickers. Everything before that is in the changelog itself.',
          ),
        ),
      ),
    );
  }
}
