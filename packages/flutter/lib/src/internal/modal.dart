/// A surface that takes the page: the overlay it is shown in, the scrim
/// behind it, the focus held inside it and given back, and the ways out.
///
/// The React package leaves all of it to Base UI's dialog: the portal, the
/// focus trap, the inert page, Escape, the press outside and the focus
/// returned to the trigger. Flutter has the pieces and none of the assembly,
/// so it is assembled here once, for every surface that is modal: a Drawer
/// first, and a Dialog, a Confirm and a CommandPalette after it.
///
/// The surface is shown in the app's root overlay, because it is attached to
/// the window rather than to where it was written, and it is built where it
/// was written, so it keeps the theme and the `NebaProvider` defaults from
/// there, as `NebaPortal` does.
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:ui' as ui;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Builds the surface of a [NebaModalLayer] from how far it has arrived,
/// from `0`, not there, to `1`, there. The surface is laid out against the
/// whole overlay, so an `Align` places it.
typedef NebaModalBuilder = Widget Function(BuildContext context, Animation<double> arrival);

/// A surface shown over the page while [open], with a scrim behind it.
///
/// [child] stays where it was written and takes the room it takes there; the
/// surface goes into the root [Overlay]. While it is open the focus is inside
/// it: the first thing in it that takes the focus has it, Tab goes round
/// inside it, and when it closes the focus goes back to what had it before.
/// Escape and a press on the scrim ask for it to close through [onDismiss],
/// unless it is not [dismissible]; the owner decides, so a controlled surface
/// stays open until its owner says otherwise.
class NebaModalLayer extends StatefulWidget {
  /// A surface built by [builder], shown while [open].
  const NebaModalLayer({
    required this.open,
    required this.builder,
    required this.onDismiss,
    this.modal = NebaModal.on,
    this.dismissible = true,
    this.keepMounted = false,
    this.label,
    this.child,
    super.key,
  });

  /// Whether the surface is shown. It arrives and leaves over
  /// `NebaScale.duration`, and in no time for a reader who asked for less
  /// motion.
  final bool open;

  /// Builds the surface.
  final NebaModalBuilder builder;

  /// Asks for the surface to close: Escape, or a press on the scrim.
  final VoidCallback onDismiss;

  /// How much of the page it takes away.
  final NebaModal modal;

  /// Whether Escape and a press outside the surface ask for it to close.
  final bool dismissible;

  /// Keeps the surface built while it is closed, offstage, out of the focus
  /// order and out of the semantics tree, so what is in it keeps its state
  /// between one opening and the next.
  final bool keepMounted;

  /// The name a screen reader announces for the surface, for one with no
  /// title of its own to name it.
  final String? label;

  /// What stays where the layer was written: usually what opens it.
  final Widget? child;

  @override
  State<NebaModalLayer> createState() => _NebaModalLayerState();
}

class _NebaModalLayerState extends State<NebaModalLayer> with SingleTickerProviderStateMixin {
  final OverlayPortalController _portal = OverlayPortalController();
  final FocusScopeNode _scope = FocusScopeNode(debugLabel: 'NebaModalLayer');

  late final AnimationController _arrival = AnimationController(
    vsync: this,
    duration: NebaScale.duration,
    value: widget.open ? 1 : 0,
  )..addStatusListener(_onStatus);

  late final CurvedAnimation _curved = CurvedAnimation(parent: _arrival, curve: NebaScale.ease);

  /// What held the focus before the surface opened, given it back on closing.
  FocusNode? _returnTo;

  @override
  void initState() {
    super.initState();
    // Shown for as long as the layer is there, with nothing in it while it is
    // closed: a portal may only be shown outside a build, and a surface that
    // waited for the frame after its opening would arrive a frame late.
    _portal.show();

    if (widget.open) {
      _takeFocus();
    }
  }

