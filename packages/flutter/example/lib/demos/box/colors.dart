import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BoxColors extends StatelessWidget {
  const BoxColors({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        for (final NebaColor color in NebaColor.values)
          SizedBox(
            width: 160,
            child: NebaBox(color: color, child: Text(color.name)),
          ),
      ],
    );
  }
}
