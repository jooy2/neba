import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BoxElevation extends StatelessWidget {
  const BoxElevation({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: <Widget>[
        for (int elevation = 0; elevation <= 3; elevation++)
          NebaBox(
            variant: NebaVariant.solid,
            elevation: elevation,
            child: Text('elevation $elevation'),
          ),
      ],
    );
  }
}
