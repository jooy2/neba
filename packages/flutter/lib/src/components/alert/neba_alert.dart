/// `NebaAlert`, a message about something that happened, set into the page it
/// is about.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/hit.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/live_region.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/ring.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A message about something that happened, set into the page it is about: a
/// save confirmation, a validation error, a setting that needs attention.
///
/// The three shapes people mean by "an alert" are one widget with different
/// slots filled: a bare line (`showIcon: false`), a line with the glyph of its
/// severity (the default), and the glyph with a [title] and the detail under
/// it. The surface does not change between them, only how much of it is used.
///
/// An alert *is* the thing being coloured, so unlike a `NebaBox` its sheet
/// takes the tint of [color]. The title and the message are a live region,
/// which [role] decides, and the [action] and the dismiss button sit outside
/// it, so a screen reader does not read their names out with the message. An
/// alert takes the width it is given, as a paragraph does.
///
/// ```dart
/// NebaAlert(
///   color: NebaColor.danger,
///   title: const Text('Deploy failed'),
///   onClose: dismiss,
///   child: const Text('The build exited with code 1.'),
/// )
/// ```
class NebaAlert extends StatelessWidget {
  /// An alert saying [child].
  const NebaAlert({
    this.child,
    this.title,
    this.icon,
    this.showIcon = true,
    this.action,
    this.onClose,
    this.locale,
    this.closeLabel,
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

  /// The message, usually a [Text]. On its own it is the whole alert, in the
  /// body's ink; under a [title] it is the detail, in the muted ink on an
  /// `outline` or a `text` alert.
  final Widget? child;

  /// The heading line, one step above the message in semibold and in the
  /// family's accent. With it the alert is two-part, a headline and the
  /// detail under it; without it the whole thing is one line.
  final Widget? title;

  /// Replaces the glyph that goes with [color]. It is drawn at 1.2 times the
  /// message's size through the [IconTheme] the alert hands down, centred on
  /// the first line.
  final Widget? icon;

  /// Whether the alert draws a glyph at all. `false` is the bare line, the
  /// React package's `icon={false}`.
  final bool showIcon;

  /// Pinned to the end of the row: a "Retry" button, a link. Kept out of
  /// [child] so it stays on the first line while the message wraps beside it.
  final Widget? action;

  /// Passing it is what makes the dismiss button appear, after [action].
  final VoidCallback? onClose;

  /// The language the dismiss button is named in. Defaults to
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// What a screen reader hears for the dismiss button. Defaults to the
  /// [locale]'s "Dismiss".
  final String? closeLabel;

  /// The live region the title and the message are in.
  /// [SemanticsRole.alert] interrupts what a screen reader is saying and
  /// [SemanticsRole.status] waits for a pause; `warning` and `danger` take
  /// the first and every other family the second. [SemanticsRole.none]
  /// leaves the message out of every live region.
  final SemanticsRole? role;

  /// The sheet's weight: `solid` floods it with the family, `outline` tints
  /// it and draws the hairline, `text` lays only the wash, for an alert among
  /// form fields. Defaults to `NebaProvider`'s, then [NebaVariant.outline].
  final NebaVariant? variant;

  /// The type of the title and the message, the sheet's corners and its
  /// padding. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The severity, which picks the surface, the glyph and the live region
  /// together. Defaults to [NebaColor.info]: an alert with no severity named
  /// is an informational one.
  final NebaColor? color;

  /// How much padding the sheet has at its [size]. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0`, which is none, to `3`. An alert sits in the
  /// flow of the page; the one that floats above it is a toast. A `text`
  /// alert has no sheet to lift and ignores it.
  final NebaElevation? elevation;

  /// How the alert arrives when it is first built: `const
  /// NebaTransition.slide()` for a banner arriving, `const
  /// NebaTransition.fade()` for one appearing in place.
  final NebaTransition? transition;

  /// The live region each family's alert is in: what goes wrong is worth
  /// interrupting for, and what went well is not.
  static const Map<NebaColor, SemanticsRole> rolesFor = <NebaColor, SemanticsRole>{
    NebaColor.primary: SemanticsRole.status,
    NebaColor.secondary: SemanticsRole.status,
    NebaColor.info: SemanticsRole.status,
    NebaColor.success: SemanticsRole.status,
    NebaColor.warning: SemanticsRole.alert,
    NebaColor.danger: SemanticsRole.alert,
  };

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = this.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final NebaColor color = this.color ?? NebaColor.info;
    final NebaDensity density = this.density ?? defaults.density ?? NebaDensity.standard;
    final NebaElevation elevation = this.elevation ?? 0;
    final NebaColorRoles roles = tokens.roles(color);
    final BorderRadius radius = BorderRadius.circular(tokens.radius[size]!);
    final TextScaler scaler = MediaQuery.textScalerOf(context);

    final double bodySize = NebaScale.sheetBodyText[size]!;
    final double titleSize = NebaScale.sheetTitleText[size]!;
    // The React package's `em` and `1lh`: the message's size as it is drawn,
    // and the height of its first line, which the glyph, the action and the
    // dismiss button are centred on whatever the type scale turns out to be.
    final double em = scaler.scale(bodySize);
    final double line = em * NebaScale.sheetBodyLeading[size]! / bodySize;

    // On a filled sheet the family is already the surface, so the glyph and
    // the title ride on it in one ink. On a tinted one the message stays
    // ordinary reading text, and the accent is spent on the two things that
    // say which kind of alert this is; under a title the message steps back
    // to the muted ink, which a filled sheet has no room for.
    final bool solid = variant == NebaVariant.solid;
    final Color ink = solid ? roles.onSolid : tokens.fg;
    final Color accent = solid ? roles.onSolid : roles.accent;
    final Color detail = solid ? roles.onSolid : tokens.mutedFg;

    final Widget? glyph = showIcon ? icon ?? NebaGlyph(NebaGlyphs.severity(color)) : null;
    final Widget? title = this.title;
    final Widget? message = child;
    final Widget? action = this.action;
    final VoidCallback? onClose = this.onClose;

    final Widget row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: NebaScale.sheetSectionGap[size]!,
      children: <Widget>[
        if (glyph != null)
          _FirstLine(
            height: line,
            child: NebaInk(color: accent, child: glyph),
          ),
        Expanded(
          child: NebaLiveRegion(
            role: role ?? rolesFor[color]!,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: NebaScale.sheetHeaderGap[size]!,
              children: <Widget>[
                if (title != null)
                  NebaInk(
                    color: accent,
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: titleSize,
                        height: NebaScale.sheetTitleLeading[size]! / titleSize,
                        fontWeight: FontWeight.w600,
                      ),
                      child: IconTheme.merge(
                        data: IconThemeData(size: scaler.scale(titleSize) * 1.2),
                        child: title,
                      ),
                    ),
                  ),
                if (message != null)
                  title == null ? message : NebaInk(color: detail, child: message),
              ],
            ),
          ),
        ),
        if (action != null) _FirstLine(height: line, child: action),
        if (onClose != null)
          _FirstLine(
            height: line,
            child: _DismissButton(
              onPressed: onClose,
              label: closeLabel ?? nebaMessages(context, 'action', locale: locale)['dismiss']!,
              ring: roles.ring,
              extent: em * 1.15,
              glyph: em * 1.2,
            ),
          ),
      ],
    );

    final Widget content = NebaInk(
      color: ink,
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: bodySize, height: NebaScale.sheetBodyLeading[size]! / bodySize),
        child: IconTheme.merge(
          // Icons track the text they sit in, as `1.2em` does.
          data: IconThemeData(size: em * 1.2),
          // The dismiss button's target reaches into the padding around it.
          child: NebaHitArea(
            child: Padding(padding: EdgeInsets.all(NebaBox.padding[density]![size]!), child: row),
          ),
        ),
      ),
    );

    final Widget sheet = switch (variant) {
      NebaVariant.solid => NebaSheet(
        fill: roles.fill,
        elevation: elevation,
        borderRadius: radius,
        child: content,
      ),
      NebaVariant.outline => NebaSheet(
        fill: roles.panel,
        edge: roles.line,
        plate: NebaPlate.glass,
        elevation: elevation,
        borderRadius: radius,
        child: content,
      ),
      // No sheet and no edge, only the tint: for an alert set among form
      // fields, where a second bordered rectangle is one too many.
      NebaVariant.text => NebaSheet(
        fill: roles.soft,
        plate: NebaPlate.none,
        borderRadius: radius,
        blur: false,
        texture: false,
        child: content,
      ),
    };

    // The ring of a pile the alert is in, around its corners.
    Widget alert = Semantics(
      container: true,
      child: NebaRing(borderRadius: radius, child: sheet),
    );

    final NebaTransition? transition = this.transition;

    if (transition != null) {
      alert = NebaEntrance(transition: transition, child: alert);
    }

    return alert;
  }
}

