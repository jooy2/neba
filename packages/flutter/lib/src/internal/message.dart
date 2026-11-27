/// The inside of a sheet that says what happened: the row an Alert and a
/// Toast lay out on their sheets.
///
/// The React package writes the same classes into both: the box padding, the
/// sheet's body type, a glyph, an action and a × each centred on the first
/// line of the text with `h-[1lh]`, and the title over the message in a column
/// that is the live region. What differs between the two is the colours and
/// the action, so those are arguments and the rest is here once.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/hit.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/live_region.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/types.dart';

/// The padded row of a message sheet: [glyph], then [title] over [message] in
/// a live region in [role], then [action] and a × that calls [onClose].
///
/// The type is the sheet body's at [size], and the glyph, the action and the
/// × are centred on the message's first line. The × is drawn at the size of
/// the text and pressed across 24 pixels that reach into the padding around
/// it. The action and the × sit outside the live region, so a screen reader
/// does not read their names out with the message.
class NebaMessageContent extends StatelessWidget {
  /// A row at [size] and [density] in [ink].
  const NebaMessageContent({
    required this.size,
    required this.density,
    required this.ink,
    required this.accent,
    required this.detail,
    required this.role,
    this.glyph,
    this.title,
    this.message,
    this.action,
    this.onClose,
    this.closeLabel = '',
    this.ring = const Color(0x00000000),
    super.key,
  });

  /// The type, the gaps and the padding.
  final NebaSize size;

  /// How much padding the row has at its [size].
  final NebaDensity density;

  /// The message's ink, when it is the whole of what is said.
  final Color ink;

  /// The ink of the glyph and the title.
  final Color accent;

  /// The message's ink under a title.
  final Color detail;

  /// The live region the title and the message are in.
  final SemanticsRole role;

  /// Drawn at the start, at 1.2 times the message's size.
  final Widget? glyph;

  /// The heading line, one step above the message in semibold.
  final Widget? title;

  /// What is said.
  final Widget? message;

  /// Pinned to the end of the first line, before the ×.
  final Widget? action;

  /// Passing it is what draws the ×.
  final VoidCallback? onClose;

  /// What a screen reader hears for the ×.
  final String closeLabel;

  /// The ×'s focus ring.
  final Color ring;

  @override
  Widget build(BuildContext context) {
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final double bodySize = NebaScale.sheetBodyText[size]!;
    final double titleSize = NebaScale.sheetTitleText[size]!;
    // The React package's `em` and `1lh`: the message's size as it is drawn,
    // and the height of its first line, which the glyph, the action and the
    // × are centred on whatever the type scale turns out to be.
    final double em = scaler.scale(bodySize);
    final double line = em * NebaScale.sheetBodyLeading[size]! / bodySize;

    final Widget? glyph = this.glyph;
    final Widget? title = this.title;
    final Widget? message = this.message;
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
            role: role,
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
              label: closeLabel,
              ring: ring,
              extent: em * 1.15,
              glyph: em * 1.2,
            ),
          ),
      ],
    );

    return NebaInk(
      color: ink,
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: bodySize, height: NebaScale.sheetBodyLeading[size]! / bodySize),
        child: IconTheme.merge(
          // Icons track the text they sit in, as `1.2em` does.
          data: IconThemeData(size: em * 1.2),
          // The ×'s target reaches into the padding around it.
          child: NebaHitArea(
            child: Padding(padding: EdgeInsets.all(NebaBox.padding[density]![size]!), child: row),
          ),
        ),
      ),
    );
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
