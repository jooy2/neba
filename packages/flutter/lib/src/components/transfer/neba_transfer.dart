/// `NebaTransfer`, two lists and the arrows between them.
library;

import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/checkbox/neba_checkbox.dart';
import 'package:neba/src/components/icon_button/neba_icon_button.dart';
import 'package:neba/src/components/scroll_area/neba_scroll_area.dart';
import 'package:neba/src/components/text_field/neba_text_field.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/live_region.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/search.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// One thing that can be on either side of a [NebaTransfer].
@immutable
class NebaTransferItem<T> {
  /// An item standing for [value], saying [label].
  const NebaTransferItem({required this.value, required this.label, this.disabled = false});

  /// What identifies it, and what the transfer's value is a list of.
  final T value;

  /// What the row says, usually a [Text]. A `Text` is also what a search
  /// matches; a row with any other widget stays through every search.
  final Widget label;

  /// In the list, but never ticked or moved.
  final bool disabled;
}

/// Two lists and the arrows between them, generic over the type of the
/// items' values: everything that could be chosen on one side, everything
/// that has been on the other.
///
/// It is the shape for a choice that is long, the columns in a report, the
/// permissions on a role, the people on a channel, where a field of forty
/// chips stops being readable and forty checkboxes give no answer to "what
/// did I pick". Ticking a row says which rows the next press of an arrow
/// moves; the value says which side they are on, so ticking is not choosing.
/// Both lists show the rows in the order of [items], so a row does not move
/// when it is sent across and back, and the rows that a press sent across
/// fade up on the side they reached.
///
/// It fills the width it is given, a list on each side of the arrows.
///
/// ```dart
/// NebaTransfer<String>(
///   items: const <NebaTransferItem<String>>[
///     NebaTransferItem<String>(value: 'status', label: Text('Status')),
///     NebaTransferItem<String>(value: 'commit', label: Text('Commit')),
///   ],
///   value: shown,
///   onValueChange: (List<String> next) => setState(() => shown = next),
/// )
/// ```
class NebaTransfer<T> extends StatefulWidget {
  /// A transfer between two lists of [items].
  const NebaTransfer({
    required this.items,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.sourceLabel,
    this.targetLabel,
    this.searchable = false,
    this.height = 220,
    this.disabled = false,
    this.locale,
    this.variant,
    this.size,
    this.color,
    this.density,
    super.key,
  }) : assert(height > 0);

  /// Everything that can be on either side, in the order the lists show it.
  final List<NebaTransferItem<T>> items;

  /// The values on the right, for a controlled transfer. Leave it `null` and
  /// the transfer keeps its own state, starting from [defaultValue].
  final List<T>? value;

  /// What starts on the right, for an uncontrolled transfer.
  final List<T>? defaultValue;

  /// Called with the values on the right after an arrow moves something.
  final ValueChanged<List<T>>? onValueChange;

  /// The heading over the left-hand list, usually a [Text]. Defaults to the
  /// [locale]'s word.
  final Widget? sourceLabel;

  /// The heading over the right-hand list.
  final Widget? targetLabel;

  /// Puts a filter above each list. It hides rows and never moves them, and
  /// a row it hides is not part of the next press.
  final bool searchable;

  /// How tall each list is, in logical pixels.
  final double height;

  /// Nothing can be ticked or moved.
  final bool disabled;

  /// Which language the headings, the arrows, the filter and what a screen
  /// reader is told after a move are in. Defaults to `NebaProvider`'s, then
  /// the app's.
  final Locale? locale;

  /// The weight of each list's sheet, a field's. Defaults to
  /// `NebaProvider`'s, then [NebaVariant.outline].
  final NebaVariant? variant;

  /// The rows, the ticks, the type and the arrows. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the ticks, the arrows and each sheet's edge. Defaults to
  /// [NebaColor.primary].
  final NebaColor? color;

