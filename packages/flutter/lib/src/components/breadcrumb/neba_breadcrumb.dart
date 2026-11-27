/// `NebaBreadcrumb` and `NebaBreadcrumbItem`, the trail of pages above the
/// one being read.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/link.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

enum _Mark { chevron, arrow, slash, dot }

/// What a [NebaBreadcrumb] draws between two steps.
///
/// Four named marks, because the difference between them is meaning: a
/// [chevron] and an [arrow] say "and then", a [slash] says "path", and a
/// [dot] says these are peers of one thing. Anything else is a widget.
@immutable
class NebaBreadcrumbSeparator {
  const NebaBreadcrumbSeparator._(this._mark) : child = null;

  /// A widget of the caller's own, drawn in the trail's muted ink.
  const NebaBreadcrumbSeparator.widget(Widget this.child) : _mark = null;

  /// A chevron pointing along the trail, turned back under a right-to-left
  /// direction.
  static const NebaBreadcrumbSeparator chevron = NebaBreadcrumbSeparator._(_Mark.chevron);

  /// An arrow pointing along the trail, turned back under a right-to-left
  /// direction.
  static const NebaBreadcrumbSeparator arrow = NebaBreadcrumbSeparator._(_Mark.arrow);

  /// A slash, as in a path.
  static const NebaBreadcrumbSeparator slash = NebaBreadcrumbSeparator._(_Mark.slash);

  /// A middle dot.
  static const NebaBreadcrumbSeparator dot = NebaBreadcrumbSeparator._(_Mark.dot);

  final _Mark? _mark;

  /// The widget drawn instead of a named mark.
  final Widget? child;
}

/// What a [NebaBreadcrumbItem] takes from the [NebaBreadcrumb] around it.
class _NebaBreadcrumbScope extends InheritedWidget {
  const _NebaBreadcrumbScope({
    required this.size,
    required this.color,
    required this.locale,
    required this.last,
    required this.focusNode,
    required super.child,
    super.key,
  });

  final NebaSize size;
  final NebaColor color;
  final Locale? locale;

  /// Whether this is the step the trail ends on, which is the current page
  /// unless another step says it is.
  final bool last;

  /// The focus node the trail hands the first step its fold was hiding, so
  /// it can take the focus from the fold once the fold opens.
  final FocusNode? focusNode;

  static _NebaBreadcrumbScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_NebaBreadcrumbScope>();
  }

  @override
  bool updateShouldNotify(_NebaBreadcrumbScope oldWidget) {
    return size != oldWidget.size ||
        color != oldWidget.color ||
        locale != oldWidget.locale ||
        last != oldWidget.last ||
        focusNode != oldWidget.focusNode;
  }
}

/// The trail of pages above the one being read, for any screen that sits in
/// a hierarchy the reader may want to climb back out of.
///
/// The last step is where the reader already is, so it is not pressable and
/// a screen reader hears it as the current one; a step's [current] moves
/// that mark. A trail longer than [maxItems] folds its middle away behind a
/// `…` that puts it back when pressed. The separators are drawn by the trail,
/// so a step never has to know whether anything follows it.
///
/// ```dart
/// NebaBreadcrumb(
///   children: <NebaBreadcrumbItem>[
///     NebaBreadcrumbItem(onPressed: openHome, child: const Text('Home')),
///     NebaBreadcrumbItem(onPressed: openProjects, child: const Text('Projects')),
///     const NebaBreadcrumbItem(child: Text('Settings')),
///   ],
/// )
/// ```
class NebaBreadcrumb extends StatefulWidget {
  /// A trail of [children].
  const NebaBreadcrumb({
    required this.children,
    this.size,
    this.color,
    this.density,
    this.separator = NebaBreadcrumbSeparator.chevron,
    this.maxItems,
    this.itemsBeforeCollapse = 1,
    this.itemsAfterCollapse = 1,
    this.expandable = true,
    this.locale,
    this.label,
    this.expandLabel,
    super.key,
  });

  /// The steps, from the top of the hierarchy down to the current page.
  final List<NebaBreadcrumbItem> children;

