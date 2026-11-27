import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TabsOrientation extends StatelessWidget {
  const TabsOrientation({super.key});

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
          child: const NebaTabs<String>(
            orientation: NebaOrientation.vertical,
            defaultValue: 'general',
            size: NebaSize.sm,
            children: <Widget>[
              NebaTab<String>(value: 'general', child: Text('General')),
              NebaTab<String>(value: 'members', child: Text('Members')),
              NebaTab<String>(value: 'tokens', child: Text('Tokens')),
              NebaTab<String>(value: 'webhooks', child: Text('Webhooks')),
              NebaTabPanel<String>(
                value: 'general',
                child: Text('The project name, its slug and its default branch.'),
              ),
              NebaTabPanel<String>(
                value: 'members',
                child: Text('Nine people, three of them admins.'),
              ),
              NebaTabPanel<String>(
                value: 'tokens',
                child: Text('Two tokens, one expiring in eleven days.'),
              ),
              NebaTabPanel<String>(value: 'webhooks', child: Text('No webhooks yet.')),
            ],
          ),
        ),
        NebaGrid(
          span: half,
          child: const NebaCard(
            size: NebaSize.sm,
            title: Text('Inside a card'),
            subtitle: Text('variant: NebaVariant.text and fullWidth'),
            child: NebaTabs<String>(
              variant: NebaVariant.text,
              fullWidth: true,
              defaultValue: 'a',
              size: NebaSize.sm,
              children: <Widget>[
                NebaTab<String>(value: 'a', child: Text('Daily')),
                NebaTab<String>(value: 'b', child: Text('Weekly')),
                NebaTab<String>(value: 'c', child: Text('Monthly')),
                NebaTabPanel<String>(
                  value: 'a',
                  child: Text('A card already has an edge, so the bar gives up its own.'),
                ),
                NebaTabPanel<String>(value: 'b', child: Text('The tabs share the width equally.')),
                NebaTabPanel<String>(
                  value: 'c',
                  child: Text('Nothing here draws a second rectangle.'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
