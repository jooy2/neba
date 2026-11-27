/// `NebaToastProvider`, which puts a stack of toasts above the app, and
/// `NebaToastActions`, which raises them from anywhere below it.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/drag.dart';
import 'package:neba/src/internal/floating.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/message.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/internal/text_marks.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Where the stack sits: pinned to the top or the bottom edge, at the start,
/// the centre or the end of it.
///
/// One value rather than a side and an alignment, because the two are not
/// independent: a stack is always on the top or the bottom edge, never down a
/// side.
enum NebaToastPosition {
  /// The top edge, at the start.
  topStart(NebaSide.top, NebaAlign.start),

  /// The top edge, in the middle.
  topCenter(NebaSide.top, NebaAlign.center),

  /// The top edge, at the end.
  topEnd(NebaSide.top, NebaAlign.end),

  /// The bottom edge, at the start.
  bottomStart(NebaSide.bottom, NebaAlign.start),

  /// The bottom edge, in the middle.
  bottomCenter(NebaSide.bottom, NebaAlign.center),

  /// The bottom edge, at the end.
  bottomEnd(NebaSide.bottom, NebaAlign.end);

  const NebaToastPosition(this.edge, this.align);

  /// The edge the stack is pinned to, [NebaSide.top] or [NebaSide.bottom].
  final NebaSide edge;

  /// Where along that edge, `start` and `end` following the reading
  /// direction.
  final NebaAlign align;
}

/// How a screen reader is told about a toast.
enum NebaToastPriority {
  /// Read out once the screen reader comes to a pause.
  low,

  /// Read out at once, interrupting what the screen reader was saying.
  high,
}

/// What a toast carries: the React package's `ToastOptions`.
///
/// Every field is optional. Raised with [NebaToastActions.add], a field left
/// out falls back to the [NebaToastProvider]'s; passed to
/// [NebaToastActions.update], a field left out keeps what the toast already
/// has.
@immutable
class NebaToastOptions {
  /// A toast saying [title] and [description].
  const NebaToastOptions({
    this.id,
    this.title,
    this.description,
    this.color,
    this.variant,
    this.icon,
    this.showIcon,
    this.timeout,
    this.priority,
    this.actionLabel,
    this.onAction,
    this.onClose,
    this.onRemove,
  });

  /// Which toast this is. Raising one with the id of a toast already on
  /// screen changes that toast in place and starts its timer again, which is
  /// what "uploading" followed by "uploaded" wants: one toast that changed,
  /// not two. Left out, [NebaToastActions.add] makes one up and returns it.
  final String? id;

  /// The headline, usually a [Text], one step above the description in
  /// semibold and in the family's accent.
  final Widget? title;

  /// The detail under the title, usually a [Text]. A toast with only this is
  /// a one-line toast.
  final Widget? description;

  /// The colour family of this toast alone, which also picks its glyph.
  /// Defaults to the provider's.
  final NebaColor? color;

  /// The surface of this toast alone. Defaults to the provider's.
  final NebaVariant? variant;

  /// Replaces the glyph that goes with [color], drawn at 1.2 times the text
  /// through the [IconTheme] the toast hands down.
  final Widget? icon;

  /// Whether a glyph is drawn at all. `false` draws none, the React package's
  /// `icon: false`.
  final bool? showIcon;

  /// How long before the toast closes itself. [Duration.zero] keeps it up
  /// until it is closed, which is the right answer for anything the reader
  /// has to act on. Defaults to the provider's.
  final Duration? timeout;

  /// [NebaToastPriority.high] interrupts a screen reader, and
  /// [NebaToastPriority.low], the default, waits for a pause.
  final NebaToastPriority? priority;

  /// The label of the action button, usually a [Text]. Passing it is what
  /// makes the button appear.
  final Widget? actionLabel;

  /// Called when the action button is pressed.
  final VoidCallback? onAction;

  /// Called when the toast closes, however it closed.
  final VoidCallback? onClose;

  /// Called once it has faded out and left the stack.
  final VoidCallback? onRemove;
}

/// [options] under [id].
NebaToastOptions _withId(NebaToastOptions options, String id) {
  return NebaToastOptions(
    id: id,
    title: options.title,
    description: options.description,
    color: options.color,
    variant: options.variant,
    icon: options.icon,
    showIcon: options.showIcon,
    timeout: options.timeout,
    priority: options.priority,
    actionLabel: options.actionLabel,
    onAction: options.onAction,
    onClose: options.onClose,
    onRemove: options.onRemove,
  );
}

/// What every field [next] sets, over [previous]: an update, which keeps
/// what it does not mention.
NebaToastOptions _merged(NebaToastOptions previous, NebaToastOptions next) {
  final bool action = next.actionLabel != null;

  return NebaToastOptions(
    id: previous.id,
    title: next.title ?? previous.title,
    description: next.description ?? previous.description,
    color: next.color ?? previous.color,
    variant: next.variant ?? previous.variant,
    icon: next.icon ?? previous.icon,
    showIcon: next.showIcon ?? previous.showIcon,
    timeout: next.timeout ?? previous.timeout,
    priority: next.priority ?? previous.priority,
    actionLabel: action ? next.actionLabel : previous.actionLabel,
    onAction: action ? next.onAction : previous.onAction,
    onClose: next.onClose ?? previous.onClose,
    onRemove: next.onRemove ?? previous.onRemove,
  );
}