  @override
  void didUpdateWidget(NebaModalLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.open != oldWidget.open) {
      if (widget.open) {
        _opened();
      } else {
        _closed();
      }
    }
  }

  @override
  void dispose() {
    _curved.dispose();
    _arrival.dispose();
    _scope.dispose();
    super.dispose();
  }

  void _opened() {
    _arrival.duration = nebaDuration(context, NebaScale.duration);
    _arrival.forward();
    _takeFocus();

    // Shown again once the frame is out, so a surface opened after another
    // lands on top of it.
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted && widget.open) {
        _portal.show();
      }
    });
  }

  void _closed() {
    _arrival.duration = nebaDuration(context, NebaScale.duration);
    _arrival.reverse();
    _giveFocusBack();
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && !widget.open && mounted) {
      // Rebuilt empty, or offstage when it is kept.
      setState(() {});
    }
  }

  void _takeFocus() {
    final FocusNode? current = FocusManager.instance.primaryFocus;

    if (current != null && current != _scope && !_scope.hasFocus) {
      _returnTo = current;
    }

    // Once the surface is built: the scope first, so Escape has somewhere to
    // land when nothing inside takes the focus, then the first thing that does.
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted || !widget.open || _scope.context == null) {
        return;
      }

      _scope.requestFocus();
      _scope.nextFocus();
    });
  }

  void _giveFocusBack() {
    final FocusNode? target = _returnTo;
    _returnTo = null;

    if (_scope.hasFocus && target != null && target.context != null && target.canRequestFocus) {
      target.requestFocus();
    } else if (_scope.hasFocus) {
      _scope.unfocus();
    }
  }

  void _dismiss() {
    if (widget.dismissible && widget.open) {
      widget.onDismiss();
    }
  }

  Widget _surface(BuildContext context) {
    final bool shown = widget.open || !_arrival.isDismissed;
    final bool blocking = widget.modal == NebaModal.on;

    if (!shown && !widget.keepMounted) {
      return const SizedBox.shrink();
    }

    Widget surface = widget.builder(context, _curved);
    surface = Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      role: SemanticsRole.dialog,
      label: widget.label,
      onDismiss: widget.dismissible ? _dismiss : null,
      child: FocusScope(node: _scope, child: surface),
    );

    surface = Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (DismissIntent intent) {
              _dismiss();
              return null;
            },
          ),
        },
        child: surface,
      ),
    );

    final Widget layer = Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // Outside a full modal the page stays usable and the press goes on to
        // it, so a press anywhere but the surface is the way out the scrim is
        // everywhere else. Under the surface, so a press on it is not one, and
        // there in every mode, so a change of mode keeps what is in the surface.
        IgnorePointer(
          ignoring: blocking,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (PointerDownEvent event) => _dismiss(),
          ),
        ),
        _Scrim(
          opacity: _curved,
          // The scrim is still drawn outside a full modal; only the pointer
          // goes through it, to the page.
          blocking: blocking,
          onPressed: _dismiss,
        ),
        surface,
      ],
    );

    // One shape whether it is open or kept closed, so a kept surface keeps
    // what is in it. Closed, it is built and nothing of it reaches the screen,
    // the pointer, the keyboard or a screen reader.
    return Offstage(
      offstage: !shown,
      child: ExcludeFocus(
        excluding: !shown,
        child: TickerMode(
          enabled: shown,
          child: BlockSemantics(blocking: blocking && shown, child: layer),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tab goes round inside a modal surface, and a modeless one lets it out,
    // as Base UI's does.
    _scope.traversalEdgeBehavior = widget.modal == NebaModal.off
        ? TraversalEdgeBehavior.parentScope
        : TraversalEdgeBehavior.closedLoop;

    return OverlayPortal(
      controller: _portal,
      overlayLocation: OverlayChildLocation.rootOverlay,
      overlayChildBuilder: _surface,
      child: widget.child,
    );
  }
}

/// The page dimmed behind a modal surface, `--neba-scrim` over a 2-pixel blur,
/// fading with the surface.
class _Scrim extends StatelessWidget {
  const _Scrim({required this.opacity, required this.blocking, required this.onPressed});

  final Animation<double> opacity;
  final bool blocking;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return IgnorePointer(
      ignoring: !blocking,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        // The way out a screen reader has is the surface's own dismiss action.
        excludeFromSemantics: true,
        child: FadeTransition(
          opacity: opacity,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: ColoredBox(color: tokens.scrim),
          ),
        ),
      ),
    );
  }
}
