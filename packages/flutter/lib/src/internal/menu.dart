/// What a menu, a context menu, a menu on a bar and every row in them share:
/// the size, colour and density the rows take from the menu, the popup a row
/// sits in, and the row itself.
///
/// The React package keeps the first of these in `internal/menu.ts` for the
/// reason this module exists: a submenu is a menu inside a menu, a context
/// menu is the same rows hung off a right-click and a menubar holds a menu per
/// word, so four widgets read the same scope and none of them should have to
/// import the others. What Base UI gives the React rows besides — the arrow
/// keys, Home and End, typeahead, the highlight that the pointer and the keys
/// move together, a submenu opened by the arrow that points at it — is here
/// too, once, in [NebaMenuSheet].
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/button_group.dart';
import 'package:neba/src/internal/floating.dart';
import 'package:neba/src/internal/glow.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/listbox.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// How long the pointer rests on a submenu's row before the submenu opens,
/// and how long it may rest on another row before the open one closes: Base
/// UI's 100 milliseconds, which is what lets a reach across a row on the way
/// into the submenu leave it open.
const Duration nebaSubmenuDelay = Duration(milliseconds: 100);

/// How long typeahead keeps what was typed: Base UI's 500 milliseconds.
const Duration nebaTypeaheadReset = Duration(milliseconds: 500);

/// The narrowest a menu's popup is, CSS `min-w-40`.
const double nebaMenuMinWidth = 160;

/// The tallest a menu's popup is before it scrolls, CSS `24rem`.
const double nebaMenuMaxHeight = 384;

/// The popup's padding around its rows, CSS `p-1`.
const double nebaMenuPadding = 4;

/// Where the focus goes when a popup opens, or is asked to again.
enum NebaMenuFocus {
  /// Nowhere: a popup the pointer opened by resting on its trigger.
  none,

  /// The popup itself, with no row highlighted: a popup a press opened. The
  /// arrow keys then start from the first row or the last.
  popup,

  /// The first row: a popup the keyboard opened.
  first,

  /// The last row: a popup the Up arrow opened.
  last,
}

/// Where a popup should put the focus, asked for by whatever opened it.
///
/// It holds the request until the popup is open and laid out, since the popup
/// arrives a frame after it is asked to open and its rows are only placed
/// after that.
class NebaMenuFocusRequest extends ChangeNotifier {
  NebaMenuFocus? _pending;

  /// Asks the popup to put the focus at [focus] once it can.
  void request(NebaMenuFocus focus) {
    _pending = focus;
    notifyListeners();
  }

  /// Takes the pending request, if there is one.
  NebaMenuFocus? take() {
    final NebaMenuFocus? focus = _pending;
    _pending = null;

    return focus;
  }
}

/// What every popup of a menu asks of the widget that opened the menu.
abstract interface class NebaMenuRoot {
  /// Closes the menu and every submenu open in it, as picking a row does.
  void closeAll();

  /// Tab, in any popup of the menu: the menu closes, and the focus moves on
  /// from its trigger as if the menu had never been there.
  void tab({required bool forward});
}

/// The menu a row is in: the size, colour and density every row of it takes,
/// and the widget that opened it.
class NebaMenuScope extends InheritedWidget {
  /// The menu around [child].
  const NebaMenuScope({
    required this.size,
    required this.color,
    required this.density,
    required this.root,
    required super.child,
    this.loop = true,
    super.key,
  });

  /// The rows' type, padding and corners.
  final NebaSize size;

  /// The family of the popup's edge and of a row's tint under the pointer.
  final NebaColor color;

  /// The rows' padding.
  final NebaDensity density;

  /// The widget that opened the menu.
  final NebaMenuRoot root;

  /// Whether the arrow keys wrap from the last row to the first, in every
  /// popup of the menu.
  final bool loop;

