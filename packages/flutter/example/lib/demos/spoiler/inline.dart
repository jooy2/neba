import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class SpoilerInline extends StatelessWidget {
  const SpoilerInline({super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle code = TextStyle(
      fontFamily: NebaScale.monoFonts.first,
      fontFamilyFallback: NebaScale.monoFonts.sublist(1),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 4,
        children: <Widget>[
          NebaTypography.rich(
            TextSpan(
              children: <InlineSpan>[
                const TextSpan(text: 'A Spoiler with '),
                TextSpan(text: 'NebaVariant.text', style: code),
                const TextSpan(
                  text:
                      ' draws no box at all, which is what a paragraph in the middle of a '
                      'review usually wants:',
                ),
              ],
            ),
          ),
          const NebaSpoiler(
            variant: NebaVariant.text,
            size: NebaSize.sm,
            showDescription: false,
            padded: false,
            child: NebaTypography('The butler did it, and the dog knew all along.'),
          ),
          const NebaSpoiler(
            variant: NebaVariant.solid,
            size: NebaSize.lg,
            color: NebaColor.info,
            child: NebaTypography('And a filled sheet, for one that is meant to be a stop sign.'),
          ),
        ],
      ),
    );
  }
}
