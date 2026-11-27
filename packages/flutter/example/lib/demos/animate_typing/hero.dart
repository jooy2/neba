import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateTypingHero extends StatelessWidget {
  const AnimateTypingHero({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return NebaAnimateTyping(
      text: 'Ship the interface, not the design system.',
      speed: 18,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: tokens.fg),
    );
  }
}
