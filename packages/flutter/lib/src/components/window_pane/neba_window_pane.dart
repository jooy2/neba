/// `NebaWindowPane`, a window drawn the way one of eight systems draws it,
/// with anything at all inside it.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/portal/neba_portal.dart';
import 'package:neba/src/internal/color.dart';
import 'package:neba/src/internal/drag.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/hit.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Whose window a [NebaWindowPane] is a picture of.
///
/// A version is an entry of its own wherever its title bar is what changed:
/// XP painted its bar Luna blue and framed the window in it, 7 made it glass,
/// 8 made it a flat square sheet with a band of colour round it, 10 ruled the
/// bar off from the body, and 11 rounded the corners. [macosx] is Aqua against
/// the flat [macos] that replaced it. What is drawn is a bar, a border and
/// three buttons at the proportions the system used, and no mark of anyone's.
enum NebaWindowOs {
  /// Three coloured dots at the start and the title centred over the window.
  macos,

  /// Aqua: a short striped bar, glossy lights and square bottom corners.
  macosx,

  /// Rounded corners, one sheet, and three full-height buttons in the corner.
  windows11,

  /// Square corners, a bar ruled off from the body, and an accent border.
  windows10,

  /// Flat and square, with a band of colour round the whole window.
  windows8,

  /// Aero: a sheet of glass with the content sunk into it, and a wider close.
  windows7,

  /// Luna: a blue bar, a blue frame and coloured plates for buttons.
  windowsxp,

  /// A GNOME header bar: taller, with its title centred and circles for
  /// buttons.
  linux,
}

/// The three buttons a [NebaWindowPane]'s title bar can carry.
enum NebaWindowControl {
  /// Rolls the window up to its title bar.
  minimize,

  /// Fills whatever is holding the window, and back.
  maximize,

  /// Closes the window.
  close,
}

/// How a [NebaWindowPane] is laid out.
enum NebaWindowPanePosition {
  /// In the flow, moved by its `offset` without disturbing anything around
  /// it.
  static,

  /// Placed in the [Stack] it is a child of, which a desktop of windows
  /// wants.
  absolute,

  /// Placed on the screen, in the nearest [Overlay].
  fixed,
}

/// A window, drawn the way one of eight systems draws it, with anything at all
/// inside it.
///
/// It is not a real window: there is no desktop and no dock. It is a frame
/// that behaves. The title bar drags, the edges and corners resize, and the
/// three buttons are real buttons with names. Nothing in it is transformed: a
/// dragged window moves by its position and a resized one by its size, so the
/// text inside it stays where the pixels are.
///
/// Minimizing rolls the window up to its title bar, because a page has nowhere
/// to send it, and maximizing fills whatever holds it: the [Stack] for
/// [NebaWindowPanePosition.absolute] and the screen for
/// [NebaWindowPanePosition.fixed]. A window is in front until another
/// `NebaWindowPane` is pressed or takes the focus, unless [active] says.
///
/// ```dart
/// NebaWindowPane(title: const Text('Notes'), height: 280, child: notes)
/// ```
class NebaWindowPane extends StatefulWidget {
  /// A window around [child].
  const NebaWindowPane({
    this.os,
    this.title,
    this.icon,
    this.actions,
    this.controls = const <NebaWindowControl>{
      NebaWindowControl.minimize,
      NebaWindowControl.maximize,
      NebaWindowControl.close,
    },
    this.size,
    this.color,
    this.accent = false,
    this.transparency = 0,
    this.active,
    this.elevation,
    this.position = NebaWindowPanePosition.static,
    this.draggable = false,
    this.resizable = false,
    this.width,
    this.height,
    this.minWidth = 180,
    this.minHeight,
    this.offset,
    this.defaultOffset = Offset.zero,
    this.onOffsetChange,
    this.onResize,
    this.open,
    this.defaultOpen = true,
    this.onOpenChange,
    this.minimized,
    this.defaultMinimized = false,
    this.onMinimizedChange,
    this.maximized,
    this.defaultMaximized = false,
    this.onMaximizedChange,
    this.scroll = true,
    this.locale,
    this.minimizeLabel,
    this.maximizeLabel,
    this.restoreLabel,
    this.closeLabel,
    this.resizeLabel,
    this.semanticLabel,
    this.child,
    super.key,
  }) : assert(transparency >= 0 && transparency <= 1),
       assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// Whose window this is a picture of: where the controls sit, how they are
  /// drawn, how tall the bar is and how its corners are cut. Defaults to
  /// [NebaWindowOs.macos].
  final NebaWindowOs? os;

  /// The window's name, in the title bar. A [Text] also names the window for
  /// a screen reader.
  final Widget? title;

  /// A glyph beside the title: the app's mark.
  final Widget? icon;

  /// Anything else the bar carries, set beside the controls.
  final Widget? actions;

  /// Which buttons the bar has; an empty set is none. The order is the
  /// system's: macOS puts close first and Windows puts it last.
  final Set<NebaWindowControl> controls;

  /// The scale of the chrome: the bar's height, its buttons and its type. It
  /// does not touch the content. Defaults to `NebaProvider`'s, then
  /// [NebaSize.md].
  final NebaSize? size;

  /// The family the focus rings and an [accent] bar take. Defaults to
  /// [NebaColor.primary].
  final NebaColor? color;

  /// Whether the bar is dyed with [color], the way Windows offers to.
  final bool accent;

  /// How much of what is behind the window shows through its chrome, from `0`
  /// to `1`: the bar, the body's own fill and the band, never what is on
  /// them. Anything above `0` blurs the page underneath as well.
  final double transparency;

  /// Whether this is the window in front. Left out, the window is in front
  /// until another `NebaWindowPane` is pressed or takes the focus. A window
  /// behind keeps its shape and loses its emphasis: its colours drain and its
  /// shadow drops a step.
  final bool? active;

  /// The shadow, from `0` to `3`. Defaults to `2`: a window is not part of
  /// the page it is on.
  final NebaElevation? elevation;

  /// How the window is laid out.
  final NebaWindowPanePosition position;

  /// Whether the title bar drags the window.
  final bool draggable;

  /// Whether the edges and corners resize it.
  final bool resizable;

  /// The window's width. Left out, it is as wide as its parent allows, or as
  /// wide as what is in it when it is placed in a [Stack].
  final double? width;

  /// The window's height. Left out, it is as tall as what is in it.
  final double? height;

  /// How narrow it may be dragged.
  final double minWidth;

  /// How short it may be dragged. Defaults to the title bar's height.
  final double? minHeight;

  /// How far it has been dragged from where the layout put it. Controlled
  /// with [onOffsetChange], or left to keep its own from [defaultOffset].
  final Offset? offset;

  /// Where a window that keeps its own offset starts.
  final Offset defaultOffset;

  /// Called with the offset a drag moves the window to.
  final ValueChanged<Offset>? onOffsetChange;

  /// Called with the window's size while an edge is dragged.
  final ValueChanged<Size>? onResize;

  /// Whether the window is on screen at all. A closed window fades out and
  /// then draws nothing. Controlled with [onOpenChange], or left to keep its
  /// own from [defaultOpen].
  final bool? open;

  /// Whether a window that keeps its own state starts open.
  final bool defaultOpen;

  /// Called when the close button is pressed.
  final ValueChanged<bool>? onOpenChange;

  /// Whether the window is rolled up to its title bar.
  final bool? minimized;

  /// Whether a window that keeps its own state starts rolled up.
  final bool defaultMinimized;

  /// Called when the minimize button is pressed.
  final ValueChanged<bool>? onMinimizedChange;

  /// Whether the window fills whatever is holding it. Its corners go square
  /// while it does.
  final bool? maximized;

  /// Whether a window that keeps its own state starts maximized.
  final bool defaultMaximized;

  /// Called when the maximize button is pressed or the bar is double-tapped.
  final ValueChanged<bool>? onMaximizedChange;

