import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TabsVariants extends StatelessWidget {
  const TabsVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 6,
      children: <Widget>[
        for (final NebaVariant variant in NebaVariant.values)
          NebaTabs<String>(
            variant: variant,
            defaultValue: 'a',
            size: NebaSize.sm,
            children: <Widget>[
              const NebaTab<String>(value: 'a', child: Text('Overview')),
              const NebaTab<String>(value: 'b', child: Text('Usage')),
              const NebaTab<String>(value: 'c', child: Text('Billing')),
              NebaTabPanel<String>(value: 'a', child: Text('variant: ${variant.name}')),
              const NebaTabPanel<String>(
                value: 'b',
                child: Text('The indicator moves by animating its box, never by transforming it.'),
              ),
              const NebaTabPanel<String>(value: 'c', child: Text('Nothing with text in it moves.')),
            ],
          ),
      ],
    );
  }
}
