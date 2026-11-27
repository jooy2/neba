import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateShakeHero extends StatefulWidget {
  const AnimateShakeHero({super.key});

  @override
  State<AnimateShakeHero> createState() => _AnimateShakeHeroState();
}

class _AnimateShakeHeroState extends State<AnimateShakeHero> {
  final TextEditingController _value = TextEditingController();
  int _wrong = 0;

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  void _unlock() {
    if (_value.text != 'neba') {
      setState(() => _wrong += 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaFlex(
        spacing: 2,
        alignItems: NebaAlignItems.end,
        children: <Widget>[
          // The count of wrong answers, so every rejection replays the shake
          // without rebuilding the field, and the focus stays in it.
          Expanded(
            child: NebaAnimateShake(
              play: _wrong,
              child: NebaTextField(
                controller: _value,
                label: const Text('Passphrase'),
                error: _wrong > 0 ? const Text('That is not it. Try “neba”.') : null,
                fullWidth: true,
                onSubmitted: (String value) => _unlock(),
              ),
            ),
          ),
          NebaButton(onPressed: _unlock, child: const Text('Unlock')),
        ],
      ),
    );
  }
}
