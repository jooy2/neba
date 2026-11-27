import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ChipSizes extends StatelessWidget {
  const ChipSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 2,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        for (final NebaSize size in NebaSize.values)
          NebaChip(size: size, count: const Text('9'), child: Text(size.name)),
      ],
    );
  }
}
