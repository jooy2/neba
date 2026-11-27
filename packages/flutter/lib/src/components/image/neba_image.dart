/// `NebaImage`, a picture that holds its space while it loads, shows that it
/// is loading, and shows something useful when it fails.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/skeleton/neba_skeleton.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/modal.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/picture.dart';
import 'package:neba/src/internal/viewer.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

export 'package:neba/src/internal/picture.dart'
    show NebaImageFilter, NebaImageFlip, NebaImageWatermark;

/// Where a [NebaImage] is in its own life.
enum NebaImageLoadingStatus {
  /// The file has been asked for, or there is no file to ask for yet.
  loading,

  /// It arrived.
  loaded,

  /// It did not.
  failed,
}

/// The silhouette a [NebaImageFrame] cuts the picture to.
enum NebaImageFrameShape {
  /// Square corners.
  rect,

  /// Corners rounded at the frame's corner.
  rounded,

  /// A circle, or an ellipse in a box that is not square.
  circle,

  /// Corners cut off on the diagonal.
  cut,

  /// A round top over rounded bottom corners.
  arch,
}

/// What fills the part of the box a picture leaves empty under
/// [BoxFit.contain], [BoxFit.none] or [BoxFit.scaleDown].
@immutable
class NebaImageLetterbox {
  const NebaImageLetterbox._({this.blurred = false}) : color = null, decoration = null;

  /// A colour of your own.
  const NebaImageLetterbox.color(Color this.color) : blurred = false, decoration = null;

  /// A decoration of your own: a gradient, an image. The React package's CSS
  /// `background`.
  const NebaImageLetterbox.decoration(Decoration this.decoration) : blurred = false, color = null;

  /// Nothing: the box stays transparent.
  static const NebaImageLetterbox none = NebaImageLetterbox._();

  /// The picture itself, covering the box and blurred behind it, the way a
  /// video player fills the sides of a portrait clip. It is drawn from the
  /// file the picture is drawn from, so it is not a second download.
  static const NebaImageLetterbox blur = NebaImageLetterbox._(blurred: true);

  /// Whether this is [blur].
  final bool blurred;

  /// The colour, for one made with [NebaImageLetterbox.color].
  final Color? color;

  /// The decoration, for one made with [NebaImageLetterbox.decoration].
  final Decoration? decoration;
}

/// What stands in while the file is arriving.
@immutable
class NebaImagePlaceholder {
  const NebaImagePlaceholder._() : child = null, image = null, blur = 0;

  /// A widget of your own, laid over the box.
  const NebaImagePlaceholder.widget(Widget this.child) : image = null, blur = 0;

  /// A picture instead of a Skeleton: a small copy of the same file, drawn
  /// the way the picture will be, with the same fit, position, turn and
  /// mirror, so the reader sees its colours and shape before its detail.
  /// [blur] softens a copy stretched up from a few pixels; React's
  /// `blur: true` is 20.
  const NebaImagePlaceholder.image(ImageProvider this.image, {this.blur = 0})
    : child = null,
      assert(blur >= 0);

  /// Nothing at all: React's `placeholder={false}`.
  static const NebaImagePlaceholder none = NebaImagePlaceholder._();

  /// The widget, for one made with [NebaImagePlaceholder.widget].
  final Widget? child;

  /// The stand-in picture, for one made with [NebaImagePlaceholder.image].
  final ImageProvider? image;

  /// How far the stand-in picture is blurred, as a standard deviation in
  /// logical pixels, CSS `blur()`.
  final double blur;
}

/// How a picture is mounted: the silhouette it is cut to, and the line, the
/// mount, the shadow and the softened edge around it.
@immutable
class NebaImageFrame {
  /// A frame of [shape], with whatever else is asked for around it.
  const NebaImageFrame({
    this.shape = NebaImageFrameShape.rounded,
    this.corner,
    this.cornerRadius,
    this.border = 0,
    this.borderColor,
    this.mat = 0,
    this.background,
    this.elevation = 0,
    this.feather = 0,
    this.featherFraction = 0,
  }) : assert(border >= 0),
       assert(mat >= 0),
       assert(feather >= 0),
       assert(featherFraction >= 0 && featherFraction <= 0.5);

  /// The silhouette.
  final NebaImageFrameShape shape;