/// [next] in place of [previous]: a toast raised again under its id, or a
/// promise that settled. The words carry over where [next] has none; the
/// colour, the surface, the glyph and the action are [next]'s, as the React
/// package writes them in one piece. After a promise the timeout is [next]'s
/// too, so a toast that waited on one takes the provider's unless it names
/// its own.
NebaToastOptions _replaced(
  NebaToastOptions previous,
  NebaToastOptions next, {
  bool settled = false,
}) {
  return NebaToastOptions(
    id: previous.id,
    title: next.title ?? previous.title,
    description: next.description ?? previous.description,
    color: next.color,
    variant: next.variant,
    icon: next.icon,
    showIcon: next.showIcon,
    timeout: settled ? next.timeout : next.timeout ?? previous.timeout,
    priority: next.priority ?? previous.priority,
    actionLabel: next.actionLabel,
    onAction: next.onAction,
    onClose: next.onClose ?? previous.onClose,
    onRemove: next.onRemove ?? previous.onRemove,
  );
}

/// What a widget below a [NebaToastProvider] raises toasts with: the React
/// package's `useToast()` and `useToastActions()`, as one object.
///
/// Reach it with `NebaToastProvider.of(context)`. It is the same object for
/// the life of the provider, so holding it costs a widget nothing: a widget
/// that only raises toasts is never built again because one was raised. A
/// widget that shows the list listens to [toasts].
final class NebaToastActions {
  NebaToastActions._(this._store);

  final _ToastStore _store;

  /// Raises a toast and returns its id.
  String add(NebaToastOptions options) => _store.add(options);

  /// Closes the toast [id], or every toast when [id] is left out.
  void close([String? id]) => _store.close(id);

  /// Changes the toast [id] while it is on screen, keeping whatever
  /// [options] leaves out. Its timer keeps running, unless [options] gives
  /// it a new timeout; raising it again with [add] under the same id is what
  /// starts the timer over.
  void update(String id, NebaToastOptions options) => _store.update(id, options);

  /// One toast that follows [future]: [loading] while it runs, then what
  /// [success] or [error] makes of how it ended.
  ///
  /// The loading toast never closes on its own, so a slow request cannot
  /// dismiss it. The returned future completes as [future] does, its error
  /// included.
  Future<T> promise<T>(
    Future<T> future, {
    required NebaToastOptions loading,
    required NebaToastOptions Function(T value) success,
    required NebaToastOptions Function(Object error) error,
  }) {
    final String id = _store.add(loading, loading: true);

    return future.then<T>(
      (T value) {
        _store.settle(id, success(value));

        return value;
      },
      onError: (Object reason, StackTrace stack) {
        _store.settle(id, error(reason));
        Error.throwWithStackTrace(reason, stack);
      },
    );
  }

  /// Every toast in the stack that has not closed, newest first, each with
  /// its id. It changes whenever one is raised, changed or closed.
  ValueListenable<List<NebaToastOptions>> get toasts => _store.toasts;
}

/// Puts a stack of toasts above the app and lets anything below it raise one,
/// through `NebaToastProvider.of(context)`.
///
/// Place it once, around the app. Everything about how a toast looks is
/// decided here, where the stack sits, how wide a toast gets, which surface it
/// wears and how long it lasts, so a call site says only what happened.
///
/// The stack is drawn in the root [Overlay] above the provider, and a provider
/// with none above it brings its own, so it can sit around the navigator in
/// `WidgetsApp.builder`. It is drawn over everything opened before the newest
/// toast, keeps out of the safe areas and the keyboard, and takes no pointer
/// except on the toasts themselves.
///
/// A toast arrives and leaves in opacity, the newest nearest the edge, and
/// closes itself after its timeout. The timers hold while a mouse is over the
/// stack, while the keyboard focus is in it, from a finger on it until a
/// finger goes down elsewhere, and while the app is not the focused window.
/// A toast closes by its ×, by Escape while it holds the focus, and by a
/// swipe sideways or towards its edge. F6 moves the focus to the newest one.
///
/// ```dart
/// NebaToastProvider(
///   position: NebaToastPosition.bottomEnd,
///   child: app,
/// )
///
/// // anywhere below it
/// NebaToastProvider.of(context).add(
///   const NebaToastOptions(
///     color: NebaColor.success,
///     title: Text('Deployed'),
///     description: Text('production · 4m 02s'),
///   ),
/// );
/// ```
class NebaToastProvider extends StatefulWidget {
  /// A stack of toasts above [child].
  const NebaToastProvider({
    required this.child,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.position = NebaToastPosition.bottomEnd,
    this.timeout = const Duration(milliseconds: 5000),
    this.limit = 3,
    this.width = 380,
    this.locale,
    this.closeLabel,
    this.label,
    super.key,
  }) : assert(limit > 0),
       assert(width > 0);

