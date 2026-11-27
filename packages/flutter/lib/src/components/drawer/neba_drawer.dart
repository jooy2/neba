/// `NebaDrawer`, a panel attached to one edge of the window.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/modal.dart';
import 'package:neba/src/internal/sheet_close.dart';
import 'package:neba/src/internal/sheet_sections.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// How a [NebaDrawer] relates to the page.
enum NebaDrawerMode {
  /// It is opened, it floats over the page on a scrim, it holds the focus,
  /// and it is dismissed: the navigation behind a menu button, the filters
  /// beside a table.
  overlay,

  /// It is part of the layout, and the page is laid out around it: no scrim,
  /// no overlay, no focus held, nothing to dismiss. The sidebar that is simply
  /// there.
  inline,
}

/// Builds what opens a [NebaDrawer], handed the callback that opens it.
typedef NebaDrawerTriggerBuilder = Widget Function(BuildContext context, VoidCallback open);

/// Builds a control that closes the [NebaDrawer] it is inside, handed the
/// callback that closes it.
typedef NebaDrawerCloseBuilder = Widget Function(BuildContext context, VoidCallback close);

/// A panel attached to one edge of the window: [side].
///
/// Two things in one widget, because they are the same panel. In
/// [NebaDrawerMode.overlay] it is the drawer that is opened: it comes in from
/// its edge over a scrim in the app's root [Overlay], holds the focus, closes
/// on Escape and on a press on the scrim, and gives the focus back to what had
/// it. In [NebaDrawerMode.inline] the same panel is part of the layout, and
/// [open] says whether it is in the layout at all.
///
/// The sections are arguments rather than children: a [title], a
/// [description] under it and the × beside them, the body ([child]), which is
/// the only part that scrolls, and the [actions] held against the foot of the
/// panel. An overlay drawer needs an [Overlay] above it, which a `WidgetsApp`
/// with a navigator has and `Overlay.wrap` gives anything else.
///
/// ```dart
/// NebaDrawer(
///   title: const Text('Workspace'),
///   triggerBuilder: (BuildContext context, VoidCallback open) =>
///       NebaButton(onPressed: open, child: const Text('Open navigation')),
///   child: navigation,
/// )
/// ```
class NebaDrawer extends StatefulWidget {
  /// A drawer holding [child] as its body.
  const NebaDrawer({
    this.side = NebaSide.left,
    this.mode = NebaDrawerMode.overlay,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.open,
    this.defaultOpen,
    this.onOpenChange,
    this.triggerBuilder,
    this.title,
    this.headingLevel = 2,
    this.description,
    this.actions,
    this.dividers = false,
    this.showClose,
    this.locale,
    this.closeLabel,
    this.extent,
    this.rounded = true,
    this.modal = NebaModal.on,
    this.dismissible = true,
    this.safeArea = true,
    this.keepMounted = false,
    this.semanticLabel,
    this.child,
    super.key,
  }) : assert(headingLevel >= 1 && headingLevel <= 6),
       assert(extent == null || extent >= 0);

  /// Which edge of the window the panel is attached to. Physical, as
  /// [NebaSide] is everywhere: a drawer along the top is along the top in
  /// every writing direction.
  final NebaSide side;

  /// Whether it floats over the page or is part of it.
  final NebaDrawerMode mode;

  /// The type of every section, the padding, the corners and a side panel's
  /// default width. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the hairline on the free edge, the dividers and the focus
  /// rings. The sheet itself stays undyed.
  final NebaColor color;

  /// How much padding each section has at its [size]. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// Whether the drawer is shown, for a controlled drawer that hears about
  /// every change through [onOpenChange]. In [NebaDrawerMode.inline] it is
  /// whether the panel is in the layout.
  final bool? open;

  /// Whether an uncontrolled drawer starts open: `false` in
  /// [NebaDrawerMode.overlay] and `true` in [NebaDrawerMode.inline], because
  /// a fixed sidebar that had to be opened would not be fixed.
  final bool? defaultOpen;

  /// Called with the new state when the drawer opens or closes: from the
  /// trigger, the ×, a [NebaDrawerClose], Escape or the scrim.
  final ValueChanged<bool>? onOpenChange;

  /// Builds what opens the drawer, which stays where the drawer was written.
  /// Overlay only: an inline drawer is in the layout and has nothing to open.
  final NebaDrawerTriggerBuilder? triggerBuilder;

  /// The heading, usually a [Text], one step above the body in semibold. It is
  /// the heading a screen reader hears at [headingLevel], and the name of an
  /// overlay drawer.
  final Widget? title;

