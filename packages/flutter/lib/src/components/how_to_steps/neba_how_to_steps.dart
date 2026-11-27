/// `NebaHowToSteps`, a guide the reader walks through one step at a time.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/components/button/neba_button.dart';
import 'package:neba/src/components/visually_hidden/neba_visually_hidden.dart';
import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/live_region.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/ring.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// One step of a [NebaHowToSteps] guide.
@immutable
class NebaHowToStep {
  /// A step headed [title].
  const NebaHowToStep({
    required this.title,
    this.icon,
    this.content,
    this.image,
    this.imageAlt,
    this.imageWidth,
    this.imageHeight,
  });

  /// The heading, shown both in the list and over the step's own body. A
  /// [Text] also names the step's row for a screen reader, "Step 3: Use it".
  final Widget title;

  /// A glyph before the title over the step's own body, in the family's
  /// accent: what kind of step this is. Not in the list, where the row
  /// already carries a numbered disc.
  final Widget? icon;

  /// What the reader has to do: prose, a code block, a form.
  final Widget? content;

  /// A picture above the content, for a step that is easier shown than said.
  /// It spans the panel and is never taller than 288 pixels.
  final ImageProvider? image;

  /// What the picture says for a reader who cannot see it. Defaults to the
  /// title's words when the title is a [Text].
  final String? imageAlt;

  /// The picture's own width in pixels. With [imageHeight] it is the
  /// picture's proportion, which the panel reserves before the picture
  /// arrives; not a size, since the picture still spans the panel.
  final double? imageWidth;

  /// The picture's own height in pixels. See [imageWidth].
  final double? imageHeight;
}

/// A guide the reader walks through: numbered steps down one side, one
/// step's instructions at a time beside them, and a way forward under those.
/// It ends, and says so.
///
/// Every step's body is built into the same place, with the ones not showing
/// kept out of sight, out of the focus order and out of the semantics tree.
/// The panel is therefore as tall as the tallest step at every moment, so
/// moving between a short step and a long one does not resize what the guide
/// sits in, and a form halfway through keeps what was typed into it.
///
/// The list is a list of buttons, not a set of tabs: the steps are ordered,
/// and the current one is marked as the current step rather than as the
/// chosen view.
///
/// ```dart
/// NebaHowToSteps(
///   title: const Text('Schedule a job with cron'),
///   steps: const <NebaHowToStep>[
///     NebaHowToStep(title: Text('Open your crontab'), content: Text('crontab -e')),
///     NebaHowToStep(title: Text('Write the schedule'), content: Text('Five fields.')),
///   ],
/// )
/// ```
class NebaHowToSteps extends StatefulWidget {
  /// A guide through [steps].
  const NebaHowToSteps({
    required this.steps,
    this.title,
    this.headingLevel = 3,
    this.step,
    this.defaultStep = 0,
    this.onStepChange,
    this.completed,
    this.defaultCompleted = false,
    this.onCompletedChange,
    this.orientation = NebaOrientation.vertical,
    this.maxHeight,
    this.railWidth = 240,
    this.navigation = true,
    this.divider = true,
    this.transition = const NebaTransition.fade(),
    this.completion = true,
    this.completedContent,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.locale,
    this.previousLabel,
    this.nextLabel,
    this.doneLabel,
    this.restartLabel,
    super.key,
  }) : assert(headingLevel >= 2 && headingLevel <= 5),
       assert(railWidth >= 0),
       assert(maxHeight == null || maxHeight >= 0),
       assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The steps, in the order they are to be done. A guide with none builds
  /// nothing.
  final List<NebaHowToStep> steps;

  /// The guide's own heading, over the list and the body.
  final Widget? title;

  /// The heading level [title] is at, from `2` to `5`, with a step's title one
  /// below it; without a [title] a step's title takes this level itself, so
  /// the guide skips no level of the screen's outline.
  final int headingLevel;

  /// Which step is showing, for a guide driven from outside. Left null, it
  /// keeps its own, starting from [defaultStep]. Held to the steps there are.
  final int? step;

  /// Where a guide that keeps its own step starts.
  final int defaultStep;

  /// Called with the index whenever the step changes, however it changed.
  final ValueChanged<int>? onStepChange;

  /// Whether the guide is finished, for a guide driven from outside. Left
  /// null, it keeps its own, starting from [defaultCompleted].
  final bool? completed;

  /// Whether a guide that keeps its own state starts finished.
  final bool defaultCompleted;

  /// Called when the guide is finished, and again when it is started over.
  final ValueChanged<bool>? onCompletedChange;

  /// Which way the list runs. [NebaOrientation.vertical] puts the numbers
  /// down one side with the body beside them, stacked under the list on a
  /// window narrower than the `sm` breakpoint; [NebaOrientation.horizontal]
  /// runs them across the top, for a guide whose titles are all short.
  final NebaOrientation orientation;

