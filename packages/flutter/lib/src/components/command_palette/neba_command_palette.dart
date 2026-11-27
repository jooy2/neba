/// `NebaCommandPalette`, everything an application can do behind one field.
library;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/shortcut/neba_shortcut.dart';
import 'package:neba/src/internal/button_group.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/keys.dart';
import 'package:neba/src/internal/listbox.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/modal.dart';
import 'package:neba/src/internal/search.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// One thing a [NebaCommandPalette] can do.
@immutable
class NebaCommandItem {
  /// A command called [label].
  const NebaCommandItem({
    required this.value,
    required this.label,
    this.description,
    this.icon,
    this.shortcut,
    this.group,
    this.keywords = const <String>[],
    this.disabled = false,
    this.onSelect,
  });

  /// What identifies the command.
  final String value;

  /// What the row says, and what the query is matched against.
  final String label;

  /// A second line under it, usually a [Text]: where the command goes, or
  /// what it changes.
  final Widget? description;

  /// A glyph before the label.
  final Widget? icon;

  /// The keystroke that does the same thing, drawn at the end of the row as a
  /// `NebaShortcut` draws it, so `Mod` reads per platform. The palette does
  /// not bind it; the app does.
  final String? shortcut;

  /// The heading the command sits under. Commands are drawn in the order they
  /// are given, and a heading is drawn each time the group changes, so a
  /// group's commands have to be listed together.
  final String? group;

  /// Words the query is matched against that are never drawn: another
  /// product's name for the same command, an abbreviation, the word a reader
  /// would have searched for.
  final List<String> keywords;

  /// In the list but not runnable.
  final bool disabled;

  /// What running it does.
  final VoidCallback? onSelect;
}

/// The field's height at each size.
const Map<NebaSize, double> _inputHeight = <NebaSize, double>{
  NebaSize.xs: 36,
  NebaSize.sm: 40,
  NebaSize.md: 48,
  NebaSize.lg: 56,
  NebaSize.xl: 64,
};

/// The padding along a row's ends, the field's and a heading's.
const Map<NebaSize, double> _insetX = <NebaSize, double>{
  NebaSize.xs: 10,
  NebaSize.sm: 12,
  NebaSize.md: 14,
  NebaSize.lg: 16,
  NebaSize.xl: 20,
};

/// The padding above and below a row's text.
const Map<NebaSize, double> _rowPadY = <NebaSize, double>{
  NebaSize.xs: 4,
  NebaSize.sm: 6,
  NebaSize.md: 8,
  NebaSize.lg: 10,
  NebaSize.xl: 12,
};

/// A run of rows that share a group, in the order they were given, with each
/// row's place in the whole list, which is what the highlight moves through.
class _Run {
  _Run(this.group);

  final String? group;
  final List<int> places = <int>[];
}

/// Everything an application can do, behind one field.
///
/// A modal sheet near the top of the window with a field over a list of
/// commands, opened by a keystroke bound on the whole app ([shortcut],
/// `Mod+K` by default) or by [open]. What is typed narrows the list, matched
/// against each command's label, group and [NebaCommandItem.keywords] with
/// case and accents folded away; the arrow keys and the pointer move one
/// highlight, Enter or a press runs the command, and the palette closes and
/// forgets the query.
///
/// It is not a menu, a short list in one place with every row in sight, and
/// it is not a combobox: what comes back is not a value, it is something
/// happening. It builds nothing where it is written.
///
/// ```dart
/// NebaCommandPalette(
///   items: <NebaCommandItem>[
///     NebaCommandItem(value: 'deploy', label: 'Deploy production', group: 'Actions', onSelect: deploy),
///     const NebaCommandItem(value: 'logs', label: 'Go to logs', group: 'Navigate'),
///   ],
/// )
/// ```
class NebaCommandPalette extends StatefulWidget {
  /// A palette of [items].
  const NebaCommandPalette({
    required this.items,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.onSelect,
    this.shortcut = 'Mod+K',
    this.width,
    this.maxHeight = nebaListMaxHeight,
    this.locale,
    this.placeholder,
    this.emptyMessage,
    this.label,
    this.size,
    this.color,
    this.density,
    super.key,
  }) : assert(width == null || width > 0),
       assert(maxHeight > 0);

