/// `NebaFloatingBottomNavigation`, a row of an app's main destinations
/// floating clear of the bottom edge.
library;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/bottom_navigation/neba_bottom_navigation.dart';
import 'package:neba/src/components/floating_action_button/neba_floating_action_button.dart';
import 'package:neba/src/internal/bottom_navigation.dart';
import 'package:neba/src/internal/pin.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/internal/tile.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Where a floating bar sits: the four values a floating button takes, which
/// the React package spells as two types of the same shape.
typedef NebaFloatingBottomNavigationPosition = NebaFloatingActionButtonPosition;

/// A row of an app's main destinations floating clear of the bottom edge,
/// generic over the type of a destination's `value`.
///
/// It is `NebaBottomNavigation` lifted off the page: the same navigation
/// region, the same `NebaBottomNavigationItem` children, each a button or a
/// link of its own, and the current one heard as selected. What differs is the
/// shape, and everything about the shape follows from [offset]. Because the
/// page goes on underneath, the sheet is a stadium as wide as its destinations
/// rather than a bar across the screen, it carries a shadow, and by default it
/// names only the destination the reader is on.
///
/// The current destination's highlight is the bar's own, a tile behind the
/// destinations that slides to the next one by its rectangle when the
/// selection moves, while the name that leaves narrows to nothing and the one
/// that arrives widens to its own width on the same clock.
///
/// With [position] anything but static, the bar takes the whole of the space
/// it is laid out in and floats at the bottom of it, so it goes in a `Stack`
/// over the screen or the region it belongs to:
///
/// ```dart
/// Stack(
///   children: <Widget>[
///     page,
///     NebaFloatingBottomNavigation<String>(
///       label: 'Main',
///       value: section,
///       onValueChange: (String next) => setState(() => section = next),
///       children: const <NebaBottomNavigationItem<String>>[
///         NebaBottomNavigationItem<String>(value: 'home', icon: homeIcon, child: Text('Home')),
///         NebaBottomNavigationItem<String>(value: 'search', icon: searchIcon, child: Text('Search')),
///       ],
///     ),
///   ],
/// )
/// ```
class NebaFloatingBottomNavigation<T> extends StatefulWidget {
  /// A floating bar of [children], one of which may be current.
  const NebaFloatingBottomNavigation({
    required this.children,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.position = NebaFloatingBottomNavigationPosition.fixed,
    this.offset = 16,
    this.labels = NebaBottomNavigationLabels.selected,
    this.safeArea = true,
    this.disabled = false,
    this.label,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       ),
       assert(offset >= 0);

  /// The destinations, each named by its `value`: the same item a
  /// `NebaBottomNavigation` takes.
  final List<NebaBottomNavigationItem<T>> children;

  /// The destination the reader is on, for a controlled bar. Leave it `null`
  /// and the bar keeps its own state, starting from [defaultValue].
  final T? value;

  /// Which destination starts current, for an uncontrolled bar.
  final T? defaultValue;

  /// Called with the value of the destination that was pressed, the current
  /// one included.
  final ValueChanged<T>? onValueChange;

  /// The sheet's weight, said the way a container says it: `outline`, the
  /// default, with a hairline that separates it from what passes underneath,
  /// `solid` the brighter panel, `text` no sheet at all. Defaults to
  /// `NebaProvider`'s, then [NebaVariant.outline].
  final NebaVariant? variant;

  /// The bar's floor and the scale of the glyphs and the names, the ladder
  /// `NebaBottomNavigation` is on: `md` is 56 logical pixels. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family the current destination is drawn in, and the hairline's.
  /// Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// The room inside the sheet and beside each name. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`. Defaults to `2`: a bar floating flat
  /// over the content it floats over reads as a mistake.
  final NebaElevation? elevation;

  /// Where the bar sits. Anything but static floats it at the bottom of the
  /// space it is laid out in, centred; static puts it in the flow, centred.
  final NebaFloatingBottomNavigationPosition position;

  /// How far the bar floats above the bottom edge, in logical pixels: the
  /// whole difference between this bar and `NebaBottomNavigation`.
  final double offset;

  /// Which names are drawn. [NebaBottomNavigationLabels.selected] by default,
  /// because the bar is only as wide as what is in it and five drawn names
  /// would stretch it back into a bar.
  final NebaBottomNavigationLabels labels;

  /// On a fixed or sticky bar, adds the bottom system inset to [offset], so
  /// the bar clears a phone's home indicator. The whole sheet moves up: there
  /// is nothing under it to keep covered.
  final bool safeArea;

  /// Every destination stops answering.
  final bool disabled;

  /// The name a screen reader announces for the bar: "Main", "Sections".
  final String? label;

  /// The room inside the sheet, around the row: tighter than the full-width
  /// bar's, because the current destination's tile is a stadium of its own
  /// and the gap between it and the sheet's edge is this padding.
  static const Map<NebaDensity, Map<NebaSize, double>> padding =
      <NebaDensity, Map<NebaSize, double>>{
        NebaDensity.standard: <NebaSize, double>{
          NebaSize.xs: 4,
          NebaSize.sm: 4,
          NebaSize.md: 6,
          NebaSize.lg: 6,
          NebaSize.xl: 8,
        },
        NebaDensity.compact: <NebaSize, double>{
          NebaSize.xs: 2,
          NebaSize.sm: 2,
          NebaSize.md: 4,
          NebaSize.lg: 4,
          NebaSize.xl: 4,
        },
      };

  /// Between one destination and the next.
  static const Map<NebaSize, double> gap = <NebaSize, double>{
    NebaSize.xs: 2,
    NebaSize.sm: 2,
    NebaSize.md: 4,
    NebaSize.lg: 4,
    NebaSize.xl: 6,
  };

  @override
  State<NebaFloatingBottomNavigation<T>> createState() => _NebaFloatingBottomNavigationState<T>();
}

class _NebaFloatingBottomNavigationState<T> extends State<NebaFloatingBottomNavigation<T>> {
  late T? _value = widget.defaultValue;

