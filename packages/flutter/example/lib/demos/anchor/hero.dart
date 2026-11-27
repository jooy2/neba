import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<(String, int)> _sections = <(String, int)>[
  ('Install', 0),
  ('Setup', 0),
  ('With Tailwind', 1),
  ('Standalone', 1),
  ('First component', 0),
  ('Dark mode', 0),
];

class AnchorHero extends StatefulWidget {
  const AnchorHero({super.key});

  @override
  State<AnchorHero> createState() => _AnchorHeroState();
}

class _AnchorHeroState extends State<AnchorHero> {
  /// One key per heading: what a row scrolls to and what the list measures.
  final List<GlobalKey> _headings = <GlobalKey>[for (final _ in _sections) GlobalKey()];

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: <Widget>[
          Expanded(
            child: NebaBox(
              variant: NebaVariant.outline,
              child: SizedBox(
                height: 256,
                child: SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                  child: NebaFlex(
                    direction: NebaOrientation.vertical,
                    spacing: 6,
                    children: <Widget>[
                      for (int i = 0; i < _sections.length; i++)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            NebaTypography(
                              _sections[i].$1,
                              key: _headings[i],
                              level: NebaTypographyLevel.h6,
                            ),
                            const NebaTypography(
                              'Two or three sentences of whatever this section is about, so '
                              'there is something to scroll past on the way to the next heading.',
                              color: NebaColor.secondary,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          NebaAnchor(
            size: NebaSize.sm,
            items: <NebaAnchorItem>[
              for (int i = 0; i < _sections.length; i++)
                NebaAnchorItem(
                  target: _headings[i],
                  label: Text(_sections[i].$1),
                  depth: _sections[i].$2,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
