import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ProgressBoxCounts extends StatelessWidget {
  const ProgressBoxCounts({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 5,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        for (final int count in <int>[3, 4, 6, 10]) NebaProgressBox(count: count),
      ],
    );
  }
}
