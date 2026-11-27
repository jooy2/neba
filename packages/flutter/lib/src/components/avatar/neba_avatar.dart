/// `NebaAvatar`, a picture of a person or a thing that is never an empty box.
library;

import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/internal/initials.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/ring.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/internal/svg_path.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// The crop of a [NebaAvatar].
enum NebaAvatarShape {
  /// Round: a portrait.
  circle,

  /// Corners cut off: a logo or a repository icon, drawn to the edges of a
  /// rectangle that a round crop would eat.
  square,
}

/// Where a [NebaAvatar]'s picture is in loading.
enum NebaAvatarLoadingStatus {
  /// There is no picture to load.
  idle,

  /// The picture is on its way.
  loading,

  /// The picture is drawn.
  loaded,

  /// The picture could not be loaded, so the fallback stays.
  error,
}

/// A picture of a person or a thing, at a known size, that is never an empty
/// box.
///
/// One of three things is drawn at a time: the [image], once it has loaded;
/// otherwise what stands in for it, which is [child], or [initials], or the
/// initials of [name]; and failing all of those, a silhouette. The picture
/// fades up over the stand-in when it arrives rather than replacing it in a
/// single frame.
///
/// ```dart
/// const NebaAvatar(name: 'Jane Doe')
/// ```
class NebaAvatar extends StatefulWidget {
  /// An avatar of [name], or of [image].
  const NebaAvatar({
    this.image,
    this.semanticLabel,
    this.name,
    this.initials,
    this.shape = NebaAvatarShape.circle,
    this.variant,
    this.size,
    this.color,
    this.elevation,
    this.transition,
    this.delay,
    this.onLoadingStatusChange,
    this.child,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The picture. Until it loads, and for good if it fails, the fallback is
  /// what is drawn.
  final ImageProvider? image;

  /// What the avatar says to a screen reader. Defaults to [name]; an empty
  /// string makes the avatar silent, for one beside the person's own name.
  final String? semanticLabel;

  /// Who or what this is: it names the avatar, and the initials are derived
  /// from it, the first character of the first word and of the last. "Jane
  /// Doe" is `JD` and "홍길동" is `홍`.
  final String? name;

  /// The initials, written out, for when the rule derived the wrong ones.
  final String? initials;

  /// The crop.
  final NebaAvatarShape shape;

  /// The weight of the surface behind the fallback. Defaults to
  /// `NebaProvider`'s, then [NebaVariant.text].
  final NebaVariant? variant;

  /// The box, on the control heights, so an avatar and the button beside it
  /// are the same height. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The colour family. Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// The drop shadow, from `0`, which is none, to `3`.
  final NebaElevation? elevation;

  /// How the avatar arrives when it is first built: `const
  /// NebaTransition.fade()`, or any of the others.
  final NebaTransition? transition;

  /// How long to wait before drawing the fallback while an [image] loads.
  /// Set it to about the time a cached picture takes and the initials stop
  /// flashing up before a face that was about to arrive anyway.
  final Duration? delay;

  /// Called as the picture moves between the [NebaAvatarLoadingStatus]es.
  final ValueChanged<NebaAvatarLoadingStatus>? onLoadingStatusChange;

  /// The fallback, drawn instead of the initials: an icon, a logo, a single
  /// emoji. An icon is drawn at 55% of the box through the [IconTheme] the
  /// avatar hands down.
  final Widget? child;

  /// The initials' size at each step: about 40% of the box, where two
  /// characters fill the width without touching the edge.
  static const Map<NebaSize, double> initialsText = <NebaSize, double>{
    NebaSize.xs: 9,
    NebaSize.sm: 11,
    NebaSize.md: 13,
    NebaSize.lg: 16,
    NebaSize.xl: 19,
  };

  /// The corner of a squared avatar at each step, about 28% of the box: the
  /// control ladder's 45% on a box as wide as it is tall is a circle.
  static const Map<NebaSize, double> squareRadius = <NebaSize, double>{
    NebaSize.xs: 6,
    NebaSize.sm: 7,
    NebaSize.md: 9,
    NebaSize.lg: 11,
    NebaSize.xl: 14,
  };

  @override
  State<NebaAvatar> createState() => _NebaAvatarState();
}

class _NebaAvatarState extends State<NebaAvatar> {
  ImageStream? _stream;
  ImageInfo? _info;
  NebaAvatarLoadingStatus _status = NebaAvatarLoadingStatus.idle;
  Timer? _delay;
  bool _waited = true;

  late final ImageStreamListener _listener = ImageStreamListener(
    _handleImage,
    onError: _handleError,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(NebaAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.image != oldWidget.image) {
      _resolve();
    }
  }

  @override
  void dispose() {
    _delay?.cancel();
    _stream?.removeListener(_listener);
    _info?.dispose();
    super.dispose();
  }

  void _resolve() {
    final ImageProvider? image = widget.image;

    if (image == null) {
      _stream?.removeListener(_listener);
      _stream = null;
      _replaceInfo(null);
      _delay?.cancel();
      _waited = true;
      _setStatus(NebaAvatarLoadingStatus.idle);
      return;
    }

    final ImageStream stream = image.resolve(createLocalImageConfiguration(context));

    if (stream.key == _stream?.key) {
      return;
    }

    _stream?.removeListener(_listener);
    _stream = stream;
    _replaceInfo(null);
    _startDelay();
    _setStatus(NebaAvatarLoadingStatus.loading);
    // A picture already in the cache arrives inside this call.
    stream.addListener(_listener);
  }

  void _startDelay() {
    _delay?.cancel();
    final Duration? delay = widget.delay;

    if (delay == null || delay == Duration.zero) {
      _waited = true;
      return;
    }

    _waited = false;
    _delay = Timer(delay, () {
      if (mounted) {
        setState(() => _waited = true);
      }
    });
  }

  void _handleImage(ImageInfo info, bool synchronousCall) {
    setState(() => _replaceInfo(info));
    _setStatus(NebaAvatarLoadingStatus.loaded);
  }

  void _handleError(Object error, StackTrace? stackTrace) {
    // A picture that fails is not an error the page has to hear about: the
    // fallback is what it is for.
    setState(() => _replaceInfo(null));
    _setStatus(NebaAvatarLoadingStatus.error);
  }

  void _replaceInfo(ImageInfo? info) {
    _info?.dispose();
    _info = info;
  }

  void _setStatus(NebaAvatarLoadingStatus status) {
    if (_status == status) {
      return;
    }

    setState(() => _status = status);

    final ValueChanged<NebaAvatarLoadingStatus>? report = widget.onLoadingStatusChange;

    if (report != null) {
      // After the frame, since a status can change while the avatar is being
      // built, and a caller's own setState must not land inside that.
      SchedulerBinding.instance.addPostFrameCallback((Duration _) {
        if (mounted) {
          report(status);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.text;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaColorRoles roles = tokens.roles(widget.color ?? NebaColor.primary);
    final NebaElevation elevation = widget.elevation ?? 0;

    final double box = NebaScale.controlHeight[size]!;
    final BorderRadius radius = BorderRadius.circular(
      widget.shape == NebaAvatarShape.circle ? box / 2 : NebaAvatar.squareRadius[size]!,
    );

    final (Color fill, Color? edge, NebaPlate plate, Color ink, bool textured) = switch (variant) {
      NebaVariant.solid => (roles.fill, null, NebaPlate.solid, roles.family.onSolid, true),
      NebaVariant.outline => (roles.panel, roles.line, NebaPlate.glass, roles.onTint, true),
      NebaVariant.text => (tintPlate(tokens, roles), null, NebaPlate.none, roles.onTint, false),
    };

    final bool loaded = _status == NebaAvatarLoadingStatus.loaded;
    final bool showFallback = !loaded && _waited;
    final String? label = widget.semanticLabel ?? widget.name;
    final ImageInfo? info = _info;

    Widget avatar = NebaSheet(
      fill: fill,
      edge: edge,
      plate: plate,
      elevation: elevation,
      borderRadius: radius,
      blur: textured,
      texture: textured,
      // The picture reaches the edge, so the light along it is drawn on top.
      plateOnTop: true,
      child: SizedBox.square(
        dimension: box - (edge == null ? 0 : 2),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (showFallback) _Fallback(box: box, size: size, ink: ink, child: _standIn()),
            if (widget.image != null)
              AnimatedOpacity(
                opacity: loaded ? 1 : 0,
                duration: nebaDuration(context, NebaScale.durationFill),
                curve: NebaScale.ease,
                child: RawImage(image: info?.image, scale: info?.scale ?? 1, fit: BoxFit.cover),
              ),
          ],
        ),
      ),
    );

    // The ring of a pile the avatar is in, around its own crop.
    avatar = NebaRing(borderRadius: radius, child: avatar);

    final NebaTransition? transition = widget.transition;

    if (transition != null) {
      avatar = NebaEntrance(transition: transition, child: avatar);
    }

    if (label == null) {
      return avatar;
    }

    if (label.isEmpty) {
      return ExcludeSemantics(child: avatar);
    }

    // `JD` read out is two letters, not a person: with a name to say, the
    // stand-in is the picture it stands in for.
    return Semantics(
      container: true,
      image: loaded,
      label: label,
      excludeSemantics: true,
      child: avatar,
    );
  }

  Widget _standIn() {
    final Widget? child = widget.child;

    if (child != null) {
      return child;
    }

    final String? name = widget.name;
    final String letters = widget.initials ?? (name == null ? '' : initialsOf(name));

    return letters.isEmpty ? const _PersonGlyph() : Text(letters);
  }
}

/// What stands in for the picture, centred and sized off the box rather than
/// off a line of text.
class _Fallback extends StatelessWidget {
  const _Fallback({required this.box, required this.size, required this.ink, required this.child});

  final double box;
  final NebaSize size;
  final Color ink;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double text = NebaAvatar.initialsText[size]!;

    return Center(
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: ink,
          fontSize: text,
          fontWeight: FontWeight.w600,
          letterSpacing: text * 0.025,
          height: 1,
        ),
        maxLines: 1,
        softWrap: false,
        child: IconTheme.merge(
          data: IconThemeData(color: ink, size: box * 0.55),
          // Larger text from the platform shrinks to the box rather than
          // spilling out of it.
          child: FittedBox(fit: BoxFit.scaleDown, child: child),
        ),
      ),
    );
  }
}

/// The silhouette drawn when there is nothing else to go on, so an avatar with
/// no picture, no name and no glyph is still an avatar.
class _PersonGlyph extends StatelessWidget {
  const _PersonGlyph();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 24,
      child: CustomPaint(painter: _PersonPainter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _PersonPainter extends CustomPainter {
  _PersonPainter(this.color);

  final Color color;

  /// The React package's silhouette, in its 24-unit box.
  static final Path _path = parseSvgPath(
    'M12 12a4.5 4.5 0 1 0 0-9 4.5 4.5 0 0 0 0 9Z'
    'M12 14.25c-4.28 0-7.75 2.42-7.75 5.4 0 .75.6 1.35 1.35 1.35h12.8c.75 0 1.35-.6 '
    '1.35-1.35 0-2.98-3.47-5.4-7.75-5.4Z',
  );

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 24, size.height / 24)
      ..drawPath(_path, Paint()..color = color)
      ..restore();
  }

  @override
  bool shouldRepaint(_PersonPainter oldDelegate) => oldDelegate.color != color;
}