  /// How tall the guide may get, in logical pixels. The list and the body
  /// scroll inside it rather than the sheet growing, and the current row is
  /// kept in view as the step changes.
  final double? maxHeight;

  /// How wide the list is while it is a column beside the body, in logical
  /// pixels, the divider and its gutter included.
  final double railWidth;

  /// Whether the row of buttons sits under the body. Off, the list is the
  /// only way to move.
  final bool navigation;

  /// Whether a hairline in [color]'s family runs between the list and the
  /// body: down the inner edge while they are side by side, along the bottom
  /// of the list once they have stacked.
  final bool divider;

  /// How a step arrives when the reader moves to it: `const
  /// NebaTransition.fade()` by default, any of the others, or `null` for
  /// none. It runs on the panel and never on what is pressed, and the step
  /// the guide is first built with has no entrance.
  final NebaTransition? transition;

  /// Whether there is a finished state at all. On, the last step's button
  /// says Done, and pressing it replaces the body with a panel that says so
  /// and offers to start again. Off, the last step is simply the last.
  final bool completion;

  /// What the finished panel says, in place of the [locale]'s sentence.
  final Widget? completedContent;

  /// The sheet's weight, which is never dyed. Defaults to `NebaProvider`'s,
  /// then [NebaVariant.outline].
  final NebaVariant? variant;

  /// The disc's diameter, the type and the buttons. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family the numbers, the connector, the divider and the buttons
  /// wear. Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// The padding, and nothing else. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`. Defaults to `0`, which is flat.
  final NebaElevation? elevation;

  /// The language of the buttons, the finished panel and what a screen
  /// reader is told. Defaults to `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// The Previous button's label, in place of the [locale]'s.
  final String? previousLabel;

  /// The Next button's label, in place of the [locale]'s.
  final String? nextLabel;

  /// The Done button's label, in place of the [locale]'s.
  final String? doneLabel;

  /// The Start over button's label, in place of the [locale]'s.
  final String? restartLabel;

  /// The numbered disc's diameter at each size.
  static const Map<NebaSize, double> markSize = <NebaSize, double>{
    NebaSize.xs: 20,
    NebaSize.sm: 24,
    NebaSize.md: 28,
    NebaSize.lg: 32,
    NebaSize.xl: 36,
  };

  /// The number's size on the disc at each size.
  static const Map<NebaSize, double> markText = <NebaSize, double>{
    NebaSize.xs: 10,
    NebaSize.sm: 11,
    NebaSize.md: 12,
    NebaSize.lg: 13,
    NebaSize.xl: 14,
  };

  /// The gap between one row of the list and the next, per density.
  static const Map<NebaDensity, Map<NebaSize, double>> railGap =
      <NebaDensity, Map<NebaSize, double>>{
        NebaDensity.standard: <NebaSize, double>{
          NebaSize.xs: 2,
          NebaSize.sm: 4,
          NebaSize.md: 4,
          NebaSize.lg: 6,
          NebaSize.xl: 8,
        },
        NebaDensity.compact: <NebaSize, double>{
          NebaSize.xs: 0,
          NebaSize.sm: 0,
          NebaSize.md: 2,
          NebaSize.lg: 2,
          NebaSize.xl: 4,
        },
      };

  @override
  State<NebaHowToSteps> createState() => _NebaHowToStepsState();
}

/// A transition that plays nothing, for a guide with none and for the step it
/// is first built with: the same effect throughout, so no panel is rebuilt
/// when it changes.
const NebaTransition _still = NebaTransition.fade(duration: Duration.zero);

class _NebaHowToStepsState extends State<NebaHowToSteps> {
  late int _ownStep = widget.defaultStep;
  late bool _ownCompleted = widget.defaultCompleted;

  /// Where the guide was first drawn, and whether the reader has moved off
  /// it: that first panel arrives with the screen and has no entrance.
  (int, bool)? _opening;
  bool _moved = false;

  /// How many times each panel has been arrived at, the finished panel last,
  /// which is what replays a panel's entrance.
  final List<int> _arrivals = <int>[];
  int? _shown;

  /// Where the focus goes once Done or Start over has rebuilt the row of
  /// buttons: `true` to Start over, `false` back to the forward button.
  bool? _handOff;

  /// The step whose row was last brought into view.
  int? _revealed;

  final FocusNode _restart = FocusNode(debugLabel: 'NebaHowToSteps restart');
  final FocusNode _forward = FocusNode(debugLabel: 'NebaHowToSteps forward');
  final ScrollController _rail = ScrollController();
  final List<GlobalKey> _rows = <GlobalKey>[];

  @override
  void dispose() {
    _restart.dispose();
    _forward.dispose();
    _rail.dispose();
    super.dispose();
  }

  int get _total => widget.steps.length;

  int get _active => math.min(math.max(widget.step ?? _ownStep, 0), math.max(_total - 1, 0));

  bool get _completed => widget.completion && (widget.completed ?? _ownCompleted);

