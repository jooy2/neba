// NebaImage: the suite the React package runs on Image, asked the way Flutter
// asks it — the box laid out before anything arrives, what stands in while
// the file is on its way and after it fails, the picture's turn, mirror,
// colour and frame as the widgets that draw them, the mark, and what a screen
// reader hears — rather than the elements, the classes and the styles it
// writes.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/modal.dart';
import 'package:neba/src/internal/picture.dart';
import 'package:neba/src/internal/viewer.dart';

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

/// A picture that is already in, as one in the image cache is.
class _Cached extends ImageProvider<_Cached> {
  _Cached(this.info);

  final ImageInfo info;

  @override
  Future<_Cached> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_Cached>(this);
  }

  @override
  ImageStreamCompleter loadImage(_Cached key, ImageDecoderCallback decode) {
    return _Instant(info);
  }
}

class _Instant extends ImageStreamCompleter {
  _Instant(ImageInfo info) {
    setImage(info);
  }
}

void main() {
  final NebaTokens tokens = NebaTokens.light();

  /// [image] at the start of a column [width] wide, in a window with an
  /// overlay for a preview to open into.
  Widget scene(Widget image, {double width = 300}) {
    return host(
      Overlay.wrap(
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: image),
        ),
      ),
    );
  }

  Future<void> pump(WidgetTester tester, Widget image, {double width = 300}) {
    return tester.pumpWidget(scene(image, width: width));
  }

  Future<ui.Image> decoded(WidgetTester tester, {int width = 40, int height = 20}) async {
    return (await tester.runAsync(() => createTestImage(width: width, height: height)))!;
  }

  Future<void> arrive(
    WidgetTester tester,
    _Picture picture, {
    int width = 40,
    int height = 20,
  }) async {
    picture.arrival.complete(
      ImageInfo(
        image: await decoded(tester, width: width, height: height),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Future<void> fail(WidgetTester tester, _Picture picture) async {
    picture.arrival.completeError(Exception('gone'));
    await tester.pump();
    await tester.pump();
  }

  Size boxOf(WidgetTester tester) => tester.getSize(find.byType(NebaImage));

  Finder picture() => find.byType(RawImage);

  group('the box', () {
    testWidgets('reserves a ratio it was given before anything arrives', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaImage(image: _Picture(), alt: 'A ridge', ratio: 3 / 2));

      expect(boxOf(tester), const Size(300, 200));
    });

    testWidgets('reserves the proportion width and height describe, at its width', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaImage(image: _Picture(), alt: 'A ridge', width: 1200, height: 800));

      expect(boxOf(tester), const Size(300, 200));
    });

    testWidgets('gives way to a ratio it was given', (WidgetTester tester) async {
      await pump(
        tester,
        NebaImage(image: _Picture(), alt: 'A ridge', width: 1200, height: 800, ratio: 16 / 9),
      );

      expect(boxOf(tester).width / boxOf(tester).height, closeTo(16 / 9, 0.001));
    });

    testWidgets('takes the shape of a file nobody described once it arrives', (
      WidgetTester tester,
    ) async {
      final _Picture file = _Picture();
      await pump(tester, NebaImage(image: file, alt: 'A ridge'));

      expect(boxOf(tester).height, 0);

      await arrive(tester, file, width: 40, height: 20);

      expect(boxOf(tester), const Size(300, 150));
    });

    testWidgets('sizes the box to a lone height across the width it is given', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaImage(image: _Picture(), alt: 'A ridge', height: 120));

      expect(boxOf(tester), const Size(300, 120));
    });

    testWidgets('takes the width from a ratio beside a lone height, at the start', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaImage(image: _Picture(), alt: 'A ridge', height: 120, ratio: 4 / 3));

      final Finder inner = find.descendant(
        of: find.byType(NebaImage),
        matching: find.byType(ClipRect),
      );

      expect(tester.getSize(inner.first), const Size(160, 120));
      expect(tester.getTopLeft(inner.first), Offset.zero);
    });

    testWidgets('sizes the box to a lone width, capped at what it is given', (
      WidgetTester tester,
    ) async {
      final _Picture file = _Picture();
      await pump(tester, NebaImage(image: file, alt: 'A ridge', width: 200));
      await arrive(tester, file, width: 40, height: 20);

      final Finder inner = find
          .descendant(of: find.byType(NebaImage), matching: find.byType(ClipRect))
          .first;

      expect(tester.getSize(inner), const Size(200, 100));

      await pump(tester, NebaImage(image: file, alt: 'A ridge', width: 500));
      await tester.pump();

      expect(tester.getSize(inner), const Size(300, 150));
    });

    testWidgets('answers a parent that measures it before laying it out', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        IntrinsicHeight(
          child: NebaImage(image: _Picture(), alt: 'A ridge', ratio: 2),
        ),
      );

      expect(boxOf(tester), const Size(300, 150));
    });
  });

  group('while it loads', () {
    testWidgets('stands a Skeleton in, the shape of the box', (WidgetTester tester) async {
      await pump(tester, NebaImage(image: _Picture(), alt: 'A ridge', ratio: 2));

      expect(find.byType(NebaSkeleton), findsOneWidget);
      expect(tester.getSize(find.byType(NebaSkeleton)), const Size(300, 150));
    });

    testWidgets('stands one in for a picture that has no file yet', (WidgetTester tester) async {
      await pump(tester, const NebaImage(image: null, alt: 'A ridge', ratio: 2));

      expect(find.byType(NebaSkeleton), findsOneWidget);
    });

    testWidgets('draws no placeholder when told not to', (WidgetTester tester) async {
      await pump(
        tester,
        NebaImage(
          image: _Picture(),
          alt: 'A ridge',
          ratio: 2,
          placeholder: NebaImagePlaceholder.none,
        ),
      );

      expect(find.byType(NebaSkeleton), findsNothing);
    });

    testWidgets('draws a widget of its own', (WidgetTester tester) async {
      await pump(
        tester,
        NebaImage(
          image: _Picture(),
          alt: 'A ridge',
          ratio: 2,
          placeholder: const NebaImagePlaceholder.widget(Text('Loading the ridge')),
        ),
      );

      expect(find.text('Loading the ridge'), findsOneWidget);
      expect(find.byType(NebaSkeleton), findsNothing);
    });

    testWidgets('draws a picture stand-in, blurred and grown past the box', (
      WidgetTester tester,
    ) async {
      final _Picture tiny = _Picture();

      await pump(
        tester,
        NebaImage(
          image: _Picture(),
          alt: 'A ridge',
          ratio: 2,
          rotate: 90,
          placeholder: NebaImagePlaceholder.image(tiny, blur: 20),
        ),
      );

      final Finder stand = find.byWidgetPredicate(
        (Widget widget) => widget is Image && widget.image == tiny,
      );

      expect(stand, findsOneWidget);
      expect(find.byType(NebaSkeleton), findsNothing);
      // Turned the way the picture will be.
      expect(find.ancestor(of: stand, matching: find.byType(RotatedBox)), findsOneWidget);
      expect(find.ancestor(of: stand, matching: find.byType(ImageFiltered)), findsOneWidget);
      expect(
        tester.getSize(find.ancestor(of: stand, matching: find.byType(ImageFiltered))),
        const Size(300 + 80, 150 + 80),
      );
    });

    testWidgets('keeps the stand-in until the picture has faded in over it', (
      WidgetTester tester,
    ) async {
      final _Picture file = _Picture();
      final _Picture tiny = _Picture();

      await pump(
        tester,
        NebaImage(
          image: file,
          alt: 'A ridge',
          ratio: 2,
          placeholder: NebaImagePlaceholder.image(tiny),
        ),
      );

      Finder stand() =>
          find.byWidgetPredicate((Widget widget) => widget is Image && widget.image == tiny);

      await arrive(tester, file);
      expect(stand(), findsOneWidget);

      await tester.pump(NebaScale.durationFill);
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump();
      expect(stand(), findsNothing);
    });

    testWidgets('fades the picture in over the fill pace', (WidgetTester tester) async {
      final _Picture file = _Picture();

      await pump(tester, NebaImage(image: file, alt: 'A ridge', ratio: 2));
      await arrive(tester, file);

      final FadeTransition fade = tester.widget<FadeTransition>(
        find.ancestor(of: picture(), matching: find.byType(FadeTransition)).first,
      );

      expect(fade.opacity.value, lessThan(1));
      expect(find.byType(NebaSkeleton), findsNothing);

      await tester.pump(NebaScale.durationFill);

      expect(fade.opacity.value, 1);
    });

    testWidgets('draws a picture already in the cache at once', (WidgetTester tester) async {
      final ImageInfo info = ImageInfo(image: await decoded(tester));
      final List<NebaImageLoadingStatus> statuses = <NebaImageLoadingStatus>[];

      await pump(
        tester,
        NebaImage(
          image: _Cached(info),
          alt: 'A ridge',
          ratio: 2,
          onLoadingStatusChange: statuses.add,
        ),
      );
      await tester.pump();

      final FadeTransition fade = tester.widget<FadeTransition>(
        find.ancestor(of: picture(), matching: find.byType(FadeTransition)).first,
      );

      expect(fade.opacity.value, 1);
      expect(find.byType(NebaSkeleton), findsNothing);
      expect(statuses, <NebaImageLoadingStatus>[NebaImageLoadingStatus.loaded]);
    });

    testWidgets('draws a priority picture with no fade and no Skeleton', (
      WidgetTester tester,
    ) async {
      final _Picture file = _Picture();

      await pump(tester, NebaImage(image: file, alt: 'A ridge', ratio: 2, priority: true));

      expect(find.byType(NebaSkeleton), findsNothing);

      await arrive(tester, file);

      final FadeTransition fade = tester.widget<FadeTransition>(
        find.ancestor(of: picture(), matching: find.byType(FadeTransition)).first,
      );

      expect(fade.opacity.value, 1);
    });

    testWidgets('reports loading, then loaded', (WidgetTester tester) async {
      final _Picture file = _Picture();
      final List<NebaImageLoadingStatus> statuses = <NebaImageLoadingStatus>[];

      await pump(
        tester,
        NebaImage(image: file, alt: 'A ridge', ratio: 2, onLoadingStatusChange: statuses.add),
      );
      await tester.pump();

      expect(statuses, <NebaImageLoadingStatus>[NebaImageLoadingStatus.loading]);

      await arrive(tester, file);

      expect(statuses, <NebaImageLoadingStatus>[
        NebaImageLoadingStatus.loading,
        NebaImageLoadingStatus.loaded,
      ]);
    });

    testWidgets('reports loading for a picture with no file yet', (WidgetTester tester) async {
      final List<NebaImageLoadingStatus> statuses = <NebaImageLoadingStatus>[];

      await pump(
        tester,
        NebaImage(image: null, alt: 'A ridge', ratio: 2, onLoadingStatusChange: statuses.add),
      );
      await tester.pump();

      expect(statuses, <NebaImageLoadingStatus>[NebaImageLoadingStatus.loading]);
    });

    testWidgets('starts over when the file changes', (WidgetTester tester) async {
      final _Picture first = _Picture();
      final _Picture second = _Picture();
      final List<NebaImageLoadingStatus> statuses = <NebaImageLoadingStatus>[];

      await pump(
        tester,
        NebaImage(image: first, alt: 'A ridge', ratio: 2, onLoadingStatusChange: statuses.add),
      );
      await arrive(tester, first);

      expect(find.byType(NebaSkeleton), findsNothing);

      await pump(
        tester,
        NebaImage(image: second, alt: 'A ridge', ratio: 2, onLoadingStatusChange: statuses.add),
      );
      await tester.pump();

      expect(find.byType(NebaSkeleton), findsOneWidget);
      expect(picture(), findsNothing);
      expect(statuses.last, NebaImageLoadingStatus.loading);
    });
  });

  group('when it fails', () {
    testWidgets('reports it and draws a box carrying the alt', (WidgetTester tester) async {
      final _Picture file = _Picture();
      final List<NebaImageLoadingStatus> statuses = <NebaImageLoadingStatus>[];

      await pump(
        tester,
        NebaImage(image: file, alt: 'A ridge', ratio: 2, onLoadingStatusChange: statuses.add),
      );
      await fail(tester, file);

      expect(statuses.last, NebaImageLoadingStatus.failed);
      expect(find.text('A ridge'), findsOneWidget);
      expect(find.byType(NebaSkeleton), findsNothing);
      expect(
        find
            .ancestor(of: find.text('A ridge'), matching: find.byType(ColoredBox))
            .evaluate()
            .map((Element element) => (element.widget as ColoredBox).color),
        contains(tokens.disabledBg),
      );
    });

    testWidgets('names a failed picture once, by its alt', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final _Picture file = _Picture();

      await pump(tester, NebaImage(image: file, alt: 'A ridge', ratio: 2));
      await fail(tester, file);

      expect(find.bySemanticsLabel('A ridge'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('names its own absence when there is no alt to put there', (
      WidgetTester tester,
    ) async {
      final _Picture file = _Picture();

      await pump(tester, NebaImage(image: file, alt: '', ratio: 2));
      await fail(tester, file);

      expect(find.text('Image unavailable'), findsOneWidget);
    });

    testWidgets("says so in the locale's words, or in its own", (WidgetTester tester) async {
      registerNebaMessages('ko', ko);
      addTearDown(resetNebaMessages);

      final _Picture first = _Picture();
      await pump(tester, NebaImage(image: first, alt: '', ratio: 2, locale: const Locale('ko')));
      await fail(tester, first);

      expect(find.text(resolveNebaMessages('image', 'ko')['unavailable']!), findsOneWidget);

      final _Picture second = _Picture();
      await pump(tester, NebaImage(image: second, alt: '', ratio: 2, unavailableLabel: 'Gone'));
      await fail(tester, second);

      expect(find.text('Gone'), findsOneWidget);
    });

    testWidgets('draws a fallback of its own when given one', (WidgetTester tester) async {
      final _Picture file = _Picture();

      await pump(
        tester,
        NebaImage(image: file, alt: 'A ridge', ratio: 2, fallback: const Text('Try again')),
      );
      await fail(tester, file);

      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('A ridge'), findsNothing);
    });
  });

  group('semantics', () {
    testWidgets('is an image named by its alt', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaImage(image: _Picture(), alt: 'A ridge', ratio: 2));

      expect(
        tester.getSemantics(find.byType(NebaImage)),
        matchesSemantics(isImage: true, label: 'A ridge'),
      );
      semantics.dispose();
    });

    testWidgets('says nothing at all with an empty alt', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaImage(image: _Picture(), alt: '', ratio: 2));

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Semantics && widget.properties.image == true,
        ),
        findsNothing,
      );
      semantics.dispose();
    });
  });

  group('fit and position', () {
    testWidgets('covers by default, at the centre', (WidgetTester tester) async {
      final _Picture file = _Picture();
      await pump(tester, NebaImage(image: file, alt: 'A ridge', ratio: 2));
      await arrive(tester, file);

      final RawImage raw = tester.widget<RawImage>(picture());
      expect(raw.fit, BoxFit.cover);
      expect(raw.alignment, Alignment.center);
    });

    testWidgets('hands the fit and the position to the picture', (WidgetTester tester) async {
      final _Picture file = _Picture();
      await pump(
        tester,
        NebaImage(
          image: file,
          alt: 'A ridge',
          ratio: 2,
          fit: BoxFit.scaleDown,
          position: Alignment.topLeft,
        ),
      );
      await arrive(tester, file);

      final RawImage raw = tester.widget<RawImage>(picture());
      expect(raw.fit, BoxFit.scaleDown);
      expect(raw.alignment, Alignment.topLeft);
    });

    test('keeps the side of the picture the reader sees, through a turn', () {
      // Upside down, the top of what is seen is the bottom of the file.
      expect(
        nebaPlacedAlignment(Alignment.topCenter, 2, NebaImageFlip.none),
        Alignment.bottomCenter,
      );
      // A quarter clockwise draws the file's left edge along the top.
      expect(nebaPlacedAlignment(Alignment.topCenter, 1, NebaImageFlip.none), Alignment.centerLeft);
      expect(
        nebaPlacedAlignment(Alignment.centerRight, 1, NebaImageFlip.none),
        Alignment.topCenter,
      );
    });

    test('keeps the side of the picture the reader sees, through a mirror', () {
      expect(
        nebaPlacedAlignment(Alignment.topLeft, 0, NebaImageFlip.horizontal),
        Alignment.topRight,
      );
      expect(nebaPlacedAlignment(Alignment.topLeft, 0, NebaImageFlip.both), Alignment.bottomRight);
      expect(
        nebaPlacedAlignment(const Alignment(-0.4, -0.6), 0, NebaImageFlip.none),
        const Alignment(-0.4, -0.6),
      );
    });
  });

  group('rotate and flip', () {
    test('reads any number as the nearest quarter turn', () {
      expect(nebaQuarters(0), 0);
      expect(nebaQuarters(90), 1);
      expect(nebaQuarters(-90), 3);
      expect(nebaQuarters(450), 1);
      expect(nebaQuarters(40), 0);
      expect(nebaQuarters(50), 1);
      expect(nebaQuarters(double.nan), 0);
    });

    testWidgets('draws nothing turned or mirrored when neither is asked for', (
      WidgetTester tester,
    ) async {
      final _Picture file = _Picture();
      await pump(tester, NebaImage(image: file, alt: 'A ridge', ratio: 2));
      await arrive(tester, file);

      expect(find.ancestor(of: picture(), matching: find.byType(RotatedBox)), findsNothing);
      expect(find.ancestor(of: picture(), matching: find.byType(Transform)), findsNothing);
    });

    testWidgets('turns the picture inside its box, laid out on its side', (
      WidgetTester tester,
    ) async {
      final _Picture file = _Picture();
      await pump(tester, NebaImage(image: file, alt: 'A ridge', ratio: 2, rotate: 90));
      await arrive(tester, file);

      final RotatedBox turned = tester.widget<RotatedBox>(
        find.ancestor(of: picture(), matching: find.byType(RotatedBox)),
      );

      expect(turned.quarterTurns, 1);
      // Laid out at the box's height by its width.
      expect(tester.getSize(picture()), const Size(150, 300));
      expect(boxOf(tester), const Size(300, 150));
    });

    testWidgets('mirrors along the screen, whatever the turn', (WidgetTester tester) async {
      final _Picture file = _Picture();
      await pump(
        tester,
        NebaImage(
          image: file,
          alt: 'A ridge',
          ratio: 1,
          rotate: 90,
          flip: NebaImageFlip.horizontal,
        ),
      );
      await arrive(tester, file);

      // The mirror is outside the turn, so it runs along the screen's axes.
      final Finder mirror = find.ancestor(
        of: find.byType(RotatedBox),
        matching: find.byType(Transform),
      );
      final Matrix4 transform = tester.widget<Transform>(mirror.first).transform;

      expect(transform.entry(0, 0), -1);
      expect(transform.entry(1, 1), 1);
    });

    testWidgets('reserves the turned shape of the file it was told about', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaImage(image: _Picture(), alt: 'A ridge', width: 1200, height: 800, rotate: 270),
      );

      expect(boxOf(tester).width / boxOf(tester).height, closeTo(800 / 1200, 0.001));
    });

    testWidgets('takes the turned shape of a file nobody described', (WidgetTester tester) async {
      final _Picture file = _Picture();
      await pump(tester, NebaImage(image: file, alt: 'A ridge', rotate: 90));
      await arrive(tester, file, width: 40, height: 20);

      expect(boxOf(tester), const Size(300, 600));
    });
  });

  group('filter', () {
    testWidgets('colours the picture with the matrix a name stands for', (
      WidgetTester tester,
    ) async {
      final _Picture file = _Picture();
      await pump(
        tester,
        NebaImage(image: file, alt: 'A ridge', ratio: 2, filter: NebaImageFilter.grayscale),
      );
      await arrive(tester, file);

      final ColorFiltered filtered = tester.widget<ColorFiltered>(
        find.ancestor(of: picture(), matching: find.byType(ColorFiltered)),
      );

      expect(filtered.colorFilter, ColorFilter.matrix(NebaImageFilter.grayscale.matrix!));
    });

    testWidgets('writes nothing at all when it is none', (WidgetTester tester) async {
      final _Picture file = _Picture();
      await pump(tester, NebaImage(image: file, alt: 'A ridge', ratio: 2));
      await arrive(tester, file);

      expect(find.byType(ColorFiltered), findsNothing);
    });

    testWidgets('travels to a new treatment rather than snapping', (WidgetTester tester) async {
      final _Picture file = _Picture();
      await pump(tester, NebaImage(image: file, alt: 'A ridge', ratio: 2));
      await arrive(tester, file);
      await tester.pump(NebaScale.durationFill);

      await pump(
        tester,
        NebaImage(image: file, alt: 'A ridge', ratio: 2, filter: NebaImageFilter.grayscale),
      );
      await tester.pump(NebaScale.durationFill ~/ 4);

      final ColorFiltered halfway = tester.widget<ColorFiltered>(find.byType(ColorFiltered));
      expect(halfway.colorFilter, isNot(ColorFilter.matrix(NebaImageFilter.grayscale.matrix!)));

      await tester.pumpAndSettle();
      expect(
        tester.widget<ColorFiltered>(find.byType(ColorFiltered)).colorFilter,
        ColorFilter.matrix(NebaImageFilter.grayscale.matrix!),
      );
    });

    test('is the matrix the Filter Effects specification writes', () {
      // contrast(1.25) on a mid grey is the same mid grey.
      final List<double> contrast = NebaImageFilter.contrast.matrix!;
      expect(contrast[0] * 127.5 + contrast[4], closeTo(127.5, 1e-9));
      // invert(1) turns black white.
      final List<double> invert = NebaImageFilter.invert.matrix!;
      expect(invert[0] * 0 + invert[4], 255);
      // A dim after a treatment is the two chained.
      final List<double> dimmed = nebaComposeMatrices(nebaIdentityMatrix, nebaBrightness(0.5));
      expect(dimmed[0], 0.5);
      expect(nebaIsIdentity(nebaComposeMatrices(nebaIdentityMatrix, nebaIdentityMatrix)), isTrue);
    });
  });

  group('letterbox', () {
    testWidgets('paints a colour behind the picture', (WidgetTester tester) async {
      await pump(
        tester,
        NebaImage(
          image: _Picture(),
          alt: 'A ridge',
          ratio: 2,
          fit: BoxFit.contain,
          letterbox: const NebaImageLetterbox.color(Color(0xFF18181B)),
        ),
      );

      final DecoratedBox box = tester.widget<DecoratedBox>(
        find.descendant(of: find.byType(NebaImage), matching: find.byType(DecoratedBox)).first,
      );

      expect((box.decoration as BoxDecoration).color, const Color(0xFF18181B));
    });

    testWidgets('draws the picture blurred behind itself where the fit leaves space', (
      WidgetTester tester,
    ) async {
      final _Picture file = _Picture();
      await pump(
        tester,
        NebaImage(
          image: file,
          alt: 'A ridge',
          ratio: 1,
          fit: BoxFit.contain,
          letterbox: NebaImageLetterbox.blur,
        ),
      );
      await arrive(tester, file);

      expect(picture(), findsNWidgets(2));
      final RawImage copy = tester.widgetList<RawImage>(picture()).first;
      expect(copy.fit, BoxFit.cover);
      expect(find.byType(ImageFiltered), findsOneWidget);
    });

    testWidgets('draws no copy where the fit leaves no space for one', (WidgetTester tester) async {
      final _Picture file = _Picture();
      await pump(
        tester,
        NebaImage(image: file, alt: 'A ridge', ratio: 1, letterbox: NebaImageLetterbox.blur),
      );
      await arrive(tester, file);

      expect(picture(), findsOneWidget);
    });
  });

  group('frame', () {
    ShapeBorder clipOf(WidgetTester tester) {
      final ClipPath clip = tester.widget<ClipPath>(
        find.descendant(of: find.byType(NebaImage), matching: find.byType(ClipPath)),
      );

      return (clip.clipper! as ShapeBorderClipper).shape;
    }

    testWidgets('cuts the silhouette a shape names', (WidgetTester tester) async {
      await pump(
        tester,
        NebaImage(
          image: _Picture(),
          alt: 'A ridge',
          ratio: 2,
          frame: const NebaImageFrame(shape: NebaImageFrameShape.circle),
        ),
      );

      final Path path = clipOf(tester).getOuterPath(Offset.zero & const Size(300, 150));
      expect(path.contains(const Offset(150, 75)), isTrue);
      expect(path.contains(const Offset(4, 4)), isFalse);
      expect(path.contains(const Offset(296, 146)), isFalse);
    });

    testWidgets('chamfers a cut corner on the diagonal', (WidgetTester tester) async {
      await pump(
        tester,
        NebaImage(
          image: _Picture(),
          alt: 'A ridge',
          ratio: 2,
          frame: const NebaImageFrame(shape: NebaImageFrameShape.cut, cornerRadius: 20),
        ),
      );

      final Path path = clipOf(tester).getOuterPath(Offset.zero & const Size(300, 150));
      expect(path.contains(const Offset(5, 5)), isFalse);
      expect(path.contains(const Offset(15, 15)), isTrue);
    });

    testWidgets('takes the corner from rounded when the frame does not say', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaImage(
          image: _Picture(),
          alt: 'A ridge',
          ratio: 2,
          rounded: NebaSize.xl,
          frame: const NebaImageFrame(),
        ),
      );

      final Path path = clipOf(tester).getOuterPath(Offset.zero & const Size(300, 150));
      final double radius = tokens.radius[NebaSize.xl]!;
      // Just inside the corner's curve is outside the shape.
      expect(path.contains(Offset(radius * 0.2, radius * 0.2)), isFalse);
    });

    testWidgets('mounts the picture on a mat, with a shadow under it and a line over it', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaImage(
          image: _Picture(),
          alt: 'A ridge',
          ratio: 1,
          frame: const NebaImageFrame(mat: 10, border: 1, elevation: 2),
        ),
      );

      final ShapeDecoration mount =
          tester
                  .widget<DecoratedBox>(
                    find
                        .descendant(of: find.byType(NebaImage), matching: find.byType(DecoratedBox))
                        .first,
                  )
                  .decoration
              as ShapeDecoration;

      expect(mount.color, tokens.surface);
      expect(mount.shadows, tokens.elevation(2));
      expect(boxOf(tester), const Size(300, 300));
      // The mat takes room: the picture is 20 narrower than the mount.
      expect(
        tester.getSize(
          find.descendant(of: find.byType(NebaImage), matching: find.byType(ClipPath)),
        ),
        const Size(280, 280),
      );
      expect(
        find.descendant(
          of: find.byType(NebaImage),
          matching: find.byWidgetPredicate(
            (Widget widget) => widget is CustomPaint && widget.foregroundPainter != null,
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('feathers the edge instead of cutting it', (WidgetTester tester) async {
      await pump(
        tester,
        NebaImage(
          image: _Picture(),
          alt: 'A ridge',
          ratio: 2,
          frame: const NebaImageFrame(shape: NebaImageFrameShape.rect, featherFraction: 0.1),
        ),
      );

      expect(find.byType(ShaderMask), findsNWidgets(2));
    });
  });

  group('watermark', () {
    testWidgets('draws a line of text the picture keeps to itself', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaImage(
          image: _Picture(),
          alt: 'A ridge',
          ratio: 2,
          watermark: const NebaImageWatermark('© Neba'),
        ),
      );

      expect(find.text('© Neba'), findsOneWidget);
      expect(find.bySemanticsLabel('© Neba'), findsNothing);
      expect(
        find.ancestor(of: find.text('© Neba'), matching: find.byType(IgnorePointer)),
        findsWidgets,
      );
      // In the bottom corner at the end, 8 pixels in.
      final Offset end = tester.getBottomRight(find.text('© Neba'));
      expect(end.dx, closeTo(300 - 8, 0.5));
      expect(end.dy, closeTo(150 - 8, 0.5));
      semantics.dispose();
    });

    testWidgets('tiles it instead when it is asked to repeat', (WidgetTester tester) async {
      await pump(
        tester,
        NebaImage(
          image: _Picture(),
          alt: 'A ridge',
          ratio: 2,
          watermark: const NebaImageWatermark('PROOF', repeat: true, opacity: 0.22),
        ),
      );

      expect(find.text('PROOF'), findsNothing);
      final Opacity strength = tester.widget<Opacity>(
        find.descendant(of: find.byType(NebaWatermarkLayer), matching: find.byType(Opacity)),
      );
      expect(strength.opacity, 0.22);
    });
  });

  group('protect', () {
    testWidgets('draws nothing in the way where there is no browser menu', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaImage(image: _Picture(), alt: 'A ridge', ratio: 2, protect: true));

      expect(find.byType(NebaPictureGuard), findsOneWidget);
      expect(
        find.descendant(of: find.byType(NebaPictureGuard), matching: find.byType(MouseRegion)),
        findsNothing,
      );
    });
  });

  group('preview', () {
    testWidgets('is not a button without it', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaImage(image: _Picture(), alt: 'A ridge', ratio: 2));

      expect(find.byType(NebaModalLayer), findsNothing);
      expect(tester.getSemantics(find.byType(NebaImage)), isNot(matchesSemantics(isButton: true)));
      semantics.dispose();
    });

    testWidgets('becomes a button named by its alt', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaImage(image: _Picture(), alt: 'A ridge', ratio: 2, preview: true));

      expect(
        tester.getSemantics(find.byType(NebaInteractive)),
        matchesSemantics(
          isButton: true,
          label: 'A ridge',
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('names a picture with an empty alt by what it does', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaImage(image: _Picture(), alt: '', ratio: 2, preview: true));

      expect(find.bySemanticsLabel('Enlarge image'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('opens the full picture on a sheet titled by its alt, and closes', (
      WidgetTester tester,
    ) async {
      final _Picture file = _Picture();

      await pump(
        tester,
        NebaImage(
          image: file,
          alt: 'A ridge',
          ratio: 2,
          preview: true,
          rotate: 180,
          flip: NebaImageFlip.horizontal,
          watermark: const NebaImageWatermark('© Neba'),
        ),
      );
      await tester.tap(find.byType(NebaImage));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(NebaViewerSheet), findsOneWidget);
      expect(
        find.descendant(of: find.byType(NebaViewerSheet), matching: find.text('A ridge')),
        findsOneWidget,
      );

      final NebaViewerPicture enlarged = tester.widget<NebaViewerPicture>(
        find.byType(NebaViewerPicture),
      );
      expect(enlarged.image, file);
      expect(enlarged.quarters, 2);
      expect(enlarged.flip, NebaImageFlip.horizontal);
      expect(enlarged.watermark?.text, '© Neba');

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(NebaViewerSheet), findsNothing);
    });

    testWidgets('opens from the keyboard and hands the focus back', (WidgetTester tester) async {
      await pump(
        tester,
        Column(
          children: <Widget>[NebaImage(image: _Picture(), alt: 'A ridge', ratio: 2, preview: true)],
        ),
      );

      final FocusNode node = Focus.of(tester.element(find.byType(NebaFocusRing)));
      node.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(NebaViewerSheet), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(NebaViewerSheet), findsNothing);
      expect(node.hasFocus, isTrue);
    });
  });
}
