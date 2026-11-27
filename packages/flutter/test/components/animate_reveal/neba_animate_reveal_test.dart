// NebaAnimateReveal: the edge the wipe comes from, the fade it does not do
// unless asked, and the wipe backwards. The settings every `Animate*` shares
// are checked on NebaAnimateFade.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

const Size _size = Size(100, 40);
const Widget _content = SizedBox(key: Key('content'), width: 100, height: 40);

Future<void> _pump(WidgetTester tester, Widget widget) {
  return tester.pumpWidget(host(Center(child: widget)));
}

/// What the clip lets through, in the content's own box.
Rect _shown(WidgetTester tester) {
  final RenderClipRect clip = tester.renderObject<RenderClipRect>(
    find.descendant(of: find.byType(NebaAnimateReveal), matching: find.byType(ClipRect)),
  );

  return clip.clipper!.getClip(_size);
}

double _opacity(WidgetTester tester) {
  return tester
      .widget<Opacity>(
        find.descendant(of: find.byType(NebaAnimateReveal), matching: find.byType(Opacity)),
      )
      .opacity;
}

void main() {
  testWidgets('renders what it was given, at its finished size from the first frame', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await _pump(tester, const NebaAnimateReveal(child: Text('Let through')));

    expect(find.bySemanticsLabel('Let through'), findsOneWidget);
    expect(tester.getSize(find.byType(NebaAnimateReveal)), tester.getSize(find.byType(Text)));

    await tester.pumpAndSettle();
    semantics.dispose();
  });

  testWidgets('uncovers from the left by default, without fading', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateReveal(curve: Curves.linear, child: _content));

    expect(_shown(tester), const Rect.fromLTWH(0, 0, 0, 40));
    expect(_opacity(tester), 1);

    await tester.pump(const Duration(milliseconds: 310));
    expect(_shown(tester), const Rect.fromLTWH(0, 0, 50, 40));

    await tester.pumpAndSettle();
    expect(_shown(tester), const Rect.fromLTWH(0, 0, 100, 40));
  });

  testWidgets('wipes from the side it was told, whatever the direction', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      host(
        const Center(
          child: NebaAnimateReveal(side: NebaSide.bottom, curve: Curves.linear, child: _content),
        ),
        textDirection: TextDirection.rtl,
      ),
    );

    await tester.pump(const Duration(milliseconds: 155));
    expect(_shown(tester), const Rect.fromLTRB(0, 30, 100, 40));

    await tester.pumpAndSettle();
  });

  testWidgets('fades as well when it is given an opacity to start from', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const NebaAnimateReveal(from: 0, child: _content));

    expect(_opacity(tester), 0);
    await tester.pumpAndSettle();
    expect(_opacity(tester), 1);
  });

  testWidgets('runs backwards to cover it up again, and stays covered', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const NebaAnimateReveal(mode: NebaAnimateMode.exit, child: _content));

    expect(_shown(tester), const Rect.fromLTWH(0, 0, 100, 40));

    await tester.pumpAndSettle();
    expect(_shown(tester), const Rect.fromLTWH(0, 0, 0, 40));
  });
}
