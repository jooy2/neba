import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class CardDividers extends StatelessWidget {
  const CardDividers({super.key});

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
            child: const NebaCard(
              title: Text('Without'),
              subtitle: Text('separated by space'),
              footer: Text('Footer'),
              child: Text('Body'),
            ),
          ),
          NebaGrid(
            span: half,
            child: const NebaCard(
              dividers: true,
              title: Text('With'),
              subtitle: Text('separated by a hairline'),
              footer: Text('Footer'),
              child: Text('Body'),
            ),
          ),
        ],
      ),
    );
  }
}