  /// How big the corner treatment is, a step of the radius ladder. Defaults
  /// to the image's `rounded`, and to [NebaSize.md] when that says nothing.
  final NebaSize? corner;

  /// The corner in logical pixels, over [corner].
  final double? cornerRadius;

  /// A line around the picture, this many pixels wide; `1` is React's `true`,
  /// a hairline. It is drawn over the picture, along the outer edge of the
  /// mount, and takes no room.
  final double border;

  /// What colour the line is. Defaults to the house hairline.
  final Color? borderColor;

  /// The mount: space between the line and the picture, in logical pixels.
  /// The one part of a frame that takes room.
  final double mat;

  /// What fills the mount. Defaults to the page's surface when there is a
  /// [mat].
  final Color? background;

  /// The drop shadow under the mount, on the house ladder.
  final NebaElevation elevation;

  /// Fades the picture's edge out over this many pixels instead of cutting
  /// it.
  final double feather;

  /// Fades the edge out over this fraction of the picture's width at the
  /// sides and of its height at the top and the bottom, React's `'8%'`. Over
  /// [feather] when both are given.
  final double featherFraction;
}

/// A picture that holds its space, says when it is loading and says when it
/// failed.
///
/// Flutter's `Image` does none of the three on its own: an unsized picture
/// moves what is below it when it lands, a slow one leaves a hole with no
/// explanation, and a broken one draws nothing. A NebaImage reserves the box
/// from [ratio], or from [width] and [height], before anything has arrived,
/// stands a Skeleton of the box's shape in while the file arrives, fades the
/// picture in over it, and says what was meant to be there when the file
/// does not arrive.
///
/// [alt] is required, which is deliberate: an empty one says the picture
/// tells a reader nothing the text around it does not, and is the only
/// other answer that is ever right.
///
/// ```dart
/// NebaImage(
///   image: const AssetImage('assets/tea.jpg'),
///   alt: 'Terraced tea fields under morning mist',
///   ratio: 16 / 9,
///   rounded: NebaSize.md,
/// )
/// ```
class NebaImage extends StatefulWidget {
  /// A picture of [image], described by [alt].
  const NebaImage({
    required this.image,
    required this.alt,
    this.ratio,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.position,
    this.letterbox = NebaImageLetterbox.none,
    this.rounded,
    this.placeholder,
    this.fallback,
    this.onLoadingStatusChange,
    this.priority = false,
    this.preview = false,
    this.filter = NebaImageFilter.none,
    this.rotate = 0,
    this.flip = NebaImageFlip.none,
    this.frame,
    this.watermark,
    this.protect = false,
    this.locale,
    this.unavailableLabel,
    super.key,
  }) : assert(ratio == null || ratio > 0),
       assert(width == null || width >= 0),
       assert(height == null || height >= 0);

  /// The file. `null` is a picture still waiting for one, which stands its
  /// placeholder in for as long as it stays `null`. A new provider is a
  /// different picture and starts over.
  final ImageProvider? image;

  /// What the picture says, which a screen reader reads as its name. Write
  /// what the picture says, not what it is a picture of; an empty string for
  /// one that says nothing the text around it does not.
  final String alt;

  /// The proportion to hold, width over height, while the file is still
  /// arriving and after. Left out, the file decides once it is in, and
  /// [width] and [height] are how you tell it what the file will say.
  final double? ratio;

  /// The file's own pixel width, with [height]: together they are the
  /// picture's proportion stated in advance, and not a size, so the box
  /// spans the width it is given. On its own, the width of the box, never
  /// wider than what it is given, and as tall as the picture.
  final double? width;

  /// The file's own pixel height, with [width]. On its own, the height of
  /// the box across the width it is given, or across [ratio]'s width when
  /// there is one.
  final double? height;

  /// How the picture fills its box, CSS `object-fit`.
  final BoxFit fit;

  /// Where the picture sits in its box: which part survives a
  /// [BoxFit.cover] crop, and where the other fits leave their space. Read on
  /// the picture as it is shown, so it holds through [rotate] and [flip], and
  /// physical rather than directional: the subject of a photograph is on the
  /// left of it in every language. Defaults to the centre.
  final Alignment? position;

  /// What fills the space [BoxFit.contain], [BoxFit.none] and
  /// [BoxFit.scaleDown] leave. The blurred copy is only drawn under a fit
  /// that can leave space.
  final NebaImageLetterbox letterbox;

