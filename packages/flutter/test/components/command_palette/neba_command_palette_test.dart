// NebaCommandPalette: the suite the React package runs on CommandPalette,
// asked the way Flutter asks it — the dialog, the field and the rows it
// builds, what typing, the arrow keys, Enter and a press do, and the key it
// binds on the whole app — rather than the roles, the classes and the chunk
// it writes.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  const List<NebaCommandItem> items = <NebaCommandItem>[
    NebaCommandItem(value: 'home', label: 'Go to overview', group: 'Navigate', shortcut: 'G H'),
    NebaCommandItem(value: 'deploys', label: 'Go to deployments', group: 'Navigate'),
    NebaCommandItem(
      value: 'deploy',
      label: 'Deploy production',
      group: 'Actions',
      keywords: <String>['ship', 'release'],
    ),
    NebaCommandItem(value: 'rollback', label: 'Roll back', group: 'Actions', disabled: true),
  ];

  Future<void> pump(WidgetTester tester, Widget palette) async {
    await tester.pumpWidget(host(Overlay.wrap(child: palette)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(EditableText), text);
    await tester.pump();
  }

  Future<void> press(WidgetTester tester, LogicalKeyboardKey key, {LogicalKeyboardKey? holding}) {
    return () async {
      if (holding != null) {
        await tester.sendKeyDownEvent(holding);
      }

      await tester.sendKeyEvent(key);

      if (holding != null) {
        await tester.sendKeyUpEvent(holding);
      }

      await settle(tester);
    }();
  }

  bool isOpen(WidgetTester tester) => find.byType(EditableText).evaluate().isNotEmpty;

  group('rendering', () {
    testWidgets('builds nothing until it is open', (WidgetTester tester) async {
      await pump(tester, const NebaCommandPalette(items: items, shortcut: null));

      expect(isOpen(tester), isFalse);
      expect(find.text('Go to overview'), findsNothing);
    });

    testWidgets('builds a named dialog with a field and every command', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaCommandPalette(items: items, shortcut: null, defaultOpen: true));

      final SemanticsData dialog = tester
          .getSemantics(find.bySemanticsLabel('Command palette'))
          .getSemanticsData();

      expect(dialog.role, SemanticsRole.dialog);
      expect(find.byType(EditableText), findsOneWidget);
      expect(find.text('Go to overview'), findsOneWidget);
      expect(find.text('Deploy production'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('puts the focus in the field as it opens', (WidgetTester tester) async {
      await pump(tester, const NebaCommandPalette(items: items, shortcut: null, defaultOpen: true));

      expect(tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus, isTrue);
    });

    testWidgets('draws a heading each time the group changes', (WidgetTester tester) async {
      await pump(tester, const NebaCommandPalette(items: items, shortcut: null, defaultOpen: true));

      expect(find.text('Navigate'), findsOneWidget);
      expect(find.text('Actions'), findsOneWidget);
      expect(
        tester.getRect(find.text('Actions')).top,
        greaterThan(tester.getRect(find.text('Go to deployments')).bottom),
      );
    });

    testWidgets('puts each group of rows in a group named by its heading', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaCommandPalette(items: items, shortcut: null, defaultOpen: true));

      final SemanticsNode navigate = tester.getSemantics(find.bySemanticsLabel('Navigate'));
      SemanticsNode? up = tester.getSemantics(find.text('Go to deployments'));

      while (up != null && up != navigate) {
        up = up.parent;
      }

      expect(up, navigate);
      expect(find.bySemanticsLabel('Actions'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('draws the keystroke a command already has', (WidgetTester tester) async {
      await pump(tester, const NebaCommandPalette(items: items, shortcut: null, defaultOpen: true));

      expect(tester.widget<NebaShortcut>(find.byType(NebaShortcut)).keys, 'G H');
    });

    testWidgets('takes a placeholder and an empty line of its own', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCommandPalette(
          items: <NebaCommandItem>[],
          shortcut: null,
          defaultOpen: true,
          placeholder: 'What now?',
          emptyMessage: Text('Nothing to run'),
        ),
      );

      expect(find.text('What now?'), findsOneWidget);
      expect(find.text('Nothing to run'), findsOneWidget);
    });

    testWidgets('caps the sheet at the width its size gives it, or its own', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaCommandPalette(items: items, shortcut: null, defaultOpen: true));

      expect(tester.getSize(find.byType(NebaSheet).first).width, 576);

      await pump(
        tester,
        const NebaCommandPalette(items: items, shortcut: null, defaultOpen: true, width: 400),
      );

      expect(tester.getSize(find.byType(NebaSheet).first).width, 400);
    });
  });

  group('searching', () {
    testWidgets('filters on the label', (WidgetTester tester) async {
      await pump(tester, const NebaCommandPalette(items: items, shortcut: null, defaultOpen: true));
      await type(tester, 'overview');

      expect(find.text('Go to overview'), findsOneWidget);
      expect(find.text('Deploy production'), findsNothing);
    });

    testWidgets('filters on keywords nobody can see', (WidgetTester tester) async {
      await pump(tester, const NebaCommandPalette(items: items, shortcut: null, defaultOpen: true));
      await type(tester, 'ship');

      expect(find.text('Deploy production'), findsOneWidget);
      expect(find.text('Go to overview'), findsNothing);
    });

    testWidgets('ignores case and accents', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCommandPalette(
          items: <NebaCommandItem>[
            NebaCommandItem(value: 'cafe', label: 'Café settings'),
            ...items,
          ],
          shortcut: null,
          defaultOpen: true,
        ),
      );
      await type(tester, 'CAFE');

      expect(find.text('Café settings'), findsOneWidget);
      expect(find.text('Deploy production'), findsNothing);
    });

    testWidgets('says so when nothing matched', (WidgetTester tester) async {
      await pump(tester, const NebaCommandPalette(items: items, shortcut: null, defaultOpen: true));
      await type(tester, 'zzzz');

      expect(find.text('No commands found'), findsOneWidget);
    });

    testWidgets('starts empty again after a command ran and closed it', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaCommandPalette(items: items, shortcut: 'Alt+P', defaultOpen: true),
      );
      await type(tester, 'overview');
      await press(tester, LogicalKeyboardKey.arrowDown);
      await press(tester, LogicalKeyboardKey.enter);

      expect(isOpen(tester), isFalse);

      await press(tester, LogicalKeyboardKey.keyP, holding: LogicalKeyboardKey.altLeft);

      expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, isEmpty);
      expect(find.text('Deploy production'), findsOneWidget);
    });

    testWidgets('closes on Escape from the field, and starts empty again', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaCommandPalette(items: items, shortcut: 'Alt+P', defaultOpen: true),
      );
      await type(tester, 'overview');
      await press(tester, LogicalKeyboardKey.escape);

      expect(isOpen(tester), isFalse);

      await press(tester, LogicalKeyboardKey.keyP, holding: LogicalKeyboardKey.altLeft);

      expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, isEmpty);
      expect(find.text('Deploy production'), findsOneWidget);
    });

    testWidgets('starts empty again after a controlled open was turned off', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaCommandPalette(items: items, shortcut: null, open: true));
      await type(tester, 'overview');

      await pump(tester, const NebaCommandPalette(items: items, shortcut: null, open: false));
      expect(isOpen(tester), isFalse);

      await pump(tester, const NebaCommandPalette(items: items, shortcut: null, open: true));

      expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, isEmpty);
      expect(find.text('Deploy production'), findsOneWidget);
    });
  });

  group('running a command', () {
    testWidgets('runs the command and closes', (WidgetTester tester) async {
      int own = 0;
      NebaCommandItem? selected;
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaCommandPalette(
          items: <NebaCommandItem>[
            NebaCommandItem(
              value: 'home',
              label: 'Go to overview',
              group: 'Navigate',
              onSelect: () => own++,
            ),
            ...items.skip(1),
          ],
          shortcut: null,
          defaultOpen: true,
          onSelect: (NebaCommandItem item) => selected = item,
          onOpenChange: changes.add,
        ),
      );

      await press(tester, LogicalKeyboardKey.arrowDown);
      await press(tester, LogicalKeyboardKey.enter);

      expect(own, 1);
      expect(selected?.value, 'home');
      expect(changes, <bool>[false]);
      expect(isOpen(tester), isFalse);
    });

    testWidgets('walks the highlight from one group into the next', (WidgetTester tester) async {
      NebaCommandItem? selected;

      await pump(
        tester,
        NebaCommandPalette(
          items: items,
          shortcut: null,
          defaultOpen: true,
          onSelect: (NebaCommandItem item) => selected = item,
        ),
      );

      for (int step = 0; step < 3; step++) {
        await press(tester, LogicalKeyboardKey.arrowDown);
      }

      await press(tester, LogicalKeyboardKey.enter);

      expect(selected?.value, 'deploy');
    });

    testWidgets('passes over a disabled one on the way round', (WidgetTester tester) async {
      NebaCommandItem? selected;

      await pump(
        tester,
        NebaCommandPalette(
          items: items,
          shortcut: null,
          defaultOpen: true,
          onSelect: (NebaCommandItem item) => selected = item,
        ),
      );

      // Up from nothing lands on the last that runs, not on the disabled one.
      await press(tester, LogicalKeyboardKey.arrowUp);
      await press(tester, LogicalKeyboardKey.enter);

      expect(selected?.value, 'deploy');
    });

    testWidgets('runs a command pressed with the pointer', (WidgetTester tester) async {
      NebaCommandItem? selected;

      await pump(
        tester,
        NebaCommandPalette(
          items: items,
          shortcut: null,
          defaultOpen: true,
          onSelect: (NebaCommandItem item) => selected = item,
        ),
      );

      await tester.tap(find.text('Go to deployments'));
      await settle(tester);

      expect(selected?.value, 'deploys');
      expect(isOpen(tester), isFalse);
    });

    testWidgets('never runs a disabled one', (WidgetTester tester) async {
      NebaCommandItem? selected;

      await pump(
        tester,
        NebaCommandPalette(
          items: items,
          shortcut: null,
          defaultOpen: true,
          onSelect: (NebaCommandItem item) => selected = item,
        ),
      );

      await tester.tap(find.text('Roll back'));
      await settle(tester);

      expect(selected, isNull);
      expect(isOpen(tester), isTrue);
    });

    testWidgets("runs the highlighted command from a touch keyboard's action key", (
      WidgetTester tester,
    ) async {
      NebaCommandItem? selected;

      await pump(
        tester,
        NebaCommandPalette(
          items: items,
          shortcut: null,
          defaultOpen: true,
          onSelect: (NebaCommandItem item) => selected = item,
        ),
      );

      await tester.showKeyboard(find.byType(EditableText));
      await tester.testTextInput.receiveAction(TextInputAction.go);
      await settle(tester);

      // Nothing highlighted: nothing runs, and the field keeps the focus.
      expect(selected, isNull);
      expect(tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus, isTrue);

      await press(tester, LogicalKeyboardKey.arrowDown);
      await tester.testTextInput.receiveAction(TextInputAction.go);
      await settle(tester);

      expect(selected?.value, 'home');
    });

    testWidgets('runs the row the pointer is on with Enter', (WidgetTester tester) async {
      NebaCommandItem? selected;

      await pump(
        tester,
        NebaCommandPalette(
          items: items,
          shortcut: null,
          defaultOpen: true,
          onSelect: (NebaCommandItem item) => selected = item,
        ),
      );

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('Deploy production')));
      await tester.pump();
      await press(tester, LogicalKeyboardKey.enter);

      expect(selected?.value, 'deploy');
    });
  });

  group('the shortcut', () {
    testWidgets('opens on the keystroke it was given', (WidgetTester tester) async {
      await pump(tester, const NebaCommandPalette(items: items, shortcut: 'Alt+P'));

      expect(isOpen(tester), isFalse);

      await press(tester, LogicalKeyboardKey.keyP, holding: LogicalKeyboardKey.altLeft);

      expect(isOpen(tester), isTrue);
    });

    testWidgets('opens on Control+K by default off a Mac', (WidgetTester tester) async {
      await pump(tester, const NebaCommandPalette(items: items));

      await press(tester, LogicalKeyboardKey.keyK, holding: LogicalKeyboardKey.metaLeft);
      expect(isOpen(tester), isFalse);

      await press(tester, LogicalKeyboardKey.keyK, holding: LogicalKeyboardKey.controlLeft);
      expect(isOpen(tester), isTrue);
    });

    testWidgets('opens on Command+K by default on a Mac', (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      try {
        await pump(tester, const NebaCommandPalette(items: items));
        await press(tester, LogicalKeyboardKey.keyK, holding: LogicalKeyboardKey.metaLeft);

        expect(isOpen(tester), isTrue);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    for (final String shortcut in <String>['Ctrl+K', 'Control+K', 'ctrl + k']) {
      testWidgets('binds $shortcut, which NebaShortcut already draws', (WidgetTester tester) async {
        await pump(tester, NebaCommandPalette(items: items, shortcut: shortcut));
        await press(tester, LogicalKeyboardKey.keyK, holding: LogicalKeyboardKey.controlLeft);

        expect(isOpen(tester), isTrue);
      });
    }

    testWidgets('binds a key named the short way', (WidgetTester tester) async {
      await pump(tester, const NebaCommandPalette(items: items, shortcut: 'Alt+Esc'));
      await press(tester, LogicalKeyboardKey.escape, holding: LogicalKeyboardKey.altLeft);

      expect(isOpen(tester), isTrue);
    });

    testWidgets('matches its modifiers exactly', (WidgetTester tester) async {
      await pump(tester, const NebaCommandPalette(items: items, shortcut: 'Alt+P'));
      await press(tester, LogicalKeyboardKey.keyP);

      expect(isOpen(tester), isFalse);
    });

    testWidgets('asks to open only while it is shut', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaCommandPalette(items: items, shortcut: 'Alt+P', open: true, onOpenChange: changes.add),
      );
      await press(tester, LogicalKeyboardKey.keyP, holding: LogicalKeyboardKey.altLeft);

      expect(changes, isEmpty);
    });

    testWidgets('binds its key once however often the page around it builds', (
      WidgetTester tester,
    ) async {
      int opens = 0;

      for (int tick = 0; tick < 4; tick++) {
        await pump(
          tester,
          NebaCommandPalette(
            items: items,
            shortcut: 'Alt+P',
            open: false,
            onOpenChange: (bool open) => opens++,
          ),
        );
      }

      await press(tester, LogicalKeyboardKey.keyP, holding: LogicalKeyboardKey.altLeft);

      expect(opens, 1);
    });

    testWidgets('binds nothing when it is turned off, and lets go when it leaves', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaCommandPalette(items: items, shortcut: null));
      await press(tester, LogicalKeyboardKey.keyK, holding: LogicalKeyboardKey.controlLeft);

      expect(isOpen(tester), isFalse);

      await pump(tester, const NebaCommandPalette(items: items));
      await tester.pumpWidget(host(const SizedBox()));

      // Pressed with nothing left to open: no error, and nothing built.
      await press(tester, LogicalKeyboardKey.keyK, holding: LogicalKeyboardKey.controlLeft);

      expect(isOpen(tester), isFalse);
    });
  });
}