  /// Whether content taller than the window scrolls. Off, it is given the
  /// window's height exactly, which a child that fills the window wants.
  final bool scroll;

  /// The language the buttons name themselves in. Defaults to
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// The minimize button's name, over the [locale]'s word.
  final String? minimizeLabel;

  /// The maximize button's name.
  final String? maximizeLabel;

  /// The maximize button's name while the window is maximized.
  final String? restoreLabel;

  /// The close button's name.
  final String? closeLabel;

  /// The resizing corner's name.
  final String? resizeLabel;

  /// The name a screen reader announces for the window, over a [Text]
  /// title.
  final String? semanticLabel;

  /// What is in the window.
  final Widget? child;

  /// How far one arrow key moves the resizing corner.
  static const double keyboardStep = 16;

  /// The chrome's metrics for [os] at [size], in logical pixels.
  static NebaWindowMetrics metricsOf(NebaWindowOs os, NebaSize size) {
    return NebaWindowMetrics._(_chromes[os]!, _scales[size]!);
  }

  /// The controls in [controls], in the order [os] puts them in.
  static List<NebaWindowControl> orderOf(NebaWindowOs os, Set<NebaWindowControl> controls) {
    final List<NebaWindowControl> order = switch (os) {
      NebaWindowOs.macos || NebaWindowOs.macosx => const <NebaWindowControl>[
        NebaWindowControl.close,
        NebaWindowControl.minimize,
        NebaWindowControl.maximize,
      ],
      _ => const <NebaWindowControl>[
        NebaWindowControl.minimize,
        NebaWindowControl.maximize,
        NebaWindowControl.close,
      ],
    };

    return <NebaWindowControl>[
      for (final NebaWindowControl control in order)
        if (controls.contains(control)) control,
    ];
  }

  @override
  State<NebaWindowPane> createState() => _NebaWindowPaneState();
}

/* ---------------------------------------------------------------------------
 * The chrome, per system
 * ------------------------------------------------------------------------- */

enum _Shape { dot, glossDot, square, plate, aero, circle }

/// A system's chrome at `md`, the React package's `internal/window.tsx`.
@immutable
class _Chrome {
  const _Chrome({
    required this.bar,
    required this.radius,
    required this.radiusBottom,
    required this.padX,
    required this.padEnd,
    required this.gap,
    required this.title,
    required this.glyph,
    required this.weight,
    required this.frame,
    required this.band,
    required this.control,
    required this.centred,
    required this.controlsAtStart,
    required this.shape,
    required this.rule,
    required this.stroke,
    required this.boxRadius,
    required this.tint,
    required this.accentBorder,
    this.closeWidth,
    this.paint,
    this.image,
    this.shadows = const <Shadow>[],
    this.stripes = false,
    this.glass = false,
  });

  final double bar;
  final double radius;
  final double radiusBottom;
  final double padX;
  final double padEnd;
  final double gap;
  final double title;
  final double glyph;
  final FontWeight weight;
  final double frame;
  final ({double side, double bottom}) band;
  final Size control;
  final double? closeWidth;
  final bool centred;
  final bool controlsAtStart;
  final _Shape shape;
  final bool rule;
  final double stroke;
  final double boxRadius;

  /// How much of the page's ink is stirred into the bar, in front and behind,
  /// out of a hundred.
  final (double, double) tint;
  final bool accentBorder;

  /// The colours a system painted its bar in rather than the page's.
  final ({Color fill, Color ink, bool dark})? paint;

  /// What is laid over that fill: the gloss, the gradient.
  final Gradient? image;

  /// The title's own shadow.
  final List<Shadow> shadows;

  /// Aqua's pinstripes across the bar.
  final bool stripes;

  /// Whether the window blurs what is behind it, which is what made Aero.
  final bool glass;
}

Color _white(double alpha) => Color.from(alpha: alpha, red: 1, green: 1, blue: 1);
Color _black(double alpha) => Color.from(alpha: alpha, red: 0, green: 0, blue: 0);

LinearGradient _down(List<(Color, double)> stops) {
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[for (final (Color colour, double _) in stops) colour],
    stops: <double>[for (final (Color _, double at) in stops) at],
  );
}

final Map<NebaWindowOs, _Chrome> _chromes = <NebaWindowOs, _Chrome>{
  NebaWindowOs.macos: const _Chrome(
    bar: 38,
    radius: 10,
    radiusBottom: 10,
    padX: 12,
    padEnd: 12,
    gap: 8,
    title: 13,
    glyph: 7,
    weight: FontWeight.w500,
    frame: 1,
    band: (side: 0, bottom: 0),
    control: Size(12, 12),
    centred: true,
    controlsAtStart: true,
    shape: _Shape.dot,
    rule: false,
    stroke: 1.4,
    boxRadius: 0,
    tint: (6, 3),
    accentBorder: false,
  ),
  NebaWindowOs.macosx: _Chrome(
    bar: 26,
    radius: 8,
    radiusBottom: 0,
    padX: 10,
    padEnd: 10,
    gap: 8,
    title: 12,
    glyph: 7,
    weight: FontWeight.w700,
    frame: 1,
    band: (side: 0, bottom: 0),
    control: const Size(13, 13),
    centred: true,
    controlsAtStart: true,
    shape: _Shape.glossDot,
    rule: true,
    stroke: 1.5,
    boxRadius: 0,
    tint: (0, 0),
    accentBorder: false,
    paint: (fill: const Color(0xFFE4E4E4), ink: const Color(0xFF333333), dark: false),
    image: _down(<(Color, double)>[(_white(0.8), 0), (_black(0.07), 1)]),
    shadows: <Shadow>[Shadow(offset: const Offset(0, 1), color: _white(0.85))],
    stripes: true,
  ),
  NebaWindowOs.windows11: const _Chrome(
    bar: 32,
    radius: 8,
    radiusBottom: 8,
    padX: 12,
    padEnd: 0,
    gap: 0,
    title: 12,
    glyph: 10,
    weight: FontWeight.w400,
    frame: 1,
    band: (side: 0, bottom: 0),
    control: Size(46, 32),
    centred: false,
    controlsAtStart: false,
    shape: _Shape.square,
    rule: false,
    stroke: 1,
    boxRadius: 1.6,
    tint: (3, 1),
    accentBorder: false,
  ),
  NebaWindowOs.windows10: const _Chrome(
    bar: 30,
    radius: 0,
    radiusBottom: 0,
    padX: 10,
    padEnd: 0,
    gap: 0,
    title: 12,
    glyph: 10,
    weight: FontWeight.w400,
    frame: 1,
    band: (side: 0, bottom: 0),
    control: Size(45, 30),
    centred: false,
    controlsAtStart: false,
    shape: _Shape.square,
    rule: true,
    stroke: 0.9,
    boxRadius: 0,
    tint: (0, 0),
    accentBorder: true,
  ),
  NebaWindowOs.windows8: const _Chrome(
    bar: 32,
    radius: 0,
    radiusBottom: 0,
    padX: 10,
    padEnd: 0,
    gap: 0,
    title: 12,
    glyph: 11,
    weight: FontWeight.w400,
    frame: 2,
    band: (side: 0, bottom: 0),
    control: Size(45, 32),
    centred: false,
    controlsAtStart: false,
    shape: _Shape.square,
    rule: false,
    stroke: 1,
    boxRadius: 0,
    tint: (0, 0),
    accentBorder: true,
  ),
  NebaWindowOs.windows7: _Chrome(
    bar: 30,
    radius: 7,
    radiusBottom: 0,
    padX: 10,
    padEnd: 3,
    gap: 2,
    title: 12,
    glyph: 10,
    weight: FontWeight.w400,
    frame: 1,
    band: (side: 7, bottom: 7),
    control: const Size(29, 20),
    closeWidth: 45,
    centred: false,
    controlsAtStart: false,
    shape: _Shape.aero,
    rule: false,
    stroke: 1.1,
    boxRadius: 0,
    tint: (0, 0),
    accentBorder: false,
    paint: (fill: rgb(198, 218, 242, 0.45), ink: const Color(0xFF12314F), dark: false),
    image: _down(<(Color, double)>[
      (_white(0.62), 0),
      (_white(0.1), 0.46),
      (_white(0.34), 0.88),
      (_white(0.5), 1),
    ]),
    shadows: <Shadow>[
      Shadow(color: _white(0.95), blurRadius: shadowBlurRadius(6)),
      Shadow(color: _white(0.95), blurRadius: shadowBlurRadius(3)),
    ],
    glass: true,
  ),
  NebaWindowOs.windowsxp: _Chrome(
    bar: 30,
    radius: 8,
    radiusBottom: 0,
    padX: 6,
    padEnd: 4,
    gap: 2,
    title: 13,
    glyph: 9,
    weight: FontWeight.w700,
    frame: 1,
    band: (side: 4, bottom: 4),
    control: const Size(21, 21),
    closeWidth: 26,
    centred: false,
    controlsAtStart: false,
    shape: _Shape.plate,
    rule: false,
    stroke: 1.8,
    boxRadius: 3,
    tint: (0, 0),
    accentBorder: false,
    paint: (fill: const Color(0xFF1F66D6), ink: const Color(0xFFFFFFFF), dark: true),
    image: _down(<(Color, double)>[
      (_white(0.55), 0),
      (_white(0.26), 0.07),
      (_black(0.11), 0.42),
      (_black(0.05), 0.56),
      (_white(0.22), 0.76),
      (_white(0.34), 0.88),
      (_black(0.16), 0.96),
      (_black(0.34), 1),
    ]),
    shadows: <Shadow>[
      Shadow(offset: const Offset(0, 1), color: _black(0.45), blurRadius: shadowBlurRadius(1)),
    ],
  ),
  NebaWindowOs.linux: const _Chrome(
    bar: 44,
    radius: 12,
    radiusBottom: 12,
    padX: 10,
    padEnd: 10,
    gap: 6,
    title: 14,
    glyph: 10,
    weight: FontWeight.w600,
    frame: 1,
    band: (side: 0, bottom: 0),
    control: Size(24, 24),
    centred: true,
    controlsAtStart: false,
    shape: _Shape.circle,
    rule: false,
    stroke: 1.2,
    boxRadius: 0,
    tint: (11, 5),
    accentBorder: false,
  ),
};