  /// The app.
  final Widget child;

  /// The surface every toast wears unless it says otherwise: `solid` floods
  /// it with the family, `outline` tints it and draws the hairline, `text`
  /// tints it with no hairline. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The type, the corners and the padding of every toast. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The colour family every toast takes unless it names its own. Defaults
  /// to [NebaColor.primary].
  final NebaColor? color;

  /// How much padding a toast has at its [size]. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// Where the stack is pinned.
  final NebaToastPosition position;

  /// How long a toast lasts unless it says otherwise. [Duration.zero] keeps
  /// every toast up until it is closed.
  final Duration timeout;

  /// How many toasts are shown at once. The rest are kept and shown as the
  /// stack drains rather than thrown away. Their timers run while they wait,
  /// so a toast that waits longer than its timeout closes without being
  /// shown.
  final int limit;

  /// The widest a toast gets, in logical pixels.
  final double width;

  /// The language the × on every toast and the stack's region are named in.
  /// Defaults to `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// What a screen reader hears for the × on every toast. Defaults to the
  /// [locale]'s "Close".
  final String? closeLabel;

  /// The name of the region the stack is, which a screen reader can move to.
  /// Defaults to the [locale]'s "Notifications".
  final String? label;

  /// How far the stack keeps from the edges of the window, besides the safe
  /// areas.
  static const double inset = 16;

  /// The gap between two toasts.
  static const double gap = 8;

  /// The shadow every toast casts: it floats over the page, so unlike a
  /// sheet set into it, it has one by default.
  static const NebaElevation elevation = 3;

  /// How far a swipe travels before letting go closes the toast.
  static const double swipeThreshold = 40;

  /// The raising half of the nearest [NebaToastProvider] above [context].
  ///
  /// It does not make [context] depend on anything, so it can be called from
  /// `initState`, from a build or from a press, and a widget that only
  /// raises toasts is not built again when one is raised.
  static NebaToastActions of(BuildContext context) {
    final NebaToastActions? actions = maybeOf(context);

    if (actions == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('NebaToastProvider.of() was called with no NebaToastProvider above it.'),
        ErrorHint(
          'Place one NebaToastProvider around the app, such as in WidgetsApp.builder around '
          'the navigator, so that every route can raise a toast.',
        ),
        context.describeElement('The context used was'),
      ]);
    }

    return actions;
  }

  /// [of], or `null` when there is no [NebaToastProvider] above [context].
  static NebaToastActions? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<_NebaToastScope>()?.actions;
  }

  @override
  State<NebaToastProvider> createState() => _NebaToastProviderState();
}

class _NebaToastProviderState extends State<NebaToastProvider> {
  late final _ToastStore _store = _ToastStore(timeout: widget.timeout, limit: widget.limit);
  late final NebaToastActions _actions = NebaToastActions._(_store);
  final OverlayPortalController _portal = OverlayPortalController();
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _store.onRaise = _raise;
    // Before the first build the controller only takes note.
    _portal.show();

    final AppLifecycleState? state = WidgetsBinding.instance.lifecycleState;
    _store.away = state != null && state != AppLifecycleState.resumed;
    _lifecycle = AppLifecycleListener(
      onStateChange: (AppLifecycleState state) {
        _store.away = state != AppLifecycleState.resumed;
      },
    );
  }

  @override
  void didUpdateWidget(NebaToastProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    _store
      ..timeout = widget.timeout
      ..limit = widget.limit;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _store.dispose();
    super.dispose();
  }

  // Shown again so the stack comes to the top, over any popup opened since
  // the last toast: the toast a dialog raises is drawn over that dialog.
  void _raise() {
    if (mounted) {
      _portal.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget result = OverlayPortal(
      controller: _portal,
      overlayLocation: OverlayChildLocation.rootOverlay,
      overlayChildBuilder: (BuildContext context) {
        return _ToastViewport(
          store: _store,
          position: widget.position,
          width: widget.width,
          variant: widget.variant,
          size: widget.size,
          color: widget.color ?? NebaColor.primary,
          density: widget.density,
          locale: widget.locale,
          closeLabel: widget.closeLabel,
          label: widget.label,
        );
      },
      child: _NebaToastScope(actions: _actions, child: widget.child),
    );

    // With no overlay above it, it brings one, so that it can be placed
    // around a navigator, whose own overlay is below it.
    if (Overlay.maybeOf(context, rootOverlay: true) == null) {
      result = Overlay.wrap(child: result);
    }

    return result;
  }
}

class _NebaToastScope extends InheritedWidget {
  const _NebaToastScope({required this.actions, required super.child});

  final NebaToastActions actions;

  @override
  bool updateShouldNotify(_NebaToastScope oldWidget) => actions != oldWidget.actions;
}

