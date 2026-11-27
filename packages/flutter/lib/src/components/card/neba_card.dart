/// `NebaCard`, a sheet with the parts a card is made of laid out on it.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A [NebaBox] with a title, a subtitle, a body and a footer laid out on it.
///
/// A slot that is left out is not built, so a card with only a title has no
/// empty header above it. Every axis of the box it is passes straight
/// through: [variant], [size], [color], [density], [elevation] and
/// [transition] mean what they mean on [NebaBox]. A card takes the width it
/// is given, so one in a row needs a width of its own, as a paragraph does.
///
/// ```dart
/// const NebaCard(title: Text('Starter'), child: Text('One project.'))
/// ```
class NebaCard extends StatelessWidget {
  /// A card with [child] as its body.
  const NebaCard({
    this.title,
    this.subtitle,
    this.headerAction,
    this.footer,
    this.dividers = false,
    this.variant,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.elevation = 0,
    this.transition,
    this.child,
    super.key,
  }) : assert(elevation >= nebaElevationMin && elevation <= nebaElevationMax);

  /// The heading, usually a [Text], set one step above the body in semibold.
  /// Wrap it in a `Semantics(header: true, …)` when the card belongs in the
  /// screen's outline; it keeps the title's type either way.
  final Widget? title;

  /// A second line under the title, one step down the type scale and muted.
  final Widget? subtitle;

  /// Pinned to the end of the header row: a menu button, a status chip. It
  /// stays on the title's first line while the title wraps beside it.
  final Widget? headerAction;

  /// The bottom area, in the body's type. A row of buttons is a `Row` or a
  /// `NebaFlex` of its own, where a `Spacer` pushes one to the end.
  final Widget? footer;

  /// Draws a hairline in [color]'s family between the sections instead of
  /// separating them with space. The lines run the full width of the sheet.
  final bool dividers;

  /// The sheet's weight. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The type of every section, the sheet's corners and its padding.
  /// Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the edge and of the dividers. The sheet itself stays
  /// undyed.
  final NebaColor color;

  /// How much padding each section has at its [size]. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`.
  final NebaElevation elevation;

  /// How the card arrives when it is first built: `const
  /// NebaTransition.fade()`, or any of the others.
  final NebaTransition? transition;

  /// The body.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = this.density ?? defaults.density ?? NebaDensity.standard;
    final double inset = NebaBox.padding[density]![size]!;
    final TextStyle body = TextStyle(
      fontSize: NebaScale.sheetBodyText[size],
      height: NebaScale.sheetBodyLeading[size]! / NebaScale.sheetBodyText[size]!,
    );

    final List<Widget> sections = <Widget>[
      if (title != null || subtitle != null || headerAction != null) _header(tokens, size),
      if (child != null) DefaultTextStyle.merge(style: body, child: child!),
      if (footer != null) DefaultTextStyle.merge(style: body, child: footer!),
    ];

    // With dividers the lines reach both edges, so each section takes the
    // padding on itself; without them the sheet keeps its vertical padding
    // and a gap tells the sections apart.
    final EdgeInsets sectionPadding = dividers
        ? EdgeInsets.all(inset)
        : EdgeInsets.symmetric(horizontal: inset);
    final BorderSide line = BorderSide(color: tokens.roles(color).line);
    final List<Widget> laid = <Widget>[
      for (int i = 0; i < sections.length; i++)
        // A Container, because it adds the line's width to the padding as a
        // CSS border does, where a DecoratedBox would draw it over the text.
        Container(
          decoration: BoxDecoration(border: dividers && i > 0 ? Border(top: line) : null),
          padding: sectionPadding,
          child: sections[i],
        ),
    ];

    return NebaBox(
      variant: variant,
      size: size,
      color: color,
      density: density,
      elevation: elevation,
      transition: transition,
      padded: false,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: dividers ? 0 : inset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: dividers ? 0 : NebaScale.sheetSectionGap[size]!,
          children: laid,
        ),
      ),
    );
  }

  Widget _header(NebaTokens tokens, NebaSize size) {
    final Widget? title = this.title;
    final Widget? subtitle = this.subtitle;
    final Widget? headerAction = this.headerAction;
    final double titleSize = NebaScale.sheetTitleText[size]!;
    final double metaSize = NebaScale.metaText[size]!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: <Widget>[
        if (title != null || subtitle != null)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: NebaScale.sheetHeaderGap[size]!,
              children: <Widget>[
                if (title != null)
                  DefaultTextStyle.merge(
                    style: TextStyle(
                      fontSize: titleSize,
                      height: NebaScale.sheetTitleLeading[size]! / titleSize,
                      fontWeight: FontWeight.w600,
                    ),
                    child: title,
                  ),
                if (subtitle != null)
                  DefaultTextStyle.merge(
                    style: TextStyle(fontSize: metaSize, color: tokens.mutedFg),
                    child: subtitle,
                  ),
              ],
            ),
          )
        else
          const Spacer(),
        ?headerAction,
      ],
    );
  }
}
