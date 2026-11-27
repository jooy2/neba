// NebaFilePicker: the suite the React package runs on FilePicker, asked the
// way Flutter asks it — the semantics and the parts it builds, what a pick, a
// drop and a press on a remove button do, and what it turns away — rather than
// the elements, the drag events and the hidden input it writes.

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  const String drop = 'Drop files here, or click to browse';

  NebaFile file(String name, {String type = 'text/plain', int size = 10}) {
    return NebaFile(name: name, size: size, type: type);
  }

  Future<void> pump(WidgetTester tester, Widget picker) {
    return tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: 360, child: picker),
        ),
      ),
    );
  }

  NebaFilePickerState stateOf(WidgetTester tester) {
    return tester.state<NebaFilePickerState>(find.byType(NebaFilePicker));
  }

  Future<void> dropOn(WidgetTester tester, List<NebaFile> files) async {
    stateOf(tester).drop(files);
    await tester.pump();
  }

  Finder zone() => find.text(drop);

  group('rendering', () {
    testWidgets('builds a button that opens the dialog', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaFilePicker(onPick: () async => null));

      expect(
        tester.getSemantics(find.bySemanticsLabel(drop)),
        matchesSemantics(
          label: drop,
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );

      semantics.dispose();
    });

    testWidgets('builds its own words when it is given some', (WidgetTester tester) async {
      await pump(tester, const NebaFilePicker(title: Text('Drop a CSV'), hint: Text('Up to 5 MB')));

      expect(find.text('Drop a CSV'), findsOneWidget);
      expect(find.text('Up to 5 MB'), findsOneWidget);
      expect(zone(), findsNothing);
    });

    testWidgets('builds the label, the description and the error', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaFilePicker(label: Text('Attachments'), description: Text('PDF or PNG.')),
      );

      expect(find.text('Attachments'), findsOneWidget);
      expect(find.text('PDF or PNG.'), findsOneWidget);

      await pump(
        tester,
        const NebaFilePicker(label: Text('Attachments'), error: Text('Pick at least one.')),
      );

      expect(find.text('Pick at least one.'), findsOneWidget);
      expect(
        tester.renderObject<RenderParagraph>(find.text('Pick at least one.')).text.style!.color,
        tokens.roles(NebaColor.danger).accent,
      );
    });

    testWidgets('names the box by its label and what the box says', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        Column(
          children: <Widget>[
            NebaFilePicker(
              label: const Text('Resume'),
              title: const Text('Drop a PDF'),
              onPick: () async => null,
            ),
            NebaFilePicker(
              label: const Text('Cover letter'),
              title: const Text('Drop a PDF'),
              onPick: () async => null,
            ),
          ],
        ),
      );

      expect(find.bySemanticsLabel('Resume Drop a PDF'), findsOneWidget);
      expect(find.bySemanticsLabel('Cover letter Drop a PDF'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('says its own words in the language it was given', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      registerNebaMessages('ko', ko);
      await pump(
        tester,
        NebaFilePicker(
          locale: const Locale('ko'),
          label: const Text('첨부'),
          defaultValue: <NebaFile>[file('notes.txt')],
        ),
      );

      expect(find.text('파일을 여기에 놓거나 클릭해 찾아보세요'), findsOneWidget);
      expect(find.bySemanticsLabel('notes.txt 삭제'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('reflects a changed title on a rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaFilePicker(title: Text('Before')));
      await pump(tester, const NebaFilePicker(title: Text('After')));

      expect(find.text('After'), findsOneWidget);
      expect(find.text('Before'), findsNothing);
    });

    testWidgets('draws the upload glyph in its colour, or nothing when told to', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaFilePicker());

      final Finder glyph = find.descendant(
        of: find.byType(NebaFilePicker),
        matching: find.byWidgetPredicate(
          (Widget widget) => widget.runtimeType.toString() == 'NebaGlyph',
        ),
      );

      expect(glyph, findsOneWidget);
      expect(tester.getSize(glyph).width, 14 * 1.8);

      await pump(tester, const NebaFilePicker(showIcon: false));

      expect(glyph, findsNothing);
    });
  });

  group('the files it holds', () {
    testWidgets('lists the files it is given, each with its size', (WidgetTester tester) async {
      await pump(
        tester,
        NebaFilePicker(multiple: true, defaultValue: <NebaFile>[file('notes.txt', size: 2500)]),
      );

      expect(find.text('notes.txt'), findsOneWidget);
      expect(find.text('2.5 kB'), findsOneWidget);
    });

    testWidgets('hides the list when told to', (WidgetTester tester) async {
      await pump(
        tester,
        NebaFilePicker(showList: false, defaultValue: <NebaFile>[file('notes.txt')]),
      );

      expect(find.text('notes.txt'), findsNothing);
    });

    testWidgets('removes a file when its remove button is pressed', (WidgetTester tester) async {
      List<NebaFile>? changed;

      await pump(
        tester,
        NebaFilePicker(
          defaultValue: <NebaFile>[file('notes.txt')],
          onFilesChange: (List<NebaFile> files) => changed = files,
        ),
      );

      await tester.tap(find.bySemanticsLabel('Remove notes.txt'));
      await tester.pump();

      expect(changed, isEmpty);
      expect(find.text('notes.txt'), findsNothing);
    });

    testWidgets('keeps the keyboard focus in the list as files are removed', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaFilePicker(
          multiple: true,
          onPick: () async => null,
          defaultValue: <NebaFile>[file('a.txt'), file('b.txt'), file('c.txt')],
        ),
      );

      FocusNode focusOf(String label) {
        final Finder button = find.descendant(
          of: find.bySemanticsLabel(label),
          matching: find.byType(FocusableActionDetector),
        );

        return tester.widget<FocusableActionDetector>(button).focusNode!;
      }

      Future<void> enter() async {
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        await tester.pump();
      }

      focusOf('Remove b.txt').requestFocus();
      await tester.pump();

      await enter();
      // The next file moved into the place of the one removed.
      expect(focusOf('Remove c.txt').hasFocus, isTrue);

      await enter();
      // The last one gone, the one before it.
      expect(focusOf('Remove a.txt').hasFocus, isTrue);

      await enter();
      // Nothing left, the box that adds files.
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<NebaFilePicker>(),
        isNotNull,
      );
      expect(find.text('a.txt'), findsNothing);
    });

    testWidgets('follows a controlled value', (WidgetTester tester) async {
      await pump(tester, NebaFilePicker(value: <NebaFile>[file('a.txt')]));
      expect(find.text('a.txt'), findsOneWidget);

      await pump(tester, NebaFilePicker(value: <NebaFile>[file('b.txt')]));
      expect(find.text('b.txt'), findsOneWidget);
      expect(find.text('a.txt'), findsNothing);
    });
  });

  group('picking', () {
    testWidgets('a press asks onPick and takes what it hands back', (WidgetTester tester) async {
      int picks = 0;
      List<NebaFile>? changed;

      await pump(
        tester,
        NebaFilePicker(
          onPick: () async {
            picks++;
            return <NebaFile>[file('notes.txt')];
          },
          onFilesChange: (List<NebaFile> files) => changed = files,
        ),
      );

      await tester.tap(zone());
      await tester.pump();

      expect(picks, 1);
      expect(changed!.single.name, 'notes.txt');
      expect(find.text('notes.txt'), findsOneWidget);
    });

    testWidgets('takes nothing from a dialog that was dismissed', (WidgetTester tester) async {
      int changes = 0;

      await pump(
        tester,
        NebaFilePicker(onPick: () async => null, onFilesChange: (List<NebaFile> _) => changes++),
      );

      await tester.tap(zone());
      await tester.pump();

      expect(changes, 0);
    });

    testWidgets('is no button and no stop in the focus order without onPick', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaFilePicker());

      // Every flag left out is held false: no button, no focus.
      expect(tester.getSemantics(find.bySemanticsLabel(drop)), matchesSemantics(label: drop));

      semantics.dispose();
    });
  });

  group('dropping', () {
    testWidgets('takes a dropped file', (WidgetTester tester) async {
      int changes = 0;

      await pump(tester, NebaFilePicker(onFilesChange: (List<NebaFile> _) => changes++));
      await dropOn(tester, <NebaFile>[file('notes.txt')]);

      expect(changes, 1);
      expect(find.text('notes.txt'), findsOneWidget);
    });

    testWidgets('takes a file dragged onto it from elsewhere in the app', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        Overlay.wrap(
          child: Column(
            children: <Widget>[
              Draggable<NebaFile>(
                data: file('dragged.txt'),
                feedback: const SizedBox.square(dimension: 20),
                child: const SizedBox(height: 40, child: Text('Handle')),
              ),
              const NebaFilePicker(),
            ],
          ),
        ),
      );

      final TestGesture gesture = await tester.startGesture(tester.getCenter(find.text('Handle')));

      await gesture.moveTo(tester.getCenter(zone()));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(find.text('dragged.txt'), findsOneWidget);
    });

    testWidgets('lights its edge while a drag is over it, and puts it out on the drop', (
      WidgetTester tester,
    ) async {
      final NebaColorRoles primary = tokens.roles(NebaColor.primary);

      Color edge() {
        final CustomPaint paint = tester
            .widgetList<CustomPaint>(
              find.descendant(of: find.byType(NebaFilePicker), matching: find.byType(CustomPaint)),
            )
            .firstWhere(
              (CustomPaint paint) => paint.painter.runtimeType.toString() == '_DashedEdge',
            );

        return (paint.painter! as dynamic).color as Color;
      }

      await pump(tester, const NebaFilePicker());
      expect(edge(), primary.line);

      stateOf(tester).dragging = true;
      await tester.pumpAndSettle();
      expect(edge(), primary.ring);

      await dropOn(tester, <NebaFile>[file('notes.txt')]);
      await tester.pumpAndSettle();
      expect(stateOf(tester).dragging, isFalse);
      expect(edge(), primary.line);
    });

    testWidgets('replaces rather than appends when it holds one file at a time', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaFilePicker(defaultValue: <NebaFile>[file('first.txt')]));
      await dropOn(tester, <NebaFile>[file('second.txt')]);

      expect(find.text('second.txt'), findsOneWidget);
      expect(find.text('first.txt'), findsNothing);
    });

    testWidgets('appends when it takes more than one', (WidgetTester tester) async {
      await pump(
        tester,
        NebaFilePicker(multiple: true, defaultValue: <NebaFile>[file('first.txt')]),
      );
      await dropOn(tester, <NebaFile>[file('second.txt')]);

      expect(find.text('first.txt'), findsOneWidget);
      expect(find.text('second.txt'), findsOneWidget);
    });

    for (final (String state, Widget Function(ValueChanged<List<NebaFile>>) build)
        in <(String, Widget Function(ValueChanged<List<NebaFile>>))>[
          (
            'disabled',
            (ValueChanged<List<NebaFile>> changed) =>
                NebaFilePicker(disabled: true, onFilesChange: changed),
          ),
          (
            'read-only',
            (ValueChanged<List<NebaFile>> changed) =>
                NebaFilePicker(readOnly: true, onFilesChange: changed),
          ),
          (
            'inside a disabled fieldset',
            (ValueChanged<List<NebaFile>> changed) => NebaFieldset(
              disabled: true,
              children: <Widget>[NebaFilePicker(onFilesChange: changed)],
            ),
          ),
        ]) {
      testWidgets('ignores a drop while it is $state', (WidgetTester tester) async {
        int changes = 0;

        await pump(tester, build((List<NebaFile> _) => changes++));
        await dropOn(tester, <NebaFile>[file('notes.txt')]);

        expect(changes, 0);
      });
    }
  });

  group('what it turns away', () {
    testWidgets('rejects a file the accept string does not match', (WidgetTester tester) async {
      List<NebaFileRejection>? rejected;
      int changes = 0;

      await pump(
        tester,
        NebaFilePicker(
          accept: 'image/*',
          onReject: (List<NebaFileRejection> rejections) => rejected = rejections,
          onFilesChange: (List<NebaFile> _) => changes++,
        ),
      );
      await dropOn(tester, <NebaFile>[file('notes.txt')]);

      expect(changes, 0);
      expect(rejected!.single.reason, NebaFileRejectionReason.type);
    });

    testWidgets('matches an accept entry written as an extension', (WidgetTester tester) async {
      int changes = 0;

      await pump(
        tester,
        NebaFilePicker(accept: '.txt', onFilesChange: (List<NebaFile> _) => changes++),
      );
      await dropOn(tester, <NebaFile>[file('NOTES.TXT', type: '')]);

      expect(changes, 1);
    });

    testWidgets('matches an accept entry written as a wildcard type', (WidgetTester tester) async {
      int changes = 0;

      await pump(
        tester,
        NebaFilePicker(accept: 'image/*', onFilesChange: (List<NebaFile> _) => changes++),
      );
      await dropOn(tester, <NebaFile>[file('cat.png', type: 'image/png')]);

      expect(changes, 1);
    });

    testWidgets('rejects a file over maxSize', (WidgetTester tester) async {
      List<NebaFileRejection>? rejected;

      await pump(
        tester,
        NebaFilePicker(
          maxSize: 5,
          onReject: (List<NebaFileRejection> rejections) => rejected = rejections,
        ),
      );
      await dropOn(tester, <NebaFile>[file('big.txt', size: 50)]);

      expect(rejected!.single.reason, NebaFileRejectionReason.size);
    });

    testWidgets('rejects the files past maxFiles, counting what it already holds', (
      WidgetTester tester,
    ) async {
      List<NebaFileRejection>? rejected;

      await pump(
        tester,
        NebaFilePicker(
          multiple: true,
          maxFiles: 2,
          defaultValue: <NebaFile>[file('one.txt')],
          onReject: (List<NebaFileRejection> rejections) => rejected = rejections,
        ),
      );
      await dropOn(tester, <NebaFile>[file('two.txt'), file('three.txt')]);

      expect(find.text('two.txt'), findsOneWidget);
      expect(find.text('three.txt'), findsNothing);
      expect(rejected!.single.reason, NebaFileRejectionReason.count);
      expect(rejected!.single.file.name, 'three.txt');
    });

    testWidgets('checks a picked file as it checks a dropped one', (WidgetTester tester) async {
      List<NebaFileRejection>? rejected;

      await pump(
        tester,
        NebaFilePicker(
          accept: '.pdf',
          onPick: () async => <NebaFile>[file('notes.txt')],
          onReject: (List<NebaFileRejection> rejections) => rejected = rejections,
        ),
      );
      await tester.tap(zone());
      await tester.pump();

      expect(rejected!.single.reason, NebaFileRejectionReason.type);
    });
  });

  group('inert states', () {
    testWidgets('a disabled picker opens nothing and is heard as disabled', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      int picks = 0;

      await pump(
        tester,
        NebaFilePicker(
          disabled: true,
          onPick: () async {
            picks++;
            return null;
          },
        ),
      );
      await tester.tap(zone(), warnIfMissed: false);
      await tester.pump();

      expect(picks, 0);
      expect(
        tester.getSemantics(find.bySemanticsLabel(drop)),
        matchesSemantics(label: drop, isButton: true, hasEnabledState: true),
      );

      semantics.dispose();
    });

    testWidgets('drops the remove buttons when read-only', (WidgetTester tester) async {
      await pump(
        tester,
        NebaFilePicker(readOnly: true, defaultValue: <NebaFile>[file('notes.txt')]),
      );

      expect(find.text('notes.txt'), findsOneWidget);
      expect(find.bySemanticsLabel('Remove notes.txt'), findsNothing);
    });
  });

  group('style', () {
    testWidgets('re-points the colour family at danger when invalid', (WidgetTester tester) async {
      await pump(tester, const NebaFilePicker(error: Text('Pick one.')));
      await tester.pumpAndSettle();

      final CustomPaint paint = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .firstWhere((CustomPaint paint) => paint.painter.runtimeType.toString() == '_DashedEdge');

      expect((paint.painter! as dynamic).color, tokens.roles(NebaColor.danger).line);
    });

    testWidgets('carries the elevation onto its sheet, and none for text', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaFilePicker(elevation: 2));

      expect(tester.widget<NebaSheet>(find.byType(NebaSheet)).elevation, 2);

      await pump(tester, const NebaFilePicker(elevation: 2, variant: NebaVariant.text));

      expect(find.byType(NebaSheet), findsNothing);
    });

    testWidgets('never applies a transform', (WidgetTester tester) async {
      await pump(
        tester,
        NebaFilePicker(defaultValue: <NebaFile>[file('notes.txt')], error: const Text('Nope.')),
      );

      expect(
        find.descendant(of: find.byType(NebaFilePicker), matching: find.byType(Transform)),
        findsNothing,
      );
    });
  });

  group('nebaFormatFileSize', () {
    test('writes a size in the units a file browser shows', () {
      expect(nebaFormatFileSize(999), '999 B');
      expect(nebaFormatFileSize(2500), '2.5 kB');
      expect(nebaFormatFileSize(24000), '24 kB');
      expect(nebaFormatFileSize(1400000), '1.4 MB');
      expect(nebaFormatFileSize(5 * 1000 * 1000 * 1000 * 1000 * 1000), '5000 TB');
    });
  });
}
