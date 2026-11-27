// What the React package's Toast test covers, asked the way Flutter asks it:
// the toasts a provider draws once something raises them, where they sit,
// how long they stay and what holds them, how they close, and what a screen
// reader is told.

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/live_region.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/internal/text_marks.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  const Duration fade = Duration(milliseconds: 160);
  const NebaToastOptions saved = NebaToastOptions(title: Text('Saved'), timeout: Duration.zero);

  // The provider around an app that hands its actions to the test.
  Future<NebaToastActions> pump(
    WidgetTester tester, {
    NebaToastPosition position = NebaToastPosition.bottomEnd,
    Duration timeout = const Duration(milliseconds: 5000),
    int limit = 3,
    double width = 380,
    NebaVariant? variant,
    NebaColor? color,
    Locale? locale,
    String? closeLabel,
    String? label,
    Widget app = const SizedBox.expand(),
    double hostWidth = 800,
    bool disableAnimations = false,
    TextDirection textDirection = TextDirection.ltr,
    EdgeInsets padding = EdgeInsets.zero,
    EdgeInsets viewInsets = EdgeInsets.zero,
  }) async {
    late NebaToastActions actions;

    await tester.pumpWidget(
      host(
        Builder(
          builder: (BuildContext context) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(padding: padding, viewInsets: viewInsets),
              child: NebaToastProvider(
                position: position,
                timeout: timeout,
                limit: limit,
                width: width,
                variant: variant,
                color: color,
                locale: locale,
                closeLabel: closeLabel,
                label: label,
                child: Builder(
                  builder: (BuildContext context) {
                    actions = NebaToastProvider.of(context);

                    return app;
                  },
                ),
              ),
            );
          },
        ),
        width: hostWidth,
        disableAnimations: disableAnimations,
        textDirection: textDirection,
      ),
    );

    return actions;
  }

  // Raised, built and faded in.
  Future<String> raise(
    WidgetTester tester,
    NebaToastActions actions,
    NebaToastOptions options,
  ) async {
    final String id = actions.add(options);
    await tester.pump();
    await tester.pump(fade);

    return id;
  }

  // Faded out and gone: an animation is done only once its duration has
  // passed, so a frame just after it.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(fade + const Duration(milliseconds: 1));
    await tester.pump();
  }

  Rect toastRect(WidgetTester tester, String text) {
    return tester.getRect(
      find.ancestor(of: find.text(text), matching: find.byType(NebaSheet)).first,
    );
  }

  NebaSheet sheetOf(WidgetTester tester, String text) {
    return tester.widget<NebaSheet>(
      find.ancestor(of: find.text(text), matching: find.byType(NebaSheet)).first,
    );
  }

  Finder closeGlyph() => find.byWidgetPredicate(
    (Widget widget) => widget is NebaGlyph && identical(widget.parts, NebaGlyphs.close),
  );

  Finder severityGlyph() => find.byWidgetPredicate(
    (Widget widget) => widget is NebaGlyph && !identical(widget.parts, NebaGlyphs.close),
  );

  double opacityOf(WidgetTester tester, String text) {
    return tester
        .widget<FadeTransition>(
          find.ancestor(of: find.text(text), matching: find.byType(FadeTransition)).first,
        )
        .opacity
        .value;
  }

  FocusNode toastFocus(WidgetTester tester, String text) {
    return Focus.of(tester.element(find.text(text)));
  }

  group('raising one', () {
    testWidgets('draws nothing until something raises a toast', (WidgetTester tester) async {
      await pump(tester);

      expect(find.byType(NebaSheet), findsNothing);
    });

    testWidgets('shows the title and the description', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester);

      await raise(
        tester,
        actions,
        const NebaToastOptions(
          title: Text('Deploy failed'),
          description: Text('The build exited with 1.'),
        ),
      );

      expect(find.text('Deploy failed'), findsOneWidget);
      expect(find.text('The build exited with 1.'), findsOneWidget);
    });

    testWidgets('shows a toast with a description alone', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester);

      await raise(tester, actions, const NebaToastOptions(description: Text('Copied')));

      expect(find.text('Copied'), findsOneWidget);
    });

    testWidgets('stacks more than one, the newest nearest the edge', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester);

      await raise(tester, actions, const NebaToastOptions(title: Text('One')));
      await raise(tester, actions, const NebaToastOptions(title: Text('Two')));

      expect(toastRect(tester, 'Two').bottom, 600 - NebaToastProvider.inset);
      expect(toastRect(tester, 'Two').top - toastRect(tester, 'One').bottom, NebaToastProvider.gap);
    });

    testWidgets('keeps the toasts past the limit out of sight, and shows them as it drains', (
      WidgetTester tester,
    ) async {
      final NebaToastActions actions = await pump(tester, limit: 2);

      final String one = await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('One'), timeout: Duration.zero),
      );
      await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('Two'), timeout: Duration.zero),
      );
      final String three = await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('Three'), timeout: Duration.zero),
      );

      expect(find.text('One'), findsNothing);
      expect(find.text('One', skipOffstage: false), findsOneWidget);
      // It takes no room while it waits, and leaves no gap.
      expect(tester.getSize(find.byKey(ValueKey<String>(one), skipOffstage: false)).height, 0);

      actions.close(three);
      await settle(tester);

      expect(find.text('One'), findsOneWidget);
      expect(find.text('Three', skipOffstage: false), findsNothing);
    });

    testWidgets('runs the timer of a toast waiting past the limit', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester, limit: 1);

      await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('One'), timeout: Duration(seconds: 1)),
      );
      await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('Two'), timeout: Duration.zero),
      );

      await tester.pump(const Duration(seconds: 1));
      await settle(tester);

      expect(find.text('One', skipOffstage: false), findsNothing);
      expect(find.text('Two'), findsOneWidget);
    });

    testWidgets('changes the toast it has when one is raised under the same id', (
      WidgetTester tester,
    ) async {
      final NebaToastActions actions = await pump(tester);

      await raise(
        tester,
        actions,
        const NebaToastOptions(id: 'sync', title: Text('Syncing'), timeout: Duration.zero),
      );
      final String id = await raise(
        tester,
        actions,
        const NebaToastOptions(id: 'sync', title: Text('Synced'), timeout: Duration.zero),
      );

      expect(id, 'sync');
      expect(find.text('Syncing'), findsNothing);
      expect(find.text('Synced'), findsOneWidget);
    });

    testWidgets('starts the timer again when one is raised under the same id', (
      WidgetTester tester,
    ) async {
      final NebaToastActions actions = await pump(tester);
      const Duration second = Duration(seconds: 1);

      await raise(
        tester,
        actions,
        const NebaToastOptions(id: 'job', title: Text('One'), timeout: second),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await raise(tester, actions, const NebaToastOptions(id: 'job', title: Text('Two')));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Two'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);

      expect(find.text('Two'), findsNothing);
    });

    testWidgets('makes up an id when it is given none', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester);

      final String one = actions.add(saved);
      final String two = actions.add(saved);

      expect(one, isNotEmpty);
      expect(two, isNot(one));
    });
  });

  group('the actions', () {
    testWidgets('are the same object for the life of the provider', (WidgetTester tester) async {
      final NebaToastActions first = await pump(tester);
      first.add(saved);
      await tester.pump();
      final NebaToastActions second = await pump(tester);

      expect(identical(first, second), isTrue);
    });

    testWidgets('tell a caller that forgot the provider', (WidgetTester tester) async {
      late BuildContext context;

      await tester.pumpWidget(
        host(
          Builder(
            builder: (BuildContext inner) {
              context = inner;

              return const SizedBox();
            },
          ),
        ),
      );

      expect(NebaToastProvider.maybeOf(context), isNull);
      expect(() => NebaToastProvider.of(context), throwsA(isA<FlutterError>()));
    });

    testWidgets('raise a toast from a widget as it is first built', (WidgetTester tester) async {
      await pump(tester, app: const _RaisesOnStart());
      await tester.pump();

      expect(find.text('Connection lost'), findsOneWidget);
    });

    testWidgets('never build again a widget that only raises toasts', (WidgetTester tester) async {
      int builds = 0;
      late NebaToastActions actions;

      await pump(
        tester,
        app: Builder(
          builder: (BuildContext context) {
            builds += 1;
            actions = NebaToastProvider.of(context);

            return const SizedBox.expand();
          },
        ),
      );

      final int before = builds;
      await raise(tester, actions, saved);
      await raise(tester, actions, saved);

      expect(builds, before);
      expect(find.text('Saved'), findsNWidgets(2));
    });

    testWidgets('list the open toasts newest first, each with its id', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester);

      final String one = await raise(tester, actions, saved);
      final String two = await raise(tester, actions, saved);

      expect(actions.toasts.value.map((NebaToastOptions toast) => toast.id), <String>[two, one]);

      actions.close(one);
      await tester.pump();

      expect(actions.toasts.value.map((NebaToastOptions toast) => toast.id), <String>[two]);
    });

    testWidgets('update a toast and keep what the update does not mention', (
      WidgetTester tester,
    ) async {
      final NebaToastActions actions = await pump(tester);

      final String id = await raise(
        tester,
        actions,
        const NebaToastOptions(
          title: Text('Upload'),
          color: NebaColor.danger,
          actionLabel: Text('Retry'),
          timeout: Duration.zero,
        ),
      );
      actions.update(id, const NebaToastOptions(description: Text('Halfway')));
      await tester.pump();

      expect(find.text('Halfway'), findsOneWidget);
      expect(find.text('Upload'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(sheetOf(tester, 'Upload').fill, tokens.roles(NebaColor.danger).panelPress);
    });

    testWidgets('keep the timer running through an update', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester);

      final String id = await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('Upload'), timeout: Duration(seconds: 1)),
      );
      await tester.pump(const Duration(milliseconds: 600));
      actions.update(id, const NebaToastOptions(description: Text('Halfway')));
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);

      expect(find.text('Upload'), findsNothing);
    });

    testWidgets('close every toast at once when close is called with nothing', (
      WidgetTester tester,
    ) async {
      final NebaToastActions actions = await pump(tester);

      await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('One'), timeout: Duration.zero),
      );
      await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('Two'), timeout: Duration.zero),
      );
      actions.close();
      await settle(tester);

      expect(find.byType(NebaSheet), findsNothing);
    });
  });

  group('following a future', () {
    testWidgets('shows the loading toast, then the success', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester, timeout: const Duration(seconds: 1));
      final Completer<String> job = Completer<String>();

      final Future<String> result = actions.promise<String>(
        job.future,
        loading: const NebaToastOptions(title: Text('Saving')),
        success: (String value) => NebaToastOptions(title: Text(value)),
        error: (Object error) => const NebaToastOptions(title: Text('Failed')),
      );
      await tester.pump();

      expect(find.text('Saving'), findsOneWidget);

      // The loading toast never closes on its own.
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Saving'), findsOneWidget);

      job.complete('Saved');
      await tester.pump();

      expect(await result, 'Saved');
      await tester.pump();
      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('Saving'), findsNothing);

      // And the success takes the provider's timeout.
      await tester.pump(const Duration(seconds: 1));
      await settle(tester);
      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('shows the error when the future fails, and fails as it does', (
      WidgetTester tester,
    ) async {
      final NebaToastActions actions = await pump(tester);
      final Completer<String> job = Completer<String>();

      final Future<String> result = actions.promise<String>(
        job.future,
        loading: const NebaToastOptions(title: Text('Saving')),
        success: (String value) => const NebaToastOptions(title: Text('Saved')),
        error: (Object error) => NebaToastOptions(title: Text('$error'), timeout: Duration.zero),
      );
      final Future<void> failed = expectLater(result, throwsA('Offline'));
      await tester.pump();

      job.completeError('Offline');
      await tester.pump();
      await failed;

      expect(find.text('Offline'), findsOneWidget);
    });

    testWidgets('takes the look of the outcome rather than keeping the loading one', (
      WidgetTester tester,
    ) async {
      final NebaToastActions actions = await pump(tester);
      final Completer<void> job = Completer<void>();

      unawaited(
        actions.promise<void>(
          job.future,
          loading: const NebaToastOptions(title: Text('Uploading'), showIcon: false),
          success: (void _) =>
              const NebaToastOptions(color: NebaColor.success, title: Text('Uploaded')),
          error: (Object _) => const NebaToastOptions(title: Text('Failed')),
        ),
      );
      await tester.pump();

      expect(severityGlyph(), findsNothing);

      job.complete();
      await tester.pump();

      expect(
        tester.widget<NebaGlyph>(severityGlyph()).parts,
        same(NebaGlyphs.severity(NebaColor.success)),
      );
      expect(sheetOf(tester, 'Uploaded').fill, tokens.roles(NebaColor.success).panelPress);
    });
  });

  group('dismissing', () {
    testWidgets('closes from its ×, then leaves once it has faded', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester);
      int closed = 0;
      int removed = 0;

      await raise(
        tester,
        actions,
        NebaToastOptions(
          title: const Text('Saved'),
          timeout: Duration.zero,
          onClose: () => closed += 1,
          onRemove: () => removed += 1,
        ),
      );
      await tester.tap(closeGlyph());
      await tester.pump();

      expect(closed, 1);
      expect(removed, 0);
      // Still there while it fades.
      expect(find.text('Saved'), findsOneWidget);

      await settle(tester);

      expect(removed, 1);
      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('dismisses itself once its timeout has run out', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester);

      await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('Saved'), timeout: Duration(milliseconds: 200)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await settle(tester);

      expect(find.text('Saved'), findsNothing);
    });

    testWidgets("lasts the provider's timeout when it names none", (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester);

      actions.add(const NebaToastOptions(title: Text('Saved')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 4900));

      expect(find.text('Saved'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      await settle(tester);

      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('stays up when its timeout is zero', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(
        tester,
        timeout: const Duration(milliseconds: 60),
      );

      await raise(tester, actions, saved);
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('takes a name of its own for the ×', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final NebaToastActions actions = await pump(tester, closeLabel: 'Dismiss');

      await raise(tester, actions, saved);

      expect(find.bySemanticsLabel('Dismiss'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('closes on Escape while it holds the focus', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester);
      int closed = 0;

      await raise(
        tester,
        actions,
        NebaToastOptions(
          title: const Text('Saved'),
          timeout: Duration.zero,
          onClose: () => closed += 1,
        ),
      );
      toastFocus(tester, 'Saved').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);

      expect(closed, 1);
      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('is swiped away sideways', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester);

      await raise(tester, actions, saved);
      await tester.drag(find.text('Saved'), const Offset(-60, 0));
      await settle(tester);

      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('is swiped away towards the edge it is pinned to', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester);

      await raise(tester, actions, saved);
      await tester.drag(find.text('Saved'), const Offset(0, 60));
      await settle(tester);

      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('on a top stack, is swiped away upwards and not downwards', (
      WidgetTester tester,
    ) async {
      final NebaToastActions actions = await pump(tester, position: NebaToastPosition.topEnd);

      await raise(tester, actions, saved);
      await tester.drag(find.text('Saved'), const Offset(0, 60));
      await settle(tester);

      expect(find.text('Saved'), findsOneWidget);

      await tester.drag(find.text('Saved'), const Offset(0, -60));
      await settle(tester);

      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('follows the hand, damped away from its edge, and goes back when let go short', (
      WidgetTester tester,
    ) async {
      final NebaToastActions actions = await pump(tester);

      await raise(tester, actions, saved);
      final Rect rest = toastRect(tester, 'Saved');

      final TestGesture hand = await tester.startGesture(tester.getCenter(find.text('Saved')));
      await hand.moveBy(const Offset(20, 0));
      await hand.moveBy(const Offset(10, 0));
      await tester.pump();

      expect(toastRect(tester, 'Saved').left - rest.left, 30);

      await hand.up();
      await tester.pump();

      expect(toastRect(tester, 'Saved'), rest);

      // Away from the bottom edge it is pinned to, the pull is damped.
      final TestGesture up = await tester.startGesture(tester.getCenter(find.text('Saved')));
      await up.moveBy(const Offset(0, -20));
      await up.moveBy(const Offset(0, -16));
      await tester.pump();

      expect(rest.top - toastRect(tester, 'Saved').top, closeTo(6, 0.001));

      await up.up();
      await settle(tester);

      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('stays where the hand let it go while it fades', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester);

      await raise(tester, actions, saved);
      final Rect rest = toastRect(tester, 'Saved');

      await tester.drag(find.text('Saved'), const Offset(80, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));

      expect(toastRect(tester, 'Saved').left - rest.left, 80);
    });
  });

  group('holding', () {
    testWidgets('holds while a mouse is over the stack, and runs again once it leaves', (
      WidgetTester tester,
    ) async {
      final NebaToastActions actions = await pump(tester);

      await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('Saved'), timeout: Duration(seconds: 1)),
      );

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(find.text('Saved')));
      await tester.pump(const Duration(seconds: 3));

      expect(find.text('Saved'), findsOneWidget);

      await mouse.moveTo(Offset.zero);
      await tester.pump(const Duration(seconds: 1));
      await settle(tester);

      expect(find.text('Saved'), findsNothing);
      await mouse.removePointer();
    });

    testWidgets('holds from a finger on it until a finger goes down elsewhere', (
      WidgetTester tester,
    ) async {
      final NebaToastActions actions = await pump(tester);

      await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('Saved'), timeout: Duration(seconds: 1)),
      );
      await tester.tap(find.text('Saved'));
      await tester.pump(const Duration(seconds: 3));

      expect(find.text('Saved'), findsOneWidget);

      await tester.tapAt(const Offset(10, 10));
      await tester.pump(const Duration(seconds: 1));
      await settle(tester);

      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('holds while the keyboard focus is in the stack', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester);

      await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('Saved'), timeout: Duration(seconds: 1)),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.f6);
      await tester.pump(const Duration(seconds: 3));

      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('holds while the app is not the focused window', (WidgetTester tester) async {
      addTearDown(() => tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed));
      final NebaToastActions actions = await pump(tester);

      await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('Saved'), timeout: Duration(seconds: 1)),
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump(const Duration(seconds: 3));

      expect(find.text('Saved'), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(seconds: 1));
      await settle(tester);

      expect(find.text('Saved'), findsNothing);
    });
  });

  group('the keyboard', () {
    testWidgets('F6 moves the focus to the newest toast and rings it', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester);

      await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('One'), timeout: Duration.zero),
      );
      await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('Two'), timeout: Duration.zero),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.f6);
      await tester.pump();
      await tester.pump();

      expect(toastFocus(tester, 'Two').hasPrimaryFocus, isTrue);
      expect(
        tester
            .widget<NebaFocusRing>(
              find.ancestor(of: find.text('Two'), matching: find.byType(NebaFocusRing)).first,
            )
            .visible,
        isTrue,
      );
    });

    testWidgets('hands the focus to the next toast when the one holding it closes', (
      WidgetTester tester,
    ) async {
      final NebaToastActions actions = await pump(tester);

      await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('One'), timeout: Duration.zero),
      );
      await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('Two'), timeout: Duration.zero),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.f6);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);

      expect(find.text('Two'), findsNothing);
      expect(toastFocus(tester, 'One').hasPrimaryFocus, isTrue);
    });

    testWidgets('gives the focus back to where F6 found it when the last one closes', (
      WidgetTester tester,
    ) async {
      final FocusNode field = FocusNode();
      addTearDown(field.dispose);
      final NebaToastActions actions = await pump(
        tester,
        app: Focus(focusNode: field, child: const SizedBox.expand()),
      );

      field.requestFocus();
      await raise(tester, actions, saved);
      await tester.sendKeyEvent(LogicalKeyboardKey.f6);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);

      expect(field.hasPrimaryFocus, isTrue);
    });
  });

  group('the action', () {
    testWidgets('appears only when it is given a label', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester);

      await raise(tester, actions, saved);

      expect(find.byType(NebaTextMarks), findsNothing);
    });

    testWidgets('calls onAction when it is pressed', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester);
      int pressed = 0;

      await raise(
        tester,
        actions,
        NebaToastOptions(
          title: const Text('Deleted'),
          timeout: Duration.zero,
          actionLabel: const Text('Undo'),
          onAction: () => pressed += 1,
        ),
      );
      await tester.tap(find.text('Undo'));

      expect(pressed, 1);
    });

    testWidgets('is underlined under the pointer and sits on the first line', (
      WidgetTester tester,
    ) async {
      final NebaToastActions actions = await pump(tester);

      await raise(
        tester,
        actions,
        const NebaToastOptions(
          title: Text('Deleted'),
          timeout: Duration.zero,
          actionLabel: Text('Undo'),
        ),
      );

      expect(tester.widget<NebaTextMarks>(find.byType(NebaTextMarks)).underline, isNull);

      // `h-[1lh]`: as tall as the message's first line, and centred on it,
      // inside the sheet's padding and its hairline.
      final Rect slot = tester.getRect(
        find.ancestor(of: find.text('Undo'), matching: find.byType(SizedBox)).first,
      );
      expect(slot.height, 22);
      expect(slot.top, toastRect(tester, 'Deleted').top + 16 + 1);

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(find.text('Undo')));
      await tester.pump();

      expect(
        tester.widget<NebaTextMarks>(find.byType(NebaTextMarks)).underline,
        tokens.roles(NebaColor.primary).onTint,
      );
      await mouse.removePointer();
    });
  });

  group('style', () {
    testWidgets('is an outline sheet in the primary family, lifted to elevation 3', (
      WidgetTester tester,
    ) async {
      final NebaToastActions actions = await pump(tester);

      await raise(tester, actions, saved);
      final NebaSheet sheet = sheetOf(tester, 'Saved');

      expect(sheet.fill, tokens.roles(NebaColor.primary).panelPress);
      expect(sheet.edge, tokens.roles(NebaColor.primary).line);
      expect(sheet.plate, NebaPlate.glass);
      expect(sheet.elevation, 3);
      expect(sheet.blur, isTrue);
    });

    testWidgets('takes its colour from the provider', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester, color: NebaColor.success);

      await raise(tester, actions, saved);

      expect(sheetOf(tester, 'Saved').fill, tokens.roles(NebaColor.success).panelPress);
    });

    testWidgets('lets a single toast override the provider', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(
        tester,
        color: NebaColor.success,
        variant: NebaVariant.outline,
      );

      await raise(
        tester,
        actions,
        const NebaToastOptions(
          title: Text('Failed'),
          color: NebaColor.danger,
          variant: NebaVariant.solid,
          timeout: Duration.zero,
        ),
      );
      final NebaSheet sheet = sheetOf(tester, 'Failed');

      expect(sheet.fill, tokens.roles(NebaColor.danger).fill);
      expect(sheet.edge, isNull);
      expect(sheet.plate, NebaPlate.solid);
    });

    testWidgets('keeps the frosted sheet without its hairline on text', (
      WidgetTester tester,
    ) async {
      final NebaToastActions actions = await pump(tester, variant: NebaVariant.text);

      await raise(tester, actions, saved);
      final NebaSheet sheet = sheetOf(tester, 'Saved');

      expect(sheet.edge, isNull);
      expect(sheet.plate, NebaPlate.glass);
      expect(sheet.blur, isTrue);
      expect(sheet.texture, isTrue);
    });

    testWidgets('draws the severity glyph, or none when asked', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester);

      await raise(
        tester,
        actions,
        const NebaToastOptions(
          title: Text('Saved'),
          color: NebaColor.success,
          timeout: Duration.zero,
        ),
      );

      expect(
        tester.widget<NebaGlyph>(severityGlyph()).parts,
        same(NebaGlyphs.severity(NebaColor.success)),
      );

      actions.close();
      await settle(tester);
      await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('Saved'), showIcon: false, timeout: Duration.zero),
      );

      expect(severityGlyph(), findsNothing);
      expect(closeGlyph(), findsOneWidget);
    });

    testWidgets('writes the title in the tint ink and the detail under it muted', (
      WidgetTester tester,
    ) async {
      final NebaToastActions actions = await pump(tester);

      await raise(
        tester,
        actions,
        const NebaToastOptions(
          title: Text('Deployed'),
          description: Text('production'),
          timeout: Duration.zero,
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      Color inkOf(String text) => tester
          .widget<RichText>(find.descendant(of: find.text(text), matching: find.byType(RichText)))
          .text
          .style!
          .color!;

      expect(inkOf('Deployed'), tokens.roles(NebaColor.primary).onTint);
      expect(inkOf('production'), tokens.mutedFg);
    });
  });

  group('placement', () {
    testWidgets('sits at the bottom end by default, no wider than its width', (
      WidgetTester tester,
    ) async {
      final NebaToastActions actions = await pump(tester);

      await raise(tester, actions, saved);
      final Rect toast = toastRect(tester, 'Saved');

      expect(toast.right, 800 - NebaToastProvider.inset);
      expect(toast.bottom, 600 - NebaToastProvider.inset);
      expect(toast.width, 380);
    });

    testWidgets('pins the stack where it is told to', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester, position: NebaToastPosition.topCenter);

      await raise(tester, actions, saved);
      final Rect toast = toastRect(tester, 'Saved');

      expect(toast.top, NebaToastProvider.inset);
      expect(toast.center.dx, 400);
    });

    testWidgets('puts the end at the start of a right-to-left page', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester, textDirection: TextDirection.rtl);

      await raise(tester, actions, saved);

      expect(toastRect(tester, 'Saved').left, NebaToastProvider.inset);
    });

    testWidgets('fills a window narrower than its width', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester, hostWidth: 320);

      await raise(tester, actions, saved);

      expect(toastRect(tester, 'Saved').width, 320 - 2 * NebaToastProvider.inset);
    });

    testWidgets('keeps out of the safe area and from under the keyboard', (
      WidgetTester tester,
    ) async {
      final NebaToastActions actions = await pump(
        tester,
        padding: const EdgeInsets.only(bottom: 34),
        viewInsets: const EdgeInsets.only(bottom: 200),
      );

      await raise(tester, actions, saved);

      expect(toastRect(tester, 'Saved').bottom, 600 - NebaToastProvider.inset - 34 - 200);
    });

    testWidgets('lets a press through anywhere but on a toast', (WidgetTester tester) async {
      int pressed = 0;
      final NebaToastActions actions = await pump(
        tester,
        app: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => pressed += 1,
          child: const SizedBox.expand(),
        ),
      );

      await raise(tester, actions, saved);
      // In the strip, beside the toast.
      await tester.tapAt(Offset(20, toastRect(tester, 'Saved').center.dy));
      expect(pressed, 1);

      await tester.tapAt(toastRect(tester, 'Saved').center);
      expect(pressed, 1);
    });
  });

  group('motion', () {
    testWidgets('arrives in opacity alone', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester);

      actions.add(saved);
      await tester.pump();
      final Rect start = toastRect(tester, 'Saved');

      expect(opacityOf(tester, 'Saved'), 0);

      await tester.pump(const Duration(milliseconds: 80));

      expect(opacityOf(tester, 'Saved'), inExclusiveRange(0, 1));
      expect(toastRect(tester, 'Saved'), start);

      await tester.pump(const Duration(milliseconds: 80));

      expect(opacityOf(tester, 'Saved'), 1);
    });

    testWidgets('lands at once under reduced motion', (WidgetTester tester) async {
      final NebaToastActions actions = await pump(tester, disableAnimations: true);

      final String id = actions.add(saved);
      await tester.pump();

      expect(opacityOf(tester, 'Saved'), 1);

      actions.close(id);
      await tester.pump();
      await tester.pump();

      expect(find.text('Saved'), findsNothing);
    });
  });

  group('semantics', () {
    testWidgets('reads a toast out politely unless its priority is high', (
      WidgetTester tester,
    ) async {
      final NebaToastActions actions = await pump(tester);

      await raise(tester, actions, saved);
      await raise(
        tester,
        actions,
        const NebaToastOptions(
          title: Text('Failed'),
          priority: NebaToastPriority.high,
          timeout: Duration.zero,
        ),
      );

      SemanticsRole roleOf(String text) => tester
          .widget<NebaLiveRegion>(
            find.ancestor(of: find.text(text), matching: find.byType(NebaLiveRegion)),
          )
          .role;

      expect(roleOf('Saved'), SemanticsRole.status);
      expect(roleOf('Failed'), SemanticsRole.alert);
    });

    testWidgets('reads the title and the description without the action or the ×', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final NebaToastActions actions = await pump(tester);

      await raise(
        tester,
        actions,
        const NebaToastOptions(
          title: Text('Deleted'),
          description: Text('Q3 forecast'),
          actionLabel: Text('Undo'),
          timeout: Duration.zero,
        ),
      );

      expect(tester.getSemantics(find.byType(NebaLiveRegion)).label, 'Deleted\nQ3 forecast');
      expect(find.bySemanticsLabel('Undo'), findsOneWidget);
      expect(find.bySemanticsLabel('Close'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('puts the stack in a region named for it', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final NebaToastActions actions = await pump(tester);

      await raise(tester, actions, saved);
      final SemanticsNode region = tester.getSemantics(find.bySemanticsLabel('Notifications'));

      expect(region.getSemanticsData().role, SemanticsRole.region);
      semantics.dispose();
    });
  });

  group('locale', () {
    tearDown(resetNebaMessages);

    testWidgets("names every toast's × and the region in the language it was given", (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      registerNebaMessages('ko', ko);
      final NebaToastActions actions = await pump(tester, locale: const Locale('ko'));

      await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('저장됨'), timeout: Duration.zero),
      );

      expect(find.bySemanticsLabel('닫기'), findsOneWidget);
      expect(find.bySemanticsLabel('알림'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('takes words of its own over the locale', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      registerNebaMessages('ko', ko);
      final NebaToastActions actions = await pump(
        tester,
        locale: const Locale('ko'),
        closeLabel: 'Dismiss',
        label: 'Updates',
      );

      await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('저장됨'), timeout: Duration.zero),
      );

      expect(find.bySemanticsLabel('Dismiss'), findsOneWidget);
      expect(find.bySemanticsLabel('Updates'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('the provider', () {
    testWidgets('shows the toasts that waited when its limit is raised', (
      WidgetTester tester,
    ) async {
      final NebaToastActions actions = await pump(tester, limit: 1);

      await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('One'), timeout: Duration.zero),
      );
      await raise(
        tester,
        actions,
        const NebaToastOptions(title: Text('Two'), timeout: Duration.zero),
      );

      expect(find.text('One'), findsNothing);

      await pump(tester, limit: 2);
      await tester.pump();

      expect(find.text('One'), findsOneWidget);
    });

    testWidgets('draws its stack over a popup opened before the toast', (
      WidgetTester tester,
    ) async {
      int under = 0;
      final NebaToastActions actions = await pump(
        tester,
        app: NebaPortal(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => under += 1,
            child: const SizedBox.expand(),
          ),
        ),
      );
      await tester.pump();

      await raise(tester, actions, saved);
      await tester.tapAt(toastRect(tester, 'Saved').center);

      expect(under, 0);

      await tester.tapAt(const Offset(20, 20));

      expect(under, 1);
    });
  });
}

/// Raises a toast as it is first built, as a page that finds the network
/// gone does.
class _RaisesOnStart extends StatefulWidget {
  const _RaisesOnStart();

  @override
  State<_RaisesOnStart> createState() => _RaisesOnStartState();
}

class _RaisesOnStartState extends State<_RaisesOnStart> {
  @override
  void initState() {
    super.initState();
    NebaToastProvider.of(
      context,
    ).add(const NebaToastOptions(title: Text('Connection lost'), timeout: Duration.zero));
  }

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
