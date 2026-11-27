import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TabsHero extends StatelessWidget {
  const TabsHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 576),
      child: const NebaTabs<String>(
        defaultValue: 'overview',
        children: <Widget>[
          NebaTab<String>(value: 'overview', child: Text('Overview')),
          NebaTab<String>(value: 'usage', child: Text('Usage')),
          NebaTab<String>(value: 'billing', child: Text('Billing')),
          NebaTab<String>(value: 'archived', disabled: true, child: Text('Archived')),
          NebaTabPanel<String>(
            value: 'overview',
            child: Text('Three deploys today, all green. The last one finished four minutes ago.'),
          ),
          NebaTabPanel<String>(
            value: 'usage',
            child: Text('1,284 build minutes of the 4,000 on this plan.'),
          ),
          NebaTabPanel<String>(
            value: 'billing',
            child: Text('Next invoice on the first, for \$84.'),
          ),
        ],
      ),
    );
  }
}
