import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// `multiple` is the whole difference between an accordion and a stack of
/// collapsibles: closing the last section as you open the next is what keeps
/// the page from growing under the reader.
///
/// `dividers` decides whether the sections are one ruled block or a stack of
/// tiles. A section cannot be both.
class AccordionBehaviour extends StatelessWidget {
  const AccordionBehaviour({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.lg.width;
    final NebaGridSpan half = NebaGridSpan.columns(wide ? 6 : 12);

    return NebaGridContainer(
      spacing: 5,
      padded: false,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaGrid(
          span: half,
          child: const NebaFlex(
            direction: NebaOrientation.vertical,
            spacing: 2,
            children: <Widget>[
              NebaTypography('multiple', level: NebaTypographyLevel.caption),
              NebaAccordion<String>(
                multiple: true,
                defaultValue: <String>['a', 'b'],
                size: NebaSize.sm,
                children: <Widget>[
                  NebaAccordionItem<String>(
                    value: 'a',
                    title: Text('Both open at once'),
                    child: Text('Nothing closed when this one opened.'),
                  ),
                  NebaAccordionItem<String>(
                    value: 'b',
                    title: Text('And so is this'),
                    child: Text(
                      'Reach for it when the sections are a checklist rather than a set of '
                      'answers.',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        NebaGrid(
          span: half,
          child: const NebaFlex(
            direction: NebaOrientation.vertical,
            spacing: 2,
            children: <Widget>[
              NebaTypography(
                'dividers: false · action · disabled',
                level: NebaTypographyLevel.caption,
              ),
              NebaAccordion<String>(
                dividers: false,
                size: NebaSize.sm,
                defaultValue: <String>['a'],
                children: <Widget>[
                  NebaAccordionItem<String>(
                    value: 'a',
                    title: Text('Notifications'),
                    subtitle: Text('Tiles rather than rules'),
                    action: NebaSwitch(
                      size: NebaSize.sm,
                      defaultChecked: true,
                      semanticLabel: 'Notifications',
                    ),
                    child: Text(
                      'The switch sits outside the folding button: a header that both folds and '
                      'holds a control has two things to press, and one of them cannot be nested '
                      'inside the other.',
                    ),
                  ),
                  NebaAccordionItem<String>(
                    value: 'b',
                    title: Text('Archived'),
                    disabled: true,
                    child: Text('This one never opens.'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
