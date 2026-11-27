// NebaDateRangePicker: the suite the React package runs on DateRangePicker,
// asked the way Flutter asks it — the panels and the trigger it builds, what
// a screen reader hears and what a press, a pointer and a key do — rather
// than the grids, the classes and the ARIA it writes. The calendar's own
// keys and cells are tested with NebaCalendar.

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/calendar.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/notch.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);
  final DateTime july = DateTime(2026, 7);
  final NebaDateRange stay = NebaDateRange(start: DateTime(2026, 7, 3), end: DateTime(2026, 7, 9));

  Future<void> pump(WidgetTester tester, Widget picker) {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    return tester.pumpWidget(
      host(
        Overlay.wrap(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(padding: const EdgeInsets.all(40), child: picker),
          ),
        ),
        width: 1000,
        height: 900,
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byType(NebaFieldShell));
    await settle(tester);
  }

  Finder cell(String label) => find.bySemanticsLabel(label);

  Future<void> press(WidgetTester tester, String label) async {
    await tester.tap(cell(label));
    await settle(tester);
  }

  bool popupOpen() => find.byType(NebaCalendarGrid).evaluate().isNotEmpty;

  // The fill a day is drawn on: the band's wash inside a range, the family's
  // fill at its ends, and nothing at all outside it.
  Color? fillOf(WidgetTester tester, String label) {
    final DecoratedBox box = tester.widget<DecoratedBox>(
      find.descendant(of: cell(label), matching: find.byType(DecoratedBox)).first,
    );

    return (box.decoration as BoxDecoration).color;
  }

  bool inBand(WidgetTester tester, String label) => fillOf(tester, label) == primary.soft;

  Matcher dayCell(
    String label, {
    bool selected = false,
    bool enabled = true,
    bool focused = false,
  }) {
    return matchesSemantics(
      label: label,
      isFocused: focused,
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

  Future<TestGesture> hover(WidgetTester tester, String label) async {
    final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(tester.getCenter(cell(label)));
    await settle(tester);

    return gesture;
  }

  group('rendering', () {
    testWidgets('is a button named by its label that says the range it holds', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaDateRangePicker(label: const Text('Stay'), defaultValue: stay));

      expect(
        tester.getSemantics(find.byType(NebaFieldWidth).first),
        matchesSemantics(
          label: 'Stay',
          value: 'Jul 3, 2026 – Jul 9, 2026',
          isButton: true,
          hasExpandedState: true,
          isFocusable: true,
          isEnabled: true,
          hasEnabledState: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
    });

    testWidgets('shows a muted placeholder for each end while it is unchosen', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaDateRangePicker(
          startPlaceholder: Text('Check in'),
          endPlaceholder: Text('Check out'),
        ),
      );

      expect(find.text('Check in'), findsOneWidget);
      expect(find.text('Check out'), findsOneWidget);
      expect(
        DefaultTextStyle.of(tester.element(find.text('Check in'))).style.color,
        tokens.mutedFg,
      );
    });

    testWidgets('writes both ends when it has them, or by a format', (WidgetTester tester) async {
      await pump(tester, NebaDateRangePicker(defaultValue: stay));

      expect(find.text('Jul 3, 2026'), findsOneWidget);
      expect(find.text('Jul 9, 2026'), findsOneWidget);

      await pump(
        tester,
        NebaDateRangePicker(
          key: const Key('format'),
          defaultValue: stay,
          format: (DateTime date) => '${date.day}/${date.month}',
        ),
      );

      expect(find.text('3/7'), findsOneWidget);
      expect(find.text('9/7'), findsOneWidget);
    });

    testWidgets('opens two months side by side, with no day in both', (WidgetTester tester) async {
      await pump(tester, NebaDateRangePicker(defaultMonth: july));
      await open(tester);

      expect(find.byType(NebaCalendarGrid), findsNWidgets(2));
      expect(cell('Saturday, August 1, 2026'), findsOneWidget);
      expect(find.bySemanticsLabel('Next month'), findsOneWidget);
      expect(find.bySemanticsLabel('Previous month'), findsOneWidget);
    });

    testWidgets('opens one month when asked for one', (WidgetTester tester) async {
      await pump(tester, NebaDateRangePicker(defaultMonth: july, monthCount: 1));
      await open(tester);

      expect(find.byType(NebaCalendarGrid), findsOneWidget);
      expect(find.bySemanticsLabel('Next month'), findsOneWidget);
    });

    testWidgets('holds each end at one width whatever it holds', (WidgetTester tester) async {
      Finder shell() => find.byType(NebaFieldShell);

      await pump(
        tester,
        NebaDateRangePicker(
          defaultValue: NebaDateRange(start: DateTime(2026, 5, 1), end: DateTime(2026, 5, 2)),
        ),
      );
      final double short = tester.getSize(shell()).width;
      final double arrow = tester.getCenter(find.byType(RotatedBox).first).dx;

      await pump(
        tester,
        NebaDateRangePicker(
          key: const Key('long'),
          defaultValue: NebaDateRange(start: DateTime(2026, 9, 28), end: DateTime(2026, 9, 30)),
        ),
      );

      expect(tester.getSize(shell()).width, short);
      expect(tester.getCenter(find.byType(RotatedBox).first).dx, arrow);
    });
  });

  group('choosing a range', () {
    testWidgets('takes the two ends in two presses and closes', (WidgetTester tester) async {
      final List<NebaDateRange> reported = <NebaDateRange>[];

      await pump(tester, NebaDateRangePicker(defaultMonth: july, onValueChange: reported.add));
      await open(tester);
      await press(tester, 'Friday, July 3, 2026');

      // Half a range is the picker's own business: nothing is reported yet,
      // and the footer says which end comes next.
      expect(reported, isEmpty);
      expect(popupOpen(), isTrue);
      expect(find.text('End'), findsOneWidget);

      await press(tester, 'Thursday, July 9, 2026');

      expect(reported, <NebaDateRange>[stay]);
      expect(popupOpen(), isFalse);
    });

    testWidgets('starts a new range at a day before the start', (WidgetTester tester) async {
      final List<NebaDateRange> reported = <NebaDateRange>[];

      await pump(tester, NebaDateRangePicker(defaultMonth: july, onValueChange: reported.add));
      await open(tester);
      await press(tester, 'Thursday, July 9, 2026');
      await press(tester, 'Friday, July 3, 2026');

      expect(reported, isEmpty);
      expect(popupOpen(), isTrue);

      await press(tester, 'Tuesday, July 7, 2026');

      expect(reported, <NebaDateRange>[
        NebaDateRange(start: DateTime(2026, 7, 3), end: DateTime(2026, 7, 7)),
      ]);
    });

    testWidgets('spans the two months on screen', (WidgetTester tester) async {
      final List<NebaDateRange> reported = <NebaDateRange>[];

      await pump(tester, NebaDateRangePicker(defaultMonth: july, onValueChange: reported.add));
      await open(tester);
      await press(tester, 'Monday, July 27, 2026');
      await press(tester, 'Monday, August 3, 2026');

      expect(reported, <NebaDateRange>[
        NebaDateRange(start: DateTime(2026, 7, 27), end: DateTime(2026, 8, 3)),
      ]);
    });

    testWidgets('marks both ends as chosen and bands the days between', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaDateRangePicker(defaultMonth: july, defaultValue: stay));
      await open(tester);

      expect(
        tester.getSemantics(cell('Friday, July 3, 2026')),
        dayCell('Friday, July 3, 2026', selected: true, focused: true),
      );
      expect(
        tester.getSemantics(cell('Thursday, July 9, 2026')),
        dayCell('Thursday, July 9, 2026', selected: true),
      );
      expect(tester.getSemantics(cell('Monday, July 6, 2026')), dayCell('Monday, July 6, 2026'));
      expect(inBand(tester, 'Monday, July 6, 2026'), isTrue);
      expect(fillOf(tester, 'Friday, July 3, 2026'), primary.fill);
    });

    testWidgets('starts a new range on the press after a finished one', (
      WidgetTester tester,
    ) async {
      final List<NebaDateRange> reported = <NebaDateRange>[];

      await pump(
        tester,
        NebaDateRangePicker(
          defaultMonth: july,
          defaultValue: stay,
          closeOnSelect: false,
          onValueChange: reported.add,
        ),
      );
      await open(tester);
      await press(tester, 'Monday, July 20, 2026');

      expect(reported, isEmpty);

      await press(tester, 'Wednesday, July 22, 2026');

      expect(reported, <NebaDateRange>[
        NebaDateRange(start: DateTime(2026, 7, 20), end: DateTime(2026, 7, 22)),
      ]);
      expect(popupOpen(), isTrue);
    });

    testWidgets('keeps the previous range when the popup closes after one press', (
      WidgetTester tester,
    ) async {
      final List<NebaDateRange> reported = <NebaDateRange>[];

      await pump(
        tester,
        NebaDateRangePicker(defaultMonth: july, defaultValue: stay, onValueChange: reported.add),
      );
      await open(tester);
      await press(tester, 'Monday, July 20, 2026');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);

      expect(popupOpen(), isFalse);
      expect(reported, isEmpty);
      expect(find.text('Jul 3, 2026'), findsOneWidget);
      expect(find.text('Jul 9, 2026'), findsOneWidget);

      // And the half range is gone: the next press starts afresh.
      await open(tester);
      expect(find.text('End'), findsNothing);
    });

    testWidgets('moves the pair with either header', (WidgetTester tester) async {
      await pump(tester, NebaDateRangePicker(defaultMonth: july));
      await open(tester);
      await tester.tap(find.bySemanticsLabel('Next month'));
      await settle(tester);

      expect(cell('Monday, September 14, 2026'), findsOneWidget);
      expect(cell('Monday, August 3, 2026'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Previous month'));
      await settle(tester);

      expect(cell('Friday, July 3, 2026'), findsOneWidget);
    });
  });

  group('the band under the pointer', () {
    testWidgets('follows the pointer from the first press, and starts again at a new one', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaDateRangePicker(defaultMonth: july));
      await open(tester);
      await press(tester, 'Friday, July 3, 2026');
      final TestGesture pointer = await hover(tester, 'Thursday, July 9, 2026');

      expect(inBand(tester, 'Monday, July 6, 2026'), isTrue);
      expect(inBand(tester, 'Sunday, July 12, 2026'), isFalse);

      // Before the start, so a new start: the band is the new press alone.
      await pointer.moveTo(tester.getCenter(cell('Wednesday, July 1, 2026')));
      await tester.tap(cell('Wednesday, July 1, 2026'));
      await settle(tester);

      expect(inBand(tester, 'Monday, July 6, 2026'), isFalse);
      expect(inBand(tester, 'Thursday, July 2, 2026'), isFalse);
    });

    testWidgets('reaches across into the second month', (WidgetTester tester) async {
      await pump(tester, NebaDateRangePicker(defaultMonth: july));
      await open(tester);
      await press(tester, 'Friday, July 3, 2026');
      await hover(tester, 'Monday, August 3, 2026');

      expect(inBand(tester, 'Friday, July 31, 2026'), isTrue);
      expect(inBand(tester, 'Saturday, August 1, 2026'), isTrue);
    });

    testWidgets('does not ask shouldDisableDate again as the pointer moves', (
      WidgetTester tester,
    ) async {
      int asked = 0;

      await pump(
        tester,
        NebaDateRangePicker(
          defaultMonth: july,
          shouldDisableDate: (DateTime date) {
            asked++;
            return false;
          },
        ),
      );
      await open(tester);
      await press(tester, 'Friday, July 3, 2026');
      final TestGesture pointer = await hover(tester, 'Thursday, July 9, 2026');
      asked = 0;

      await pointer.moveTo(tester.getCenter(cell('Monday, August 3, 2026')));
      await settle(tester);

      expect(inBand(tester, 'Friday, July 31, 2026'), isTrue);
      expect(asked, 0);
    });
  });

  group('presets', () {
    testWidgets('applies a preset and closes', (WidgetTester tester) async {
      final List<NebaDateRange> reported = <NebaDateRange>[];
      final NebaDateRange firstWeek = NebaDateRange(
        start: DateTime(2026, 7, 1),
        end: DateTime(2026, 7, 7),
      );

      await pump(
        tester,
        NebaDateRangePicker(
          defaultMonth: july,
          onValueChange: reported.add,
          presets: <NebaDateRangePreset>[
            NebaDateRangePreset(label: const Text('First week'), value: firstWeek),
          ],
        ),
      );
      await open(tester);
      await tester.tap(find.text('First week'));
      await settle(tester);

      expect(reported, <NebaDateRange>[firstWeek]);
      expect(popupOpen(), isFalse);
    });

    testWidgets('works a computed preset out when it is pressed', (WidgetTester tester) async {
      final List<NebaDateRange> reported = <NebaDateRange>[];
      int built = 0;

      await pump(
        tester,
        NebaDateRangePicker(
          defaultMonth: july,
          onValueChange: reported.add,
          presets: <NebaDateRangePreset>[
            NebaDateRangePreset.computed(
              label: const Text('Last 7 days'),
              value: () {
                built++;
                return NebaDateRange(start: DateTime(2026, 7, 1), end: DateTime(2026, 7, 7));
              },
            ),
          ],
        ),
      );
      await open(tester);

      expect(built, 0);

      await tester.tap(find.text('Last 7 days'));
      await settle(tester);

      expect(built, 1);
      expect(reported, hasLength(1));
    });

    testWidgets('rules the presets off from the calendars, as tall as they are', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaDateRangePicker(
          defaultMonth: july,
          presets: <NebaDateRangePreset>[
            NebaDateRangePreset(label: const Text('Stay'), value: stay),
          ],
        ),
      );
      await open(tester);

      // The column the presets stand in, ruled off at its end.
      final Finder column = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).border is BorderDirectional,
      );
      final Rect presets = tester.getRect(column);
      final Rect calendar = tester.getRect(find.byType(NebaCalendarGrid).first);

      expect(presets.top, calendar.top);
      expect(presets.height, 256);
      expect(presets.right, lessThanOrEqualTo(calendar.left));
    });
  });

  group('states', () {
    testWidgets('marks days outside the bounds unavailable in both panels', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaDateRangePicker(
          defaultMonth: july,
          minDate: DateTime(2026, 7, 10),
          maxDate: DateTime(2026, 8, 5),
        ),
      );
      await open(tester);

      expect(
        tester.getSemantics(cell('Friday, July 3, 2026')),
        dayCell('Friday, July 3, 2026', enabled: false),
      );
      expect(
        tester.getSemantics(cell('Monday, August 10, 2026')),
        dayCell('Monday, August 10, 2026', enabled: false),
      );
      expect(tester.getSemantics(cell('Monday, July 20, 2026')), dayCell('Monday, July 20, 2026'));
    });

    testWidgets('empties both ends through the ×', (WidgetTester tester) async {
      final List<NebaDateRange> reported = <NebaDateRange>[];

      await pump(
        tester,
        NebaDateRangePicker(
          startPlaceholder: const Text('Check in'),
          defaultValue: stay,
          clearable: true,
          onValueChange: reported.add,
        ),
      );
      await tester.tap(find.bySemanticsLabel('Clear'));
      await settle(tester);

      expect(reported, <NebaDateRange>[const NebaDateRange()]);
      expect(find.text('Check in'), findsOneWidget);
      expect(popupOpen(), isFalse);
    });

    testWidgets('empties both ends from the footer, and closes', (WidgetTester tester) async {
      final List<NebaDateRange> reported = <NebaDateRange>[];

      await pump(
        tester,
        NebaDateRangePicker(defaultValue: stay, clearable: true, onValueChange: reported.add),
      );
      await open(tester);
      await tester.tap(find.text('Clear'));
      await settle(tester);

      expect(reported, <NebaDateRange>[const NebaDateRange()]);
      expect(popupOpen(), isFalse);
    });

    testWidgets('says in the footer which end comes next', (WidgetTester tester) async {
      await pump(tester, NebaDateRangePicker(defaultMonth: july));
      await open(tester);

      expect(find.text('Start'), findsOneWidget);

      await press(tester, 'Friday, July 3, 2026');

      expect(find.text('Start'), findsNothing);
      expect(find.text('End'), findsOneWidget);
    });

    testWidgets('does not open when read-only', (WidgetTester tester) async {
      await pump(tester, NebaDateRangePicker(defaultValue: stay, readOnly: true));
      await tester.tap(find.byType(NebaFieldShell));
      await settle(tester);

      expect(popupOpen(), isFalse);
    });
  });

  group('label placement', () {
    testWidgets('names the trigger from a notched label', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaDateRangePicker(labelPlacement: NebaLabelPlacement.notch, label: Text('Stay')),
      );

      expect(find.byType(NebaNotch), findsOneWidget);
      expect(tester.getSemantics(find.byType(NebaFieldWidth).first).label, 'Stay');
    });

    testWidgets('lets a floating label stand in for both placeholders until an end is chosen', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaDateRangePicker(
          labelPlacement: NebaLabelPlacement.float,
          label: Text('Stay'),
          startPlaceholder: Text('Check in'),
          endPlaceholder: Text('Check out'),
          showStartIcon: false,
        ),
      );
      await settle(tester);

      expect(tester.widget<NebaNotch>(find.byType(NebaNotch)).resting, isTrue);
      expect(
        DefaultTextStyle.of(tester.element(find.text('Check in'))).style.color,
        tokens.mutedFg.withValues(alpha: 0),
      );
    });
  });
}