  /// The stadium the sheet, the tile and every destination are cut to.
  static const BorderRadius _round = BorderRadius.all(Radius.circular(9999));

  T? get _current => widget.value ?? _value;

  void _choose(T value) {
    if (widget.disabled) {
      return;
    }

    if (widget.value == null) {
      setState(() => _value = value);
    }

    widget.onValueChange?.call(value);
  }

  /// The index of the destination carrying [value], or `null` when none does,
  /// which takes the tile away rather than leaving it where the last one was.
  int? _indexOf(T? value) {
    if (value == null) {
      return null;
    }

    for (int i = 0; i < widget.children.length; i++) {
      if (widget.children[i].value == value) {
        return i;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaColor color = widget.color ?? NebaColor.primary;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaElevation elevation = widget.elevation ?? 2;
    final NebaColorRoles roles = tokens.roles(color);
    final int? chosen = _indexOf(_current);
    final List<NebaBottomNavigationItem<T>> items = widget.children;

    // The highlight is the bar's rather than the current destination's, which
    // is the whole of why it can travel: a destination painting its own fill
    // could only switch it on and off.
    final Widget tile = switch (variant) {
      NebaVariant.solid => NebaSheet(
        fill: tokens.panelHover,
        plate: NebaPlate.glass,
        elevation: 1,
        borderRadius: _round,
      ),
      NebaVariant.outline => NebaSheet(
        fill: roles.softHover,
        plate: NebaPlate.glass,
        elevation: 1,
        borderRadius: _round,
      ),
      NebaVariant.text => NebaSheet(
        fill: roles.softHover,
        plate: NebaPlate.none,
        borderRadius: _round,
        blur: false,
        texture: false,
      ),
    };

    Widget bar = NebaTileRun(
      current: chosen,
      spacing: NebaFloatingBottomNavigation.gap[size]!,
      tile: tile,
      children: <Widget>[
        for (int i = 0; i < items.length; i++)
          NebaBottomNavigationSlot(
            // The item's own key, one level up, so a reordered bar keeps each
            // destination's state with it, and the tile follows it.
            key: items[i].key == null ? null : ValueKey<Key>(items[i].key!),
            selected: i == chosen,
            onChoose: () => _choose(items[i].value),
            size: size,
            density: density,
            color: color,
            labels: widget.labels,
            disabled: widget.disabled,
            floating: true,
            child: items[i],
          ),
      ],
    );

    bar = Padding(
      padding: EdgeInsets.all(NebaFloatingBottomNavigation.padding[density]![size]!),
      child: Center(widthFactor: 1, heightFactor: 1, child: bar),
    );

    bar = DefaultTextStyle.merge(
      style: TextStyle(color: tokens.fg),
      child: bar,
    );

    bar = switch (variant) {
      NebaVariant.solid => NebaSheet(
        fill: tokens.panelPress,
        elevation: elevation,
        borderRadius: _round,
        child: bar,
      ),
      NebaVariant.outline => NebaSheet(
        fill: tokens.panelHover,
        edge: roles.line,
        plate: NebaPlate.glass,
        elevation: elevation,
        borderRadius: _round,
        child: bar,
      ),
      NebaVariant.text => bar,
    };

    bar = Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.navigation,
      label: widget.label,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: nebaBarMinHeight[size]!),
        child: bar,
      ),
    );

    if (widget.position == NebaFloatingBottomNavigationPosition.static) {
      return Center(heightFactor: 1, child: bar);
    }

    return NebaPin(
      alignment: AlignmentDirectional.bottomCenter,
      offset: widget.offset,
      safeArea:
          widget.safeArea &&
          (widget.position == NebaFloatingBottomNavigationPosition.fixed ||
              widget.position == NebaFloatingBottomNavigationPosition.sticky),
      child: bar,
    );
  }
}
