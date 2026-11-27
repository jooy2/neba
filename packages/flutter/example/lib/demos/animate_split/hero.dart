import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateSplitHero extends StatelessWidget {
  const AnimateSplitHero({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return Semantics(
      header: true,
      child: NebaAnimateSplit(
        text: 'A line arriving a word at a time',
        stagger: const Duration(milliseconds: 70),
        distance: 14,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: tokens.fg),
      ),
    );
  }
}