  void _go(int next, {bool done = false}) {
    final bool completed = _completed;
    final int active = _active;

    setState(() {
      if (widget.completed == null) {
        _ownCompleted = done;
      }

      if (!done && widget.step == null) {
        _ownStep = next;
      }
    });

    if (completed != done) {
      widget.onCompletedChange?.call(done);
    }

    if (!done && next != active) {
      widget.onStepChange?.call(next);
    }
  }

  /// Keeps the current row inside the part of a scrolling list that shows,
  /// by the list's own scroll alone: bringing it into view through every
  /// scrollable around it would move the screen under a reader who only
  /// pressed a button inside a card.
  void _reveal(int index) {
    if (!mounted || !_rail.hasClients || index >= _rows.length) {
      return;
    }

    final RenderObject? row = _rows[index].currentContext?.findRenderObject();

    if (row == null) {
      return;
    }

    final RenderAbstractViewport? viewport = RenderAbstractViewport.maybeOf(row);

    if (viewport == null) {
      return;
    }

    final ScrollPosition position = _rail.position;
    final double leading = viewport.getOffsetToReveal(row, 0).offset;
    final double trailing = viewport.getOffsetToReveal(row, 1).offset;

    if (position.pixels > leading) {
      position.jumpTo(leading.clamp(position.minScrollExtent, position.maxScrollExtent));
    } else if (position.pixels < trailing) {
      position.jumpTo(trailing.clamp(position.minScrollExtent, position.maxScrollExtent));
    }
  }

  @override
  Widget build(BuildContext context) {
    final int total = _total;

    if (total == 0) {
      return const SizedBox.shrink();
    }

    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaColor color = widget.color ?? NebaColor.primary;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaElevation elevation = widget.elevation ?? 0;
    final NebaColorRoles roles = tokens.roles(color);
    final Map<String, String> messages = nebaMessages(context, 'steps', locale: widget.locale);

    final int active = _active;
    final bool completed = _completed;

    _opening ??= (active, completed);

    if (!_moved && (active, completed) != _opening) {
      _moved = true;
    }

    while (_arrivals.length < total + 1) {
      _arrivals.add(0);
    }

    while (_rows.length < total) {
      _rows.add(GlobalKey(debugLabel: 'NebaHowToSteps row ${_rows.length}'));
    }

    final int shown = completed ? total : active;

    if (_shown != null && _shown != shown && _moved) {
      _arrivals[shown == total ? _arrivals.length - 1 : shown]++;
    }

    _shown = shown;

    final bool? handOff = _handOff;

    if (handOff != null && handOff == completed) {
      final FocusNode target = completed ? _restart : _forward;

      _handOff = null;
      WidgetsBinding.instance.addPostFrameCallback((Duration _) {
        if (mounted) {
          target.requestFocus();
        }
      });
    }

    if (_revealed != active) {
      _revealed = active;
      WidgetsBinding.instance.addPostFrameCallback((Duration _) => _reveal(active));
    }

    final bool vertical = widget.orientation == NebaOrientation.vertical;
    final bool split = vertical && MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final bool bounded = widget.maxHeight != null;
    final BorderSide line = BorderSide(color: roles.line);
    final TextDirection direction = Directionality.of(context);
    final NebaTransition motion = _moved ? (widget.transition ?? _still) : _still;
    final double gap = NebaScale.sheetSectionGap[size]!;

    String? plain(Widget title) => title is Text ? title.data : null;

    // The list.
    final List<Widget> rows = <Widget>[
      for (int i = 0; i < total; i++)
        Semantics(
          container: true,
          role: SemanticsRole.listItem,
          child: _StepRow(
            key: _rows[i],
            index: i,
            total: total,
            done: completed || i < active,
            current: !completed && i == active,
            vertical: vertical,
            size: size,
            roles: roles,
            label: plain(widget.steps[i].title) == null
                ? null
                : fillNebaMessage(messages['step']!, <String, String>{
                    'index': '${i + 1}',
                    'title': plain(widget.steps[i].title)!,
                  }),
            onPressed: () => _go(i),
            child: widget.steps[i].title,
          ),
        ),
    ];

    Widget list(Widget layout) {
      return Semantics(
        container: true,
        role: SemanticsRole.list,
        label: messages['steps'],
        child: layout,
      );
    }

    final double rowGap = NebaHowToSteps.railGap[density]![size]!;
    Widget rail;

    if (vertical) {
      rail = list(
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: rowGap,
          children: rows,
        ),
      );

      if (bounded) {
        rail = SingleChildScrollView(controller: _rail, child: rail);
      }
    } else {
      final double least = NebaHowToSteps.markSize[size]! + 8;

      rail = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double share = (constraints.maxWidth - rowGap * (total - 1)) / total;

          // An even share each while every disc fits in one, and a strip that
          // scrolls sideways once they no longer do.
          if (share >= least) {
            return list(
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: rowGap,
                children: <Widget>[for (final Widget row in rows) Expanded(child: row)],
              ),
            );
          }

