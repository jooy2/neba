// NebaCalendar: the suite the React package runs on Calendar, asked the way
// Flutter asks it — the sheet it builds, the semantics of its grid and what a
// press and a key do — rather than the classes and the ARIA it writes. The
// grid is the pickers' too, and its keys are tested here once.

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/calendar.dart';
import 'package:neba/src/internal/date.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);
  final DateTime july = DateTime(2026, 7);

  tearDown(() {
    resetNebaMessages();
    resetNebaDateNames();
  });

  Future<void> pump(
    WidgetTester tester,
    Widget calendar, {
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return tester.pumpWidget(host(Center(child: calendar), textDirection: textDirection));
  }

  Finder cell(String label) => find.bySemanticsLabel(label);

  SemanticsData dataOf(WidgetTester tester, String label) {
    return tester.getSemantics(cell(label)).getSemanticsData();
  }

  // A day cell's node: a button named by its whole date, chosen or not, and
  // focusable whether or not it can be chosen.
  Matcher dayCell(String label, {bool selected = false, bool enabled = true}) {
    return matchesSemantics(
      label: label,
      isButton: true,
      hasSelectedState: true,
      isSelected: selected,
      hasEnabledState: true,
      isEnabled: enabled,
      isFocusable: true,
      hasTapAction: enabled,
      hasFocusAction: true,
    );
  }

  // The focused cell is the one whose node holds the focus, found by where
  // that node is drawn.
  Rect? focused() => FocusManager.instance.primaryFocus?.rect;

  Future<void> focusCell(WidgetTester tester, String label) async {
    Focus.of(
      tester.element(find.descendant(of: cell(label), matching: find.byType(Stack)).first),
    ).requestFocus();
    await tester.pump();
    await tester.pump();
  }

  Color? fillOf(WidgetTester tester, String label) {
    final DecoratedBox box = tester.widget<DecoratedBox>(
      find.descendant(of: cell(label), matching: find.byType(DecoratedBox)).first,
    );

    return (box.decoration as BoxDecoration).color;
  }

  testWidgets('renders a month inline, as a table of days named in full', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await pump(tester, NebaCalendar(defaultMonth: july));

    expect(tester.getSemantics(find.bySemanticsLabel('July 2026').first), isNotNull);
    expect(dataOf(tester, 'Monday, July 27, 2026').role, SemanticsRole.none);
    expect(
      tester.getSemantics(cell('Monday, July 27, 2026')),
      matchesSemantics(
        label: 'Monday, July 27, 2026',
        isButton: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    // Seven column heads read by the weekday's whole name.
    expect(find.bySemanticsLabel('Sunday'), findsOneWidget);
    expect(find.text('Sun'), findsOneWidget);
    // No popup: nothing to open.
    expect(find.byType(Overlay), findsNothing);

    semantics.dispose();
  });

  group('its sheet', () {
    testWidgets('draws the popup sheet, padded for its size, and a shadow from elevation', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaCalendar(defaultMonth: july, size: NebaSize.sm, elevation: 2));

      final NebaSheet sheet = tester.widget<NebaSheet>(
        find.descendant(of: find.byType(NebaCalendarSheet), matching: find.byType(NebaSheet)).first,
      );

      expect(sheet.elevation, 2);
      expect(sheet.plate, NebaPlate.glass);
      expect(sheet.fill, tokens.panelPress);
      expect(sheet.edge, primary.line);
      expect(
        tester
            .widget<Padding>(
              find
                  .ancestor(of: find.byType(NebaCalendarGrid), matching: find.byType(Padding))
                  .first,
            )
            .padding,
        const EdgeInsets.all(8),
      );
    });

    testWidgets('keeps the shadow on a bare grid', (WidgetTester tester) async {
      await pump(tester, NebaCalendar(defaultMonth: july, bordered: false, elevation: 1));

      expect(find.byType(NebaCalendarSheet), findsNothing);
      expect(
        tester
            .widgetList<DecoratedBox>(find.byType(DecoratedBox))
            .any(
              (DecoratedBox box) =>
                  box.decoration is BoxDecoration &&
                  (box.decoration as BoxDecoration).boxShadow?.isNotEmpty == true,
            ),
        isTrue,
      );
    });

    testWidgets('is as tall as seven cells and a header at every view', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaCalendar(defaultMonth: july, bordered: false));

      final Size days = tester.getSize(find.byType(NebaCalendar));

      await tester.tap(find.text('July'));
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(NebaCalendar)).height, days.height);

      await tester.tap(find.text('2026'));
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(NebaCalendar)).height, days.height);
      // Seven 32-pixel rows under a 32-pixel header, six apart.
      expect(days.height, 32 * 8 + 6);
    });
  });

  testWidgets('keeps the focus in the calendar after a month is picked from the month grid', (
    WidgetTester tester,
  ) async {
    await pump(tester, NebaCalendar(defaultMonth: july));

    await tester.tap(find.text('July'));
    await tester.pumpAndSettle();
    await tester.tap(cell('November 2026'));
    await tester.pumpAndSettle();

    expect(focused(), tester.getRect(cell('Sunday, November 1, 2026')));
  });

  testWidgets('moves to the next day on the left arrow under RTL', (WidgetTester tester) async {
    await pump(tester, NebaCalendar(defaultMonth: july), textDirection: TextDirection.rtl);
    await focusCell(tester, 'Monday, July 27, 2026');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();

    expect(focused(), tester.getRect(cell('Tuesday, July 28, 2026')));

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();

    expect(focused(), tester.getRect(cell('Sunday, July 26, 2026')));
  });

  testWidgets('marks today, with a dot and with the word for it', (WidgetTester tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    final DateTime now = DateTime.now();
    final String label = NebaDateNames.english.write(NebaDateNames.english.fullDate, now);

    await pump(tester, const NebaCalendar());

    expect(dataOf(tester, label).hint, 'Today');
    expect(
      find.descendant(
        of: cell(label),
        matching: find.byWidgetPredicate(
          (Widget widget) =>
              widget is DecoratedBox &&
              (widget.decoration as BoxDecoration).shape == BoxShape.circle,
        ),
      ),
      findsOneWidget,
    );

    semantics.dispose();
  });

  group('header', () {
    testWidgets('names the month and year buttons by what they show', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaCalendar(defaultMonth: july));

      expect(
        tester.getSemantics(
          find.ancestor(of: find.text('July'), matching: find.byType(MergeSemantics)),
        ),
        matchesSemantics(
          label: 'July',
          hint: 'Choose a month',
          isButton: true,
          hasExpandedState: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(
        tester.getSemantics(
          find.ancestor(of: find.text('2026'), matching: find.byType(MergeSemantics)),
        ),
        matchesSemantics(
          label: '2026',
          hint: 'Choose a year',
          isButton: true,
          hasExpandedState: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(find.bySemanticsLabel('Previous month'), findsOneWidget);
      expect(find.bySemanticsLabel('Next month'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('names the grid by the month on screen, and says so again when it changes', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaCalendar(defaultMonth: july));

      // The table, and the live region that says it again.
      expect(find.bySemanticsLabel('July 2026'), findsNWidgets(2));

      await tester.tap(find.bySemanticsLabel('Next month'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('August 2026'), findsNWidgets(2));
      expect(find.text('August'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('names a month cell the way a month of a year is written', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaCalendar(defaultMonth: july));
      await tester.tap(find.text('July'));
      await tester.pumpAndSettle();

      expect(cell('November 2026'), findsOneWidget);
      expect(find.text('Nov'), findsOneWidget);
      expect(find.bySemanticsLabel('Previous year'), findsOneWidget);
    });

    testWidgets('pages the year grid twelve years at a time', (WidgetTester tester) async {
      await pump(tester, NebaCalendar(defaultMonth: july));
      await tester.tap(find.text('2026'));
      await tester.pumpAndSettle();

      expect(find.text('2016–2027'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Next years'));
      await tester.pumpAndSettle();

      expect(find.text('2028–2039'), findsOneWidget);

      // A year hands over to its months, and a month to its days.
      await tester.tap(cell('2030'));
      await tester.pumpAndSettle();
      await tester.tap(cell('March 2030'));
      await tester.pumpAndSettle();

      expect(cell('Friday, March 1, 2030'), findsOneWidget);
    });

    testWidgets('puts the year first where the language does', (WidgetTester tester) async {
      registerNebaDateNames(
        'ko',
        const NebaDateNames(
          months: <String>[
            '1월',
            '2월',
            '3월',
            '4월',
            '5월',
            '6월',
            '7월',
            '8월',
            '9월',
            '10월',
            '11월',
            '12월',
          ],
          shortMonths: <String>[
            '1월',
            '2월',
            '3월',
            '4월',
            '5월',
            '6월',
            '7월',
            '8월',
            '9월',
            '10월',
            '11월',
            '12월',
          ],
          weekdays: <String>['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'],
          shortWeekdays: <String>['월', '화', '수', '목', '금', '토', '일'],
          monthYear: '{year}년 {month}',
          fullDate: '{year}년 {month} {day}일 {weekday}',
        ),
      );

      await pump(tester, NebaCalendar(defaultMonth: july, locale: const Locale('ko')));

      expect(
        tester.getTopLeft(find.text('2026')).dx,
        lessThan(tester.getTopLeft(find.text('7월')).dx),
      );
      expect(cell('2026년 7월 27일 월요일'), findsOneWidget);
      // Korea starts its week on Sunday.
      expect(tester.getTopLeft(find.text('일')).dx, lessThan(tester.getTopLeft(find.text('월')).dx));
    });
  });

  group('week start', () {
    testWidgets('follows the locale, and weekStartsOn over it', (WidgetTester tester) async {
      await pump(tester, NebaCalendar(defaultMonth: july, locale: const Locale('en', 'GB')));

      expect(
        tester.getTopLeft(find.text('Mon')).dx,
        lessThan(tester.getTopLeft(find.text('Sun')).dx),
      );

      await pump(tester, NebaCalendar(defaultMonth: july, weekStartsOn: DateTime.saturday));

      expect(
        tester.getTopLeft(find.text('Sat')).dx,
        lessThan(tester.getTopLeft(find.text('Sun')).dx),
      );
      expect(
        tester.getTopLeft(find.text('Sun')).dx,
        lessThan(tester.getTopLeft(find.text('Mon')).dx),
      );
    });
  });

  group('single', () {
    testWidgets('reports the day that was pressed', (WidgetTester tester) async {
      DateTime? chosen;

      await pump(
        tester,
        NebaCalendar(defaultMonth: july, onValueChange: (DateTime? value) => chosen = value),
      );
      await tester.tap(cell('Monday, July 27, 2026'));
      await tester.pumpAndSettle();

      expect(chosen, DateTime(2026, 7, 27));
    });

    testWidgets('lights the day it is holding with the family fill', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaCalendar(defaultValue: DateTime(2026, 7, 27)));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(cell('Monday, July 27, 2026')),
        dayCell('Monday, July 27, 2026', selected: true),
      );
      expect(
        tester.getSemantics(cell('Tuesday, July 28, 2026')),
        dayCell('Tuesday, July 28, 2026', selected: false),
      );
      expect(fillOf(tester, 'Monday, July 27, 2026'), primary.fill);

      semantics.dispose();
    });

    testWidgets('opens on the month of its value', (WidgetTester tester) async {
      await pump(tester, NebaCalendar(defaultValue: DateTime(2019, 3, 14)));

      expect(find.text('March'), findsOneWidget);
      expect(find.text('2019'), findsOneWidget);
    });

    testWidgets('leaves a controlled value alone until the caller changes it', (
      WidgetTester tester,
    ) async {
      final List<DateTime?> reported = <DateTime?>[];

      await pump(tester, NebaCalendar(value: DateTime(2026, 7, 10), onValueChange: reported.add));
      await tester.tap(cell('Monday, July 27, 2026'));
      await tester.pumpAndSettle();

      expect(reported, <DateTime?>[DateTime(2026, 7, 27)]);
      expect(fillOf(tester, 'Friday, July 10, 2026'), primary.fill);
    });

    testWidgets('empties when the caller goes from a day to none', (WidgetTester tester) async {
      await pump(tester, NebaCalendar(value: DateTime(2026, 7, 10)));
      await pump(tester, NebaCalendar(defaultMonth: july));
      await tester.pumpAndSettle();

      expect(fillOf(tester, 'Friday, July 10, 2026'), isNot(primary.fill));
    });
  });

  group('multiple', () {
    testWidgets('collects the days that were pressed, and takes one back out', (
      WidgetTester tester,
    ) async {
      List<DateTime> held = <DateTime>[];

      await pump(
        tester,
        NebaCalendar.multiple(
          defaultMonth: july,
          onValueChange: (List<DateTime> value) => held = value,
        ),
      );
      await tester.tap(cell('Monday, July 6, 2026'));
      await tester.pump();
      await tester.tap(cell('Wednesday, July 8, 2026'));
      await tester.pump();

      expect(held, <DateTime>[DateTime(2026, 7, 6), DateTime(2026, 7, 8)]);

      await tester.tap(cell('Monday, July 6, 2026'));
      await tester.pump();

      expect(held, <DateTime>[DateTime(2026, 7, 8)]);
    });
  });

  group('range', () {
    testWidgets('fills the near end and then the far one, banding the days between', (
      WidgetTester tester,
    ) async {
      NebaCalendarRange? span;

      await pump(
        tester,
        NebaCalendar.range(
          defaultMonth: july,
          onValueChange: (NebaCalendarRange value) => span = value,
        ),
      );
      await tester.tap(cell('Monday, July 6, 2026'));
      await tester.pump();

      expect(span, NebaCalendarRange(start: DateTime(2026, 7, 6)));

      await tester.tap(cell('Friday, July 10, 2026'));
      await tester.pumpAndSettle();

      expect(span, NebaCalendarRange(start: DateTime(2026, 7, 6), end: DateTime(2026, 7, 10)));
      expect(fillOf(tester, 'Wednesday, July 8, 2026'), primary.soft);
      expect(fillOf(tester, 'Friday, July 10, 2026'), primary.fill);
    });

    testWidgets('starts again below the start rather than turning the span round', (
      WidgetTester tester,
    ) async {
      NebaCalendarRange? span;

      await pump(
        tester,
        NebaCalendar.range(
          defaultValue: NebaCalendarRange(start: DateTime(2026, 7, 10)),
          onValueChange: (NebaCalendarRange value) => span = value,
        ),
      );
      await tester.tap(cell('Monday, July 6, 2026'));
      await tester.pump();

      expect(span, NebaCalendarRange(start: DateTime(2026, 7, 6)));
    });

    testWidgets('starts a new span once one is finished', (WidgetTester tester) async {
      NebaCalendarRange? span;

      await pump(
        tester,
        NebaCalendar.range(
          defaultValue: NebaCalendarRange(start: DateTime(2026, 7, 6), end: DateTime(2026, 7, 10)),
          onValueChange: (NebaCalendarRange value) => span = value,
        ),
      );
      await tester.tap(cell('Monday, July 20, 2026'));
      await tester.pump();

      expect(span, NebaCalendarRange(start: DateTime(2026, 7, 20)));
    });
  });

  testWidgets('chooses a whole month at that granularity', (WidgetTester tester) async {
    DateTime? chosen;

    await pump(
      tester,
      NebaCalendar(
        defaultMonth: july,
        granularity: NebaDateGranularity.month,
        onValueChange: (DateTime? value) => chosen = value,
      ),
    );

    // It opens on the months, and has no day view to fall into.
    expect(find.text('Jul'), findsOneWidget);

    await tester.tap(cell('March 2026'));
    await tester.pumpAndSettle();

    expect(chosen, DateTime(2026, 3));
    expect(find.text('Mar'), findsOneWidget);
  });

  testWidgets('draws whatever renderDay returns in the cell', (WidgetTester tester) async {
    await pump(
      tester,
      NebaCalendar(
        defaultMonth: july,
        renderDay: (DateTime date) => date.day == 4 ? const Text('3') : null,
      ),
    );

    expect(
      find.descendant(of: cell('Saturday, July 4, 2026\n3'), matching: find.text('3')),
      findsOneWidget,
    );
  });

  testWidgets('marks days outside the bounds unavailable, and keeps them in place', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    DateTime? chosen;

    await pump(
      tester,
      NebaCalendar(
        defaultMonth: july,
        minDate: DateTime(2026, 7, 10),
        shouldDisableDate: (DateTime date) => date.weekday == DateTime.sunday,
        onValueChange: (DateTime? value) => chosen = value,
      ),
    );

    // Unavailable and still focusable, so the arrow keys never fall into a
    // hole.
    expect(
      tester.getSemantics(cell('Thursday, July 9, 2026')),
      dayCell('Thursday, July 9, 2026', enabled: false),
    );
    expect(
      tester.getSemantics(cell('Sunday, July 12, 2026')),
      dayCell('Sunday, July 12, 2026', enabled: false),
    );
    expect(tester.getSemantics(cell('Monday, July 13, 2026')), dayCell('Monday, July 13, 2026'));

    await tester.tap(cell('Thursday, July 9, 2026'));
    await tester.pump();

    expect(chosen, isNull);

    semantics.dispose();
  });

  testWidgets('leaves holes where the neighbouring months are not drawn', (
    WidgetTester tester,
  ) async {
    await pump(tester, NebaCalendar(defaultMonth: july, showOutsideDays: false));

    expect(cell('Tuesday, June 30, 2026'), findsNothing);
    expect(cell('Wednesday, July 1, 2026'), findsOneWidget);
  });

  group('keys', () {
    testWidgets('walk a day and a week, and follow into the next month', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaCalendar(defaultMonth: july));
      await focusCell(tester, 'Friday, July 31, 2026');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(find.text('August'), findsOneWidget);
      expect(focused(), tester.getRect(cell('Saturday, August 1, 2026')));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      expect(find.text('July'), findsOneWidget);
      expect(focused(), tester.getRect(cell('Saturday, July 25, 2026')));
    });

    testWidgets('take Home and End to the week’s ends', (WidgetTester tester) async {
      await pump(tester, NebaCalendar(defaultMonth: july));
      await focusCell(tester, 'Wednesday, July 15, 2026');

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();

      expect(focused(), tester.getRect(cell('Sunday, July 12, 2026')));

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();

      expect(focused(), tester.getRect(cell('Saturday, July 18, 2026')));
    });

    testWidgets('page a month, and a year with Shift', (WidgetTester tester) async {
      await pump(tester, NebaCalendar(defaultMonth: july));
      await focusCell(tester, 'Friday, July 31, 2026');

      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pumpAndSettle();

      // The 31st held to the last day September has.
      expect(focused(), tester.getRect(cell('Monday, August 31, 2026')));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();

      expect(find.text('2025'), findsOneWidget);
      expect(focused(), tester.getRect(cell('Sunday, August 31, 2025')));
    });

    testWidgets('choose the focused day with Enter', (WidgetTester tester) async {
      DateTime? chosen;

      await pump(
        tester,
        NebaCalendar(defaultMonth: july, onValueChange: (DateTime? value) => chosen = value),
      );
      await focusCell(tester, 'Wednesday, July 15, 2026');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(chosen, DateTime(2026, 7, 16));
    });

    testWidgets('move the month grid three across and a year a page', (WidgetTester tester) async {
      await pump(tester, NebaCalendar(defaultMonth: july, granularity: NebaDateGranularity.month));
      await focusCell(tester, 'July 2026');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      expect(focused(), tester.getRect(cell('October 2026')));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(find.text('2027'), findsOneWidget);
      expect(focused(), tester.getRect(cell('January 2027')));
    });

    testWidgets('leave one tab stop in the grid', (WidgetTester tester) async {
      await pump(tester, NebaCalendar(defaultValue: DateTime(2026, 7, 15)));

      final List<FocusNode> stops = FocusManager.instance.rootScope.traversalDescendants
          .where((FocusNode node) => node.debugLabel?.startsWith('NebaCalendar day') ?? false)
          .toList();

      expect(stops, hasLength(1));
      expect(stops.single.rect, tester.getRect(cell('Wednesday, July 15, 2026')));
    });
  });

  group('locale', () {
    testWidgets('names its steppers in the language it was given', (WidgetTester tester) async {
      registerNebaMessages('ko', ko);

      await pump(tester, NebaCalendar(defaultMonth: july, locale: const Locale('ko')));

      expect(find.bySemanticsLabel('이전 달'), findsOneWidget);
    });

    testWidgets('takes a label of its own over the locale, and keeps the rest', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaCalendar(
          defaultMonth: july,
          labels: const NebaPickerLabels(previousMonth: 'Back'),
        ),
      );

      expect(find.bySemanticsLabel('Back'), findsOneWidget);
      expect(find.bySemanticsLabel('Next month'), findsOneWidget);
    });
  });

  testWidgets('controls the month on screen', (WidgetTester tester) async {
    final List<DateTime> months = <DateTime>[];

    await pump(tester, NebaCalendar(month: july, onMonthChange: months.add));
    await tester.tap(find.bySemanticsLabel('Next month'));
    await tester.pumpAndSettle();

    expect(months, <DateTime>[DateTime(2026, 8)]);
    // The caller has not moved it.
    expect(find.text('July'), findsOneWidget);
  });
}
