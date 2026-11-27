import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateSplitBy extends StatefulWidget {
  const AnimateSplitBy({super.key});

  @override
  State<AnimateSplitBy> createState() => _AnimateSplitByState();
}

class _AnimateSplitByState extends State<AnimateSplitBy> {
  int _run = 0;

  @override
  Widget build(BuildContext context) {
    final TextStyle line = TextStyle(fontSize: 18, color: NebaTheme.of(context).fg);

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
            child: const Text('Play again'),
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
                  'by: NebaSplitBy.word — the default',
                  level: NebaTypographyLevel.caption,
                  color: NebaColor.secondary,
                ),
                NebaAnimateSplit(text: 'Eight words is eight boxes on the page.', style: line),
              ],
            ),
            NebaFlex(
              direction: NebaOrientation.vertical,
              spacing: 1,
              alignItems: NebaAlignItems.stretch,
              children: <Widget>[
                const NebaTypography(
                  'by: NebaSplitBy.character · effect: NebaAnimation.grow',
                  level: NebaTypographyLevel.caption,
                  color: NebaColor.secondary,
                ),
                NebaAnimateSplit(
                  text: 'Letter by letter',
                  by: NebaSplitBy.character,
                  effect: NebaAnimation.grow,
                  stagger: const Duration(milliseconds: 28),
                  style: line,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
