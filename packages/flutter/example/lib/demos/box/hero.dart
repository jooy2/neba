import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BoxHero extends StatelessWidget {
  const BoxHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        Expanded(child: NebaBox(child: Text('The default — a hairline edge'))),
        Expanded(
          child: NebaBox(
            variant: NebaVariant.solid,
            color: NebaColor.info,
            child: Text('solid, info'),
          ),
        ),
        Expanded(
          child: NebaBox(variant: NebaVariant.text, child: Text('text — it only groups')),
        ),
      ],
    );
  }
}