  /// The menu around [context], or `null` when there is none.
  static NebaMenuScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NebaMenuScope>();
  }

  /// The menu around [context]. A row outside a menu fails here.
  static NebaMenuScope of(BuildContext context) {
    final NebaMenuScope? scope = maybeOf(context);

    if (scope == null) {
      throw FlutterError(
        'A menu row was built outside a menu.\n'
        'NebaMenuItem, NebaMenuCheckboxItem, NebaMenuRadioItem, NebaMenuGroup, '
        'NebaMenuSeparator and NebaMenuSubmenu go inside a NebaMenu, a NebaContextMenu '
        'or a NebaMenubarMenu.',
      );
    }

    return scope;
  }

  @override
  bool updateShouldNotify(NebaMenuScope oldWidget) {
    return size != oldWidget.size ||
        color != oldWidget.color ||
        density != oldWidget.density ||
        root != oldWidget.root ||
        loop != oldWidget.loop;
  }
}

/// One row of a popup, as the popup sees it.
abstract interface class NebaMenuEntry {
  /// Where the row is, which is what orders the rows for the arrow keys.
  BuildContext get context;

  /// The row's focus node: the row is highlighted while it holds the focus.
  FocusNode get focusNode;

  /// What typeahead matches against.
  String? get typeahead;

  /// Opens the submenu the row leads to with its first row highlighted, and
  /// says whether there was one.
  bool openSubmenu();
}

/// A submenu that is open, as the popup it opened from sees it.
abstract interface class NebaMenuSubmenuHandle {
  /// The focus node of the row that opened it.
  FocusNode get triggerNode;

  /// Whether the pointer is over the submenu's popup.
  bool get pointerInside;

  /// Closes it.
  void close();
}

/// One popup of a menu, as its rows see it.
abstract interface class NebaMenuLevel {
  /// Takes [entry] into the popup's rows.
  void register(NebaMenuEntry entry);

  /// Lets [entry] go.
  void unregister(NebaMenuEntry entry);

  /// The pointer came onto [entry], which takes the highlight.
  void hover(NebaMenuEntry entry);

  /// The pointer left [entry], which gives the highlight back.
  void unhover(NebaMenuEntry entry);

  /// [submenu] opened from this popup, closing any other.
  void submenuOpened(NebaMenuSubmenuHandle submenu);

  /// [submenu] closed.
  void submenuClosed(NebaMenuSubmenuHandle submenu);
}

/// The popup a row is in, and whether it is open.
class NebaMenuLevelScope extends InheritedWidget {
  /// The popup around [child].
  const NebaMenuLevelScope({
    required this.level,
    required this.open,
    required super.child,
    super.key,
  });

  /// The popup.
  final NebaMenuLevel level;

  /// Whether it is open: a submenu inside a popup that is closing closes with
  /// it.
  final bool open;

  /// The popup around [context], or `null` when there is none.
  static NebaMenuLevelScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NebaMenuLevelScope>();
  }

  @override
  bool updateShouldNotify(NebaMenuLevelScope oldWidget) {
    return level != oldWidget.level || open != oldWidget.open;
  }
}

/// The text of [widget] when it is a [Text], for typeahead and for a name.
String? nebaMenuTextOf(Widget? widget) {
  if (widget is Text) {
    return widget.data ?? widget.textSpan?.toPlainText(includeSemanticsLabels: false);
  }

  return null;
}

/// The character [event] types, when it types one and typeahead should take
/// it: a printable key with no Control, Command or Alt held.
String? nebaTypeaheadCharacter(KeyEvent event) {
  final String? character = event.character;
  final HardwareKeyboard keyboard = HardwareKeyboard.instance;

  if (character == null ||
      character.length != 1 ||
      character.trim().isEmpty ||
      character.codeUnitAt(0) < 0x20 ||
      keyboard.isControlPressed ||
      keyboard.isMetaPressed ||
      keyboard.isAltPressed) {
    return null;
  }

  return character;
}