          return SingleChildScrollView(
            controller: _rail,
            scrollDirection: Axis.horizontal,
            child: list(
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: rowGap,
                children: <Widget>[
                  for (final Widget row in rows) SizedBox(width: least, child: row),
                ],
              ),
            ),
          );
        },
      );
    }

    // The line goes on the list's inner edge with a matching gutter, so the
    // space either side of it is the same.
    if (widget.divider) {
      rail = Container(
        decoration: BoxDecoration(
          border: split ? BorderDirectional(end: line) : Border(bottom: line),
        ),
        padding: split
            ? const EdgeInsetsDirectional.only(end: 20)
            : const EdgeInsets.only(bottom: 16),
        child: rail,
      );
    }

    // The panels, every one in the same place.
    final int stepLevel = math.min(
      6,
      widget.title != null ? widget.headingLevel + 1 : widget.headingLevel,
    );
    final Widget panels = _Cell(
      children: <Widget>[
        for (int i = 0; i < total; i++)
          _Panel(
            hidden: completed || i != active,
            transition: motion,
            arrivals: _arrivals[i],
            scrolls: bounded,
            child: _StepBody(
              step: widget.steps[i],
              index: i,
              total: total,
              size: size,
              tokens: tokens,
              roles: roles,
              headingLevel: stepLevel,
              position: fillNebaMessage(messages['position']!, <String, String>{
                'index': '${i + 1}',
                'total': '$total',
              }),
            ),
          ),
        if (widget.completion)
          _Panel(
            hidden: !completed,
            transition: motion,
            arrivals: _arrivals.last,
            scrolls: bounded,
            child: _Finished(
              size: size,
              accent: roles.family.accent,
              child: widget.completedContent ?? Text(messages['completed']!),
            ),
          ),
      ],
    );

    final Widget? navigation = widget.navigation
        ? _navigation(
            messages: messages,
            size: size,
            color: color,
            active: active,
            total: total,
            completed: completed,
            direction: direction,
          )
        : null;

    // Under a height it is stretched to, the buttons sit at the bottom.
    final Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: gap,
      children: <Widget>[
        bounded ? Flexible(child: panels) : panels,
        ?navigation,
      ],
    );

    final Widget laid = split
        ? _SplitLayout(railWidth: widget.railWidth, gap: 20, rail: rail, body: body)
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: <Widget>[
              if (bounded) Flexible(child: rail) else rail,
              if (bounded) Flexible(child: body) else body,
            ],
          );

    final Widget? title = widget.title;
    final double titleSize = NebaScale.sheetTitleText[size]!;

    Widget guide = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: gap,
      children: <Widget>[
        if (title != null)
          Semantics(
            container: true,
            header: true,
            headingLevel: widget.headingLevel,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: titleSize,
                height: NebaScale.sheetTitleLeading[size]! / titleSize,
                fontWeight: FontWeight.w500,
              ),
              child: title,
            ),
          ),
        if (bounded) Flexible(child: laid) else laid,
      ],
    );

    // The panel changes in place and the focus stays on the button that was
    // pressed, so this is what tells a screen reader a step changed. Its
    // first sentence is there from the start and is not read out.
    final String announcement = completed
        ? ''
        : plain(widget.steps[active].title) != null
        ? fillNebaMessage(messages['step']!, <String, String>{
            'index': '${active + 1}',
            'title': plain(widget.steps[active].title)!,
          })
        : fillNebaMessage(messages['position']!, <String, String>{
            'index': '${active + 1}',
            'total': '$total',
          });

    guide = Stack(
      children: <Widget>[
        guide,
        NebaLiveRegion(
          role: SemanticsRole.status,
          child: NebaVisuallyHidden(child: Text(announcement)),
        ),
      ],
    );

    final double? maxHeight = widget.maxHeight;
    final double padding = NebaBox.padding[density]![size]!;
    final BorderRadius radius = BorderRadius.circular(tokens.radius[size]!);

    final Widget content = DefaultTextStyle.merge(
      style: TextStyle(color: tokens.fg),
      child: Padding(padding: EdgeInsets.all(padding), child: guide),
    );

    Widget sheet = switch (variant) {
      NebaVariant.solid => NebaSheet(
        fill: tokens.panelHover,
        elevation: elevation,
        borderRadius: radius,
        child: content,
      ),
      NebaVariant.outline => NebaSheet(
        fill: tokens.panel,
        edge: roles.line,
        plate: NebaPlate.glass,
        elevation: elevation,
        borderRadius: radius,
        child: content,
      ),
      NebaVariant.text => content,
    };

    // The whole sheet, its hairline included, as a CSS `max-height` holds a
    // border box.
    if (maxHeight != null) {
      sheet = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: sheet,
      );
    }

    final String? named = title == null ? null : plain(title);

    // A set of steps is a group, named by its title when it has one.
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: named,
      child: NebaRing(borderRadius: radius, child: sheet),
    );
  }

  Widget _navigation({
    required Map<String, String> messages,
    required NebaSize size,
    required NebaColor color,
    required int active,
    required int total,
    required bool completed,
    required TextDirection direction,
  }) {
    final bool first = active == 0;
    final bool last = active == total - 1;
    final bool rtl = direction == TextDirection.rtl;

    // A chevron that points down, turned to point back or on.
    Widget chevron({required bool back}) {
      return RotatedBox(quarterTurns: back == rtl ? 3 : 1, child: NebaGlyph(NebaGlyphs.chevron));
    }

    final List<Widget> buttons;

    if (completed) {
      buttons = <Widget>[
        NebaButton(
          key: const ValueKey<String>('restart'),
          focusNode: _restart,
          size: size,
          variant: NebaVariant.outline,
          color: color,
          startIcon: NebaGlyph(NebaGlyphs.restart),
          onPressed: () {
            _handOff = _restart.hasPrimaryFocus ? false : null;
            _go(0);
          },
          child: Text(widget.restartLabel ?? messages['restart']!),
        ),
      ];
    } else {
      buttons = <Widget>[
        NebaButton(
          key: const ValueKey<String>('previous'),
          size: size,
          variant: NebaVariant.outline,
          color: color,
          // Pressing Previous onto the first step disables it, and a button
          // that dropped the focus then would drop a keyboard reader too.
          focusableWhenDisabled: true,
          startIcon: chevron(back: true),
          onPressed: first ? null : () => _go(active - 1),
          child: Text(widget.previousLabel ?? messages['previous']!),
        ),
        if (last && widget.completion)
          NebaButton(
            key: const ValueKey<String>('forward'),
            focusNode: _forward,
            size: size,
            color: color,
            startIcon: NebaGlyph(NebaGlyphs.check),
            onPressed: () {
              _handOff = _forward.hasPrimaryFocus ? true : null;
              _go(active, done: true);
            },
            child: Text(widget.doneLabel ?? messages['done']!),
          )
        else
          NebaButton(
            key: const ValueKey<String>('forward'),
            focusNode: _forward,
            size: size,
            color: color,
            focusableWhenDisabled: true,
            endIcon: chevron(back: false),
            onPressed: last ? null : () => _go(active + 1),
            child: Text(widget.nextLabel ?? messages['next']!),
          ),
      ];
    }

    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: buttons,
    );
  }
}