/// `size` on a window: what it scales is the chrome, gently.
const Map<NebaSize, double> _scales = <NebaSize, double>{
  NebaSize.xs: 0.8,
  NebaSize.sm: 0.9,
  NebaSize.md: 1,
  NebaSize.lg: 1.15,
  NebaSize.xl: 1.3,
};

/// The lengths a [NebaWindowPane]'s chrome is laid out with, for one system
/// at one size.
@immutable
class NebaWindowMetrics {
  NebaWindowMetrics._(this._chrome, double scale)
    : bar = (_chrome.bar * scale).roundToDouble(),
      padX = (_chrome.padX * scale).roundToDouble(),
      padEnd = (_chrome.padEnd * scale).roundToDouble(),
      gap = (_chrome.gap * scale).roundToDouble(),
      title = (_chrome.title * scale).roundToDouble(),
      glyph = (_chrome.glyph * scale).roundToDouble(),
      control = Size(
        (_chrome.control.width * scale).roundToDouble(),
        (_chrome.control.height * scale).roundToDouble(),
      ),
      closeWidth = ((_chrome.closeWidth ?? _chrome.control.width) * scale).roundToDouble(),
      band = (
        side: (_chrome.band.side * scale).roundToDouble(),
        bottom: (_chrome.band.bottom * scale).roundToDouble(),
      );

  final _Chrome _chrome;

  /// The title bar's height.
  final double bar;

  /// The window's corner at the top, which `size` does not scale: it is the
  /// window's shape rather than a measure of its chrome.
  double get radius => _chrome.radius;

  /// And at the bottom, which the older systems leave square.
  double get radiusBottom => _chrome.radiusBottom;

  /// The hairline around the window.
  double get frame => _chrome.frame;

  /// The band of the system's colour down the sides and along the bottom, on
  /// XP and Aero.
  final ({double side, double bottom}) band;

  /// The air at the leading end of the bar.
  final double padX;

  /// And at the trailing end, which is nothing where the buttons run to it.
  final double padEnd;

  /// Between one control and the next.
  final double gap;

  /// The title's type size.
  final double title;

  /// The mark inside a control.
  final double glyph;

  /// One control's box.
  final Size control;

  /// The close button's width, which is wider on Aero and XP.
  final double closeWidth;

  /// How much room [count] controls take.
  double controlsWidth(int count) {
    if (count <= 0) {
      return 0;
    }

    final bool dots = _chrome.shape == _Shape.dot || _chrome.shape == _Shape.glossDot;
    final double one = dots ? control.height : control.width;
    final double close = dots ? control.height : closeWidth;

    return close + (count - 1) * one + (count - 1) * gap;
  }
}

/* ---------------------------------------------------------------------------
 * The colours
 * ------------------------------------------------------------------------- */

@immutable
class _Slots {
  const _Slots({
    required this.bar,
    required this.barInk,
    required this.body,
    required this.line,
    required this.band,
    required this.hover,
    required this.press,
    required this.ring,
    required this.elevation,
  });

  final Color bar;
  final Color barInk;
  final Color body;
  final Color line;
  final Color band;
  final Color hover;
  final Color press;
  final Color ring;
  final int elevation;
}

/// The traffic lights, which are hardware colours rather than tokens.
const Map<NebaWindowControl, Color> _trafficColours = <NebaWindowControl, Color>{
  NebaWindowControl.close: Color(0xFFFF5F57),
  NebaWindowControl.minimize: Color(0xFFFEBC2E),
  NebaWindowControl.maximize: Color(0xFF28C840),
};

/// XP's plates, the same three ideas at a different weight.
const Map<NebaWindowControl, Color> _plateColours = <NebaWindowControl, Color>{
  NebaWindowControl.close: Color(0xFFCF4B36),
  NebaWindowControl.minimize: Color(0xFF4B85D4),
  NebaWindowControl.maximize: Color(0xFF4B85D4),
};

/// What a system turns the close button when the pointer is on it.
const Map<NebaWindowOs, Color> _closeHover = <NebaWindowOs, Color>{
  NebaWindowOs.windows11: Color(0xFFC42B1C),
  NebaWindowOs.windows10: Color(0xFFE81123),
  NebaWindowOs.windows8: Color(0xFFE81123),
  NebaWindowOs.windows7: Color(0xFFE04A45),
};

/// The grey a painted bar washes out to behind the window in front.
const Color _washed = Color(0xFFC6C9CE);

