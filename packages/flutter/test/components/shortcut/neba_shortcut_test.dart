import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget shortcut) {
    return tester.pumpWidget(host(Center(child: shortcut)));
  }

  /// The key caps' symbols, in order.
  List<String> capsOf(WidgetTester tester) {
    return tester
        .widgetList<Text>(find.descendant(of: find.byType(NebaSheet), matching: find.byType(Text)))
        .map((Text text) => text.data!)
        .toList();
  }

  /// Every text drawn, caps and separators, in order.
  List<String> textOf(WidgetTester tester) {
    return tester
        .widgetList<Text>(
          find.descendant(of: find.byType(NebaShortcut), matching: find.byType(Text)),
        )
        .map((Text text) => text.data!)
        .toList();
  }

  group('keys', () {
    testWidgets('splits a string on plus signs, one cap per key', (WidgetTester tester) async {
      await pump(tester, const NebaShortcut(keys: 'Ctrl+Shift+P', os: NebaShortcutOS.windows));

      expect(capsOf(tester), <String>['Ctrl', 'Shift', 'P']);
    });

    testWidgets('takes a list for a key that is itself a plus', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaShortcut.split(keys: <String>['Ctrl', '+'], os: NebaShortcutOS.windows),
      );

      expect(capsOf(tester), <String>['Ctrl', '+']);
    });

    testWidgets('capitalises a single letter and leaves longer tokens alone', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaShortcut(keys: 'k+F12+PageUp', os: NebaShortcutOS.linux));

      expect(capsOf(tester), <String>['K', 'F12', 'PageUp']);
    });
  });

  group('os', () {
    testWidgets('resolves Mod to Command on a Mac and Ctrl everywhere else', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaShortcut(keys: 'Mod+K', os: NebaShortcutOS.mac));
      expect(capsOf(tester), <String>['⌘', 'K']);

      await pump(tester, const NebaShortcut(keys: 'Mod+K', os: NebaShortcutOS.windows));
      expect(capsOf(tester), <String>['Ctrl', 'K']);

      await pump(tester, const NebaShortcut(keys: 'Mod+K', os: NebaShortcutOS.linux));
      expect(capsOf(tester), <String>['Ctrl', 'K']);
    });

    testWidgets('names Meta by platform, apart from Mod', (WidgetTester tester) async {
      await pump(tester, const NebaShortcut(keys: 'Meta+L', os: NebaShortcutOS.windows));
      expect(capsOf(tester), <String>['Win', 'L']);

      await pump(tester, const NebaShortcut(keys: 'Meta+L', os: NebaShortcutOS.linux));
      expect(capsOf(tester), <String>['Super', 'L']);
    });

    testWidgets('accepts the several names one key already has', (WidgetTester tester) async {
      await pump(tester, const NebaShortcut(keys: 'Cmd+Option+Esc+Return', os: NebaShortcutOS.mac));

      // Escape is not a modifier, so the written order stands.
      expect(capsOf(tester), <String>['⌘', '⌥', '⎋', '↩']);
    });

    testWidgets('writes the Mac modifiers in the order macOS writes them', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaShortcut(keys: 'Mod+Shift+P', os: NebaShortcutOS.mac));
      expect(capsOf(tester), <String>['⇧', '⌘', 'P']);

      await pump(tester, const NebaShortcut(keys: 'Mod+Shift+P', os: NebaShortcutOS.windows));
      expect(capsOf(tester), <String>['Ctrl', 'Shift', 'P']);
    });

    testWidgets('draws the arrows as arrows on every platform', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaShortcut.split(keys: <String>['Up', 'ArrowDown'], os: NebaShortcutOS.windows),
      );

      expect(capsOf(tester), <String>['↑', '↓']);
    });

    testWidgets('reads the platform the app runs on when left to auto', (
      WidgetTester tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      await pump(tester, const NebaShortcut(keys: 'Mod+K'));
      expect(capsOf(tester), <String>['⌘', 'K']);

      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      await pump(tester, const NebaShortcut(keys: 'Mod+K'));
      expect(capsOf(tester), <String>['Ctrl', 'K']);

      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('separator', () {
    testWidgets('is a plus between keys off a Mac and nothing on one', (WidgetTester tester) async {
      await pump(tester, const NebaShortcut(keys: 'Ctrl+Alt+Delete', os: NebaShortcutOS.windows));
      expect(textOf(tester), <String>['Ctrl', '+', 'Alt', '+', 'Del']);

      await pump(tester, const NebaShortcut(keys: 'Ctrl+Alt+Delete', os: NebaShortcutOS.mac));
      expect(textOf(tester), <String>['⌃', '⌥', '⌦']);
    });

    testWidgets('takes one of the caller\'s own on either platform', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaShortcut(keys: 'Mod+K', os: NebaShortcutOS.mac, separator: Text('then')),
      );

      expect(textOf(tester), <String>['⌘', 'then', 'K']);
    });
  });

  group('semantics', () {
    testWidgets('names every key, the glyphs by their names', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaShortcut(keys: 'Mod+Shift+K', os: NebaShortcutOS.mac));
      expect(
        tester.getSemantics(find.byType(NebaShortcut)),
        matchesSemantics(label: 'Shift Command K'),
      );

      await pump(tester, const NebaShortcut(keys: 'Mod+K', os: NebaShortcutOS.windows));
      expect(tester.getSemantics(find.byType(NebaShortcut)), matchesSemantics(label: 'Ctrl K'));

      semantics.dispose();
    });
  });

  group('look', () {
    testWidgets('is an outline secondary cap by default, a step down the ladder', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaShortcut(keys: 'K'));
      final NebaTokens tokens = NebaTheme.of(tester.element(find.byType(NebaShortcut)));
      final NebaColorRoles secondary = tokens.roles(NebaColor.secondary);
      final NebaSheet sheet = tester.widget<NebaSheet>(find.byType(NebaSheet));

      expect(sheet.fill, secondary.panel);
      expect(sheet.edge, secondary.line);
      // A md shortcut's caps are sm controls.
      expect(tester.getSize(find.byType(NebaSheet)).height, NebaScale.controlHeight[NebaSize.sm]);
      expect(
        tester.getSize(find.byType(NebaSheet)).width,
        greaterThanOrEqualTo(NebaShortcut.keyMinWidth[NebaSize.sm]!),
      );
    });

    testWidgets('fills a solid cap and leaves a text one without an edge', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaShortcut(keys: 'K', variant: NebaVariant.solid, color: NebaColor.danger),
      );
      final NebaTokens tokens = NebaTheme.of(tester.element(find.byType(NebaShortcut)));
      NebaSheet sheet() => tester.widget<NebaSheet>(find.byType(NebaSheet));

      expect(sheet().fill, tokens.roles(NebaColor.danger).fill);
      expect(sheet().edge, isNull);

      await pump(tester, const NebaShortcut(keys: 'K', variant: NebaVariant.text));
      expect(sheet().fill, tokens.roles(NebaColor.secondary).soft);
      expect(sheet().edge, isNull);
      expect(sheet().plate, NebaPlate.none);
    });

    testWidgets('changes padding with density but never height', (WidgetTester tester) async {
      await pump(tester, const NebaShortcut(keys: 'PageDown', density: NebaDensity.compact));
      final Size compact = tester.getSize(find.byType(NebaSheet));

      await pump(tester, const NebaShortcut(keys: 'PageDown', density: NebaDensity.standard));
      final Size standard = tester.getSize(find.byType(NebaSheet));

      expect(standard.height, compact.height);
      expect(standard.width, greaterThan(compact.width));
    });

    testWidgets('takes the provider\'s size and variant', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const NebaProvider(
            defaults: NebaDefaults(size: NebaSize.xl, variant: NebaVariant.solid),
            child: Center(child: NebaShortcut(keys: 'K')),
          ),
        ),
      );

      expect(tester.getSize(find.byType(NebaSheet)).height, NebaScale.controlHeight[NebaSize.lg]);
      expect(tester.widget<NebaSheet>(find.byType(NebaSheet)).edge, isNull);
    });
  });
}