/// One toast in the stack, as the stack knows it.
@immutable
class _Entry {
  const _Entry({
    required this.id,
    required this.options,
    this.loading = false,
    this.ending = false,
    this.limited = false,
  });

  final String id;
  final NebaToastOptions options;

  /// Waiting on a promise, which keeps it from closing on its own.
  final bool loading;

  /// Closed, and fading out.
  final bool ending;

  /// Past the limit, and waiting out of sight.
  final bool limited;

  _Entry copyWith({NebaToastOptions? options, bool? loading, bool? ending, bool? limited}) {
    return _Entry(
      id: id,
      options: options ?? this.options,
      loading: loading ?? this.loading,
      ending: ending ?? this.ending,
      limited: limited ?? this.limited,
    );
  }
}

/// A toast's time on screen, which stops while the stack is held and goes
/// on from where it stopped.
class _Countdown {
  _Countdown(this.delay, this.onDone) : _remaining = delay;

  final Duration delay;
  final VoidCallback onDone;
  Duration _remaining;
  Timer? _timer;
  final Stopwatch _watch = Stopwatch();

  void start() {
    if (_timer != null) {
      return;
    }

    // A hold that began as the time ran out starts it again rather than
    // closing the toast the moment it lets go, as Base UI does.
    if (_remaining <= Duration.zero) {
      _remaining = delay;
    }

    _watch
      ..reset()
      ..start();
    _timer = Timer(_remaining, () {
      _timer = null;
      _watch.stop();
      onDone();
    });
  }

  void pause() {
    final Timer? timer = _timer;

    if (timer == null) {
      return;
    }

    timer.cancel();
    _timer = null;
    _watch.stop();
    _remaining -= _watch.elapsed;
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}

/// The stack: the toasts, their timers, and what holds them.
class _ToastStore extends ChangeNotifier {
  _ToastStore({required this.timeout, required int limit}) : _limit = limit;

  /// The provider's timeout, for the toasts raised from now on.
  Duration timeout;

  int _limit;
  int _count = 0;
  bool _disposed = false;

  /// Newest first, the closing ones included until they have faded out.
  List<_Entry> _entries = const <_Entry>[];
  final Map<String, _Countdown> _timers = <String, _Countdown>{};
  final Map<String, FocusNode> _nodes = <String, FocusNode>{};

  final ValueNotifier<List<NebaToastOptions>> toasts = ValueNotifier<List<NebaToastOptions>>(
    const <NebaToastOptions>[],
  );

  /// Called once a toast has been raised, after the stack has changed.
  VoidCallback? onRaise;
  bool _raised = false;
  bool _scheduled = false;

  /// Where the focus was before F6 took it into the stack.
  FocusNode? _previous;

  bool _hovering = false;
  bool _focused = false;
  bool _touching = false;
  bool _away = false;
  bool _paused = false;

  List<_Entry> get entries => _entries;

  bool get isEmpty => _entries.isEmpty;

  set limit(int value) {
    if (value == _limit) {
      return;
    }

    _limit = value;
    _entries = _limitedFrom(_entries);
    _changed();
  }

  set hovering(bool value) {
    _hovering = value;
    _hold();
  }

  set focused(bool value) {
    _focused = value;
    _hold();
  }

  set touching(bool value) {
    _touching = value;
    _hold();
  }

  set away(bool value) {
    _away = value;
    _hold();
  }

  bool get touching => _touching;

  void _hold() {
    final bool held = _hovering || _focused || _touching || _away;

    if (held == _paused) {
      return;
    }

    _paused = held;

    for (final _Countdown countdown in _timers.values) {
      held ? countdown.pause() : countdown.start();
    }
  }

  int _indexOf(String id) => _entries.indexWhere((_Entry entry) => entry.id == id);

  String add(NebaToastOptions options, {bool loading = false}) {
    final String? given = options.id;

    if (_disposed) {
      return given ?? '';
    }

    if (given != null) {
      final int index = _indexOf(given);

      if (index != -1) {
        final _Entry existing = _entries[index];

        if (!existing.ending) {
          _entries = List<_Entry>.of(_entries)
            ..[index] = existing.copyWith(
              options: _replaced(existing.options, options),
              loading: loading,
            );
          _schedule(given);
          _changed();

          return given;
        }

        // On its way out: it comes back as a toast of its own.
        _entries = List<_Entry>.of(_entries)..removeAt(index);
        _timers.remove(given)?.cancel();
      }
    }

    _count += 1;
    final String id = given ?? 'neba-toast-$_count';
    final _Entry entry = _Entry(
      id: id,
      options: given == null ? _withId(options, id) : options,
      loading: loading,
    );

    _entries = _limitedFrom(<_Entry>[entry, ..._entries]);
    _schedule(id);
    _raised = true;
    _changed();

    return id;
  }

  void update(String id, NebaToastOptions options) {
    final int index = _indexOf(id);

    if (_disposed || index == -1 || _entries[index].ending) {
      return;
    }

    final _Entry previous = _entries[index];
    _entries = List<_Entry>.of(_entries)
      ..[index] = previous.copyWith(options: _merged(previous.options, options));

    if (options.timeout != null) {
      _schedule(id);
    }

    _changed();
  }