  /// The type scale. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family a pressable step is tinted with under the pointer, and its
  /// focus ring. Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// How tightly the steps pack, and nothing else. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The mark between two steps.
  final NebaBreadcrumbSeparator separator;

  /// How many steps are shown before the middle is folded away behind a `…`.
  /// Left out, the whole trail is shown however long it gets.
  final int? maxItems;

  /// How many steps stay at the front of a folded trail.
  final int itemsBeforeCollapse;

  /// How many steps stay at the end of a folded trail.
  final int itemsAfterCollapse;

  /// Whether pressing the `…` unfolds the trail. Off, the fold is a plain
  /// mark.
  final bool expandable;

  /// The language the trail and its `…` are named in. Defaults to
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// The name a screen reader hears for the trail. Defaults to the
  /// [locale]'s "Breadcrumb".
  final String? label;

  /// The name a screen reader hears for the `…`. Defaults to the [locale]'s
  /// wording.
  final String? expandLabel;

  /// The space between the steps and the marks, per density.
  static const Map<NebaDensity, Map<NebaSize, double>> gap = <NebaDensity, Map<NebaSize, double>>{
    NebaDensity.standard: <NebaSize, double>{
      NebaSize.xs: 4,
      NebaSize.sm: 6,
      NebaSize.md: 8,
      NebaSize.lg: 10,
      NebaSize.xl: 12,
    },
    NebaDensity.compact: <NebaSize, double>{
      NebaSize.xs: 2,
      NebaSize.sm: 4,
      NebaSize.md: 4,
      NebaSize.lg: 6,
      NebaSize.xl: 8,
    },
  };

  @override
  State<NebaBreadcrumb> createState() => _NebaBreadcrumbState();
}

class _NebaBreadcrumbState extends State<NebaBreadcrumb> {
  /// The trail the fold was opened for. A trail that stays where it is
  /// across a change of page is a new trail, and one unfolded on the last
  /// page folds again on this one, so what is kept is the trail rather than
  /// a flag.
  List<Object?>? _unfolded;

  final FocusNode _fold = FocusNode(debugLabel: 'NebaBreadcrumb fold');
  final FocusNode _firstHidden = FocusNode(debugLabel: 'NebaBreadcrumb first hidden step');

  @override
  void dispose() {
    _fold.dispose();
    _firstHidden.dispose();
    super.dispose();
  }

  /// What the trail is, as far as unfolding it goes: each step's key, its
  /// address and its words.
  static List<Object?> _trailOf(List<NebaBreadcrumbItem> steps) {
    return <Object?>[
      for (final NebaBreadcrumbItem step in steps) ...<Object?>[
        step.key,
        step.href,
        _textOf(step.child),
      ],
    ];
  }

  static String? _textOf(Widget? child) {
    return child is Text ? child.data ?? child.textSpan?.toPlainText() : null;
  }

  void _unfold(List<Object?> trail, int firstHidden) {
    // The `…` leaves the trail the moment it is pressed, which would drop the
    // focus it held, so the first step it was hiding takes it.
    final bool refocus = _fold.hasFocus;

    setState(() => _unfolded = trail);

    if (!refocus) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted || firstHidden >= widget.children.length) {
        return;
      }

      (widget.children[firstHidden].focusNode ?? _firstHidden).requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColor color = widget.color ?? NebaColor.primary;
    final Map<String, String> messages = nebaMessages(context, 'breadcrumb', locale: widget.locale);
    final List<NebaBreadcrumbItem> steps = widget.children;
    final int total = steps.length;
    final List<Object?> trail = _trailOf(steps);
    final List<Object?>? unfolded = _unfolded;
    final bool open = unfolded != null && listEquals(unfolded, trail);
    // Exactly one step is the current page: the last one, unless a step
    // says it is.
    final bool claimed = steps.any((NebaBreadcrumbItem step) => step.current ?? false);
    final int? maxItems = widget.maxItems;
    final bool folding =
        !open &&
        maxItems != null &&
        total > math.max(maxItems, 1) &&
        // A fold has to take away more than one step, or the `…` is longer
        // than what it stands for.
        total - widget.itemsBeforeCollapse - widget.itemsAfterCollapse > 1;
    final int before = math.max(0, widget.itemsBeforeCollapse);
    final int after = total - math.max(0, widget.itemsAfterCollapse);

