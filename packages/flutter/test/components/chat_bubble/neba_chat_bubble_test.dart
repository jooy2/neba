import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  setUpAll(() => registerNebaMessages('ko', ko));

  Future<void> pump(
    WidgetTester tester,
    Widget bubble, {
    TextDirection textDirection = TextDirection.ltr,
    bool disableAnimations = false,
  }) {
    return tester.pumpWidget(
      host(
        Align(alignment: Alignment.topCenter, child: bubble),
        textDirection: textDirection,
        disableAnimations: disableAnimations,
      ),
    );
  }

  NebaTokens tokensOf(WidgetTester tester) =>
      NebaTheme.of(tester.element(find.byType(NebaChatBubble)));

  NebaSheet sheetOf(WidgetTester tester) => tester.widget<NebaSheet>(find.byType(NebaSheet).first);

  Finder byLabel(String label) => find.bySemanticsLabel(label);

  group('the message', () {
    testWidgets('renders the message it is given', (WidgetTester tester) async {
      await pump(tester, const NebaChatBubble(child: Text('Still on?')));

      expect(find.text('Still on?'), findsOneWidget);
    });

    testWidgets('reflects a changed message on rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaChatBubble(child: Text('One')));
      await pump(tester, const NebaChatBubble(child: Text('Two')));

      expect(find.text('One'), findsNothing);
      expect(find.text('Two'), findsOneWidget);
    });

    testWidgets('is as wide as its message, not as its row', (WidgetTester tester) async {
      await pump(tester, const NebaChatBubble(child: Text('Hi')));

      expect(tester.getSize(find.byType(NebaSheet)).width, lessThan(100));
    });

    testWidgets('stretches its media across the width the message gives it', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaChatBubble(
          media: SizedBox(key: Key('media'), height: 40),
          child: Text('A sentence of some length'),
        ),
      );

      expect(
        tester.getSize(find.byKey(const Key('media'))).width,
        tester.getSize(find.byType(NebaSheet)).width - 2,
      );
      expect(tester.getSize(find.byType(NebaSheet)).width, lessThan(400));
    });

    testWidgets('grows no wider than 512 pixels', (WidgetTester tester) async {
      await pump(tester, NebaChatBubble(child: Text('word ' * 80)));

      expect(tester.getSize(find.byType(NebaSheet)).width, lessThanOrEqualTo(512));
    });

    testWidgets('pads the bubble by density and size', (WidgetTester tester) async {
      await pump(tester, const NebaChatBubble(variant: NebaVariant.solid, child: Text('Hi')));
      final Rect sheet = tester.getRect(find.byType(NebaSheet));
      final Rect text = tester.getRect(find.text('Hi'));

      expect(text.left - sheet.left, 12);
      expect(text.top - sheet.top, 8);

      await pump(
        tester,
        const NebaChatBubble(
          variant: NebaVariant.solid,
          density: NebaDensity.compact,
          size: NebaSize.xs,
          child: Text('Hi'),
        ),
      );

      expect(tester.getRect(find.text('Hi')).left - tester.getRect(find.byType(NebaSheet)).left, 6);
    });
  });

  group('identity', () {
    testWidgets('draws the name, the time and the avatar when it has them', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaChatBubble(
          avatar: SizedBox.square(key: Key('avatar'), dimension: 32),
          name: Text('Farah'),
          time: Text('09:41'),
          child: Text('Still on?'),
        ),
      );

      expect(find.text('Farah'), findsOneWidget);
      expect(find.text('09:41'), findsOneWidget);
      expect(find.byKey(const Key('avatar')), findsOneWidget);
      // The name over the bubble, the time muted.
      expect(
        tester.getRect(find.text('Farah')).bottom,
        lessThanOrEqualTo(tester.getRect(find.byType(NebaSheet)).top),
      );
      expect(
        DefaultTextStyle.of(tester.element(find.text('09:41'))).style.color,
        tokensOf(tester).mutedFg,
      );
    });

    testWidgets('draws nothing beyond the message when given nothing else', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaChatBubble(child: Text('Hi')));

      expect(find.byType(Text), findsOneWidget);
      expect(find.byType(NebaGlyph), findsNothing);
    });
  });

  group('side', () {
    testWidgets('starts at the start, its top start corner cut short', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaChatBubble(
          avatar: SizedBox.square(key: Key('avatar'), dimension: 32),
          child: Text('Hi'),
        ),
      );
      final BorderRadius corners = sheetOf(tester).borderRadius;

      expect(
        tester.getRect(find.byKey(const Key('avatar'))).left,
        lessThan(tester.getRect(find.byType(NebaSheet)).left),
      );
      expect(corners.topLeft, const Radius.circular(NebaChatBubble.tailRadius));
      expect(corners.topRight.x, greaterThan(NebaChatBubble.tailRadius));
    });

    testWidgets('runs the row the other way for a message of your own', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaChatBubble(
          side: NebaChatBubbleSide.end,
          avatar: SizedBox.square(key: Key('avatar'), dimension: 32),
          child: Text('Hi'),
        ),
      );
      final BorderRadius corners = sheetOf(tester).borderRadius;

      expect(
        tester.getRect(find.byKey(const Key('avatar'))).left,
        greaterThan(tester.getRect(find.byType(NebaSheet)).right),
      );
      expect(corners.topRight, const Radius.circular(NebaChatBubble.tailRadius));
      expect(corners.topLeft.x, greaterThan(NebaChatBubble.tailRadius));
    });

    testWidgets('cuts the other corner in a right-to-left thread', (WidgetTester tester) async {
      await pump(tester, const NebaChatBubble(child: Text('Hi')), textDirection: TextDirection.rtl);

      expect(sheetOf(tester).borderRadius.topRight, const Radius.circular(4));
    });
  });

  group('variant and color', () {
    testWidgets('defaults to an outline in the primary family', (WidgetTester tester) async {
      await pump(tester, const NebaChatBubble(child: Text('Hi')));
      final NebaColorRoles primary = tokensOf(tester).roles(NebaColor.primary);

      expect(sheetOf(tester).fill, primary.panel);
      expect(sheetOf(tester).edge, primary.line);
      expect(sheetOf(tester).plate, NebaPlate.glass);
    });

    testWidgets('floods a solid bubble and turns its text to the ink on a fill', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaChatBubble(
          variant: NebaVariant.solid,
          color: NebaColor.success,
          child: Text('Hi'),
        ),
      );
      final NebaColorRoles success = tokensOf(tester).roles(NebaColor.success);

      expect(sheetOf(tester).fill, success.fill);
      expect(sheetOf(tester).edge, isNull);
      expect(DefaultTextStyle.of(tester.element(find.text('Hi'))).style.color, success.onSolid);
    });

    testWidgets('tints a text bubble with no plate and no blur', (WidgetTester tester) async {
      await pump(tester, const NebaChatBubble(variant: NebaVariant.text, child: Text('Hi')));

      expect(sheetOf(tester).fill, tokensOf(tester).roles(NebaColor.primary).soft);
      expect(sheetOf(tester).plate, NebaPlate.none);
      expect(sheetOf(tester).blur, isFalse);
    });

    testWidgets('takes its variant from the provider', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaProvider(
          defaults: NebaDefaults(variant: NebaVariant.solid),
          child: NebaChatBubble(child: Text('Hi')),
        ),
      );

      expect(sheetOf(tester).plate, NebaPlate.solid);
    });
  });

  group('status', () {
    testWidgets('draws nothing when no status is given', (WidgetTester tester) async {
      await pump(tester, const NebaChatBubble(child: Text('Hi')));

      expect(byLabel('Sent'), findsNothing);
      expect(find.byType(CustomPaint).evaluate().where(_isReadMark), isEmpty);
    });

    testWidgets('names the mark for a screen reader', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      for (final (NebaChatBubbleStatus status, String word) in <(NebaChatBubbleStatus, String)>[
        (NebaChatBubbleStatus.sending, 'Sending'),
        (NebaChatBubbleStatus.sent, 'Sent'),
        (NebaChatBubbleStatus.delivered, 'Delivered'),
        (NebaChatBubbleStatus.read, 'Read'),
        (NebaChatBubbleStatus.failed, 'Not sent'),
      ]) {
        await pump(tester, NebaChatBubble(status: status, child: const Text('Hi')));

        expect(byLabel(word), findsOneWidget, reason: status.name);
      }

      semantics.dispose();
    });

    testWidgets('draws read as a different shape from delivered', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaChatBubble(status: NebaChatBubbleStatus.delivered, child: Text('Hi')),
      );

      expect(tester.widget<NebaGlyph>(find.byType(NebaGlyph)).parts, same(NebaGlyphs.doubleCheck));

      await pump(
        tester,
        const NebaChatBubble(status: NebaChatBubbleStatus.read, child: Text('Hi')),
      );

      expect(find.byType(NebaGlyph), findsNothing);
      expect(find.byType(CustomPaint).evaluate().where(_isReadMark), hasLength(1));
    });

    testWidgets('colours only failed among the glyphs', (WidgetTester tester) async {
      Color colorOf(WidgetTester tester) => tester.widget<NebaGlyph>(find.byType(NebaGlyph)).color!;

      await pump(
        tester,
        const NebaChatBubble(status: NebaChatBubbleStatus.sent, child: Text('Hi')),
      );
      final NebaTokens tokens = tokensOf(tester);

      expect(colorOf(tester), tokens.mutedFg);

      await pump(
        tester,
        const NebaChatBubble(status: NebaChatBubbleStatus.failed, child: Text('Hi')),
      );

      expect(colorOf(tester), tokens.roles(NebaColor.danger).accent);
    });

    testWidgets('names it in the language it was given', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await pump(
        tester,
        const NebaChatBubble(
          status: NebaChatBubbleStatus.read,
          locale: Locale('ko'),
          child: Text('Hi'),
        ),
      );

      expect(byLabel('읽음'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('takes a word of its own over the locale', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await pump(
        tester,
        const NebaChatBubble(
          status: NebaChatBubbleStatus.read,
          statusLabel: 'Seen by Farah',
          locale: Locale('ko'),
          child: Text('Hi'),
        ),
      );

      expect(byLabel('Seen by Farah'), findsOneWidget);
      expect(byLabel('읽음'), findsNothing);
      semantics.dispose();
    });
  });

  group('typing', () {
    testWidgets('draws the dots in place of the message, and says what they mean', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await pump(tester, const NebaChatBubble(typing: true, child: Text('Found it')));

      expect(find.text('Found it'), findsNothing);
      expect(byLabel('Typing…'), findsOneWidget);
      expect(tester.getSemantics(byLabel('Typing…')).flagsCollection.isLiveRegion, isTrue);

      await pump(
        tester,
        const NebaChatBubble(typing: true, locale: Locale('ko'), child: Text('Found it')),
      );

      expect(byLabel('입력 중…'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('gives the message back when the typing stops', (WidgetTester tester) async {
      await pump(tester, const NebaChatBubble(typing: true, child: Text('Found it')));
      await pump(tester, const NebaChatBubble(child: Text('Found it')));

      expect(find.text('Found it'), findsOneWidget);
    });

    testWidgets('lights the dots in turn without moving them', (WidgetTester tester) async {
      await pump(tester, const NebaChatBubble(typing: true));
      final Finder dots = _dots();

      List<double> alphas() => <double>[
        for (final Element dot in dots.evaluate())
          ((dot.widget as DecoratedBox).decoration as BoxDecoration).color!.a,
      ];

      final List<Offset> rest = <Offset>[
        for (final Element dot in dots.evaluate()) tester.getTopLeft(find.byWidget(dot.widget)),
      ];
      final List<double> first = alphas();

      await tester.pump(const Duration(milliseconds: 375));
      final List<double> later = alphas();

      expect(dots, findsNWidgets(3));
      expect(later, isNot(equals(first)));
      // The first dot is at its brightest by 30% of a pass, ahead of the next.
      expect(later[0], greaterThan(later[1]));
      expect(<Offset>[
        for (final Element dot in dots.evaluate()) tester.getTopLeft(find.byWidget(dot.widget)),
      ], rest);
    });

    testWidgets('keeps lighting, more slowly, under reduced motion', (WidgetTester tester) async {
      await pump(tester, const NebaChatBubble(typing: true), disableAnimations: true);
      final Finder dot = _dots().first;

      double alpha() => ((tester.widget<DecoratedBox>(dot).decoration as BoxDecoration).color!).a;

      final double start = alpha();
      // 375 ms is 30% of a full-speed pass and about 14% of a slow one.
      await tester.pump(const Duration(milliseconds: 375));

      expect(alpha(), greaterThan(start));
      expect(alpha(), lessThan(0.9));
    });
  });

  group('media and preview', () {
    testWidgets('draws the media edge to edge above the text', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaChatBubble(
          variant: NebaVariant.solid,
          media: SizedBox(key: Key('media'), height: 80),
          child: Text('The nook'),
        ),
      );
      final Rect sheet = tester.getRect(find.byType(NebaSheet));
      final Rect media = tester.getRect(find.byKey(const Key('media')));

      expect(media.left, sheet.left);
      expect(media.right, sheet.right);
      expect(media.top, sheet.top);
      expect(tester.getRect(find.text('The nook')).top, greaterThan(media.bottom));
    });

    testWidgets('unfurls a link into a card read as a link', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      int presses = 0;
      await pump(
        tester,
        NebaChatBubble(
          preview: NebaChatBubbleLinkPreview(
            url: Uri.parse('https://example.com/rfc-14'),
            onPressed: () => presses++,
            site: const Text('example.com'),
            title: const Text('RFC 14'),
            description: const Text('Why a surface is a sheet.'),
          ),
          child: const Text('Read this first'),
        ),
      );

      expect(find.text('example.com'), findsOneWidget);
      expect(find.text('RFC 14'), findsOneWidget);
      expect(find.text('Why a surface is a sheet.'), findsOneWidget);

      final SemanticsNode link = tester.getSemantics(
        find.ancestor(of: find.text('RFC 14'), matching: find.byType(Semantics)).first,
      );

      expect(link.flagsCollection.isLink, isTrue);
      expect(link.linkUrl, Uri.parse('https://example.com/rfc-14'));

      await tester.tap(find.text('RFC 14'));

      expect(presses, 1);
      semantics.dispose();
    });

    testWidgets('says a new-tab card opens elsewhere only when asked', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      NebaChatBubble bubble({required bool newTab}) => NebaChatBubble(
        preview: NebaChatBubbleLinkPreview(
          url: Uri.parse('https://example.com'),
          onPressed: () {},
          title: const Text('Page'),
          newTab: newTab,
        ),
      );

      await pump(tester, bubble(newTab: false));

      expect(byLabel('(opens in a new tab)'), findsNothing);

      await pump(tester, bubble(newTab: true));

      expect(find.bySemanticsLabel(RegExp(r'\(opens in a new tab\)')), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('hands on no address that could run a script', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await pump(
        tester,
        NebaChatBubble(
          preview: NebaChatBubbleLinkPreview(
            url: Uri.parse('javascript:alert(1)'),
            onPressed: () {},
            title: const Text('Page'),
          ),
        ),
      );
      final SemanticsNode link = tester.getSemantics(
        find.ancestor(of: find.text('Page'), matching: find.byType(Semantics)).first,
      );

      expect(link.linkUrl, isNull);
      semantics.dispose();
    });

    testWidgets('washes the card in the bubble ink, more under the pointer', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaChatBubble(
          variant: NebaVariant.solid,
          preview: NebaChatBubbleLinkPreview(
            url: Uri.parse('https://example.com'),
            onPressed: () {},
            title: const Text('Page'),
          ),
        ),
      );
      final Color ink = tokensOf(tester).roles(NebaColor.primary).onSolid;

      final Finder container = find
          .descendant(of: find.byType(NebaFocusRing), matching: find.byType(AnimatedContainer))
          .first;

      BoxDecoration card() =>
          tester.widget<AnimatedContainer>(container).decoration! as BoxDecoration;

      expect(card().color, ink.withValues(alpha: ink.a * 0.07));

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(find.text('Page')));
      await tester.pumpAndSettle();

      expect(card().color, ink.withValues(alpha: ink.a * 0.12));
      await mouse.removePointer();
    });
  });

  group('actions', () {
    double opacityOf(WidgetTester tester) =>
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;

    testWidgets('renders the actions it is handed beside the bubble', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaChatBubble(
          actions: SizedBox.square(key: Key('actions'), dimension: 24),
          child: Text('Hi'),
        ),
      );

      expect(
        tester.getRect(find.byKey(const Key('actions'))).left,
        greaterThan(tester.getRect(find.byType(NebaSheet)).right),
      );
    });

    testWidgets('are always there on a touch screen', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaChatBubble(actions: SizedBox.square(dimension: 24), child: Text('Hi')),
      );

      expect(opacityOf(tester), 1);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('stay out of the way until the row is hovered or focused', (
      WidgetTester tester,
    ) async {
      final FocusNode focus = FocusNode();
      addTearDown(focus.dispose);
      await pump(
        tester,
        NebaChatBubble(
          actions: Focus(focusNode: focus, child: const SizedBox.square(dimension: 24)),
          child: const Text('Hi'),
        ),
      );

      expect(opacityOf(tester), 0);

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(find.text('Hi')));
      await tester.pump();

      expect(opacityOf(tester), 1);

      await mouse.moveTo(const Offset(1, 599));
      await tester.pump();

      expect(opacityOf(tester), 0);

      focus.requestFocus();
      await tester.pump();

      expect(opacityOf(tester), 1);
      await mouse.removePointer();
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
  });
}

bool _isReadMark(Element element) {
  final CustomPaint paint = element.widget as CustomPaint;

  return paint.painter.runtimeType.toString() == '_ReadPainter';
}

/// The three typing dots.
Finder _dots() => find.byWidgetPredicate(
  (Widget widget) =>
      widget is DecoratedBox &&
      widget.decoration is BoxDecoration &&
      (widget.decoration as BoxDecoration).shape == BoxShape.circle,
);
