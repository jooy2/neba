/// `NebaList` and `NebaListItem`, a stack of rows of the same shape.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/internal/breakpoint.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/link.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A key for what a list wraps [child] in, after [child]'s own, so the
/// wrapper follows the child when the children are reordered.
Key? _keyOf(Widget child) {
  final Key? key = child.key;

  return key == null ? null : ValueKey<Key>(key);
}

/// What a [NebaListItem] takes from the [NebaList] around it: a row is a row
/// of something, so its size, its density, its colour family and whether the
/// rows are ruled belong to the list.
class _NebaListScope extends InheritedWidget {
  const _NebaListScope({
    required this.size,
    required this.density,
    required this.color,
    required this.dividers,
    required super.child,
  });

  final NebaSize size;
  final NebaDensity density;
  final NebaColor color;
  final bool dividers;

  static _NebaListScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_NebaListScope>();
  }

  @override
  bool updateShouldNotify(_NebaListScope oldWidget) {
    return size != oldWidget.size ||
        density != oldWidget.density ||
        color != oldWidget.color ||
        dividers != oldWidget.dividers;
  }
}

/// A stack of rows of the same shape: navigation, settings, search results,
/// anything that repeats.
///
/// The list is the sheet and the rows are what is on it. [size] and
/// [density] belong to the list and reach every [NebaListItem] below it, so
/// they are never repeated per row. A screen reader hears a list of items.
///
/// ```dart
/// NebaList(
///   children: <Widget>[
///     NebaListItem(onPressed: open, selected: true, child: const Text('production')),
///     NebaListItem(onPressed: open, child: const Text('staging')),
///   ],
/// )
/// ```
class NebaList extends StatelessWidget {
  /// A list of [children], usually [NebaListItem]s.
  const NebaList({
    required this.children,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.dividers = false,
    this.spacing,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       ),
       assert(spacing == null || spacing >= 0);

  /// The rows, usually [NebaListItem]s.
  final List<Widget> children;

  /// The sheet's weight. The sheet is never dyed, as on [NebaBox]; reach for
  /// [NebaVariant.text] inside a card, which is already a sheet. Defaults to
  /// `NebaProvider`'s, then [NebaVariant.outline].
  final NebaVariant? variant;

  /// The rows' type scale and padding, and the sheet's corners. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the hairline, the rules, a chosen row's tint and the focus
  /// ring. Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// The rows' padding, and nothing else. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0`, which is none and the default, to `3`. A
  /// `text` list has no sheet to lift and ignores it.
  final NebaElevation? elevation;

  /// Separates the rows with a hairline instead of with space. The rules reach
  /// both edges of the sheet, so the list gives up its inner padding and the
  /// rows give up their rounded corners.
  final bool dividers;

  /// The gap between the rows, on the spacing scale: `1` is 4 logical pixels.
  /// Left out, the rows touch and the padding inside each keeps their text
  /// apart. Ignored with [dividers], where the rule separates the rows.
  final double? spacing;

  /// The padding the sheet keeps around tiled rows, so a hovered row does not
  /// run into its edge: the React package's `p-1`.
  static const double inset = 4;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = this.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = this.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColor color = this.color ?? NebaColor.primary;
    final List<Widget> rows = nebaPresentChildren(context, children);
    final BorderSide rule = BorderSide(color: tokens.roles(color).line);
    final double? spacing = this.spacing;

    Widget column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: dividers || spacing == null ? 0 : spacing * NebaScale.spacingUnit,
      children: <Widget>[
        for (int i = 0; i < rows.length; i++)
          // A Container, because it adds the rule's pixel to the row as a
          // CSS border does, where a DecoratedBox would draw over it. Every
          // row has one, keyed after the row, so a row put in front of the
          // others leaves their state where it was.
          Container(
            key: _keyOf(rows[i]),
            decoration: BoxDecoration(
              border: Border(top: dividers && i > 0 ? rule : BorderSide.none),
            ),
            child: rows[i],
          ),
      ],
    );

    if (!dividers) {
      column = Padding(padding: const EdgeInsets.all(inset), child: column);
    }

    return Semantics(
      container: true,
      role: SemanticsRole.list,
      explicitChildNodes: true,
      child: _NebaListScope(
        size: size,
        density: density,
        color: color,
        dividers: dividers,
        child: NebaBox(
          variant: variant,
          size: size,
          color: color,
          elevation: elevation ?? 0,
          padded: false,
          child: column,
        ),
      ),
    );
  }
}