/// A slot at the end or the start of the row, centred on the message's first
/// line, the React package's `h-[1lh] items-center`. Something taller than
/// the line stands out of it above and below rather than pushing the line
/// down, as it does in CSS.
class _FirstLine extends StatelessWidget {
  const _FirstLine({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OverflowBox(
        minHeight: 0,
        maxHeight: double.infinity,
        fit: OverflowBoxFit.deferToChild,
        child: child,
      ),
    );
  }
}

/// The ×: drawn at the size of the text beside it, pressed at the size of a
/// finger.
class _DismissButton extends StatelessWidget {
  const _DismissButton({
    required this.onPressed,
    required this.label,
    required this.ring,
    required this.extent,
    required this.glyph,
  });

  final VoidCallback onPressed;
  final String label;
  final Color ring;
  final double extent;
  final double glyph;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      enabled: true,
      label: label,
      child: NebaHitTarget(
        child: NebaInteractive(
          onTap: onPressed,
          builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
            return NebaFocusRing(
              visible: interaction.focusVisible,
              color: ring,
              borderRadius: BorderRadius.circular(extent),
              child: AnimatedOpacity(
                opacity: interaction.hovered || interaction.focusVisible ? 1 : 0.7,
                duration: nebaDuration(context, NebaScale.duration),
                curve: NebaScale.ease,
                child: SizedBox.square(
                  dimension: extent,
                  child: OverflowBox(
                    maxWidth: glyph,
                    maxHeight: glyph,
                    child: NebaGlyph(NebaGlyphs.close, size: glyph),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
