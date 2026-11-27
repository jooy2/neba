import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class CardSizes extends StatelessWidget {
  const CardSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 3,
        children: <Widget>[
          for (final NebaSize size in NebaSize.values)
            NebaCard(
              size: size,
              dividers: true,
              title: Text('size ${size.name}'),
              subtitle: const Text('Subtitle'),
              child: const Text('Body copy sits one step below the title.'),
            ),
        ],
      ),
    );
  }
}
