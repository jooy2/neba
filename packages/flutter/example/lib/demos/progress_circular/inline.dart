import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// The ring lands just under the control height at every step, so it drops
/// into a row of controls without making the row taller than it was.
class ProgressCircularInline extends StatelessWidget {
  const ProgressCircularInline({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 3,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        const NebaTextField(
          size: NebaSize.sm,
          placeholder: 'Search',
          endIcon: NebaProgressCircular(size: NebaSize.xs),
        ),
        const NebaChip(
          size: NebaSize.sm,
          variant: NebaVariant.text,
          color: NebaColor.info,
          startIcon: NebaProgressCircular(size: NebaSize.xs, color: NebaColor.info),
          child: Text('Building'),
        ),
        NebaButton(
          size: NebaSize.sm,
          variant: NebaVariant.outline,
          startIcon: const NebaProgressCircular(size: NebaSize.xs),
          onPressed: () {},
          child: const Text('Syncing'),
        ),
      ],
    );
  }
}
