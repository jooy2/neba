/// `NebaBottomNavigation` and `NebaBottomNavigationItem`, a row of an app's
/// main destinations along the bottom edge.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/bottom_navigation.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/link.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/internal/text_marks.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

export 'package:neba/src/internal/bottom_navigation.dart' show NebaBottomNavigationLabels;

/// A row of an app's main destinations along the bottom edge, generic over
/// the type of a destination's `value`.
///
/// It is navigation rather than a tab bar: each destination is a button of
/// its own in the focus order, or a link when it has an `href`, and the one
/// the reader is on is heard as selected. A tab bar would owe a keyboard
/// reader one stop for the set and the arrow keys inside it, and a panel for
/// each tab; a bottom navigation changes what the screen is.
///
/// The sheet is never dyed: what carries the colour family is the current
/// destination. Its [position] says how it is drawn: [NebaPosition.static] is
/// a sheet in the flow with corners and, `outline`, a hairline all round,
/// while [NebaPosition.sticky] and [NebaPosition.fixed] are square, draw only
/// the hairline facing the content, and keep the destinations clear of the
/// system insets with the sheet still running under them. Where the bar goes
/// is its parent's: the bottom of a screen's `Column`, or a `NebaPageLayout`'s
/// `footer`, which holds a bar that is not static at the bottom of the page.
///
/// ```dart
/// NebaBottomNavigation<String>(
///   label: 'Main',
///   value: section,
///   onValueChange: (String next) => setState(() => section = next),
///   children: const <NebaBottomNavigationItem<String>>[
///     NebaBottomNavigationItem<String>(value: 'home', icon: homeIcon, child: Text('Home')),
///     NebaBottomNavigationItem<String>(value: 'search', icon: searchIcon, child: Text('Search')),
///   ],
/// )
/// ```
class NebaBottomNavigation<T> extends StatefulWidget {
  /// A bar of [children], one of which may be current.
  const NebaBottomNavigation({
    required this.children,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.position = NebaPosition.fixed,
    this.labels = NebaBottomNavigationLabels.all,
    this.divider = true,
    this.safeArea = true,
    this.disabled = false,
    this.label,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The destinations, each named by its `value`.
  final List<NebaBottomNavigationItem<T>> children;

  /// The destination the reader is on, for a controlled bar. Leave it `null`
  /// and the bar keeps its own state, starting from [defaultValue].
  final T? value;

  /// Which destination starts current, for an uncontrolled bar.
  final T? defaultValue;

  /// Called with the value of the destination that was pressed, the current
  /// one included.
  final ValueChanged<T>? onValueChange;

  /// The sheet's weight, said the way a container says it: `solid` the
  /// brighter panel, `outline` the lighter one, `text` no sheet at all.
  /// Defaults to `NebaProvider`'s, then [NebaVariant.outline].
  final NebaVariant? variant;

  /// The bar's floor and the scale of the glyphs and the names: `md` is 56
  /// logical pixels. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family the current destination is drawn in, and the hairlines'.
  /// Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// The room around the row of destinations. Defaults to `NebaProvider`'s,
  /// then [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0`, the default, to `3`: the bar is attached to
  /// the edge rather than floating over it, and [divider] is what separates
  /// it from the content.
  final NebaElevation? elevation;

  /// How the bar sits: [NebaPosition.fixed], the default, and
  /// [NebaPosition.sticky] against the bottom edge, square and clear of the
  /// system insets; [NebaPosition.static] as a sheet in the flow. A
  /// `NebaPageLayout` holds a bar it was handed as its `footer` at the bottom
  /// of the page unless it is static.
  final NebaPosition position;

  /// Which names are drawn.
  final NebaBottomNavigationLabels labels;

  /// Draws a hairline along the top edge, against the content the bar is
  /// over.
  final bool divider;

  /// Keeps the destinations clear of the system insets on the bottom and the
  /// two sides, where the home indicator and a notch are, while the sheet
  /// still runs under them. A static bar is not against the edge of the
  /// screen, so it is left alone.
  final bool safeArea;

  /// Every destination stops answering.
  final bool disabled;

  /// The name a screen reader announces for the bar: "Main", "Sections".
  final String? label;

  /// The room inside the sheet, around the row.
  static const Map<NebaDensity, Map<NebaSize, double>> padding =
      <NebaDensity, Map<NebaSize, double>>{
        NebaDensity.standard: <NebaSize, double>{
          NebaSize.xs: 4,
          NebaSize.sm: 4,
          NebaSize.md: 6,
          NebaSize.lg: 8,
          NebaSize.xl: 10,
        },
        NebaDensity.compact: <NebaSize, double>{
          NebaSize.xs: 2,
          NebaSize.sm: 2,
          NebaSize.md: 4,
          NebaSize.lg: 4,
          NebaSize.xl: 6,
        },
      };

  @override
  State<NebaBottomNavigation<T>> createState() => _NebaBottomNavigationState<T>();
}

class _NebaBottomNavigationState<T> extends State<NebaBottomNavigation<T>> {
  late T? _value = widget.defaultValue;

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

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaColor color = widget.color ?? NebaColor.primary;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaElevation elevation = widget.elevation ?? 0;
    final NebaColorRoles roles = tokens.roles(color);
    final bool inFlow = widget.position == NebaPosition.static;
    final T? current = _current;
    final List<NebaBottomNavigationItem<T>> items = widget.children;

    Widget bar = ConstrainedBox(
      constraints: BoxConstraints(minHeight: nebaBarMinHeight[size]!),
      child: Padding(
        padding: EdgeInsets.all(NebaBottomNavigation.padding[density]![size]!),
        // Every destination as tall as the tallest, so a highlight reaches
        // the same line on each, as a CSS row stretches its items.
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final NebaBottomNavigationItem<T> item in items)
                Expanded(
                  // The item's own key, one level up, so a reordered bar keeps
                  // each destination's state with it.
                  key: item.key == null ? null : ValueKey<Key>(item.key!),
                  child: NebaBottomNavigationSlot(
                    selected: current != null && item.value == current,
                    onChoose: () => _choose(item.value),
                    size: size,
                    density: density,
                    color: color,
                    labels: widget.labels,
                    disabled: widget.disabled,
                    floating: false,
                    child: item,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (widget.safeArea && !inFlow) {
      // The sheet keeps reaching the edge of the screen; what the insets move
      // is the row on it.
      final EdgeInsets screen = MediaQuery.paddingOf(context);
      bar = Padding(
        padding: EdgeInsets.only(left: screen.left, right: screen.right, bottom: screen.bottom),
        child: bar,
      );
    }

    // In the flow an outline bar is an ordinary sheet with a hairline all
    // round. Against the edge, three of its sides face the screen's and only
    // the one facing the content is drawn.
    final bool outlined = variant == NebaVariant.outline && inFlow;

    if (widget.divider && !outlined) {
      // A Container, because it adds the line's width to the bar as a CSS
      // border does.
      bar = Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: roles.line)),
        ),
        child: bar,
      );
    }

    // Only a bar in the flow has corners: one against the edge has nothing
    // behind them.
    final BorderRadius radius = inFlow
        ? BorderRadius.circular(tokens.radius[size]!)
        : BorderRadius.zero;

    bar = DefaultTextStyle.merge(
      style: TextStyle(color: tokens.fg),
      child: bar,
    );

    final Widget sheet = switch (variant) {
      NebaVariant.solid => NebaSheet(
        fill: tokens.panelHover,
        elevation: elevation,
        borderRadius: radius,
        child: bar,
      ),
      NebaVariant.outline => NebaSheet(
        fill: tokens.panel,
        edge: outlined ? roles.line : null,
        plate: NebaPlate.glass,
        elevation: elevation,
        borderRadius: radius,
        child: bar,
      ),
      NebaVariant.text => ClipRRect(borderRadius: radius, child: bar),
    };

    return Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.navigation,
      label: widget.label,
      child: SizedBox(width: double.infinity, child: sheet),
    );
  }
}