  /// A promise's toast, once the promise has settled.
  void settle(String id, NebaToastOptions options) {
    final int index = _indexOf(id);

    if (_disposed || index == -1 || _entries[index].ending) {
      return;
    }

    final _Entry previous = _entries[index];
    _entries = List<_Entry>.of(_entries)
      ..[index] = previous.copyWith(
        options: _replaced(previous.options, options, settled: true),
        loading: false,
      );
    _schedule(id);
    _changed();
  }

  void close([String? id]) {
    if (_disposed) {
      return;
    }

    final List<_Entry> closing = <_Entry>[
      for (final _Entry entry in _entries)
        if (!entry.ending && (id == null || entry.id == id)) entry,
    ];

    if (closing.isEmpty) {
      return;
    }

    // Before the toast drops out of the focus order, so the focus has
    // somewhere to go.
    _moveFocus(id);

    final Set<String> ids = <String>{for (final _Entry entry in closing) entry.id};

    for (final String closed in ids) {
      _timers.remove(closed)?.cancel();
    }

    _entries = _limitedFrom(<_Entry>[
      for (final _Entry entry in _entries)
        ids.contains(entry.id) ? entry.copyWith(ending: true) : entry,
    ]);

    // Nothing left to read: whatever held the stack is over.
    if (_entries.every((_Entry entry) => entry.ending)) {
      _hovering = false;
      _focused = false;
      _touching = false;
      _hold();
    }

    _changed();

    for (final _Entry entry in closing) {
      entry.options.onClose?.call();
    }
  }

  /// Takes a toast out once it has faded.
  void remove(String id) {
    final int index = _indexOf(id);

    if (_disposed || index == -1) {
      return;
    }

    final _Entry entry = _entries[index];
    _entries = List<_Entry>.of(_entries)..removeAt(index);
    _changed();
    entry.options.onRemove?.call();
  }

  void attach(String id, FocusNode node) => _nodes[id] = node;

  void detach(String id, FocusNode node) {
    if (_nodes[id] == node) {
      _nodes.remove(id);
    }
  }

  bool _inside(FocusNode? node) {
    if (node == null) {
      return false;
    }

    return _nodes.values.any((FocusNode toast) => node == toast || node.ancestors.contains(toast));
  }

  /// F6: the focus to the newest toast on show.
  bool focusStack() {
    for (final _Entry entry in _entries) {
      if (entry.ending || entry.limited) {
        continue;
      }

      final FocusNode? node = _nodes[entry.id];

      if (node == null) {
        return false;
      }

      final FocusNode? current = FocusManager.instance.primaryFocus;

      if (!_inside(current)) {
        _previous = current;
      }

      node.requestFocus();

      return true;
    }

    return false;
  }

  // A keyboard reader whose toast closed under them goes to the next one,
  // then the one before, then back to where F6 found them.
  void _moveFocus(String? id) {
    final FocusNode? current = FocusManager.instance.primaryFocus;

    if (!_inside(current) || NebaInputModality.pointer.value) {
      return;
    }

    final int index = id == null ? -1 : _indexOf(id);

    if (index != -1) {
      bool open(int i) => !_entries[i].ending && !_entries[i].limited;

      for (int i = index + 1; i < _entries.length; i++) {
        if (open(i) && _nodes[_entries[i].id] != null) {
          _nodes[_entries[i].id]!.requestFocus();

          return;
        }
      }

      for (int i = index - 1; i >= 0; i--) {
        if (open(i) && _nodes[_entries[i].id] != null) {
          _nodes[_entries[i].id]!.requestFocus();

          return;
        }
      }
    }

    final FocusNode? previous = _previous;
    _previous = null;

    if (previous != null && previous.context != null) {
      previous.requestFocus();
    }
  }

  void _schedule(String id) {
    _timers.remove(id)?.cancel();

    final int index = _indexOf(id);

    if (index == -1) {
      return;
    }

    final _Entry entry = _entries[index];
    final Duration delay = entry.options.timeout ?? timeout;

    if (entry.ending || entry.loading || delay <= Duration.zero) {
      return;
    }

    final _Countdown countdown = _Countdown(delay, () {
      _timers.remove(id);
      close(id);
    });
    _timers[id] = countdown;

    if (!_paused) {
      countdown.start();
    }
  }

  // The newest `limit` that are not closing are shown and the rest wait.
  List<_Entry> _limitedFrom(List<_Entry> entries) {
    final List<_Entry> result = <_Entry>[];
    int active = 0;

    for (final _Entry entry in entries) {
      if (entry.ending) {
        result.add(entry);
        continue;
      }

      final bool limited = active >= _limit;
      active += 1;
      result.add(entry.limited == limited ? entry : entry.copyWith(limited: limited));
    }

    return result;
  }