    // What the row holds: every step, or the two ends with the fold, `null`,
    // between them.
    final List<int?> shown = <int?>[];

    for (int at = 0; at < total; at++) {
      if (folding && at == before) {
        shown.add(null);
      }

      if (!(folding && at >= before && at < after)) {
        shown.add(at);
      }
    }

    // A trail folded at its very end ends on the `…`, which is no step.
    final int lastShown = shown.isEmpty ? -1 : shown.last ?? -1;
    final Widget mark = _Separator(separator: widget.separator, size: size, tokens: tokens);

    final List<Widget> row = <Widget>[
      for (int i = 0; i < shown.length; i++) ...<Widget>[
        if (i > 0)
          KeyedSubtree(key: ValueKey<Object>(('mark', _keyOf(steps, shown[i]))), child: mark),
        if (shown[i] case final int at)
          _NebaBreadcrumbScope(
            key: ValueKey<Object>(('step', _keyOf(steps, at))),
            size: size,
            color: color,
            locale: widget.locale,
            last: !claimed && at == lastShown,
            focusNode: at == before ? _firstHidden : null,
            child: steps[at],
          )
        else
          _Fold(
            key: const ValueKey<String>('fold'),
            size: size,
            roles: tokens.roles(color),
            tokens: tokens,
            focusNode: _fold,
            label: widget.expandLabel ?? messages['expand']!,
            onPressed: widget.expandable ? () => _unfold(trail, before) : null,
          ),
      ],
    ];

    final double gap = NebaBreadcrumb.gap[density]![size]!;

    return Semantics(
      container: true,
      role: SemanticsRole.navigation,
      label: widget.label ?? messages['label'],
      explicitChildNodes: true,
      child: Semantics(
        container: true,
        role: SemanticsRole.list,
        explicitChildNodes: true,
        child: Wrap(
          spacing: gap,
          runSpacing: gap,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: row,
        ),
      ),
    );
  }

  /// A step's key, or its place in the trail when it has none, so a step is
  /// never rebuilt by the fold opening or closing.
  static Object _keyOf(List<NebaBreadcrumbItem> steps, int? at) {
    if (at == null) {
      return 'fold';
    }

    return steps[at].key ?? at;
  }
}