/// Moves the focus on from [from], forwards or back, once the frame that
/// closed a menu has given the focus back to it: Tab out of a menu lands
/// where it would have landed from the trigger.
void nebaMenuMoveOn(FocusNode? from, {required bool forward}) {
  if (from == null) {
    return;
  }

  SchedulerBinding.instance.addPostFrameCallback((Duration _) {
    if (from.context == null) {
      return;
    }

    if (forward) {
      from.nextFocus();
    } else {
      from.previousFocus();
    }
  });
  SchedulerBinding.instance.ensureVisualUpdate();
}

/// The popup of a menu: the Select popup's frosted sheet at elevation 3, its
/// rows in a column that scrolls past 384 pixels, and everything the keys do
/// in it.
///
/// The arrow keys, Home and End move the highlight, which is the focus, so the
/// pointer and the keys light the same row; letters move it to the next row
/// that starts with what was typed; the arrow that points at a submenu opens
/// it, and [onBack] and [onForward] take the arrows across the menu that lead
/// nowhere in it. Tab closes the whole menu. The focus goes where [focus] asks
/// once the popup is open, and back to [returnFocus] when it closes with the
/// focus inside it.
class NebaMenuSheet extends StatefulWidget {
  /// A popup holding [children].
  const NebaMenuSheet({
    required this.open,
    required this.focus,
    required this.children,
    this.returnFocus,
    this.onBack,
    this.onForward,
    this.onFocusOut,
    super.key,
  });

  /// Whether the popup is open; a closing one is on its way out.
  final bool open;

  /// Where the focus goes once the popup is open.
  final NebaMenuFocusRequest focus;

  /// The rows.
  final List<Widget> children;

  /// Where the focus goes back to when the popup closes with the focus inside
  /// it, or nowhere.
  final ValueGetter<FocusNode?>? returnFocus;

  /// The arrow pointing at the inline start: a submenu closes, and a menu on
  /// a bar walks to the one before it.
  final VoidCallback? onBack;

  /// The arrow pointing at the inline end on a row that opens nothing: a menu
  /// on a bar walks to the one after it.
  final VoidCallback? onForward;

  /// The focus left the popup for [focus], somewhere outside it.
  final ValueChanged<FocusNode>? onFocusOut;

  @override
  State<NebaMenuSheet> createState() => _NebaMenuSheetState();
}

class _NebaMenuSheetState extends State<NebaMenuSheet> implements NebaMenuLevel {
  final FocusNode _popup = FocusNode(debugLabel: 'NebaMenu popup', skipTraversal: true);
  final ScrollController _scroll = ScrollController();
  final GlobalKey _viewport = GlobalKey();
  final List<NebaMenuEntry> _entries = <NebaMenuEntry>[];

  NebaMenuSubmenuHandle? _submenu;
  Timer? _siblingTimer;
  final NebaTypeahead _typeahead = NebaTypeahead(resetAfter: nebaTypeaheadReset);
  bool _scheduled = false;

  @override
  void initState() {
    super.initState();
    widget.focus.addListener(_onRequest);
    _popup.addListener(_onFocusChange);

    if (widget.open) {
      _schedule();
    }
  }

  @override
  void didUpdateWidget(NebaMenuSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focus != oldWidget.focus) {
      oldWidget.focus.removeListener(_onRequest);
      widget.focus.addListener(_onRequest);
    }

