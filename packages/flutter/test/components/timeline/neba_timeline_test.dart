// NebaTimeline and NebaTimelineItem: the suite the React package runs on
// Timeline, asked the way Flutter asks it — what a screen reader hears for
// each step, the bullet and the line actually drawn, and where the steps
// land — rather than the `<ol>`, the classes and the `data-status` it writes.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

/// How many probes have been built from scratch, which is what a step losing
/// its place in the tree would show.
int probeStarts = 0;

class _Probe extends StatefulWidget {
  const _Probe();

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    probeStarts++;
  }

  @override
  Widget build(BuildContext context) => const Text('probe');
}

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);

  Future<void> pump(
    WidgetTester tester,
    Widget timeline, {
    double width = 400,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: timeline),
        ),
        textDirection: textDirection,
      ),
    );
  }

  List<Widget> steps() {
    return const <Widget>[
      NebaTimelineItem(title: Text('One')),
      NebaTimelineItem(title: Text('Two')),
      NebaTimelineItem(title: Text('Three')),
    ];
  }

  /// The semantics node of the step titled [title].
  SemanticsNode stepOf(WidgetTester tester, String title) {
    return tester.getSemantics(
      find.ancestor(of: find.text(title), matching: find.byType(NebaTimelineItem)),
    );
  }

  /// What the step titled [title] says it is: the word a screen reader hears
  /// first, or `current` for the selected one.
  String statusOf(WidgetTester tester, String title) {
    final SemanticsNode node = stepOf(tester, title);

    return node.getSemanticsData().label.split('\n').first == title
        ? 'current'
        : node.getSemanticsData().label.split('\n').first;
  }

  Finder bullets() {
    return find.descendant(of: find.byType(NebaTimeline), matching: find.byType(NebaSheet));
  }

  Finder connectors() {
    return find.byWidgetPredicate(
      (Widget widget) =>
          widget is CustomPaint && widget.painter.runtimeType.toString() == '_ConnectorPainter',
    );
  }

  group('rendering', () {
    testWidgets('is a list of its steps, in order', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaTimeline(active: 1, children: steps()));

      final SemanticsNode list = tester.getSemantics(find.byType(NebaTimeline));
      expect(list.role, SemanticsRole.list);

      final List<SemanticsNode> items = <SemanticsNode>[];
      list.visitChildren((SemanticsNode child) {
        items.add(child);
        return true;
      });
      expect(items.map((SemanticsNode node) => node.role).toSet(), <SemanticsRole>{
        SemanticsRole.listItem,
      });
      expect(items.map((SemanticsNode node) => node.label), <String>[
        'Completed\nOne',
        'Two',
        'Upcoming\nThree',
      ]);

      semantics.dispose();
    });

    testWidgets('renders the title, the meta and the body, the meta beside the title', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTimeline(
          children: <Widget>[
            NebaTimelineItem(title: Text('Ordered'), meta: Text('12 Jul'), child: Text('Paid.')),
          ],
        ),
      );

      final Rect title = tester.getRect(find.text('Ordered'));
      final Rect meta = tester.getRect(find.text('12 Jul'));
      final Rect body = tester.getRect(find.text('Paid.'));

      expect(meta.left, greaterThan(title.right));
      expect(body.top, greaterThan(title.bottom));
      expect(body.left, title.left);
    });

    testWidgets('moves the meta under the title when the two do not fit', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTimeline(
          children: <Widget>[
            NebaTimelineItem(
              title: Text('A title long enough to fill the line'),
              meta: Text('12 July 2026'),
            ),
          ],
        ),
        width: 260,
      );

      expect(
        tester.getRect(find.text('12 July 2026')).top,
        greaterThanOrEqualTo(
          tester.getRect(find.text('A title long enough to fill the line')).bottom,
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders a step with only a body', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTimeline(children: <Widget>[NebaTimelineItem(child: Text('Just a body'))]),
      );

      expect(find.text('Just a body'), findsOneWidget);
    });

    testWidgets('draws what it is given in the bullet, sized off the bullet', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTimeline(
          size: NebaSize.lg,
          children: <Widget>[NebaTimelineItem(bullet: Text('1'), title: Text('Account'))],
        ),
      );

      final RichText number = tester.widget<RichText>(
        find.descendant(of: find.text('1'), matching: find.byType(RichText)),
      );
      expect(number.text.style!.fontSize, NebaTimelineItem.bulletSize[NebaSize.lg]! / 2);
      expect(tester.getCenter(find.text('1')), tester.getCenter(bullets().first));
    });

    testWidgets('reflects a changed title on rebuild', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTimeline(children: <Widget>[NebaTimelineItem(title: Text('Before'))]),
      );
      await pump(
        tester,
        const NebaTimeline(children: <Widget>[NebaTimelineItem(title: Text('After'))]),
      );

      expect(find.text('Before'), findsNothing);
      expect(find.text('After'), findsOneWidget);
    });
  });

  group('progress', () {
    testWidgets('leaves every step upcoming when active is not given', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaTimeline(children: steps()));

      expect(<String>['One', 'Two', 'Three'].map((String t) => statusOf(tester, t)), <String>[
        'Upcoming',
        'Upcoming',
        'Upcoming',
      ]);

      semantics.dispose();
    });

    testWidgets('splits the sequence around the active index, and finishes it past the end', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaTimeline(active: 1, children: steps()));
      expect(<String>['One', 'Two', 'Three'].map((String t) => statusOf(tester, t)), <String>[
        'Completed',
        'current',
        'Upcoming',
      ]);

      await pump(tester, NebaTimeline(active: 3, children: steps()));
      expect(<String>['One', 'Two', 'Three'].map((String t) => statusOf(tester, t)), <String>[
        'Completed',
        'Completed',
        'Completed',
      ]);

      semantics.dispose();
    });

    testWidgets('marks the current step selected, and no other', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaTimeline(active: 1, children: steps()));

      expect(
        stepOf(tester, 'Two'),
        matchesSemantics(label: 'Two', hasSelectedState: true, isSelected: true),
      );
      expect(stepOf(tester, 'One'), matchesSemantics(label: 'Completed\nOne'));

      semantics.dispose();
    });

    testWidgets('says the status in the language it was given, or in words of its own', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      registerNebaMessages('ko', ko);

      await pump(tester, NebaTimeline(active: 1, locale: const Locale('ko'), children: steps()));
      expect(statusOf(tester, 'One'), '완료');
      expect(statusOf(tester, 'Three'), '예정');

      await pump(
        tester,
        NebaTimeline(
          active: 1,
          labels: const <NebaTimelineStatus, String>{NebaTimelineStatus.complete: 'Done'},
          children: steps(),
        ),
      );
      expect(statusOf(tester, 'One'), 'Done');
      expect(statusOf(tester, 'Three'), 'Upcoming');

      semantics.dispose();
    });

    testWidgets('moves the current step when active changes', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaTimeline(active: 0, children: steps()));
      expect(statusOf(tester, 'One'), 'current');

      await pump(tester, NebaTimeline(active: 2, children: steps()));
      expect(statusOf(tester, 'One'), 'Completed');
      expect(statusOf(tester, 'Three'), 'current');

      semantics.dispose();
    });

    testWidgets('lets a step override what the index made of it', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaTimeline(
          active: 2,
          children: <Widget>[
            NebaTimelineItem(title: Text('One')),
            NebaTimelineItem(title: Text('Two'), status: NebaTimelineStatus.upcoming),
            NebaTimelineItem(title: Text('Three')),
          ],
        ),
      );

      expect(statusOf(tester, 'Two'), 'Upcoming');

      semantics.dispose();
    });

    testWidgets('counts only the steps that are on the screen', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaTimeline(
          active: 1,
          children: <Widget>[
            NebaShow(
              above: NebaBreakpoint.xl,
              child: NebaTimelineItem(title: Text('Hidden')),
            ),
            NebaTimelineItem(title: Text('One')),
            NebaTimelineItem(title: Text('Two')),
          ],
        ),
      );

      expect(statusOf(tester, 'One'), 'Completed');
      expect(statusOf(tester, 'Two'), 'current');

      semantics.dispose();
    });
  });

  group('the connector', () {
    testWidgets('draws a line after every step but the last', (WidgetTester tester) async {
      await pump(tester, NebaTimeline(children: steps()));

      expect(connectors(), findsNWidgets(2));
      // From the bottom of a bullet to the top of the next.
      final Rect first = tester.getRect(connectors().first);
      expect(first.top, tester.getRect(bullets().at(0)).bottom);
      expect(first.bottom, tester.getRect(bullets().at(1)).top);
      expect(first.center.dx, tester.getCenter(bullets().at(0)).dx);
    });

    testWidgets('takes the line away for NebaTimelineConnector.none', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTimeline(
          children: <Widget>[
            NebaTimelineItem(title: Text('One'), connector: NebaTimelineConnector.none),
            NebaTimelineItem(title: Text('Two')),
            NebaTimelineItem(title: Text('Three')),
          ],
        ),
      );

      expect(connectors(), findsOneWidget);
    });

    testWidgets('draws it in one stroke, or in dashes or dots', (WidgetTester tester) async {
      Future<void> withConnector(NebaTimelineConnector connector) {
        return pump(
          tester,
          NebaTimeline(
            children: <Widget>[
              NebaTimelineItem(title: const Text('One'), connector: connector),
              const NebaTimelineItem(title: Text('Two')),
            ],
          ),
        );
      }

      await withConnector(NebaTimelineConnector.solid);
      expect(tester.renderObject(connectors()), paintsExactlyCountTimes(#drawLine, 1));

      await withConnector(NebaTimelineConnector.dashed);
      final double length = tester.getSize(connectors()).height;
      // Dashes six pixels long with about four between them.
      expect(
        tester.renderObject(connectors()),
        paintsExactlyCountTimes(#drawLine, ((length + 4) / 10).round()),
      );

      await withConnector(NebaTimelineConnector.dotted);
      expect(
        tester.renderObject(connectors()),
        paintsExactlyCountTimes(#drawLine, ((length + 2) / 4).round()),
      );
    });

    testWidgets('takes its colour from the step it leaves', (WidgetTester tester) async {
      await pump(tester, NebaTimeline(active: 1, children: steps()));
      await tester.pumpAndSettle();

      expect(tester.renderObject(connectors().at(0)), paints..line(color: primary.lineHover));
      expect(tester.renderObject(connectors().at(1)), paints..line(color: tokens.border));
    });
  });

  group('style', () {
    testWidgets('fills a reached bullet in the family, haloes the current one and rings the rest', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaTimeline(active: 1, children: steps()));
      await tester.pumpAndSettle();

      final List<NebaSheet> sheets = tester.widgetList<NebaSheet>(bullets()).toList();
      expect(sheets[0].fill, primary.fill);
      expect(sheets[1].fill, primary.fill);
      expect(sheets[2].fill, tokens.panel);

      final List<AnimatedContainer> boxes = tester
          .widgetList<AnimatedContainer>(
            find.ancestor(of: bullets(), matching: find.byType(AnimatedContainer)),
          )
          .toList();
      Border halo(int i) => (boxes[i].decoration! as BoxDecoration).border! as Border;
      Border ring(int i) => (boxes[i].foregroundDecoration! as BoxDecoration).border! as Border;

      expect(halo(1).top.color, primary.soft);
      expect(halo(1).top.strokeAlign, BorderSide.strokeAlignOutside);
      expect(halo(0).top.color.a, 0);
      expect(ring(2).top.color, primary.line);
      expect(ring(2).top.width, 2);
      expect(ring(0).top.color.a, 0);
    });

    testWidgets('draws the current title in the accent and a waiting one muted', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaTimeline(active: 1, children: steps()));
      await tester.pumpAndSettle();

      Color? inkOf(String text) => tester
          .widget<RichText>(find.descendant(of: find.text(text), matching: find.byType(RichText)))
          .text
          .style
          ?.color;

      expect(inkOf('One'), tokens.fg);
      expect(inkOf('Two'), primary.accent);
      expect(inkOf('Three'), tokens.mutedFg);
    });

    testWidgets('lets one step take a colour of its own', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTimeline(
          active: 0,
          children: <Widget>[
            NebaTimelineItem(title: Text('Failed'), color: NebaColor.danger),
            NebaTimelineItem(title: Text('Next')),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.widget<NebaSheet>(bullets().first).fill, tokens.roles(NebaColor.danger).fill);
    });

    testWidgets('changes the bullet with size', (WidgetTester tester) async {
      for (final NebaSize size in NebaSize.values) {
        await pump(tester, NebaTimeline(size: size, children: steps()));
        await tester.pumpAndSettle();

        expect(tester.getSize(bullets().first), Size.square(NebaTimelineItem.bulletSize[size]!));
      }
    });

    testWidgets('changes the space between steps with density, and not the bullet', (
      WidgetTester tester,
    ) async {
      Future<double> pitch(NebaDensity density) async {
        await pump(tester, NebaTimeline(density: density, children: steps()));
        await tester.pumpAndSettle();

        return tester.getRect(bullets().at(1)).top - tester.getRect(bullets().at(0)).top;
      }

      final double standard = await pitch(NebaDensity.standard);
      final double compact = await pitch(NebaDensity.compact);

      expect(
        standard - compact,
        NebaTimeline.itemGap[NebaDensity.standard]![NebaSize.md]! -
            NebaTimeline.itemGap[NebaDensity.compact]![NebaSize.md]!,
      );
      expect(
        tester.getSize(bullets().first),
        Size.square(NebaTimelineItem.bulletSize[NebaSize.md]!),
      );
    });

    testWidgets('lays the sequence out across when horizontal, from the end under RTL', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaTimeline(orientation: NebaOrientation.horizontal, children: steps()));

      final Rect first = tester.getRect(bullets().at(0));
      final Rect second = tester.getRect(bullets().at(1));
      expect(second.top, first.top);
      expect(second.left, greaterThan(first.right));
      // The line runs across from the first bullet to the second.
      expect(tester.getRect(connectors().first).left, first.right);
      expect(tester.getRect(connectors().first).right, second.left);

      await pump(
        tester,
        NebaTimeline(orientation: NebaOrientation.horizontal, children: steps()),
        textDirection: TextDirection.rtl,
      );
      expect(tester.getRect(bullets().at(1)).right, lessThan(tester.getRect(bullets().at(0)).left));
    });

    testWidgets('never applies a transform', (WidgetTester tester) async {
      await pump(tester, NebaTimeline(active: 1, children: steps()));

      expect(
        find.descendant(of: find.byType(NebaTimeline), matching: find.byType(Transform)),
        findsNothing,
      );
    });
  });

  group('identity', () {
    testWidgets('keeps a step’s state when another is put in front of it', (
      WidgetTester tester,
    ) async {
      probeStarts = 0;

      await pump(
        tester,
        const NebaTimeline(
          active: 0,
          children: <Widget>[NebaTimelineItem(key: ValueKey<String>('b'), child: _Probe())],
        ),
      );
      await pump(
        tester,
        // Not const, so the step is rebuilt as the second, with a line now.
        NebaTimeline(
          active: 0,
          children: const <Widget>[
            NebaTimelineItem(key: ValueKey<String>('a'), child: _Probe()),
            NebaTimelineItem(key: ValueKey<String>('b'), child: _Probe()),
          ],
        ),
      );

      expect(probeStarts, 2);
    });

    testWidgets('lays a step out on its own, outside a timeline', (WidgetTester tester) async {
      await pump(tester, const NebaTimelineItem(title: Text('Alone')));

      expect(find.text('Alone'), findsOneWidget);
      expect(connectors(), findsNothing);
    });
  });
}