  /// Everything the palette can do.
  final List<NebaCommandItem> items;

  /// Whether the palette is open, when the caller holds it, with
  /// [onOpenChange].
  final bool? open;

  /// Whether an uncontrolled palette starts open.
  final bool defaultOpen;

  /// Called with whether the palette should be open: the [shortcut], Escape,
  /// a press on the scrim and a command that ran.
  final ValueChanged<bool>? onOpenChange;

  /// Called when a command is run, after its own `onSelect`. The palette
  /// closes either way.
  final ValueChanged<NebaCommandItem>? onSelect;

  /// The keystroke that opens the palette, bound on the whole app whatever
  /// holds the focus, written as `NebaShortcut` writes it, so `Mod` is
  /// Command on a Mac and Control everywhere else. `null` binds nothing.
  final String? shortcut;

  /// How wide the sheet may get, in place of the width [size] gives it.
  final double? width;

  /// How tall the list may get before it scrolls.
  final double maxHeight;

  /// The language of the placeholder, the empty line and the dialog's own
  /// name. Defaults to `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// The placeholder in the field. Defaults to the [locale]'s words.
  final String? placeholder;

  /// The line where the rows would be when nothing matched, usually a
  /// [Text].
  final Widget? emptyMessage;

  /// What a screen reader names the dialog, which has no visible title.
  final String? label;

  /// The type scale, the field's height and how wide the sheet may get.
  /// Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The colour family of the edges, the caret and the highlight. Defaults to
  /// [NebaColor.primary].
  final NebaColor? color;

  /// Compact rows stand closer together. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// How wide the sheet may get at each size, CSS `max-w-sm` to `max-w-3xl`.
  static const Map<NebaSize, double> maxWidths = <NebaSize, double>{
    NebaSize.xs: 384,
    NebaSize.sm: 448,
    NebaSize.md: 576,
    NebaSize.lg: 672,
    NebaSize.xl: 768,
  };

  @override
  State<NebaCommandPalette> createState() => _NebaCommandPaletteState();
}