  // A change that arrives during a build, from a widget raising a toast in
  // its `initState`, reaches the stack once the frame is drawn: nothing
  // built already may be marked for building again.
  void _changed() {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      if (!_scheduled) {
        _scheduled = true;
        SchedulerBinding.instance.addPostFrameCallback((Duration _) {
          _scheduled = false;
          _publish();
        });
      }

      return;
    }

    _publish();
  }

  void _publish() {
    if (_disposed) {
      return;
    }

    toasts.value = List<NebaToastOptions>.unmodifiable(<NebaToastOptions>[
      for (final _Entry entry in _entries)
        if (!entry.ending) entry.options,
    ]);
    notifyListeners();

    if (_raised) {
      _raised = false;
      onRaise?.call();
    }
  }

  @override
  void dispose() {
    _disposed = true;

    for (final _Countdown countdown in _timers.values) {
      countdown.cancel();
    }

    _timers.clear();
    toasts.dispose();
    super.dispose();
  }
}

/// The strip the toasts are stacked in, drawn in the overlay.
class _ToastViewport extends StatefulWidget {
  const _ToastViewport({
    required this.store,
    required this.position,
    required this.width,
    required this.variant,
    required this.size,
    required this.color,
    required this.density,
    required this.locale,
    required this.closeLabel,
    required this.label,
  });

  final _ToastStore store;
  final NebaToastPosition position;
  final double width;
  final NebaVariant? variant;
  final NebaSize? size;
  final NebaColor color;
  final NebaDensity? density;
  final Locale? locale;
  final String? closeLabel;
  final String? label;

  @override
  State<_ToastViewport> createState() => _ToastViewportState();
}

class _ToastViewportState extends State<_ToastViewport> {
  final Set<int> _fingers = <int>{};
  bool _routing = false;

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStore);
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStore);
    HardwareKeyboard.instance.removeHandler(_onKey);
    _stopRouting();
    super.dispose();
  }

  void _onStore() {
    if (widget.store.isEmpty || !widget.store.touching) {
      _stopRouting();
    }

    setState(() {});
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.f6) {
      return false;
    }

    return widget.store.focusStack();
  }

  // A finger on a toast holds the stack until a finger goes down somewhere
  // else, as Base UI does: a touch screen has no pointer that leaves.
  void _onPointerDown(PointerDownEvent event) {
    if (event.kind != PointerDeviceKind.touch) {
      return;
    }

    _fingers.add(event.pointer);
    widget.store.touching = true;

    if (!_routing) {
      _routing = true;
      GestureBinding.instance.pointerRouter.addGlobalRoute(_onPointer);
    }
  }

  void _onPointerEnd(PointerEvent event) {
    _fingers.remove(event.pointer);
  }

  // The toasts hear a press before this does, so a finger that went down on
  // one is already counted.
  void _onPointer(PointerEvent event) {
    if (event is PointerDownEvent &&
        event.kind == PointerDeviceKind.touch &&
        !_fingers.contains(event.pointer)) {
      widget.store.touching = false;
      _stopRouting();
    }
  }

  void _stopRouting() {
    if (_routing) {
      _routing = false;
      GestureBinding.instance.pointerRouter.removeGlobalRoute(_onPointer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<_Entry> entries = widget.store.entries;

    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool top = widget.position.edge == NebaSide.top;
    final String closeLabel =
        widget.closeLabel ?? nebaMessages(context, 'action', locale: widget.locale)['close']!;
    final String regionLabel =
        widget.label ?? nebaMessages(context, 'toast', locale: widget.locale)['label']!;
    final EdgeInsets padding =
        const EdgeInsets.all(NebaToastProvider.inset) +
        MediaQuery.paddingOf(context) +
        EdgeInsets.only(bottom: top ? 0 : MediaQuery.viewInsetsOf(context).bottom);

    final List<Widget> children = <Widget>[];
    bool first = true;

    for (final _Entry entry in entries) {
      final bool shown = !entry.limited;
      // Between two toasts on show; one waiting out of sight takes no room,
      // as `display: none` takes none.
      final double gap = shown && !first ? NebaToastProvider.gap : 0;

      children.add(
        Padding(
          key: ValueKey<String>(entry.id),
          padding: top ? EdgeInsets.only(top: gap) : EdgeInsets.only(bottom: gap),
          child: _ToastItem(
            entry: entry,
            store: widget.store,
            top: top,
            width: widget.width,
            variant: widget.variant,
            size: widget.size,
            color: widget.color,
            density: widget.density,
            closeLabel: closeLabel,
          ),
        ),
      );

      if (shown) {
        first = false;
      }
    }

    Widget stack = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: switch (widget.position.align) {
        NebaAlign.start => CrossAxisAlignment.start,
        NebaAlign.center => CrossAxisAlignment.center,
        NebaAlign.end => CrossAxisAlignment.end,
      },
      // The newest nearest the edge.
      verticalDirection: top ? VerticalDirection.down : VerticalDirection.up,
      children: children,
    );

    // Over a toast, and only over one: the strip between them is the page's.
    // Opaque, because a region that is not reports no hit upward, and a
    // press on a toast would reach the page under it.
    stack = MouseRegion(
      hitTestBehavior: HitTestBehavior.deferToChild,
      onEnter: (PointerEnterEvent _) => widget.store.hovering = true,
      onExit: (PointerExitEvent _) => widget.store.hovering = false,
      child: stack,
    );

    stack = Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerEnd,
      onPointerCancel: _onPointerEnd,
      child: stack,
    );

    // The keyboard focus anywhere in the stack holds it; a focus a press
    // gave a toast does not, as `:focus-visible` would not show it.
    stack = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onFocusChange: (bool focused) {
        widget.store.focused = focused && !NebaInputModality.pointer.value;
      },
      child: stack,
    );

    stack = Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.region,
      label: regionLabel,
      child: stack,
    );

    return NebaPortalText(
      child: Align(
        alignment: top ? Alignment.topCenter : Alignment.bottomCenter,
        child: Padding(
          padding: padding,
          child: SizedBox(width: double.infinity, child: stack),
        ),
      ),
    );
  }
}

