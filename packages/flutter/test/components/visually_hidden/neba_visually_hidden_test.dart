// NebaVisuallyHidden: the suite the React package runs on VisuallyHidden,
// asked the way Flutter asks it — what a screen reader hears, what the screen
// and the pointer do not, and what visible changes.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(host(Center(child: child)));
  }

  testWidgets('is read by a screen reader', (WidgetTester tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await pump(tester, const NebaVisuallyHidden(child: Text('7 unread messages')));

    expect(find.bySemanticsLabel('7 unread messages'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('takes no room beside what it names', (WidgetTester tester) async {
    await pump(
      tester,
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(key: Key('a'), width: 10, height: 10),
          NebaVisuallyHidden(child: Text('a long sentence a sighted reader never sees')),
          SizedBox(key: Key('b'), width: 10, height: 10),
        ],
      ),
    );

    expect(tester.getSize(find.byType(NebaVisuallyHidden)), Size.zero);
    expect(
      tester.getTopLeft(find.byKey(const Key('b'))).dx,
      tester.getTopRight(find.byKey(const Key('a'))).dx,
    );
  });

  testWidgets('paints nothing and takes no tap', (WidgetTester tester) async {
    int taps = 0;

    await pump(
      tester,
      NebaVisuallyHidden(
        child: GestureDetector(
          onTap: () => taps += 1,
          child: const SizedBox(width: 100, height: 100),
        ),
      ),
    );
    await tester.tapAt(tester.getCenter(find.byType(SizedBox).last));

    expect(taps, 0);
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0);
  });

  testWidgets('keeps a hidden control focusable and its action reachable', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await pump(
      tester,
      NebaVisuallyHidden(
        child: NebaButton(onPressed: () {}, child: const Text('Skip to content')),
      ),
    );

    expect(
      tester.getSemantics(find.byType(NebaButton)),
      matchesSemantics(
        label: 'Skip to content',
        isButton: true,
        isEnabled: true,
        hasEnabledState: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('draws the child like anything else when visible', (WidgetTester tester) async {
    await pump(
      tester,
      const NebaVisuallyHidden(visible: true, child: SizedBox(width: 40, height: 20)),
    );

    expect(tester.getSize(find.byType(NebaVisuallyHidden)), const Size(40, 20));
    expect(find.byType(Opacity), findsNothing);
  });
}
