/// `NebaCollapsible`, one section that folds, standing on its own.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/internal/disclosure.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Builds a [NebaCollapsible]'s trigger from whether the panel is [open] and
/// the callback that opens or closes it, which is `null` while the
/// collapsible is disabled.
typedef NebaCollapsibleTriggerBuilder =
    Widget Function(BuildContext context, bool open, VoidCallback? onToggle);

/// One section that folds, standing on its own.
///
/// Pressing the header opens what is under it, and pressing it again closes
/// it. The panel opens to the height of what it holds and closes to none, on
/// the house duration and ease, and never by a transform: it is a window
/// opening onto its content. A set of these of which only one is open is a
/// `NebaAccordion`.
///
/// Controlled with [open] and [onOpenChange], or left to keep its own state
/// from [defaultOpen].
///
/// ```dart
/// const NebaCollapsible(
///   title: Text('Shipping and returns'),
///   child: Text('Orders placed before 2pm ship the same day.'),
/// )
/// ```
class NebaCollapsible extends StatefulWidget {
  /// A section that folds [child] away under a header.
  const NebaCollapsible({
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.title,
    this.subtitle,
    this.lines,
    this.startIcon,
    this.action,
    this.triggerBuilder,
    this.indicator = true,
    this.disabled = false,
    this.padded = true,
    this.keepMounted = true,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.child,
    super.key,
  }) : assert(lines == null || lines > 0),
       assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// Whether the panel is showing, for a controlled collapsible. Leave it
  /// `null` and the collapsible keeps its own state, starting from
  /// [defaultOpen].
  final bool? open;

  /// Where an uncontrolled collapsible starts.
  final bool defaultOpen;

  /// Called with the new state when the trigger opens or closes the panel.
  final ValueChanged<bool>? onOpenChange;

  /// The heading on the trigger, usually a [Text], set one step above the
  /// body in semibold.
  final Widget? title;

  /// A second line under the title, one step down the type scale and muted.
  final Widget? subtitle;

  /// How many lines the title and the subtitle keep before an ellipsis. Left
  /// out, both wrap: a title that is a question loses the question when it
  /// ends in an ellipsis.
  final int? lines;

  /// Before the title: an icon, a status dot, a count. Drawn muted, at 1.2
  /// times the type around it.
  final Widget? startIcon;

  /// A control pinned to the end of the header, outside the trigger, so it
  /// can be pressed on its own.
  final Widget? action;

  /// Replaces the header with a control of your own: a `NebaButton`, a
  /// `NebaChip`, a line of text made pressable. It is built with whether the
  /// panel is open and the callback that toggles it, which is `null` while
  /// [disabled], and a screen reader hears it as expanded or collapsed.
  final NebaCollapsibleTriggerBuilder? triggerBuilder;

  /// Whether the header draws the chevron at its end, turned to report the
  /// state.
  final bool indicator;

  /// Unavailable: the trigger stops answering and the panel stays as it is.
  final bool disabled;

  /// Whether the panel pads what it holds. Off for something that should
  /// reach the edges: a table, a picture, a list of its own.
  final bool padded;

  /// Whether a closed panel keeps what it holds built, so a field in it keeps
  /// what was typed through being folded away. Off for a panel that is
  /// expensive to build and only needs to exist while open.
  final bool keepMounted;

  /// The sheet's weight: `solid` a brighter sheet, `outline` a frosted one
  /// with a hairline, `text` none, for a fold inside running text or a
  /// `NebaCard`. Defaults to `NebaProvider`'s, then [NebaVariant.outline].
  final NebaVariant? variant;

  /// The padding, the corners and the type of the title and the body.
  /// Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the hairline, the hover wash, the open header's ink and
  /// the focus ring. The sheet itself stays undyed. Defaults to
  /// [NebaColor.primary].
  final NebaColor? color;

  /// How much padding the header and the panel have at their [size].
  /// Defaults to `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0`, the default, to `3`.
  final NebaElevation? elevation;

  /// The body.
  final Widget? child;

  @override
  State<NebaCollapsible> createState() => _NebaCollapsibleState();
}

class _NebaCollapsibleState extends State<NebaCollapsible> {
  late bool _open = widget.defaultOpen;

  bool get _current => widget.open ?? _open;

  void _toggle() {
    if (widget.disabled) {
      return;
    }

    final bool next = !_current;

    if (widget.open == null) {
      setState(() => _open = next);
    }

    widget.onOpenChange?.call(next);
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
    final double padding = NebaBox.padding[density]![size]!;
    final bool open = _current;
    final NebaCollapsibleTriggerBuilder? triggerBuilder = widget.triggerBuilder;
    final Widget header;

    if (triggerBuilder != null) {
      // One node for the caller's control and the state it reports, so a
      // button stays a button and is heard as expanded or collapsed.
      header = MergeSemantics(
        child: Semantics(
          expanded: open,
          child: Builder(
            builder: (BuildContext context) =>
                triggerBuilder(context, open, widget.disabled ? null : _toggle),
          ),
        ),
      );
    } else {
      header = NebaDisclosureHeader(
        open: open,
        onToggle: _toggle,
        size: size,
        padding: padding,
        color: color,
        title: widget.title,
        subtitle: widget.subtitle,
        lines: widget.lines,
        startIcon: widget.startIcon,
        action: widget.action,
        indicator: widget.indicator,
        disabled: widget.disabled,
      );
    }

    // The default header already paid for the room above the body, so the
    // body only owes the room below it. A caller's own trigger paid for
    // nothing, so there the body owes both.
    final EdgeInsetsGeometry bodyPadding = !widget.padded
        ? EdgeInsets.zero
        : triggerBuilder != null
        ? EdgeInsets.all(padding)
        : EdgeInsets.fromLTRB(padding, 0, padding, NebaDisclosureBody.bottom(density));

    return NebaDisclosureSheet(
      variant: variant,
      color: color,
      size: size,
      elevation: elevation,
      // A caller's trigger draws its own surface, and a clip would only cut
      // its focus ring off; the panel rounds its own bottom corners instead.
      clip: triggerBuilder == null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          header,
          NebaDisclosurePanel(
            open: open,
            keepMounted: widget.keepMounted,
            bottomRadius: triggerBuilder == null ? 0 : tokens.radius[size]!,
            child: NebaDisclosureBody(
              size: size,
              padding: bodyPadding,
              child: widget.child ?? const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
