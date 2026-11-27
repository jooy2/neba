import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class HoverCardHero extends StatelessWidget {
  const HoverCardHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: NebaTypography.rich(
        TextSpan(
          children: <InlineSpan>[
            const TextSpan(text: 'Reviewed by '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: NebaHoverCard(
                trigger: NebaTextLink(
                  onPressed: () {},
                  href: Uri.parse('#nadiarowan'),
                  child: const Text('@nadiarowan'),
                ),
                title: const Text('Nadia Rowan'),
                description: const Text('Seoul · joined 2019'),
                child: const Row(
                  spacing: 12,
                  children: <Widget>[
                    NebaAvatar(
                      image: AssetImage('assets/samples/people/nadia-rowan.jpg'),
                      name: 'Nadia Rowan',
                      size: NebaSize.lg,
                    ),
                    Flexible(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: <Widget>[
                          NebaChip(size: NebaSize.xs, child: Text('Maintainer')),
                          NebaChip(
                            size: NebaSize.xs,
                            color: NebaColor.info,
                            child: Text('214 commits'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const TextSpan(text: ' on 12 March.'),
          ],
        ),
        align: TextAlign.center,
      ),
    );
  }
}
