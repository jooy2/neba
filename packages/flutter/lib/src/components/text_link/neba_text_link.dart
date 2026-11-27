/// `NebaTextLink`, a link in a sentence or on its own.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/link.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/text_marks.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// When a [NebaTextLink] draws the line under it.
enum NebaTextLinkUnderline {
  /// Always.
  always,

  /// Only under the pointer.
  hover,

  /// Never: something else already says this is a link.
  none,
}

/// A link, in a sentence or on its own. It has no surface and no height of
/// its own: what it has is the line under it, and a mark for a link that
/// leaves the app.
///
/// The package opens nothing itself, so a link is a callback: [onPressed]
/// calls the router or a URL launcher, and [href] tells a screen reader, and
/// on the web the browser, where it goes. Inside a sentence it is a
/// [WidgetSpan] of a [Text.rich], set on the line's baseline.
///
/// ```dart
/// NebaTextLink(onPressed: openComponents, child: const Text('Components'))
/// ```
class NebaTextLink extends StatelessWidget {
  /// A link that runs [onPressed].
  const NebaTextLink({
    required this.child,
    required this.onPressed,
    this.href,
    this.underline = NebaTextLinkUnderline.always,
    this.color,
    this.size,
    this.newTab = false,
    this.icon,
    this.showIcon,
    this.locale,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// The label, usually a [Text]. A glyph after a [Text] flows at the end of
  /// its last line.
  final Widget child;

  /// What the link does. `null` leaves it drawn as a link that does nothing
  /// and takes no focus.
  final VoidCallback? onPressed;

  /// Where the link goes, for a screen reader and, on the web, the browser. A
  /// scheme other than `http`, `https`, `mailto` or `tel` is not written; a
  /// relative address and a fragment are kept.
  final Uri? href;

  /// When the line under the link is drawn.
  final NebaTextLinkUnderline underline;

  /// The family of the label and its line. Left out, the link is the colour
  /// of the text around it.
  final NebaColor? color;

  /// The type scale for a link standing on its own. Left out, the link is the
  /// size of the text around it; `NebaProvider` does not fill it in.
  final NebaSize? size;

  /// Whether the link leaves the app. It draws the external mark and is
  /// announced with "(opens in a new tab)"; opening the new tab is
  /// [onPressed]'s.
  final bool newTab;

  /// A glyph of the caller's own in place of the house one.
  final Widget? icon;

  /// Whether a glyph is drawn after the label. Defaults to [newTab], or to
  /// `true` when an [icon] is given.
  final bool? showIcon;

  /// The language the new-tab notice is written in. Defaults to
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// The link's focus node.
  final FocusNode? focusNode;

  /// Whether the link takes the focus when it is first built.
  final bool autofocus;

  /// How far the glyph stands from the label, as a fraction of the text size.
  static const double glyphGap = 0.25;

  /// The glyph's size, as a fraction of the text size.
  static const double glyphSize = 0.95;

  /// How much of the label's colour the line is drawn in at rest; under the
  /// pointer it is all of it.
  static const double restingLine = 0.45;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final TextStyle ambient = DefaultTextStyle.of(context).style;
    final NebaColor? color = this.color;
    final NebaSize? size = this.size;
    final double fontSize = size != null ? NebaScale.controlText[size]! : ambient.fontSize ?? 14;
    final Color ink = color != null ? tokens.roles(color).accent : ambient.color ?? tokens.fg;
    final Color ring = tokens.roles(color ?? NebaColor.primary).ring;
    final bool enabled = onPressed != null;
    final bool shown = showIcon ?? (icon != null || newTab);
    final double em = fontSize * MediaQuery.textScalerOf(context).scale(1);

    Widget? glyph;

    if (shown) {
      glyph = IconTheme.merge(
        data: IconThemeData(size: em * glyphSize, color: ink),
        child: SizedBox.square(
          dimension: em * glyphSize,
          child: icon ?? NebaGlyph(newTab ? NebaGlyphs.externalLink : NebaGlyphs.link),
        ),
      );
    }

    final Widget label = child;
    Widget content;
    List<TextRange>? underlined;

    if (glyph != null && label is Text) {
      // The glyph rides at the end of the last line, as an inline `<svg>`
      // does, with its foot on the baseline.
      final InlineSpan text = nebaSpanOf(label);
      underlined = <TextRange>[
        TextRange(start: 0, end: text.toPlainText(includeSemanticsLabels: false).length),
      ];
      content = nebaRetext(
        label,
        TextSpan(
          children: <InlineSpan>[
            text,
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: Padding(
                padding: EdgeInsetsDirectional.only(start: em * glyphGap),
                child: ExcludeSemantics(child: glyph),
              ),
            ),
          ],
        ),
      );
    } else if (glyph != null) {
      content = Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: em * glyphGap,
        children: <Widget>[
          label,
          ExcludeSemantics(child: glyph),
        ],
      );
    } else {
      content = label;
    }

    if (newTab) {
      // Read to everybody and drawn for nobody, after the label.
      content = Stack(
        children: <Widget>[
          content,
          Semantics(
            label: nebaMessages(context, 'link', locale: locale)['newTab'],
            child: const SizedBox.shrink(),
          ),
        ],
      );
    }

    content = DefaultTextStyle.merge(
      style: TextStyle(
        color: ink,
        fontSize: size != null ? fontSize : null,
        height: size != null ? NebaScale.controlLeading[size]! / fontSize : null,
      ),
      child: content,
    );

    final Color rest = ink.withValues(alpha: ink.a * restingLine);
    final double thickness = math.max(1, 0.055 * em);

    return Semantics(
      container: true,
      link: enabled,
      linkUrl: enabled ? nebaSafeHref(href) : null,
      child: NebaInteractive(
        enabled: enabled,
        onTap: onPressed,
        focusNode: focusNode,
        autofocus: autofocus,
        activatesOnSpace: false,
        builder: (BuildContext context, NebaInteraction interaction, _) {
          final bool lined =
              underline == NebaTextLinkUnderline.always ||
              (underline == NebaTextLinkUnderline.hover && interaction.hovered);

          return NebaFocusRing(
            visible: interaction.focusVisible,
            color: ring,
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: interaction.hovered ? ink : rest),
              duration: nebaDuration(context, NebaScale.duration),
              curve: NebaScale.ease,
              builder: (BuildContext context, Color? line, Widget? child) {
                return NebaTextMarks(
                  ranges: underlined,
                  underline: lined ? line : null,
                  underlineThickness: thickness,
                  child: child!,
                );
              },
              child: content,
            ),
          );
        },
      ),
    );
  }
}
