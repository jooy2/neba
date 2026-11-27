/// `NebaHoverCard`, a card that opens when the pointer rests on something.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/floating.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/types.dart';

/// A card that opens when the pointer rests on something, and holds a preview
/// of what is on the other side of it: a person behind a mention, a
/// repository behind a link, a deploy behind an id.
///
/// It sits between the library's other two popups. Like a tooltip it is not
/// asked for: it opens after [delay] under a mouse, or after the same wait on
/// keyboard focus, and never on a touch. Like a popover it can be reached:
/// the pointer can cross into it within [closeDelay], and a link inside can be
/// followed. Escape and a press elsewhere close it.
///
/// Because it is not asked for, it is never the only way to something:
/// whatever it shows has to be on the page the trigger leads to as well.
///
/// ```dart
/// NebaHoverCard(
///   trigger: NebaButton(onPressed: openProfile, child: const Text('@nadiarowan')),
///   title: const Text('Nadia Rowan'),
///   child: const Text('Maintainer · 214 commits'),
/// )
/// ```
class NebaHoverCard extends StatefulWidget {
  /// A card about [trigger], showing [child].
  const NebaHoverCard({
    required this.trigger,
    this.title,
    this.description,
    this.child,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.side = NebaSide.bottom,
    this.align = NebaAlign.center,
    this.sideOffset = 6,
    this.alignOffset = 0,
    this.arrow = false,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.delay = const Duration(milliseconds: 600),
    this.closeDelay = const Duration(milliseconds: 300),
    this.width,
    super.key,
  });

  /// What the card hangs off. Any widget: the card wraps it and adds nothing
  /// to the layout.
  final Widget trigger;

  /// A heading line at the top of the card, one step above the body in
  /// semibold. It is drawn, not announced as the card's name.
  final Widget? title;

  /// A line under the title, one step down the type scale and muted.
  final Widget? description;

  /// The body.
  final Widget? child;

  /// The type, the corners, the padding and the widest the card gets.
  /// Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the edge. The sheet itself stays undyed.
  final NebaColor color;

  /// How much padding the card has at its [size]. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// Which edge of the trigger it appears on. It flips to the opposite side
  /// when there is no room.
  final NebaSide side;

  /// Where it sits along that edge.
  final NebaAlign align;

  /// The distance from the trigger, in logical pixels.
  final double sideOffset;

  /// A shift along that edge, in logical pixels.
  final double alignOffset;

  /// Draws the wedge pointing at the trigger. Off by default, as on a
  /// popover: a wedge sticking out of a translucent sheet cannot carry the
  /// blurred backdrop with it.
  final bool arrow;

  /// Whether the card is open. With [onOpenChange] the caller owns the
  /// state; without it the card keeps its own.
  final bool? open;

  /// Whether a card that keeps its own state starts open.
  final bool defaultOpen;

  /// Called whenever the card opens or closes.
  final ValueChanged<bool>? onOpenChange;

  /// How long the pointer, or the keyboard focus, has to rest on the trigger
  /// before the card opens: long enough that crossing a paragraph of links
  /// does not open four of them.
  final Duration delay;

  /// How long the card stays after the pointer has left, which is what lets
  /// it cross the gap between the trigger and the card.
  final Duration closeDelay;

  /// The widest the card gets, in logical pixels, in place of the one
  /// [size] gives.
  final double? width;

  /// The widest a card gets at each size, one rung wider than a popover:
  /// this is a preview, not a note.
  static const Map<NebaSize, double> maxWidths = <NebaSize, double>{
    NebaSize.xs: 256,
    NebaSize.sm: 288,
    NebaSize.md: 336,
    NebaSize.lg: 448,
    NebaSize.xl: 576,
  };

  @override
  State<NebaHoverCard> createState() => _NebaHoverCardState();
}

class _NebaHoverCardState extends State<NebaHoverCard> {
  late bool _open = widget.defaultOpen;

  bool get _isOpen => widget.open ?? _open;

  void _change(bool open, NebaFloatingReason reason) {
    if (open == _isOpen) {
      return;
    }

    if (widget.open == null) {
      setState(() => _open = open);
    }

    widget.onOpenChange?.call(open);
  }

  @override
  Widget build(BuildContext context) {
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;

    return NebaFloating(
      open: _isOpen,
      onOpenChange: _change,
      side: widget.side,
      align: widget.align,
      sideOffset: widget.sideOffset,
      alignOffset: widget.alignOffset,
      arrow: widget.arrow
          ? NebaFloatingSheet.arrowOf(NebaTheme.of(context), widget.color, size)
          : null,
      hover: NebaFloatingHover(delay: () => widget.delay, closeDelay: widget.closeDelay),
      focusDelay: widget.delay,
      popup: Semantics(
        container: true,
        explicitChildNodes: true,
        child: NebaFloatingSheet(
          size: size,
          color: widget.color,
          density: density,
          maxWidth: widget.width ?? NebaHoverCard.maxWidths[size]!,
          title: widget.title,
          description: widget.description,
          child: widget.child,
        ),
      ),
      child: widget.trigger,
    );
  }
}