    if (widget.open != oldWidget.open) {
      if (widget.open) {
        _schedule();
      } else {
        _closed();
      }
    }
  }

  @override
  void dispose() {
    widget.focus.removeListener(_onRequest);
    _popup.removeListener(_onFocusChange);
    _siblingTimer?.cancel();
    _typeahead.dispose();
    _popup.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ----- The focus in and out -----------------------------------------------

  void _onRequest() {
    if (widget.open) {
      _schedule();
    }
  }

  // After the frame, when the rows are built and placed.
  void _schedule() {
    if (_scheduled) {
      return;
    }

    _scheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      _scheduled = false;
      _apply();
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  void _apply() {
    if (!mounted || !widget.open) {
      return;
    }

    switch (widget.focus.take()) {
      case null:
      case NebaMenuFocus.none:
        return;
      case NebaMenuFocus.popup:
        _popup.requestFocus();
      case NebaMenuFocus.first:
        _focusAt(_ordered(), 0, end: false);
      case NebaMenuFocus.last:
        final List<NebaMenuEntry> rows = _ordered();
        _focusAt(rows, rows.length - 1, end: true);
    }
  }

  bool get _focusInside {
    final FocusNode? primary = FocusManager.instance.primaryFocus;

    return primary == null || primary == _popup || primary.ancestors.contains(_popup);
  }

  void _closed() {
    _siblingTimer?.cancel();
    _siblingTimer = null;
    _submenu?.close();
    _submenu = null;

    if (_focusInside) {
      final FocusNode? target = widget.returnFocus?.call();

      if (target != null && target.context != null) {
        target.requestFocus();
      }
    }
  }

  void _onFocusChange() {
    final ValueChanged<FocusNode>? onFocusOut = widget.onFocusOut;

    if (!widget.open || _popup.hasFocus || onFocusOut == null) {
      return;
    }

    final FocusNode? primary = FocusManager.instance.primaryFocus;

    if (primary != null) {
      onFocusOut(primary);
    }
  }

  // ----- The rows -------------------------------------------------------------

  @override
  void register(NebaMenuEntry entry) {
    if (!_entries.contains(entry)) {
      _entries.add(entry);
    }
  }

  @override
  void unregister(NebaMenuEntry entry) {
    _entries.remove(entry);
  }

  // The rows in the order they are drawn, top to bottom.
  List<NebaMenuEntry> _ordered() {
    final List<(double, NebaMenuEntry)> placed = <(double, NebaMenuEntry)>[];

    for (final NebaMenuEntry entry in _entries) {
      final RenderObject? box = entry.context.findRenderObject();

      if (box is RenderBox && box.attached && box.hasSize) {
        placed.add((box.localToGlobal(Offset.zero).dy, entry));
      }
    }

    placed.sort(((double, NebaMenuEntry) a, (double, NebaMenuEntry) b) => a.$1.compareTo(b.$1));

    return <NebaMenuEntry>[for (final (double _, NebaMenuEntry entry) in placed) entry];
  }

  void _focusAt(List<NebaMenuEntry> rows, int index, {required bool end}) {
    if (index < 0 || index >= rows.length) {
      _popup.requestFocus();

      return;
    }

    final NebaMenuEntry entry = rows[index];
    entry.focusNode.requestFocus();
    _reveal(entry, end: end);
  }

  // Scrolls the popup, and only the popup, so that [entry] is in view: the
  // page behind is not this popup's to scroll.
  void _reveal(NebaMenuEntry entry, {required bool end}) {
    final RenderObject? row = entry.context.findRenderObject();
    final RenderObject? viewport = _viewport.currentContext?.findRenderObject();

    if (row is! RenderBox || viewport is! RenderBox || !_scroll.hasClients) {
      return;
    }

    final double top = row.localToGlobal(Offset.zero, ancestor: viewport).dy - nebaMenuPadding;
    final double bottom = top + row.size.height + 2 * nebaMenuPadding;
    final ScrollPosition position = _scroll.position;
    double offset = position.pixels;

    if (top < 0) {
      offset += top;
    } else if (bottom > viewport.size.height) {
      offset += bottom - viewport.size.height;
    }

    offset = offset.clamp(position.minScrollExtent, position.maxScrollExtent);

    if (offset != position.pixels) {
      position.jumpTo(offset);
    }
  }

  @override
  void hover(NebaMenuEntry entry) {
    if (!entry.focusNode.hasFocus) {
      entry.focusNode.requestFocus();
    }

    _siblingTimer?.cancel();
    _siblingTimer = null;

    final NebaMenuSubmenuHandle? open = _submenu;

    // A row beside an open submenu closes it, but not at once: a reach from
    // the submenu's row into it may cross the row below on the way.
    if (open != null && open.triggerNode != entry.focusNode) {
      _siblingTimer = Timer(nebaSubmenuDelay, () {
        _siblingTimer = null;

        if (identical(_submenu, open) && !open.pointerInside) {
          open.close();
        }
      });
    }
  }

  @override
  void unhover(NebaMenuEntry entry) {
    if (entry.focusNode.hasPrimaryFocus && widget.open) {
      _popup.requestFocus();
    }
  }

  @override
  void submenuOpened(NebaMenuSubmenuHandle submenu) {
    final NebaMenuSubmenuHandle? previous = _submenu;
    _submenu = submenu;

    if (previous != null && !identical(previous, submenu)) {
      previous.close();
    }
  }

  @override
  void submenuClosed(NebaMenuSubmenuHandle submenu) {
    if (identical(_submenu, submenu)) {
      _submenu = null;
    }
  }

  // ----- The keys -------------------------------------------------------------

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final LogicalKeyboardKey key = event.logicalKey;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final List<NebaMenuEntry> rows = _ordered();
    final int current = rows.indexWhere((NebaMenuEntry entry) => entry.focusNode.hasPrimaryFocus);

    if (key == LogicalKeyboardKey.tab) {
      NebaMenuScope.of(context).root.tab(forward: !HardwareKeyboard.instance.isShiftPressed);

      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.home ||
        key == LogicalKeyboardKey.end) {
      if (rows.isEmpty) {
        return KeyEventResult.handled;
      }

      final bool down = key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.end;
      int target;

      if (current < 0) {
        // Nothing highlighted yet: down starts at the top and up at the
        // bottom, whether or not the arrows wrap.
        target = key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.home
            ? 0
            : rows.length - 1;
      } else {
        target =
            nebaRovingTarget(
              event,
              current: current,
              count: rows.length,
              axis: Axis.vertical,
              textDirection: Directionality.of(context),
              loop: NebaMenuScope.of(context).loop,
              focusable: (int _) => true,
            ) ??
            current;
      }

      _focusAt(rows, target, end: down);

      return KeyEventResult.handled;
    }

    final bool forward =
        key == (rtl ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowRight);
    final bool back = key == (rtl ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft);

    if (forward) {
      if (current >= 0 && rows[current].openSubmenu()) {
        return KeyEventResult.handled;
      }

      final VoidCallback? onForward = widget.onForward;

      if (onForward != null) {
        onForward();

        return KeyEventResult.handled;
      }

      // Up to the popup this one opened from, which may be on a bar.
      return KeyEventResult.ignored;
    }

    if (back) {
      final VoidCallback? onBack = widget.onBack;

      if (onBack != null) {
        onBack();

        return KeyEventResult.handled;
      }

      return KeyEventResult.ignored;
    }

    final String? character = nebaTypeaheadCharacter(event);

    if (character != null) {
      final int? index = _typeahead.type(
        character,
        labels: <String?>[for (final NebaMenuEntry row in rows) row.typeahead],
        current: current,
      );

      if (index != null) {
        _focusAt(rows, index, end: index > current);
      }

      // Taken whether it matched or not, so that a letter typed in a
      // submenu does not move the highlight in the popup under it.
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ----- Building -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final NebaMenuScope menu = NebaMenuScope.of(context);
    final NebaTokens tokens = NebaTheme.of(context);
    final double tallest = math.max(
      0,
      math.min(nebaMenuMaxHeight, MediaQuery.sizeOf(context).height - 2 * nebaCollisionPadding),
    );

    Widget sheet = NebaSheet(
      fill: tokens.panelPress,
      edge: tokens.roles(menu.color).line,
      plate: NebaPlate.glass,
      elevation: 3,
      borderRadius: BorderRadius.circular(tokens.radius[menu.size]!),
      child: KeyedSubtree(
        key: _viewport,
        child: SingleChildScrollView(
          controller: _scroll,
          padding: const EdgeInsets.all(nebaMenuPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widget.children,
          ),
        ),
      ),
    );

    // As wide as its widest row, as a CSS box that shrinks to fit is.
    sheet = ConstrainedBox(
      constraints: BoxConstraints(minWidth: nebaMenuMinWidth, maxHeight: tallest),
      child: IntrinsicWidth(child: sheet),
    );

    return Focus(
      focusNode: _popup,
      includeSemantics: false,
      onKeyEvent: _onKey,
      child: NebaMenuLevelScope(
        level: this,
        open: widget.open,
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          // A menu cannot be empty for a screen reader, which says so.
          role: widget.children.isEmpty ? null : SemanticsRole.menu,
          child: sheet,
        ),
      ),
    );
  }
}

