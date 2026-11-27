import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateTypingLoop extends StatelessWidget {
  const AnimateTypingLoop({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaTypeStep h4 = NebaTypography.scale[NebaTypographyLevel.h4]!;
    final TextStyle heading = TextStyle(
      fontSize: h4.size,
      height: h4.leading,
      fontWeight: h4.weight,
      letterSpacing: h4.tracking * h4.size,
      color: tokens.fg,
    );

    return Text.rich(
      TextSpan(
        style: heading,
        children: <InlineSpan>[
          TextSpan(
            text: 'A component library for ',
            style: TextStyle(color: tokens.mutedFg),
          ),
          // Inline on the sentence's baseline. A widget in a paragraph is
          // scaled with the text around it, so it does not scale its own.
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: MediaQuery.withNoTextScaling(
              child: NebaAnimateTyping(
                text: 'dashboards',
                repeat: double.infinity,
                erase: true,
                hold: const Duration(milliseconds: 1200),
                speed: 14,
                style: heading.copyWith(color: tokens.roles(NebaColor.primary).accent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