class _NebaCommandPaletteState extends State<NebaCommandPalette>
    implements TextSelectionGestureDetectorBuilderDelegate {
  late bool _own = widget.defaultOpen;
  final TextEditingController _query = TextEditingController();
  final FocusNode _field = FocusNode(debugLabel: 'NebaCommandPalette field');
  final GlobalKey<EditableTextState> _editableKey = GlobalKey<EditableTextState>();
  final ScrollController _scroll = ScrollController();
  late final NebaFieldGestures _gestures = NebaFieldGestures(delegate: this);
  NebaKeyCombo? _combo;

  /// The haystacks of the items they were folded from, folded only while the
  /// palette is open.
  List<NebaCommandItem>? _folded;
  List<String> _haystacks = const <String>[];

  int? _highlight;
  bool _reveal = false;

  bool get _open => widget.open ?? _own;

  @override
  GlobalKey<EditableTextState> get editableTextKey => _editableKey;

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => true;

  @override
  void initState() {
    super.initState();
    _query.addListener(_queryChanged);
    _bind();
  }

  @override
  void didUpdateWidget(NebaCommandPalette oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.shortcut != oldWidget.shortcut) {
      _bind();
    }

    final bool was = oldWidget.open ?? _own;

    if (was && !_open) {
      _closed();
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onGlobalKey);
    _query.dispose();
    _field.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _bind() {
    final String? shortcut = widget.shortcut;

    HardwareKeyboard.instance.removeHandler(_onGlobalKey);
    _combo = shortcut == null ? null : NebaKeyCombo.parse(shortcut);

    if (_combo != null) {
      HardwareKeyboard.instance.addHandler(_onGlobalKey);
    }
  }

  /// The [shortcut], heard whatever holds the focus, a field included. It
  /// asks to open only while the palette is shut.
  bool _onGlobalKey(KeyEvent event) {
    final NebaKeyCombo? combo = _combo;

    if (!mounted || combo == null || !combo.accepts(event, HardwareKeyboard.instance)) {
      return false;
    }

    if (!_open) {
      _setOpen(true);
    }

    return true;
  }

  void _setOpen(bool open) {
    if (open == _open) {
      return;
    }

    if (widget.open == null) {
      setState(() => _own = open);
    }

    widget.onOpenChange?.call(open);

    if (!open && widget.open == null) {
      _closed();
    }
  }

  /// The query is dropped on the way out rather than on the way in, so the
  /// sheet never flashes the last search as it opens, whichever way it
  /// closed: Escape or the scrim, a command, or a caller's `open`.
  void _closed() {
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted && !_open) {
        _query.clear();
        setState(() => _highlight = null);
      }
    });
  }

  void _queryChanged() {
    if (_highlight != null) {
      setState(() => _highlight = null);
    } else {
      setState(() {});
    }
  }

  /// The items that match what is typed, folding them once per list and only
  /// while the palette is open.
  List<int> _filtered() {
    final List<NebaCommandItem> items = widget.items;
    final String needle = nebaSearchText(_query.text);

    if (needle.isEmpty) {
      return <int>[for (int index = 0; index < items.length; index++) index];
    }

    if (!identical(_folded, items)) {
      _folded = items;
      _haystacks = <String>[
        for (final NebaCommandItem item in items)
          <Object?>[item.label, item.group, ...item.keywords].map(nebaSearchText).join('\u0000'),
      ];
    }

    return <int>[
      for (int index = 0; index < items.length; index++)
        if (_haystacks[index].contains(needle)) index,
    ];
  }

  void _run(NebaCommandItem item) {
    if (item.disabled) {
      return;
    }

    item.onSelect?.call();
    widget.onSelect?.call(item);
    _setOpen(false);
  }

  /// A touch keyboard's action key: it runs the highlighted command, as
  /// Enter does, and otherwise leaves the focus in the field, which the
  /// editable gives up when it is submitted.
  void _submitted() {
    final List<int> shown = _filtered();
    final int? highlight = _highlight;

    if (highlight != null && highlight < shown.length) {
      _run(widget.items[shown[highlight]]);
    } else {
      _field.requestFocus();
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }

    final LogicalKeyboardKey key = event.logicalKey;
    final List<int> shown = _filtered();

    if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.arrowUp) {
      if (shown.isEmpty) {
        return KeyEventResult.handled;
      }

      final bool down = key == LogicalKeyboardKey.arrowDown;
      final int? current = _highlight;
      bool enabled(int at) => !widget.items[shown[at]].disabled;
      int? moved;

      if (current == null || current >= shown.length) {
        for (int step = 0; step < shown.length; step++) {
          final int at = down ? step : shown.length - 1 - step;

          if (enabled(at)) {
            moved = at;
            break;
          }
        }
      } else {
        moved = nebaRovingTarget(
          event,
          current: current,
          count: shown.length,
          axis: Axis.vertical,
          textDirection: Directionality.of(context),
          loop: true,
          focusable: enabled,
        );
      }

      setState(() {
        _highlight = moved ?? current;
        _reveal = true;
      });

      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      final int? highlight = _highlight;

      if (event is KeyDownEvent && highlight != null && highlight < shown.length) {
        _run(widget.items[shown[highlight]]);
      }

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final String label =
        widget.label ?? nebaMessages(context, 'command', locale: widget.locale)['label']!;

    return NebaModalLayer(
      open: _open,
      onDismiss: () => _setOpen(false),
      label: label,
      initialFocus: _field,
      builder: _sheet,
    );
  }

  Widget _sheet(BuildContext context, Animation<double> arrival) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColorRoles roles = tokens.roles(widget.color ?? NebaColor.primary);
    final Map<String, String> words = nebaMessages(context, 'command', locale: widget.locale);
    final MediaQueryData media = nebaModalMedia(context);
    final EdgeInsets screen = media.padding + media.viewInsets;
    final double text = NebaScale.controlText[size]!;
    final double leading = NebaScale.controlLeading[size]!;
    final double meta = NebaScale.metaText[size]!;
    final double insetX = _insetX[size]!;
    final BorderRadius radius = BorderRadius.circular(tokens.radius[size]!);
    final List<int> shown = _filtered();
    final String placeholder = widget.placeholder ?? words['search']!;
    final NebaFieldSemantics semantics = NebaFieldSemantics.of(placeholder: placeholder);

    final Widget field = Semantics(
      container: true,
      label: semantics.label,
      child: NebaFieldEditable(
        editableKey: _editableKey,
        controller: _query,
        focusNode: _field,
        style: nebaFieldTextStyle(context, tokens: tokens, size: size, disabled: false),
        roles: roles,
        empty: _query.text.isEmpty,
        placeholder: placeholder,
        textInputAction: TextInputAction.go,
        onSubmitted: (String _) => _submitted(),
        onKeyEvent: _onKey,
      ),
    );

    final Widget header = DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: roles.line)),
      ),
      child: _gestures.wrap(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: insetX),
          child: SizedBox(
            height: _inputHeight[size],
            child: Align(alignment: AlignmentDirectional.centerStart, child: field),
          ),
        ),
        disabled: false,
      ),
    );

    final List<_Run> runs = <_Run>[];

    for (int place = 0; place < shown.length; place++) {
      final String? group = widget.items[shown[place]].group;

      if (runs.isEmpty || runs.last.group != group) {
        runs.add(_Run(group));
      }

      runs.last.places.add(place);
    }

    Widget row(int place) {
      final NebaCommandItem item = widget.items[shown[place]];
      final Widget? icon = item.icon;
      final Widget? description = item.description;
      final String? shortcut = item.shortcut;

      return NebaListRow(
        key: ValueKey<String>(item.value),
        roles: roles,
        highlighted: place == _highlight,
        reveal: _reveal,
        disabled: item.disabled,
        wash: roles.soft,
        borderRadius: radius,
        padding: EdgeInsets.symmetric(
          horizontal: insetX,
          vertical: _rowPadY[density == NebaDensity.compact ? NebaSize.xs : size]!,
        ),
        onHover: () {
          if (_highlight != place || _reveal) {
            setState(() {
              _highlight = place;
              _reveal = false;
            });
          }
        },
        onExit: () {
          if (_highlight == place && !_reveal) {
            setState(() => _highlight = null);
          }
        },
        onPressed: () => _run(item),
        child: Row(
          spacing: 12,
          children: <Widget>[
            if (icon != null)
              SizedBox(
                height: leading,
                child: Center(
                  child: IconTheme.merge(
                    data: IconThemeData(size: text * 1.15),
                    child: ExcludeSemantics(child: icon),
                  ),
                ),
              ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(item.label),
                  if (description != null)
                    DefaultTextStyle.merge(
                      style: TextStyle(fontSize: meta, color: tokens.mutedFg),
                      child: description,
                    ),
                ],
              ),
            ),
            if (shortcut != null) NebaShortcut(keys: shortcut, size: NebaSize.xs),
          ],
        ),
      );
    }

    final Widget list = shown.isEmpty
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: insetX, vertical: 24),
            child: DefaultTextStyle.merge(
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: meta, color: tokens.mutedFg),
              child: widget.emptyMessage ?? Text(words['empty']!),
            ),
          )
        : ConstrainedBox(
            constraints: BoxConstraints(maxHeight: widget.maxHeight),
            child: SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.all(4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (final _Run run in runs)
                    Semantics(
                      container: true,
                      explicitChildNodes: true,
                      label: run.group,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          if (run.group != null && run.group!.isNotEmpty)
                            ExcludeSemantics(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(insetX, 8, insetX, 4),
                                child: Text(
                                  run.group!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: meta,
                                    height: leading / meta,
                                    fontWeight: FontWeight.w500,
                                    color: tokens.mutedFg,
                                  ),
                                ),
                              ),
                            ),
                          for (final int place in run.places) row(place),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );

    final Widget sheet = NebaSheet(
      fill: tokens.panelPress,
      edge: roles.line,
      plate: NebaPlate.glass,
      elevation: 3,
      borderRadius: radius,
      child: ClipRRect(
        borderRadius: radius,
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: text,
            height: leading / text,
            leadingDistribution: TextLeadingDistribution.even,
            color: tokens.fg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              header,
              Flexible(child: list),
            ],
          ),
        ),
      ),
    );

    // Near the top of the window, 12% of its height down, as wide as it may
    // be and clear of the system's insets and the keyboard.
    return FadeTransition(
      opacity: arrival,
      child: Padding(
        padding: screen + EdgeInsets.fromLTRB(16, media.size.height * 0.12, 16, 16),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: widget.width ?? NebaCommandPalette.maxWidths[size]!,
            ),
            child: sheet,
          ),
        ),
      ),
    );
  }
}
