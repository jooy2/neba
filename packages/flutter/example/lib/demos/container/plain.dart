import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ContainerPlain extends StatelessWidget {
  const ContainerPlain({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    Widget band(Widget child) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.roles(NebaColor.primary).softPress,
          borderRadius: BorderRadius.circular(tokens.radius[NebaSize.sm]!),
        ),
        child: child,
      );
    }

    return Column(
      spacing: 12,
      children: <Widget>[
        // No gutter, but still centred and still measured.
        band(
          const NebaContainer(
            maxWidth: NebaMeasure.size(NebaSize.sm),
            padded: false,
            child: NebaBox(
              size: NebaSize.sm,
              child: Center(child: Text('padded: false')),
            ),
          ),
        ),
        // Measured, but held against the start edge instead of centred.
        band(
          const NebaContainer(
            maxWidth: NebaMeasure.size(NebaSize.sm),
            centered: false,
            size: NebaSize.sm,
            child: NebaBox(
              size: NebaSize.sm,
              child: Center(child: Text('centered: false')),
            ),
          ),
        ),
      ],
    );
  }
}