/// One row of a menu, in every shape a row takes: an action, a link, a row
/// that ticks, a row that is one of a set, and a row that opens a submenu.
/// They differ in what fills the slot at the start and in what a screen
/// reader is told, and in nothing else.
///
/// The row is highlighted while it holds the focus, which the pointer gives
/// it by coming onto it and takes back by leaving, so the mouse and the arrow
/// keys light the same row; the tint is the focus indicator, and there is no
/// ring. A disabled row is still highlighted and still found by typeahead,
/// and it does nothing.
class NebaMenuRow extends StatefulWidget {
  /// A row that runs [onActivate] when it is pressed, or Enter or Space is
  /// pressed on it.
  const NebaMenuRow({
    required this.label,
    required this.onActivate,
    this.focusNode,
    this.role = SemanticsRole.menuItem,
    this.checked,
    this.mutuallyExclusive = false,
    this.expanded,
    this.link,
    this.notice,
    this.leading,
    this.leadingSlot = false,
    this.leadingAccent = false,
    this.trailing,
    this.shortcut,
    this.description,
    this.chevron = false,
    this.color,
    this.disabled = false,
    this.popupOpen = false,
    this.typeahead,
    this.onOpenSubmenu,
    super.key,
  });

  /// The label.
  final Widget? label;

