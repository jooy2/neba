import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AccordionVariants extends StatelessWidget {
  const AccordionVariants({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.lg.width;
    final NebaGridSpan third = NebaGridSpan.columns(wide ? 4 : 12);

    return NebaGridContainer(
      spacing: 4,
      padded: false,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        for (final NebaVariant variant in NebaVariant.values)
          NebaGrid(
            span: third,
            child: NebaAccordion<String>(
              variant: variant,
              size: NebaSize.sm,
              defaultValue: const <String>['a'],
              children: <Widget>[
                NebaAccordionItem<String>(
                  value: 'a',
                  title: Text(variant.name),
                  child: const Text(
                    "The sheet is never dyed — a container holds other people's content, and "
                    'that content arrives with its own colours.',
                  ),
                ),
                const NebaAccordionItem<String>(
                  value: 'b',
                  title: Text('Second'),
                  child: Text(
                    'Only one section is open at a time unless `multiple` says otherwise.',
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
