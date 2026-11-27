import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class SpoilerClamped extends StatelessWidget {
  const SpoilerClamped({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 4,
        children: <Widget>[
          NebaSpoiler(
            maxHeight: 120,
            child: NebaTypography(
              'The whole third act turns on the letter, which is why the first two acts keep '
              'putting it in shot without ever letting anybody read it. The camera passes it '
              'four times before the scene in the kitchen: on the hall table, in the coat, under '
              'the bowl of keys, and finally in her hand at the top of the stairs, where the '
              'film cuts away for the last time. When it is finally read out it takes ninety '
              'seconds, and everything anyone said in the first hour means something else.',
            ),
          ),
          NebaSpoiler(
            reversible: true,
            child: NebaTypography(
              'Reversible, so the cover can go back on — useful when the spoiler sits in a page '
              'somebody scrolls past more than once.',
            ),
          ),
        ],
      ),
    );
  }
}