/// One step of a [NebaBreadcrumb].
///
/// A step with [onPressed] is a link when it has an [href] and a button
/// otherwise; a step with neither, and the step the reader is on, is text.
/// The package opens nothing itself, so following the link is [onPressed]'s.
///
/// ```dart
/// NebaBreadcrumbItem(
///   onPressed: openProjects,
///   href: Uri.parse('/projects'),
///   child: const Text('Projects'),
/// )
/// ```
class NebaBreadcrumbItem extends StatelessWidget {
  /// A step labelled [child].
  const NebaBreadcrumbItem({
    this.child,
    this.onPressed,
    this.href,
    this.newTab = false,
    this.startIcon,
    this.endIcon,
    this.current,
    this.disabled = false,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// The step's label, usually a [Text]. One line, cut short with an
  /// ellipsis when the row is too narrow.
  final Widget? child;

  /// What pressing the step does: usually the router going to that page.
  final VoidCallback? onPressed;

  /// Where the step leads, for a screen reader and, on the web, the browser.
  /// It makes a pressable step a link; a scheme other than `http`, `https`,
  /// `mailto` or `tel` is not written.
  final Uri? href;

  /// Whether the step's link leaves the app. A screen reader hears "(opens
  /// in a new tab)" after it; opening the tab is [onPressed]'s.
  final bool newTab;

  /// Before the label: a home glyph, a repository's avatar.
  final Widget? startIcon;

  /// After the label.
  final Widget? endIcon;

  /// Marks this step as the page the reader is on, which stops it being
  /// pressable. The last step is that page on its own, so this is for a
  /// trail that ends somewhere the reader is not; setting it on any step
  /// takes the mark off the last one.
  final bool? current;

  /// Unavailable: the step stops answering and keeps its place.
  final bool disabled;

  /// The focus node of a pressable step.
  final FocusNode? focusNode;

  /// Whether a pressable step takes the focus when it is first built.
  final bool autofocus;

  /// The step of the radius ladder a step's tint is cut at, well below the
  /// control ladder: a short line of text with a pill's corners would be a
  /// chip.
  static const Map<NebaSize, NebaSize> radiusStep = <NebaSize, NebaSize>{
    NebaSize.xs: NebaSize.xs,
    NebaSize.sm: NebaSize.xs,
    NebaSize.md: NebaSize.xs,
    NebaSize.lg: NebaSize.sm,
    NebaSize.xl: NebaSize.sm,
  };

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final _NebaBreadcrumbScope? trail = _NebaBreadcrumbScope.maybeOf(context);
    final NebaSize size = trail?.size ?? defaults.size ?? NebaSize.md;
    final NebaColorRoles roles = tokens.roles(trail?.color ?? NebaColor.primary);
    final bool isCurrent = current ?? trail?.last ?? false;
    final Uri? link = nebaSafeHref(href);
    final bool interactive = onPressed != null && !isCurrent && !disabled;
    final BorderRadius radius = BorderRadius.circular(tokens.radius[radiusStep[size]]!);

    _Step step(bool hovered) {
      return _Step(
        size: size,
        radius: radius,
        tint: interactive && hovered ? roles.soft : const Color(0x00000000),
        ink: disabled
            ? tokens.disabledFg
            : isCurrent
            ? tokens.fg
            : interactive && hovered
            ? roles.onTint
            : tokens.mutedFg,
        weight: isCurrent && !disabled ? FontWeight.w500 : null,
        startIcon: startIcon,
        endIcon: endIcon,
        note: interactive && newTab
            ? nebaMessages(context, 'link', locale: trail?.locale)['newTab']
            : null,
        child: child,
      );
    }

    Widget body;

    if (interactive) {
      body = Semantics(
        container: true,
        button: link == null,
        link: link != null,
        linkUrl: link,
        enabled: link == null ? true : null,
        child: NebaInteractive(
          onTap: onPressed,
          focusNode: focusNode ?? trail?.focusNode,
          autofocus: autofocus,
          activatesOnSpace: link == null,
          builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
            return NebaFocusRing(
              visible: interaction.focusVisible,
              color: roles.ring,
              borderRadius: radius,
              offset: 1,
              child: step(interaction.hovered),
            );
          },
        ),
      );
    } else {
      body = step(false);

      if (disabled) {
        body = MouseRegion(cursor: SystemMouseCursors.forbidden, child: body);
      }
    }

    // A step that is text is the list item itself, so a screen reader hears
    // the current page as the selected item; a pressable one is a link or a
    // button inside its item.
    return Semantics(
      container: true,
      role: trail != null ? SemanticsRole.listItem : null,
      selected: isCurrent ? true : null,
      enabled: !interactive && disabled ? false : null,
      child: body,
    );
  }
}

/// What a step draws: the tint, the icons and the label.
class _Step extends StatelessWidget {
  const _Step({
    required this.size,
    required this.radius,
    required this.tint,
    required this.ink,
    required this.weight,
    this.startIcon,
    this.endIcon,
    this.note,
    this.child,
  });

  final NebaSize size;
  final BorderRadius radius;
  final Color tint;
  final Color ink;
  final FontWeight? weight;
  final Widget? startIcon;
  final Widget? endIcon;
  final String? note;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final double text = NebaScale.controlText[size]!;
    final double leading = NebaScale.controlLeading[size]!;
    final Widget? child = this.child;
    final String? note = this.note;

