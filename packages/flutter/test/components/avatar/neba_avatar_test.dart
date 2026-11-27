// NebaAvatar: the suite the React package runs on Avatar, asked the way
// Flutter asks it — what is drawn while a picture loads, after it arrives and
// after it fails, the box and the sheet it builds, and what a screen reader
// hears — rather than the elements and classes it writes.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/initials.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

/// A picture that arrives, or fails, when the test says so.
class _Picture extends ImageProvider<_Picture> {
  final Completer<ImageInfo> arrival = Completer<ImageInfo>();

  @override
  Future<_Picture> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_Picture>(this);
  }

  @override
  ImageStreamCompleter loadImage(_Picture key, ImageDecoderCallback decode) {
    return OneFrameImageStreamCompleter(arrival.future);
  }
}

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);

  Future<void> pump(WidgetTester tester, Widget avatar) {
    return tester.pumpWidget(host(Center(child: avatar)));
  }

  NebaSheet sheetOf(WidgetTester tester) => tester.widget<NebaSheet>(find.byType(NebaSheet));

  Size sizeOf(WidgetTester tester) => tester.getSize(find.byType(NebaSheet));

  Future<void> arrive(WidgetTester tester, _Picture picture) async {
    final ui.Image image = (await tester.runAsync(() => createTestImage(width: 4, height: 4)))!;
    picture.arrival.complete(ImageInfo(image: image));
    await tester.pump();
    await tester.pump();
  }

  RawImage? pictureOf(WidgetTester tester) {
    final Finder raw = find.byType(RawImage);

    return raw.evaluate().isEmpty ? null : tester.widget<RawImage>(raw);
  }

  double pictureOpacity(WidgetTester tester) {
    return tester
        .widget<AnimatedOpacity>(
          find.ancestor(of: find.byType(RawImage), matching: find.byType(AnimatedOpacity)),
        )
        .opacity;
  }

  group('initialsOf', () {
    test('takes the first character of the first word and of the last', () {
      expect(initialsOf('Jane Doe'), 'JD');
      expect(initialsOf('jane miriam van doe'), 'JD');
      expect(initialsOf('  Ada  '), 'A');
      expect(initialsOf(''), '');
    });

    test('keeps a one-word name to one character', () {
      expect(initialsOf('홍길동'), '홍');
    });

    test('never cuts a character apart', () {
      expect(initialsOf('👩‍💻 Dev'), '👩‍💻D');
      expect(initialsOf('🇰🇷 Kim'), '🇰🇷K');
      expect(initialsOf('Änne Berg'), 'ÄB');
    });
  });

  group('the stand-in', () {
    testWidgets('draws the initials of the name', (WidgetTester tester) async {
      await pump(tester, const NebaAvatar(name: 'Jane Doe'));

      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('takes initials written out over the derived ones', (WidgetTester tester) async {
      await pump(tester, const NebaAvatar(name: 'Jane Doe', initials: 'vD'));

      expect(find.text('vD'), findsOneWidget);
      expect(find.text('JD'), findsNothing);
    });

    testWidgets('takes a child over the initials', (WidgetTester tester) async {
      await pump(tester, const NebaAvatar(name: 'Deploy bot', child: Text('🤖')));

      expect(find.text('🤖'), findsOneWidget);
      expect(find.text('DB'), findsNothing);
    });

    testWidgets('draws a silhouette when there is nothing to go on', (WidgetTester tester) async {
      await pump(tester, const NebaAvatar());

      expect(find.byType(Text), findsNothing);
      expect(
        find.descendant(of: find.byType(NebaAvatar), matching: find.byType(CustomPaint)),
        findsWidgets,
      );
    });

    testWidgets('sizes the initials off the box', (WidgetTester tester) async {
      const Map<NebaSize, double> sizes = <NebaSize, double>{
        NebaSize.xs: 9,
        NebaSize.sm: 11,
        NebaSize.md: 13,
        NebaSize.lg: 16,
        NebaSize.xl: 19,
      };

      for (final MapEntry<NebaSize, double> entry in sizes.entries) {
        await pump(tester, NebaAvatar(name: 'Jane Doe', size: entry.key));

        final RichText text = tester.widget<RichText>(find.byType(RichText));
        expect(text.text.style?.fontSize, entry.value, reason: entry.key.name);
        expect(text.text.style?.fontWeight, FontWeight.w600);
      }
    });

    testWidgets('draws a glyph child at 55% of the box', (WidgetTester tester) async {
      await pump(tester, const NebaAvatar(size: NebaSize.xl, child: NebaGlyph(<NebaGlyphPart>[])));

      expect(tester.getSize(find.byType(NebaGlyph)), const Size.square(48 * 0.55));
    });
  });

  group('semantics', () {
    testWidgets('says the name rather than the initials', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaAvatar(name: 'Jane Doe'));

      expect(find.bySemanticsLabel('Jane Doe'), findsOneWidget);
      expect(find.bySemanticsLabel('JD'), findsNothing);
      semantics.dispose();
    });

    testWidgets('says the semanticLabel over the name', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaAvatar(name: 'Jane Doe', semanticLabel: 'Jane, the owner'));

      expect(find.bySemanticsLabel('Jane, the owner'), findsOneWidget);
      expect(find.bySemanticsLabel('Jane Doe'), findsNothing);
      semantics.dispose();
    });

    testWidgets('says nothing at all with an empty semanticLabel', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaAvatar(name: 'Jane Doe', semanticLabel: ''));

      expect(find.bySemanticsLabel('Jane Doe'), findsNothing);
      expect(find.bySemanticsLabel('JD'), findsNothing);
      semantics.dispose();
    });

    testWidgets('reads initials it was handed when there is no name', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaAvatar(initials: '+3'));

      expect(find.bySemanticsLabel('+3'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('the picture', () {
    testWidgets('keeps the stand-in until the picture arrives, then fades it up', (
      WidgetTester tester,
    ) async {
      final List<NebaAvatarLoadingStatus> statuses = <NebaAvatarLoadingStatus>[];
      final _Picture picture = _Picture();

      await pump(
        tester,
        NebaAvatar(image: picture, name: 'Jane Doe', onLoadingStatusChange: statuses.add),
      );
      await tester.pump();

      expect(find.text('JD'), findsOneWidget);
      expect(pictureOpacity(tester), 0);
      expect(statuses, <NebaAvatarLoadingStatus>[NebaAvatarLoadingStatus.loading]);

      await arrive(tester, picture);

      expect(find.text('JD'), findsNothing);
      expect(pictureOf(tester)?.image, isNotNull);
      expect(pictureOf(tester)?.fit, BoxFit.cover);
      expect(pictureOpacity(tester), 1);
      expect(statuses, <NebaAvatarLoadingStatus>[
        NebaAvatarLoadingStatus.loading,
        NebaAvatarLoadingStatus.loaded,
      ]);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('is an image to a screen reader once it has arrived', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final _Picture picture = _Picture();

      await pump(tester, NebaAvatar(image: picture, name: 'Jane Doe'));
      expect(
        tester.getSemantics(find.bySemanticsLabel('Jane Doe')),
        matchesSemantics(label: 'Jane Doe'),
      );

      await arrive(tester, picture);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Jane Doe')),
        matchesSemantics(label: 'Jane Doe', isImage: true),
      );

      await tester.pumpWidget(const SizedBox());
      semantics.dispose();
    });

    testWidgets('keeps the stand-in for good when the picture fails, and says nothing about it', (
      WidgetTester tester,
    ) async {
      final List<NebaAvatarLoadingStatus> statuses = <NebaAvatarLoadingStatus>[];
      final _Picture picture = _Picture();

      await pump(
        tester,
        NebaAvatar(image: picture, name: 'Jane Doe', onLoadingStatusChange: statuses.add),
      );
      picture.arrival.completeError(Exception('404'));
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('JD'), findsOneWidget);
      expect(statuses.last, NebaAvatarLoadingStatus.error);
    });

    testWidgets('holds the stand-in back for the delay while the picture loads', (
      WidgetTester tester,
    ) async {
      final _Picture picture = _Picture();

      await pump(
        tester,
        NebaAvatar(image: picture, name: 'Jane Doe', delay: const Duration(milliseconds: 300)),
      );
      expect(find.text('JD'), findsNothing);

      await tester.pump(const Duration(milliseconds: 299));
      expect(find.text('JD'), findsNothing);

      await tester.pump(const Duration(milliseconds: 2));
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('reports nothing and draws the stand-in at once with no picture', (
      WidgetTester tester,
    ) async {
      final List<NebaAvatarLoadingStatus> statuses = <NebaAvatarLoadingStatus>[];

      await pump(
        tester,
        NebaAvatar(
          name: 'Jane Doe',
          delay: const Duration(seconds: 1),
          onLoadingStatusChange: statuses.add,
        ),
      );
      await tester.pump();

      expect(find.text('JD'), findsOneWidget);
      expect(statuses, isEmpty);
    });
  });

  group('style props', () {
    testWidgets('is a tinted plate in the primary family by default', (WidgetTester tester) async {
      await pump(tester, const NebaAvatar(name: 'Jane Doe'));

      expect(sheetOf(tester).fill, Color.alphaBlend(primary.softHover, tokens.surface));
      expect(sheetOf(tester).plate, NebaPlate.none);
      expect(sheetOf(tester).edge, isNull);
      expect(sheetOf(tester).elevation, 0);
    });

    testWidgets('fills a solid avatar and draws a hairline round an outline one', (
      WidgetTester tester,
    ) async {
      final NebaColorRoles info = tokens.roles(NebaColor.info);

      await pump(
        tester,
        const NebaAvatar(name: 'Jane Doe', variant: NebaVariant.solid, color: NebaColor.info),
      );
      expect(sheetOf(tester).fill, info.fill);
      expect(sheetOf(tester).plate, NebaPlate.solid);
      expect(sheetOf(tester).plateOnTop, isTrue);

      await pump(
        tester,
        const NebaAvatar(name: 'Jane Doe', variant: NebaVariant.outline, color: NebaColor.info),
      );
      expect(sheetOf(tester).fill, info.panel);
      expect(sheetOf(tester).edge, info.line);
      expect(sheetOf(tester).plate, NebaPlate.glass);
    });

    testWidgets('lifts every variant by its elevation', (WidgetTester tester) async {
      for (final NebaVariant variant in NebaVariant.values) {
        await pump(tester, NebaAvatar(name: 'Jane Doe', variant: variant, elevation: 2));

        expect(sheetOf(tester).elevation, 2, reason: variant.name);
      }
    });

    testWidgets('is a square on the control heights, edge included', (WidgetTester tester) async {
      const Map<NebaSize, double> boxes = <NebaSize, double>{
        NebaSize.xs: 22,
        NebaSize.sm: 26,
        NebaSize.md: 32,
        NebaSize.lg: 40,
        NebaSize.xl: 48,
      };

      for (final MapEntry<NebaSize, double> entry in boxes.entries) {
        for (final NebaVariant variant in NebaVariant.values) {
          await pump(tester, NebaAvatar(name: 'Jane Doe', size: entry.key, variant: variant));

          expect(
            sizeOf(tester),
            Size.square(entry.value),
            reason: '${entry.key.name} ${variant.name}',
          );
        }
      }
    });

    testWidgets('crops round, or cuts the corners at about 28% of the box', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaAvatar(name: 'Jane Doe'));
      expect(sheetOf(tester).borderRadius, BorderRadius.circular(16));

      await pump(
        tester,
        const NebaAvatar(name: 'Jane Doe', shape: NebaAvatarShape.square, size: NebaSize.xl),
      );
      expect(sheetOf(tester).borderRadius, BorderRadius.circular(14));
    });

    testWidgets('takes its size and variant from NebaProvider', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const NebaProvider(
            defaults: NebaDefaults(size: NebaSize.lg, variant: NebaVariant.solid),
            child: Center(child: NebaAvatar(name: 'Jane Doe')),
          ),
        ),
      );

      expect(sizeOf(tester), const Size.square(40));
      expect(sheetOf(tester).plate, NebaPlate.solid);
    });

    testWidgets('arrives by its transition', (WidgetTester tester) async {
      await pump(tester, const NebaAvatar(name: 'Jane Doe', transition: NebaTransition.fade()));

      final Finder fade = find.ancestor(of: find.byType(NebaSheet), matching: find.byType(Opacity));
      expect(tester.widget<Opacity>(fade.first).opacity, 0);

      await tester.pumpAndSettle();
      expect(tester.widget<Opacity>(fade.first).opacity, 1);
    });

    testWidgets('never applies a transform', (WidgetTester tester) async {
      await pump(tester, const NebaAvatar(name: 'Jane Doe'));

      expect(
        find.descendant(of: find.byType(NebaAvatar), matching: find.byType(Transform)),
        findsNothing,
      );
    });
  });
}