/// One row of a [NebaList].
///
/// A row with [onPressed] is a button, or a link when it has an [href]: the
/// whole row up to [action] is what a press lands on. [action] is a control
/// of its own at the end of the row, outside that pressable area, so a row
/// that navigates can still hold a switch. A row with neither only shows
/// what it holds and takes no focus.
///
/// ```dart
/// NebaListItem(
///   onPressed: open,
///   description: const Text('12 items'),
///   child: const Text('Documents'),
/// )
/// ```
class NebaListItem extends StatelessWidget {
  /// A row labelled [child].
  const NebaListItem({
    this.child,
    this.startIcon,
    this.endIcon,
    this.description,
    this.action,
    this.onPressed,
    this.href,
    this.selected = false,
    this.disabled = false,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// The label, usually a [Text]. One line, cut short with an ellipsis.
  final Widget? child;

  /// Before the label: an icon, an avatar, a status dot. Muted, at 1.2 times
  /// the label's size through the [IconTheme] the row hands down.
  final Widget? startIcon;

  /// After the label, inside the pressable area.
  final Widget? endIcon;

  /// A second line under the label, one step down the type scale and muted.
  final Widget? description;

  /// A control pinned to the end of the row: a switch, a menu button. It is
  /// outside the pressable area, so pressing it never presses the row.
  final Widget? action;

  /// Makes the row a button that calls this, or a link with an [href].
  final VoidCallback? onPressed;

  /// Where the row leads, for a screen reader and, on the web, the browser.
  /// It makes a pressable row a link; following it is [onPressed]'s. A scheme
  /// other than `http`, `https`, `mailto` or `tel` is not written.
  final Uri? href;

  /// Marks the row as the chosen one: the open page, the current filter. It
  /// is tinted in the list's family, and a screen reader hears it as
  /// selected.
  final bool selected;

  /// Unavailable: the row turns grey, and a pressable one stops answering.
  final bool disabled;

  /// The focus node of a pressable row.
  final FocusNode? focusNode;

  /// Whether a pressable row takes the focus when it is first built.
  final bool autofocus;

  /// A row's vertical padding per density: its own ladder rather than a
  /// box's, because a row is one line of text in a stack of them.
  static const Map<NebaDensity, Map<NebaSize, double>> paddingY =
      <NebaDensity, Map<NebaSize, double>>{
        NebaDensity.standard: <NebaSize, double>{
          NebaSize.xs: 4,
          NebaSize.sm: 6,
          NebaSize.md: 8,
          NebaSize.lg: 10,
          NebaSize.xl: 12,
        },
        NebaDensity.compact: <NebaSize, double>{
          NebaSize.xs: 2,
          NebaSize.sm: 2,
          NebaSize.md: 4,
          NebaSize.lg: 6,
          NebaSize.xl: 8,
        },
      };

  /// The step of the radius ladder a row is cut at, one below the sheet's:
  /// a tile cut out of a sheet cannot share the sheet's corner.
  static const Map<NebaSize, NebaSize> radiusStep = <NebaSize, NebaSize>{
    NebaSize.xs: NebaSize.xs,
    NebaSize.sm: NebaSize.xs,
    NebaSize.md: NebaSize.sm,
    NebaSize.lg: NebaSize.sm,
    NebaSize.xl: NebaSize.md,
  };

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final _NebaListScope? list = _NebaListScope.maybeOf(context);
    final NebaSize size = list?.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = list?.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColor color = list?.color ?? NebaColor.primary;
    final bool dividers = list?.dividers ?? false;
    final NebaColorRoles roles = tokens.roles(color);
    final Uri? link = nebaSafeHref(href);
    final bool interactive = onPressed != null && !disabled;
    final double padX = NebaBox.padding[density]![size]!;
    final BorderRadius radius = dividers
        ? BorderRadius.zero
        : BorderRadius.circular(tokens.radius[radiusStep[size]]!);

    _RowBody body(bool hovered) {
      return _RowBody(
        size: size,
        padding: EdgeInsets.symmetric(horizontal: padX, vertical: paddingY[density]![size]!),
        radius: radius,
        tokens: tokens,
        roles: roles,
        selected: selected,
        disabled: disabled,
        hovered: hovered,
        startIcon: startIcon,
        endIcon: endIcon,
        description: description,
        child: child,
      );
    }

    Widget row;

    if (interactive) {
      row = Semantics(
        container: true,
        button: link == null,
        link: link != null,
        linkUrl: link,
        enabled: link == null ? true : null,
        selected: selected ? true : null,
        child: NebaInteractive(
          onTap: onPressed,
          focusNode: focusNode,
          autofocus: autofocus,
          // A link answers Enter alone, and Space scrolls the page it is on.
          activatesOnSpace: link == null,
          builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
            return NebaFocusRing(
              visible: interaction.focusVisible,
              color: roles.ring,
              borderRadius: radius,
              // Inside the edge when the rows are ruled: the sheet clips them
              // then, and a ring outside a full-width row would be cut off.
              offset: dividers ? -focusRingWidth : focusRingOffset,
              child: body(interaction.hovered),
            );
          },
        ),
      );
    } else {
      row = body(false);

      if (disabled) {
        row = MouseRegion(cursor: SystemMouseCursors.forbidden, child: row);
      }
    }

    final Widget? action = this.action;

    // A row that only shows something is the list item itself, so what it
    // says is read as the item; a pressable one is a button inside it.
    return Semantics(
      container: true,
      role: list != null ? SemanticsRole.listItem : null,
      enabled: !interactive && disabled ? false : null,
      selected: !interactive && selected ? true : null,
      child: Row(
        children: <Widget>[
          Expanded(child: row),
          if (action != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padX),
              child: action,
            ),
        ],
      ),
    );
  }
}

