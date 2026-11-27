/// `NebaSpoiler`, content that stays covered until somebody asks for it.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/components/button/neba_button.dart';
import 'package:neba/src/internal/color.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/ring.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Content that stays covered until somebody asks for it: a plot twist, an
/// answer, a picture that should not be seen by accident.
///
/// The cover is a blur rather than nothing at all, so a reader can see that
/// there is something there and roughly how much of it, without reading it.
/// Over the blur sit a line saying why it is covered and a button that
/// uncovers it, both in the [locale]'s words unless [label] and [description]
/// say otherwise. While it is covered the content is out of the focus order,
/// the semantics tree, the pointer's reach and any selection.
///
/// The cover keeps its place once the content is out, and with [reversible]
/// the row of the button that puts it back is held open while the content is
/// still covered, so neither a reveal nor a cover changes the box's height.
///
/// ```dart
/// const NebaSpoiler(child: Text('Rosebud was the name of the sled.'))
/// ```
class NebaSpoiler extends StatefulWidget {
  /// [child], covered until revealed.
  const NebaSpoiler({
    this.child,
    this.revealed,
    this.defaultRevealed = false,
    this.onRevealedChange,
    this.locale,
    this.label,
    this.hideLabel,
    this.description,
    this.showDescription = true,
    this.action,
    this.reversible = false,
    this.maxHeight,
    this.blur = 10,
    this.padded = true,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    super.key,
  }) : assert(blur >= 0),
       assert(maxHeight == null || maxHeight >= 0),
       assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// What is covered.
  final Widget? child;

  /// Whether the content is uncovered, for a Spoiler driven from outside.
  /// Left null, it keeps its own state, starting from [defaultRevealed].
  final bool? revealed;

  /// Where a Spoiler that keeps its own state starts.
  final bool defaultRevealed;

  /// Called when the reveal or the hide button is pressed, with whether the
  /// content is to be uncovered.
  final ValueChanged<bool>? onRevealedChange;

  /// The language of the default button label and the notice. Defaults to
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// The reveal button's label. Defaults to the [locale]'s word for it.
  final Widget? label;

  /// The hide button's label, when [reversible] is on. Defaults to the
  /// [locale]'s word for it.
  final Widget? hideLabel;

  /// The line above the button, saying why the content is covered. Defaults
  /// to the [locale]'s wording.
  final Widget? description;

  /// Whether the line above the button is written at all. `false` is a cover
  /// with nothing written on it, the React package's `description={false}`.
  final bool showDescription;

  /// Replaces the reveal button entirely. The replacement is the caller's to
  /// wire up: it drives [revealed] and [onRevealedChange] itself.
  final Widget? action;

  /// Keeps the content coverable: once it is revealed, a hide button sits
  /// under it.
  final bool reversible;

  /// Clamps the covered box to this height, in logical pixels. Revealing
  /// releases it, and the content takes whatever height it needs. Left out,
  /// the box is as tall as what it holds.
  final double? maxHeight;

  /// How hard the content is blurred, as a CSS `blur()` length: the standard
  /// deviation in logical pixels.
  final double blur;

  /// Whether the content is padded on the box's own scale. Off for content
  /// that should reach the edges, such as a picture.
  final bool padded;

  /// The box's weight, which is never dyed: `solid` is a brighter sheet,
  /// `outline` a lighter one with a hairline, `text` no box at all.
  /// Defaults to `NebaProvider`'s, then [NebaVariant.outline].
  final NebaVariant? variant;

  /// The box's corners and the size of the buttons on it. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the hairline and the buttons. Defaults to
  /// [NebaColor.primary].
  final NebaColor? color;

  /// The padding around the content and the cover's own words. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`. Defaults to `0`, which is flat.
  final NebaElevation? elevation;

  @override
  State<NebaSpoiler> createState() => _NebaSpoilerState();
}

class _NebaSpoilerState extends State<NebaSpoiler> {
  late bool _uncontrolled = widget.defaultRevealed;

  /// Whether the focus is anywhere inside the Spoiler.
  final FocusNode _within = FocusNode(
    debugLabel: 'NebaSpoiler',
    canRequestFocus: false,
    skipTraversal: true,
  );

  /// The content, focusable from code only, so a reveal can hand it the
  /// focus.
  final FocusNode _content = FocusNode(debugLabel: 'NebaSpoiler content', skipTraversal: true);

  /// The cover, whose first control takes the focus back when the content is
  /// covered again.
  final FocusNode _cover = FocusNode(
    debugLabel: 'NebaSpoiler cover',
    canRequestFocus: false,
    skipTraversal: true,
  );

