// NebaOverlay: the suite the React package runs on Overlay, asked the way
// Flutter asks it — what is built and where, what the page behind is dimmed
// with, which ways out it takes and the semantics it builds — rather than the
// elements and the classes it writes.

import 'dart:ui' as ui;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/color.dart';
import 'package:neba/src/internal/modal.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  /// [child] in an 800 × 600 window with an overlay to open into, and
  /// [padding] as the screen's insets.
  Widget scene(Widget child, {EdgeInsets padding = EdgeInsets.zero}) {
    return MediaQuery(
      data: MediaQueryData(size: const Size(800, 600), padding: padding),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Overlay.wrap(
          child: Align(alignment: Alignment.topLeft, child: child),
        ),
      ),
    );
  }

  /// The overlay's dialog node: the scope around [inside].
  SemanticsNode dialogOf(WidgetTester tester, Finder inside) {
    return tester.getSemantics(find.ancestor(of: inside, matching: find.byType(FocusScope)).first);
  }

  /// The colours painted behind what is on the overlay.
  Iterable<Color> paintedBehind(WidgetTester tester) {
    return tester.widgetList<ColoredBox>(find.byType(ColoredBox)).map((ColoredBox box) {
      return box.color;
    });
  }

  group('rendering', () {
    testWidgets('builds nothing while closed', (WidgetTester tester) async {
      await tester.pumpWidget(scene(const NebaOverlay(child: Text('Working…'))));

      expect(find.text('Working…'), findsNothing);
    });

    testWidgets('builds what is on it while open', (WidgetTester tester) async {
      await tester.pumpWidget(scene(const NebaOverlay(open: true, child: Text('Working…'))));
      await tester.pumpAndSettle();

      expect(find.text('Working…'), findsOneWidget);
    });

    testWidgets('opens from defaultOpen', (WidgetTester tester) async {
      await tester.pumpWidget(scene(const NebaOverlay(defaultOpen: true, child: Text('Working…'))));
      await tester.pumpAndSettle();

      expect(find.text('Working…'), findsOneWidget);
    });

    testWidgets('follows a changed open', (WidgetTester tester) async {
      await tester.pumpWidget(scene(const NebaOverlay(open: false, child: Text('Working…'))));
      await tester.pumpWidget(scene(const NebaOverlay(open: true, child: Text('Working…'))));
      await tester.pumpAndSettle();

      expect(find.text('Working…'), findsOneWidget);

      await tester.pumpWidget(scene(const NebaOverlay(open: false, child: Text('Working…'))));
      await tester.pumpAndSettle();

      expect(find.text('Working…'), findsNothing);
    });

    testWidgets('is a dialog named by its label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(const NebaOverlay(open: true, label: 'Publishing', child: Text('Working…'))),
      );
      await tester.pumpAndSettle();

      final SemanticsNode dialog = dialogOf(tester, find.text('Working…'));

      expect(dialog.getSemanticsData().role, SemanticsRole.dialog);
      expect(dialog, matchesSemantics(label: 'Publishing', scopesRoute: true, namesRoute: true));
      semantics.dispose();
    });

    testWidgets('names itself even with nothing readable on it', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(const NebaOverlay(open: true, child: SizedBox(key: Key('spinner')))),
      );
      await tester.pumpAndSettle();

      expect(dialogOf(tester, find.byKey(const Key('spinner'))).label, 'Loading');
      semantics.dispose();
    });

    testWidgets('names itself in the language it was given, or in words of its own', (
      WidgetTester tester,
    ) async {
      registerNebaMessages('ko', ko);
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          const NebaOverlay(
            open: true,
            locale: Locale('ko'),
            child: SizedBox(key: Key('a')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(dialogOf(tester, find.byKey(const Key('a'))).label, '불러오는 중');

      await tester.pumpWidget(
        scene(
          const NebaOverlay(
            open: true,
            locale: Locale('ko'),
            label: 'Publishing',
            child: SizedBox(key: Key('a')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(dialogOf(tester, find.byKey(const Key('a'))).label, 'Publishing');
      semantics.dispose();
    });

    testWidgets('arrives in opacity alone', (WidgetTester tester) async {
      await tester.pumpWidget(scene(const NebaOverlay(open: false, child: Text('Working…'))));
      await tester.pumpWidget(scene(const NebaOverlay(open: true, child: Text('Working…'))));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));

      final Rect midway = tester.getRect(find.text('Working…'));
      final FadeTransition fade = tester.widget<FadeTransition>(
        find.ancestor(of: find.text('Working…'), matching: find.byType(FadeTransition)).first,
      );

      expect(fade.opacity.value, greaterThan(0));
      expect(fade.opacity.value, lessThan(1));

      await tester.pumpAndSettle();

      expect(tester.getRect(find.text('Working…')), midway);
    });
  });

  group('dismissal', () {
    testWidgets('refuses Escape and a press outside by default', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await tester.pumpWidget(
        scene(NebaOverlay(open: true, onOpenChange: changes.add, child: const Text('Working…'))),
      );
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(changes, isEmpty);
      expect(find.text('Working…'), findsOneWidget);
    });

    testWidgets('closes on Escape and a press outside when dismissible', (
      WidgetTester tester,
    ) async {
      final List<bool> changes = <bool>[];

      await tester.pumpWidget(
        scene(
          NebaOverlay(
            defaultOpen: true,
            dismissible: true,
            onOpenChange: changes.add,
            child: const Text('Working…'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(changes, <bool>[false]);
      expect(find.text('Working…'), findsNothing);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        scene(
          NebaOverlay(
            defaultOpen: true,
            dismissible: true,
            onOpenChange: changes.add,
            child: const Text('Working…'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(changes, <bool>[false, false]);
      expect(find.text('Working…'), findsNothing);
    });

    testWidgets('stays up on a press on what is on it', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(const NebaOverlay(defaultOpen: true, dismissible: true, child: Text('Working…'))),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Working…'));
      await tester.pumpAndSettle();

      expect(find.text('Working…'), findsOneWidget);
    });

    testWidgets('holds the focus while it is up and gives it back', (WidgetTester tester) async {
      final FocusNode page = FocusNode(debugLabel: 'page');
      addTearDown(page.dispose);

      Widget build(bool open) {
        return scene(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              NebaButton(focusNode: page, onPressed: () {}, child: const Text('Publish')),
              NebaOverlay(
                open: open,
                child: NebaButton(onPressed: () {}, child: const Text('Let me out')),
              ),
            ],
          ),
        );
      }

      await tester.pumpWidget(build(false));
      page.requestFocus();
      await tester.pump();
      await tester.pumpWidget(build(true));
      await tester.pumpAndSettle();

      expect(page.hasFocus, isFalse);
      expect(
        find
            .ancestor(
              of: find.byElementPredicate(
                (Element element) => element == FocusManager.instance.primaryFocus!.context,
              ),
              matching: find.byWidgetPredicate(
                (Widget widget) => widget is NebaButton && widget.onPressed != null,
              ),
            )
            .evaluate()
            .isNotEmpty,
        isTrue,
      );

      await tester.pumpWidget(build(false));
      await tester.pumpAndSettle();

      expect(page.hasFocus, isTrue);
    });
  });

  group('the page behind', () {
    Widget page(NebaModal modal, NebaOverlayTone tone, VoidCallback onPressed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          NebaButton(onPressed: onPressed, child: const Text('Page')),
          NebaOverlay(open: true, modal: modal, tone: tone, child: const Text('Working…')),
        ],
      );
    }

    testWidgets('takes every press, even when it draws nothing', (WidgetTester tester) async {
      int pressed = 0;

      await tester.pumpWidget(scene(page(NebaModal.on, NebaOverlayTone.clear, () => pressed++)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Page'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(pressed, 0);
    });

    testWidgets('lets the press through when it traps the focus only', (WidgetTester tester) async {
      int pressed = 0;

      await tester.pumpWidget(
        scene(page(NebaModal.trapFocus, NebaOverlayTone.clear, () => pressed++)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Page'));
      await tester.pumpAndSettle();

      expect(pressed, 1);
    });
  });

  group('style', () {
    testWidgets('dims with the dialog scrim by default', (WidgetTester tester) async {
      await tester.pumpWidget(scene(const NebaOverlay(open: true, child: Text('Working…'))));
      await tester.pumpAndSettle();

      final BackdropFilter blur = tester.widget<BackdropFilter>(find.byType(BackdropFilter));

      expect(paintedBehind(tester), contains(tokens.scrim));
      expect(blur.filter, ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2));
    });

    testWidgets('frosts the page with a lighter dim over a wide blur', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(const NebaOverlay(open: true, tone: NebaOverlayTone.blur, child: Text('Working…'))),
      );
      await tester.pumpAndSettle();

      expect(paintedBehind(tester), contains(mixOklab(tokens.scrim, 0.55, transparent)));
      expect(
        tester.widget<NebaModalLayer>(find.byType(NebaModalLayer)).scrim,
        NebaScrim(color: mixOklab(tokens.scrim, 0.55, transparent), blurSigma: 14, saturation: 1.4),
      );
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('covers the page with its surface when solid', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(const NebaOverlay(open: true, tone: NebaOverlayTone.solid, child: Text('Working…'))),
      );
      await tester.pumpAndSettle();

      expect(paintedBehind(tester), contains(tokens.surface));
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('draws nothing at all when clear', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(const NebaOverlay(open: true, tone: NebaOverlayTone.clear, child: Text('Working…'))),
      );
      await tester.pumpAndSettle();

      expect(paintedBehind(tester), isEmpty);
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('sits in the middle, at the top or at the foot, inside its room', (
      WidgetTester tester,
    ) async {
      Future<Rect> placed(NebaAlign align, NebaSize size) async {
        await tester.pumpWidget(
          scene(
            NebaOverlay(
              open: true,
              align: align,
              size: size,
              child: const SizedBox(key: Key('content'), width: 100, height: 40),
            ),
          ),
        );
        await tester.pumpAndSettle();

        return tester.getRect(find.byKey(const Key('content')));
      }

      expect(await placed(NebaAlign.center, NebaSize.md), const Rect.fromLTWH(350, 280, 100, 40));
      expect(await placed(NebaAlign.start, NebaSize.md), const Rect.fromLTWH(350, 24, 100, 40));
      expect(await placed(NebaAlign.end, NebaSize.xl), const Rect.fromLTWH(350, 520, 100, 40));
    });

    testWidgets('keeps what is on it clear of the system insets', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaOverlay(
            open: true,
            align: NebaAlign.start,
            child: SizedBox(key: Key('content'), width: 100, height: 40),
          ),
          padding: const EdgeInsets.only(top: 44),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(find.byKey(const Key('content'))).top, 44 + 24);
    });

    testWidgets('takes its room from NebaProvider', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaProvider(
            defaults: NebaDefaults(size: NebaSize.xs),
            child: NebaOverlay(
              open: true,
              align: NebaAlign.start,
              child: SizedBox(key: Key('content'), width: 100, height: 40),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(find.byKey(const Key('content'))).top, 12);
    });
  });
}
