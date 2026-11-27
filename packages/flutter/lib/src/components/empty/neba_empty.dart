/// `NebaEmpty`, what stands where content would have been.
library;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/live_region.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/ring.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// The tray with nothing in it, the React package's own drawing: a container
/// with an opening and no contents, which sits over every reason a place can
/// be empty rather than naming one.
final List<NebaGlyphPart> _tray = <NebaGlyphPart>[
  const NebaGlyphPart.stroke(
    'M1.75 9.75h3l.9 1.6h4.7l.9-1.6h3',
    cap: StrokeCap.round,
    join: StrokeJoin.round,
  ),
  const NebaGlyphPart.stroke(
    'm1.75 9.75 2.1-6a1.5 1.5 0 0 1 1.42-1h5.46a1.5 1.5 0 0 1 1.42 1l2.1 6v2a1.5 1.5 0 0 1-1.5 '
    '1.5h-9.5a1.5 1.5 0 0 1-1.5-1.5Z',
    join: StrokeJoin.round,
  ),
];

/// What stands where content would have been: a glyph, a headline, a
/// sentence and a way out.
///
/// It is the other half of a skeleton. A skeleton is the shape of something
/// on its way; this is the shape of something that is not coming: a search
/// with no matches, an inbox nobody has written to, a folder before its first
/// file. The headline defaults to the [locale]'s way of saying there is
/// nothing here, so an empty state with no arguments still says something.
///
/// The sheet is never dyed, and `text`, no sheet at all, is the default: an
/// empty state is nearly always inside something that is already a sheet. It
/// takes the width it is given and centres what it holds, and it is a live
/// region, so a list that empties under a reader is heard to.
///
/// ```dart
/// NebaEmpty(
///   title: const Text('No projects yet'),
///   actions: <Widget>[NebaButton(onPressed: create, child: const Text('Create a project'))],
///   child: const Text('Everything you deploy shows up here.'),
/// )
/// ```
class NebaEmpty extends StatelessWidget {
  /// An empty state saying [child] under its headline.
  const NebaEmpty({
    this.child,
    this.title,
    this.showTitle = true,
    this.icon,
    this.showIcon = true,
    this.actions = const <Widget>[],
    this.locale,
    this.role,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.transition,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The sentence under the headline: why it is empty, or what to do next.
  /// Under a headline it takes the muted ink; on its own it is the state and
  /// keeps the reading ink.
  final Widget? child;

  /// The headline. Defaults to the [locale]'s way of saying that there is
  /// nothing here.
  final Widget? title;

  /// Whether there is a headline at all. `false` leaves the glyph and the
  /// sentence, the React package's `title={false}`.
  final bool showTitle;

  /// Replaces the empty tray above the headline: an icon from any set, an
  /// illustration, a brand mark. A glyph that reads the `IconTheme` is drawn
  /// on the size ladder; anything else keeps its own size.
  final Widget? icon;

  /// Whether there is a glyph at all. `false` drops it, the React package's
  /// `icon={false}`.
  final bool showIcon;

  /// What to do about it, under the text: a "Create the first one" button, a
  /// "Clear filters" link. More than one sit in a row 8 pixels apart and wrap
  /// together.
  final List<Widget> actions;

  /// The language of the default headline. Ignored once [title] is given.
  /// Defaults to `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// The live region the state is. Defaults to [SemanticsRole.status],
  /// which a screen reader reads out when it changes without interrupting;
  /// [SemanticsRole.none] makes it no live region, for a state that is simply
  /// part of the screen when it arrives.
  final SemanticsRole? role;

  /// The sheet's weight, which is never dyed. Defaults to `NebaProvider`'s,
  /// then [NebaVariant.text]: no sheet, because the state is nearly always
  /// inside one already.
  final NebaVariant? variant;

  /// The type, the glyph and how much room the state takes. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the hairline. Defaults to [NebaColor.secondary]: an empty
  /// state in the accent colour makes a claim about content that does not
  /// exist. Move it when the emptiness is the problem, as `danger` on a
  /// region that failed to load.
  final NebaColor? color;

  /// The padding, and nothing else. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`. Defaults to `0`: an empty state is a
  /// hole in a surface that already exists, not a sheet of its own.
  final NebaElevation? elevation;

  /// How the state arrives when it is first built: `const
  /// NebaTransition.fade()` for a list that has just come back with nothing.
  final NebaTransition? transition;

  /// The vertical padding at each size, per density: more than a box's, so
  /// the emptiness reads as deliberate rather than as a paragraph that failed
  /// to load.
  static const Map<NebaDensity, Map<NebaSize, double>> paddingY =
      <NebaDensity, Map<NebaSize, double>>{
        NebaDensity.standard: <NebaSize, double>{
          NebaSize.xs: 20,
          NebaSize.sm: 24,
          NebaSize.md: 32,
          NebaSize.lg: 40,
          NebaSize.xl: 48,
        },
        NebaDensity.compact: <NebaSize, double>{
          NebaSize.xs: 12,
          NebaSize.sm: 14,
          NebaSize.md: 16,
          NebaSize.lg: 20,
          NebaSize.xl: 24,
        },
      };

  /// The glyph's scale at each size, as the type size it is measured
  /// against: the glyph is drawn at 1.2 times it.
  static const Map<NebaSize, double> glyphScale = <NebaSize, double>{
    NebaSize.xs: 20,
    NebaSize.sm: 24,
    NebaSize.md: 28,
    NebaSize.lg: 34,
    NebaSize.xl: 40,
  };

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = this.variant ?? defaults.variant ?? NebaVariant.text;
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final NebaColor color = this.color ?? NebaColor.secondary;
    final NebaDensity density = this.density ?? defaults.density ?? NebaDensity.standard;
    final NebaElevation elevation = this.elevation ?? 0;
    final BorderRadius radius = BorderRadius.circular(tokens.radius[size]!);
    final double scale = glyphScale[size]!;
    final Widget? child = this.child;

    final Widget? heading = showTitle
        ? (title ?? Text(nebaMessages(context, 'empty', locale: locale)['title']!))
        : null;
    final Widget? glyph = showIcon ? (icon ?? NebaGlyph(_tray)) : null;

    final double titleSize = NebaScale.sheetTitleText[size]!;
    final double bodySize = NebaScale.sheetBodyText[size]!;
    final TextStyle ambient = DefaultTextStyle.of(context).style;

    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      spacing: NebaScale.sheetSectionGap[size]!,
      children: <Widget>[
        if (glyph != null)
          IconTheme.merge(
            data: IconThemeData(color: tokens.mutedFg, size: scale * 1.2),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: tokens.mutedFg, fontSize: scale),
              child: glyph,
            ),
          ),
        if (heading != null || child != null)
          // No wider than a comfortable line: a centred sentence running the
          // width of a page starts its second line where the eye has to hunt.
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _prose(ambient)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: NebaScale.sheetHeaderGap[size]!,
              children: <Widget>[
                if (heading != null)
                  DefaultTextStyle.merge(
                    style: TextStyle(
                      fontSize: titleSize,
                      height: NebaScale.sheetTitleLeading[size]! / titleSize,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    child: heading,
                  ),
                if (child != null)
                  DefaultTextStyle.merge(
                    style: TextStyle(
                      fontSize: bodySize,
                      height: NebaScale.sheetBodyLeading[size]! / bodySize,
                      color: heading != null ? tokens.mutedFg : null,
                    ),
                    textAlign: TextAlign.center,
                    child: child,
                  ),
              ],
            ),
          ),
        if (actions.isNotEmpty)
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: actions,
          ),
      ],
    );

    // All of a bounded width, with what it holds centred in it, and in a
    // height it is stretched to.
    final Widget laid = DefaultTextStyle.merge(
      style: TextStyle(color: tokens.fg),
      child: Align(
        heightFactor: 1,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: NebaBox.padding[density]![size]!,
            vertical: paddingY[density]![size]!,
          ),
          child: content,
        ),
      ),
    );

    final Widget sheet = switch (variant) {
      NebaVariant.solid => NebaSheet(
        fill: tokens.panelHover,
        elevation: elevation,
        borderRadius: radius,
        child: laid,
      ),
      NebaVariant.outline => NebaSheet(
        fill: tokens.panel,
        edge: tokens.roles(color).line,
        plate: NebaPlate.glass,
        elevation: elevation,
        borderRadius: radius,
        child: laid,
      ),
      NebaVariant.text => laid,
    };

    Widget empty = NebaLiveRegion(
      role: role ?? SemanticsRole.status,
      child: NebaRing(borderRadius: radius, child: sheet),
    );

    final NebaTransition? transition = this.transition;

    if (transition != null) {
      empty = NebaEntrance(transition: transition, child: empty);
    }

    return empty;
  }

  /// CSS `65ch` in [style]: sixty-five times the advance of its `0`.
  static double _prose(TextStyle style) {
    final TextPainter zero = TextPainter(
      text: TextSpan(text: '0', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final double width = zero.width * 65;

    zero.dispose();

    return width;
  }
}
