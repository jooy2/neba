import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BoxSizes extends StatelessWidget {
  const BoxSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: <Widget>[
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            for (final NebaSize size in NebaSize.values)
              NebaBox(size: size, child: Text('size ${size.name}')),
          ],
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            for (final NebaSize size in NebaSize.values)
              NebaBox(
                size: size,
                density: NebaDensity.compact,
                child: Text('compact ${size.name}'),
              ),
          ],
        ),
      ],
    );
  }
}