_Slots _slotsOf({
  required NebaTokens tokens,
  required _Chrome chrome,
  required NebaColor color,
  required bool accent,
  required double transparency,
  required bool active,
  required int elevation,
}) {
  final NebaColorRoles roles = tokens.roles(color);
  final Color solid = roles.family.solid;

  // Mixed toward the backing, which is nothing at all unless the reader asked
  // for less transparency, when it is the page's surface.
  Color veil(Color colour) {
    return transparency <= 0 ? colour : mixOklab(colour, 1 - transparency, tokens.backing);
  }

  final double tint = active ? chrome.tint.$1 : chrome.tint.$2;
  final Color plain = tint == 0
      ? tokens.surface
      : mixOklab(tokens.surface, 1 - tint / 100, tokens.fg);
  final bool dyed = accent && active;
  final ({Color fill, Color ink, bool dark})? paint = chrome.paint;
  final Color? painted = paint == null
      ? null
      : active
      ? paint.fill
      : mixOklab(paint.fill, 0.45, _washed);
  final Color bar = dyed ? solid : painted ?? plain;
  final Color barInk = dyed
      ? roles.family.onSolid
      : paint != null
      ? active
            ? paint.ink
            : mixOklab(paint.ink, 0.6, transparent)
      : active
      ? tokens.fg
      : tokens.mutedFg;
  final bool banded = chrome.band.side > 0;
  final Color line = banded
      ? mixOklab(dyed ? solid : painted ?? tokens.border, 0.72, const Color(0xFF000000))
      : dyed && chrome.accentBorder
      ? solid
      : active
      ? tokens.border
      : mixOklab(tokens.border, 0.55, transparent);
  final bool onDark = dyed || (paint?.dark ?? false);

  return _Slots(
    bar: veil(bar),
    barInk: barInk,
    body: veil(tokens.surface),
    line: line,
    band: banded ? veil(dyed ? solid : painted ?? plain) : transparent,
    hover: onDark ? _white(0.18) : mixOklab(tokens.fg, 0.09, transparent),
    press: onDark ? _white(0.28) : mixOklab(tokens.fg, 0.16, transparent),
    ring: roles.ring,
    // The window in front sits a step further off the page than the ones
    // behind it, which is the whole of what "in front" looks like.
    elevation: active ? elevation : math.max(elevation - 1, 0),
  );
}

/* ---------------------------------------------------------------------------
 * Which window is in front
 * ------------------------------------------------------------------------- */

/// The windows that keep their own `active`, the one brought forward last at
/// the end, so the window before the front one comes forward when it closes.
final List<_NebaWindowPaneState> _attention = <_NebaWindowPaneState>[];

/* ---------------------------------------------------------------------------
 * The window
 * ------------------------------------------------------------------------- */

class _NebaWindowPaneState extends State<NebaWindowPane> {
  final GlobalKey _box = GlobalKey();
  final GlobalKey _controlsKey = GlobalKey();
  final GlobalKey _actionsKey = GlobalKey();
  final FocusNode _corner = FocusNode(debugLabel: 'NebaWindowPane resize');

  late bool _open = widget.defaultOpen;
  late bool _minimized = widget.defaultMinimized;
  late bool _maximized = widget.defaultMaximized;
  late Offset _offset = widget.defaultOffset;
  Size? _sized;
  bool _attended = true;
  bool _gesturing = false;
  bool _leaving = false;
  bool _cornerFocused = false;
  bool _hoveringControls = false;
  bool _controlsFocused = false;
  Duration? _lastTap;
  Timer? _leaveTimer;
  Offset? _lastTapAt;

  bool get _isOpen => widget.open ?? _open;
  bool get _isMinimized => widget.minimized ?? _minimized;
  bool get _isMaximized => widget.maximized ?? _maximized;
  Offset get _currentOffset => widget.offset ?? _offset;
  bool get _isActive => widget.active ?? _attended;

  @override
  void initState() {
    super.initState();
    _corner.addListener(_onCornerFocus);

    if (widget.active == null && _isOpen) {
      _attention.add(this);
    }
  }

  @override
  void didUpdateWidget(NebaWindowPane oldWidget) {
    super.didUpdateWidget(oldWidget);

    // A width or a height passed after a resize is the newest word on the
    // size.
    if (oldWidget.width != widget.width || oldWidget.height != widget.height) {
      _sized = null;
    }

    final bool wasOpen = oldWidget.open ?? _open;

    if (oldWidget.open != null && widget.open != null && wasOpen != widget.open) {
      _onOpenChanged(widget.open!);
    }

    _track();
  }

  @override
  void dispose() {
    _leaveTimer?.cancel();
    _leave();
    _corner
      ..removeListener(_onCornerFocus)
      ..dispose();
    super.dispose();
  }

  void _onCornerFocus() {
    if (_corner.hasFocus != _cornerFocused) {
      setState(() => _cornerFocused = _corner.hasFocus);
    }
  }

  /// Keeps this window in the list of the ones that decide their own front
  /// while it is open and nobody else decides it.
  void _track() {
    final bool tracked = widget.active == null && _isOpen;

    if (tracked && !_attention.contains(this)) {
      _attention.add(this);
    } else if (!tracked) {
      _leave();
    }
  }

  /// Out of the list, handing the front to the window before it if it held
  /// it.
  void _leave() {
    final int place = _attention.indexOf(this);

    if (place < 0) {
      return;
    }

    final bool wasFront = place == _attention.length - 1;

    _attention.removeAt(place);

    if (wasFront && _attention.isNotEmpty) {
      // After the frame, since a window leaves while the tree is being built.
      final _NebaWindowPaneState next = _attention.last;

      WidgetsBinding.instance.addPostFrameCallback((Duration _) => next._bring(true));
    }
  }

  void _bring(bool front) {
    if (mounted && _attended != front) {
      setState(() => _attended = front);
    }
  }

  /// A press or the focus inside this window brings it forward and sends
  /// every other one back. A press on the page around them changes nothing.
  void _attend() {
    if (widget.active != null) {
      return;
    }

    for (final _NebaWindowPaneState other in List<_NebaWindowPaneState>.of(_attention)) {
      if (other != this) {
        other._bring(false);
      }
    }

    _attention
      ..remove(this)
      ..add(this);
    _bring(true);
  }

  void _setOpen(bool next) {
    if (widget.open == null) {
      setState(() {
        _open = next;
        _onOpenChanged(next);
      });
    }

    widget.onOpenChange?.call(next);
  }

  /// Called while the state is being changed or rebuilt, so it sets what it
  /// sets without a rebuild of its own.
  void _onOpenChanged(bool open) {
    // Kept for as long as it takes to fade, out of reach, and then let go.
    _leaving = !open;
    _leaveTimer?.cancel();

    if (!open) {
      _leave();
      _leaveTimer = Timer(NebaScale.durationWindow + const Duration(milliseconds: 20), () {
        if (mounted && _leaving) {
          setState(() => _leaving = false);
        }
      });
    } else {
      _track();
    }
  }

  void _setMinimized(bool next) {
    if (widget.minimized == null) {
      setState(() => _minimized = next);
    }

    widget.onMinimizedChange?.call(next);
  }

  void _setMaximized(bool next) {
    if (widget.maximized == null) {
      setState(() => _maximized = next);
    }

    widget.onMaximizedChange?.call(next);
  }

  void _setOffset(Offset next) {
    if (widget.offset == null) {
      setState(() => _offset = next);
    }

    widget.onOffsetChange?.call(next);
  }

  void _command(NebaWindowControl control) {
    switch (control) {
      case NebaWindowControl.close:
        _setOpen(false);
      case NebaWindowControl.minimize:
        _setMinimized(!_isMinimized);
      case NebaWindowControl.maximize:
        _setMaximized(!_isMaximized);
    }
  }

  Size get _drawnSize {
    final RenderBox? box = _box.currentContext?.findRenderObject() as RenderBox?;

    return box?.hasSize ?? false ? box!.size : Size.zero;
  }

  /// Whether [global] is on a control or an action, which take their own
  /// presses rather than dragging or maximizing the window.
  bool _onOwnControl(Offset global) {
    for (final GlobalKey key in <GlobalKey>[_controlsKey, _actionsKey]) {
      final RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;

      if (box != null &&
          box.hasSize &&
          (Offset.zero & box.size).contains(box.globalToLocal(global))) {
        return true;
      }
    }

    return false;
  }

  void _onBarDown(PointerDownEvent event, bool canMaximize) {
    if (!canMaximize || _onOwnControl(event.position)) {
      _lastTap = null;

      return;
    }

    // A double click on the bar maximizes, as every one of these systems
    // does. Counted here rather than by a recognizer, which would hold every
    // single press on the buttons for the length of a double tap.
    final Duration? last = _lastTap;
    final Offset? at = _lastTapAt;

    if (last != null &&
        at != null &&
        event.timeStamp - last <= kDoubleTapTimeout &&
        (event.position - at).distance <= kDoubleTapSlop) {
      _lastTap = null;
      _setMaximized(!_isMaximized);

      return;
    }

    _lastTap = event.timeStamp;
    _lastTapAt = event.position;
  }