/// One row of the list: the numbered disc and the title, a button that
/// moves the guide to its step, with the line to the next disc behind it.
class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.total,
    required this.done,
    required this.current,
    required this.vertical,
    required this.size,
    required this.roles,
    required this.label,
    required this.onPressed,
    required this.child,
    super.key,
  });

  final int index;
  final int total;
  final bool done;
  final bool current;
  final bool vertical;
  final NebaSize size;
  final NebaColorRoles roles;
  final String? label;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final double mark = NebaHowToSteps.markSize[size]!;
    final double meta = NebaScale.metaText[size]!;
    final BorderRadius radius = BorderRadius.circular(tokens.radius[NebaSize.sm]!);
    final Duration duration = nebaDuration(context, NebaScale.duration);

    final Widget title = AnimatedDefaultTextStyle(
      duration: duration,
      curve: NebaScale.ease,
      style: DefaultTextStyle.of(context).style.merge(
        TextStyle(
          fontSize: meta,
          height: 1.5,
          fontWeight: current ? FontWeight.w500 : FontWeight.w400,
          color: current ? tokens.fg : tokens.mutedFg,
        ),
      ),
      textAlign: vertical ? TextAlign.start : TextAlign.center,
      maxLines: vertical ? 1 : null,
      overflow: vertical ? TextOverflow.ellipsis : TextOverflow.clip,
      softWrap: !vertical,
      child: child,
    );

    final Widget disc = _Disc(index: index, done: done, current: current, size: size, roles: roles);

    final Widget face = Padding(
      padding: const EdgeInsets.all(4),
      child: vertical
          ? Row(
              spacing: 12,
              children: <Widget>[
                disc,
                Flexible(child: title),
              ],
            )
          : Column(mainAxisSize: MainAxisSize.min, spacing: 6, children: <Widget>[disc, title]),
    );

    final String? label = this.label;

    // The disc is decoration, so a row with a title in words is named
    // "Step 3: Use it" and heard once; one whose title is not words keeps
    // the name its contents give it.
    final Widget button = Semantics(
      container: true,
      button: true,
      enabled: true,
      selected: current ? true : null,
      label: label,
      child: NebaInteractive(
        onTap: onPressed,
        builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
          // Inside the edge: the list scrolls, and a scroll box clips a ring
          // drawn outside the row.
          return NebaFocusRing(
            visible: interaction.focusVisible,
            color: roles.ring,
            borderRadius: radius,
            offset: -focusRingWidth,
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: interaction.hovered ? roles.soft : edgeless),
              duration: duration,
              curve: NebaScale.ease,
              builder: (BuildContext context, Color? wash, Widget? child) {
                return DecoratedBox(
                  decoration: BoxDecoration(color: wash, borderRadius: radius),
                  child: child,
                );
              },
              child: ExcludeSemantics(excluding: label != null, child: face),
            ),
          );
        },
      ),
    );

    if (index == total - 1) {
      return button;
    }

    // The line to the next disc, from the edge of this one to the edge of
    // the next rather than behind them, so it never shows through a disc.
    return CustomPaint(
      painter: _Connector(
        color: done ? roles.fill : roles.line,
        mark: mark,
        vertical: vertical,
        direction: Directionality.of(context),
      ),
      child: button,
    );
  }
}