  /// What a press does.
  final VoidCallback onActivate;

  /// The row's focus node, for a row whose focus its owner needs: a
  /// submenu's, which the focus comes back to when the submenu closes.
  final FocusNode? focusNode;

  /// What a screen reader is told the row is.
  final SemanticsRole role;

  /// Whether a row that ticks, or is one of a set, is ticked.
  final bool? checked;

  /// Whether the row is one of a set of which one is chosen.
  final bool mutuallyExclusive;

  /// Whether the submenu a row opens is open.
  final bool? expanded;

  /// Where a row that is a link leads, already made safe.
  final Uri? link;

  /// Read after the label and drawn nowhere: a link's "(opens in a new tab)".
  final String? notice;

  /// What fills the slot at the start: an icon, a tick, a dot.
  final Widget? leading;

  /// Whether the slot at the start is kept with nothing in it, as a row that
  /// ticks keeps it while it is not ticked.
  final bool leadingSlot;

  /// Whether the slot at the start is in the family's accent rather than
  /// muted: a tick and a dot are.
  final bool leadingAccent;

  /// What fills the slot after the label.
  final Widget? trailing;

  /// The keystroke that does the same thing, set muted at the end.
  final Widget? shortcut;

  /// A second line under the label.
  final Widget? description;

  /// Whether the row ends on a chevron pointing at the inline end: a
  /// submenu's.
  final bool chevron;

  /// The family of this row in place of the menu's.
  final NebaColor? color;

  /// Whether the row does nothing.
  final bool disabled;

  /// Whether the submenu the row opens is open, which tints it.
  final bool popupOpen;

  /// What typeahead matches against, in place of the label's text.
  final String? typeahead;

  /// Opens the submenu the row leads to and says whether there was one.
  final bool Function()? onOpenSubmenu;

