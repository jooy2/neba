import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ToggleVariants extends StatelessWidget {
  const ToggleVariants({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      children: <Widget>[
        for (final NebaVariant variant in NebaVariant.values)
          NebaFlex(
            wrap: true,
            spacing: 3,
            alignItems: NebaAlignItems.center,
            children: <Widget>[
              SizedBox(
                width: 64,
                child: Text(variant.name, style: TextStyle(fontSize: 12, color: tokens.mutedFg)),
              ),
              NebaToggle(variant: variant, child: const Text('Off')),
              NebaToggle(variant: variant, defaultPressed: true, child: const Text('On')),
              NebaToggle(variant: variant, disabled: true, child: const Text('Disabled')),
            ],
          ),
      ],
    );
  }
}