  /// Rounds the corners at this step of the radius ladder; `null` for
  /// square.
  final NebaSize? rounded;

  /// What stands in while the file is arriving: a Skeleton of the box's
  /// shape by default, a widget of your own, a picture, or
  /// [NebaImagePlaceholder.none]. Like the Skeleton, it fills the box, so it
  /// needs one to fill: a [ratio], or [width] and [height].
  final NebaImagePlaceholder? placeholder;

  /// What is drawn instead when the file does not arrive. Defaults to a box
  /// carrying the [alt].
  final Widget? fallback;

  /// Called with [NebaImageLoadingStatus.loading] when a file is asked for,
  /// then [NebaImageLoadingStatus.loaded] or [NebaImageLoadingStatus.failed]
  /// once it settles. A file already in the cache says it is loaded straight
  /// away.
  final ValueChanged<NebaImageLoadingStatus>? onLoadingStatusChange;

  /// Draws the picture with no fade and no Skeleton: the picture a screen is
  /// judged by. A picture placeholder still stands beneath it while it
  /// arrives.
  final bool priority;

  /// Opens the full picture over the page when it is pressed, at its own
  /// size and never enlarged. The picture becomes a button named by its
  /// [alt], so the keyboard reaches it and Enter opens it. Needs an
  /// [Overlay] above it.
  final bool preview;

  /// How the picture is coloured. A change travels over the fill's pace
  /// rather than snapping.
  final NebaImageFilter filter;

  /// Turns the picture clockwise, in degrees, a quarter at a time: any other
  /// number is the nearest quarter. A picture on its side is laid out on its
  /// side: [width] and [height] still describe the file, and with neither
  /// the box takes the turned shape once the file is in. A [ratio] is the
  /// layout's and is kept.
  final int rotate;

  /// Mirrors the picture along the axes it is shown on.
  final NebaImageFlip flip;

  /// How the picture is mounted.
  final NebaImageFrame? frame;

  /// A mark drawn over the picture, and over its preview.
  final NebaImageWatermark? watermark;

  /// Holds the browser's own menu off while the pointer is over the
  /// picture, on the web, which is the one way a Flutter picture is casually
  /// taken. A deterrent and not a lock.
  final bool protect;

  /// The language the box says the picture is unavailable in, and its
  /// preview's button is named in. Defaults to `NebaProvider`'s, then the
  /// app's.
  final Locale? locale;

  /// What the box says when the file does not arrive and [alt] is empty.
  /// Defaults to the [locale]'s wording.
  final String? unavailableLabel;

  /// How far a blurred letterbox is blurred: a standard deviation, as CSS
  /// `blur(24px)` is.
  static const double letterboxBlur = 24;

  @override
  State<NebaImage> createState() => _NebaImageState();
}

class _NebaImageState extends State<NebaImage> with SingleTickerProviderStateMixin {
  ImageStream? _stream;
  ImageInfo? _info;
  NebaImageLoadingStatus _status = NebaImageLoadingStatus.loading;
  bool _resolving = false;
  bool _started = false;
  bool _open = false;

  /// How far the picture has faded in.
  late final AnimationController _fade = AnimationController(vsync: this)
    ..addStatusListener((AnimationStatus status) {
      // The stand-in picture goes once the picture covers it.
      if (status == AnimationStatus.completed && mounted) {
        setState(() {});
      }
    });