  /// A row's padding per density and size: a ladder of its own, because a
  /// menu is as wide as its widest label, and Box's would make a menu that
  /// says "Cut" as wide as a dialog.
  static const Map<NebaDensity, Map<NebaSize, EdgeInsets>> padding =
      <NebaDensity, Map<NebaSize, EdgeInsets>>{
        NebaDensity.standard: <NebaSize, EdgeInsets>{
          NebaSize.xs: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          NebaSize.sm: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          NebaSize.md: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          NebaSize.lg: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          NebaSize.xl: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        },
        NebaDensity.compact: <NebaSize, EdgeInsets>{
          NebaSize.xs: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          NebaSize.sm: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          NebaSize.md: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          NebaSize.lg: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          NebaSize.xl: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        },
      };

  /// The step of the radius ladder a row is cut at, one below the popup's: a
  /// tile cut out of a sheet cannot carry the sheet's own corner.
  static const Map<NebaSize, NebaSize> radiusStep = <NebaSize, NebaSize>{
    NebaSize.xs: NebaSize.xs,
    NebaSize.sm: NebaSize.xs,
    NebaSize.md: NebaSize.sm,
    NebaSize.lg: NebaSize.sm,
    NebaSize.xl: NebaSize.md,
  };

  /// How far the shortcut stands from what is before it, on top of the gap.
  static const double shortcutGap = 8;

  @override
  State<NebaMenuRow> createState() => _NebaMenuRowState();
}

class _NebaMenuRowState extends State<NebaMenuRow> implements NebaMenuEntry {
  FocusNode? _own;
  NebaMenuLevel? _level;

  @override
  FocusNode get focusNode {
    return widget.focusNode ??
        (_own ??= FocusNode(debugLabel: 'NebaMenu row', skipTraversal: true));
  }

  @override
  String? get typeahead => widget.typeahead ?? nebaMenuTextOf(widget.label);

  @override
  bool openSubmenu() => widget.onOpenSubmenu?.call() ?? false;

  @override
  void initState() {
    super.initState();
    _attach(focusNode);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final NebaMenuLevel? level = NebaMenuLevelScope.maybeOf(context)?.level;

    if (level != _level) {
      _level?.unregister(this);
      _level = level;
      level?.register(this);
    }
  }

