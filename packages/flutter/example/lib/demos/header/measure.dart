import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

void _signIn() {}

class HeaderMeasure extends StatelessWidget {
  const HeaderMeasure({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radius[NebaSize.md]!),
      child: NebaHeader(
        position: NebaPosition.static,
        maxWidth: const NebaMeasure.size(NebaSize.sm),
        brand: const <Widget>[
          NebaAppLogo(
            name: 'Neba',
            image: AssetImage('assets/128x128.png'),
            showName: true,
            size: NebaSize.sm,
          ),
        ],
        actions: <Widget>[
          NebaButton(
            onPressed: _signIn,
            size: NebaSize.sm,
            variant: NebaVariant.outline,
            child: const Text('Sign in'),
          ),
        ],
      ),
    );
  }
}