/// What a row draws inside its pressable area: the tint, the icons, the label
/// and the description.
class _RowBody extends StatelessWidget {
  const _RowBody({
    required this.size,
    required this.padding,
    required this.radius,
    required this.tokens,
    required this.roles,
    required this.selected,
    required this.disabled,
    required this.hovered,
    this.startIcon,
    this.endIcon,
    this.description,
    this.child,
  });

  final NebaSize size;
  final EdgeInsets padding;
  final BorderRadius radius;
  final NebaTokens tokens;
  final NebaColorRoles roles;
  final bool selected;
  final bool disabled;
  final bool hovered;
  final Widget? startIcon;
  final Widget? endIcon;
  final Widget? description;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    const Color clear = Color(0x00000000);
    final double text = NebaScale.sheetBodyText[size]!;
    final double leading = NebaScale.sheetBodyLeading[size]!;
    final Color ambient = DefaultTextStyle.of(context).style.color ?? tokens.fg;
    // One state at a time, in the order the React package's if/else reads
    // them: grey wins, then the chosen row, then the pointer. A hovered row
    // and the chosen one are the same tint at two strengths.
    final Color fill = disabled
        ? clear
        : selected
        ? roles.softPress
        : hovered
        ? roles.soft
        : clear;
    final Color ink = disabled
        ? tokens.disabledFg
        : selected
        ? roles.onTint
        : ambient;
    final Widget? child = this.child;
    final Widget? description = this.description;

    Widget? slot(Widget? icon) {
      if (icon == null) {
        return null;
      }

      // One line tall and centred on it, as `h-[1lh]` is, in the muted ink
      // whatever state the row is in.
      return SizedBox(
        height: leading,
        child: Center(
          widthFactor: 1,
          child: IconTheme.merge(
            data: IconThemeData(color: tokens.mutedFg),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: tokens.mutedFg),
              child: icon,
            ),
          ),
        ),
      );
    }

    final Widget content = DefaultTextStyle.merge(
      style: TextStyle(
        fontSize: text,
        height: leading / text,
        // CSS shares a line's leading evenly above and below it.
        leadingDistribution: TextLeadingDistribution.even,
        fontWeight: selected && !disabled ? FontWeight.w500 : null,
      ),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      child: IconTheme.merge(
        data: IconThemeData(size: text * 1.2),
        child: NebaInk(
          color: ink,
          child: Row(
            spacing: NebaScale.gap[size]!,
            children: <Widget>[
              ?slot(startIcon),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ?child,
                    if (description != null)
                      DefaultTextStyle.merge(
                        // A chosen row's ink is already at the minimum for
                        // its tint, so its description keeps it and steps
                        // down in size alone.
                        // The line stays the label's height, as an inherited
                        // CSS line height does.
                        style: TextStyle(
                          fontSize: NebaScale.metaText[size],
                          height: leading / NebaScale.metaText[size]!,
                          color: selected ? null : tokens.mutedFg,
                        ),
                        child: description,
                      ),
                  ],
                ),
              ),
              ?slot(endIcon),
            ],
          ),
        ),
      ),
    );

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: fill),
      duration: nebaDuration(context, NebaScale.durationFill),
      curve: NebaScale.ease,
      builder: (BuildContext context, Color? tint, Widget? child) {
        return DecoratedBox(
          decoration: BoxDecoration(color: tint, borderRadius: radius),
          child: child,
        );
      },
      child: Padding(padding: padding, child: content),
    );
  }
}