  @override
  void didUpdateWidget(NebaMenuRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _own)?.removeListener(_onFocus);
      _attach(focusNode);
    }
  }

  @override
  void dispose() {
    _level?.unregister(this);
    focusNode.removeListener(_onFocus);
    _own?.dispose();
    super.dispose();
  }

  void _attach(FocusNode node) {
    // A row is reached by the arrow keys, never by Tab.
    node.skipTraversal = true;
    node.addListener(_onFocus);
  }

  void _onFocus() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final NebaMenuScope menu = NebaMenuScope.of(context);
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaSize size = menu.size;
    final NebaColorRoles roles = tokens.roles(widget.color ?? menu.color);
    final bool disabled = widget.disabled;
    final double text = NebaScale.controlText[size]!;
    final double meta = NebaScale.metaText[size]!;
    final double leading = NebaScale.controlLeading[size]!;
    final double slot = text * 1.2;
    final BorderRadius radius = BorderRadius.circular(tokens.radius[NebaMenuRow.radiusStep[size]]!);
    // The accent re-pointed is carried as the family's ink on a tint, since
    // the accent on a pale copy of itself does not clear 4.5:1.
    final Color ink = disabled
        ? tokens.disabledFg
        : widget.color != null
        ? roles.onTint
        : tokens.fg;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;

    // One line tall, 1.2 of the text wide, centred on the line.
    Widget slotted(Widget child, Color color) {
      return SizedBox(
        width: slot,
        height: leading,
        child: Center(
          child: IconTheme.merge(
            data: IconThemeData(size: slot, color: color),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: color),
              child: child,
            ),
          ),
        ),
      );
    }

    final Widget? label = widget.label;
    final Widget? description = widget.description;
    final Widget? trailing = widget.trailing;
    final Widget? shortcut = widget.shortcut;
    final Widget? leadingWidget = widget.leading;
    final String? notice = widget.notice;

    final Widget body = description == null
        ? (label ?? const SizedBox.shrink())
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ?label,
              // The line stays the label's, as an inherited CSS line height
              // does.
              DefaultTextStyle.merge(
                style: TextStyle(fontSize: meta, height: leading / meta, color: tokens.mutedFg),
                child: description,
              ),
            ],
          );

    Widget content = Row(
      spacing: NebaScale.gap[size]!,
      children: <Widget>[
        if (leadingWidget != null || widget.leadingSlot)
          slotted(
            leadingWidget ?? const SizedBox.shrink(),
            widget.leadingAccent ? roles.family.accent : tokens.mutedFg,
          ),
        Expanded(child: body),
        if (trailing != null) slotted(trailing, tokens.mutedFg),
        if (shortcut != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: NebaMenuRow.shortcutGap),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: meta,
                color: tokens.mutedFg,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
              child: shortcut,
            ),
          ),
        if (widget.chevron)
          // Drawn pointing down and turned to the inline end: the one
          // allowance the no-transform rule makes, on a glyph.
          slotted(
            RotatedBox(quarterTurns: rtl ? 1 : 3, child: NebaGlyph(NebaGlyphs.chevron)),
            tokens.mutedFg,
          ),
      ],
    );

    if (notice != null) {
      content = Stack(
        children: <Widget>[
          content,
          Semantics(label: notice, child: const SizedBox.shrink()),
        ],
      );
    }

    content = DefaultTextStyle.merge(
      style: TextStyle(
        fontSize: text,
        height: leading / text,
        // CSS shares a line's leading evenly above and below it.
        leadingDistribution: TextLeadingDistribution.even,
      ),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      child: NebaInk(color: ink, child: content),
    );

    final bool focused = focusNode.hasFocus;
    final NebaMenuLevel? level = _level;

    return Semantics(
      container: true,
      role: widget.role,
      enabled: !disabled,
      checked: widget.checked,
      inMutuallyExclusiveGroup: widget.mutuallyExclusive ? true : null,
      expanded: widget.expanded,
      link: widget.link != null ? true : null,
      linkUrl: widget.link,
      child: MouseRegion(
        opaque: false,
        onEnter: (PointerEnterEvent event) => level?.hover(this),
        onHover: (PointerHoverEvent event) {
          if (!focusNode.hasFocus) {
            level?.hover(this);
          }
        },
        onExit: (PointerExitEvent event) => level?.unhover(this),
        child: NebaInteractive(
          focusNode: focusNode,
          enabled: !disabled,
          // Still reached by the arrow keys while it does nothing, as a
          // disabled row stays listed.
          focusable: true,
          onTap: widget.onActivate,
          cursor: disabled ? SystemMouseCursors.forbidden : null,
          builder:
              (
                BuildContext context,
                NebaInteraction interaction,
                ValueListenable<Offset?> pointer,
              ) {
                const Color clear = Color(0x00000000);
                final Color fill = focused || interaction.pressed
                    ? roles.softHover
                    : widget.popupOpen
                    ? roles.soft
                    : clear;

                return Stack(
                  children: <Widget>[
                    TweenAnimationBuilder<Color?>(
                      tween: ColorTween(end: fill),
                      duration: nebaDuration(context, NebaScale.durationFill),
                      curve: NebaScale.ease,
                      builder: (BuildContext context, Color? tint, Widget? child) {
                        return DecoratedBox(
                          decoration: BoxDecoration(color: tint, borderRadius: radius),
                          child: child,
                        );
                      },
                      child: Padding(
                        padding: NebaMenuRow.padding[menu.density]![size]!,
                        child: content,
                      ),
                    ),
                    // The spotlight without the flash: a row is gone the moment
                    // it is chosen, and an afterglow on it would drain over
                    // nothing. A disabled row stays dark.
                    if (!disabled)
                      Positioned.fill(
                        child: NebaGlow(
                          interaction: interaction,
                          pointer: pointer,
                          colors: NebaGlowColors(glow: roles.soft, flash: edgeless),
                          afterglow: false,
                          borderRadius: radius,
                        ),
                      ),
                  ],
                );
              },
        ),
      ),
    );
  }
}