  /// Which heading the [title] is, `1` to `6`. An inline drawer is part of the
  /// page, so its heading is too: one beside the page's first heading wants
  /// `2`. An overlay drawer starts an outline of its own.
  final int headingLevel;

  /// A line under the title, in the muted ink one step down the type scale.
  final Widget? description;

  /// The bottom row, held against the foot of the panel while the body
  /// scrolls, end-aligned and wrapping when it runs out of room. A
  /// [NebaDrawerClose] makes one of them close the drawer.
  final List<Widget>? actions;

  /// Draws a hairline between the header, the body and the actions instead of
  /// separating them with space, which is what says the header stayed put
  /// while the body scrolls.
  final bool dividers;

  /// Shows the × beside the title. On in [NebaDrawerMode.overlay] and off in
  /// [NebaDrawerMode.inline], where a × that closes a fixed sidebar with
  /// nothing to reopen it would be a one-way door.
  final bool? showClose;

  /// The language the × is named in. Defaults to `NebaProvider`'s, then the
  /// app's.
  final Locale? locale;

  /// What a screen reader hears for the ×. Defaults to the [locale]'s
  /// "Close".
  final String? closeLabel;

  /// How far the panel reaches in from its edge, in logical pixels: a width
  /// for [NebaSide.left] and [NebaSide.right], a height for [NebaSide.top] and
  /// [NebaSide.bottom]. Left out, a side panel takes the width its [size]
  /// implies and a top or bottom one is as tall as what is in it, up to 85% of
  /// the window.
  final double? extent;

  /// Rounds the two corners on the edge that faces the page. The corners
  /// against the window's edge are always square.
  final bool rounded;

  /// How much of the page an overlay drawer takes away.
  final NebaModal modal;

  /// Whether Escape and a press on the scrim close an overlay drawer. A drawer
  /// that is not needs [actions] that close it, because there is no other way
  /// out.
  final bool dismissible;

  /// Keeps an overlay drawer's contents clear of the system's insets on the
  /// edges the panel runs to: the status bar, a notch, the home indicator.
  /// The sheet still reaches the edge of the screen; what moves is what is on
  /// it.
  final bool safeArea;

  /// Keeps a closed drawer built, offstage and out of the focus order and the
  /// semantics tree, so what is in it keeps its state from one opening to the
  /// next.
  final bool keepMounted;

  /// The name a screen reader announces for a drawer with no [title]: React's
  /// `aria-label`.
  final String? semanticLabel;

  /// The body: the only part that scrolls.
  final Widget? child;

  /// A side panel's default width at each size, the React package's
  /// `extentClasses`: narrower than a dialog at every step, because a drawer
  /// is measured by how much of the window it takes from what it is beside.
  static const Map<NebaSize, double> extents = <NebaSize, double>{
    NebaSize.xs: 224,
    NebaSize.sm: 256,
    NebaSize.md: 320,
    NebaSize.lg: 384,
    NebaSize.xl: 448,
  };

  /// What is left of a top or bottom panel's height for the rest of the
  /// window, when it is as tall as what is in it.
  static const double maxCoverage = 0.85;

  /// The room above and below the body of a drawer without dividers, the
  /// React package's `sheetScrollRoomClasses`: a scroll view clips what is
  /// drawn past it, so the body keeps room inside for a focus ring and a
  /// floated label and takes it back from the space around it.
  static const Map<NebaSize, (double, double)> scrollRoom = NebaSheetSections.scrollRoom;

  @override
  State<NebaDrawer> createState() => _NebaDrawerState();
}

class _NebaDrawerState extends State<NebaDrawer> {
  late bool _ownOpen = widget.defaultOpen ?? widget.mode == NebaDrawerMode.inline;

  bool get _overlay => widget.mode == NebaDrawerMode.overlay;

  bool get _open => widget.open ?? _ownOpen;

  void _setOpen(bool next) {
    // A second press on the × while the panel is on its way out says nothing
    // new.
    if (next == _open) {
      return;
    }

    if (widget.open == null) {
      setState(() => _ownOpen = next);
    }

    widget.onOpenChange?.call(next);
  }

  void _show() => _setOpen(true);

  void _close() => _setOpen(false);

  @override
  Widget build(BuildContext context) {
    if (!_overlay) {
      return _DrawerScope(close: _close, child: _inline(context));
    }

    final NebaDrawerTriggerBuilder? trigger = widget.triggerBuilder;

    return _DrawerScope(
      close: _close,
      child: NebaModalLayer(
        open: _open,
        onDismiss: _close,
        modal: widget.modal,
        dismissible: widget.dismissible,
        keepMounted: widget.keepMounted,
        label: widget.semanticLabel,
        builder: _arriving,
        child: trigger == null
            ? null
            : Builder(builder: (BuildContext context) => trigger(context, _show)),
      ),
    );
  }

