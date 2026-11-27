import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class HeaderVariant extends StatelessWidget {
  const HeaderVariant({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      children: <Widget>[
        for (final NebaVariant variant in NebaVariant.values)
          ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radius[NebaSize.md]!),
            child: NebaHeader(
              variant: variant,
              position: NebaPosition.static,
              brand: const <Widget>[
                NebaAppLogo(
                  name: 'Neba',
                  image: AssetImage('assets/128x128.png'),
                  showName: true,
                  size: NebaSize.sm,
                ),
              ],
              actions: <Widget>[
                Text(variant.name, style: TextStyle(fontSize: 12, color: tokens.mutedFg)),
              ],
            ),
          ),
      ],
    );
  }
}