/// One destination in a `NebaBottomNavigation` or a
/// `NebaFloatingBottomNavigation`: a glyph with its name under it.
///
/// It has no `size`, `color` or `variant` of its own: all three belong to the
/// bar, which is the only place they can be set once and mean the same thing
/// for every destination.
///
/// The package opens nothing itself, so a destination that leads somewhere is
/// a callback: the bar's `onValueChange` and the item's [onPressed] call the
/// router, and [href] tells a screen reader, and on the web the browser, where
/// it goes. With an [href] the item is a link and without one a button.
class NebaBottomNavigationItem<T> extends StatelessWidget {
  /// A destination named [value].
  const NebaBottomNavigationItem({
    required this.value,
    this.child,
    this.icon,
    this.href,
    this.newTab = false,
    this.disabled = false,
    this.onPressed,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// What names the destination, and what the bar's `onValueChange` reports
  /// when it is pressed.
  final T value;

  /// The destination's name, usually a [Text]. A [Text]'s words are what a
  /// screen reader hears, even where the bar's `labels` leaves the name
  /// undrawn; any other widget needs a [semanticLabel] for that.
  final Widget? child;

  /// The glyph above the name, sized on the icon ladder through the
  /// [IconTheme] the item hands down.
  final Widget? icon;

  /// Where the destination leads, for a screen reader and, on the web, the
  /// browser. It makes the item a link; following it is [onPressed]'s or the
  /// bar's `onValueChange`'s. A scheme other than `http`, `https`, `mailto`
  /// or `tel` is not written.
  final Uri? href;

  /// Whether the link leaves the app. A screen reader hears "(opens in a new
  /// tab)" after the name; opening the tab is [onPressed]'s.
  final bool newTab;

  /// Unavailable, but still part of the set: drawn in the disabled ink and
  /// out of the focus order.
  final bool disabled;

  /// Called when the destination is pressed, after the bar has made it
  /// current.
  final VoidCallback? onPressed;

  /// What a screen reader hears as the destination's name, in place of
  /// [child]'s words.
  final String? semanticLabel;

  /// The destination's focus node.
  final FocusNode? focusNode;

  /// Whether the destination takes the focus when it is first built.
  final bool autofocus;

  /// Between the glyph and the name under it.
  static const Map<NebaSize, double> gap = <NebaSize, double>{
    NebaSize.xs: 2,
    NebaSize.sm: 2,
    NebaSize.md: 4,
    NebaSize.lg: 4,
    NebaSize.xl: 6,
  };

  /// The fully round shape a floating bar cuts its destinations to.
  static const BorderRadius _round = BorderRadius.all(Radius.circular(9999));

  @override
  Widget build(BuildContext context) {
    final NebaBottomNavigationSlot? found = NebaBottomNavigationSlot.maybeOf(context);

    assert(() {
      if (found == null) {
        throw FlutterError(
          'A NebaBottomNavigationItem was built outside a bottom bar.\n'
          'A destination draws itself from the bar it is in, so it has to be one '
          "of a NebaBottomNavigation's or a NebaFloatingBottomNavigation's children.",
        );
      }
      return true;
    }());

    final NebaBottomNavigationSlot bar = found!;
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaColorRoles roles = tokens.roles(bar.color);
    final NebaSize size = bar.size;
    final bool off = disabled || bar.disabled;
    final bool selected = bar.selected;
    final bool floating = bar.floating;
    final NebaBottomNavigationLabels labels = bar.labels;
    final bool named =
        labels == NebaBottomNavigationLabels.all ||
        (labels == NebaBottomNavigationLabels.selected && selected);

    final Uri? link = nebaSafeHref(href);
    final Widget? child = this.child;
    final String? words = semanticLabel ?? (child is Text ? nebaSpanOf(child).toPlainText() : null);
    final String? note = newTab ? nebaMessages(context, 'link')['newTab'] : null;
    final String? name = words == null || note == null ? words : '$words $note';
    final BorderRadius radius = floating ? _round : BorderRadius.circular(tokens.radius[size]!);
    final double iconSize = NebaScale.iconSize[size]!;

    Widget? label;

    if (child != null && labels != NebaBottomNavigationLabels.none) {
      // The name is heard on the destination itself, so what is drawn is
      // only pixels; a widget with no words of its own keeps its semantics.
      final Widget drawn = ExcludeSemantics(excluding: name != null, child: child);

      if (floating && labels == NebaBottomNavigationLabels.selected) {
        label = _Arriving(shown: named, child: drawn);
      } else if (named) {
        label = drawn;
      } else {
        // Laid out and not drawn, so every destination keeps the line a name
        // takes and no glyph moves as the selection does.
        label = Opacity(opacity: 0, alwaysIncludeSemantics: true, child: drawn);
      }
    }

    final Widget body = NebaInteractive(
      enabled: !off,
      onTap: () {
        bar.onChoose();
        onPressed?.call();
      },
      focusNode: focusNode,
      autofocus: autofocus,
      activatesOnSpace: link == null,
      cursor: off ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
        final bool hovered = interaction.hovered && !off;
        final Color ink = off
            ? tokens.disabledFg
            : selected
            ? roles.onTint
            : hovered
            ? tokens.fg
            : tokens.mutedFg;
        // On a floating bar the current destination's highlight is the bar's
        // own and is already under it; a second fill here would be two fills
        // travelling at different speeds.
        final Color fill = off
            ? edgeless
            : selected
            ? (floating
                  ? edgeless
                  : hovered
                  ? roles.softHover
                  : roles.soft)
            : hovered
            ? tokens.panelHover
            : edgeless;

        return NebaFocusRing(
          visible: interaction.focusVisible,
          color: roles.ring,
          borderRadius: radius,
          offset: -focusRingWidth,
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: fill),
            duration: nebaDuration(context, NebaScale.durationFill),
            curve: NebaScale.ease,
            builder: (BuildContext context, Color? fill, Widget? child) {
              return DecoratedBox(
                decoration: BoxDecoration(color: fill, borderRadius: radius),
                child: child,
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: floating ? NebaScale.paddingX[bar.density]![size]! : 4,
                vertical: 6,
              ),
              child: NebaInk(
                color: ink,
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: NebaScale.metaText[size],
                    height: 1.25,
                    fontWeight: selected && !off ? FontWeight.w500 : null,
                  ),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: gap[size]!,
                    children: <Widget>[
                      if (icon != null)
                        IconTheme.merge(
                          data: IconThemeData(size: iconSize),
                          child: SizedBox.square(
                            dimension: iconSize,
                            child: Center(child: icon),
                          ),
                        ),
                      ?label,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    return Semantics(
      container: true,
      button: link == null,
      link: link != null,
      linkUrl: off ? null : link,
      selected: selected ? true : null,
      enabled: !off,
      label: name,
      child: body,
    );
  }
}

/// A name that travels between no width and its own as it arrives or leaves,
/// fading as it goes, while it keeps its line, so the destination it is on
/// never changes height.
class _Arriving extends StatelessWidget {
  const _Arriving({required this.shown, required this.child});

  final bool shown;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: shown ? 1 : 0),
      duration: nebaDuration(context, NebaScale.duration),
      curve: NebaScale.ease,
      builder: (BuildContext context, double t, Widget? child) {
        return ClipRect(
          child: Align(
            widthFactor: t,
            child: Opacity(opacity: t, alwaysIncludeSemantics: true, child: child),
          ),
        );
      },
      child: child,
    );
  }
}