  Widget _inline(BuildContext context) {
    // An inline drawer is in the flow, so closed is out of the layout. Kept
    // built, it is still out of it, offstage.
    if (!_open && !widget.keepMounted) {
      return const SizedBox.shrink();
    }

    final Widget panel = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool along = widget.side == NebaSide.left || widget.side == NebaSide.right;
        final NebaSize size = _size(context);

        if (along) {
          final double width = math.min(
            widget.extent ?? NebaDrawer.extents[size]!,
            constraints.maxWidth,
          );

          return SizedBox(
            width: width,
            height: constraints.hasBoundedHeight ? constraints.maxHeight : null,
            child: _panel(
              context,
              fill: constraints.hasBoundedHeight,
              bounded: constraints.hasBoundedHeight,
              insets: EdgeInsets.zero,
            ),
          );
        }

        final double? extent = widget.extent;
        final double cap = constraints.hasBoundedHeight
            ? constraints.maxHeight * NebaDrawer.maxCoverage
            : double.infinity;

        return SizedBox(
          width: constraints.hasBoundedWidth ? constraints.maxWidth : null,
          height: extent == null ? null : math.min(extent, constraints.maxHeight),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: extent == null ? cap : double.infinity),
            child: _panel(
              context,
              fill: extent != null,
              bounded: extent != null || constraints.hasBoundedHeight,
              insets: EdgeInsets.zero,
            ),
          ),
        );
      },
    );

    // One shape open or closed, so a kept drawer keeps what is in it.
    return Offstage(
      offstage: !_open,
      child: ExcludeFocus(
        excluding: !_open,
        child: TickerMode(enabled: _open, child: panel),
      ),
    );
  }

  /// The overlay drawer, travelling in from its edge as it arrives.
  Widget _arriving(BuildContext context, Animation<double> arrival) {
    final Size window = MediaQuery.sizeOf(context);
    final NebaSize size = _size(context);
    final NebaSide side = widget.side;
    final bool along = side == NebaSide.left || side == NebaSide.right;
    final EdgeInsets screen = widget.safeArea ? nebaModalMedia(context).padding : EdgeInsets.zero;
    // The insets of the three edges the panel runs to. The one it faces the
    // page with is never one of them.
    final EdgeInsets insets = switch (side) {
      NebaSide.left => screen.copyWith(right: 0),
      NebaSide.right => screen.copyWith(left: 0),
      NebaSide.top => screen.copyWith(bottom: 0),
      NebaSide.bottom => screen.copyWith(top: 0),
    };

    final Widget sized;

    if (along) {
      sized = SizedBox(
        width: math.min(widget.extent ?? NebaDrawer.extents[size]!, window.width),
        height: double.infinity,
        child: _panel(context, fill: true, insets: insets),
      );
    } else {
      final double? extent = widget.extent;

      sized = SizedBox(
        width: double.infinity,
        height: extent == null ? null : math.min(extent, window.height),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: extent == null ? window.height * NebaDrawer.maxCoverage : double.infinity,
          ),
          child: _panel(context, fill: extent != null, insets: insets),
        ),
      );
    }

    // Off the screen until it opens, by its own size, so it never has to know
    // how wide it was made.
    final Offset away = switch (side) {
      NebaSide.left => const Offset(-1, 0),
      NebaSide.right => const Offset(1, 0),
      NebaSide.top => const Offset(0, -1),
      NebaSide.bottom => const Offset(0, 1),
    };
    final Alignment edge = switch (side) {
      NebaSide.left => Alignment.centerLeft,
      NebaSide.right => Alignment.centerRight,
      NebaSide.top => Alignment.topCenter,
      NebaSide.bottom => Alignment.bottomCenter,
    };

    return Align(
      alignment: edge,
      child: AnimatedBuilder(
        animation: arrival,
        builder: (BuildContext context, Widget? panel) {
          return FractionalTranslation(translation: away * (1 - arrival.value), child: panel);
        },
        child: sized,
      ),
    );
  }

  NebaSize _size(BuildContext context) {
    return widget.size ?? NebaTheme.defaultsOf(context).size ?? NebaSize.md;
  }

  /// The sheet and its sections. [fill] is whether the panel has a height of
  /// its own, which the body then takes what is left of; [bounded] is whether
  /// it has a ceiling, which the body otherwise scrolls under; [insets] is the
  /// room kept for the system's insets.
  Widget _panel(
    BuildContext context, {
    required bool fill,
    required EdgeInsets insets,
    bool bounded = true,
  }) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = _size(context);
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColorRoles roles = tokens.roles(widget.color);
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final bool showClose = widget.showClose ?? _overlay;

    final Widget content = NebaSheetSections(
      size: size,
      density: density,
      color: widget.color,
      title: widget.title,
      headingLevel: widget.headingLevel,
      namesRoute: _overlay,
      description: widget.description,
      close: showClose
          ? NebaSheetClose(
              onPressed: _close,
              label:
                  widget.closeLabel ??
                  nebaMessages(context, 'action', locale: widget.locale)['close']!,
              em: scaler.scale(NebaScale.sheetBodyText[size]!),
              color: widget.color,
            )
          : null,
      actions: widget.actions ?? const <Widget>[],
      dividers: widget.dividers,
      fill: fill,
      bounded: bounded,
      insets: insets,
      child: widget.child,
    );

    final Radius corner = Radius.circular(widget.rounded ? tokens.radius[size]! : 0);
    final BorderRadius radius = switch (widget.side) {
      NebaSide.left => BorderRadius.horizontal(right: corner),
      NebaSide.right => BorderRadius.horizontal(left: corner),
      NebaSide.top => BorderRadius.vertical(bottom: corner),
      NebaSide.bottom => BorderRadius.vertical(top: corner),
    };
    // The hairline on the free edge only: one all round would draw a line
    // along the window's own edge, with nothing on the other side of it.
    final EdgeInsets edge = switch (widget.side) {
      NebaSide.left => const EdgeInsets.only(right: 1),
      NebaSide.right => const EdgeInsets.only(left: 1),
      NebaSide.top => const EdgeInsets.only(bottom: 1),
      NebaSide.bottom => const EdgeInsets.only(top: 1),
    };

    return NebaSheet(
      fill: tokens.panelPress,
      plate: NebaPlate.glass,
      elevation: _overlay ? 3 : 0,
      borderRadius: radius,
      child: CustomPaint(
        foregroundPainter: _FreeEdgePainter(
          side: widget.side,
          color: roles.line,
          borderRadius: radius,
        ),
        // A border takes its pixel, so what is on the sheet stops inside it.
        child: Padding(padding: edge, child: content),
      ),
    );
  }
}