  @override
  Widget build(BuildContext context) {
    final bool open = _isOpen;

    if (!open && !_leaving) {
      return const SizedBox.shrink();
    }

    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaWindowOs os = widget.os ?? NebaWindowOs.macos;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaColor color = widget.color ?? NebaColor.primary;
    final _Chrome chrome = _chromes[os]!;
    final NebaWindowMetrics metrics = NebaWindowPane.metricsOf(os, size);
    final bool active = _isActive;
    final _Slots slots = _slotsOf(
      tokens: tokens,
      chrome: chrome,
      color: color,
      accent: widget.accent,
      transparency: widget.transparency,
      active: active,
      elevation: widget.elevation ?? 2,
    );
    final Map<String, String> words = nebaMessages(context, 'window', locale: widget.locale);
    final Map<String, String> actionWords = nebaMessages(context, 'action', locale: widget.locale);
    final List<NebaWindowControl> drawn = NebaWindowPane.orderOf(os, widget.controls);
    final bool canMaximize = drawn.contains(NebaWindowControl.maximize);
    final bool maximized = _isMaximized;
    final bool minimized = _isMinimized;
    final Duration travel = _gesturing
        ? Duration.zero
        : nebaDuration(context, NebaScale.durationWindow);
    final Map<NebaWindowControl, String> labels = <NebaWindowControl, String>{
      NebaWindowControl.minimize: widget.minimizeLabel ?? words['minimize']!,
      NebaWindowControl.maximize: maximized
          ? widget.restoreLabel ?? words['restore']!
          : widget.maximizeLabel ?? words['maximize']!,
      NebaWindowControl.close: widget.closeLabel ?? actionWords['close']!,
    };
    final Widget? title = widget.title;

    final Widget controls = drawn.isEmpty
        ? const SizedBox.shrink()
        : _Controls(
            key: _controlsKey,
            os: os,
            chrome: chrome,
            metrics: metrics,
            controls: drawn,
            maximized: maximized,
            active: active,
            slots: slots,
            labels: labels,
            glyphsShown:
                _hoveringControls || (_controlsFocused && !NebaInputModality.pointer.value),
            onHover: (bool hovering) => setState(() => _hoveringControls = hovering),
            onFocus: (bool focused) => setState(() => _controlsFocused = focused),
            onCommand: _command,
          );

    final Widget? mark = widget.icon == null
        ? null
        : IconTheme.merge(
            data: IconThemeData(color: slots.barInk, size: metrics.title * 1.2),
            child: widget.icon!,
          );
    final Widget? named = title == null
        ? null
        : DefaultTextStyle.merge(
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            child: title,
          );
    final List<Widget> nameRow = <Widget>[?mark, if (named != null) Flexible(child: named)];

    Widget bar = Row(
      children: <Widget>[
        if (chrome.controlsAtStart) controls,
        if (chrome.centred)
          const Spacer()
        else ...<Widget>[
          if (chrome.controlsAtStart && drawn.isNotEmpty) SizedBox(width: metrics.gap),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: (metrics.title * 0.5).roundToDouble(),
                children: nameRow,
              ),
            ),
          ),
        ],
        if (widget.actions != null)
          Padding(
            padding: EdgeInsetsDirectional.only(end: (metrics.title * 0.7).roundToDouble()),
            child: KeyedSubtree(key: _actionsKey, child: widget.actions!),
          ),
        if (!chrome.controlsAtStart) controls,
      ],
    );

    if (chrome.centred) {
      // Centred over the window rather than over what is left of the bar,
      // with the room the controls take kept clear on both sides.
      bar = Stack(
        children: <Widget>[
          Positioned.fill(
            child: IgnorePointer(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: metrics.controlsWidth(drawn.length) + metrics.padX * 2,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: (metrics.title * 0.5).roundToDouble(),
                    children: nameRow,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(child: bar),
        ],
      );
    }

    bar = Container(
      height: metrics.bar,
      decoration: BoxDecoration(
        color: slots.bar,
        // Windows 10 is the one system that rules its bar off from the body.
        border: chrome.rule ? Border(bottom: BorderSide(color: slots.line)) : null,
      ),
      child: CustomPaint(
        painter: _BarPainter(image: chrome.image, stripes: chrome.stripes),
        child: Padding(
          padding: EdgeInsetsDirectional.only(start: metrics.padX, end: metrics.padEnd),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: metrics.title,
              fontWeight: chrome.weight,
              color: slots.barInk,
              height: 1.2,
              shadows: chrome.shadows,
            ),
            child: bar,
          ),
        ),
      ),
    );

    final bool dragsBar = widget.draggable && !maximized;

    bar = Listener(
      onPointerDown: (PointerDownEvent event) => _onBarDown(event, canMaximize),
      child: bar,
    );

    if (dragsBar) {
      bar = _BarDrag(position: widget.position, owner: this, metrics: metrics, child: bar);
    }

    final bool banded = metrics.band.side > 0;
    final BorderRadius radius = maximized
        ? BorderRadius.zero
        : BorderRadius.vertical(
            top: Radius.circular(metrics.radius),
            bottom: Radius.circular(metrics.radiusBottom),
          );
    final bool resizes = widget.resizable && !maximized && !minimized;

    // The window at a height, which a maximized one only knows once it is
    // laid out in what holds it.
    Widget windowAt(double? outerHeight) {
      final double? bodyHeight = outerHeight == null
          ? null
          : math.max(0, outerHeight - metrics.bar - metrics.frame * 2 - metrics.band.bottom);

      // The body: the caller's content on the window's own fill, sunk into
      // the band on the systems that have one.
      Widget body = widget.child ?? const SizedBox.shrink();

      if (bodyHeight != null) {
        final Widget content = body;

        body = widget.scroll
            ? LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SingleChildScrollView(
                    primary: false,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: content,
                    ),
                  );
                },
              )
            : ClipRect(child: content);
        body = SizedBox(height: bodyHeight, child: body);
      }

      body = Container(
        color: slots.body,
        foregroundDecoration: banded
            ? BoxDecoration(border: Border.all(color: _black(0.12)))
            : null,
        child: body,
      );

      body = Padding(
        padding: EdgeInsets.only(
          left: metrics.band.side,
          right: metrics.band.side,
          bottom: metrics.band.bottom,
        ),
        child: body,
      );

      body = TweenAnimationBuilder<double>(
        tween: Tween<double>(end: minimized ? 0 : 1),
        duration: travel,
        curve: NebaScale.ease,
        builder: (BuildContext context, double shown, Widget? child) {
          return ClipRect(
            child: Align(
              alignment: AlignmentDirectional.topStart,
              heightFactor: shown,
              child: child,
            ),
          );
        },
        // A body that is rolled away is still built, so rolling it back is a
        // journey rather than a cut, and out of reach while it is away.
        child: ExcludeFocus(
          excluding: minimized,
          child: ExcludeSemantics(
            excluding: minimized,
            child: IgnorePointer(ignoring: minimized, child: body),
          ),
        ),
      );

      Widget window = Container(
        decoration: BoxDecoration(
          border: Border.all(color: slots.line, width: metrics.frame),
          borderRadius: radius,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[bar, body],
        ),
      );

      window = NebaSheet(
        key: _box,
        fill: slots.band,
        plate: NebaPlate.glass,
        elevation: slots.elevation,
        borderRadius: radius,
        blur: widget.transparency > 0 || chrome.glass,
        texture: false,
        child: window,
      );

      if (resizes) {
        window = Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            window,
            ..._handles(
              metrics: metrics,
              label: widget.resizeLabel ?? words['resize']!,
              hint: words['resizeHint']!,
              ring: slots.ring,
            ),
          ],
        );
      }

      window = NebaHitArea(
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          label: widget.semanticLabel ?? (title is Text ? title.data : null),
          child: Listener(
            onPointerDown: (PointerDownEvent event) => _attend(),
            child: Focus(
              canRequestFocus: false,
              skipTraversal: true,
              onFocusChange: (bool focused) {
                if (focused) {
                  _attend();
                }
              },
              child: window,
            ),
          ),
        ),
      );

      // Nothing in a window on its way out can be pressed or reached.
      return AnimatedOpacity(
        opacity: open ? 1 : 0,
        duration: nebaDuration(context, NebaScale.durationWindow),
        curve: NebaScale.ease,
        child: ExcludeFocus(
          excluding: !open,
          child: ExcludeSemantics(
            excluding: !open,
            child: IgnorePointer(ignoring: !open, child: window),
          ),
        ),
      );
    }

    return _place(windowAt, travel);
  }

  /// The box what holds the window gives it, read during layout.
  Size? _container;

  Widget _place(Widget Function(double? outerHeight) windowAt, Duration travel) {
    final bool maximized = _isMaximized;

    Widget geometry(Size? box) {
      _container = box;

      final double? boxWidth = box != null && box.width.isFinite ? box.width : null;
      final double? boxHeight = box != null && box.height.isFinite ? box.height : null;
      final Offset offset = maximized ? Offset.zero : _currentOffset;
      final double? width = maximized ? boxWidth : _sized?.width ?? widget.width;
      final double? height = maximized ? boxHeight : _sized?.height ?? widget.height;
      // A window placed in a stack with no width is as wide as what is in it.
      final bool shrinks = widget.position != NebaWindowPanePosition.static;

      return TweenAnimationBuilder<Offset>(
        tween: Tween<Offset>(end: offset),
        duration: travel,
        curve: NebaScale.ease,
        builder: (BuildContext context, Offset at, Widget? _) {
          return TweenAnimationBuilder<double>(
            tween: _MaybeTween(width),
            duration: travel,
            curve: NebaScale.ease,
            builder: (BuildContext context, double across, Widget? _) {
              return TweenAnimationBuilder<double>(
                tween: _MaybeTween(height),
                duration: travel,
                curve: NebaScale.ease,
                builder: (BuildContext context, double down, Widget? _) {
                  final Widget window = windowAt(down < 0 ? null : down);
                  // A width of its own is kept in the flow as a block keeps
                  // one, at the start of the line.
                  final Widget sized = across >= 0
                      ? shrinks
                            ? SizedBox(width: across, child: window)
                            : Align(
                                alignment: AlignmentDirectional.topStart,
                                heightFactor: 1,
                                child: SizedBox(width: across, child: window),
                              )
                      : shrinks
                      ? IntrinsicWidth(child: window)
                      : window;

                  return _Shifted(offset: at, child: sized);
                },
              );
            },
          );
        },
      );
    }

    switch (widget.position) {
      case NebaWindowPanePosition.static:
        return maximized
            ? LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return geometry(constraints.biggest);
                },
              )
            : geometry(null);
      case NebaWindowPanePosition.absolute:
        return Positioned.fill(child: _stage(geometry));
      case NebaWindowPanePosition.fixed:
        return NebaPortal(child: _stage(geometry));
    }
  }

  /// The box a window placed against something is laid out in, with the
  /// window at its top start corner, moved from there by its offset.
  Widget _stage(Widget Function(Size box) geometry) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[Positioned(left: 0, top: 0, child: geometry(constraints.biggest))],
        );
      },
    );
  }

  /// The box a drag of the title bar keeps the window inside, or `null` for a
  /// window in the flow, which goes wherever it is dragged.
  Size? get _dragBox {
    return widget.position == NebaWindowPanePosition.static ? null : _container;
  }

  void _beginGesture() {
    setState(() => _gesturing = true);
  }

  void _endGesture() {
    if (mounted) {
      setState(() => _gesturing = false);
    }
  }

  void _resizeTo(Size next) {
    setState(() => _sized = next);
    widget.onResize?.call(next);
  }

  Size _floor(NebaWindowMetrics metrics) {
    return Size(
      math.max(0, widget.minWidth),
      math.max(metrics.bar, widget.minHeight ?? metrics.bar),
    );
  }

  Size _resizeFrom = Size.zero;
  Offset _resizeAt = Offset.zero;

  List<Widget> _handles({
    required NebaWindowMetrics metrics,
    required String label,
    required String hint,
    required Color ring,
  }) {
    Widget handle(String edge, {required Widget Function(Widget) place}) {
      final bool east = edge.contains('e');
      final bool west = edge.contains('w');
      final bool north = edge.contains('n');
      final bool south = edge.contains('s');
      final MouseCursor cursor = switch (edge) {
        'n' || 's' => SystemMouseCursors.resizeUpDown,
        'e' || 'w' => SystemMouseCursors.resizeLeftRight,
        'nw' || 'se' => SystemMouseCursors.resizeUpLeftDownRight,
        _ => SystemMouseCursors.resizeUpRightDownLeft,
      };
      Widget region = NebaDragRegion(
        cursor: cursor,
        onStart: (Offset position) {
          _resizeFrom = _drawnSize;
          _resizeAt = _currentOffset;
          _beginGesture();

          return true;
        },
        onMove: (Offset delta) {
          final Size from = _resizeFrom;
          final Offset at = _resizeAt;
          final Size floor = _floor(metrics);
          double width = from.width;
          double height = from.height;
          double x = at.dx;
          double y = at.dy;

          if (east) {
            width = math.max(floor.width, from.width + delta.dx);
          }

          if (south) {
            height = math.max(floor.height, from.height + delta.dy);
          }

          // A leading edge moves the window as it resizes it, by as much as
          // the clamped size changed, so a window held at its minimum stops
          // rather than sliding out from under the pointer.
          if (west) {
            width = math.max(floor.width, from.width - delta.dx);
            x = at.dx + (from.width - width);
          }

          if (north) {
            height = math.max(floor.height, from.height - delta.dy);
            y = at.dy + (from.height - height);
          }

          _resizeTo(Size(width, height));

          if (west || north) {
            _setOffset(Offset(x, y));
          }
        },
        onEnd: _endGesture,
        builder: (BuildContext context, bool dragging) => const SizedBox.expand(),
      );

      if (edge == 'se') {
        // The one handle a keyboard reaches: the corner that changes both
        // axes at once.
        region = Semantics(
          button: true,
          label: label,
          hint: hint,
          child: Focus(
            focusNode: _corner,
            onKeyEvent: (FocusNode node, KeyEvent event) {
              if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
                return KeyEventResult.ignored;
              }

              final Offset? step = switch (event.logicalKey) {
                LogicalKeyboardKey.arrowRight => const Offset(NebaWindowPane.keyboardStep, 0),
                LogicalKeyboardKey.arrowLeft => const Offset(-NebaWindowPane.keyboardStep, 0),
                LogicalKeyboardKey.arrowDown => const Offset(0, NebaWindowPane.keyboardStep),
                LogicalKeyboardKey.arrowUp => const Offset(0, -NebaWindowPane.keyboardStep),
                _ => null,
              };

              if (step == null) {
                return KeyEventResult.ignored;
              }

              // The size the last key gave it, which the next key may arrive
              // before a frame has laid out.
              final Size drawn = _sized ?? _drawnSize;
              final Size floor = _floor(metrics);

              _resizeTo(
                Size(
                  math.max(floor.width, drawn.width + step.dx),
                  math.max(floor.height, drawn.height + step.dy),
                ),
              );

              return KeyEventResult.handled;
            },
            child: NebaFocusRing(
              visible: _cornerFocused,
              color: ring,
              offset: -focusRingWidth,
              child: NebaHitTarget(child: region),
            ),
          ),
        );
      } else {
        region = ExcludeSemantics(child: region);
      }

      return place(region);
    }

    return <Widget>[
      handle(
        'n',
        place: (Widget c) => Positioned(left: 12, right: 12, top: 0, height: 6, child: c),
      ),
      handle(
        's',
        place: (Widget c) => Positioned(left: 12, right: 12, bottom: 0, height: 6, child: c),
      ),
      handle(
        'w',
        place: (Widget c) => Positioned(top: 12, bottom: 12, left: 0, width: 6, child: c),
      ),
      handle(
        'e',
        place: (Widget c) => Positioned(top: 12, bottom: 12, right: 0, width: 6, child: c),
      ),
      handle(
        'nw',
        place: (Widget c) => Positioned(top: 0, left: 0, width: 12, height: 12, child: c),
      ),
      handle(
        'ne',
        place: (Widget c) => Positioned(top: 0, right: 0, width: 12, height: 12, child: c),
      ),
      handle(
        'sw',
        place: (Widget c) => Positioned(bottom: 0, left: 0, width: 12, height: 12, child: c),
      ),
      handle(
        'se',
        place: (Widget c) => Positioned(bottom: 0, right: 0, width: 12, height: 12, child: c),
      ),
    ];
  }
}