/// The numbered disc: filled with a tick once its step is done, ringed in the
/// accent while it is the current one, and a hairline before that.
class _Disc extends StatelessWidget {
  const _Disc({
    required this.index,
    required this.done,
    required this.current,
    required this.size,
    required this.roles,
  });

  final int index;
  final bool done;
  final bool current;
  final NebaSize size;
  final NebaColorRoles roles;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final double extent = NebaHowToSteps.markSize[size]!;
    final double text = NebaHowToSteps.markText[size]!;
    final Color fill = done ? roles.fill : tokens.surface;
    final Color ink = done
        ? roles.family.onSolid
        : current
        ? roles.family.accent
        : tokens.mutedFg;
    final Color edge = done
        ? edgeless
        : current
        ? roles.family.accent
        : roles.line;

    return ExcludeSemantics(
      child: AnimatedContainer(
        duration: nebaDuration(context, NebaScale.duration),
        curve: NebaScale.ease,
        width: extent,
        height: extent,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
          border: Border.all(color: edge),
        ),
        child: done
            ? NebaGlyph(NebaGlyphs.check, size: text * 1.15, color: ink)
            : Text(
                '${index + 1}',
                style: TextStyle(
                  color: ink,
                  fontSize: text,
                  height: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}

/// The line from one disc to the next, a pixel wide, in the row's own box:
/// down from under the disc in a column, across from beside it in a row.
class _Connector extends CustomPainter {
  _Connector({
    required this.color,
    required this.mark,
    required this.vertical,
    required this.direction,
  });

  final Color color;
  final double mark;
  final bool vertical;
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect line = vertical
        ? Rect.fromLTWH(4 + mark / 2, 4 + mark, 1, size.height - mark)
        : Rect.fromLTWH(size.width / 2 + mark / 2, 4 + mark / 2, size.width - mark, 1);
    final Rect placed = direction == TextDirection.rtl
        ? Rect.fromLTRB(size.width - line.right, line.top, size.width - line.left, line.bottom)
        : line;

    canvas.drawRect(placed, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_Connector oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.mark != mark ||
        oldDelegate.vertical != vertical ||
        oldDelegate.direction != direction;
  }
}

/// A panel in the shared place: laid out whether it shows or not, so the
/// place is as tall as the tallest, and reached, heard and drawn only while
/// it shows. It arrives by [transition] each time [arrivals] counts up, and
/// is never built again for it.
class _Panel extends StatelessWidget {
  const _Panel({
    required this.hidden,
    required this.transition,
    required this.arrivals,
    required this.scrolls,
    required this.child,
  });

  final bool hidden;
  final NebaTransition transition;
  final int arrivals;
  final bool scrolls;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget panel = child;

    if (scrolls) {
      // A scrolling panel clips at its edge, and a focus ring against its
      // side or its foot would be cut off: the panel takes four pixels of
      // room for it and hands them back outside.
      panel = _Bleed(
        by: 4,
        child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(4, 0, 4, 4), child: panel),
      );
    }

    return Visibility(
      visible: !hidden,
      maintainState: true,
      maintainAnimation: true,
      maintainSize: true,
      child: ExcludeFocus(
        excluding: hidden,
        child: NebaEntrance(
          transition: transition,
          playsOnBuild: false,
          trigger: arrivals,
          child: panel,
        ),
      ),
    );
  }
}

/// A step's own body: its glyph, its heading and where it is in the guide,
/// its picture, and what the reader has to do.
class _StepBody extends StatelessWidget {
  const _StepBody({
    required this.step,
    required this.index,
    required this.total,
    required this.size,
    required this.tokens,
    required this.roles,
    required this.headingLevel,
    required this.position,
  });

  final NebaHowToStep step;
  final int index;
  final int total;
  final NebaSize size;
  final NebaTokens tokens;
  final NebaColorRoles roles;
  final int headingLevel;
  final String position;

