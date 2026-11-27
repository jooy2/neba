import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class SegmentedButtonSizes extends StatelessWidget {
  const SegmentedButtonSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        for (final NebaSize size in NebaSize.values)
          NebaSegmentedButton<String>(
            semanticLabel: size.name,
            size: size,
            defaultValue: 'on',
            children: const <NebaSegment<String>>[
              NebaSegment<String>(value: 'on', child: Text('On')),
              NebaSegment<String>(value: 'auto', child: Text('Auto')),
              NebaSegment<String>(value: 'off', child: Text('Off')),
            ],
          ),
      ],
    );
  }
}