/// The title bar as a handle that drags the window.
class _BarDrag extends StatefulWidget {
  const _BarDrag({
    required this.position,
    required this.owner,
    required this.metrics,
    required this.child,
  });

  final NebaWindowPanePosition position;
  final _NebaWindowPaneState owner;
  final NebaWindowMetrics metrics;
  final Widget child;

  @override
  State<_BarDrag> createState() => _BarDragState();
}

class _BarDragState extends State<_BarDrag> {
  Offset _from = Offset.zero;
  Size? _box;
  double _span = 0;

  @override
  Widget build(BuildContext context) {
    final _NebaWindowPaneState owner = widget.owner;

    return NebaDragRegion(
      eager: false,
      cursor: SystemMouseCursors.grab,
      onStart: (Offset position) {
        final RenderBox? box = context.findRenderObject() as RenderBox?;

        if (box != null && owner._onOwnControl(box.localToGlobal(position))) {
          return false;
        }

        _from = owner._currentOffset;
        // A window placed against something is kept where its bar can be
        // grabbed again: inside the box, with a strip of it inside either
        // side.
        _box = owner._dragBox;
        _span = owner._drawnSize.width;
        owner._beginGesture();

        return true;
      },
      onMove: (Offset delta) {
        final Size? box = _box;
        final double x = _from.dx + delta.dx;
        final double y = _from.dy + delta.dy;

        if (box == null) {
          owner._setOffset(Offset(x, y));

          return;
        }

        final double grip = math.min(_span, 48);

        owner._setOffset(
          Offset(
            x.clamp(grip - _span, math.max(grip - _span, box.width - grip)),
            y.clamp(0, math.max(0, box.height - widget.metrics.bar)),
          ),
        );
      },
      onEnd: owner._endGesture,
      builder: (BuildContext context, bool dragging) => widget.child,
    );
  }
}