/// One toast: its sheet, its fade, its focus and its swipe.
class _ToastItem extends StatefulWidget {
  const _ToastItem({
    required this.entry,
    required this.store,
    required this.top,
    required this.width,
    required this.variant,
    required this.size,
    required this.color,
    required this.density,
    required this.closeLabel,
  });

  final _Entry entry;
  final _ToastStore store;
  final bool top;
  final double width;
  final NebaVariant? variant;
  final NebaSize? size;
  final NebaColor color;
  final NebaDensity? density;
  final String closeLabel;

  @override
  State<_ToastItem> createState() => _ToastItemState();
}

class _ToastItemState extends State<_ToastItem> with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(vsync: this);
  late final CurvedAnimation _opacity = CurvedAnimation(
    parent: _fade,
    curve: NebaScale.ease,
    // A CSS transition runs the same curve whichever way it goes.
    reverseCurve: NebaScale.ease.flipped,
  );
  final FocusNode _focus = FocusNode(debugLabel: 'NebaToast');
  bool _started = false;
  bool _removing = false;

  // Where the hand has moved it, and along which axis, while it is dragged.
  Offset _drag = Offset.zero;
  Axis? _axis;

  String get _id => widget.entry.id;

  @override
  void initState() {
    super.initState();
    widget.store.attach(_id, _focus);
    _fade.addStatusListener(_onFade);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_started) {
      return;
    }

    _started = true;
    final Duration duration = nebaDuration(context, NebaScale.duration);
    _fade.duration = duration;

    if (widget.entry.ending) {
      _leave();
    } else if (duration == Duration.zero) {
      _fade.value = 1;
    } else {
      _fade.forward();
    }
  }

  @override
  void didUpdateWidget(_ToastItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.entry.ending && !oldWidget.entry.ending) {
      _leave();
    }
  }

  @override
  void dispose() {
    widget.store.detach(_id, _focus);
    _fade.removeStatusListener(_onFade);
    _opacity.dispose();
    _fade.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _leave() {
    final Duration duration = nebaDuration(context, NebaScale.duration);
    _fade.duration = duration;

    // One waiting out of sight has nothing to fade, and its clock is
    // stopped while it waits.
    if (duration == Duration.zero || widget.entry.limited || _fade.isDismissed) {
      _remove();
    } else {
      _fade.reverse();
    }
  }

  void _onFade(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && widget.entry.ending) {
      _remove();
    }
  }

  // Once, and never in the middle of a build: the stack tells whoever
  // listens to it.
  void _remove() {
    if (_removing) {
      return;
    }

    _removing = true;

    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((Duration _) => widget.store.remove(_id));
    } else {
      widget.store.remove(_id);
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape &&
        !widget.entry.ending) {
      widget.store.close(_id);

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // Base UI's swipe: the axis is the one the hand set off along, the toast
  // follows the hand along it, and a pull towards the edge it is not pinned
  // to is damped to the square root of the distance. Sideways is free both
  // ways.
  void _onMove(Offset travelled) {
    final Axis axis = _axis ??= travelled.dx.abs() > travelled.dy.abs()
        ? Axis.horizontal
        : Axis.vertical;

    setState(() {
      if (axis == Axis.horizontal) {
        _drag = Offset(travelled.dx, 0);
      } else {
        final double dy = travelled.dy;
        final bool towardsEdge = widget.top ? dy < 0 : dy > 0;
        _drag = Offset(0, towardsEdge ? dy : dy.sign * math.sqrt(dy.abs()));
      }
    });
  }

  void _onEnd() {
    final Axis? axis = _axis;
    _axis = null;

    final double along = switch (axis) {
      Axis.horizontal => _drag.dx.abs(),
      Axis.vertical => widget.top ? -_drag.dy : _drag.dy,
      null => 0,
    };

    if (along > NebaToastProvider.swipeThreshold) {
      // It stays where the hand let go of it and fades there.
      widget.store.close(_id);
    } else {
      setState(() => _drag = Offset.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _Entry entry = widget.entry;
    final NebaToastOptions options = entry.options;
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant =
        options.variant ?? widget.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColor color = options.color ?? widget.color;
    final NebaColorRoles roles = tokens.roles(color);
    final BorderRadius radius = BorderRadius.circular(tokens.radius[size]!);

    // On a filled toast the family is the surface, and everything rides on
    // it in one ink. On a tinted one the message stays reading text, and the
    // tint's ink marks the glyph, the title and the action.
    final bool solid = variant == NebaVariant.solid;
    final Color accent = solid ? roles.onSolid : roles.onTint;
    final Widget? actionLabel = options.actionLabel;

    final Widget content = NebaMessageContent(
      size: size,
      density: density,
      ink: solid ? roles.onSolid : tokens.fg,
      accent: accent,
      detail: solid ? roles.onSolid : tokens.mutedFg,
      role: options.priority == NebaToastPriority.high ? SemanticsRole.alert : SemanticsRole.status,
      glyph: options.showIcon ?? true
          ? options.icon ?? NebaGlyph(NebaGlyphs.severity(color))
          : null,
      title: options.title,
      message: options.description,
      action: actionLabel == null
          ? null
          : _ToastAction(
              label: actionLabel,
              onPressed: options.onAction,
              ink: accent,
              ring: roles.ring,
              size: size,
            ),
      onClose: () => widget.store.close(_id),
      closeLabel: widget.closeLabel,
      ring: roles.ring,
    );

    const NebaElevation elevation = NebaToastProvider.elevation;
    final Widget sheet = switch (variant) {
      NebaVariant.solid => NebaSheet(
        fill: roles.fill,
        elevation: elevation,
        borderRadius: radius,
        child: content,
      ),
      NebaVariant.outline => NebaSheet(
        fill: roles.panelPress,
        edge: roles.line,
        plate: NebaPlate.glass,
        elevation: elevation,
        borderRadius: radius,
        child: content,
      ),
      // The frosted sheet with no hairline: a toast floats, so even its
      // lightest surface needs the blur behind it.
      NebaVariant.text => NebaSheet(
        fill: roles.panelPress,
        plate: NebaPlate.glass,
        elevation: elevation,
        borderRadius: radius,
        child: content,
      ),
    };

    Widget toast = ListenableBuilder(
      listenable: _focus,
      builder: (BuildContext context, Widget? sheet) {
        return NebaFocusRing(
          visible: _focus.hasPrimaryFocus,
          color: roles.ring,
          borderRadius: radius,
          child: sheet!,
        );
      },
      child: sheet,
    );

    toast = Semantics(
      container: true,
      child: Focus(focusNode: _focus, onKeyEvent: _onKey, child: toast),
    );

    // The one movement a toast makes is the reader's hand, and it stops when
    // the hand lets go.
    final Widget held = toast;
    toast = Transform.translate(
      offset: _drag,
      child: NebaDragRegion(
        eager: false,
        enabled: !entry.ending,
        onMove: _onMove,
        onEnd: _onEnd,
        builder: (BuildContext context, bool dragging) => held,
      ),
    );

    toast = FadeTransition(
      opacity: _opacity,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.width),
        child: SizedBox(width: double.infinity, child: toast),
      ),
    );

    // A closing toast takes no press and is no longer read; one waiting past
    // the limit is not drawn at all, and comes back as it was.
    return Offstage(
      offstage: entry.limited,
      child: TickerMode(
        enabled: !entry.limited,
        child: ExcludeFocus(
          excluding: entry.ending || entry.limited,
          child: ExcludeSemantics(
            excluding: entry.ending,
            child: IgnorePointer(ignoring: entry.ending, child: toast),
          ),
        ),
      ),
    );
  }
}

