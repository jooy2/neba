import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BoxUnpadded extends StatelessWidget {
  const BoxUnpadded({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: NebaBox(
        padded: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ColoredBox(
              color: tokens.roles(NebaColor.primary).softPress,
              child: const SizedBox(height: 80),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('The strip above touches all four edges, because the box is not padded.'),
            ),
          ],
        ),
      ),
    );
  }
}
