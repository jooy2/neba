// NebaAnimateHeadline: one line replacing the one above it on a timer, as
// the React package's AnimateHeadline test carries it.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

const List<Widget> _claims = <Widget>[
  Text('faster', style: TextStyle(fontSize: 10)),
  Text('quieter', style: TextStyle(fontSize: 10)),
  Text('yours', style: TextStyle(fontSize: 10)),
];

Future<void> _pump(WidgetTester tester, Widget widget, {bool disableAnimations = false}) {
  return tester.pumpWidget(host(Center(child: widget), disableAnimations: disableAnimations));
}

/// Whether the line [text] is drawn at all: the one showing, or the one on
/// its way out.
bool _shown(WidgetTester tester, String text) {
  return tester
      .widget<Visibility>(find.ancestor(of: find.text(text), matching: find.byType(Visibility)))
      .visible;
}

/// The opacity the line [text] is drawn at, inside its own arrival.
double _opacity(WidgetTester tester, String text) {
  return tester
      .widget<Opacity>(find.ancestor(of: find.text(text), matching: find.byType(Opacity)).first)
      .opacity;
}

/// Which lines are drawn.
List<String> _drawn(WidgetTester tester) {
  return <String>[
    for (final String line in const <String>['faster', 'quieter', 'yours'])
      if (_shown(tester, line)) line,
  ];
}