/// The 1-pixel edge along the side a panel faces the page with, following the
/// two corners at its ends.
class _FreeEdgePainter extends CustomPainter {
  const _FreeEdgePainter({required this.side, required this.color, required this.borderRadius});

  final NebaSide side;
  final Color color;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect shape = borderRadius.toRRect(Offset.zero & size);
    final double reach = math.max(
      1,
      math.max(
        math.max(shape.tlRadiusX, shape.trRadiusX),
        math.max(shape.blRadiusY, shape.brRadiusY),
      ),
    );
    // The outline inside the sheet, cut down to the free edge and the corners
    // at its two ends.
    final Rect keep = switch (side) {
      NebaSide.left => Rect.fromLTRB(size.width - reach, 0, size.width, size.height),
      NebaSide.right => Rect.fromLTRB(0, 0, reach, size.height),
      NebaSide.top => Rect.fromLTRB(0, size.height - reach, size.width, size.height),
      NebaSide.bottom => Rect.fromLTRB(0, 0, size.width, reach),
    };

    canvas.save();
    canvas.clipRect(keep);
    strokeInside(canvas, shape, color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FreeEdgePainter oldDelegate) {
    return oldDelegate.side != side ||
        oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius;
  }
}

/// What a [NebaDrawerClose] closes.
class _DrawerScope extends InheritedWidget {
  const _DrawerScope({required this.close, required super.child});

  final VoidCallback close;

  @override
  bool updateShouldNotify(_DrawerScope oldWidget) => close != oldWidget.close;
}

/// A control that closes the [NebaDrawer] it is inside: the React package's
/// `DrawerClose`.
///
/// [builder] is handed the callback that closes it, so a Cancel button in an
/// uncontrolled drawer's [NebaDrawer.actions] needs no state of its own:
///
/// ```dart
/// NebaDrawerClose(
///   builder: (BuildContext context, VoidCallback close) =>
///       NebaButton(onPressed: close, child: const Text('Cancel')),
/// )
/// ```
///
/// Outside a drawer the callback does nothing.
class NebaDrawerClose extends StatelessWidget {
  /// A control built by [builder].
  const NebaDrawerClose({required this.builder, super.key});

  /// Builds the control.
  final NebaDrawerCloseBuilder builder;

  @override
  Widget build(BuildContext context) {
    final _DrawerScope? scope = context.dependOnInheritedWidgetOfExactType<_DrawerScope>();

    return builder(context, scope?.close ?? _nothing);
  }

  static void _nothing() {}
}
