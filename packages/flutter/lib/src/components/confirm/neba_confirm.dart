/// `NebaConfirmProvider`, which hosts the one dialog every question below it
/// is asked in, and `NebaConfirm`, which asks one and waits for the answer.
library;

import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/button/neba_button.dart';
import 'package:neba/src/components/dialog/neba_dialog.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/types.dart';

/// What a confirm asks, and how it is dressed: the React package's
/// `ConfirmOptions`.
///
/// Every field is optional. A field a question leaves out falls back to the
/// [NebaConfirmProvider.defaults], and then to the default written on it.
@immutable
class NebaConfirmOptions {
  /// A question asking [title].
  const NebaConfirmOptions({
    this.title,
    this.description,
    this.confirmLabel,
    this.cancelLabel,
    this.color,
    this.size,
    this.alert,
    this.dismissible,
    this.locale,
    this.width,
  });

  /// The question, usually a [Text]: the dialog's heading, and what a screen
  /// reader announces.
  final Widget? title;

  /// What answering costs, usually a [Text]: the consequence, not a
  /// restatement of the title.
  final Widget? description;

  /// The confirming button's label. Defaults to the [locale]'s "Confirm".
  final Widget? confirmLabel;

  /// The cancelling button's label. Defaults to the [locale]'s "Cancel".
  final Widget? cancelLabel;

  /// The colour family of the confirming button and the sheet's edge, and
  /// [NebaColor.primary] when left out. [NebaColor.danger] for anything that
  /// destroys something, which is what most confirms are for; it also opens
  /// the question on the cancelling button.
  final NebaColor? color;

  /// The sheet's step on the size ladder, [NebaSize.sm] when left out.
  final NebaSize? size;

  /// Drops the cancelling button, leaving one way out: for telling rather
  /// than asking. It still answers, always `true`, so the same `await` works
  /// either way. `false` when left out.
  final bool? alert;

  /// Whether Escape, a press outside the sheet and a screen reader's dismiss
  /// gesture answer no. Off makes a question the reader has to answer with a
  /// button: use it rarely, since a modal with no way out is the thing people
  /// report. `true` when left out.
  final bool? dismissible;

  /// The language the two default labels are in. Defaults to
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// The widest the sheet gets, in logical pixels, passed to [NebaDialog].
  final double? width;

  /// Every field this question sets, over [defaults].
  NebaConfirmOptions _over(NebaConfirmOptions defaults) {
    return NebaConfirmOptions(
      title: title ?? defaults.title,
      description: description ?? defaults.description,
      confirmLabel: confirmLabel ?? defaults.confirmLabel,
      cancelLabel: cancelLabel ?? defaults.cancelLabel,
      color: color ?? defaults.color,
      size: size ?? defaults.size,
      alert: alert ?? defaults.alert,
      dismissible: dismissible ?? defaults.dismissible,
      locale: locale ?? defaults.locale,
      width: width ?? defaults.width,
    );
  }
}

/// Asks a question in a dialog and resolves to what the reader answered: the
/// React package's `ConfirmFunction`, which `useConfirm()` returns.
///
/// Reach it with `NebaConfirmProvider.of(context)` and call it:
///
/// ```dart
/// final NebaConfirm confirm = NebaConfirmProvider.of(context);
///
/// if (await confirm(
///   const NebaConfirmOptions(title: Text('Delete the project?'), color: NebaColor.danger),
/// )) {
///   remove();
/// }
/// ```
///
/// The future completes with `true` when the reader confirms and `false` when
/// they cancel, press Escape or press outside the sheet, and with `false`
/// when the provider leaves the tree before the question is answered. It
/// never completes with an error: a question answered no is an answer, not a
/// failure.
final class NebaConfirm {
  NebaConfirm._(this._state);

  final _NebaConfirmProviderState _state;

  /// Asks [options] and waits for the answer.
  Future<bool> call(NebaConfirmOptions options) => _state._ask(options);
}

