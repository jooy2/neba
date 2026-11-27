/// `NebaBlockquote`, a passage quoted from somewhere else.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/internal/ring.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A passage quoted from somewhere else, with who said it and where.
///
/// A rule in the colour's accent runs down its start edge whatever the
/// [variant]: `text`, the default, is the rule alone, `outline` adds a sheet
/// with a hairline and `solid` a brighter sheet. A quote mark opens it until
/// [icon] says otherwise, and [author] and [source] set an attribution under
/// it.
///
/// ```dart
/// const NebaBlockquote(
///   author: Text('Dieter Rams'),
///   child: Text('Less, but better.'),
/// )
/// ```
class NebaBlockquote extends StatelessWidget {
  /// A blockquote of [child].
  const NebaBlockquote({
    this.child,
    this.author,
    this.source,
    this.icon = const _QuoteMark(),
    this.variant,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.elevation = 0,
    this.transition,
    super.key,
  }) : assert(elevation >= nebaElevationMin && elevation <= nebaElevationMax);

  /// The quoted passage.
  final Widget? child;

  /// Who said it, set after an em dash a screen reader does not read out.
  final Widget? author;

  /// Where it was said: a book, a talk, a page.
  final Widget? source;

  /// The mark that opens the quote, drawn at twice the text's size in a pale
  /// wash of the colour. `null` leaves it out.
  final Widget? icon;

  /// The weight of the surface. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.text].
  final NebaVariant? variant;

  /// The quote's type scale, its corners and its padding. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the rule and the mark.
  final NebaColor color;

  /// How much padding the quote has at its [size].
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`. A `text` quote has no sheet to lift.
  final NebaElevation elevation;

  /// How the quote arrives when it is first built.
  final NebaTransition? transition;

  /// The quote's text size and line height at each step.
  static const Map<NebaSize, (double, double)> quoteText = <NebaSize, (double, double)>{
    NebaSize.xs: (12, 20),
    NebaSize.sm: (13, 22),
    NebaSize.md: (15, 26),
    NebaSize.lg: (17, 30),
    NebaSize.xl: (20, 34),
  };

  /// The width of the rule down the start edge.
  static const double rule = 2;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = this.variant ?? defaults.variant ?? NebaVariant.text;
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = this.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColorRoles roles = tokens.roles(color);
    final double padding = NebaBox.padding[density]![size]!;
    final (double text, double leading) = quoteText[size]!;
    final Widget? icon = this.icon;
    final Widget? author = this.author;
    final Widget? source = this.source;
    final double meta = NebaScale.metaText[size]!;

    final Widget quote = DefaultTextStyle.merge(
      style: TextStyle(fontSize: text, height: leading / text, color: tokens.fg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ExcludeSemantics(
                child: IconTheme.merge(
                  data: IconThemeData(size: text * 2, color: roles.softPress),
                  child: SizedBox.square(dimension: text * 2, child: icon),
                ),
              ),
            ),
          ?child,
          if (author != null || source != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: DefaultTextStyle.merge(
                style: TextStyle(fontSize: meta, height: null, color: tokens.mutedFg),
                child: Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    if (author != null)
                      DefaultTextStyle.merge(
                        style: TextStyle(color: tokens.fg, fontWeight: FontWeight.w500),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            // An em dash, as an attribution has been set since
                            // print, which a screen reader does not read out.
                            const ExcludeSemantics(child: Text('— ')),
                            Flexible(child: author),
                          ],
                        ),
                      ),
                    ?source,
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    final BorderRadius radius = variant == NebaVariant.text
        ? BorderRadius.zero
        : BorderRadiusDirectional.horizontal(
            end: Radius.circular(tokens.radius[size]!),
          ).resolve(Directionality.of(context));

    Widget quoted;

    if (variant == NebaVariant.text) {
      // The rule alone, taking its two pixels as a CSS border does.
      quoted = Container(
        decoration: BoxDecoration(
          border: BorderDirectional(
            start: BorderSide(color: roles.accent, width: rule),
          ),
        ),
        padding: EdgeInsets.all(padding),
        child: quote,
      );
    } else {
      final bool outline = variant == NebaVariant.outline;

      quoted = Stack(
        children: <Widget>[
          NebaSheet(
            fill: outline ? tokens.panel : tokens.panelHover,
            edge: outline ? roles.line : null,
            plate: outline ? NebaPlate.glass : NebaPlate.solid,
            elevation: elevation,
            borderRadius: radius,
            child: Padding(
              // The rule's two pixels at the start, past the hairline the
              // sheet already pads for.
              padding: EdgeInsetsDirectional.fromSTEB(
                padding + rule - (outline ? 1 : 0),
                padding,
                padding,
                padding,
              ),
              child: quote,
            ),
          ),
          // Over the sheet's own edge on that side, as a wider border of
          // another colour replaces it.
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            width: rule,
            child: ColoredBox(color: roles.accent),
          ),
        ],
      );
    }

    quoted = NebaRing(borderRadius: radius, child: quoted);

    final NebaTransition? transition = this.transition;

    return transition == null ? quoted : NebaEntrance(transition: transition, child: quoted);
  }
}

/// The quote mark that opens a quote, two filled commas.
class _QuoteMark extends StatelessWidget {
  const _QuoteMark();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return CustomPaint(painter: _QuoteMarkPainter(icon.color ?? const Color(0xFF000000)));
  }
}

class _QuoteMarkPainter extends CustomPainter {
  _QuoteMarkPainter(this.color);

  final Color color;

  /// One of the two marks in its 16-unit box; the second is the first moved
  /// 6.9 units along.
  static Path _mark(double dx) {
    return Path()
      ..moveTo(6.4 + dx, 3.6)
      ..cubicTo(4.1 + dx, 4.5, 2.7 + dx, 6.4, 2.7 + dx, 8.7)
      ..cubicTo(2.7 + dx, 10.7, 3.9 + dx, 12, 5.5 + dx, 12)
      ..cubicTo(6.9 + dx, 12, 8 + dx, 11, 8 + dx, 9.6)
      ..cubicTo(8 + dx, 8.3, 7.1 + dx, 7.4, 5.9 + dx, 7.4)
      ..cubicTo(5.7 + dx, 7.4, 5.5 + dx, 7.4, 5.3 + dx, 7.5)
      ..cubicTo(5.6 + dx, 6.5, 6.4 + dx, 5.7, 7.5 + dx, 5.2)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fill = Paint()..color = color;

    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawPath(_mark(0), fill)
      ..drawPath(_mark(6.9), fill)
      ..restore();
  }

  @override
  bool shouldRepaint(_QuoteMarkPainter oldDelegate) => oldDelegate.color != color;
}
