// NebaConfirmProvider and NebaConfirm: the suite the React package runs on
// ConfirmProvider and useConfirm. A confirm is a question that returns an
// answer, so almost everything worth testing is about the future: that it
// completes, that it completes with what the reader pressed, and that nothing
// but a person completes it while the provider is there to ask.

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

void main() {
  /// A button that asks [options] when pressed and hands the answer to
  /// [onAnswer].
  Widget asker(ValueChanged<bool> onAnswer, {NebaConfirmOptions? options, FocusNode? focusNode}) {
    return Builder(
      builder: (BuildContext context) {
        return NebaButton(
          focusNode: focusNode,
          onPressed: () async {
            onAnswer(
              await NebaConfirmProvider.of(context)(
                options ?? const NebaConfirmOptions(title: Text('Delete the project?')),
              ),
            );
          },
          child: const Text('Delete'),
        );
      },
    );
  }

  Widget scene(Widget child, {NebaConfirmOptions defaults = const NebaConfirmOptions()}) {
    return host(
      NebaConfirmProvider(
        defaults: defaults,
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    );
  }

  Future<void> ask(WidgetTester tester) async {
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
  }

  group('asking', () {
    testWidgets('asks the question it was given, as an alert dialog', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(scene(asker((bool _) {})));
      await ask(tester);

      expect(find.text('Delete the project?'), findsOneWidget);
      expect(
        tester
            .getSemantics(
              find
                  .ancestor(of: find.text('Delete the project?'), matching: find.byType(FocusScope))
                  .first,
            )
            .getSemanticsData()
            .role,
        SemanticsRole.alertDialog,
      );
      semantics.dispose();
    });

    testWidgets('answers true when confirmed', (WidgetTester tester) async {
      final List<bool> answers = <bool>[];

      await tester.pumpWidget(scene(asker(answers.add)));
      await ask(tester);
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(answers, <bool>[true]);
      expect(find.text('Delete the project?'), findsNothing);
    });

    testWidgets('answers false when cancelled', (WidgetTester tester) async {
      final List<bool> answers = <bool>[];

      await tester.pumpWidget(scene(asker(answers.add)));
      await ask(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(answers, <bool>[false]);
    });

    testWidgets('answers false on Escape and on a press outside the sheet', (
      WidgetTester tester,
    ) async {
      final List<bool> answers = <bool>[];

      await tester.pumpWidget(scene(asker(answers.add)));
      await ask(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await ask(tester);
      await tester.tapAt(const Offset(20, 580));
      await tester.pumpAndSettle();

      expect(answers, <bool>[false, false]);
    });

    testWidgets('answers true when an alert is dismissed with Escape', (WidgetTester tester) async {
      final List<bool> answers = <bool>[];

      await tester.pumpWidget(
        scene(
          asker(
            answers.add,
            options: const NebaConfirmOptions(title: Text('Your export is ready.'), alert: true),
          ),
        ),
      );
      await ask(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(answers, <bool>[true]);
    });

    testWidgets('stays up on Escape and outside when it is not dismissible', (
      WidgetTester tester,
    ) async {
      final List<bool> answers = <bool>[];

      await tester.pumpWidget(
        scene(
          asker(
            answers.add,
            options: const NebaConfirmOptions(title: Text('Discard it?'), dismissible: false),
          ),
        ),
      );
      await ask(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.tapAt(const Offset(20, 580));
      await tester.pumpAndSettle();

      expect(find.text('Discard it?'), findsOneWidget);
      expect(answers, isEmpty);
    });

    testWidgets('drops the cancelling button for an alert, and still answers', (
      WidgetTester tester,
    ) async {
      final List<bool> answers = <bool>[];

      await tester.pumpWidget(
        scene(
          asker(
            answers.add,
            options: const NebaConfirmOptions(title: Text('Your export is ready.'), alert: true),
          ),
        ),
      );
      await ask(tester);

      expect(find.text('Cancel'), findsNothing);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(answers, <bool>[true]);
    });

    testWidgets('takes a description and labels of its own', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          asker(
            (bool _) {},
            options: const NebaConfirmOptions(
              title: Text('Delete the project?'),
              description: Text('Everything in it goes too.'),
              confirmLabel: Text('Delete it'),
              cancelLabel: Text('Keep it'),
            ),
          ),
        ),
      );
      await ask(tester);

      expect(find.text('Everything in it goes too.'), findsOneWidget);
      expect(find.text('Delete it'), findsOneWidget);
      expect(find.text('Keep it'), findsOneWidget);
    });

    testWidgets('dresses the confirming button and the sheet in its colour', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          asker(
            (bool _) {},
            options: const NebaConfirmOptions(title: Text('Delete?'), color: NebaColor.danger),
          ),
        ),
      );
      await ask(tester);

      final NebaButton confirm = tester.widget<NebaButton>(
        find.ancestor(of: find.text('Confirm'), matching: find.byType(NebaButton)),
      );
      final NebaButton cancel = tester.widget<NebaButton>(
        find.ancestor(of: find.text('Cancel'), matching: find.byType(NebaButton)),
      );
      final NebaDialog dialog = tester.widget<NebaDialog>(find.byType(NebaDialog));

      expect(confirm.color, NebaColor.danger);
      expect(confirm.variant, NebaVariant.solid);
      expect(cancel.color, NebaColor.secondary);
      expect(cancel.variant, NebaVariant.text);
      expect(dialog.color, NebaColor.danger);
      expect(dialog.size, NebaSize.sm);
      expect(dialog.showClose, isFalse);
    });

    testWidgets('takes its defaults from the provider, and lets a call override them', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          asker(
            (bool _) {},
            options: const NebaConfirmOptions(title: Text('Go?'), size: NebaSize.lg),
          ),
          defaults: const NebaConfirmOptions(
            confirmLabel: Text('Yes please'),
            size: NebaSize.md,
            width: 300,
          ),
        ),
      );
      await ask(tester);

      final NebaDialog dialog = tester.widget<NebaDialog>(find.byType(NebaDialog));

      expect(find.text('Yes please'), findsOneWidget);
      expect(dialog.size, NebaSize.lg);
      expect(dialog.width, 300);
    });

    testWidgets('says the labels in the registered language', (WidgetTester tester) async {
      registerNebaMessages('ko', ko);

      await tester.pumpWidget(
        scene(asker((bool _) {}), defaults: const NebaConfirmOptions(locale: Locale('ko'))),
      );
      await ask(tester);

      expect(find.text('확인'), findsOneWidget);
      expect(find.text('취소'), findsOneWidget);
    });
  });

  group('focus', () {
    testWidgets('opens on the confirming button', (WidgetTester tester) async {
      await tester.pumpWidget(scene(asker((bool _) {})));
      await ask(tester);

      expect(_focused(tester, 'Confirm'), isTrue);
    });

    // Enter asked the question; a second Enter on the confirming button would
    // be the loss, with no moment in between to read what was asked.
    testWidgets('opens a destructive question on the button that destroys nothing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          asker(
            (bool _) {},
            options: const NebaConfirmOptions(title: Text('Delete?'), color: NebaColor.danger),
          ),
        ),
      );
      await ask(tester);

      expect(_focused(tester, 'Cancel'), isTrue);
    });

    testWidgets('gives the focus back to what asked once the question is answered', (
      WidgetTester tester,
    ) async {
      final FocusNode delete = FocusNode(debugLabel: 'delete');
      addTearDown(delete.dispose);
      final List<bool> answers = <bool>[];

      await tester.pumpWidget(scene(asker(answers.add, focusNode: delete)));
      delete.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(_focused(tester, 'Confirm'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(answers, <bool>[true]);
      expect(delete.hasFocus, isTrue);
    });
  });

  group('the queue', () {
    // Answering the older question false to make room reports an answer
    // nobody gave, and at the call site that reads as "they said no".
    testWidgets('queues a second question rather than answering it', (WidgetTester tester) async {
      final List<String> answers = <String>[];

      await tester.pumpWidget(
        scene(
          Builder(
            builder: (BuildContext context) {
              return NebaButton(
                onPressed: () {
                  final NebaConfirm confirm = NebaConfirmProvider.of(context);

                  confirm(
                    const NebaConfirmOptions(title: Text('First?')),
                  ).then((bool answer) => answers.add('first:$answer'));
                  confirm(
                    const NebaConfirmOptions(title: Text('Second?')),
                  ).then((bool answer) => answers.add('second:$answer'));
                },
                child: const Text('Ask'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Ask'));
      await tester.pumpAndSettle();

      expect(find.text('First?'), findsOneWidget);
      expect(find.text('Second?'), findsNothing);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('Second?'), findsOneWidget);
      expect(answers, <String>['first:true']);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(answers, <String>['first:true', 'second:false']);
      expect(find.text('Second?'), findsNothing);
    });

    // The second question took over the open sheet, so it never opened: the
    // focus stayed where the first question put it.
    testWidgets('opens a queued destructive question on the button that destroys nothing', (
      WidgetTester tester,
    ) async {
      final FocusNode ask = FocusNode(debugLabel: 'ask');
      addTearDown(ask.dispose);

      await tester.pumpWidget(
        scene(
          Builder(
            builder: (BuildContext context) {
              return NebaButton(
                focusNode: ask,
                onPressed: () {
                  final NebaConfirm confirm = NebaConfirmProvider.of(context);

                  confirm(const NebaConfirmOptions(title: Text('Publish?')));
                  confirm(
                    const NebaConfirmOptions(
                      title: Text('Delete the draft?'),
                      color: NebaColor.danger,
                    ),
                  );
                },
                child: const Text('Ask'),
              );
            },
          ),
        ),
      );
      ask.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.text('Publish?'), findsOneWidget);
      expect(_focused(tester, 'Confirm'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.text('Delete the draft?'), findsOneWidget);
      expect(_focused(tester, 'Cancel'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // And home again once the last question is answered.
      expect(find.text('Delete the draft?'), findsNothing);
      expect(ask.hasFocus, isTrue);
    });

    testWidgets('keeps a question asked as the screen is built waiting', (
      WidgetTester tester,
    ) async {
      final List<bool> answers = <bool>[];

      await tester.pumpWidget(scene(_AskOnMount(onAnswer: answers.add)));
      await tester.pumpAndSettle();

      expect(find.text('Keep the draft?'), findsOneWidget);
      expect(answers, isEmpty);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(answers, <bool>[true]);
    });

    // The queue went with the provider, and every `await` still in it waited
    // for ever.
    testWidgets('answers every waiting question false when the provider leaves', (
      WidgetTester tester,
    ) async {
      final List<String> answers = <String>[];
      NebaConfirm? kept;

      await tester.pumpWidget(
        scene(
          Builder(
            builder: (BuildContext context) {
              return NebaButton(
                onPressed: () {
                  final NebaConfirm confirm = NebaConfirmProvider.of(context);
                  kept = confirm;

                  confirm(
                    const NebaConfirmOptions(title: Text('First?')),
                  ).then((bool answer) => answers.add('first:$answer'));
                  confirm(
                    const NebaConfirmOptions(title: Text('Second?')),
                  ).then((bool answer) => answers.add('second:$answer'));
                },
                child: const Text('Ask'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Ask'));
      await tester.pumpAndSettle();

      expect(find.text('First?'), findsOneWidget);

      await tester.pumpWidget(host(const SizedBox()));
      await tester.pump();

      expect(answers, <String>['first:false', 'second:false']);
      // And a question asked of a provider that is gone is answered at once.
      expect(await kept!(const NebaConfirmOptions(title: Text('Third?'))), isFalse);
    });

    testWidgets('keeps the words on the sheet while it fades out', (WidgetTester tester) async {
      await tester.pumpWidget(scene(asker((bool _) {})));
      await ask(tester);
      await tester.tap(find.text('Confirm'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));

      expect(find.text('Delete the project?'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Delete the project?'), findsNothing);
    });
  });

  testWidgets('tells a caller that forgot the provider', (WidgetTester tester) async {
    late BuildContext context;

    await tester.pumpWidget(
      host(
        Builder(
          builder: (BuildContext inner) {
            context = inner;

            return const SizedBox();
          },
        ),
      ),
    );

    expect(NebaConfirmProvider.maybeOf(context), isNull);
    expect(
      () => NebaConfirmProvider.of(context),
      throwsA(
        isA<FlutterError>().having(
          (FlutterError error) => error.message,
          'message',
          contains('no NebaConfirmProvider above it'),
        ),
      ),
    );
  });

  testWidgets('brings an overlay of its own when there is none above it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(800, 600)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: NebaConfirmProvider(child: asker((bool _) {})),
        ),
      ),
    );
    await ask(tester);

    expect(find.text('Delete the project?'), findsOneWidget);
  });
}

/// Whether the focus is on the button labelled [label].
bool _focused(WidgetTester tester, String label) {
  final FocusNode? focus = FocusManager.instance.primaryFocus;

  return find
      .ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate(
          (Widget widget) => widget is NebaButton && widget.focusNode == focus,
        ),
      )
      .evaluate()
      .isNotEmpty;
}

/// Asks a question from its own `initState`, while the screen is being built.
class _AskOnMount extends StatefulWidget {
  const _AskOnMount({required this.onAnswer});

  final ValueChanged<bool> onAnswer;

  @override
  State<_AskOnMount> createState() => _AskOnMountState();
}

class _AskOnMountState extends State<_AskOnMount> {
  @override
  void initState() {
    super.initState();
    NebaConfirmProvider.of(context)(
      const NebaConfirmOptions(title: Text('Keep the draft?')),
    ).then(widget.onAnswer);
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}
