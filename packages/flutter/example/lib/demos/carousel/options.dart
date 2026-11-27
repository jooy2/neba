import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaColor> _colors = <NebaColor>[
  NebaColor.primary,
  NebaColor.success,
  NebaColor.warning,
  NebaColor.danger,
];

/// The chrome is optional and the ends are a choice. Without `loop` the
/// arrows go inert at the ends rather than wrapping, which is the honest
/// thing for a set that has a first and a last.
class CarouselOptions extends StatelessWidget {
  const CarouselOptions({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    List<Widget> panels() => <Widget>[
      for (int i = 0; i < 4; i++)
        ColoredBox(
          color: tokens.roles(_colors[i % _colors.length]).softPress,
          child: SizedBox(
            height: 128,
            child: Center(child: NebaTypography('${i + 1}', level: NebaTypographyLevel.h4)),
          ),
        ),
    ];

    Widget labelled(String label, Widget carousel) {
      return NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 2,
        alignItems: NebaAlignItems.stretch,
        children: <Widget>[
          NebaTypography(label, level: NebaTypographyLevel.caption),
          carousel,
        ],
      );
    }

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 6,
      alignItems: NebaAlignItems.stretch,
      children: <Widget>[
        labelled(
          'loop: false',
          NebaCarousel(
            semanticLabel: 'Not looping',
            loop: false,
            variant: NebaVariant.text,
            children: panels(),
          ),
        ),
        labelled(
          'arrows: false. Dots and dragging only',
          NebaCarousel(
            semanticLabel: 'Dots only',
            arrows: false,
            variant: NebaVariant.text,
            children: panels(),
          ),
        ),
        labelled(
          'autoPlay. A button to stop it, and it pauses on hover, on focus and in the background',
          NebaCarousel(
            semanticLabel: 'Auto playing',
            autoPlay: true,
            interval: const Duration(milliseconds: 2500),
            variant: NebaVariant.text,
            children: panels(),
          ),
        ),
      ],
    );
  }
}
