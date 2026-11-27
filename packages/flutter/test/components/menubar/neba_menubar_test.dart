// NebaMenubar: the suite the React package runs on Menubar, asked the way
// Flutter asks it — the words it lays out and what a screen reader is told,
// where the focus is, and what a press, a key and the pointer do along the
// bar — rather than the elements, the classes and the ARIA it writes.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/menu.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Widget scene(Widget bar, {Widget? after, TextDirection textDirection = TextDirection.ltr}) {
    return host(
      Overlay.wrap(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[bar, ?after]),
          ),
        ),
      ),
      textDirection: textDirection,
    );
  }

  Widget application({
    VoidCallback? onNew,
    NebaOrientation orientation = NebaOrientation.horizontal,
    NebaSize? size,
    NebaColor color = NebaColor.primary,
    bool disabled = false,
    bool modal = true,
    bool loopFocus = true,
  }) {
    return NebaMenubar(
      semanticLabel: 'Application',
      orientation: orientation,
      size: size,
      color: color,
      disabled: disabled,
      modal: modal,
      loopFocus: loopFocus,
      children: <Widget>[
        NebaMenubarMenu(
          label: const Text('File'),
          children: <Widget>[
            NebaMenuItem(onPressed: onNew, child: const Text('New file')),
            const NebaMenuSeparator(),
            const NebaMenuItem(child: Text('Open…')),
          ],
        ),
        const NebaMenubarMenu(
          label: Text('Edit'),
          children: <Widget>[NebaMenuItem(child: Text('Undo'))],
        ),
        const NebaMenubarMenu(
          label: Text('Help'),
          disabled: true,
          children: <Widget>[NebaMenuItem(child: Text('About'))],
        ),
      ],
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  FocusNode node(WidgetTester tester, String label) => Focus.of(tester.element(find.text(label)));

  bool focused(WidgetTester tester, String label) => node(tester, label).hasPrimaryFocus;

  Matcher word(String label, {bool enabled = true, bool expanded = false, bool focused = false}) {
    return matchesSemantics(
      role: SemanticsRole.menuItem,
      label: label,
      hasEnabledState: true,
      isEnabled: enabled,
      isFocusable: enabled,
      hasFocusAction: enabled,
      hasTapAction: enabled,
      hasExpandedState: true,
      isExpanded: expanded,
      isFocused: focused,
    );
  }

  /// The tint a word is drawn on.
  Color? tint(WidgetTester tester, String label) {
    final Finder box = find.ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate(
        (Widget widget) => widget is DecoratedBox && widget.decoration is BoxDecoration,
      ),
    );

    return (tester.widget<DecoratedBox>(box.first).decoration as BoxDecoration).color;
  }

  group('rendering', () {
    testWidgets('is a menu bar of words', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(scene(application()));

      final SemanticsNode bar = tester.getSemantics(
        find.descendant(of: find.byType(NebaMenubar), matching: find.byType(Semantics)).first,
      );
      expect(bar.getSemanticsData().role, SemanticsRole.menuBar);
      expect(bar.getSemanticsData().label, 'Application');
      expect(tester.getSemantics(find.text('File')), word('File'));
      expect(tester.getSemantics(find.text('Edit')), word('Edit'));
      semantics.dispose();
    });

    testWidgets('opens nothing until a word is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(scene(application()));

      expect(find.text('New file'), findsNothing);
    });

    testWidgets('lays the words out in a row, on a ladder one rung below the controls', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(scene(application(size: NebaSize.xl)));

      final Rect file = tester.getRect(
        find.ancestor(of: find.text('File'), matching: find.byType(SizedBox)).first,
      );
      final Rect edit = tester.getRect(
        find.ancestor(of: find.text('Edit'), matching: find.byType(SizedBox)).first,
      );
      expect(file.height, 40);
      expect(edit.height, 40);
      expect(edit.left, greaterThan(file.right));
      expect(edit.top, file.top);
    });

    testWidgets('turns the strip on its side when vertical', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(SizedBox(width: 160, child: application(orientation: NebaOrientation.vertical))),
      );

      final Rect file = tester.getRect(
        find.ancestor(of: find.text('File'), matching: find.byType(SizedBox)).first,
      );
      final Rect edit = tester.getRect(
        find.ancestor(of: find.text('Edit'), matching: find.byType(SizedBox)).first,
      );
      expect(edit.top, greaterThan(file.bottom));
      expect(file.width, 160);
      expect(edit.left, file.left);
    });

    // It opened downward and covered the word below the one pressed.
    testWidgets('opens a menu beside a vertical bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(SizedBox(width: 160, child: application(orientation: NebaOrientation.vertical))),
      );

      await tester.tap(find.text('File'));
      await settle(tester);

      expect(find.text('New file'), findsOneWidget);
      expect(
        tester.getRect(find.byType(NebaMenuSheet)).left,
        greaterThanOrEqualTo(tester.getRect(find.byType(NebaMenubar)).right),
      );
    });
  });

  group('behaviour', () {
    testWidgets('opens the rows behind a word, below it, and marks the word', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(scene(application()));
      await tester.tap(find.text('File'));
      await settle(tester);

      expect(find.text('New file'), findsOneWidget);
      expect(
        tester.getRect(find.byType(NebaMenuSheet)).top,
        greaterThan(tester.getRect(find.text('File')).bottom),
      );
      expect(tester.getSemantics(find.text('File')), word('File', expanded: true));
      expect(tint(tester, 'File'), tokens.roles(NebaColor.primary).softHover);
      expect(
        DefaultTextStyle.of(tester.element(find.text('File'))).style.color,
        tokens.roles(NebaColor.primary).onTint,
      );

      // A second press closes it.
      await tester.tap(find.text('File'));
      await settle(tester);
      expect(find.text('New file'), findsNothing);
      semantics.dispose();
    });

    testWidgets('runs a row and closes', (WidgetTester tester) async {
      int created = 0;

      await tester.pumpWidget(scene(application(onNew: () => created += 1)));
      await tester.tap(find.text('File'));
      await settle(tester);
      await tester.tap(find.text('New file'));
      await settle(tester);

      expect(created, 1);
      expect(find.text('New file'), findsNothing);
    });

    testWidgets('leaves a disabled word unopenable', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(scene(application()));

      expect(tester.getSemantics(find.text('Help')), word('Help', enabled: false));

      await tester.tap(find.text('Help'));
      await settle(tester);
      expect(find.text('About'), findsNothing);
      expect(DefaultTextStyle.of(tester.element(find.text('Help'))).style.color, tokens.disabledFg);
      semantics.dispose();
    });

    testWidgets('walks the open menu along the bar under the pointer', (WidgetTester tester) async {
      await tester.pumpWidget(scene(application()));

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(5, 5));
      addTearDown(mouse.removePointer);

      // Crossing the bar with nothing open opens nothing.
      await mouse.moveTo(tester.getCenter(find.text('Edit')));
      await settle(tester);
      expect(find.text('Undo'), findsNothing);

      await mouse.moveTo(tester.getCenter(find.text('File')));
      await mouse.down(tester.getCenter(find.text('File')));
      await mouse.up();
      await settle(tester);
      expect(find.text('New file'), findsOneWidget);

      // Through the modal barrier, which leaves the bar out.
      await mouse.moveTo(tester.getCenter(find.text('Edit')));
      await settle(tester);
      expect(find.text('Undo'), findsOneWidget);
      expect(find.text('New file'), findsNothing);

      // A disabled word is passed over.
      await mouse.moveTo(tester.getCenter(find.text('Help')));
      await settle(tester);
      expect(find.text('Undo'), findsOneWidget);
      expect(find.text('About'), findsNothing);
    });

    testWidgets('takes the page behind away, but not the bar', (WidgetTester tester) async {
      int pressed = 0;

      await tester.pumpWidget(
        scene(
          application(),
          after: Padding(
            padding: const EdgeInsets.only(top: 200),
            child: NebaButton(onPressed: () => pressed += 1, child: const Text('Behind')),
          ),
        ),
      );
      await tester.tap(find.text('File'));
      await settle(tester);

      // Another word takes the press, and opens its own menu.
      await tester.tap(find.text('Edit'));
      await settle(tester);
      expect(find.text('Undo'), findsOneWidget);
      expect(find.text('New file'), findsNothing);

      await tester.tap(find.text('Behind'), warnIfMissed: false);
      await settle(tester);
      expect(pressed, 0);
      expect(find.text('Undo'), findsNothing);
    });

    testWidgets('leaves the page pressable when it is not modal', (WidgetTester tester) async {
      int pressed = 0;

      await tester.pumpWidget(
        scene(
          application(modal: false),
          after: Padding(
            padding: const EdgeInsets.only(top: 200),
            child: NebaButton(onPressed: () => pressed += 1, child: const Text('Behind')),
          ),
        ),
      );
      await tester.tap(find.text('File'));
      await settle(tester);

      await tester.tap(find.text('Behind'));
      await settle(tester);
      expect(pressed, 1);
      expect(find.text('New file'), findsNothing);
    });
  });

  group('the keyboard', () {
    testWidgets('is one stop in the focus order, walked with the arrow keys', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          application(),
          after: NebaButton(onPressed: () {}, child: const Text('After')),
        ),
      );

      expect(node(tester, 'File').skipTraversal, isFalse);
      expect(node(tester, 'Edit').skipTraversal, isTrue);

      node(tester, 'File').requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focused(tester, 'Edit'), isTrue);
      expect(node(tester, 'Edit').skipTraversal, isFalse);
      expect(node(tester, 'File').skipTraversal, isTrue);

      // Help is disabled, so the arrow wraps past it to the start.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focused(tester, 'File'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(focused(tester, 'Edit'), isTrue);

      // Letters move to the word that starts with them.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.pump();
      expect(focused(tester, 'File'), isTrue);

      // Tab leaves the bar from whichever word holds the stop.
      expect(node(tester, 'File').nextFocus(), isTrue);
      await tester.pump();
      expect(focused(tester, 'After'), isTrue);
    });

    testWidgets('opens a menu at its first row on Down and Enter, and its last on Up', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(scene(application()));
      node(tester, 'File').requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await settle(tester);
      expect(focused(tester, 'New file'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);
      expect(find.text('New file'), findsNothing);
      expect(focused(tester, 'File'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await settle(tester);
      expect(focused(tester, 'Open…'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);
      expect(focused(tester, 'New file'), isTrue);
    });

    testWidgets('walks from one open menu to the next with the arrows across it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(scene(application()));
      node(tester, 'File').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await settle(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await settle(tester);
      expect(find.text('New file'), findsNothing);
      expect(focused(tester, 'Undo'), isTrue);

      // Past the disabled Help, round to File.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await settle(tester);
      expect(focused(tester, 'New file'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await settle(tester);
      expect(focused(tester, 'Undo'), isTrue);
    });

    testWidgets('opens beside a vertical bar on the arrow towards it, and closes on the one back', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(SizedBox(width: 160, child: application(orientation: NebaOrientation.vertical))),
      );
      node(tester, 'File').requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focused(tester, 'Edit'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await settle(tester);
      expect(focused(tester, 'Undo'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await settle(tester);
      expect(find.text('Undo'), findsNothing);
      expect(focused(tester, 'Edit'), isTrue);
    });

    testWidgets('closes on Tab and moves on past the bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          application(),
          after: NebaButton(onPressed: () {}, child: const Text('After')),
        ),
      );
      node(tester, 'File').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await settle(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await settle(tester);

      expect(find.text('New file'), findsNothing);
      expect(focused(tester, 'After'), isTrue);
    });
  });

  group('shared props', () {
    testWidgets('sets the size once for every menu on the bar', (WidgetTester tester) async {
      await tester.pumpWidget(scene(application(size: NebaSize.xl)));
      await tester.tap(find.text('File'));
      await settle(tester);

      expect(
        DefaultTextStyle.of(tester.element(find.text('New file'))).style.fontSize,
        NebaScale.controlText[NebaSize.xl],
      );
      expect(
        DefaultTextStyle.of(tester.element(find.text('File'))).style.fontSize,
        NebaScale.controlText[NebaSize.xl],
      );
    });

    testWidgets('draws the open word and the rows in its colour family', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(scene(application(color: NebaColor.secondary)));
      await tester.tap(find.text('File'));
      await settle(tester);

      expect(tint(tester, 'File'), tokens.roles(NebaColor.secondary).softHover);
      expect(tester.widget<NebaMenuSheet>(find.byType(NebaMenuSheet)).children, isNotEmpty);
    });

    testWidgets('disables every menu on the bar at once', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(scene(application(disabled: true)));

      expect(tester.getSemantics(find.text('File')), word('File', enabled: false));
      await tester.tap(find.text('File'));
      await settle(tester);
      expect(find.text('New file'), findsNothing);
      semantics.dispose();
    });
  });

  testWidgets('fails with a message when a menu is used outside a bar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(host(const NebaMenubarMenu(label: Text('Lost'))));

    expect(tester.takeException(), isA<FlutterError>());
  });
}
