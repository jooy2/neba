import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class CardHero extends StatelessWidget {
  const CardHero({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan half = NebaGridSpan.columns(wide ? 6 : 12);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: NebaGridContainer(
        spacing: 4,
        padded: false,
        alignItems: NebaAlignItems.start,
        children: <Widget>[
          NebaGrid(
            span: half,
            child: NebaCard(
              title: const Text('Starter'),
              subtitle: const Text('For a single project'),
              footer: Row(
                children: <Widget>[
                  NebaButton(
                    onPressed: () {},
                    size: NebaSize.sm,
                    variant: NebaVariant.text,
                    color: NebaColor.secondary,
                    child: const Text('Compare'),
                  ),
                  const Spacer(),
                  NebaButton(onPressed: () {}, size: NebaSize.sm, child: const Text('Choose')),
                ],
              ),
              child: const Text('Everything you need to put one site in front of real users.'),
            ),
          ),
          NebaGrid(
            span: half,
            child: NebaCard(
              variant: NebaVariant.solid,
              color: NebaColor.secondary,
              title: const Text('Team'),
              subtitle: const Text('Up to twelve seats'),
              headerAction: const NebaChip(
                size: NebaSize.sm,
                variant: NebaVariant.outline,
                color: NebaColor.secondary,
                child: Text('Popular'),
              ),
              footer: NebaButton(
                onPressed: () {},
                size: NebaSize.sm,
                fullWidth: true,
                child: const Text('Choose'),
              ),
              child: const Text('Shared environments, review apps and a seat for everyone.'),
            ),
          ),
        ],
      ),
    );
  }
}