void main() {
  group('rendering', () {
    testWidgets('keeps every line laid out, and draws only the first', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateHeadline(children: _claims));

      expect(find.text('faster'), findsOneWidget);
      expect(find.text('yours'), findsOneWidget);
      expect(_drawn(tester), <String>['faster']);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('is as large as its largest line from the first frame', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const NebaAnimateHeadline(children: _claims));

      expect(tester.getSize(find.byType(NebaAnimateHeadline)), const Size(70, 10));

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('tells a screen reader the line that is showing, and no other', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await _pump(tester, const NebaAnimateHeadline(children: _claims));

      expect(find.bySemanticsLabel('faster'), findsOneWidget);
      expect(find.bySemanticsLabel('quieter'), findsNothing);

      await tester.pumpWidget(const SizedBox());
      semantics.dispose();
    });

    testWidgets('brings its first line up as it is built', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateHeadline(children: _claims));

      expect(_opacity(tester, 'faster'), 0);
      await tester.pump(const Duration(milliseconds: 480));
      expect(_opacity(tester, 'faster'), 1);

      await tester.pumpWidget(const SizedBox());
    });
  });

  group('turning', () {
    testWidgets('moves on once the line has arrived and been held, and not before', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const NebaAnimateHeadline(
          interval: Duration(milliseconds: 1000),
          duration: Duration(milliseconds: 200),
          children: _claims,
        ),
      );

      await tester.pump(const Duration(milliseconds: 1199));
      expect(_drawn(tester), <String>['faster']);

      await tester.pump(const Duration(milliseconds: 1));
      // The old line leaves as the new one comes up.
      expect(_drawn(tester), <String>['faster', 'quieter']);
      expect(_opacity(tester, 'quieter'), 0);
      expect(_opacity(tester, 'faster'), 1);

      await tester.pump(const Duration(milliseconds: 199));
      expect(_opacity(tester, 'quieter'), greaterThan(0.95));
      expect(_opacity(tester, 'faster'), lessThan(0.05));

      // Gone once its time is up.
      await tester.pump(const Duration(milliseconds: 1));
      expect(_drawn(tester), <String>['quieter']);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('waits out its delay once, before the first turn', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateHeadline(
          interval: Duration(milliseconds: 1000),
          duration: Duration(milliseconds: 200),
          delay: Duration(milliseconds: 500),
          children: _claims,
        ),
      );

      await tester.pump(const Duration(milliseconds: 1600));
      expect(_drawn(tester), <String>['faster']);
      await tester.pump(const Duration(milliseconds: 100));
      expect(_drawn(tester), contains('quieter'));

      // The next turn waits the line's time and no more.
      await tester.pump(const Duration(milliseconds: 1200));
      expect(_drawn(tester), contains('yours'));

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('comes back to the first line, and says which line came up', (
      WidgetTester tester,
    ) async {
      final List<int> heard = <int>[];

      await _pump(
        tester,
        NebaAnimateHeadline(
          interval: const Duration(milliseconds: 1000),
          duration: const Duration(milliseconds: 200),
          onIndexChange: heard.add,
          children: _claims,
        ),
      );

      for (int turn = 0; turn < 3; turn++) {
        await tester.pump(const Duration(milliseconds: 1200));
      }

      expect(heard, <int>[1, 2, 0]);
      expect(_drawn(tester), contains('faster'));

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('stops on the last line when loop is off', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateHeadline(
          interval: Duration(milliseconds: 1000),
          duration: Duration(milliseconds: 200),
          loop: false,
          children: _claims,
        ),
      );

      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(seconds: 10));
      expect(_drawn(tester), <String>['yours']);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('starts on the line it was given', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateHeadline(defaultIndex: 2, children: _claims));

      expect(_drawn(tester), <String>['yours']);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('does not turn itself when it is handed an index, and follows it', (
      WidgetTester tester,
    ) async {
      final List<int> heard = <int>[];

      Widget headline(int index) {
        return NebaAnimateHeadline(
          index: index,
          interval: const Duration(milliseconds: 1000),
          duration: const Duration(milliseconds: 200),
          onIndexChange: heard.add,
          children: _claims,
        );
      }

      await _pump(tester, headline(0));
      await tester.pump(const Duration(seconds: 10));
      expect(_drawn(tester), <String>['faster']);
      expect(heard, isEmpty);

      await _pump(tester, headline(2));
      expect(_drawn(tester), <String>['faster', 'yours']);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();
      expect(_drawn(tester), <String>['yours']);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('holds on its line while paused, and waits for play when manual', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const NebaAnimateHeadline(
          paused: true,
          interval: Duration(milliseconds: 1000),
          duration: Duration(milliseconds: 200),
          children: _claims,
        ),
      );
      await tester.pump(const Duration(seconds: 5));
      expect(_drawn(tester), <String>['faster']);

      await _pump(
        tester,
        const NebaAnimateHeadline(
          trigger: NebaAnimateTrigger.manual,
          interval: Duration(milliseconds: 1000),
          duration: Duration(milliseconds: 200),
          children: _claims,
        ),
      );
      await tester.pump(const Duration(seconds: 5));
      expect(_drawn(tester), <String>['faster']);

      await _pump(
        tester,
        const NebaAnimateHeadline(
          trigger: NebaAnimateTrigger.manual,
          play: true,
          interval: Duration(milliseconds: 1000),
          duration: Duration(milliseconds: 200),
          children: _claims,
        ),
      );
      await tester.pump(const Duration(milliseconds: 1200));
      expect(_drawn(tester), contains('quieter'));

      await tester.pumpWidget(const SizedBox());
    });
  });

  group('less motion', () {
    testWidgets('stays on its line, which is simply there', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateHeadline(interval: Duration(milliseconds: 1000), children: _claims),
        disableAnimations: true,
      );

      expect(_opacity(tester, 'faster'), 1);
      await tester.pump(const Duration(seconds: 10));
      expect(_drawn(tester), <String>['faster']);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('brings a line it is handed in place, with nothing leaving', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const NebaAnimateHeadline(index: 0, children: _claims),
        disableAnimations: true,
      );
      await _pump(
        tester,
        const NebaAnimateHeadline(index: 1, children: _claims),
        disableAnimations: true,
      );

      expect(_drawn(tester), <String>['quieter']);
      expect(_opacity(tester, 'quieter'), 1);
    });
  });
}