  late final ImageStreamListener _listener = ImageStreamListener(_arrived, onError: _failed);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(NebaImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.image != oldWidget.image) {
      _resolve();
    }
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    _info?.dispose();
    _fade.dispose();
    super.dispose();
  }

  void _resolve() {
    final ImageProvider? image = widget.image;

    if (image == null) {
      // Said on the first build and whenever a file is taken away, as a
      // picture with nothing to show is a picture still loading.
      final bool had = !_started || _stream != null || _status != NebaImageLoadingStatus.loading;
      _started = true;
      _stream?.removeListener(_listener);
      _stream = null;
      _replaceInfo(null);
      _fade.value = 0;
      _status = NebaImageLoadingStatus.loading;

      if (had) {
        _report(_status);
      }

      return;
    }

    final ImageStream stream = image.resolve(createLocalImageConfiguration(context));

    if (stream.key == _stream?.key) {
      return;
    }

    _started = true;

    // A different file is a different picture, so it starts over: without
    // this a second file inherits the first one's success and never shows a
    // placeholder, and a second file that fails inherits it too.
    _stream?.removeListener(_listener);
    _stream = stream;
    _replaceInfo(null);
    _fade.value = 0;
    _status = NebaImageLoadingStatus.loading;
    _resolving = true;
    // A file already in the cache arrives inside this call.
    stream.addListener(_listener);
    _resolving = false;
    // Said once the call is over, so a caller hears `loaded` alone for a file
    // that was already in, and `loading` first for one that is on its way.
    _report(_status);
  }

  void _arrived(ImageInfo info, bool synchronousCall) {
    final bool first = _info == null;

    setState(() => _replaceInfo(info));

    if (first) {
      // A picture that was already in is drawn at once: nothing was ever
      // painted without it, so there is nothing to fade from.
      if (synchronousCall || _resolving || widget.priority || nebaReducedMotion(context)) {
        _fade.value = 1;
      } else {
        _fade.duration = NebaScale.durationFill;
        _fade.forward(from: 0);
      }
    }

    _setStatus(NebaImageLoadingStatus.loaded);
  }

  void _failed(Object error, StackTrace? stackTrace) {
    // A picture that fails is not an error the app has to hear about: the
    // fallback is what it is for.
    setState(() => _replaceInfo(null));
    _setStatus(NebaImageLoadingStatus.failed);
  }

  void _replaceInfo(ImageInfo? info) {
    _info?.dispose();
    _info = info;
  }

  void _setStatus(NebaImageLoadingStatus status) {
    if (_status == status) {
      return;
    }

    setState(() => _status = status);

    if (!_resolving) {
      _report(status);
    }
  }

  void _report(NebaImageLoadingStatus status) {
    final ValueChanged<NebaImageLoadingStatus>? report = widget.onLoadingStatusChange;

    if (report == null) {
      return;
    }

    // After the frame, since a status can change while the picture is being
    // built, and a caller's own setState must not land inside that.
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted) {
        report(status);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final Map<String, String> messages = nebaMessages(context, 'image', locale: widget.locale);
    final int quarters = nebaQuarters(widget.rotate);
    final bool sideways = quarters.isOdd;
    final Alignment placed = nebaPlacedAlignment(
      widget.position ?? Alignment.center,
      quarters,
      widget.flip,
    );
    final ImageInfo? info = _info;
    final Size? natural = info == null
        ? null
        : Size(info.image.width / info.scale, info.image.height / info.scale);
    final double? width = widget.width;
    final double? height = widget.height;
    final Size? declared = width != null && height != null && width > 0 && height > 0
        ? Size(width, height)
        : null;
    final double? loneWidth = height == null ? width : null;
    final double? loneHeight = width == null ? height : null;
    // What the box is as wide as when nothing gives it a width to fill: the
    // file it was told about, or the file that arrived, on its side if turned.
    final Size? file = declared ?? natural;
    final Size? shown = file == null || !sideways ? file : file.flipped;

    // The box's proportion. An explicit ratio is the layout's and outranks
    // everything; two dimensions are the file's, stated in advance; and with
    // neither the file says once it is in. A lone height leaves the width to
    // what the box is given unless a ratio says otherwise.
    final double? proportion =
        widget.ratio ??
        (declared != null || loneHeight == null
            ? (shown == null || shown.height == 0 ? null : shown.width / shown.height)
            : null);
    final bool narrowed = loneWidth != null || (loneHeight != null && widget.ratio != null);

    final NebaImageFrame? frame = widget.frame;
    final double corner = frame == null
        ? (widget.rounded == null ? 0 : tokens.radius[widget.rounded]!)
        : frame.cornerRadius ?? tokens.radius[frame.corner ?? widget.rounded ?? NebaSize.md]!;
    final NebaImageFrameShape shape = frame == null
        ? (widget.rounded == null ? NebaImageFrameShape.rect : NebaImageFrameShape.rounded)
        : frame.shape;

    Widget box = _stack(context, tokens, messages, placed: placed, quarters: quarters);

    final Decoration? painted = widget.letterbox.decoration ?? _colour(widget.letterbox.color);

    if (painted != null) {
      box = DecoratedBox(decoration: painted, child: box);
    }

    box = shape == NebaImageFrameShape.rect
        ? ClipRect(child: box)
        : ClipPath(
            clipper: ShapeBorderClipper(shape: _FrameBorder(shape, corner)),
            child: box,
          );

    if (frame != null && (frame.feather > 0 || frame.featherFraction > 0)) {
      box = _Feathered(pixels: frame.feather, fraction: frame.featherFraction, child: box);
    }

    box = _ImageBox(
      ratio: proportion,
      width: loneWidth,
      height: loneHeight,
      fallback: shown,
      child: box,
    );

    if (frame != null) {
      box = _mount(tokens, frame, shape, corner, box);
    }

    final String alt = widget.alt;

    if (!widget.preview) {
      box = alt.isEmpty ? box : Semantics(container: true, image: true, label: alt, child: box);

      return narrowed ? _start(box) : box;
    }

    final String name = alt.isEmpty ? messages['preview']! : alt;
    final BorderRadius ring = BorderRadius.circular(
      widget.rounded == null ? 0 : tokens.radius[widget.rounded]!,
    );

    Widget button = Semantics(
      container: true,
      button: true,
      label: name,
      child: NebaInteractive(
        onTap: () => setState(() => _open = true),
        cursor: SystemMouseCursors.zoomIn,
        builder: (BuildContext context, NebaInteraction interaction, _) {
          return NebaFocusRing(
            visible: interaction.focusVisible,
            color: tokens.roles(NebaColor.primary).ring,
            borderRadius: ring,
            child: ExcludeSemantics(child: box),
          );
        },
      ),
    );

    if (narrowed) {
      button = _start(button);
    }

    final ImageProvider? image = widget.image;

    return NebaModalLayer(
      open: _open,
      onDismiss: () => setState(() => _open = false),
      builder: (BuildContext context, Animation<double> arrival) {
        return nebaViewerSurface(
          arrival,
          NebaViewerSheet(
            title: name,
            closeLabel: nebaMessages(context, 'action', locale: widget.locale)['close']!,
            onClose: () => setState(() => _open = false),
            child: Center(
              child: image == null
                  ? const SizedBox.shrink()
                  : NebaViewerPicture(
                      image: image,
                      alt: alt,
                      unavailableLabel: widget.unavailableLabel ?? messages['unavailable']!,
                      quarters: quarters,
                      flip: widget.flip,
                      filter: widget.filter.matrix,
                      watermark: widget.watermark,
                      protect: widget.protect,
                    ),
            ),
          ),
        );
      },
      child: button,
    );
  }

  Widget _start(Widget child) {
    // A box narrower than what it is given keeps its width at the start of
    // it, as a block of that width does, rather than being stretched across.
    return Align(
      alignment: AlignmentDirectional.topStart,
      widthFactor: 1,
      heightFactor: 1,
      child: child,
    );
  }

  Decoration? _colour(Color? color) => color == null ? null : BoxDecoration(color: color);

  /// The picture with whatever stands under it and over it, filling the box.
  Widget _stack(
    BuildContext context,
    NebaTokens tokens,
    Map<String, String> messages, {
    required Alignment placed,
    required int quarters,
  }) {
    final ImageInfo? info = _info;
    final NebaImageFlip flip = widget.flip;
    final List<double>? tint = widget.filter.matrix;
    final NebaImagePlaceholder? placeholder = widget.placeholder;
    final ImageProvider? stand = placeholder?.image;
    final bool failed = _status == NebaImageLoadingStatus.failed;
    final bool loaded = _status == NebaImageLoadingStatus.loaded;
    final BoxFit fit = widget.fit;
    final List<Widget> layers = <Widget>[];

    // The blurred copy behind the picture, drawn only where it can show, and
    // from the picture's own file: grown past the box by two radii on every
    // side, so the blur's fringe is clipped rather than letting the page in.
    if (widget.letterbox.blurred && fit != BoxFit.cover && fit != BoxFit.fill && info != null) {
      layers.add(
        _bleed(
          NebaImage.letterboxBlur * 2,
          FadeTransition(
            opacity: _fade,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(
                sigmaX: NebaImage.letterboxBlur,
                sigmaY: NebaImage.letterboxBlur,
              ),
              child: nebaPose(
                quarters: quarters,
                flip: flip,
                child: NebaColorTreated(
                  matrix: tint,
                  child: RawImage(
                    image: info.image,
                    scale: info.scale,
                    fit: BoxFit.cover,
                    alignment: placed,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // The stand-in picture, under the picture rather than over it: the
    // picture fades in on top of it, and it goes once that fade has run, so
    // the two are never both half there with the page showing through. Gone
    // when the file fails, since the fallback says that instead.
    if (stand != null && !failed && !(loaded && _fade.isCompleted)) {
      final double blur = placeholder!.blur;
      Widget copy = nebaPose(
        quarters: quarters,
        flip: flip,
        child: Image(
          image: stand,
          fit: fit,
          alignment: placed,
          excludeFromSemantics: true,
          gaplessPlayback: true,
        ),
      );

      if (blur > 0) {
        copy = ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: copy,
        );
      }

      layers.add(_bleed(blur * 2, copy));
    }

    if (info != null) {
      layers.add(
        Positioned.fill(
          child: FadeTransition(
            opacity: _fade,
            child: _Picture(
              info: info,
              fit: fit,
              alignment: placed,
              quarters: quarters,
              flip: flip,
              tint: tint,
            ),
          ),
        ),
      );
    }

    // What stands in while the file arrives, over the box: the picture is not
    // there to be covered yet.
    if (_status == NebaImageLoadingStatus.loading && stand == null && !widget.priority) {
      final Widget? own = placeholder?.child;
      final bool none = placeholder != null && placeholder.child == null;

      if (!none) {
        layers.add(
          Positioned.fill(
            child:
                own ??
                NebaSkeleton(shape: NebaSkeletonShape.rect, size: widget.rounded ?? NebaSize.md),
          ),
        );
      }
    }

    if (failed) {
      final Widget? fallback = widget.fallback;
      final String alt = widget.alt;

      layers.add(
        Positioned.fill(
          child: ColoredBox(
            color: tokens.disabledBg,
            child: Center(
              child:
                  fallback ??
                  ExcludeSemantics(
                    // The words are the picture's name when it has one, and a
                    // screen reader has already heard them.
                    excluding: alt.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        alt.isNotEmpty ? alt : widget.unavailableLabel ?? messages['unavailable']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: tokens.mutedFg, fontSize: 14, height: 20 / 14),
                      ),
                    ),
                  ),
            ),
          ),
        ),
      );
    }

    final NebaImageWatermark? mark = widget.watermark;

    if (mark != null) {
      layers.add(Positioned.fill(child: NebaWatermarkLayer(mark: mark)));
    }

    return NebaPictureGuard(
      enabled: widget.protect,
      child: Stack(fit: StackFit.expand, children: layers),
    );
  }

  Widget _bleed(double by, Widget child) {
    return Positioned(
      left: -by,
      top: -by,
      right: -by,
      bottom: -by,
      child: ExcludeSemantics(child: IgnorePointer(child: child)),
    );
  }

  /// The mount: the shadow and the fill under the picture, the room around
  /// it, and the line over the outer edge, all on the frame's silhouette.
  Widget _mount(
    NebaTokens tokens,
    NebaImageFrame frame,
    NebaImageFrameShape shape,
    double corner,
    Widget box,
  ) {
    final double mat = frame.mat;
    final _FrameBorder outer = _FrameBorder(shape, corner + mat);
    final Color? fill = frame.background ?? (mat > 0 ? tokens.surface : null);

    Widget mounted = DecoratedBox(
      decoration: ShapeDecoration(
        shape: outer,
        color: fill,
        shadows: frame.elevation > 0 ? tokens.elevation(frame.elevation) : null,
      ),
      child: Padding(padding: EdgeInsets.all(mat), child: box),
    );

    if (frame.border > 0) {
      mounted = CustomPaint(
        foregroundPainter: _LinePainter(
          shape: outer,
          width: frame.border,
          color: frame.borderColor ?? tokens.border,
        ),
        child: mounted,
      );
    }

    return mounted;
  }
}

/// The picture itself: the file at the fit and the position asked for,
/// turned, mirrored and coloured, with a Gallery tile's treatment on it.
class _Picture extends StatelessWidget {
  const _Picture({
    required this.info,
    required this.fit,
    required this.alignment,
    required this.quarters,
    required this.flip,
    required this.tint,
  });

  final ImageInfo info;
  final BoxFit fit;
  final Alignment alignment;
  final int quarters;
  final NebaImageFlip flip;
  final List<double>? tint;

  @override
  Widget build(BuildContext context) {
    final NebaPictureTreatment? treatment = NebaPictureTreatment.maybeOf(context);
    final double brightness = treatment?.brightness ?? 1;
    final List<double>? own = tint;
    // A dim on top of a treatment of the caller's own, as a filter chain.
    final List<double>? matrix = brightness == 1 && treatment == null
        ? own
        : nebaComposeMatrices(own ?? nebaIdentityMatrix, nebaBrightness(brightness));

    Widget picture = nebaPose(
      quarters: quarters,
      flip: flip,
      child: RawImage(image: info.image, scale: info.scale, fit: fit, alignment: alignment),
    );

    picture = NebaColorTreated(matrix: matrix, child: picture);

    if (treatment != null) {
      picture = NebaPictureZoom(scale: treatment.scale, child: picture);
    }

    return picture;
  }
}

/// The box a picture is drawn in, sized before anything has arrived.
///
/// With a [width] alone it is that wide, never wider than it is given, and
/// as tall as [ratio] makes it; with a [height] alone it is that tall, and
/// as wide as [ratio] makes it or as wide as it is given; otherwise it takes
/// the width it is given and [ratio] decides the height. Given no width to
/// take, as in a row, it is as wide as [fallback], the file it knows about.
/// It reports intrinsic and dry sizes from the same arithmetic, so a parent
/// that measures before it lays out sees the box it will get.
class _ImageBox extends SingleChildRenderObjectWidget {
  const _ImageBox({
    required this.ratio,
    required this.width,
    required this.height,
    required this.fallback,
    super.child,
  });

  final double? ratio;
  final double? width;
  final double? height;
  final Size? fallback;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderImageBox(ratio: ratio, width: width, height: height, fallback: fallback);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderImageBox renderObject) {
    renderObject
      ..ratio = ratio
      ..width = width
      ..height = height
      ..fallback = fallback;
  }
}

class _RenderImageBox extends RenderProxyBox {
  _RenderImageBox({double? ratio, double? width, double? height, Size? fallback})
    : _ratio = ratio,
      _width = width,
      _height = height,
      _fallback = fallback;

  double? _ratio;
  double? get ratio => _ratio;
  set ratio(double? value) {
    if (value != _ratio) {
      _ratio = value;
      markNeedsLayout();
    }
  }

  double? _width;
  double? get width => _width;
  set width(double? value) {
    if (value != _width) {
      _width = value;
      markNeedsLayout();
    }
  }

  double? _height;
  double? get height => _height;
  set height(double? value) {
    if (value != _height) {
      _height = value;
      markNeedsLayout();
    }
  }

  Size? _fallback;
  Size? get fallback => _fallback;
  set fallback(Size? value) {
    if (value != _fallback) {
      _fallback = value;
      markNeedsLayout();
    }
  }

  Size _sizeFor(BoxConstraints constraints) {
    final double? ratio = _ratio;
    final double? lone = _width;
    final double? tall = _height;
    final Size? fallback = _fallback;
    double width;
    double height;

    if (lone != null) {
      width = constraints.hasBoundedWidth ? math.min(lone, constraints.maxWidth) : lone;
      height = ratio == null ? 0 : width / ratio;
    } else if (tall != null) {
      height = tall;

      if (ratio != null) {
        width = tall * ratio;
        width = constraints.hasBoundedWidth ? math.min(width, constraints.maxWidth) : width;
      } else if (constraints.hasBoundedWidth) {
        width = constraints.maxWidth;
      } else {
        width = fallback == null || fallback.height == 0
            ? 0
            : tall * fallback.width / fallback.height;
      }
    } else {
      width = constraints.hasBoundedWidth ? constraints.maxWidth : fallback?.width ?? 0;
      height = ratio == null ? 0 : width / ratio;
    }

    return constraints.constrain(Size(width, height));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => _sizeFor(constraints);

  @override
  void performLayout() {
    size = _sizeFor(constraints);
    child?.layout(BoxConstraints.tight(size));
  }

  double _intrinsicWidth(double height) {
    final double? ratio = _ratio;

    if (_width != null) {
      return _width!;
    }

    if (ratio != null && height.isFinite) {
      return (_height ?? height) * ratio;
    }

    return _sizeFor(const BoxConstraints()).width;
  }

  double _intrinsicHeight(double width) {
    return _sizeFor(BoxConstraints(maxWidth: width)).height;
  }

  @override
  double computeMinIntrinsicWidth(double height) => _intrinsicWidth(height);

  @override
  double computeMaxIntrinsicWidth(double height) => _intrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) => _intrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) => _intrinsicHeight(width);
}