/// A tween between two lengths either of which may be `-1`, a length the
/// content decides: from or to one, the tween is at its end at once, as CSS
/// cannot travel from `auto` either.
class _MaybeTween extends Tween<double> {
  _MaybeTween(double? end) : super(end: end ?? -1);

  @override
  double lerp(double t) {
    final double a = begin!;
    final double b = end!;

    if (a < 0 || b < 0) {
      return b;
    }

    return a + (b - a) * t;
  }
}

/// Its child laid out where it is and drawn [offset] from there, as a
/// relatively positioned box is: moved without moving anything around it,
/// and pressed where it is drawn.
class _Shifted extends SingleChildRenderObjectWidget {
  const _Shifted({required this.offset, super.child});

  final Offset offset;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderShifted(offset);

  @override
  void updateRenderObject(BuildContext context, _RenderShifted renderObject) {
    renderObject.offset = offset;
  }
}

class _RenderShifted extends RenderProxyBox {
  _RenderShifted(this._offset);

  Offset _offset;

  set offset(Offset value) {
    if (value != _offset) {
      _offset = value;
      markNeedsPaint();
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    return result.addWithPaintOffset(
      offset: _offset,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        return child?.hitTest(result, position: transformed) ?? false;
      },
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child!, offset + _offset);
    }
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.translateByDouble(_offset.dx, _offset.dy, 0, 1);
  }

  @override
  Rect get paintBounds => (Offset.zero & size).shift(_offset);
}

/// What a system lays over its bar's colour: a gradient, and Aqua's
/// pinstripes.
class _BarPainter extends CustomPainter {
  const _BarPainter({required this.image, required this.stripes});

  final Gradient? image;
  final bool stripes;

  @override
  void paint(Canvas canvas, Size size) {
    // The padding is the bar's own, and the image covers the whole bar.
    final Rect rect = Offset.zero & size;

    if (stripes) {
      final Paint light = Paint()..color = _white(0.55);
      final Paint dark = Paint()..color = _black(0.035);

      for (double y = 0; y < size.height; y += 2) {
        canvas
          ..drawRect(Rect.fromLTWH(rect.left, y, rect.width, 1), light)
          ..drawRect(Rect.fromLTWH(rect.left, y + 1, rect.width, 1), dark);
      }
    }

    final Gradient? image = this.image;

    if (image != null) {
      canvas.drawRect(rect, Paint()..shader = image.createShader(rect));
    }
  }

  @override
  bool shouldRepaint(_BarPainter oldDelegate) {
    return oldDelegate.image != image || oldDelegate.stripes != stripes;
  }
}

/* ---------------------------------------------------------------------------
 * The buttons
 * ------------------------------------------------------------------------- */

class _Controls extends StatelessWidget {
  const _Controls({
    required this.os,
    required this.chrome,
    required this.metrics,
    required this.controls,
    required this.maximized,
    required this.active,
    required this.slots,
    required this.labels,
    required this.glyphsShown,
    required this.onHover,
    required this.onFocus,
    required this.onCommand,
    super.key,
  });

  final NebaWindowOs os;
  final _Chrome chrome;
  final NebaWindowMetrics metrics;
  final List<NebaWindowControl> controls;
  final bool maximized;
  final bool active;
  final _Slots slots;
  final Map<NebaWindowControl, String> labels;
  final bool glyphsShown;
  final ValueChanged<bool> onHover;
  final ValueChanged<bool> onFocus;
  final ValueChanged<NebaWindowControl> onCommand;

  @override
  Widget build(BuildContext context) {
    final bool dots = chrome.shape == _Shape.dot || chrome.shape == _Shape.glossDot;
    // On a screen with no pointer to hover, the traffic lights keep their
    // glyphs, or the three are told apart only by colour.
    final bool touch = switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.fuchsia => true,
      _ => false,
    };

    Widget row = MouseRegion(
      onEnter: (PointerEnterEvent event) => onHover(true),
      onExit: (PointerExitEvent event) => onHover(false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: chrome.shape == _Shape.aero
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        spacing: metrics.gap,
        children: <Widget>[
          for (final NebaWindowControl control in controls)
            _Control(
              os: os,
              chrome: chrome,
              metrics: metrics,
              control: control,
              maximized: maximized,
              active: active,
              slots: slots,
              label: labels[control]!,
              glyphShown: !dots || glyphsShown || touch,
              onPressed: () => onCommand(control),
            ),
        ],
      ),
    );

    row = Focus(canRequestFocus: false, skipTraversal: true, onFocusChange: onFocus, child: row);

    // Aero's buttons hang off the top edge of the window rather than sitting
    // in the middle of the bar.
    return chrome.shape == _Shape.aero
        ? SizedBox(
            height: metrics.bar,
            child: Align(alignment: Alignment.topCenter, widthFactor: 1, child: row),
          )
        : row;
  }
}

