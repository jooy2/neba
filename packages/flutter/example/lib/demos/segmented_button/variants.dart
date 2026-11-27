import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class SegmentedButtonVariants extends StatelessWidget {
  const SegmentedButtonVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 5,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        for (final NebaVariant variant in NebaVariant.values)
          NebaSegmentedButton<String>(
            semanticLabel: variant.name,
            variant: variant,
            defaultValue: 'week',
            children: const <NebaSegment<String>>[
              NebaSegment<String>(value: 'day', child: Text('Day')),
              NebaSegment<String>(value: 'week', child: Text('Week')),
              NebaSegment<String>(value: 'month', child: Text('Month')),
            ],
          ),
      ],
    );
  }
}
