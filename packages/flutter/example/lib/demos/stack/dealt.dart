import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _team = <String>[
  'Anya Sol',
  'Theo Quinn',
  'Lucas Adebayo',
  'Nadia Rowan',
  'Noa Marin',
];
const List<String> _cards = <String>['Alpha', 'Beta', 'Gamma', 'Delta'];

class StackDealt extends StatefulWidget {
  const StackDealt({super.key});

  @override
  State<StackDealt> createState() => _StackDealtState();
}

class _StackDealtState extends State<StackDealt> {
  int _run = 0;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      children: <Widget>[
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: NebaButton(
            onPressed: () => setState(() => _run += 1),
            variant: NebaVariant.outline,
            size: NebaSize.sm,
            child: const Text('Deal again'),
          ),
        ),
        NebaFlex(
          key: ValueKey<int>(_run),
          wrap: true,
          spacing: 10,
          alignItems: NebaAlignItems.start,
          children: <Widget>[
            NebaFlex(
              direction: NebaOrientation.vertical,
              spacing: 2,
              children: <Widget>[
                const NebaTypography(
                  'fade · stagger: 90 ms',
                  level: NebaTypographyLevel.caption,
                  color: NebaColor.secondary,
                ),
                NebaStack(
                  ring: true,
                  transition: const NebaTransition.fade(),
                  stagger: const Duration(milliseconds: 90),
                  children: <Widget>[
                    for (final String name in _team)
                      NebaAvatar(
                        name: name,
                        image: AssetImage(
                          'assets/samples/people/${name.toLowerCase().replaceAll(' ', '-')}.jpg',
                        ),
                      ),
                  ],
                ),
              ],
            ),
            NebaFlex(
              direction: NebaOrientation.vertical,
              spacing: 2,
              children: <Widget>[
                const NebaTypography(
                  'zoom · stagger: 120 ms · reverse',
                  level: NebaTypographyLevel.caption,
                  color: NebaColor.secondary,
                ),
                NebaStack(
                  direction: NebaStackDirection.diagonal,
                  overlap: 56,
                  drop: 12,
                  scaleStep: 0.96,
                  transition: const NebaTransition.zoom(),
                  stagger: const Duration(milliseconds: 120),
                  reverse: true,
                  children: <Widget>[
                    for (final String name in _cards)
                      SizedBox(
                        width: 128,
                        child: NebaCard(size: NebaSize.sm, elevation: 1, title: Text(name)),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
