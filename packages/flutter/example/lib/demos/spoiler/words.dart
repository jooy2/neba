import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class SpoilerWords extends StatefulWidget {
  const SpoilerWords({super.key});

  @override
  State<SpoilerWords> createState() => _SpoilerWordsState();
}

class _SpoilerWordsState extends State<SpoilerWords> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 4,
        children: <Widget>[
          const NebaSpoiler(
            label: Text('Show the ending'),
            description: Text('Season 2, episode 6'),
            color: NebaColor.warning,
            child: NebaTypography('Words of its own, on both lines.'),
          ),
          const NebaSpoiler(
            showDescription: false,
            blur: 16,
            child: NebaTypography('A cover with nothing written on it, blurred harder.'),
          ),
          // A control of your own means driving the state yourself.
          NebaSpoiler(
            revealed: _revealed,
            onRevealedChange: (bool next) => setState(() => _revealed = next),
            description: const Text('Contains the last five minutes'),
            action: NebaButton(
              onPressed: () => setState(() => _revealed = true),
              variant: NebaVariant.outline,
              color: NebaColor.danger,
              child: const Text('I can take it'),
            ),
            child: const NebaTypography('A button of your own, wired up through revealed.'),
          ),
        ],
      ),
    );
  }
}
