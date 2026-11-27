// NebaTreeView: the suite the React package runs on TreeView, asked the way
// Flutter asks it — which rows are built and what a screen reader hears of
// them, where the one focus stop is and where the keys move it, what a press
// opens and chooses and what the tree reports — rather than the roles, the
// attributes and the classes it writes.

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/disclosure.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);

  /// The three-level tree most of these tests walk.
  const List<NebaTreeItem<String>> sample = <NebaTreeItem<String>>[
    NebaTreeItem<String>(
      value: 'src',
      label: Text('src'),
      children: <NebaTreeItem<String>>[
        NebaTreeItem<String>(
          value: 'components',
          label: Text('components'),
          children: <NebaTreeItem<String>>[
            NebaTreeItem<String>(value: 'button', label: Text('Button.tsx')),
          ],
        ),
        NebaTreeItem<String>(value: 'index', label: Text('index.ts')),
      ],
    ),
    NebaTreeItem<String>(value: 'readme', label: Text('README.md')),
  ];

  Future<void> pump(
    WidgetTester tester,
    Widget tree, {
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: 320, child: tree),
        ),
        textDirection: textDirection,
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// The focus node of the row labelled [text].
  FocusNode node(WidgetTester tester, String text) => Focus.of(tester.element(find.text(text)));

  Future<void> focus(WidgetTester tester, String text) async {
    node(tester, text).requestFocus();
    await tester.pump();
    await tester.pump();
  }

  /// The label of the row holding the focus.
  String? focused(WidgetTester tester) {
    final FocusNode? primaryFocus = FocusManager.instance.primaryFocus;

    for (final String text in <String>[
      'src',
      'components',
      'Button.tsx',
      'index.ts',
      'README.md',
      'Apple',
      'Banana',
      'Cherry',
      'Blueberry',
      'Guide',
      'Installation',
      'FAQ',
    ]) {
      final Finder found = find.text(text);

      if (found.evaluate().isNotEmpty && node(tester, text) == primaryFocus) {
        return text;
      }
    }

    return null;
  }

  /// The labels of the rows that hold the tree's stop in the focus order.
  List<String> stops(WidgetTester tester) {
    return <String>[
      for (final Element element in find.byType(Text).evaluate())
        if (Focus.maybeOf(element) case final FocusNode found
            when !found.skipTraversal && found.debugLabel == 'NebaTreeItem')
          (element.widget as Text).data!,
    ];
  }

  SemanticsNode row(WidgetTester tester, String text) => tester.getSemantics(find.text(text));

  /// What a screen reader hears of a row: a button, or a link, that says
  /// whether its branch is open and whether it is chosen.
  Matcher heard(
    String label, {
    bool branch = false,
    bool expanded = false,
    bool? selected,
    bool link = false,
    bool enabled = true,
    bool focused = false,
  }) {
    return matchesSemantics(
      label: label,
      isButton: !link,
      isLink: link,
      hasEnabledState: true,
      isEnabled: enabled,
      isFocusable: true,
      isFocused: focused,
      hasTapAction: enabled,
      hasFocusAction: true,
      hasExpandedState: branch,
      isExpanded: expanded,
      hasSelectedState: selected != null,
      isSelected: selected ?? false,
    );
  }

  group('rendering', () {
    testWidgets('is a list named by its label, one item per top-level row', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaTreeView<String>(label: 'Files', children: sample));

      final SemanticsNode list = tester.getSemantics(
        find.byWidgetPredicate(
          (Widget widget) => widget is Semantics && widget.properties.label == 'Files',
        ),
      );

      expect(list.getSemanticsData().role, SemanticsRole.list);
      expect(list.label, 'Files');

      final List<SemanticsNode> items = <SemanticsNode>[];

      list.visitChildren((SemanticsNode child) {
        items.add(child);
        return true;
      });

      expect(items, hasLength(2));
      expect(items.every((SemanticsNode item) => item.role == SemanticsRole.listItem), isTrue);
      semantics.dispose();
    });

    testWidgets('builds the rows of the branches that start open, and no others', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTreeView<String>(defaultExpanded: <String>['src'], children: sample),
      );

      expect(find.text('index.ts'), findsOneWidget);
      expect(find.text('Button.tsx'), findsNothing);
    });

    testWidgets('says a row with children is collapsed and a leaf is neither', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaTreeView<String>(children: sample));

      expect(
        row(tester, 'src'),
        matchesSemantics(
          label: 'src',
          isButton: true,
          hasExpandedState: true,
          isExpanded: false,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(
        row(tester, 'README.md'),
        matchesSemantics(
          label: 'README.md',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('draws the arrow on a row with no children yet', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaTreeView<String>(
          children: <NebaTreeItem<String>>[
            NebaTreeItem<String>(value: 'remote', label: Text('Remote'), expandable: true),
          ],
        ),
      );

      expect(row(tester, 'Remote'), heard('Remote', branch: true));
      expect(find.byType(NebaDisclosurePanel), findsNothing);
      semantics.dispose();
    });

    testWidgets('names a row with an href as a link to it', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaTreeView<String>(
          children: <NebaTreeItem<String>>[
            NebaTreeItem<String>(
              value: 'docs',
              label: const Text('Docs'),
              href: Uri.parse('/docs'),
            ),
            NebaTreeItem<String>(
              value: 'bad',
              label: const Text('Bad'),
              href: Uri.parse('javascript:alert(1)'),
            ),
          ],
        ),
      );

      expect(row(tester, 'Docs'), heard('Docs', link: true));
      expect(row(tester, 'Docs').getSemanticsData().linkUrl, Uri.parse('/docs'));
      expect(row(tester, 'Bad'), heard('Bad'));
      semantics.dispose();
    });

    testWidgets('shows a changed label on a rebuild', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTreeView<String>(
          children: <NebaTreeItem<String>>[NebaTreeItem<String>(value: 'a', label: Text('Before'))],
        ),
      );
      await pump(
        tester,
        const NebaTreeView<String>(
          children: <NebaTreeItem<String>>[NebaTreeItem<String>(value: 'a', label: Text('After'))],
        ),
      );

      expect(find.text('After'), findsOneWidget);
      expect(find.text('Before'), findsNothing);
    });

    testWidgets('fills the width it is given, at the control height per row', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTreeView<String>(children: sample));

      final Finder pressable = find
          .ancestor(of: find.text('README.md'), matching: find.byType(DecoratedBox))
          .first;

      expect(tester.getSize(pressable).height, 32);
      expect(tester.getSize(find.byType(NebaTreeView<String>)).width, 320);
    });
  });

  group('the sheet', () {
    testWidgets('is a frosted, outlined sheet by default and none for text', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTreeView<String>(children: sample));

      final NebaSheet outline = tester.widget<NebaSheet>(find.byType(NebaSheet).first);

      expect(outline.fill, tokens.panel);
      expect(outline.edge, primary.line);

      await pump(tester, const NebaTreeView<String>(variant: NebaVariant.text, children: sample));

      expect(find.byType(NebaSheet), findsNothing);
    });

    testWidgets('draws a rail beside each row in a group, and none for none', (
      WidgetTester tester,
    ) async {
      Finder rails() => find.byWidgetPredicate(
        (Widget widget) =>
            widget is CustomPaint &&
            widget.painter != null &&
            widget.painter.runtimeType.toString() == '_RailPainter',
      );

      await pump(
        tester,
        const NebaTreeView<String>(defaultExpanded: <String>['src'], children: sample),
      );

      expect(rails(), findsNWidgets(2));

      await pump(
        tester,
        const NebaTreeView<String>(
          lines: NebaTreeViewLines.none,
          defaultExpanded: <String>['src'],
          children: sample,
        ),
      );

      expect(rails(), findsNothing);
    });
  });

  group('opening and shutting', () {
    testWidgets('opens a branch when its row is pressed', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaTreeView<String>(children: sample));
      await tester.tap(find.text('src'));
      await settle(tester);

      expect(
        row(tester, 'src'),
        heard('src', branch: true, expanded: true, selected: true, focused: true),
      );
      expect(find.text('index.ts'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('reports which branches are open', (WidgetTester tester) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(tester, NebaTreeView<String>(onExpandedChange: reported.add, children: sample));
      await tester.tap(find.text('src'));
      await settle(tester);

      expect(reported, <List<String>>[
        <String>['src'],
      ]);
    });

    testWidgets('takes a shut branch out of the tree once it has closed', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTreeView<String>(defaultExpanded: <String>['src'], children: sample),
      );
      await tester.tap(find.text('src'));
      await settle(tester);

      expect(find.text('index.ts', skipOffstage: false), findsNothing);
    });

    testWidgets('takes a shutting branch out of reach while it goes', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaTreeView<String>(defaultExpanded: <String>['src'], children: sample),
      );
      await tester.tap(find.text('src'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));

      // Still drawn, closing, and neither heard nor reachable.
      expect(find.text('index.ts'), findsOneWidget);
      expect(
        find.ancestor(of: find.text('index.ts'), matching: find.byType(ExcludeFocus)),
        findsWidgets,
      );
      expect(
        tester
            .widgetList<ExcludeFocus>(
              find.ancestor(of: find.text('index.ts'), matching: find.byType(ExcludeFocus)),
            )
            .any((ExcludeFocus widget) => widget.excluding),
        isTrue,
      );
      expect(find.semantics.byLabel('index.ts'), findsNothing);
      semantics.dispose();
    });

    testWidgets('opens a branch at a height, from none to its rows', (WidgetTester tester) async {
      await pump(tester, const NebaTreeView<String>(children: sample));

      final double shut = tester.getSize(find.byType(NebaTreeView<String>)).height;

      await tester.tap(find.text('src'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));

      final double opening = tester.getSize(find.byType(NebaTreeView<String>)).height;

      await tester.pump(const Duration(milliseconds: 400));

      final double open = tester.getSize(find.byType(NebaTreeView<String>)).height;

      expect(opening, greaterThan(shut));
      expect(opening, lessThan(open));
      // Two rows of 32 came in.
      expect(open - shut, 64);
    });

    testWidgets('reports to the handler it was most recently given', (WidgetTester tester) async {
      final List<List<String>> first = <List<String>>[];
      final List<List<String>> second = <List<String>>[];

      await pump(
        tester,
        NebaTreeView<String>(
          onExpandedChange: first.add,
          onSelectedChange: first.add,
          children: sample,
        ),
      );
      await pump(
        tester,
        NebaTreeView<String>(
          onExpandedChange: second.add,
          onSelectedChange: second.add,
          children: sample,
        ),
      );
      await tester.tap(find.text('src'));
      await settle(tester);

      expect(first, isEmpty);
      expect(second, <List<String>>[
        <String>['src'],
        <String>['src'],
      ]);
    });

    testWidgets('opens a row that cannot be chosen without choosing it', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<List<String>> chosen = <List<String>>[];

      await pump(
        tester,
        NebaTreeView<String>(
          onSelectedChange: chosen.add,
          children: const <NebaTreeItem<String>>[
            NebaTreeItem<String>(
              value: 'src',
              label: Text('src'),
              selectable: false,
              children: <NebaTreeItem<String>>[
                NebaTreeItem<String>(value: 'index', label: Text('index.ts')),
              ],
            ),
          ],
        ),
      );
      await tester.tap(find.text('src'));
      await settle(tester);

      expect(find.text('index.ts'), findsOneWidget);
      expect(chosen, isEmpty);
      expect(row(tester, 'src'), heard('src', branch: true, expanded: true, focused: true));
      semantics.dispose();
    });

    testWidgets('stays shut when the caller controls it and does not answer', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTreeView<String>(expanded: <String>[], children: sample));
      await tester.tap(find.text('src'));
      await settle(tester);

      expect(find.text('index.ts'), findsNothing);
    });

    testWidgets('opens and shuts with the arrow alone, choosing nothing', (
      WidgetTester tester,
    ) async {
      final List<List<String>> chosen = <List<String>>[];

      await pump(tester, NebaTreeView<String>(onSelectedChange: chosen.add, children: sample));

      final Finder arrow = find
          .descendant(
            of: find.ancestor(of: find.text('src'), matching: find.byType(Row)).first,
            matching: find.byType(GestureDetector),
          )
          .first;

      await tester.tap(arrow);
      await settle(tester);

      expect(find.text('index.ts'), findsOneWidget);
      expect(chosen, isEmpty);
    });
  });

  group('keepMounted', () {
    const List<NebaTreeItem<String>> docs = <NebaTreeItem<String>>[
      NebaTreeItem<String>(
        value: 'guide',
        label: Text('Guide'),
        children: <NebaTreeItem<String>>[
          NebaTreeItem<String>(value: 'install', label: Text('Installation')),
          NebaTreeItem<String>(value: 'theming', label: Text('Theming')),
        ],
      ),
      NebaTreeItem<String>(value: 'faq', label: Text('FAQ')),
    ];

    testWidgets('leaves a shut branch unbuilt by default', (WidgetTester tester) async {
      await pump(tester, const NebaTreeView<String>(children: docs));

      expect(find.text('Installation', skipOffstage: false), findsNothing);
    });

    testWidgets('keeps the rows of a shut branch built, out of sight and reach', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTreeView<String>(keepMounted: true, children: docs));

      expect(find.text('Installation', skipOffstage: false), findsOneWidget);
      expect(find.text('Installation'), findsNothing);
    });

    testWidgets('opens and shuts the kept branch in place', (WidgetTester tester) async {
      await pump(tester, const NebaTreeView<String>(keepMounted: true, children: docs));
      await focus(tester, 'Guide');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await settle(tester);

      expect(find.text('Installation'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await settle(tester);

      expect(find.text('Installation'), findsNothing);
      expect(find.text('Installation', skipOffstage: false), findsOneWidget);
    });

    testWidgets('steps over the rows of a shut branch with the arrow keys', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTreeView<String>(keepMounted: true, children: docs));
      await focus(tester, 'Guide');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(focused(tester), 'FAQ');
    });

    testWidgets('keeps the focus stop off the rows of a shut branch', (WidgetTester tester) async {
      await pump(tester, const NebaTreeView<String>(keepMounted: true, children: docs));

      expect(stops(tester), <String>['Guide']);
    });
  });

  group('choosing', () {
    testWidgets('marks the row that was pressed', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaTreeView<String>(children: sample));
      await tester.tap(find.text('README.md'));
      await settle(tester);

      expect(row(tester, 'README.md'), heard('README.md', selected: true, focused: true));
      semantics.dispose();
    });

    testWidgets('tints the chosen row and sets its label a weight up', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTreeView<String>(defaultSelected: <String>['readme'], children: sample),
      );
      await settle(tester);

      final DecoratedBox tint = tester.widget<DecoratedBox>(
        find.ancestor(of: find.text('README.md'), matching: find.byType(DecoratedBox)).first,
      );
      final DefaultTextStyle style = DefaultTextStyle.of(tester.element(find.text('README.md')));

      expect((tint.decoration as BoxDecoration).color, primary.softPress);
      expect(style.style.fontWeight, FontWeight.w500);
      expect(style.style.color, primary.onTint);
    });

    testWidgets('reports the chosen row', (WidgetTester tester) async {
      final List<List<String>> chosen = <List<String>>[];

      await pump(tester, NebaTreeView<String>(onSelectedChange: chosen.add, children: sample));
      await tester.tap(find.text('README.md'));
      await settle(tester);

      expect(chosen, <List<String>>[
        <String>['readme'],
      ]);
    });

    testWidgets('replaces the chosen row when only one may be chosen', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaTreeView<String>(defaultSelected: <String>['src'], children: sample),
      );
      await tester.tap(find.text('README.md'));
      await settle(tester);

      expect(row(tester, 'src'), heard('src', branch: true));
      expect(row(tester, 'README.md'), heard('README.md', selected: true, focused: true));
      semantics.dispose();
    });

    testWidgets('keeps the chosen row chosen when it is pressed again', (
      WidgetTester tester,
    ) async {
      final List<List<String>> chosen = <List<String>>[];

      await pump(
        tester,
        NebaTreeView<String>(
          defaultSelected: const <String>['readme'],
          onSelectedChange: chosen.add,
          children: sample,
        ),
      );
      await tester.tap(find.text('README.md'));
      await settle(tester);

      expect(chosen.single, <String>['readme']);
    });

    testWidgets('adds to the chosen rows when multiple is set', (WidgetTester tester) async {
      final List<List<String>> chosen = <List<String>>[];

      await pump(
        tester,
        NebaTreeView<String>(
          multiple: true,
          defaultSelected: const <String>['src'],
          onSelectedChange: chosen.add,
          children: sample,
        ),
      );
      await tester.tap(find.text('README.md'));
      await settle(tester);

      expect(chosen.last, <String>['src', 'readme']);

      await tester.tap(find.text('README.md'));
      await settle(tester);

      expect(chosen.last, <String>['src']);
    });

    testWidgets('does not answer a disabled row', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<List<String>> chosen = <List<String>>[];

      await pump(
        tester,
        NebaTreeView<String>(
          onSelectedChange: chosen.add,
          children: const <NebaTreeItem<String>>[
            NebaTreeItem<String>(value: 'a', label: Text('Locked'), disabled: true),
          ],
        ),
      );
      await tester.tap(find.text('Locked'));
      await settle(tester);

      expect(chosen, isEmpty);
      expect(
        row(tester, 'Locked'),
        matchesSemantics(
          label: 'Locked',
          isButton: true,
          hasEnabledState: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
      expect(
        DefaultTextStyle.of(tester.element(find.text('Locked'))).style.color,
        tokens.disabledFg,
      );
      semantics.dispose();
    });
  });

  group('the keyboard', () {
    testWidgets('starts the focus stop on the chosen row when one is showing', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTreeView<String>(defaultSelected: <String>['readme'], children: sample),
      );

      expect(stops(tester), <String>['README.md']);
    });

    testWidgets('gives the first row the focus stop in the build that draws it', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTreeView<String>(defaultExpanded: <String>['src'], children: sample),
      );

      expect(stops(tester), <String>['src']);
    });

    testWidgets('is one stop in the focus order however many rows there are', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTreeView<String>(
          defaultExpanded: <String>['src', 'components'],
          children: sample,
        ),
      );

      expect(stops(tester), hasLength(1));
    });

    testWidgets('moves the focus stop off a row a shut branch took away', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTreeView<String>(expanded: <String>['src', 'components'], children: sample),
      );
      await focus(tester, 'components');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(stops(tester), <String>['Button.tsx']);

      await pump(tester, const NebaTreeView<String>(expanded: <String>[], children: sample));
      await settle(tester);

      expect(stops(tester), <String>['src']);
      expect(find.text('Button.tsx'), findsNothing);
    });

    testWidgets('walks the rows that are showing with the arrow keys', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTreeView<String>(defaultExpanded: <String>['src'], children: sample),
      );
      await focus(tester, 'src');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(focused(tester), 'components');

      // A shut branch is stepped over.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(focused(tester), 'index.ts');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      expect(focused(tester), 'src');
      expect(stops(tester), <String>['src']);
    });

    testWidgets('moves to the next row whose label starts with a typed letter', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTreeView<String>(
          label: 'Fruit',
          children: <NebaTreeItem<String>>[
            NebaTreeItem<String>(value: 'apple', label: Text('Apple')),
            NebaTreeItem<String>(value: 'banana', label: Text('Banana')),
            NebaTreeItem<String>(value: 'cherry', label: Text('Cherry')),
            NebaTreeItem<String>(value: 'blueberry', label: Text('Blueberry')),
          ],
        ),
      );
      await focus(tester, 'Apple');

      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.pump();
      expect(focused(tester), 'Banana');

      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.pump();
      expect(focused(tester), 'Blueberry');

      // Round past the end to the first match again.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.pump();
      expect(focused(tester), 'Banana');

      // A letter no label starts with leaves the focus where it is.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
      await tester.pump();
      expect(focused(tester), 'Banana');
    });

    testWidgets('opens a shut branch with the forward arrow and steps into an open one', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTreeView<String>(children: sample));
      await focus(tester, 'src');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await settle(tester);

      expect(find.text('components'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(focused(tester), 'components');
    });

    testWidgets('opens with the forward arrow without choosing the row', (
      WidgetTester tester,
    ) async {
      final List<List<String>> chosen = <List<String>>[];

      await pump(tester, NebaTreeView<String>(onSelectedChange: chosen.add, children: sample));
      await focus(tester, 'src');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await settle(tester);

      expect(find.text('components'), findsOneWidget);
      expect(chosen, isEmpty);
    });

    testWidgets('shuts an open branch with the back arrow and climbs out of a leaf', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTreeView<String>(defaultExpanded: <String>['src'], children: sample),
      );
      await focus(tester, 'index.ts');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(focused(tester), 'src');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await settle(tester);

      expect(find.text('index.ts'), findsNothing);
    });

    testWidgets('swaps the two arrows right to left', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTreeView<String>(children: sample),
        textDirection: TextDirection.rtl,
      );
      await focus(tester, 'src');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await settle(tester);

      expect(find.text('components'), findsNothing);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await settle(tester);

      expect(find.text('components'), findsOneWidget);
    });

    testWidgets('jumps to the ends with Home and End', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTreeView<String>(defaultExpanded: <String>['src'], children: sample),
      );
      await focus(tester, 'src');
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();

      expect(focused(tester), 'README.md');

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();

      expect(focused(tester), 'src');
    });

    testWidgets('chooses the row in hand with Enter and Space', (WidgetTester tester) async {
      final List<List<String>> chosen = <List<String>>[];

      await pump(
        tester,
        NebaTreeView<String>(multiple: true, onSelectedChange: chosen.add, children: sample),
      );
      await focus(tester, 'README.md');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(chosen.last, <String>['readme']);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(chosen.last, <String>[]);
    });

    testWidgets('rings the row in hand for the keyboard, inside its edge', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTreeView<String>(children: sample));
      await focus(tester, 'src');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final NebaFocusRing ring = tester.widget<NebaFocusRing>(
        find.ancestor(of: find.text('README.md'), matching: find.byType(NebaFocusRing)).first,
      );

      expect(ring.visible, isTrue);
      expect(ring.offset, -focusRingWidth);
      expect(ring.color, primary.ring);
    });
  });

  group('a tree that chooses several', () {
    testWidgets('says which rows are not chosen as well as which are', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaTreeView<String>(
          multiple: true,
          defaultSelected: <String>['readme'],
          children: sample,
        ),
      );

      expect(row(tester, 'README.md'), heard('README.md', selected: true));
      expect(row(tester, 'src'), heard('src', branch: true, selected: false));
      semantics.dispose();
    });
  });

  group('the row', () {
    testWidgets('puts an action outside the pressable area', (WidgetTester tester) async {
      final List<List<String>> chosen = <List<String>>[];
      int shared = 0;

      await pump(
        tester,
        NebaTreeView<String>(
          onSelectedChange: chosen.add,
          children: <NebaTreeItem<String>>[
            NebaTreeItem<String>(
              value: 'a',
              label: const Text('Report'),
              action: NebaButton(
                size: NebaSize.xs,
                onPressed: () => shared++,
                child: const Text('Share'),
              ),
            ),
          ],
        ),
      );
      await tester.tap(find.text('Share'));
      await settle(tester);

      expect(shared, 1);
      expect(chosen, isEmpty);
    });

    testWidgets('leaves Enter on an action to the action', (WidgetTester tester) async {
      final List<List<String>> chosen = <List<String>>[];
      int shared = 0;

      await pump(
        tester,
        NebaTreeView<String>(
          onSelectedChange: chosen.add,
          children: <NebaTreeItem<String>>[
            NebaTreeItem<String>(
              value: 'a',
              label: const Text('Report'),
              action: NebaButton(
                size: NebaSize.xs,
                onPressed: () => shared++,
                child: const Text('Share'),
              ),
            ),
          ],
        ),
      );
      Focus.of(tester.element(find.text('Share'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(shared, 1);
      expect(chosen, isEmpty);
    });

    testWidgets('follows a row that is a link when Enter is pressed on it', (
      WidgetTester tester,
    ) async {
      int followed = 0;

      await pump(
        tester,
        NebaTreeView<String>(
          children: <NebaTreeItem<String>>[
            NebaTreeItem<String>(
              value: 'guide',
              label: const Text('Guide'),
              href: Uri.parse('#guide'),
              onPressed: () => followed++,
            ),
          ],
        ),
      );
      await focus(tester, 'Guide');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(followed, 1);
    });

    testWidgets('calls the row handler before it opens', (WidgetTester tester) async {
      final List<String> order = <String>[];

      await pump(
        tester,
        NebaTreeView<String>(
          onExpandedChange: (List<String> open) => order.add('open'),
          children: <NebaTreeItem<String>>[
            NebaTreeItem<String>(
              value: 'a',
              label: const Text('src'),
              onPressed: () => order.add('pressed'),
              children: const <NebaTreeItem<String>>[
                NebaTreeItem<String>(value: 'b', label: Text('index.ts')),
              ],
            ),
          ],
        ),
      );
      await tester.tap(find.text('src'));
      await settle(tester);

      expect(order, <String>['pressed', 'open']);
    });

    testWidgets('opens and chooses a row that has no value, and reports neither', (
      WidgetTester tester,
    ) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(
        tester,
        NebaTreeView<String>(
          onExpandedChange: reported.add,
          children: const <NebaTreeItem<String>>[
            NebaTreeItem<String>(
              label: Text('src'),
              children: <NebaTreeItem<String>>[NebaTreeItem<String>(label: Text('index.ts'))],
            ),
          ],
        ),
      );
      await tester.tap(find.text('src'));
      await settle(tester);

      expect(find.text('index.ts'), findsOneWidget);
      expect(reported, <List<String>>[<String>[]]);
    });
  });
}
