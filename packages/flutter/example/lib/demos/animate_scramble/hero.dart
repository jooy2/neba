import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateScrambleHero extends StatelessWidget {
  const AnimateScrambleHero({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaAnimateScramble(
      text: 'RESOLVING SIGNAL',
      style: TextStyle(
        fontFamily: NebaScale.monoFonts.first,
        fontFamilyFallback: NebaScale.monoFonts.sublist(1),
        fontSize: 20,
        letterSpacing: 2,
        color: NebaTheme.of(context).fg,
      ),
    );
  }
}
