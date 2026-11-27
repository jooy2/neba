// NebaBreadcrumb and NebaBreadcrumbItem: the suite the React package runs on
// Breadcrumb, asked the way Flutter asks it — the navigation region, the
// list and the current step a screen reader hears, the marks drawn between
// the steps, and the fold — rather than the `<nav>`, `<ol>` and attributes it
// writes. The structured data and `keepMounted` are the web's alone.

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/messages.dart';

import '../../support/host.dart';

void noop() {}

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(
    WidgetTester tester,
    Widget trail, {
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return tester.pumpWidget(
      host(
        Align(alignment: Alignment.topLeft, child: trail),
        textDirection: textDirection,
      ),
    );
  }

  /// A trail of [labels], each step pressable but the last.
  NebaBreadcrumb trailOf(
    List<String> labels, {
    int? maxItems,
    int itemsBeforeCollapse = 1,
    int itemsAfterCollapse = 1,
    bool expandable = true,
    FocusNode? focus,
  }) {
    return NebaBreadcrumb(
      maxItems: maxItems,
      itemsBeforeCollapse: itemsBeforeCollapse,
      itemsAfterCollapse: itemsAfterCollapse,
      expandable: expandable,
      children: <NebaBreadcrumbItem>[
        for (int i = 0; i < labels.length; i++)
          NebaBreadcrumbItem(
            onPressed: i == labels.length - 1 ? null : noop,
            href: i == labels.length - 1 ? null : Uri.parse('/${labels[i].toLowerCase()}'),
            focusNode: i == 1 ? focus : null,
            child: Text(labels[i]),
          ),
      ],
    );
  }

  SemanticsNode nodeOf(WidgetTester tester, String label) => tester.getSemantics(find.text(label));

  Finder marks() {
    return find.byWidgetPredicate((Widget widget) => widget.runtimeType.toString() == '_Separator');
  }

  Finder fold() => find.bySemanticsLabel('Show hidden steps');

  group('rendering', () {
    testWidgets('is a navigation region named Breadcrumb, holding a list of its steps', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, trailOf(<String>['Home', 'Projects', 'Settings']));

      final SemanticsNode nav = tester.getSemantics(find.byType(NebaBreadcrumb));
      expect(nav.role, SemanticsRole.navigation);
      expect(nav.label, 'Breadcrumb');

      final List<SemanticsNode> children = <SemanticsNode>[];
      nav.visitChildren((SemanticsNode child) {
        children.add(child);
        return true;
      });
      expect(children.single.role, SemanticsRole.list);

      final List<SemanticsNode> items = <SemanticsNode>[];
      children.single.visitChildren((SemanticsNode child) {
        items.add(child);
        return true;
      });
      expect(items, hasLength(3));
      expect(items.every((SemanticsNode item) => item.role == SemanticsRole.listItem), isTrue);

      semantics.dispose();
    });

    testWidgets('takes the name it is announced by, or the locale’s', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      registerNebaMessages('ko', ko);

      await pump(
        tester,
        const NebaBreadcrumb(
          label: 'Folders',
          children: <NebaBreadcrumbItem>[NebaBreadcrumbItem(child: Text('Home'))],
        ),
      );
      expect(tester.getSemantics(find.byType(NebaBreadcrumb)).label, 'Folders');

      await pump(
        tester,
        const NebaBreadcrumb(
          locale: Locale('ko'),
          children: <NebaBreadcrumbItem>[NebaBreadcrumbItem(child: Text('Home'))],
        ),
      );
      expect(
        tester.getSemantics(find.byType(NebaBreadcrumb)).label,
        resolveNebaMessages('breadcrumb', 'ko')['label'],
      );

      semantics.dispose();
    });

    testWidgets('is a link to a safe address with an href, and Space leaves it alone', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final FocusNode focus = FocusNode();
      addTearDown(focus.dispose);
      int presses = 0;

      await pump(
        tester,
        NebaBreadcrumb(
          children: <NebaBreadcrumbItem>[
            NebaBreadcrumbItem(
              onPressed: () => presses++,
              href: Uri.parse('/projects'),
              focusNode: focus,
              child: const Text('Projects'),
            ),
            NebaBreadcrumbItem(
              onPressed: noop,
              href: Uri.parse('javascript:alert(1)'),
              child: const Text('Unsafe'),
            ),
            const NebaBreadcrumbItem(child: Text('Settings')),
          ],
        ),
      );

      expect(
        nodeOf(tester, 'Projects'),
        matchesSemantics(
          label: 'Projects',
          isLink: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(nodeOf(tester, 'Projects').getSemanticsData().linkUrl, Uri.parse('/projects'));
      expect(nodeOf(tester, 'Unsafe').getSemanticsData().linkUrl, isNull);

      await tester.tap(find.text('Projects'));
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(presses, 2);

      semantics.dispose();
    });

    testWidgets('is a button with a handler and no href', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaBreadcrumb(
          children: <NebaBreadcrumbItem>[
            NebaBreadcrumbItem(onPressed: noop, child: Text('Back')),
            NebaBreadcrumbItem(child: Text('Here')),
          ],
        ),
      );

      expect(
        nodeOf(tester, 'Back'),
        matchesSemantics(
          label: 'Back',
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

    testWidgets('says a step that opens a new tab does, after its label', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaBreadcrumb(
          children: <NebaBreadcrumbItem>[
            NebaBreadcrumbItem(
              onPressed: noop,
              href: Uri.parse('https://example.com/partners'),
              newTab: true,
              child: const Text('Partners'),
            ),
            const NebaBreadcrumbItem(child: Text('Here')),
          ],
        ),
      );

      expect(nodeOf(tester, 'Partners').label, 'Partners\n(opens in a new tab)');

      semantics.dispose();
    });

    testWidgets('reflects a changed step on rebuild', (WidgetTester tester) async {
      await pump(tester, trailOf(<String>['Home', 'Before']));
      await pump(tester, trailOf(<String>['Home', 'After']));

      expect(find.text('Before'), findsNothing);
      expect(find.text('After'), findsOneWidget);
    });
  });

  group('the current step', () {
    testWidgets('is the last one, selected and not pressable even with a handler', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      int presses = 0;

      await pump(
        tester,
        NebaBreadcrumb(
          children: <NebaBreadcrumbItem>[
            const NebaBreadcrumbItem(onPressed: noop, child: Text('Home')),
            NebaBreadcrumbItem(onPressed: () => presses++, child: const Text('Settings')),
          ],
        ),
      );

      await tester.tap(find.text('Settings'));
      expect(presses, 0);
      expect(
        nodeOf(tester, 'Settings'),
        matchesSemantics(label: 'Settings', hasSelectedState: true, isSelected: true),
      );

      final RichText text = tester.widget<RichText>(
        find.descendant(of: find.text('Settings'), matching: find.byType(RichText)),
      );
      expect(text.text.style!.color, tokens.fg);
      expect(text.text.style!.fontWeight, FontWeight.w500);

      semantics.dispose();
    });

    testWidgets('moves to a step that says it is the current one', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaBreadcrumb(
          children: <NebaBreadcrumbItem>[
            NebaBreadcrumbItem(onPressed: noop, child: Text('Home')),
            NebaBreadcrumbItem(current: true, child: Text('Projects')),
            NebaBreadcrumbItem(onPressed: noop, child: Text('Archive')),
          ],
        ),
      );

      expect(
        nodeOf(tester, 'Projects'),
        matchesSemantics(label: 'Projects', hasSelectedState: true, isSelected: true),
      );
      expect(
        nodeOf(tester, 'Archive'),
        matchesSemantics(
          label: 'Archive',
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

    testWidgets('does not answer a disabled step', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      int presses = 0;

      await pump(
        tester,
        NebaBreadcrumb(
          children: <NebaBreadcrumbItem>[
            NebaBreadcrumbItem(
              onPressed: () => presses++,
              disabled: true,
              child: const Text('Archive'),
            ),
            const NebaBreadcrumbItem(child: Text('Here')),
          ],
        ),
      );

      await tester.tap(find.text('Archive'));
      expect(presses, 0);
      expect(
        nodeOf(tester, 'Archive'),
        matchesSemantics(label: 'Archive', hasEnabledState: true, isEnabled: false),
      );

      semantics.dispose();
    });
  });

  group('separators', () {
    testWidgets('draws one fewer than there are steps, and none for a trail of one', (
      WidgetTester tester,
    ) async {
      await pump(tester, trailOf(<String>['Home', 'Projects', 'Settings']));
      expect(marks(), findsNWidgets(2));

      await pump(tester, trailOf(<String>['Home']));
      expect(marks(), findsNothing);
    });

    testWidgets('turns the chevron along the trail, and back under a right-to-left direction', (
      WidgetTester tester,
    ) async {
      await pump(tester, trailOf(<String>['Home', 'Settings']));
      expect(tester.widget<RotatedBox>(find.byType(RotatedBox)).quarterTurns, 3);
      expect(tester.widget<NebaGlyph>(find.byType(NebaGlyph)).parts, same(NebaGlyphs.chevron));

      await pump(tester, trailOf(<String>['Home', 'Settings']), textDirection: TextDirection.rtl);
      expect(tester.widget<RotatedBox>(find.byType(RotatedBox)).quarterTurns, 1);
      expect(
        tester.getCenter(find.text('Settings')).dx,
        lessThan(tester.getCenter(find.text('Home')).dx),
      );
    });

    testWidgets('draws the named marks and whatever else it is given', (WidgetTester tester) async {
      Future<void> withSeparator(NebaBreadcrumbSeparator separator) {
        return pump(
          tester,
          NebaBreadcrumb(
            separator: separator,
            children: const <NebaBreadcrumbItem>[
              NebaBreadcrumbItem(child: Text('Home')),
              NebaBreadcrumbItem(child: Text('Here')),
            ],
          ),
        );
      }

      await withSeparator(NebaBreadcrumbSeparator.arrow);
      expect(tester.widget<NebaGlyph>(find.byType(NebaGlyph)).parts, same(NebaGlyphs.arrowRight));

      await withSeparator(NebaBreadcrumbSeparator.slash);
      expect(find.text('/'), findsOneWidget);

      await withSeparator(NebaBreadcrumbSeparator.dot);
      expect(find.text('·'), findsOneWidget);

      await withSeparator(const NebaBreadcrumbSeparator.widget(Text('»')));
      expect(find.text('»'), findsOneWidget);
    });

    testWidgets('keeps the marks away from a screen reader', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaBreadcrumb(
          separator: NebaBreadcrumbSeparator.slash,
          children: <NebaBreadcrumbItem>[
            NebaBreadcrumbItem(child: Text('Home')),
            NebaBreadcrumbItem(child: Text('Here')),
          ],
        ),
      );

      expect(find.bySemanticsLabel('/'), findsNothing);

      semantics.dispose();
    });
  });

  group('folding', () {
    const List<String> five = <String>['Home', 'Projects', 'Neba', 'Settings', 'Billing'];
    const List<String> four = <String>['Home', 'Projects', 'Neba', 'Billing'];

    testWidgets('leaves a short trail alone', (WidgetTester tester) async {
      await pump(tester, trailOf(<String>['Home', 'Projects', 'Billing'], maxItems: 4));

      expect(find.text('Projects'), findsOneWidget);
      expect(fold(), findsNothing);
    });

    testWidgets('folds the middle away when the trail is too long', (WidgetTester tester) async {
      await pump(tester, trailOf(five, maxItems: 3));

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Billing'), findsOneWidget);
      expect(find.text('Neba'), findsNothing);
      expect(fold(), findsOneWidget);
    });

    testWidgets('puts the middle back when the fold is pressed', (WidgetTester tester) async {
      await pump(tester, trailOf(four, maxItems: 3));

      await tester.tap(fold());
      await tester.pump();

      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Neba'), findsOneWidget);
      expect(fold(), findsNothing);
    });

    testWidgets('folds again when the steps change, and stays open while they do not', (
      WidgetTester tester,
    ) async {
      await pump(tester, trailOf(four, maxItems: 3));
      await tester.tap(fold());
      await tester.pump();

      await pump(tester, trailOf(four, maxItems: 3));
      expect(find.text('Neba'), findsOneWidget);

      await pump(tester, trailOf(<String>['Home', 'Projects', 'Neba', 'Members'], maxItems: 3));
      expect(find.text('Members'), findsOneWidget);
      expect(find.text('Neba'), findsNothing);
    });

    testWidgets('hands the focus to the first step the fold was hiding', (
      WidgetTester tester,
    ) async {
      final FocusNode projects = FocusNode();
      addTearDown(projects.dispose);

      await pump(tester, trailOf(four, maxItems: 3, focus: projects));

      tester
          .widget<FocusableActionDetector>(
            find.descendant(of: fold(), matching: find.byType(FocusableActionDetector)),
          )
          .focusNode!
          .requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.pump();

      expect(projects.hasFocus, isTrue);
    });

    testWidgets('does the same for a step with no focus node of its own', (
      WidgetTester tester,
    ) async {
      await pump(tester, trailOf(four, maxItems: 3));

      tester
          .widget<FocusableActionDetector>(
            find.descendant(of: fold(), matching: find.byType(FocusableActionDetector)),
          )
          .focusNode!
          .requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.pump();

      final FocusNode? focused = FocusManager.instance.primaryFocus;
      expect(
        find.descendant(
          of: find.ancestor(of: find.text('Projects'), matching: find.byType(NebaBreadcrumbItem)),
          matching: find.byWidgetPredicate(
            (Widget widget) => widget is FocusableActionDetector && widget.focusNode == focused,
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('keeps the ends the caller asked for', (WidgetTester tester) async {
      await pump(tester, trailOf(five, maxItems: 3, itemsBeforeCollapse: 2));

      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Billing'), findsOneWidget);
      expect(find.text('Neba'), findsNothing);
      expect(find.text('Settings'), findsNothing);
    });

    testWidgets('leaves the fold as a mark nobody hears when it does not unfold', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, trailOf(four, maxItems: 3, expandable: false));

      expect(fold(), findsNothing);
      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is NebaGlyph && widget.parts == NebaGlyphs.ellipsis,
        ),
        findsOneWidget,
      );
      expect(find.text('Neba'), findsNothing);

      semantics.dispose();
    });

    testWidgets('does not fold a single step away', (WidgetTester tester) async {
      await pump(tester, trailOf(<String>['Home', 'Projects', 'Billing'], maxItems: 2));

      expect(find.text('Projects'), findsOneWidget);
    });

    testWidgets('makes the last step it shows the current one', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaBreadcrumb(
          maxItems: 3,
          children: <NebaBreadcrumbItem>[
            for (final String label in four)
              NebaBreadcrumbItem(onPressed: noop, child: Text(label)),
          ],
        ),
      );

      expect(
        nodeOf(tester, 'Billing'),
        matchesSemantics(label: 'Billing', hasSelectedState: true, isSelected: true),
      );

      semantics.dispose();
    });

    testWidgets('names the fold in the language it was given, or in words of its own', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      registerNebaMessages('ko', ko);

      await pump(
        tester,
        NebaBreadcrumb(
          maxItems: 3,
          locale: const Locale('ko'),
          children: <NebaBreadcrumbItem>[
            for (final String label in four) NebaBreadcrumbItem(child: Text(label)),
          ],
        ),
      );
      expect(
        find.bySemanticsLabel(resolveNebaMessages('breadcrumb', 'ko')['expand']!),
        findsOneWidget,
      );

      await pump(
        tester,
        NebaBreadcrumb(
          maxItems: 3,
          expandLabel: 'More',
          children: <NebaBreadcrumbItem>[
            for (final String label in four) NebaBreadcrumbItem(child: Text(label)),
          ],
        ),
      );
      expect(find.bySemanticsLabel('More'), findsOneWidget);

      semantics.dispose();
    });
  });

  group('style', () {
    testWidgets('changes the type with size and the gaps with density', (
      WidgetTester tester,
    ) async {
      Future<double> gap(NebaDensity density) async {
        await pump(
          tester,
          NebaBreadcrumb(
            density: density,
            separator: NebaBreadcrumbSeparator.slash,
            children: const <NebaBreadcrumbItem>[
              NebaBreadcrumbItem(child: Text('Home')),
              NebaBreadcrumbItem(child: Text('Here')),
            ],
          ),
        );

        // The step's own inset, then the gap, then the slash.
        return tester.getRect(find.text('/')).left - tester.getRect(find.text('Home')).right - 4;
      }

      expect(
        await gap(NebaDensity.standard),
        NebaBreadcrumb.gap[NebaDensity.standard]![NebaSize.md],
      );
      expect(await gap(NebaDensity.compact), NebaBreadcrumb.gap[NebaDensity.compact]![NebaSize.md]);

      await pump(
        tester,
        const NebaBreadcrumb(
          size: NebaSize.xl,
          children: <NebaBreadcrumbItem>[NebaBreadcrumbItem(child: Text('Home'))],
        ),
      );
      expect(
        tester
            .widget<RichText>(
              find.descendant(of: find.text('Home'), matching: find.byType(RichText)),
            )
            .text
            .style!
            .fontSize,
        NebaScale.controlText[NebaSize.xl],
      );
    });

    testWidgets('draws a step that leads somewhere muted, and a disabled one grey', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaBreadcrumb(
          children: <NebaBreadcrumbItem>[
            NebaBreadcrumbItem(onPressed: noop, child: Text('Home')),
            NebaBreadcrumbItem(onPressed: noop, disabled: true, child: Text('Archive')),
            NebaBreadcrumbItem(child: Text('Here')),
          ],
        ),
      );
      await tester.pumpAndSettle();

      Color? inkOf(String text) => tester
          .widget<RichText>(find.descendant(of: find.text(text), matching: find.byType(RichText)))
          .text
          .style
          ?.color;

      expect(inkOf('Home'), tokens.mutedFg);
      expect(inkOf('Archive'), tokens.disabledFg);
    });

    testWidgets('never applies a transform', (WidgetTester tester) async {
      await pump(tester, trailOf(<String>['Home', 'Projects', 'Settings']));

      expect(
        find.descendant(of: find.byType(NebaBreadcrumb), matching: find.byType(Transform)),
        findsNothing,
      );
    });
  });
}
