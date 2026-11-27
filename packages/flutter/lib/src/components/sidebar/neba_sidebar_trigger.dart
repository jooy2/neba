/// `NebaSidebarTrigger`, the button that brings back a collapsed sidebar.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/icon_button/neba_icon_button.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/page_layout.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/types.dart';

/// The button that brings back a `NebaSidebar` the window has become too
/// narrow to hold, as a drawer.
///
/// It is there exactly while the sidebar is not: below the `NebaPageLayout`'s
/// `collapseBelow`, and nothing at and above it. Put it in a `NebaHeader`'s
/// `brand`, ahead of the logo, which is where readers look for it. Outside a
/// layout there is no sidebar it could be talking about, and it builds
/// nothing.
///
/// ```dart
/// NebaHeader(brand: const <Widget>[NebaSidebarTrigger(), Text('Neba')])
/// ```
class NebaSidebarTrigger extends StatelessWidget {
  /// A button that opens and closes a layout's sidebar.
  const NebaSidebarTrigger({
    this.side = NebaSidebarSide.start,
    this.collapseBelow,
    this.icon,
    this.label,
    this.locale,
    this.onPressed,
    this.variant,
    this.size,
    this.color,
    this.elevation,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// Which of the layout's two sidebars it opens.
  final NebaSidebarSide side;

  /// The window width below which it is there: the one the sidebar collapses
  /// at. Defaults to the layout's, which is where it should be set.
  final NebaBreakpoint? collapseBelow;

  /// The glyph: three lines, unless something else is given.
  final Widget? icon;

  /// What it does, in words. Defaults to the [locale]'s "Open sidebar" or
  /// "Close sidebar".
  final String? label;

  /// The language of that word. Defaults to the layout's, then
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// Called after the press has opened or closed the drawer.
  final VoidCallback? onPressed;

  /// The weight of the button. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.text].
  final NebaVariant? variant;

  /// The button's height, which is also its width.
  final NebaSize? size;

  /// The colour family.
  final NebaColor? color;

  /// The drop shadow, from `0` to `3`.
  final NebaElevation? elevation;

  /// The button's focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the button takes the focus when it is first built.
  final bool autofocus;

  /// Three lines, in the 16-unit box the library's glyphs are drawn in: the
  /// one picture of a menu a reader knows without a word beside it.
  static final List<NebaGlyphPart> glyph = <NebaGlyphPart>[
    const NebaGlyphPart.stroke(
      'M2.667 4.667h10.666M2.667 8h10.666M2.667 11.333h10.666',
      width: 4 / 3,
      cap: StrokeCap.round,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final NebaPageLayoutScope? layout = NebaPageLayoutScope.maybeOf(context);

    if (layout == null || !nebaCollapsed(context, collapseBelow ?? layout.collapseBelow)) {
      return const SizedBox.shrink();
    }

    final bool open = layout.openOf(side);
    final Map<String, String> words = nebaMessages(
      context,
      'layout',
      locale: locale ?? layout.locale,
    );

    // One node with the button's own, so the state it opens is said on the
    // button rather than on something around it.
    return MergeSemantics(
      child: Semantics(
        expanded: open,
        child: NebaIconButton(
          onPressed: () {
            layout.onOpenChange(side, !open);
            onPressed?.call();
          },
          icon: icon ?? NebaGlyph(glyph),
          label: label ?? (open ? words['closeSidebar']! : words['openSidebar']!),
          variant: variant ?? NebaTheme.defaultsOf(context).variant ?? NebaVariant.text,
          size: size,
          color: color,
          elevation: elevation,
          focusNode: focusNode,
          autofocus: autofocus,
        ),
      ),
    );
  }
}