  /// The padding inside each list, and nothing else. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  @override
  State<NebaTransfer<T>> createState() => _NebaTransferState<T>();
}

/// Above and below a list's heading, its filter and its rows.
const Map<NebaSize, double> _panelPadY = <NebaSize, double>{
  NebaSize.xs: 4,
  NebaSize.sm: 6,
  NebaSize.md: 8,
  NebaSize.lg: 10,
  NebaSize.xl: 12,
};

/// Above and below a row.
const Map<NebaSize, double> _rowPadY = <NebaSize, double>{
  NebaSize.xs: 2,
  NebaSize.sm: 4,
  NebaSize.md: 4,
  NebaSize.lg: 6,
  NebaSize.xl: 8,
};

/// How long a screen reader's region stays empty before it speaks again:
/// long enough for every screen reader to notice the words went away.
const Duration _speakAfter = Duration(milliseconds: 100);

class _NebaTransferState<T> extends State<NebaTransfer<T>> {
  late List<T> _own = <T>[...?widget.defaultValue];
  final TextEditingController _sourceSearch = TextEditingController();
  final TextEditingController _targetSearch = TextEditingController();
  Set<T> _ticked = <T>{};
  // What the last press moved, so the side it landed on can say which.
  Set<T> _arrived = <T>{};
  // What a screen reader is told after a move.
  String _spoken = '';
  Timer? _speak;

  // Every label folded once, by the item it belongs to.
  List<NebaTransferItem<T>>? _indexed;
  Map<T, String> _haystacks = <T, String>{};

  List<T> get _selected => widget.value ?? _own;

  @override
  void initState() {
    super.initState();
    _sourceSearch.addListener(_rebuild);
    _targetSearch.addListener(_rebuild);
  }

