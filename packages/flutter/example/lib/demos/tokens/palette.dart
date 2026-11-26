import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// Every colour family as a widget draws it: the fill, the tinted panel with
/// its hairline, and the soft wash, over the neutral sheets.
///
/// Not a component's demo: it is how the tokens are eyeballed against the
/// React package's colour page before any widget uses them.
class TokensPalette extends StatelessWidget {
  const TokensPalette({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final double radius = tokens.radius[NebaSize.md]!;

    Widget swatch(Color fill, {Color? edge, Color? ink, String label = ''}) {
      return Container(
        width: 88,
        height: NebaScale.controlHeight[NebaSize.md],
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(radius),
          border: edge == null ? null : Border.all(color: edge),
        ),
        child: Text(
          label,
          style: TextStyle(color: ink ?? tokens.fg, fontSize: NebaScale.controlText[NebaSize.md]),
        ),
      );
    }

    final List<Widget> rows = <Widget>[
      for (final NebaColor color in NebaColor.values)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              SizedBox(width: 72, child: Text(color.name)),
              swatch(tokens.roles(color).fill, ink: tokens.roles(color).onSolid, label: 'fill'),
              swatch(
                tokens.roles(color).panel,
                edge: tokens.roles(color).line,
                ink: tokens.roles(color).onTint,
                label: 'panel',
              ),
              swatch(tokens.roles(color).soft, ink: tokens.roles(color).onTint, label: 'soft'),
            ],
          ),
        ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          const SizedBox(width: 72, child: Text('neutral')),
          swatch(tokens.panel, edge: tokens.border, label: 'panel'),
          swatch(tokens.groove, label: 'groove'),
          swatch(tokens.disabledBg, ink: tokens.disabledFg, label: 'disabled'),
        ],
      ),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}
