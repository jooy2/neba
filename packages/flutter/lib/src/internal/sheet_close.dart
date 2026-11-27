/// The × in the corner of a sheet: the React package's `sheetCloseClasses`,
/// which a Popover draws now and a Dialog, a Drawer and a Tour step will.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A round × button 1.6 times the sheet's text across, with the glyph at 1.1
/// times: muted at rest, in the page's foreground on a wash of [color]'s
/// family under the pointer, and ringed in that family for the keyboard.
class NebaSheetClose extends StatelessWidget {
  /// A × that calls [onPressed], announced as [label].
  const NebaSheetClose({
    required this.onPressed,
    required this.label,
    required this.color,
    this.hiddenUntilFocused = false,
    super.key,
  });

  /// Closes the sheet.
  final VoidCallback onPressed;

  /// What a screen reader hears.
  final String label;

  /// The family of the wash and the ring.
  final NebaColor color;

  /// Takes no room and draws nothing until it holds the keyboard focus, and
  /// then draws on a plate of the sheet's own colour: the way out a modal
  /// popup keeps for a reader who cannot see the page or press Escape, which
  /// a screen reader still finds and presses while it is hidden.
  final bool hiddenUntilFocused;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaColorRoles roles = tokens.roles(color);
    final double text = DefaultTextStyle.of(context).style.fontSize ?? 13;
    final double extent = text * 1.6;

    return Semantics(
      container: true,
      button: true,
      label: label,
      child: NebaInteractive(
        onTap: onPressed,
        builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
          final bool lit = interaction.hovered && !hiddenUntilFocused;
          final Color plate = hiddenUntilFocused
              ? tokens.panelPress
              : lit
              ? roles.soft
              : roles.soft.withValues(alpha: 0);

          final Widget button = NebaFocusRing(
            visible: interaction.focusVisible,
            color: roles.ring,
            borderRadius: BorderRadius.circular(extent / 2),
            child: AnimatedContainer(
              duration: nebaDuration(context, NebaScale.duration),
              curve: NebaScale.ease,
              width: extent,
              height: extent,
              decoration: BoxDecoration(color: plate, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: NebaInk(
                color: lit ? tokens.fg : tokens.mutedFg,
                child: NebaGlyph(NebaGlyphs.close, size: text * 1.1),
              ),
            ),
          );

          if (!hiddenUntilFocused) {
            return button;
          }

          // The same widgets whether it shows or not, so that showing it does
          // not build it again and take the focus away from it. Hidden, it is
          // a box of none that a pointer cannot reach. It shows for the
          // keyboard only, as `:focus-visible` does.
          return ValueListenableBuilder<bool>(
            valueListenable: NebaInputModality.pointer,
            builder: (BuildContext context, bool pointer, Widget? _) {
              final bool shown = interaction.focusVisible && !pointer;

              return SizedBox(
                width: shown ? extent : 0,
                height: shown ? extent : 0,
                child: OverflowBox(
                  alignment: AlignmentDirectional.topEnd,
                  minWidth: 0,
                  minHeight: 0,
                  maxWidth: extent,
                  maxHeight: extent,
                  child: Opacity(
                    opacity: shown ? 1 : 0,
                    alwaysIncludeSemantics: true,
                    child: button,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
