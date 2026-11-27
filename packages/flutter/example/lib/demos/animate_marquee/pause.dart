import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _posts = <String>[
  'Why a control never moves',
  'Acrylic, not moulded plastic',
  'One prop vocabulary',
  'Press is instant, release is slow',
];

class AnimateMarqueePause extends StatelessWidget {
  const AnimateMarqueePause({super.key});

  @override
  Widget build(BuildContext context) {
    // Links on a strip that never stopped would be links nobody could follow.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaAnimateMarquee(
        speed: 40,
        gap: 32,
        children: <Widget>[
          for (final String post in _posts)
            NebaTextLink(
              key: ValueKey<String>(post),
              href: Uri.parse('#pause'),
              onPressed: () {},
              child: Text(post),
            ),
        ],
      ),
    );
  }
}
