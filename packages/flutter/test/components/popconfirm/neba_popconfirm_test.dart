// NebaPopconfirm: the suite the React package runs on Popconfirm, asked the
// way Flutter asks it — what is built, what a screen reader hears, which
// callback runs and when the bubble closes — rather than the elements and the
// classes it writes.

import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/floating.dart';
import 'package:neba/src/internal/glyphs.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Widget scene(Widget child) {
    return host(Overlay.wrap(child: Center(child: child)));
  }

  Widget trigger() => NebaButton(onPressed: () {}, child: const Text('Delete'));

  Future<void> raise(WidgetTester tester) async {
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
  }

  testWidgets('builds nothing until the trigger is pressed', (WidgetTester tester) async {
    await tester.pumpWidget(
      scene(NebaPopconfirm(trigger: trigger(), title: const Text('Delete this row?'))),
    );

    expect(find.text('Delete this row?'), findsNothing);

    await raise(tester);

    expect(find.text('Delete this row?'), findsOneWidget);
  });

  testWidgets('is a dialog named by its title, with the description read after it', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      scene(
        NebaPopconfirm(
          trigger: trigger(),
          title: const Text('Delete this row?'),
          description: const Text('It cannot be undone.'),
        ),
      ),
    );
    await raise(tester);

    final SemanticsNode bubble = tester.getSemantics(
      find.ancestor(of: find.byType(NebaFloatingSheet), matching: find.byType(Semantics)).first,
    );

    expect(bubble.getSemanticsData().role, SemanticsRole.dialog);
    expect(bubble.getSemanticsData().label, 'Delete this row?');
    // Named by itself, which is what makes the title its `aria-label` on the
    // web.
    expect(bubble, matchesSemantics(label: 'Delete this row?', namesRoute: true));
    expect(find.text('It cannot be undone.'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('calls onConfirm and closes', (WidgetTester tester) async {
    int confirmed = 0;

    await tester.pumpWidget(
      scene(
        NebaPopconfirm(
          trigger: trigger(),
          title: const Text('Delete this row?'),
          onConfirm: () => confirmed++,
        ),
      ),
    );
    await raise(tester);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(confirmed, 1);
    expect(find.text('Delete this row?'), findsNothing);
  });

  testWidgets('calls onCancel and closes', (WidgetTester tester) async {
    int cancelled = 0;
    int confirmed = 0;

    await tester.pumpWidget(
      scene(
        NebaPopconfirm(
          trigger: trigger(),
          title: const Text('Delete this row?'),
          onConfirm: () => confirmed++,
          onCancel: () => cancelled++,
        ),
      ),
    );
    await raise(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(cancelled, 1);
    expect(confirmed, 0);
    expect(find.text('Delete this row?'), findsNothing);
  });

  // Dismissing is walking away from the question, which is not the same act
  // as answering no: a caller that undoes something in onCancel would undo it
  // every time somebody pressed Escape.
  testWidgets('does not call onCancel when dismissed with Escape or a press outside', (
    WidgetTester tester,
  ) async {
    int cancelled = 0;

    await tester.pumpWidget(
      scene(
        NebaPopconfirm(
          trigger: trigger(),
          title: const Text('Delete this row?'),
          onCancel: () => cancelled++,
        ),
      ),
    );
    await raise(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('Delete this row?'), findsNothing);

    await raise(tester);
    await tester.tapAt(const Offset(10, 590));
    await tester.pumpAndSettle();

    expect(find.text('Delete this row?'), findsNothing);
    expect(cancelled, 0);
  });

  // A question that vanished before its answer landed is a question the
  // reader has no way to know was heard.
  testWidgets('stays open, its button busy, until an asynchronous onConfirm completes', (
    WidgetTester tester,
  ) async {
    final Completer<void> work = Completer<void>();

    await tester.pumpWidget(
      scene(
        NebaPopconfirm(
          trigger: trigger(),
          title: const Text('Delete this row?'),
          onConfirm: () => work.future,
        ),
      ),
    );
    await raise(tester);
    await tester.tap(find.text('Confirm'));
    await tester.pump();

    NebaButton confirm() {
      return tester.widget<NebaButton>(
        find.ancestor(of: find.text('Confirm'), matching: find.byType(NebaButton)),
      );
    }

    expect(find.text('Delete this row?'), findsOneWidget);
    expect(confirm().loading, isTrue);

    work.complete();
    await tester.pumpAndSettle();

    expect(find.text('Delete this row?'), findsNothing);
  });

  // A failure is the caller's error. The bubble stays open, the button is
  // ready to try again, and the error is left to the zone to report.
  testWidgets('stays open and ready again when onConfirm fails, without catching it', (
    WidgetTester tester,
  ) async {
    final List<Object> errors = <Object>[];

    await tester.pumpWidget(
      scene(
        NebaPopconfirm(
          trigger: trigger(),
          title: const Text('Delete this row?'),
          onConfirm: () => Future<void>.error(StateError('Failed')),
        ),
      ),
    );
    await raise(tester);
    await runZonedGuarded(() async {
      await tester.tap(find.text('Confirm'));
      await tester.pump();
    }, (Object error, StackTrace stack) => errors.add(error));
    await tester.pumpAndSettle();

    expect(errors.single, isA<StateError>());
    expect(find.text('Delete this row?'), findsOneWidget);
    expect(
      tester
          .widget<NebaButton>(
            find.ancestor(of: find.text('Confirm'), matching: find.byType(NebaButton)),
          )
          .loading,
      isFalse,
    );
  });

  testWidgets('takes its own labels and a description', (WidgetTester tester) async {
    await tester.pumpWidget(
      scene(
        NebaPopconfirm(
          trigger: trigger(),
          title: const Text('Delete this row?'),
          description: const Text('It cannot be brought back.'),
          confirmLabel: const Text('Delete it'),
          cancelLabel: const Text('Keep it'),
        ),
      ),
    );
    await raise(tester);

    expect(find.text('It cannot be brought back.'), findsOneWidget);
    expect(find.text('Delete it'), findsOneWidget);
    expect(find.text('Keep it'), findsOneWidget);
  });

  testWidgets('says the labels in the registered language', (WidgetTester tester) async {
    registerNebaMessages('ko', ko);

    await tester.pumpWidget(
      scene(
        NebaPopconfirm(trigger: trigger(), title: const Text('삭제할까요?'), locale: const Locale('ko')),
      ),
    );
    await raise(tester);

    expect(find.text('확인'), findsOneWidget);
    expect(find.text('취소'), findsOneWidget);
  });

  testWidgets('honours a controlled open', (WidgetTester tester) async {
    final List<bool> changes = <bool>[];

    await tester.pumpWidget(
      scene(
        NebaPopconfirm(
          trigger: trigger(),
          title: const Text('Delete this row?'),
          open: false,
          onOpenChange: changes.add,
        ),
      ),
    );
    await raise(tester);

    expect(changes, <bool>[true]);
    expect(find.text('Delete this row?'), findsNothing);
  });

  testWidgets('sits above its trigger by default', (WidgetTester tester) async {
    await tester.pumpWidget(
      scene(NebaPopconfirm(trigger: trigger(), title: const Text('Delete this row?'))),
    );
    await raise(tester);

    expect(
      tester.getRect(find.byType(NebaFloatingSheet)).bottom,
      lessThan(tester.getRect(find.text('Delete').first).top),
    );
  });

  testWidgets('is danger-coloured and small by default, and caps its width', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      scene(
        NebaPopconfirm(
          trigger: trigger(),
          title: const Text(
            'A question long enough to run past the widest the bubble gets, twice over at least.',
          ),
        ),
      ),
    );
    await raise(tester);

    final NebaFloatingSheet sheet = tester.widget<NebaFloatingSheet>(
      find.byType(NebaFloatingSheet),
    );
    final NebaButton confirm = tester.widget<NebaButton>(
      find.ancestor(of: find.text('Confirm'), matching: find.byType(NebaButton)),
    );
    final NebaButton cancel = tester.widget<NebaButton>(
      find.ancestor(of: find.text('Cancel'), matching: find.byType(NebaButton)),
    );

    expect(sheet.color, NebaColor.danger);
    expect(sheet.size, NebaSize.sm);
    expect(tester.getRect(find.byType(NebaFloatingSheet)).width, 280);
    expect(confirm.color, NebaColor.danger);
    expect(confirm.size, NebaSize.sm);
    expect(cancel.color, NebaColor.secondary);
    expect(cancel.variant, NebaVariant.text);
  });

  testWidgets('draws the severity mark of its family in the accent, hidden from a reader', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      scene(NebaPopconfirm(trigger: trigger(), title: const Text('Delete this row?'))),
    );
    await raise(tester);

    final Finder mark = find.byType(NebaGlyph);
    final NebaGlyph glyph = tester.widget<NebaGlyph>(mark);
    final Rect drawn = tester.getRect(mark);
    final double text = NebaScale.sheetBodyText[NebaSize.sm]!;

    expect(glyph.parts, NebaGlyphs.danger);
    expect(drawn.width, closeTo(text * 1.2, 0.01));
    expect(IconTheme.of(tester.element(mark)).color, tokens.roles(NebaColor.danger).accent);
    expect(find.ancestor(of: mark, matching: find.byType(ExcludeSemantics)), findsWidgets);
    // Beside the question, in the middle of its first line.
    expect(drawn.right, lessThan(tester.getRect(find.text('Delete this row?')).left));
    expect(
      drawn.center.dy - tester.getRect(find.text('Delete this row?')).top,
      closeTo(NebaScale.sheetBodyLeading[NebaSize.sm]! / 2, 1),
    );
  });

  testWidgets('draws a mark of its own, or none', (WidgetTester tester) async {
    await tester.pumpWidget(
      scene(
        NebaPopconfirm(
          trigger: trigger(),
          title: const Text('Publish?'),
          color: NebaColor.primary,
          icon: const SizedBox(key: Key('mark')),
        ),
      ),
    );
    await raise(tester);

    expect(find.byKey(const Key('mark')), findsOneWidget);
    expect(find.byType(NebaGlyph), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      scene(NebaPopconfirm(trigger: trigger(), title: const Text('Publish?'), showIcon: false)),
    );
    await raise(tester);

    expect(find.byType(NebaGlyph), findsNothing);
  });

  testWidgets('sets the title in the medium weight and the description muted', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      scene(
        NebaPopconfirm(
          trigger: trigger(),
          title: const Text('Delete this row?'),
          description: const Text('Gone for good.'),
        ),
      ),
    );
    await raise(tester);

    TextStyle styleOf(String text) {
      return tester
          .widget<RichText>(find.descendant(of: find.text(text), matching: find.byType(RichText)))
          .text
          .style!;
    }

    expect(styleOf('Delete this row?').fontWeight, FontWeight.w500);
    expect(styleOf('Delete this row?').color, tokens.fg);
    expect(styleOf('Gone for good.').color, tokens.mutedFg);
    expect(styleOf('Gone for good.').fontSize, NebaScale.sheetBodyText[NebaSize.sm]);
  });
}