Color _brighter(Color colour, double factor) {
  return Color.from(
    alpha: colour.a,
    red: (colour.r * factor).clamp(0, 1),
    green: (colour.g * factor).clamp(0, 1),
    blue: (colour.b * factor).clamp(0, 1),
  );
}

class _Control extends StatelessWidget {
  const _Control({
    required this.os,
    required this.chrome,
    required this.metrics,
    required this.control,
    required this.maximized,
    required this.active,
    required this.slots,
    required this.label,
    required this.glyphShown,
    required this.onPressed,
  });

  final NebaWindowOs os;
  final _Chrome chrome;
  final NebaWindowMetrics metrics;
  final NebaWindowControl control;
  final bool maximized;
  final bool active;
  final _Slots slots;
  final String label;
  final bool glyphShown;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final _Shape shape = chrome.shape;
    final bool dots = shape == _Shape.dot || shape == _Shape.glossDot;
    final bool round = dots || shape == _Shape.circle;
    final Color? danger = control == NebaWindowControl.close ? _closeHover[os] : null;
    final double width = dots
        ? metrics.control.height
        : control == NebaWindowControl.close
        ? metrics.closeWidth
        : metrics.control.width;
    final BorderRadius corners = switch (shape) {
      _Shape.dot || _Shape.glossDot || _Shape.circle => BorderRadius.circular(width),
      _Shape.plate => BorderRadius.circular(chrome.boxRadius + 1),
      _Shape.aero => const BorderRadius.vertical(bottom: Radius.circular(3)),
      _Shape.square => BorderRadius.zero,
    };

    Widget button = NebaInteractive(
      onTap: onPressed,
      builder: (BuildContext context, NebaInteraction state, ValueListenable<Offset?> _) {
        final bool lit = state.hovered || state.pressed;
        final (Color? face, Color? ink, Gradient? image, List<BoxShadow> plate) = _face(
          shape: shape,
          lit: lit,
          pressed: state.pressed,
          danger: danger,
        );

        return NebaFocusRing(
          visible: state.focusVisible,
          color: slots.ring,
          offset: -focusRingWidth,
          borderRadius: corners,
          child: AnimatedContainer(
            duration: nebaDuration(context, NebaScale.duration, instant: state.pressed),
            curve: NebaScale.ease,
            width: width,
            height: metrics.control.height,
            decoration: BoxDecoration(
              color: face ?? transparent,
              gradient: image,
              borderRadius: corners,
              boxShadow: plate,
            ),
            alignment: Alignment.center,
            child: AnimatedOpacity(
              // The glyph is an affordance on macOS rather than a state: it
              // stays out of the way of a window that is only being looked
              // at.
              opacity: glyphShown ? 1 : 0,
              duration: nebaDuration(context, NebaScale.duration),
              child: CustomPaint(
                size: Size.square(metrics.glyph),
                painter: _GlyphPainter(
                  control: control,
                  maximized: maximized,
                  chrome: chrome,
                  color: ink ?? slots.barInk,
                  round: chrome.boxRadius > 0 || shape != _Shape.square,
                ),
              ),
            ),
          ),
        );
      },
    );

    if (round && dots) {
      button = NebaHitTarget(child: button);
    }

    return Semantics(container: true, button: true, label: label, child: button);
  }

  (Color?, Color?, Gradient?, List<BoxShadow>) _face({
    required _Shape shape,
    required bool lit,
    required bool pressed,
    required Color? danger,
  }) {
    switch (shape) {
      case _Shape.dot:
      case _Shape.glossDot:
        final bool gloss = shape == _Shape.glossDot;

        return (
          active ? _trafficColours[control]! : mixOklab(slots.barInk, 0.22, transparent),
          _black(0.55),
          gloss
              ? RadialGradient(
                  center: const Alignment(0, -0.48),
                  radius: 0.62,
                  colors: <Color>[_white(0.8), _white(0)],
                )
              : null,
          gloss
              ? <BoxShadow>[
                  BoxShadow(color: _black(0.22), spreadRadius: -0.5, blurStyle: BlurStyle.inner),
                ]
              : const <BoxShadow>[],
        );
      case _Shape.plate:
        final Color base = active
            ? _plateColours[control]!
            : mixOklab(_plateColours[control]!, 0.45, _washed);

        return (
          pressed
              ? _brighter(base, 0.95)
              : lit
              ? _brighter(base, 1.1)
              : base,
          const Color(0xFFFFFFFF),
          _down(<(Color, double)>[(_white(0.5), 0), (_white(0.05), 0.55), (_black(0.14), 1)]),
          const <BoxShadow>[],
        );
      case _Shape.aero:
        if (danger != null && lit) {
          return (danger, const Color(0xFFFFFFFF), null, const <BoxShadow>[]);
        }

        final Color face = _white(0.3);

        return (
          pressed
              ? _brighter(face, 0.95)
              : lit
              ? _brighter(face, 1.1)
              : face,
          null,
          _down(<(Color, double)>[(_white(0.6), 0), (_white(0.08), 0.52), (_white(0.3), 1)]),
          const <BoxShadow>[],
        );
      case _Shape.circle:
        return (lit ? slots.press : slots.hover, null, null, const <BoxShadow>[]);
      case _Shape.square:
        if (danger != null && lit) {
          return (danger, const Color(0xFFFFFFFF), null, const <BoxShadow>[]);
        }

        return (
          pressed
              ? slots.press
              : lit
              ? slots.hover
              : null,
          null,
          null,
          const <BoxShadow>[],
        );
    }
  }
}

/// A control's mark, drawn on a 10-unit grid: a line, a box, two boxes or a
/// cross, at the system's weight and with its corner.
class _GlyphPainter extends CustomPainter {
  const _GlyphPainter({
    required this.control,
    required this.maximized,
    required this.chrome,
    required this.color,
    required this.round,
  });

  final NebaWindowControl control;
  final bool maximized;
  final _Chrome chrome;
  final Color color;
  final bool round;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.width / 10;
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = chrome.stroke * unit
      ..strokeCap = round ? StrokeCap.round : StrokeCap.square
      ..strokeJoin = round ? StrokeJoin.round : StrokeJoin.miter;
    final double r = chrome.boxRadius * unit;

    Offset at(double x, double y) => Offset(x * unit, y * unit);

    switch (control) {
      case NebaWindowControl.minimize:
        // On a plate the mark sits low in it, where every one of them drew
        // it.
        if (chrome.shape == _Shape.plate) {
          canvas.drawLine(at(2, 7.5), at(8, 7.5), stroke);
        } else {
          canvas.drawLine(at(1.5, 5), at(8.5, 5), stroke);
        }
      case NebaWindowControl.close:
        canvas
          ..drawLine(at(1.6, 1.6), at(8.4, 8.4), stroke)
          ..drawLine(at(8.4, 1.6), at(1.6, 8.4), stroke);
      case NebaWindowControl.maximize:
        if (maximized) {
          // Restore: two boxes, one behind the other.
          canvas
            ..drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(1.4 * unit, 3.4 * unit, 5.2 * unit, 5.2 * unit),
                Radius.circular(r),
              ),
              stroke,
            )
            ..drawPath(
              Path()
                ..moveTo(3.6 * unit, 3.4 * unit)
                ..lineTo(3.6 * unit, 1.4 * unit)
                ..lineTo(8.6 * unit, 1.4 * unit)
                ..lineTo(8.6 * unit, 6.4 * unit)
                ..lineTo(6.6 * unit, 6.4 * unit),
              stroke,
            );
        } else {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(1.5 * unit, 1.5 * unit, 7 * unit, 7 * unit),
              Radius.circular(r),
            ),
            stroke,
          );
        }
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter oldDelegate) {
    return oldDelegate.control != control ||
        oldDelegate.maximized != maximized ||
        oldDelegate.chrome != chrome ||
        oldDelegate.color != color ||
        oldDelegate.round != round;
  }
}
