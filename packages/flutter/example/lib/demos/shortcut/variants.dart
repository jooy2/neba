import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ShortcutVariants extends StatelessWidget {
  const ShortcutVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 6,
      children: <Widget>[
        const Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            NebaShortcut(keys: 'Mod+K', variant: NebaVariant.solid),
            NebaShortcut(keys: 'Mod+K', variant: NebaVariant.outline),
            NebaShortcut(keys: 'Mod+K', variant: NebaVariant.text),
            NebaShortcut(keys: 'Mod+K', variant: NebaVariant.outline, color: NebaColor.primary),
            NebaShortcut(keys: 'Mod+K', variant: NebaVariant.solid, color: NebaColor.danger),
          ],
        ),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            for (final NebaSize size in NebaSize.values) NebaShortcut(keys: 'Mod+K', size: size),
          ],
        ),
      ],
    );
  }
}
