import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ScrollAreaHero extends StatelessWidget {
  const ScrollAreaHero({super.key});

  static const List<(String, String)> changes = <(String, String)>[
    ('1.8.1', 'Every component marked with a client directive.'),
    ('1.8.0', 'Package dependencies upgraded.'),
    ('1.7.0', 'Every component got its own entry point.'),
    ('1.6.2', 'The pure annotations terser was throwing away.'),
    ('1.6.1', 'A header holds its three slots apart.'),
    ('1.6.0', 'PageLayout, Header, Footer and Sidebar.'),
    ('1.5.0', 'CodeBlock and HowToSteps.'),
    ('1.4.1', 'A floating bottom navigation stops moving on press.'),
    ('1.4.0', 'The eleven Animate wrappers.'),
    ('1.3.0', 'Mockup, Empty and DataTable.'),
  ];

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: SizedBox(
        width: double.infinity,
        child: NebaBox(
          child: NebaScrollArea(
            height: 200,
            fade: true,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: NebaFlex(
                direction: NebaOrientation.vertical,
                spacing: 3,
                children: <Widget>[
                  for (final (String version, String note) in changes)
                    NebaFlex(
                      direction: NebaOrientation.vertical,
                      spacing: 0.5,
                      children: <Widget>[
                        NebaTypography(
                          version,
                          level: NebaTypographyLevel.caption,
                          style: const TextStyle(
                            fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                          ),
                        ),
                        NebaTypography(note),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
