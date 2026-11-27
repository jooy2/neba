import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateTypingSpeed extends StatelessWidget {
  const AnimateTypingSpeed({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontFamily: NebaScale.monoFonts.first,
          fontFamilyFallback: NebaScale.monoFonts.sublist(1),
          fontSize: 14,
          color: tokens.fg,
        ),
        child: NebaFlex(
          direction: NebaOrientation.vertical,
          spacing: 2,
          alignItems: NebaAlignItems.stretch,
          children: <Widget>[
            for (final int speed in const <int>[8, 20, 60])
              NebaAnimateTyping(
                key: ValueKey<int>(speed),
                text: 'speed: $speed — the same line, three paces',
                speed: speed.toDouble(),
                // A block caret, drawn rather than typed.
                caretChar: SizedBox(width: 8, height: 15, child: ColoredBox(color: tokens.fg)),
              ),
          ],
        ),
      ),
    );
  }
}
