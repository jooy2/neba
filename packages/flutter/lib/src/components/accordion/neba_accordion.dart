/// `NebaAccordion` and `NebaAccordionItem`, a stack of sections that fold open
/// and shut.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/internal/disclosure.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A stack of sections that fold open and shut, of which one is open unless
/// [multiple] says otherwise.
///
/// Each section is a `NebaAccordionItem`, named by its `value`. Closing the
/// open section as the next one opens is what keeps the page from growing
/// under the reader, and the whole reason an accordion is more than a stack of
/// `NebaCollapsible`s. A section opens to the height of what it holds and
/// closes to none, by layout and never by a transform.
///
/// Controlled with [value] and [onValueChange], or left to keep its own state
/// from [defaultValue]; the value is a list in the single case too, so it does
/// not change type with [multiple]. [size], [density], [dividers],
/// [headingLevel] and [disabled] belong to the stack, so a section has none
/// of its own but `disabled`.
///
/// ```dart
/// NebaAccordion<String>(
///   defaultValue: const <String>['billing'],
///   children: const <Widget>[
///     NebaAccordionItem<String>(
///       value: 'billing',
///       title: Text('How does billing work?'),
///       child: Text('You are charged on the first of each month.'),
///     ),
///   ],
/// )
/// ```
class NebaAccordion<T> extends StatefulWidget {
  /// A stack of [children], each a `NebaAccordionItem`.
  const NebaAccordion({
    required this.children,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.multiple = false,
    this.dividers = true,
    this.disabled = false,
    this.headingLevel = 3,
    this.keepMounted = true,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    super.key,
  }) : assert(headingLevel >= 1 && headingLevel <= 6),
       assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The sections, each a `NebaAccordionItem`.
  final List<Widget> children;

  /// Which sections are open, by their `value`, for a controlled accordion.
  /// Leave it `null` and the accordion keeps its own state, starting from
  /// [defaultValue].
  final List<T>? value;

  /// Which sections start open, for an uncontrolled accordion.
  final List<T>? defaultValue;

  /// Called with the values of the open sections after a header is pressed.
  /// A section with no `value` opens and closes, and is left out of the list.
  final ValueChanged<List<T>>? onValueChange;

  /// Whether more than one section may be open at once. Off, opening one
  /// closes the one that was open.
  final bool multiple;

  /// Separates the sections with a hairline in [color]'s family rather than
  /// with space. Off, the sections are tiles a step rounder inside the sheet.
  final bool dividers;

  /// Unavailable: every section stops answering.
  final bool disabled;

  /// The heading level every section's header is, in the screen's outline:
  /// `3` under a level-two heading, `4` under a level-three one.
  final int headingLevel;

  /// Whether a closed section keeps what it holds built, so its state
  /// survives being folded away. Off for sections that are expensive to
  /// build and only need to exist while open.
  final bool keepMounted;

  /// The sheet's weight: `solid` a brighter sheet, `outline` a frosted one
  /// with a hairline, `text` none, for an accordion inside a `NebaCard`.
  /// Defaults to `NebaProvider`'s, then [NebaVariant.outline].
  final NebaVariant? variant;

  /// The padding, the corners and the type of every section. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the hairlines, the hover wash, an open header's ink and
  /// the focus ring. The sheet itself stays undyed. Defaults to
  /// [NebaColor.primary].
  final NebaColor? color;

  /// How much padding every section has at its [size]. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0`, the default, to `3`.
  final NebaElevation? elevation;

  @override
  State<NebaAccordion<T>> createState() => _NebaAccordionState<T>();
}

class _NebaAccordionState<T> extends State<NebaAccordion<T>> {
  /// What is open in an uncontrolled accordion: the values of the sections,
  /// and the place of a section that has none.
  late Set<Object?> _open = <Object?>{...?widget.defaultValue};

  Set<Object?> get _current {
    final List<T>? value = widget.value;

    return value == null ? _open : <Object?>{...value};
  }

  void _toggle(Object? key) {
    if (widget.disabled) {
      return;
    }

    final Set<Object?> current = _current;
    final Set<Object?> next = current.contains(key)
        ? (<Object?>{...current}..remove(key))
        : (widget.multiple ? <Object?>{...current, key} : <Object?>{key});

    if (widget.value == null) {
      setState(() => _open = next);
    }

    widget.onValueChange?.call(<T>[
      for (final Object? key in next)
        if (key is! _Place) key as T,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaColor color = widget.color ?? NebaColor.primary;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final bool dividers = widget.dividers;
    final BorderSide rule = BorderSide(color: tokens.roles(color).line);
    final List<Widget> children = widget.children;

    final Widget stack = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < children.length; i++)
          _Section(
            index: i,
            // A Container, so the rule takes its pixel as a CSS border does.
            child: dividers && i > 0
                ? Container(
                    decoration: BoxDecoration(border: Border(top: rule)),
                    child: children[i],
                  )
                : children[i],
          ),
      ],
    );

    return _AccordionScope(
      open: _current,
      toggle: _toggle,
      size: size,
      density: density,
      color: color,
      dividers: dividers,
      headingLevel: widget.headingLevel,
      disabled: widget.disabled,
      keepMounted: widget.keepMounted,
      child: NebaDisclosureSheet(
        variant: variant,
        color: color,
        size: size,
        elevation: widget.elevation ?? 0,
        // With rules the sections run to the sheet's edge. Without them they
        // are tiles, and a hair of padding keeps a hovered header off it.
        child: Padding(padding: EdgeInsets.all(dividers ? 0 : 4), child: stack),
      ),
    );
  }
}

