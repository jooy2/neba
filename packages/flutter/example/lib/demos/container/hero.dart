import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ContainerHero extends StatelessWidget {
  const ContainerHero({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.roles(NebaColor.primary).softPress,
        borderRadius: BorderRadius.circular(tokens.radius[NebaSize.md]!),
      ),
      child: const NebaContainer(
        child: NebaBox(
          child: Text(
            'The tinted band is the page. The gutter either side of me is the Container.',
          ),
        ),
      ),
    );
  }
}