/// The silhouette of a frame, as the path that cuts it: the React package's
/// `shapeStyle`, a radius for four of them and a polygon for `cut`.
class _FrameBorder extends ShapeBorder {
  const _FrameBorder(this.shape, this.corner);

  final NebaImageFrameShape shape;
  final double corner;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final Path path = Path();
    final double c = math.max(0, math.min(corner, math.min(rect.width, rect.height) / 2));

    switch (shape) {
      case NebaImageFrameShape.rect:
        path.addRect(rect);
      case NebaImageFrameShape.rounded:
        path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(corner)));
      case NebaImageFrameShape.circle:
        path.addOval(rect);
      case NebaImageFrameShape.arch:
        // Half the width on each top corner and a little over half the height,
        // which is exactly the width between them, so nothing is scaled down.
        final Radius top = Radius.elliptical(rect.width / 2, rect.height * 0.55);
        path.addRRect(
          RRect.fromRectAndCorners(
            rect,
            topLeft: top,
            topRight: top,
            bottomLeft: Radius.circular(corner),
            bottomRight: Radius.circular(corner),
          ),
        );
      case NebaImageFrameShape.cut:
        path
          ..moveTo(rect.left + c, rect.top)
          ..lineTo(rect.right - c, rect.top)
          ..lineTo(rect.right, rect.top + c)
          ..lineTo(rect.right, rect.bottom - c)
          ..lineTo(rect.right - c, rect.bottom)
          ..lineTo(rect.left + c, rect.bottom)
          ..lineTo(rect.left, rect.bottom - c)
          ..lineTo(rect.left, rect.top + c)
          ..close();
    }

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => _FrameBorder(shape, corner * t);

  @override
  bool operator ==(Object other) {
    return other is _FrameBorder && other.shape == shape && other.corner == corner;
  }

  @override
  int get hashCode => Object.hash(shape, corner);
}

