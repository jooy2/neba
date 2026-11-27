import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AppLogoVariant extends StatelessWidget {
  const AppLogoVariant({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 32,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        NebaAppLogo(name: 'Acme Corp', shape: NebaAppLogoShape.app, size: NebaSize.lg),
        NebaAppLogo(
          name: 'Acme Corp',
          shape: NebaAppLogoShape.app,
          size: NebaSize.lg,
          variant: NebaVariant.outline,
          color: NebaColor.info,
        ),
        NebaAppLogo(
          name: 'Acme Corp',
          shape: NebaAppLogoShape.app,
          size: NebaSize.lg,
          variant: NebaVariant.text,
          color: NebaColor.success,
        ),
      ],
    );
  }
}