/// The toast's one button: the label in the tint's ink at the size of a
/// caption, underlined under the pointer.
class _ToastAction extends StatelessWidget {
  const _ToastAction({
    required this.label,
    required this.onPressed,
    required this.ink,
    required this.ring,
    required this.size,
  });

  final Widget label;
  final VoidCallback? onPressed;
  final Color ink;
  final Color ring;
  final NebaSize size;

  @override
  Widget build(BuildContext context) {
    final double body = NebaScale.sheetBodyText[size]!;
    // `h-[1lh]`: the height of the message's first line, which the slot it
    // sits in already is.
    final double line =
        MediaQuery.textScalerOf(context).scale(body) * NebaScale.sheetBodyLeading[size]! / body;

    return Semantics(
      container: true,
      button: true,
      child: NebaInteractive(
        onTap: onPressed ?? () {},
        builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
          return NebaFocusRing(
            visible: interaction.focusVisible,
            color: ring,
            borderRadius: BorderRadius.circular(line / 2),
            child: SizedBox(
              height: line,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  widthFactor: 1,
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      fontSize: NebaScale.metaText[size],
                      fontWeight: FontWeight.w500,
                    ),
                    child: NebaInk(
                      color: ink,
                      child: NebaTextMarks(
                        underline: interaction.hovered ? ink : null,
                        child: label,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
