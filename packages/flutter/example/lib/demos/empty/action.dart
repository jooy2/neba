import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class EmptyAction extends StatelessWidget {
  const EmptyAction({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan half = NebaGridSpan.columns(wide ? 6 : 12);

    return NebaGridContainer(
      spacing: 4,
      padded: false,
      children: <Widget>[
        NebaGrid(
          span: half,
          child: NebaEmpty(
            variant: NebaVariant.outline,
            title: const Text('No results'),
            actions: <Widget>[
              NebaButton(
                onPressed: () {},
                size: NebaSize.sm,
                variant: NebaVariant.outline,
                child: const Text('Clear filters'),
              ),
            ],
            child: const Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(text: 'Nothing matched '),
                  TextSpan(
                    text: 'ingress-nginx',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ),
        NebaGrid(
          span: half,
          child: NebaEmpty(
            variant: NebaVariant.outline,
            title: const Text('No team members'),
            actions: <Widget>[
              NebaButton(onPressed: () {}, size: NebaSize.sm, child: const Text('Invite someone')),
              NebaTextLink(onPressed: () {}, child: const Text('Read about roles')),
            ],
            child: const Text('You are the only one here so far.'),
          ),
        ),
      ],
    );
  }
}