/// Hosts the one dialog every question asked below it is asked in, through
/// `NebaConfirmProvider.of(context)`.
///
/// Place it once, around the app. What a caller has at the moment a question
/// is warranted is a press handler rather than a place in the tree, and a
/// [NebaDialog] with a piece of state for each question is the shape this
/// exists to avoid.
///
/// **Questions wait their turn.** Two asked at once are two questions
/// somebody meant to ask, so the second waits for the first, and nothing but
/// a person answers one while the provider is there. When it leaves the tree,
/// everything still waiting is answered `false`, since nobody is left to ask,
/// and so is a question asked after that.
///
/// The dialog is drawn in the root [Overlay] above the provider, and a
/// provider with none above it brings its own, so it can sit around the
/// navigator in `WidgetsApp.builder`.
///
/// ```dart
/// NebaConfirmProvider(
///   defaults: const NebaConfirmOptions(size: NebaSize.md),
///   child: app,
/// )
/// ```
class NebaConfirmProvider extends StatefulWidget {
  /// Questions asked anywhere below [child].
  const NebaConfirmProvider({
    required this.child,
    this.defaults = const NebaConfirmOptions(),
    super.key,
  });

  /// The app.
  final Widget child;

  /// What every question asked below it shares, such as its `color`, `size`,
  /// `width` and `locale`. Each question overrides them.
  final NebaConfirmOptions defaults;

  /// The asking half of the nearest [NebaConfirmProvider] above [context]:
  /// the React package's `useConfirm()`.
  ///
  /// It does not make [context] depend on anything, so it can be called from
  /// `initState`, from a build or from a press, and the object it returns is
  /// the same for the life of the provider.
  static NebaConfirm of(BuildContext context) {
    final NebaConfirm? confirm = maybeOf(context);

    if (confirm == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('NebaConfirmProvider.of() was called with no NebaConfirmProvider above it.'),
        ErrorHint(
          'Place one NebaConfirmProvider around the app, such as in WidgetsApp.builder around '
          'the navigator, so that every route can ask a question.',
        ),
        context.describeElement('The context used was'),
      ]);
    }

    return confirm;
  }

  /// [of], or `null` when there is no [NebaConfirmProvider] above [context].
  static NebaConfirm? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<_NebaConfirmScope>()?.confirm;
  }

  @override
  State<NebaConfirmProvider> createState() => _NebaConfirmProviderState();
}

/// One question waiting: what to ask, and the future waiting on the answer.
class _Pending {
  _Pending(this.options);

  final NebaConfirmOptions options;
  final Completer<bool> answer = Completer<bool>();
}

class _NebaConfirmProviderState extends State<NebaConfirmProvider> {
  late final NebaConfirm _confirm = NebaConfirm._(this);
  final List<_Pending> _queue = <_Pending>[];

  /// The question on the sheet, which outlives the head of the queue: the
  /// sheet keeps the last thing it was asked while it fades out.
  NebaConfirmOptions _shown = const NebaConfirmOptions();

  /// Which sheet the question is on. A question that takes over the open
  /// sheet from the one before it gets a sheet of its own, so that it opens:
  /// the focus goes to its own answer and its title is announced. It stays
  /// when the sheet closes, so the closing sheet is the same one and fades.
  int _sheet = 0;

  /// What held the focus when the first of a run of questions was asked, and
  /// so where it goes back to once the last is answered: a confirm has no
  /// trigger of its own to return to.
  FocusNode? _opener;

  bool _gone = false;

  @override
  void dispose() {
    _gone = true;

    for (final _Pending pending in _queue) {
      pending.answer.complete(false);
    }

    _queue.clear();
    super.dispose();
  }

  Future<bool> _ask(NebaConfirmOptions options) {
    if (_gone) {
      return Future<bool>.value(false);
    }

    final _Pending pending = _Pending(options);

    if (_queue.isEmpty) {
      _opener = FocusManager.instance.primaryFocus;
      _shown = options;
    }

    _queue.add(pending);
    _rebuild();

    return pending.answer.future;
  }

