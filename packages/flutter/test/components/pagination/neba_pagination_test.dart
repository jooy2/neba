import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget pagination) {
    return tester.pumpWidget(host(Center(child: pagination)));
  }

  /// The page numbers drawn, with `…` for a run left out.
  List<String> shown(WidgetTester tester) {
    return tester
        .widgetList<Text>(
          find.descendant(of: find.byType(NebaPagination), matching: find.byType(Text)),
        )
        .map((Text text) => text.data!)
        .toList();
  }

  group('pagesOf', () {
    test('keeps the ends and the pages beside the current one', () {
      expect(NebaPagination.pagesOf(count: 20, page: 10), <int?>[1, null, 9, 10, 11, null, 20]);
    });

    test('fills a gap of one page rather than writing an ellipsis for it', () {
      expect(NebaPagination.pagesOf(count: 20, page: 4), <int?>[1, 2, 3, 4, 5, null, 20]);
      expect(NebaPagination.pagesOf(count: 7, page: 4), <int?>[1, 2, 3, 4, 5, 6, 7]);
    });

    test('widens with siblings and boundaries', () {
      expect(NebaPagination.pagesOf(count: 30, page: 15, siblingCount: 2, boundaryCount: 2), <int?>[
        1,
        2,
        null,
        13,
        14,
        15,
        16,
        17,
        null,
        29,
        30,
      ]);
    });
  });

  testWidgets('draws nothing for one page', (WidgetTester tester) async {
    await pump(tester, const NebaPagination(count: 1));

    expect(find.byType(NebaButton), findsNothing);
  });

  testWidgets('goes to the page pressed, and steps back and forth', (WidgetTester tester) async {
    final List<int> pages = <int>[];

    await pump(tester, NebaPagination(count: 10, defaultPage: 5, onPageChange: pages.add));
    expect(shown(tester), <String>['1', '…', '4', '5', '6', '…', '10']);

    await tester.tap(find.text('6'));
    await tester.pump();
    expect(pages, <int>[6]);
    expect(shown(tester), <String>['1', '…', '5', '6', '7', '…', '10']);

    await tester.tap(find.bySemanticsLabel('Previous page'));
    await tester.pump();
    expect(pages, <int>[6, 5]);
  });

  testWidgets('fills the current page and leaves the rest in the variant', (
    WidgetTester tester,
  ) async {
    await pump(tester, const NebaPagination(count: 5, page: 2));

    NebaButton button(String page) => tester.widget<NebaButton>(
      find.ancestor(of: find.text(page), matching: find.byType(NebaButton)),
    );
    expect(button('2').variant, NebaVariant.solid);
    expect(button('3').variant, NebaVariant.text);
  });

  testWidgets('disables the steps at the ends but keeps them in the focus order', (
    WidgetTester tester,
  ) async {
    await pump(tester, const NebaPagination(count: 5, page: 1, showEdges: true));

    final List<NebaButton> steps = tester
        .widgetList<NebaButton>(find.byType(NebaButton))
        .where((NebaButton button) => button.semanticLabel?.contains('page') ?? false)
        .where((NebaButton button) => button.child == null)
        .toList();
    expect(steps.map((NebaButton b) => b.disabled), <bool?>[true, true, false, false]);
    expect(steps.every((NebaButton b) => b.focusableWhenDisabled), isTrue);
  });

  testWidgets('names the row, each page, the current one and where the reader is', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await pump(tester, const NebaPagination(count: 8, page: 3));

    expect(find.bySemanticsLabel('Pagination'), findsOneWidget);
    expect(find.bySemanticsLabel('Page 3 of 8'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Page 3')),
      matchesSemantics(
        label: 'Page 3',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );

    semantics.dispose();
  });
}
