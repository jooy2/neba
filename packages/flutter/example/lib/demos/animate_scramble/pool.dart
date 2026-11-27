import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateScramblePool extends StatefulWidget {
  const AnimateScramblePool({super.key});

  @override
  State<AnimateScramblePool> createState() => _AnimateScramblePoolState();
}

class _AnimateScramblePoolState extends State<AnimateScramblePool> {
  int _run = 0;

  @override
  Widget build(BuildContext context) {
    final TextStyle line = TextStyle(
      fontFamily: NebaScale.monoFonts.first,
      fontFamilyFallback: NebaScale.monoFonts.sublist(1),
      fontSize: 18,
      color: NebaTheme.of(context).fg,
    );

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      alignItems: NebaAlignItems.stretch,
      children: <Widget>[
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: NebaButton(
            onPressed: () => setState(() => _run += 1),
            variant: NebaVariant.outline,
            size: NebaSize.sm,
            child: const Text('Run again'),
          ),
        ),
        NebaFlex(
          key: ValueKey<int>(_run),
          direction: NebaOrientation.vertical,
          spacing: 5,
          alignItems: NebaAlignItems.stretch,
          children: <Widget>[
            NebaFlex(
              direction: NebaOrientation.vertical,
              spacing: 1,
              alignItems: NebaAlignItems.stretch,
              children: <Widget>[
                const NebaTypography(
                  'speed: 10 — slower',
                  level: NebaTypographyLevel.caption,
                  color: NebaColor.secondary,
                ),
                NebaAnimateScramble(text: 'DECODING', speed: 10, style: line),
              ],
            ),
            NebaFlex(
              direction: NebaOrientation.vertical,
              spacing: 1,
              alignItems: NebaAlignItems.stretch,
              children: <Widget>[
                const NebaTypography(
                  "characters: '01'",
                  level: NebaTypographyLevel.caption,
                  color: NebaColor.secondary,
                ),
                NebaAnimateScramble(text: '0100 1110 0100 0101', characters: '01', style: line),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