  /// The content's key, which keeps its state as the selection around it
  /// comes and goes.
  final GlobalKey _held = GlobalKey(debugLabel: 'NebaSpoiler content');

  bool get _open => widget.revealed ?? _uncontrolled;

  @override
  void didUpdateWidget(NebaSpoiler oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool was = oldWidget.revealed ?? _uncontrolled;

    if (was != _open) {
      _handOff(_open);
    }
  }

  @override
  void dispose() {
    _within.dispose();
    _content.dispose();
    _cover.dispose();
    super.dispose();
  }

  void _change(bool next) {
    if (widget.revealed == null && next != _uncontrolled) {
      _handOff(next);
      setState(() => _uncontrolled = next);
    }

    widget.onRevealedChange?.call(next);
  }

  /// The button that was pressed is in the half that is about to stop taking
  /// the focus: the cover on a reveal, the hide row on a cover. So the focus
  /// is handed to the half that is live once it has been built: the content
  /// that was revealed, or the cover's first control.
  void _handOff(bool open) {
    if (!_within.hasFocus) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted) {
        return;
      }

      if (open) {
        _content.requestFocus();
      } else {
        _cover.traversalDescendants.firstOrNull?.requestFocus();
      }
    });
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
    final Map<String, String> messages = nebaMessages(context, 'spoiler', locale: widget.locale);
    final double padding = NebaBox.padding[density]![size]!;
    final BorderRadius radius = BorderRadius.circular(tokens.radius[size]!);
    final bool open = _open;
    final double? maxHeight = widget.maxHeight;
    final Widget? description = widget.showDescription
        ? (widget.description ?? Text(messages['notice']!))
        : null;

    // Moved in and out of a selection by its key, so what is in it keeps its
    // state: a covered spoiler that a select-all could copy is no spoiler.
    final Widget held = KeyedSubtree(key: _held, child: widget.child ?? const SizedBox.shrink());

    // The blur leaves the content's colour and rhythm and takes the words, and
    // the clamp is only ever on the covered state: a revealed box with its end
    // cut off would be answering the wrong question.
    final Widget content = ExcludeFocus(
      excluding: !open,
      child: Focus(
        focusNode: _content,
        child: IgnorePointer(
          ignoring: !open,
          child: ExcludeSemantics(
            excluding: !open,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: open ? 0 : widget.blur),
              duration: nebaDuration(context, NebaScale.durationFill),
              curve: NebaScale.ease,
              builder: (BuildContext context, double sigma, Widget? child) {
                return ImageFiltered(
                  enabled: sigma > 0,
                  imageFilter: ui.ImageFilter.blur(
                    sigmaX: sigma,
                    sigmaY: sigma,
                    tileMode: TileMode.decal,
                  ),
                  child: child,
                );
              },
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: open || maxHeight == null ? double.infinity : maxHeight,
                ),
                child: UnconstrainedBox(
                  constrainedAxis: Axis.horizontal,
                  alignment: AlignmentDirectional.topStart,
                  clipBehavior: Clip.hardEdge,
                  child: Padding(
                    padding: EdgeInsets.all(widget.padded ? padding : 0),
                    child: open ? held : SelectionContainer.disabled(child: held),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Built while the content is still covered and only kept out of sight, so
    // the box does not grow by a row at the moment of a reveal.
    final Widget? hideRow = widget.reversible
        ? _Shown(
            visible: open,
            child: Padding(
              padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _Reports(
                  expanded: true,
                  child: NebaButton(
                    onPressed: () => _change(false),
                    variant: NebaVariant.text,
                    size: size,
                    color: color,
                    density: density,
                    child: widget.hideLabel ?? Text(messages['hide']!),
                  ),
                ),
              ),
            ),
          )
        : null;

    // Over every row, the hide row included, and kept in place once the
    // content is out: a cover is routinely taller than the line it covers,
    // and a box that lost it would shrink under the press that revealed it.
    final Widget cover = Focus(
      focusNode: _cover,
      child: _Shown(
        visible: !open,
        child: ColoredBox(
          // The page's own surface over the blur, so the content goes to a
          // wash of its own colours and the button has a ground to stand on.
          color: open ? edgeless : mixOklab(tokens.surface, 0.55, edgeless),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: <Widget>[
                  if (description != null)
                    DefaultTextStyle.merge(
                      style: TextStyle(
                        color: tokens.mutedFg,
                        fontSize: NebaScale.metaText[size],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                      child: description,
                    ),
                  widget.action ??
                      _Reports(
                        expanded: false,
                        child: NebaButton(
                          onPressed: () => _change(true),
                          size: size,
                          color: color,
                          density: density,
                          child: widget.label ?? Text(messages['reveal']!),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final Widget laid = Focus(
      focusNode: _within,
      child: _CoverLayout(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[content, ?hideRow],
        ),
        cover: cover,
      ),
    );

    final Widget sheet = switch (variant) {
      NebaVariant.solid => NebaSheet(
        fill: tokens.panelHover,
        elevation: elevation,
        borderRadius: radius,
        child: laid,
      ),
      NebaVariant.outline => NebaSheet(
        fill: tokens.panel,
        edge: tokens.roles(color).line,
        plate: NebaPlate.glass,
        elevation: elevation,
        borderRadius: radius,
        child: laid,
      ),
      // No box, and still clipped to its corners, so the blur stops at them.
      NebaVariant.text => ClipRRect(borderRadius: radius, child: laid),
    };

    return NebaRing(borderRadius: radius, child: sheet);
  }
}

/// [child] laid out and holding its place either way, and drawn, reached and
/// heard only while [visible].
class _Shown extends StatelessWidget {
  const _Shown({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      maintainState: true,
      maintainAnimation: true,
      maintainSize: true,
      child: ExcludeFocus(excluding: !visible, child: child),
    );
  }
}

/// A button heard as expanded or collapsed, on its own node.
class _Reports extends StatelessWidget {
  const _Reports({required this.expanded, required this.child});

  final bool expanded;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(expanded: expanded, child: child),
    );
  }
}

/// The content and the cover in one cell: as tall as the taller of the two,
/// with the content at the top and the cover over all of it.
///
/// The cover is laid over the content rather than beside it, and it still
/// counts toward the height: a cover taller than what it covers, a one-line
/// spoiler under a two-line notice, would otherwise lose its button off the
/// bottom edge.
class _CoverLayout extends MultiChildRenderObjectWidget {
  _CoverLayout({required Widget content, required Widget cover})
    : super(children: <Widget>[content, cover]);

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderCoverLayout();
}

class _CoverParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderCoverLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _CoverParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _CoverParentData> {
  RenderBox get _content => firstChild!;

  RenderBox get _cover => lastChild!;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _CoverParentData) {
      child.parentData = _CoverParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return math.max(_content.getMinIntrinsicWidth(height), _cover.getMinIntrinsicWidth(height));
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return math.max(_content.getMaxIntrinsicWidth(height), _cover.getMaxIntrinsicWidth(height));
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return math.max(_content.getMinIntrinsicHeight(width), _cover.getMinIntrinsicHeight(width));
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return math.max(_content.getMaxIntrinsicHeight(width), _cover.getMaxIntrinsicHeight(width));
  }

  /// The width both are laid out at: all of a bounded width, as a block takes
  /// it, or the wider of the two where there is no bound.
  double _width(BoxConstraints constraints, Size Function(RenderBox, BoxConstraints) measure) {
    if (constraints.hasBoundedWidth) {
      return constraints.maxWidth;
    }

    final BoxConstraints loose = BoxConstraints(maxHeight: constraints.maxHeight);

    return math.max(measure(_content, loose).width, measure(_cover, loose).width);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    Size dry(RenderBox child, BoxConstraints given) => child.getDryLayout(given);

    final double width = _width(constraints, dry);
    final double content = dry(
      _content,
      BoxConstraints(minWidth: width, maxWidth: width, maxHeight: constraints.maxHeight),
    ).height;
    final double cover = dry(_cover, BoxConstraints.tightFor(width: width)).height;

    return constraints.constrain(Size(width, math.max(content, cover)));
  }

  @override
  void performLayout() {
    Size measure(RenderBox child, BoxConstraints given) {
      child.layout(given, parentUsesSize: true);

      return child.size;
    }

    final double width = _width(constraints, measure);

    // The cover measured at its own height first, then stretched over the
    // whole cell once the cell's height is known.
    final double cover = measure(_cover, BoxConstraints.tightFor(width: width)).height;
    final double content = measure(
      _content,
      BoxConstraints(minWidth: width, maxWidth: width, maxHeight: constraints.maxHeight),
    ).height;
    final double height = constraints.constrainHeight(math.max(content, cover));

    _cover.layout(BoxConstraints.tight(Size(width, height)));
    size = constraints.constrain(Size(width, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