  void _answer(bool value) {
    if (_queue.isEmpty) {
      return;
    }

    final _Pending current = _queue.removeAt(0);
    current.answer.complete(value);

    if (_queue.isNotEmpty) {
      _shown = _queue.first.options;
      _sheet += 1;
    }

    _rebuild();
  }

  // A question asked while a frame is being built, from a widget's
  // `initState` say, is shown once that frame is out.
  void _rebuild() {
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

  @override
  Widget build(BuildContext context) {
    Widget result = _NebaConfirmScope(
      confirm: _confirm,
      // The sheet beside the app rather than around it, so that a sheet of
      // its own for the next question leaves the app where it is.
      child: Stack(
        alignment: Alignment.topLeft,
        fit: StackFit.passthrough,
        children: <Widget>[
          widget.child,
          _ConfirmSheet(
            key: ValueKey<int>(_sheet),
            open: _queue.isNotEmpty,
            options: _shown._over(widget.defaults),
            opener: _opener,
            onAnswer: _answer,
          ),
        ],
      ),
    );

    // With no overlay above it, it brings one, so that it can be placed
    // around a navigator, whose own overlay is below it.
    if (Overlay.maybeOf(context, rootOverlay: true) == null) {
      result = Overlay.wrap(child: result);
    }

    return result;
  }
}

class _NebaConfirmScope extends InheritedWidget {
  const _NebaConfirmScope({required this.confirm, required super.child});

  final NebaConfirm confirm;

  @override
  bool updateShouldNotify(_NebaConfirmScope oldWidget) => confirm != oldWidget.confirm;
}

/// The dialog one question is asked in, with the two answers it puts the
/// focus on.
class _ConfirmSheet extends StatefulWidget {
  const _ConfirmSheet({
    required this.open,
    required this.options,
    required this.opener,
    required this.onAnswer,
    super.key,
  });

  final bool open;
  final NebaConfirmOptions options;
  final FocusNode? opener;
  final ValueChanged<bool> onAnswer;

  @override
  State<_ConfirmSheet> createState() => _ConfirmSheetState();
}

class _ConfirmSheetState extends State<_ConfirmSheet> {
  final FocusNode _cancel = FocusNode(debugLabel: 'NebaConfirm cancel');
  final FocusNode _confirm = FocusNode(debugLabel: 'NebaConfirm confirm');

  @override
  void dispose() {
    _cancel.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NebaConfirmOptions options = widget.options;
    final NebaColor color = options.color ?? NebaColor.primary;
    final bool alert = options.alert ?? false;
    final Map<String, String> messages = nebaMessages(context, 'confirm', locale: options.locale);
    // A destructive question opens on the answer that destroys nothing, so a
    // reader who pressed Enter once to ask is not one more Enter from the
    // loss.
    final bool cautious = color == NebaColor.danger && !alert;

    return NebaDialog(
      open: widget.open,
      // Escape and a press outside are the cancelling button by another
      // route. An alert has no cancelling button: dismissing it is
      // acknowledging it.
      onOpenChange: (bool open) {
        if (!open) {
          widget.onAnswer(alert);
        }
      },
      size: options.size ?? NebaSize.sm,
      color: color,
      width: options.width,
      title: options.title,
      description: options.description,
      dismissible: options.dismissible ?? true,
      showClose: false,
      // A question to be answered before anything else happens, which a
      // screen reader announces with more urgency than a dialog.
      role: SemanticsRole.alertDialog,
      initialFocus: cautious ? _cancel : _confirm,
      finalFocus: widget.opener,
      actions: <Widget>[
        if (!alert)
          NebaButton(
            focusNode: _cancel,
            onPressed: () => widget.onAnswer(false),
            variant: NebaVariant.text,
            color: NebaColor.secondary,
            child: options.cancelLabel ?? Text(messages['cancel']!),
          ),
        NebaButton(
          focusNode: _confirm,
          onPressed: () => widget.onAnswer(true),
          variant: NebaVariant.solid,
          color: color,
          child: options.confirmLabel ?? Text(messages['confirm']!),
        ),
      ],
    );
  }
}
