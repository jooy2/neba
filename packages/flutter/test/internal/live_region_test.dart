// A region a screen reader reads out as it changes, written the way each
// platform can read it.

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/src/internal/live_region.dart';

import '../support/host.dart';

void main() {
  const String said = 'Deploy failed\nThe build exited with 1.';

  SemanticsNode nodeOf(WidgetTester tester) => tester.getSemantics(find.byType(NebaLiveRegion));

  Widget region(SemanticsRole role, {required bool web}) {
    return host(
      Center(
        child: NebaLiveRegion(
          role: role,
          web: web,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[Text('Deploy failed'), Text('The build exited with 1.')],
          ),
        ),
      ),
    );
  }

  testWidgets('is a live region holding everything inside it, off the web', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    for (final SemanticsRole role in <SemanticsRole>[SemanticsRole.alert, SemanticsRole.status]) {
      await tester.pumpWidget(region(role, web: false));

      expect(nodeOf(tester), matchesSemantics(label: said, isLiveRegion: true));
      expect(nodeOf(tester).getSemanticsData().role, SemanticsRole.none);
    }

    semantics.dispose();
  });

  testWidgets('writes the role itself on the web, where it is read', (WidgetTester tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    for (final SemanticsRole role in <SemanticsRole>[SemanticsRole.alert, SemanticsRole.status]) {
      await tester.pumpWidget(region(role, web: true));

      expect(nodeOf(tester), matchesSemantics(label: said));
      expect(nodeOf(tester).getSemanticsData().role, role);
    }

    semantics.dispose();
  });

  testWidgets('is not live in any other role', (WidgetTester tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await tester.pumpWidget(region(SemanticsRole.none, web: false));

    expect(nodeOf(tester), matchesSemantics(label: said));

    semantics.dispose();
  });
}
