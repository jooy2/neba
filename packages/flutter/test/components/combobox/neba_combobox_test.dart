// NebaCombobox: the suite the React package runs on Combobox, asked the way
// Flutter asks it — the shell, the list and the chips it lays out, the
// semantics it builds, and what typing, a press and a key do — rather than
// the elements, the classes and the ARIA it writes.

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/listbox.dart';
import 'package:neba/src/internal/notch.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);
  final NebaColorRoles danger = tokens.roles(NebaColor.danger);

  const List<NebaComboboxOption<String>> frameworks = <NebaComboboxOption<String>>[
    NebaComboboxOption<String>(value: 'react', label: 'React'),
    NebaComboboxOption<String>(value: 'vue', label: 'Vue'),
    NebaComboboxOption<String>(value: 'svelte', label: 'Svelte'),
    NebaComboboxOption<String>(value: 'ember', label: 'Ember', disabled: true),
  ];

  Future<void> pump(WidgetTester tester, Widget combobox, {NebaDefaults? defaults, Widget? after}) {
    final Widget placed = Overlay.wrap(
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[combobox, ?after]),
      ),
    );

    return tester.pumpWidget(
      host(defaults == null ? placed : NebaProvider(defaults: defaults, child: placed)),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Finder shellSheet() =>
      find.descendant(of: find.byType(NebaFieldShell), matching: find.byType(NebaSheet)).first;

  NebaSheet shellOf(WidgetTester tester) => tester.widget<NebaSheet>(shellSheet());

  // The chips in the field, not the copies it is measured with.
  Finder chips() =>
      find.descendant(of: find.byType(NebaFieldShell), matching: find.byType(NebaChip));

  Finder listSheet() =>
      find.descendant(of: find.byType(NebaListSheet), matching: find.byType(NebaSheet));

  Finder row(String text) =>
      find.ancestor(of: find.text(text), matching: find.byType(NebaListRow)).first;

  NebaListRow rowOf(WidgetTester tester, String text) => tester.widget<NebaListRow>(row(text));

  List<String> rows(WidgetTester tester) {
    return tester
        .widgetList<NebaListRow>(find.byType(NebaListRow))
        .map((NebaListRow row) => row.semanticLabel!)
        .toList();
  }

  String textOf(WidgetTester tester) {
    return tester.widget<EditableText>(find.byType(EditableText)).controller.text;
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.tap(find.byType(EditableText), kind: PointerDeviceKind.mouse);
    await tester.pump();
    await tester.enterText(find.byType(EditableText), text);
    await settle(tester);
  }

  Future<void> focus(WidgetTester tester) async {
    tester.widget<EditableText>(find.byType(EditableText)).focusNode.requestFocus();
    await tester.pump();
    await tester.pump();
  }

  group('rendering', () {
    testWidgets('is a text field named by its label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaCombobox<String>(items: frameworks, label: Text('Framework')));

      expect(
        tester.getSemantics(find.byType(NebaFieldWidth)),
        matchesSemantics(
          label: 'Framework',
          isTextField: true,
          isFocusable: true,
          isEnabled: true,
          hasEnabledState: true,
          hasExpandedState: true,
          hasTapAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('is named by semanticLabel when it has no label of its own', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaCombobox<String>(items: frameworks, semanticLabel: 'Framework'));

      expect(
        tester.getSemantics(find.byType(NebaFieldWidth)).getSemanticsData().label,
        'Framework',
      );
      semantics.dispose();
    });

    testWidgets('shows the placeholder while nothing is typed', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCombobox<String>(items: frameworks, placeholder: 'Search frameworks'),
      );

      expect(find.text('Search frameworks'), findsOneWidget);
    });

    testWidgets("shows the chosen option's label rather than its value", (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaCombobox<String>(items: frameworks, defaultValue: 'vue'));

      expect(textOf(tester), 'Vue');
    });

    testWidgets('falls back to the value when an option has no label', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCombobox<int>(
          items: <NebaComboboxOption<int>>[NebaComboboxOption<int>(value: 7)],
          defaultValue: 7,
        ),
      );

      expect(textOf(tester), '7');
    });

    testWidgets('renders the description and reads it after the name', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaCombobox<String>(
          items: frameworks,
          label: Text('Framework'),
          description: Text('Pick the one you know.'),
        ),
      );

      expect(find.text('Pick the one you know.'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(NebaFieldWidth)).getSemanticsData().hint,
        'Pick the one you know.',
      );
      semantics.dispose();
    });
  });

  group('choosing', () {
    testWidgets('opens the list on a press and chooses an option', (WidgetTester tester) async {
      final List<String?> chosen = <String?>[];

      await pump(
        tester,
        NebaCombobox<String>(
          items: frameworks,
          label: const Text('Framework'),
          onValueChange: chosen.add,
        ),
      );

      await tester.tap(find.byType(EditableText), kind: PointerDeviceKind.mouse);
      await settle(tester);
      expect(find.byType(NebaListSheet), findsOneWidget);

      await tester.tap(row('Vue'), kind: PointerDeviceKind.mouse);
      await settle(tester);

      expect(chosen, <String>['vue']);
      expect(textOf(tester), 'Vue');
      expect(find.byType(NebaListSheet), findsNothing);
    });

    testWidgets('opens on the chevron, which the field names', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaCombobox<String>(items: frameworks, label: Text('Framework')));

      final Finder chevron = find.bySemanticsLabel('Framework').last;
      await tester.tap(chevron, kind: PointerDeviceKind.mouse);
      await settle(tester);

      expect(find.byType(NebaListSheet), findsOneWidget);
      expect(tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus, isTrue);
      semantics.dispose();
    });

    testWidgets('lists a disabled option as unavailable, and it takes no press', (
      WidgetTester tester,
    ) async {
      final List<String?> chosen = <String?>[];

      await pump(tester, NebaCombobox<String>(items: frameworks, onValueChange: chosen.add));
      await type(tester, 'e');

      expect(rowOf(tester, 'Ember').disabled, isTrue);
      await tester.tap(row('Ember'), kind: PointerDeviceKind.mouse);
      await settle(tester);

      expect(chosen, isEmpty);
    });

    testWidgets('narrows the list to what was typed, accents and case folded away', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaCombobox<String>(
          items: <NebaComboboxOption<String>>[
            NebaComboboxOption<String>(value: 'jose', label: 'José'),
            NebaComboboxOption<String>(value: 'ana', label: 'Ana'),
          ],
          allowCustom: false,
        ),
      );
      await type(tester, 'JOSE');

      expect(rows(tester), <String>['José']);
    });

    testWidgets('keeps every row with a filter that keeps everything', (WidgetTester tester) async {
      await pump(
        tester,
        NebaCombobox<String>(
          items: frameworks,
          allowCustom: false,
          filter: (NebaComboboxOption<String> option, String query) => true,
        ),
      );
      await type(tester, 'zzz');

      expect(rows(tester), <String>['React', 'Vue', 'Svelte', 'Ember']);
    });

    testWidgets('takes a filter of its own', (WidgetTester tester) async {
      await pump(
        tester,
        NebaCombobox<String>(
          items: frameworks,
          allowCustom: false,
          filter: (NebaComboboxOption<String> option, String query) =>
              option.value.startsWith(query),
        ),
      );
      await type(tester, 'v');

      expect(rows(tester), <String>['Vue']);
    });

    testWidgets('lights the first match, so Enter takes it', (WidgetTester tester) async {
      final List<String?> chosen = <String?>[];

      await pump(tester, NebaCombobox<String>(items: frameworks, onValueChange: chosen.add));
      await type(tester, 'sv');

      expect(rowOf(tester, 'Svelte').highlighted, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);

      expect(chosen, <String>['svelte']);
      expect(textOf(tester), 'Svelte');
    });

    testWidgets('walks the list with the arrows, past a disabled option and round', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaCombobox<String>(items: frameworks, allowCustom: false));
      await focus(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await settle(tester);
      expect(find.byType(NebaListSheet), findsOneWidget);
      expect(rowOf(tester, 'React').highlighted, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(rowOf(tester, 'Svelte').highlighted, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(rowOf(tester, 'React').highlighted, isTrue);
    });

    testWidgets('shows every option again once the chosen label is back in the field', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaCombobox<String>(items: frameworks, defaultValue: 'vue'));

      await tester.tap(find.byType(EditableText), kind: PointerDeviceKind.mouse);
      await settle(tester);

      expect(rows(tester), <String>['React', 'Vue', 'Svelte', 'Ember']);
      expect(rowOf(tester, 'Vue').selected, isTrue);
    });

    testWidgets('closes on Escape, and Escape again empties it', (WidgetTester tester) async {
      final List<String?> chosen = <String?>[];

      await pump(
        tester,
        NebaCombobox<String>(items: frameworks, defaultValue: 'vue', onValueChange: chosen.add),
      );
      await tester.tap(find.byType(EditableText), kind: PointerDeviceKind.mouse);
      await settle(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);
      expect(find.byType(NebaListSheet), findsNothing);
      expect(textOf(tester), 'Vue');

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);
      expect(textOf(tester), '');
      expect(chosen, <String?>[null]);
    });

    testWidgets('closes when the focus leaves', (WidgetTester tester) async {
      await pump(tester, const NebaCombobox<String>(items: frameworks));
      await type(tester, 'r');
      expect(find.byType(NebaListSheet), findsOneWidget);

      FocusManager.instance.primaryFocus?.unfocus();
      await settle(tester);

      expect(find.byType(NebaListSheet), findsNothing);
    });

    testWidgets('honours a controlled value', (WidgetTester tester) async {
      await pump(
        tester,
        NebaCombobox<String>(items: frameworks, value: 'react', onValueChange: (String? _) {}),
      );
      expect(textOf(tester), 'React');

      await pump(
        tester,
        NebaCombobox<String>(items: frameworks, value: 'svelte', onValueChange: (String? _) {}),
      );
      await settle(tester);
      expect(textOf(tester), 'Svelte');
    });

    testWidgets('does not open, and takes no focus, when disabled', (WidgetTester tester) async {
      await pump(tester, const NebaCombobox<String>(items: frameworks, disabled: true));

      await tester.tap(find.byType(NebaFieldShell), kind: PointerDeviceKind.mouse);
      await settle(tester);

      expect(find.byType(NebaListSheet), findsNothing);
      expect(tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus, isFalse);
    });

    testWidgets('opens when read-only so the options can be read, and chooses nothing', (
      WidgetTester tester,
    ) async {
      final List<String?> chosen = <String?>[];

      await pump(
        tester,
        NebaCombobox<String>(
          items: frameworks,
          readOnly: true,
          defaultValue: 'vue',
          onValueChange: chosen.add,
        ),
      );

      await tester.tap(find.byType(EditableText), kind: PointerDeviceKind.mouse);
      await settle(tester);
      expect(find.byType(NebaListSheet), findsOneWidget);

      await tester.tap(row('React'), kind: PointerDeviceKind.mouse);
      await settle(tester);
      expect(chosen, isEmpty);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);
      expect(chosen, isEmpty);
      expect(textOf(tester), 'Vue');
    });

    testWidgets('reports the open state, and honours a controlled one', (
      WidgetTester tester,
    ) async {
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaCombobox<String>(items: frameworks, open: true, onOpenChange: changes.add),
      );
      await settle(tester);
      expect(find.byType(NebaListSheet), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);
      expect(changes, <bool>[false]);
      expect(find.byType(NebaListSheet), findsOneWidget);
    });
  });

  group('a value the list does not have', () {
    testWidgets('offers what was typed as a row of its own', (WidgetTester tester) async {
      final List<String?> chosen = <String?>[];

      await pump(tester, NebaCombobox<String>(items: frameworks, onValueChange: chosen.add));
      await type(tester, 'qwik');

      expect(rows(tester), <String>['Add “qwik”']);
      expect(rowOf(tester, 'Add “qwik”').highlighted, isTrue);

      await tester.tap(row('Add “qwik”'), kind: PointerDeviceKind.mouse);
      await settle(tester);

      expect(chosen, <String>['qwik']);
      expect(textOf(tester), 'qwik');
    });

    testWidgets('draws the row beyond the limit, after as many options as it allows', (
      WidgetTester tester,
    ) async {
      final List<String?> chosen = <String?>[];

      await pump(
        tester,
        NebaCombobox<String>(items: frameworks, limit: 2, onValueChange: chosen.add),
      );
      await type(tester, 'e');

      expect(rows(tester), <String>['React', 'Vue', 'Add “e”']);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);

      expect(chosen, <String>['e']);
    });

    testWidgets('lets the row say something else', (WidgetTester tester) async {
      await pump(
        tester,
        NebaCombobox<String>(
          items: frameworks,
          customLabel: (String query) => Text('Use $query anyway'),
        ),
      );
      await type(tester, 'qwik');

      expect(find.text('Use qwik anyway'), findsOneWidget);
    });

    testWidgets('does not offer an option under another case, or spelled as its value', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaCombobox<String>(
          items: <NebaComboboxOption<String>>[
            NebaComboboxOption<String>(value: 'ng', label: 'Angular'),
          ],
        ),
      );

      await type(tester, 'aNGULAR');
      expect(rows(tester), <String>['Angular']);

      await tester.enterText(find.byType(EditableText), 'NG');
      await settle(tester);
      expect(rows(tester), <String>['Angular']);
    });

    testWidgets('does not offer a value that has already been chosen', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCombobox<String>.multiple(items: frameworks, defaultValue: <String>['qwik']),
      );
      await type(tester, 'QWIK');

      expect(rows(tester), isEmpty);
    });

    testWidgets('offers nothing when allowCustom is off, and says nothing matches', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaCombobox<String>(
          items: frameworks,
          allowCustom: false,
          emptyMessage: Text('Nope.'),
        ),
      );
      await type(tester, 'qwik');

      expect(rows(tester), isEmpty);
      expect(find.text('Nope.'), findsOneWidget);
    });

    testWidgets('says nothing matches in the language it was given', (WidgetTester tester) async {
      registerNebaMessages('ko', ko);

      await pump(tester, const NebaCombobox<String>(items: frameworks, locale: Locale('ko')));
      await type(tester, 'qwik');

      expect(rows(tester), <String>['“qwik” 추가']);
    });

    testWidgets('keeps what is typed after a value the list does not have', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaCombobox<String>(items: frameworks, defaultValue: 'qwik'));
      expect(textOf(tester), 'qwik');

      await type(tester, 'qwikx');
      expect(textOf(tester), 'qwikx');
    });

    testWidgets('offers no row over a type a typed string cannot be', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCombobox<int>(
          items: <NebaComboboxOption<int>>[NebaComboboxOption<int>(value: 1, label: 'One')],
        ),
      );
      await type(tester, 'two');

      expect(rows(tester), isEmpty);
    });
  });

  group('multiple', () {
    testWidgets('draws a chip per chosen value', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCombobox<String>.multiple(
          items: frameworks,
          defaultValue: <String>['react', 'svelte'],
        ),
      );

      expect(chips(), findsNWidgets(2));
      expect(find.text('React'), findsOneWidget);
      expect(find.text('Svelte'), findsOneWidget);
      expect(textOf(tester), '');
    });

    testWidgets('reports a list, and keeps the list open and the field empty', (
      WidgetTester tester,
    ) async {
      final List<List<String>> chosen = <List<String>>[];

      await pump(
        tester,
        NebaCombobox<String>.multiple(
          items: frameworks,
          defaultValue: const <String>['react'],
          onValueChange: chosen.add,
        ),
      );
      await type(tester, 'v');
      await tester.tap(row('Vue'), kind: PointerDeviceKind.mouse);
      await settle(tester);

      expect(chosen.last, <String>['react', 'vue']);
      expect(find.byType(NebaListSheet), findsOneWidget);
      expect(textOf(tester), '');

      // Choosing a chosen option again takes it out.
      await tester.tap(row('React'), kind: PointerDeviceKind.mouse);
      await settle(tester);
      expect(chosen.last, <String>['vue']);
    });

    testWidgets('removes a chip through its own ×, named for it', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<List<String>> chosen = <List<String>>[];

      await pump(
        tester,
        NebaCombobox<String>.multiple(
          items: frameworks,
          defaultValue: const <String>['react', 'vue'],
          onValueChange: chosen.add,
        ),
      );

      await tester.tap(find.bySemanticsLabel('Remove React'));
      await settle(tester);

      expect(chosen.last, <String>['vue']);
      expect(chips(), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('names the × from removeLabel', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaCombobox<String>.multiple(
          items: frameworks,
          defaultValue: const <String>['react'],
          removeLabel: (String chip) => '$chip 지우기',
        ),
      );

      expect(find.bySemanticsLabel('React 지우기'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('takes the × away while read-only', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaCombobox<String>.multiple(
          items: frameworks,
          readOnly: true,
          defaultValue: <String>['react'],
        ),
      );

      expect(find.bySemanticsLabel('Remove React'), findsNothing);
      semantics.dispose();
    });

    testWidgets('takes the last chip out on Backspace in an empty field', (
      WidgetTester tester,
    ) async {
      final List<List<String>> chosen = <List<String>>[];

      await pump(
        tester,
        NebaCombobox<String>.multiple(
          items: frameworks,
          defaultValue: const <String>['react', 'vue'],
          onValueChange: chosen.add,
        ),
      );
      await focus(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await settle(tester);

      expect(chosen.last, <String>['react']);
    });

    testWidgets('walks its chips with the arrow keys from the caret and back', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaCombobox<String>.multiple(
          items: frameworks,
          defaultValue: <String>['react', 'vue', 'svelte'],
        ),
      );
      await focus(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(_chipHasFocus('Svelte'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(_chipHasFocus('React'), isTrue);

      // Off the start, as off the end, the focus goes back to the field.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(_chipHasFocus('React'), isFalse);
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'NebaCombobox');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(_chipHasFocus('Svelte'), isFalse);
      expect(_chipHasFocus('React'), isFalse);
    });

    testWidgets('takes a chip out on Backspace or Delete and moves to the one in its place', (
      WidgetTester tester,
    ) async {
      final List<List<String>> chosen = <List<String>>[];

      await pump(
        tester,
        NebaCombobox<String>.multiple(
          items: frameworks,
          defaultValue: const <String>['react', 'vue', 'svelte'],
          onValueChange: chosen.add,
        ),
      );
      await focus(tester);

      // The last chip goes, and the one before it takes the focus.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await settle(tester);

      expect(chosen.last, <String>['react', 'vue']);
      expect(_chipHasFocus('Vue'), isTrue);

      // A chip in the middle goes, and the one after it slides into its place.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(_chipHasFocus('React'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await settle(tester);

      expect(chosen.last, <String>['vue']);
      expect(_chipHasFocus('Vue'), isTrue);
    });

    testWidgets('types a letter pressed at a chip into the field', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCombobox<String>.multiple(items: frameworks, defaultValue: <String>['react']),
      );
      await focus(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS, character: 's');
      await settle(tester);

      expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, 's');
    });

    testWidgets('keeps its chips out of reach while it is read-only', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCombobox<String>.multiple(
          items: frameworks,
          readOnly: true,
          defaultValue: <String>['react'],
        ),
      );
      await focus(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(_chipHasFocus('React'), isFalse);
    });

    testWidgets('stands one row of chips at the height of a field', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCombobox<String>.multiple(items: frameworks, defaultValue: <String>['react']),
      );
      expect(tester.getSize(shellSheet()).height, 32);

      await pump(
        tester,
        const SizedBox(
          width: 150,
          child: NebaCombobox<String>.multiple(
            items: frameworks,
            fullWidth: true,
            defaultValue: <String>['react', 'svelte'],
          ),
        ),
      );
      // Two lines of chips grow the field rather than spill out of it.
      expect(tester.getSize(shellSheet()).height, greaterThan(32));
      expect(tester.takeException(), isNull);
    });

    testWidgets('leaves room between the last chip and the text, and only then', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaCombobox<String>.multiple(items: frameworks, defaultValue: <String>['react']),
      );

      final Rect chip = tester.getRect(chips());
      final Rect input = tester.getRect(find.byType(EditableText));
      // The chips' own gap and six pixels more, so the query does not read
      // as another chip's label.
      expect(input.left - chip.right, 4 + 6);
    });

    testWidgets('grows with its chips, as a field sized by its content does', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaCombobox<String>.multiple(items: frameworks));
      final double bare = tester.getSize(shellSheet()).width;

      await pump(
        tester,
        const NebaCombobox<String>.multiple(
          key: Key('chips'),
          items: frameworks,
          defaultValue: <String>['react', 'svelte'],
        ),
      );

      expect(tester.getSize(shellSheet()).width, greaterThan(bare));
      expect(find.text('React'), findsOneWidget);
    });
  });

  group('clearing', () {
    testWidgets('shows no × unless asked', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaCombobox<String>(items: frameworks, defaultValue: 'react'));

      expect(find.bySemanticsLabel('Clear'), findsNothing);
      semantics.dispose();
    });

    testWidgets('empties the field', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<String?> chosen = <String?>[];

      await pump(
        tester,
        NebaCombobox<String>(
          items: frameworks,
          clearable: true,
          defaultValue: 'react',
          onValueChange: chosen.add,
        ),
      );

      await tester.tap(find.bySemanticsLabel('Clear'), kind: PointerDeviceKind.mouse);
      await settle(tester);

      expect(chosen, <String?>[null]);
      expect(textOf(tester), '');
      expect(find.bySemanticsLabel('Clear'), findsNothing);
      semantics.dispose();
    });
  });

  group('validation', () {
    testWidgets('renders the error and turns the family over to danger, the list too', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaCombobox<String>(
          items: frameworks,
          label: Text('Framework'),
          error: Text('Pick one.'),
        ),
      );

      expect(find.text('Pick one.'), findsOneWidget);
      expect(shellOf(tester).edge, danger.line);

      await type(tester, 'r');
      expect(tester.widget<NebaSheet>(listSheet()).edge, danger.line);
    });
  });

  group('style', () {
    testWidgets('is drawn on the same shell as a TextField', (WidgetTester tester) async {
      await pump(tester, const NebaCombobox<String>(items: frameworks));

      expect(tester.getSize(shellSheet()).height, 32);
      expect(shellOf(tester).fill, tokens.panel);
      expect(shellOf(tester).edge, primary.line);
    });

    testWidgets('changes height with size but not with density', (WidgetTester tester) async {
      await pump(tester, const NebaCombobox<String>(items: frameworks, size: NebaSize.lg));
      expect(tester.getSize(shellSheet()).height, 40);

      await pump(
        tester,
        const NebaCombobox<String>(
          items: frameworks,
          size: NebaSize.lg,
          density: NebaDensity.compact,
        ),
      );
      expect(tester.getSize(shellSheet()).height, 40);
    });

    testWidgets('opens a list exactly as wide as the field, on the frosted sheet', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaCombobox<String>(items: frameworks));
      await type(tester, 'r');

      final NebaSheet sheet = tester.widget<NebaSheet>(listSheet());
      expect(sheet.fill, tokens.panelPress);
      expect(sheet.elevation, 3);
      expect(tester.getSize(listSheet()).width, closeTo(tester.getSize(shellSheet()).width, 0.01));
      expect(tester.getRect(listSheet()).top, tester.getRect(shellSheet()).bottom + 6);
    });

    testWidgets('stretches to the container when full width', (WidgetTester tester) async {
      await pump(
        tester,
        const SizedBox(width: 500, child: NebaCombobox<String>(items: frameworks, fullWidth: true)),
      );

      expect(tester.getSize(shellSheet()).width, 500);
    });
  });

  group('shortcuts', () {
    testWidgets('runs before the list acts, and does not replace what it does', (
      WidgetTester tester,
    ) async {
      final List<String> log = <String>[];

      await pump(
        tester,
        NebaCombobox<String>(
          items: frameworks,
          onValueChange: (String? value) => log.add('chose $value'),
          shortcuts: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.enter): () => log.add('enter'),
          },
        ),
      );
      await type(tester, 'vu');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);

      expect(log, <String>['enter', 'chose vue']);
    });
  });

  group('the text', () {
    testWidgets('reports what is typed, not the value', (WidgetTester tester) async {
      final List<String> typed = <String>[];
      final List<String?> chosen = <String?>[];

      await pump(
        tester,
        NebaCombobox<String>(
          items: frameworks,
          onInputValueChange: typed.add,
          onValueChange: chosen.add,
        ),
      );
      await type(tester, 'sv');

      expect(typed, <String>['sv']);
      expect(chosen, isEmpty);
    });

    testWidgets('puts the light out while the reader types', (WidgetTester tester) async {
      await pump(tester, const NebaCombobox<String>(items: frameworks));

      expect(find.byType(NebaFieldTypingMark), findsOneWidget);
    });
  });

  group('label placement', () {
    testWidgets('rests a floating label while the field is empty and idle', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaCombobox<String>(
          items: frameworks,
          labelPlacement: NebaLabelPlacement.float,
          label: Text('Framework'),
          placeholder: 'Search',
        ),
      );
      bool resting() => tester.widget<NebaNotch>(find.byType(NebaNotch)).resting;
      expect(resting(), isTrue);

      await focus(tester);
      expect(resting(), isFalse);
    });

    testWidgets('names the field from a notched label on its edge', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaCombobox<String>(
          items: frameworks,
          labelPlacement: NebaLabelPlacement.notch,
          label: Text('Framework'),
        ),
      );

      expect(find.byType(NebaNotch), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(NebaFieldWidth)).getSemanticsData().label,
        'Framework',
      );
      semantics.dispose();
    });

    testWidgets('rests a multiple field only while nothing is chosen or typed', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaCombobox<String>.multiple(
          items: frameworks,
          labelPlacement: NebaLabelPlacement.float,
          label: Text('Also used'),
        ),
      );
      bool resting() => tester.widget<NebaNotch>(find.byType(NebaNotch)).resting;
      expect(resting(), isTrue);

      await pump(
        tester,
        const NebaCombobox<String>.multiple(
          key: Key('chosen'),
          items: frameworks,
          labelPlacement: NebaLabelPlacement.float,
          label: Text('Also used'),
          defaultValue: <String>['react'],
        ),
      );
      expect(resting(), isFalse);
    });
  });
}

/// Whether the chip that reads [label] holds the focus.
bool _chipHasFocus(String label) {
  final FocusNode? node = FocusManager.instance.primaryFocus;

  if (node?.debugLabel != 'NebaCombobox chip') {
    return false;
  }

  return find
      .descendant(
        of: find.byWidgetPredicate((Widget widget) => widget is Focus && widget.focusNode == node),
        matching: find.text(label),
      )
      .evaluate()
      .isNotEmpty;
}