  @override
  void dispose() {
    _speak?.cancel();
    _sourceSearch.dispose();
    _targetSearch.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (!mounted) {
      return;
    }

    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((Duration _) {
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      setState(() {});
    }
  }

  /// The folded words of every label that is a `Text`. A label that is any
  /// other widget has no words to match and is left out, so its row stays
  /// through a search it could never satisfy rather than vanishing from it.
  Map<T, String> _haystacksOf(List<NebaTransferItem<T>> items) {
    if (!identical(items, _indexed)) {
      _indexed = items;
      _haystacks = <T, String>{
        for (final NebaTransferItem<T> item in items)
          if (nebaPlainText(item.label) case final String words) item.value: nebaSearchText(words),
      };
    }

    return _haystacks;
  }

  List<NebaTransferItem<T>> _narrow(List<NebaTransferItem<T>> rows, String query) {
    final String needle = nebaSearchText(query);

    if (needle.isEmpty) {
      return rows;
    }

    final Map<T, String> haystacks = _haystacksOf(widget.items);

    return <NebaTransferItem<T>>[
      for (final NebaTransferItem<T> row in rows)
        if (haystacks[row.value] case final String? haystack
            when haystack == null || haystack.contains(needle))
          row,
    ];
  }

  void _commit(List<T> next) {
    if (widget.value == null) {
      setState(() => _own = next);
    }

    widget.onValueChange?.call(next);
  }

  void _tick(T value, bool on) {
    setState(() {
      _ticked = on ? <T>{..._ticked, value} : (<T>{..._ticked}..remove(value));
    });
  }

  void _tickAll(List<NebaTransferItem<T>> rows, bool on) {
    setState(() {
      final Set<T> next = <T>{..._ticked};

      for (final NebaTransferItem<T> row in rows) {
        if (row.disabled) {
          continue;
        }

        on ? next.add(row.value) : next.remove(row.value);
      }

      _ticked = next;
    });
  }

  /// Moves the ticked rows of [rows] across, and drops their ticks: a row
  /// that has arrived on the other side is not still waiting to be sent
  /// there, and a row the filter was hiding was never part of this press.
  void _move(
    List<NebaTransferItem<T>> rows, {
    required bool toTarget,
    required Map<String, String> messages,
  }) {
    final List<NebaTransferItem<T>> moved = <NebaTransferItem<T>>[
      for (final NebaTransferItem<T> row in rows)
        if (!row.disabled && _ticked.contains(row.value)) row,
    ];

    if (moved.isEmpty) {
      return;
    }

    final Set<T> ids = <T>{for (final NebaTransferItem<T> row in moved) row.value};
    final Set<T> chosen = _selected.toSet();
    // A value that `items` does not list, a row not loaded yet or one the
    // caller filtered out, stays whichever way rows are moved.
    final Set<T> known = <T>{for (final NebaTransferItem<T> item in widget.items) item.value};
    final List<T> next = toTarget
        ? <T>[
            for (final NebaTransferItem<T> item in widget.items)
              if (chosen.contains(item.value) || ids.contains(item.value)) item.value,
            for (final T value in _selected)
              if (!known.contains(value)) value,
          ]
        : <T>[
            for (final T value in _selected)
              if (!ids.contains(value)) value,
          ];

    setState(() {
      _ticked = <T>{
        for (final T value in _ticked)
          if (!ids.contains(value)) value,
      };
      _arrived = ids;
    });
    _commit(next);

    final String? landed = nebaPlainText(toTarget ? widget.targetLabel : widget.sourceLabel);
    final String list = landed != null && landed.trim().isNotEmpty
        ? landed
        : messages[toTarget ? 'target' : 'source']!;
    final String text = fillNebaMessage(messages['moved']!, <String, String>{
      'count': '${moved.length}',
      'list': list,
    });

    // A region speaks only when its words change, so two moves of the same
    // count to the same list would say the second to nobody: it is emptied
    // and written again a moment later.
    _speak?.cancel();
    setState(() => _spoken = '');
    _speak = Timer(_speakAfter, () {
      if (mounted) {
        setState(() => _spoken = text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColor color = widget.color ?? NebaColor.primary;
    final Locale? locale = widget.locale ?? defaults.locale;
    final Map<String, String> messages = nebaMessages(context, 'transfer', locale: locale);
    final bool disabled = widget.disabled;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final Set<T> chosen = _selected.toSet();
    final List<NebaTransferItem<T>> source = <NebaTransferItem<T>>[
      for (final NebaTransferItem<T> item in widget.items)
        if (!chosen.contains(item.value)) item,
    ];
    final List<NebaTransferItem<T>> target = <NebaTransferItem<T>>[
      for (final NebaTransferItem<T> item in widget.items)
        if (chosen.contains(item.value)) item,
    ];
    final List<NebaTransferItem<T>> sourceRows = _narrow(source, _sourceSearch.text);
    final List<NebaTransferItem<T>> targetRows = _narrow(target, _targetSearch.text);
    final bool canSend = sourceRows.any(
      (NebaTransferItem<T> row) => !row.disabled && _ticked.contains(row.value),
    );
    final bool canReturn = targetRows.any(
      (NebaTransferItem<T> row) => !row.disabled && _ticked.contains(row.value),
    );

    Widget panel(
      Widget? title,
      String fallback,
      List<NebaTransferItem<T>> rows,
      TextEditingController search,
    ) {
      return _Panel<T>(
        title: title ?? Text(fallback),
        rows: rows,
        arrived: _arrived,
        ticked: _ticked,
        onTick: _tick,
        onTickAll: (bool on) => _tickAll(rows, on),
        search: widget.searchable ? search : null,
        disabled: disabled,
        height: widget.height,
        emptyMessage: messages['empty']!,
        searchLabel: messages['search']!,
        selectAllLabel: messages['selectAll']!,
        variant: variant,
        size: size,
        color: color,
        density: density,
      );
    }

    // A rotation is physical, so under RTL, where the lists swap sides, both
    // arrows turn back the other way. Turning a glyph is the one transform
    // the design language allows.
    Widget arrow({required bool forward}) {
      return RotatedBox(
        quarterTurns: forward == !rtl ? 0 : 2,
        child: NebaGlyph(NebaGlyphs.arrowRight),
      );
    }

    final NebaVariant buttons = variant == NebaVariant.text
        ? NebaVariant.text
        : NebaVariant.outline;

    return Stack(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: panel(widget.sourceLabel, messages['source']!, sourceRows, _sourceSearch),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: <Widget>[
                NebaIconButton(
                  size: size,
                  color: color,
                  variant: buttons,
                  label: messages['toTarget']!,
                  disabled: disabled || !canSend,
                  // A press that moves every ticked row runs the button
                  // out, and a disabled button would drop the focus.
                  focusableWhenDisabled: !disabled,
                  onPressed: () => _move(sourceRows, toTarget: true, messages: messages),
                  icon: arrow(forward: true),
                ),
                NebaIconButton(
                  size: size,
                  color: color,
                  variant: buttons,
                  label: messages['toSource']!,
                  disabled: disabled || !canReturn,
                  focusableWhenDisabled: !disabled,
                  onPressed: () => _move(targetRows, toTarget: false, messages: messages),
                  icon: arrow(forward: false),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: panel(widget.targetLabel, messages['target']!, targetRows, _targetSearch),
            ),
          ],
        ),
        Positioned(
          left: 0,
          top: 0,
          child: NebaLiveRegion(
            role: SemanticsRole.status,
            child: Semantics(label: _spoken, child: const SizedBox.shrink()),
          ),
        ),
      ],
    );
  }
}

/// One side: a heading with its select-all tick and its count, a filter,
/// and the rows, on a field's sheet that lifts under the pointer and rings
/// its edge while anything in it holds the focus.
class _Panel<T> extends StatefulWidget {
  const _Panel({
    required this.title,
    required this.rows,
    required this.arrived,
    required this.ticked,
    required this.onTick,
    required this.onTickAll,
    required this.search,
    required this.disabled,
    required this.height,
    required this.emptyMessage,
    required this.searchLabel,
    required this.selectAllLabel,
    required this.variant,
    required this.size,
    required this.color,
    required this.density,
  });

  final Widget title;
  final List<NebaTransferItem<T>> rows;
  final Set<T> arrived;
  final Set<T> ticked;
  final void Function(T value, bool on) onTick;
  final ValueChanged<bool> onTickAll;
  final TextEditingController? search;
  final bool disabled;
  final double height;
  final String emptyMessage;
  final String searchLabel;
  final String selectAllLabel;
  final NebaVariant variant;
  final NebaSize size;
  final NebaColor color;
  final NebaDensity density;

  @override
  State<_Panel<T>> createState() => _PanelState<T>();
}

class _PanelState<T> extends State<_Panel<T>> {
  bool _hovered = false;
  bool _focused = false;

  void _later(VoidCallback change) {
    if (!mounted) {
      return;
    }

    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((Duration _) {
        if (mounted) {
          setState(change);
        }
      });
    } else {
      setState(change);
    }
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaSize size = widget.size;
    final NebaColorRoles roles = tokens.roles(widget.color);
    final List<NebaTransferItem<T>> rows = widget.rows;
    final List<NebaTransferItem<T>> movable = <NebaTransferItem<T>>[
      for (final NebaTransferItem<T> row in rows)
        if (!row.disabled) row,
    ];
    final int tickedHere = movable
        .where((NebaTransferItem<T> row) => widget.ticked.contains(row.value))
        .length;
    final bool all = movable.isNotEmpty && tickedHere == movable.length;
    final bool some = tickedHere > 0 && !all;
    final double insetX = NebaScale.paddingX[widget.density]![size]!;
    final double padY = _panelPadY[size]!;
    final double meta = NebaScale.metaText[size]!;
    final TextEditingController? search = widget.search;
    final String? heading = nebaPlainText(widget.title);
    final NebaFieldLook look = NebaFieldLook.of(
      tokens: tokens,
      roles: roles,
      variant: widget.variant,
      elevation: 0,
      disabled: false,
      readOnly: false,
      hovered: _hovered,
      focused: _focused,
    );
    final BorderRadius radius = BorderRadius.circular(tokens.radius[size]!);

    final Widget header = Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: tokens.border)),
      ),
      padding: EdgeInsets.symmetric(horizontal: insetX, vertical: padY),
      child: Row(
        spacing: 8,
        children: <Widget>[
          NebaCheckbox(
            size: size,
            color: widget.color,
            checked: all,
            indeterminate: some,
            disabled: widget.disabled || movable.isEmpty,
            semanticLabel: widget.selectAllLabel,
            onCheckedChange: widget.onTickAll,
          ),
          Expanded(
            child: ExcludeSemantics(
              excluding: heading != null,
              child: DefaultTextStyle.merge(
                style: TextStyle(fontSize: meta, fontWeight: FontWeight.w500),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                child: widget.title,
              ),
            ),
          ),
          Text(
            '$tickedHere/${rows.length}',
            style: TextStyle(
              fontSize: meta,
              color: tokens.mutedFg,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );

    final Widget list = NebaScrollArea(
      size: size,
      color: widget.color,
      height: widget.height,
      fade: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: insetX, vertical: padY),
        child: rows.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: _rowPadY[size]!),
                child: Text(
                  widget.emptyMessage,
                  style: TextStyle(fontSize: meta, color: tokens.mutedFg),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final NebaTransferItem<T> row in rows)
                    _Arrival(
                      key: ValueKey<Object?>(row.value),
                      arrived: widget.arrived.contains(row.value),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: _rowPadY[size]!),
                        child: NebaCheckbox(
                          size: size,
                          color: widget.color,
                          label: row.label,
                          checked: widget.ticked.contains(row.value),
                          disabled: widget.disabled || row.disabled,
                          onCheckedChange: (bool on) => widget.onTick(row.value, on),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );

    // A group named by its heading, so the two select-all ticks and the two
    // filters, which are the same controls, are heard with the list each
    // belongs to.
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: heading,
      child: MouseRegion(
        onEnter: (PointerEnterEvent _) => setState(() => _hovered = true),
        onExit: (PointerExitEvent _) => setState(() => _hovered = false),
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          includeSemantics: false,
          onFocusChange: (bool focused) {
            if (focused != _focused) {
              _later(() => _focused = focused);
            }
          },
          child: NebaSheet(
            fill: look.fill,
            edge: look.edge,
            plate: look.plate,
            elevation: look.elevation,
            borderRadius: radius,
            blur: look.textured,
            texture: look.textured,
            fillDuration: _focused ? NebaScale.duration : null,
            child: ClipRRect(
              borderRadius: radius,
              child: NebaInk(
                color: look.ink,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    header,
                    if (search != null)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: insetX, vertical: padY),
                        child: NebaTextField(
                          controller: search,
                          size: size,
                          color: widget.color,
                          density: widget.density,
                          variant: NebaVariant.text,
                          fullWidth: true,
                          disabled: widget.disabled,
                          placeholder: widget.searchLabel,
                          semanticLabel: widget.searchLabel,
                        ),
                      ),
                    list,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A row that has just been sent to this side, fading up at the pace a
/// picture arrives rather than the pace a control answers a pointer: what it
/// says is "these are the ones that moved". It plays when the row arrives,
/// never when a search uncovers it.
class _Arrival extends StatelessWidget {
  const _Arrival({required this.arrived, required this.child, super.key});

  final bool arrived;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: arrived ? 0 : 1, end: 1),
      duration: nebaDuration(context, NebaScale.durationFill),
      curve: NebaScale.ease,
      builder: (BuildContext context, double opacity, Widget? child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: child,
    );
  }
}
