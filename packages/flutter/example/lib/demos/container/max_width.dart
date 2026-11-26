import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ContainerMaxWidth extends StatelessWidget {
  const ContainerMaxWidth({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final Map<String, NebaMeasure> widths = <String, NebaMeasure>{
      'xs': const NebaMeasure.size(NebaSize.xs),
      'sm': const NebaMeasure.size(NebaSize.sm),
      'md': const NebaMeasure.size(NebaSize.md),
      'none': NebaMeasure.none,
    };

    return Column(
      spacing: 12,
      children: <Widget>[
        for (final MapEntry<String, NebaMeasure> width in widths.entries)
          DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.roles(NebaColor.primary).softPress,
              borderRadius: BorderRadius.circular(tokens.radius[NebaSize.sm]!),
            ),
            child: NebaContainer(
              maxWidth: width.value,
              size: NebaSize.sm,
              child: NebaBox(
                size: NebaSize.sm,
                child: Center(child: Text('maxWidth ${width.key}')),
              ),
            ),
          ),
      ],
    );
  }
}