  @override
  Widget build(BuildContext context) {
    final double titleSize = NebaScale.sheetTitleText[size]!;
    final double leading = NebaScale.sheetTitleLeading[size]!;
    final double bodySize = NebaScale.sheetBodyText[size]!;
    final Widget? icon = step.icon;
    final Widget? content = step.content;
    final ImageProvider? image = step.image;
    final Widget title = step.title;

    final Widget heading = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: <Widget>[
        // On the heading's own line, so it stays centred on the title at
        // every size.
        if (icon != null)
          ExcludeSemantics(
            child: IconTheme.merge(
              data: IconThemeData(color: roles.family.accent, size: titleSize * 1.2),
              child: SizedBox(
                height: leading,
                child: Center(widthFactor: 1, child: icon),
              ),
            ),
          ),
        Expanded(
          child: Semantics(
            container: true,
            header: true,
            headingLevel: headingLevel,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: titleSize,
                height: leading / titleSize,
                fontWeight: FontWeight.w500,
              ),
              child: title,
            ),
          ),
        ),
      ],
    );

    Widget? picture;

    if (image != null) {
      final String alt = step.imageAlt ?? (title is Text ? title.data ?? '' : '');
      final double? width = step.imageWidth;
      final double? height = step.imageHeight;

      Widget drawn = Image(
        image: image,
        fit: BoxFit.contain,
        width: double.infinity,
        semanticLabel: alt.isEmpty ? null : alt,
        excludeFromSemantics: alt.isEmpty,
      );

      // The picture's proportion, held before it arrives.
      if (width != null && height != null && width > 0 && height > 0) {
        drawn = AspectRatio(aspectRatio: width / height, child: drawn);
      }

      picture = Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radius[size]!),
          child: ConstrainedBox(constraints: const BoxConstraints(maxHeight: 288), child: drawn),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: 12,
            children: <Widget>[
              Expanded(child: heading),
              Text(
                position,
                style: TextStyle(
                  color: tokens.mutedFg,
                  fontSize: NebaScale.metaText[size],
                  height: 1.5,
                  fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        ?picture,
        if (content != null)
          DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: bodySize,
              height: NebaScale.sheetBodyLeading[size]! / bodySize,
            ),
            child: content,
          ),
      ],
    );
  }
}

/// The panel a finished guide shows: the success glyph and a sentence.
class _Finished extends StatelessWidget {
  const _Finished({required this.size, required this.accent, required this.child});

  final NebaSize size;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double bodySize = NebaScale.sheetBodyText[size]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: <Widget>[
          ExcludeSemantics(child: NebaGlyph(NebaGlyphs.success, size: 36, color: accent)),
          DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: bodySize,
              height: NebaScale.sheetBodyLeading[size]! / bodySize,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Every panel in one place: each at the full width, the place as tall as
/// the tallest, and every panel stretched to that height, as items in one CSS
/// grid cell are. So the finished panel stands centred in the height the
/// steps hold open, and nothing that moves in is clipped at the edge.
class _Cell extends MultiChildRenderObjectWidget {
  const _Cell({super.children});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderCell();
}

class _CellParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderCell extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _CellParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _CellParentData> {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _CellParentData) {
      child.parentData = _CellParentData();
    }
  }

  double _widest(double Function(RenderBox child) measure) {
    double widest = 0;

    for (RenderBox? child = firstChild; child != null; child = childAfter(child)) {
      widest = math.max(widest, measure(child));
    }

    return widest;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _widest((RenderBox child) => child.getMinIntrinsicWidth(height));
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _widest((RenderBox child) => child.getMaxIntrinsicWidth(height));
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _widest((RenderBox child) => child.getMinIntrinsicHeight(width));
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _widest((RenderBox child) => child.getMaxIntrinsicHeight(width));
  }

  BoxConstraints _across(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      maxHeight: constraints.maxHeight,
    );
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final BoxConstraints across = _across(constraints);
    final double height = _widest((RenderBox child) => child.getDryLayout(across).height);

    return constraints.constrain(Size(constraints.maxWidth, height));
  }

  @override
  void performLayout() {
    final BoxConstraints across = _across(constraints);
    double height = 0;

    for (RenderBox? child = firstChild; child != null; child = childAfter(child)) {
      child.layout(across, parentUsesSize: true);
      height = math.max(height, child.size.height);
    }

    size = constraints.constrain(Size(constraints.maxWidth, height));

    final BoxConstraints stretched = BoxConstraints.tight(size);

    for (RenderBox? child = firstChild; child != null; child = childAfter(child)) {
      child.layout(stretched);
    }
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

/// [child] laid out [by] pixels wider on each side and taller at the foot
/// than the box it is in, and drawn reaching out into that room: a negative
/// margin, for a scroll box that has to leave a focus ring room inside it
/// without moving what is in it.
class _Bleed extends SingleChildRenderObjectWidget {
  const _Bleed({required this.by, super.child});

  final double by;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderBleed(by);

  @override
  void updateRenderObject(BuildContext context, _RenderBleed renderObject) {
    renderObject.by = by;
  }
}

class _RenderBleed extends RenderShiftedBox {
  _RenderBleed(this._by) : super(null);

  double _by;

  set by(double value) {
    if (value != _by) {
      _by = value;
      markNeedsLayout();
    }
  }

  BoxConstraints _grown(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.minWidth + _by * 2,
      maxWidth: constraints.maxWidth + _by * 2,
      minHeight: constraints.minHeight + _by,
      maxHeight: constraints.maxHeight + _by,
    );
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return math.max(0, (child?.getMinIntrinsicWidth(height + _by) ?? 0) - _by * 2);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return math.max(0, (child?.getMaxIntrinsicWidth(height + _by) ?? 0) - _by * 2);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return math.max(0, (child?.getMinIntrinsicHeight(width + _by * 2) ?? 0) - _by);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return math.max(0, (child?.getMaxIntrinsicHeight(width + _by * 2) ?? 0) - _by);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final Size grown = child?.getDryLayout(_grown(constraints)) ?? Size.zero;

    return constraints.constrain(Size(grown.width - _by * 2, grown.height - _by));
  }

  @override
  void performLayout() {
    final RenderBox? child = this.child;

    if (child == null) {
      size = constraints.smallest;
      return;
    }

    child.layout(_grown(constraints), parentUsesSize: true);
    (child.parentData! as BoxParentData).offset = Offset(-_by, 0);
    size = constraints.constrain(Size(child.size.width - _by * 2, child.size.height - _by));
  }
}