/// A frame's line, inside the edge of its silhouette.
class _LinePainter extends CustomPainter {
  const _LinePainter({required this.shape, required this.width, required this.color});

  final _FrameBorder shape;
  final double width;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = shape.getOuterPath(Offset.zero & size);

    // A stroke twice as wide, clipped to the shape, is a line inside it that
    // follows every edge, the diagonal of a cut corner included.
    canvas
      ..save()
      ..clipPath(path)
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width * 2
          ..color = color,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_LinePainter oldDelegate) {
    return oldDelegate.shape != shape || oldDelegate.width != width || oldDelegate.color != color;
  }
}

/// A picture whose edge fades out rather than being cut: one gradient across
/// and one down, intersected, so what fades is a rectangle with its sides
/// softened rather than an oval.
class _Feathered extends StatelessWidget {
  const _Feathered({required this.pixels, required this.fraction, required this.child});

  final double pixels;
  final double fraction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Shader fade(Rect bounds, {required bool across}) {
      final double length = across ? bounds.width : bounds.height;
      final double distance = fraction > 0 ? fraction * length : pixels;
      final double stop = length == 0 ? 0 : math.min(0.5, distance / length);

      return LinearGradient(
        begin: across ? Alignment.centerLeft : Alignment.topCenter,
        end: across ? Alignment.centerRight : Alignment.bottomCenter,
        colors: const <Color>[
          Color(0x00000000),
          Color(0xFF000000),
          Color(0xFF000000),
          Color(0x00000000),
        ],
        stops: <double>[0, stop, 1 - stop, 1],
      ).createShader(bounds);
    }

    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (Rect bounds) => fade(bounds, across: true),
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (Rect bounds) => fade(bounds, across: false),
        child: child,
      ),
    );
  }
}