    Widget? slot(Widget? icon) {
      return icon == null
          ? null
          : SizedBox(
              height: leading,
              child: Center(widthFactor: 1, child: icon),
            );
    }

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: tint),
      duration: nebaDuration(context, NebaScale.durationFill),
      curve: NebaScale.ease,
      builder: (BuildContext context, Color? fill, Widget? child) {
        return DecoratedBox(
          decoration: BoxDecoration(color: fill, borderRadius: radius),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: NebaInk(
          color: ink,
          child: DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: text,
              height: leading / text,
              // CSS shares a line's leading evenly above and below it.
              leadingDistribution: TextLeadingDistribution.even,
              fontWeight: weight,
            ),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            child: IconTheme.merge(
              data: IconThemeData(size: text * 1.2),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: NebaScale.gap[size]!,
                    children: <Widget>[
                      ?slot(startIcon),
                      if (child != null) Flexible(child: child),
                      ?slot(endIcon),
                    ],
                  ),
                  // Read to everybody and drawn for nobody, after the label.
                  if (note != null) Semantics(label: note, child: const SizedBox.shrink()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The `…` standing in for the steps a fold hides: a button that unfolds
/// the trail, or a plain mark nobody hears when it does not.
class _Fold extends StatelessWidget {
  const _Fold({
    required this.size,
    required this.roles,
    required this.tokens,
    required this.focusNode,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final NebaSize size;
  final NebaColorRoles roles;
  final NebaTokens tokens;
  final FocusNode focusNode;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final double glyph = NebaScale.controlText[size]! * 1.2;
    final BorderRadius radius = BorderRadius.circular(tokens.radius[NebaSize.xs]!);
    final VoidCallback? onPressed = this.onPressed;

    Widget fold(bool hovered) {
      return TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: hovered ? roles.soft : const Color(0x00000000)),
        duration: nebaDuration(context, NebaScale.durationFill),
        curve: NebaScale.ease,
        builder: (BuildContext context, Color? fill, Widget? child) {
          return DecoratedBox(
            decoration: BoxDecoration(color: fill, borderRadius: radius),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: NebaInk(
            color: hovered ? roles.onTint : tokens.mutedFg,
            child: NebaGlyph(NebaGlyphs.ellipsis, size: glyph),
          ),
        ),
      );
    }

    if (onPressed == null) {
      return ExcludeSemantics(child: fold(false));
    }

    return Semantics(
      container: true,
      role: SemanticsRole.listItem,
      child: Semantics(
        container: true,
        button: true,
        enabled: true,
        label: label,
        child: NebaInteractive(
          onTap: onPressed,
          focusNode: focusNode,
          builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
            return NebaFocusRing(
              visible: interaction.focusVisible,
              color: roles.ring,
              borderRadius: radius,
              offset: 1,
              child: fold(interaction.hovered),
            );
          },
        ),
      ),
    );
  }
}

/// The mark between two steps, in the trail's muted ink and never heard.
class _Separator extends StatelessWidget {
  const _Separator({required this.separator, required this.size, required this.tokens});

  final NebaBreadcrumbSeparator separator;
  final NebaSize size;
  final NebaTokens tokens;

  @override
  Widget build(BuildContext context) {
    final double text = NebaScale.controlText[size]!;
    final double glyph = text * 1.2;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    // The two marks of punctuation sit back a little from the steps.
    final Color faint = tokens.mutedFg.withValues(alpha: tokens.mutedFg.a * 0.7);

    final Widget mark = switch (separator._mark) {
      // The chevron is drawn pointing down and turned to point along the
      // trail, the one turn the design language allows a glyph.
      _Mark.chevron => RotatedBox(
        quarterTurns: rtl ? 1 : 3,
        child: NebaGlyph(NebaGlyphs.chevron, size: glyph),
      ),
      _Mark.arrow => RotatedBox(
        quarterTurns: rtl ? 2 : 0,
        child: NebaGlyph(NebaGlyphs.arrowRight, size: glyph),
      ),
      _Mark.slash => Text('/', style: TextStyle(color: faint)),
      _Mark.dot => Text('·', style: TextStyle(color: faint)),
      null => separator.child ?? const SizedBox.shrink(),
    };

    return ExcludeSemantics(
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: text,
          height: NebaScale.controlLeading[size]! / text,
          leadingDistribution: TextLeadingDistribution.even,
          color: tokens.mutedFg,
        ),
        child: IconTheme.merge(
          data: IconThemeData(size: glyph, color: tokens.mutedFg),
          child: mark,
        ),
      ),
    );
  }
}