/// One section of a [NebaAccordion]: a header that folds a panel open and
/// shut.
///
/// The header is a button covering the title and the chevron, inside a
/// heading at the accordion's `headingLevel`, and [action] sits beside it as
/// a control of its own. [size], density and the rest come from the
/// accordion, which is the only place they can be set once for every
/// section.
class NebaAccordionItem<T> extends StatelessWidget {
  /// A section named [value], headed [title], holding [child].
  const NebaAccordionItem({
    this.value,
    this.title,
    this.subtitle,
    this.startIcon,
    this.action,
    this.lines,
    this.disabled = false,
    this.child,
    super.key,
  }) : assert(lines == null || lines > 0);

  /// What names the section to the accordion's `value` and `defaultValue`.
  /// Left out, the accordion names it by its place, which is fine for an
  /// accordion nobody drives from code.
  final T? value;

  /// The heading on the fold, usually a [Text]. Plain text rather than a
  /// heading of its own: the header is already one.
  final Widget? title;

  /// A second line under the title, one step down the type scale and muted.
  final Widget? subtitle;

  /// Before the title: an icon, a status dot, a count.
  final Widget? startIcon;

  /// A control pinned to the end of the header, outside the trigger and the
  /// heading, so it can be pressed on its own and is not read as part of the
  /// title.
  final Widget? action;

  /// How many lines the title and the subtitle keep before an ellipsis. Left
  /// out, both wrap: a question cut off with an ellipsis loses the question.
  final int? lines;

  /// Unavailable: this section stops folding, and the rest keep working.
  final bool disabled;

  /// The body.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final _AccordionScope? scope = context.dependOnInheritedWidgetOfExactType<_AccordionScope>();
    final _Section? section = context.dependOnInheritedWidgetOfExactType<_Section>();

    assert(() {
      if (scope == null || section == null) {
        throw FlutterError(
          'A NebaAccordionItem was built outside a NebaAccordion.\n'
          'A section draws itself from the stack it is in, so it has to be one of '
          "a NebaAccordion's children.",
        );
      }
      return true;
    }());

    final _AccordionScope stack = scope!;
    final T? value = this.value;
    final Object key = value ?? _Place(section!.index);
    final bool open = stack.open.contains(key);
    final NebaSize size = stack.size;
    final double padding = NebaBox.padding[stack.density]![size]!;
    final NebaTokens tokens = NebaTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        NebaDisclosureHeader(
          open: open,
          onToggle: () => stack.toggle(key),
          size: size,
          padding: padding,
          color: stack.color,
          title: title,
          subtitle: subtitle,
          lines: lines,
          startIcon: startIcon,
          action: action,
          disabled: disabled || stack.disabled,
          // Inside the edge when the sections are ruled: the sheet clips them,
          // and a ring outside a header that spans it would be cut off.
          insetRing: stack.dividers,
          // A tile is one step down the radius ladder from the sheet.
          borderRadius: stack.dividers
              ? BorderRadius.zero
              : BorderRadius.circular(tokens.radius[_tileRadius[size]]!),
          headingLevel: stack.headingLevel,
        ),
        NebaDisclosurePanel(
          open: open,
          keepMounted: stack.keepMounted,
          child: NebaDisclosureBody(
            size: size,
            padding: EdgeInsets.fromLTRB(
              padding,
              0,
              padding,
              NebaDisclosureBody.bottom(stack.density),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

/// The radius step a tile takes, one down from the sheet it is inside, as a
/// list row's does.
const Map<NebaSize, NebaSize> _tileRadius = <NebaSize, NebaSize>{
  NebaSize.xs: NebaSize.xs,
  NebaSize.sm: NebaSize.xs,
  NebaSize.md: NebaSize.sm,
  NebaSize.lg: NebaSize.sm,
  NebaSize.xl: NebaSize.md,
};

/// What names a section with no `value`: its place in the stack.
@immutable
class _Place {
  const _Place(this.index);

  final int index;

  @override
  bool operator ==(Object other) => other is _Place && other.index == index;

  @override
  int get hashCode => index.hashCode;
}

/// What the stack tells its sections.
class _AccordionScope extends InheritedWidget {
  const _AccordionScope({
    required this.open,
    required this.toggle,
    required this.size,
    required this.density,
    required this.color,
    required this.dividers,
    required this.headingLevel,
    required this.disabled,
    required this.keepMounted,
    required super.child,
  });

  final Set<Object?> open;
  final void Function(Object? key) toggle;
  final NebaSize size;
  final NebaDensity density;
  final NebaColor color;
  final bool dividers;
  final int headingLevel;
  final bool disabled;
  final bool keepMounted;

  @override
  bool updateShouldNotify(_AccordionScope oldWidget) {
    return !setEquals(open, oldWidget.open) ||
        toggle != oldWidget.toggle ||
        size != oldWidget.size ||
        density != oldWidget.density ||
        color != oldWidget.color ||
        dividers != oldWidget.dividers ||
        headingLevel != oldWidget.headingLevel ||
        disabled != oldWidget.disabled ||
        keepMounted != oldWidget.keepMounted;
  }
}

/// A section's place in the stack.
class _Section extends InheritedWidget {
  const _Section({required this.index, required super.child});

  final int index;

  @override
  bool updateShouldNotify(_Section oldWidget) => index != oldWidget.index;
}
