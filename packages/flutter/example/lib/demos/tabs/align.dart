import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TabsAlign extends StatelessWidget {
  const TabsAlign({super.key});

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
          child: const NebaCard(
            size: NebaSize.sm,
            title: Text('A column of settings'),
            subtitle: Text('align: NebaAlign.start'),
            child: NebaTabs<String>(
              orientation: NebaOrientation.vertical,
              align: NebaAlign.start,
              defaultValue: 'general',
              size: NebaSize.sm,
              children: <Widget>[
                NebaTab<String>(value: 'general', child: Text('General')),
                NebaTab<String>(value: 'members', child: Text('Members and roles')),
                NebaTab<String>(value: 'tokens', child: Text('Tokens')),
                NebaTab<String>(value: 'webhooks', child: Text('Webhooks')),
                NebaTabPanel<String>(
                  value: 'general',
                  child: Text('Every label starts on the same edge.'),
                ),
                NebaTabPanel<String>(
                  value: 'members',
                  child: Text('The tabs are still as wide as the longest one.'),
                ),
                NebaTabPanel<String>(value: 'tokens', child: Text('Only the label moved.')),
                NebaTabPanel<String>(
                  value: 'webhooks',
                  child: Text('The indicator is where it always was.'),
                ),
              ],
            ),
          ),
        ),
        NebaGrid(
          span: half,
          child: const NebaCard(
            size: NebaSize.sm,
            title: Text('A bar of equal shares'),
            subtitle: Text('fullWidth with align: NebaAlign.start'),
            child: NebaTabs<String>(
              variant: NebaVariant.text,
              fullWidth: true,
              align: NebaAlign.start,
              defaultValue: 'a',
              size: NebaSize.sm,
              children: <Widget>[
                NebaTab<String>(value: 'a', child: Text('Daily')),
                NebaTab<String>(value: 'b', child: Text('Weekly')),
                NebaTab<String>(value: 'c', child: Text('Monthly')),
                NebaTabPanel<String>(
                  value: 'a',
                  child: Text('Each tab takes an equal share of the bar.'),
                ),
                NebaTabPanel<String>(
                  value: 'b',
                  child: Text('The labels sit at the start of their own share.'),
                ),
                NebaTabPanel<String>(
                  value: 'c',
                  child: Text('Without fullWidth there would be nothing to align.'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