/// The list beside the body: the list at its own width, the body in the
/// rest, both as tall as the taller of the two, so the divider down the
/// list's edge runs the whole height and the buttons sit at the body's foot.
class _SplitLayout extends MultiChildRenderObjectWidget {
  _SplitLayout({
    required this.railWidth,
    required this.gap,
    required Widget rail,
    required Widget body,
  }) : super(children: <Widget>[rail, body]);

  final double railWidth;
  final double gap;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSplit(railWidth: railWidth, gap: gap, textDirection: Directionality.of(context));
  }

  @override
  void updateRenderObject(BuildContext context, _RenderSplit renderObject) {
    renderObject
      ..railWidth = railWidth
      ..gap = gap
      ..textDirection = Directionality.of(context);
  }
}

class _SplitParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderSplit extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _SplitParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _SplitParentData> {
  _RenderSplit({
    required double railWidth,
    required double gap,
    required TextDirection textDirection,
  }) : _railWidth = railWidth,
       _gap = gap,
       _textDirection = textDirection;

  double _railWidth;

  set railWidth(double value) {
    if (value != _railWidth) {
      _railWidth = value;
      markNeedsLayout();
    }
  }

  double _gap;

  set gap(double value) {
    if (value != _gap) {
      _gap = value;
      markNeedsLayout();
    }
  }

  TextDirection _textDirection;

  set textDirection(TextDirection value) {
    if (value != _textDirection) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  RenderBox get _rail => firstChild!;

  RenderBox get _body => lastChild!;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _SplitParentData) {
      child.parentData = _SplitParentData();
    }
  }

  double _bodyWidth(BoxConstraints constraints) {
    final double available = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : _railWidth + _gap + _body.getMaxIntrinsicWidth(double.infinity);

    return math.max(0, available - _railWidth - _gap);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _railWidth + _gap + _body.getMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _railWidth + _gap + _body.getMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final double body = math.max(0, width - _railWidth - _gap);

    return math.max(_rail.getMinIntrinsicHeight(_railWidth), _body.getMinIntrinsicHeight(body));
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final double body = math.max(0, width - _railWidth - _gap);

    return math.max(_rail.getMaxIntrinsicHeight(_railWidth), _body.getMaxIntrinsicHeight(body));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final double body = _bodyWidth(constraints);
    final double height = math.max(
      _rail
          .getDryLayout(
            BoxConstraints(
              minWidth: _railWidth,
              maxWidth: _railWidth,
              maxHeight: constraints.maxHeight,
            ),
          )
          .height,
      _body
          .getDryLayout(
            BoxConstraints(minWidth: body, maxWidth: body, maxHeight: constraints.maxHeight),
          )
          .height,
    );

    return constraints.constrain(Size(_railWidth + _gap + body, height));
  }

  @override
  void performLayout() {
    final double body = _bodyWidth(constraints);

    // Each at its own height first, then both stretched to the taller.
    _rail.layout(
      BoxConstraints(minWidth: _railWidth, maxWidth: _railWidth, maxHeight: constraints.maxHeight),
      parentUsesSize: true,
    );
    _body.layout(
      BoxConstraints(minWidth: body, maxWidth: body, maxHeight: constraints.maxHeight),
      parentUsesSize: true,
    );

    final double height = constraints.constrainHeight(
      math.max(_rail.size.height, _body.size.height),
    );

    _rail.layout(BoxConstraints.tight(Size(_railWidth, height)));
    _body.layout(BoxConstraints.tight(Size(body, height)));

    final bool rtl = _textDirection == TextDirection.rtl;
    final double width = _railWidth + _gap + body;

    (_rail.parentData! as _SplitParentData).offset = Offset(rtl ? width - _railWidth : 0, 0);
    (_body.parentData! as _SplitParentData).offset = Offset(rtl ? 0 : _railWidth + _gap, 0);
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
