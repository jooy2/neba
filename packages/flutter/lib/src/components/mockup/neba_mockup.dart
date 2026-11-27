/// `NebaMockup`, a device with a screen you can put anything on.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/internal/color.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Which machine a [NebaMockup] is a picture of.
enum NebaMockupDevice {
  /// A monitor or a laptop.
  desktop,

  /// A tablet.
  tablet,

  /// A phone.
  mobile,
}

/// The system whose chrome a [NebaMockup] draws on its screen. A desktop runs
/// [macos], [windows] or [linux], a tablet [ipados] or [android], and a phone
/// [ios] or [android]; any other falls back to the device's first.
enum NebaMockupOs {
  /// A menu bar and a dock.
  macos,

  /// A taskbar.
  windows,

  /// A top bar and a dock down the leading edge.
  linux,

  /// A status bar and a home indicator.
  ios,

  /// iOS's status bar and home indicator, at a tablet's size.
  ipados,

  /// A status bar and three navigation buttons.
  android,
}

/// What holds a desktop screen up.
enum NebaMockupHardware {
  /// A neck and a foot under it.
  monitor,

  /// A keyboard's base in front of it.
  laptop,
}

/// The camera cut out of the top of a screen: hardware rather than chrome, so
/// it is drawn whether or not the system's bars are.
enum NebaMockupNotch {
  /// None.
  none,

  /// A notch cut out of the edge.
  notch,

  /// A pill floating on the glass.
  dynamicIsland,

  /// A hole for the camera alone.
  punchHole,
}

/// How much hardware there is around the screen.
enum NebaMockupBezel {
  /// No hardware at all: the screen on its own with its corners cut.
  none,

  /// A narrow frame.
  thin,

  /// The frame the device has today.
  standard,

  /// An older device: narrow sides, a forehead and a chin.
  thick,
}

/// What the hardware is made of. Fixed colours rather than tokens: a graphite
/// phone stays graphite on a page switched to dark.
enum NebaMockupFinish {
  /// Near black.
  graphite,

  /// A light grey metal.
  silver,

  /// White.
  white,
}

/// Which way a handheld is held. A desktop is drawn as it stands.
enum NebaMockupOrientation {
  /// Upright.
  portrait,

  /// On its side, with the bezel and the cut-out turned with the screen.
  landscape,
}

/// The lengths a [NebaMockup] lays its device out with, in the device's own
/// pixels.
@immutable
class NebaMockupMetrics {
  const NebaMockupMetrics._({
    required this.screen,
    required this.bezel,
    required this.body,
    required this.frame,
    required this.frameRadius,
    required this.screenRadius,
    this.stand,
    this.base,
  });

  /// The screen, after the orientation has had its say.
  final Size screen;

  /// The hardware on each side of it: none when the bezel is
  /// [NebaMockupBezel.none].
  final EdgeInsets bezel;

  /// Screen and bezel: the device's face.
  final Size body;

  /// The face and whatever holds it up: what is scaled to fit.
  final Size frame;

  /// The corner of the hardware.
  final double frameRadius;

  /// The corner of the glass.
  final double screenRadius;

  /// A monitor's neck and foot.
  final ({Size neck, Size foot})? stand;

  /// A laptop's base and the lip it is opened by.
  final ({Size base, double lip})? base;
}

/// A device with a screen you can put anything on: a phone, a tablet, a
/// monitor or a laptop, with the system's own bars drawn on it.
///
/// The screen is laid out at the device's own resolution, a `md` phone being
/// 390 by 844, and the whole device is then scaled once to the room it is
/// given. So what is on the screen lays out against a screen rather than the
/// window: a 390-pixel column wraps where it would on a phone, and the
/// [MediaQuery] below it reports the screen's size. That scale is the one
/// transform in the library, set once from the space available and never on
/// an interaction.
///
/// ```dart
/// const NebaMockup(device: NebaMockupDevice.mobile, width: 260, child: Screen())
/// ```
class NebaMockup extends StatelessWidget {
  /// A [device] showing [child].
  const NebaMockup({
    required this.device,
    this.os,
    this.hardware = NebaMockupHardware.monitor,
    this.size,
    this.resolution,
    this.orientation = NebaMockupOrientation.portrait,
    this.bezel = NebaMockupBezel.standard,
    this.finish = NebaMockupFinish.graphite,
    this.notch,
    this.systemUi = true,
    this.scroll = false,
    this.wallpaper,
    this.time = '9:41',
    this.width,
    this.height,
    this.color,
    this.elevation,
    this.transition,
    this.child,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// Which machine this is a picture of.
  final NebaMockupDevice device;

  /// The system whose chrome is on the screen. Defaults to the device's
  /// first: [NebaMockupOs.macos], [NebaMockupOs.ipados] and
  /// [NebaMockupOs.ios].
  final NebaMockupOs? os;

  /// What holds a desktop screen up. Ignored on a handheld.
  final NebaMockupHardware hardware;

  /// The device's resolution, on a ladder of five real ones per device, from
  /// a 320-wide phone to a 430-wide one and a 1024-wide desktop to a
  /// 1920-wide one. It sets no height and no type. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The screen's logical resolution, when no step of the ladder is the
  /// machine you mean.
  final Size? resolution;

  /// Which way a handheld is held.
  final NebaMockupOrientation orientation;

  /// How much hardware there is around the screen.
  final NebaMockupBezel bezel;

  /// What the hardware is made of.
  final NebaMockupFinish finish;

  /// The camera cut-out. Defaults to a dynamic island on an iOS phone, a
  /// punch hole on an Android one and none anywhere else.
  final NebaMockupNotch? notch;

  /// Whether the system's bars are drawn. Each takes its own room, so turning
  /// them off gives the screen back to [child] rather than uncovering it.
  final bool systemUi;

  /// Whether content taller than the screen scrolls. Off, it is given the
  /// screen exactly and clipped to it.
  final bool scroll;

  /// What is behind the content: a colour, a gradient or a picture. Defaults
  /// to the page's surface.
  final Decoration? wallpaper;

  /// The clock in the status bar or the taskbar, and the only text the chrome
  /// draws.
  final String time;

  /// How wide the whole device is drawn. Given alone, the height follows the
  /// device's proportion; given neither, the device fills the width it is in.
  final double? width;

  /// How tall the whole device is drawn.
  final double? height;

  /// The family the chrome's accent takes: a dock's first icon. Defaults to
  /// [NebaColor.primary].
  final NebaColor? color;

  /// How far off the page the device sits, as a shadow that follows its
  /// outline and does not shrink with it. Defaults to `0`.
  final NebaElevation? elevation;

  /// An entrance animation, run once when the mockup is first built.
  final NebaTransition? transition;

  /// What is on the screen.
  final Widget? child;

  /// The system [device] draws for [os], which falls back to the device's
  /// own, reading `ios` on a tablet and `ipados` on a phone as the Apple one.
  static NebaMockupOs resolveOs(NebaMockupDevice device, NebaMockupOs? os) {
    final List<NebaMockupOs> allowed = _systems[device]!;

    if (os != null && allowed.contains(os)) {
      return os;
    }

    if (os == NebaMockupOs.ios && device == NebaMockupDevice.tablet) {
      return NebaMockupOs.ipados;
    }

    if (os == NebaMockupOs.ipados && device == NebaMockupDevice.mobile) {
      return NebaMockupOs.ios;
    }

    return allowed.first;
  }

  /// The cut-out [device] has when nothing says otherwise.
  static NebaMockupNotch defaultNotch(NebaMockupDevice device, NebaMockupOs os) {
    if (device != NebaMockupDevice.mobile) {
      return NebaMockupNotch.none;
    }

    return os == NebaMockupOs.android ? NebaMockupNotch.punchHole : NebaMockupNotch.dynamicIsland;
  }

  /// The resolutions of the ladder, per device.
  static const Map<NebaMockupDevice, Map<NebaSize, Size>> resolutions =
      <NebaMockupDevice, Map<NebaSize, Size>>{
        NebaMockupDevice.mobile: <NebaSize, Size>{
          NebaSize.xs: Size(320, 568),
          NebaSize.sm: Size(360, 780),
          NebaSize.md: Size(390, 844),
          NebaSize.lg: Size(414, 896),
          NebaSize.xl: Size(430, 932),
        },
        NebaMockupDevice.tablet: <NebaSize, Size>{
          NebaSize.xs: Size(744, 1133),
          NebaSize.sm: Size(768, 1024),
          NebaSize.md: Size(820, 1180),
          NebaSize.lg: Size(834, 1194),
          NebaSize.xl: Size(1024, 1366),
        },
        NebaMockupDevice.desktop: <NebaSize, Size>{
          NebaSize.xs: Size(1024, 640),
          NebaSize.sm: Size(1280, 800),
          NebaSize.md: Size(1440, 900),
          NebaSize.lg: Size(1680, 1050),
          NebaSize.xl: Size(1920, 1200),
        },
      };

  /// Every length the device is laid out with.
  static NebaMockupMetrics metricsOf({
    required NebaMockupDevice device,
    NebaSize size = NebaSize.md,
    Size? resolution,
    NebaMockupOrientation orientation = NebaMockupOrientation.portrait,
    NebaMockupBezel bezel = NebaMockupBezel.standard,
    NebaMockupHardware hardware = NebaMockupHardware.monitor,
  }) {
    final Size native = resolution ?? resolutions[device]![size]!;
    // A desktop has one orientation, and its stand does not turn with it.
    final bool landscape =
        device != NebaMockupDevice.desktop && orientation == NebaMockupOrientation.landscape;
    final Size screen = landscape ? native.flipped : native;

    if (bezel == NebaMockupBezel.none) {
      return NebaMockupMetrics._(
        screen: screen,
        bezel: EdgeInsets.zero,
        body: screen,
        frame: screen,
        frameRadius: _bareRadius[device]!,
        screenRadius: _bareRadius[device]!,
      );
    }

    final _Shell shell = _shells[device]![bezel]!;
    // Turning the device turns its bezel: a forehead and a chin become its
    // sides.
    final ({double x, double top, double bottom}) inset = landscape
        ? (x: shell.top, top: shell.x, bottom: shell.x)
        : (x: shell.x, top: shell.top, bottom: shell.bottom);
    // A laptop's chin is on its base, so the lid's bezel is even.
    final bool laptop = device == NebaMockupDevice.desktop && hardware == NebaMockupHardware.laptop;
    final EdgeInsets edges = EdgeInsets.fromLTRB(
      inset.x,
      inset.top,
      inset.x,
      laptop ? inset.top : inset.bottom,
    );
    final Size body = Size(screen.width + edges.horizontal, screen.height + edges.vertical);

    if (device != NebaMockupDevice.desktop) {
      return NebaMockupMetrics._(
        screen: screen,
        bezel: edges,
        body: body,
        frame: body,
        frameRadius: shell.frameRadius,
        screenRadius: shell.screenRadius,
      );
    }

    if (laptop) {
      final Size base = Size(
        (body.width * 1.075).roundToDouble(),
        (body.height * 0.035).roundToDouble(),
      );

      return NebaMockupMetrics._(
        screen: screen,
        bezel: edges,
        body: body,
        frame: Size(base.width, body.height + base.height),
        frameRadius: shell.frameRadius,
        screenRadius: shell.screenRadius,
        base: (base: base, lip: (body.width * 0.12).roundToDouble()),
      );
    }

    final Size neck = Size(
      (body.width * 0.11).roundToDouble(),
      (body.height * 0.09).roundToDouble(),
    );
    final Size foot = Size(
      (body.width * 0.28).roundToDouble(),
      (body.height * 0.018).roundToDouble(),
    );

    return NebaMockupMetrics._(
      screen: screen,
      bezel: edges,
      body: body,
      frame: Size(body.width, body.height + neck.height + foot.height),
      frameRadius: shell.frameRadius,
      screenRadius: shell.screenRadius,
      stand: (neck: neck, foot: foot),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaSize size = this.size ?? NebaTheme.defaultsOf(context).size ?? NebaSize.md;
    final NebaMockupOs system = resolveOs(device, os);
    final NebaMockupNotch cutout = notch ?? defaultNotch(device, system);
    final bool landscape =
        device != NebaMockupDevice.desktop && orientation == NebaMockupOrientation.landscape;
    final NebaMockupMetrics metrics = metricsOf(
      device: device,
      size: size,
      resolution: resolution,
      orientation: orientation,
      bezel: bezel,
      hardware: hardware,
    );
    final _Finish shell = _finishes[finish]!;
    final Size frame = metrics.frame;
    final double ratio = frame.width / frame.height;
    final int level = elevation ?? 0;
    final bool bare = bezel == NebaMockupBezel.none;

    Widget fitted(Size box) {
      final double scale = math.min(box.width / frame.width, box.height / frame.height);
      final List<_Drop> drops = <_Drop>[
        // Divided by the scale, so the shadow is the size it says on the page
        // rather than shrunk with the device.
        for (final _Drop drop in _drops[level]) drop.over(scale),
      ];

      final Widget screen = _Screen(
        metrics: metrics,
        system: system,
        cutout: cutout,
        landscape: landscape,
        systemUi: systemUi,
        scroll: scroll,
        wallpaper: wallpaper,
        time: time,
        accent: tokens.roles(color ?? NebaColor.primary).accent,
        shade: bare ? null : shell.shade,
        child: child,
      );

      final Widget face = bare
          ? _Shadowed(
              shape: BorderRadius.circular(metrics.screenRadius),
              drops: drops,
              ambient: tokens.shadowAmbient,
              child: screen,
            )
          : CustomPaint(
              painter: _ShellPainter(
                finish: shell,
                radius: BorderRadius.circular(metrics.frameRadius),
                drops: drops,
                ambient: tokens.shadowAmbient,
              ),
              child: Padding(padding: metrics.bezel, child: screen),
            );

      final ({Size neck, Size foot})? stand = metrics.stand;
      final ({Size base, double lip})? base = metrics.base;

      final Widget device = SizedBox.fromSize(
        size: frame,
        child: Column(
          children: <Widget>[
            SizedBox.fromSize(size: metrics.body, child: face),
            if (stand != null) ...<Widget>[
              ClipPath(
                clipper: const _Trapezoid(top: 0.16, bottom: 0),
                child: Container(
                  width: stand.neck.width,
                  height: stand.neck.height,
                  color: shell.shade,
                ),
              ),
              CustomPaint(
                size: stand.foot,
                painter: _ShellPainter(
                  finish: shell,
                  radius: BorderRadius.circular(stand.foot.height / 2),
                  drops: drops,
                  ambient: tokens.shadowAmbient,
                ),
              ),
            ],
            if (base != null) _Base(base: base.base, lip: base.lip, finish: shell, drops: drops),
          ],
        ),
      );

      return SizedBox.fromSize(
        size: box,
        child: FittedBox(child: device),
      );
    }

    final double? width = this.width;
    final double? height = this.height;
    Widget mockup;

    if (width != null && height != null) {
      mockup = fitted(Size(width, height));
    } else if (width != null) {
      mockup = fitted(Size(width, width / ratio));
    } else if (height != null) {
      mockup = fitted(Size(height * ratio, height));
    } else {
      mockup = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double across = constraints.hasBoundedWidth ? constraints.maxWidth : frame.width;

          return fitted(Size(across, across / ratio));
        },
      );
    }

    final NebaTransition? transition = this.transition;

    return transition == null ? mockup : NebaEntrance(transition: transition, child: mockup);
  }
}

/* ---------------------------------------------------------------------------
 * The tables
 * ------------------------------------------------------------------------- */

const Map<NebaMockupDevice, List<NebaMockupOs>> _systems = <NebaMockupDevice, List<NebaMockupOs>>{
  NebaMockupDevice.desktop: <NebaMockupOs>[
    NebaMockupOs.macos,
    NebaMockupOs.windows,
    NebaMockupOs.linux,
  ],
  NebaMockupDevice.tablet: <NebaMockupOs>[NebaMockupOs.ipados, NebaMockupOs.android],
  NebaMockupDevice.mobile: <NebaMockupOs>[NebaMockupOs.ios, NebaMockupOs.android],
};

@immutable
class _Shell {
  const _Shell(this.x, this.top, this.bottom, this.frameRadius, this.screenRadius);

  final double x;
  final double top;
  final double bottom;
  final double frameRadius;

  /// Written out rather than derived: a thick-bezelled screen is square,
  /// which no subtraction from the frame's corner gives.
  final double screenRadius;
}

const Map<NebaMockupDevice, Map<NebaMockupBezel, _Shell>> _shells =
    <NebaMockupDevice, Map<NebaMockupBezel, _Shell>>{
      NebaMockupDevice.mobile: <NebaMockupBezel, _Shell>{
        NebaMockupBezel.thin: _Shell(8, 8, 8, 50, 42),
        NebaMockupBezel.standard: _Shell(13, 13, 13, 56, 43),
        NebaMockupBezel.thick: _Shell(16, 62, 62, 40, 4),
      },
      NebaMockupDevice.tablet: <NebaMockupBezel, _Shell>{
        NebaMockupBezel.thin: _Shell(12, 12, 12, 34, 22),
        NebaMockupBezel.standard: _Shell(20, 20, 20, 42, 22),
        NebaMockupBezel.thick: _Shell(28, 74, 74, 36, 4),
      },
      NebaMockupDevice.desktop: <NebaMockupBezel, _Shell>{
        NebaMockupBezel.thin: _Shell(8, 8, 8, 12, 4),
        NebaMockupBezel.standard: _Shell(13, 13, 30, 16, 4),
        NebaMockupBezel.thick: _Shell(22, 22, 62, 18, 3),
      },
    };

/// The screen's own corner when there is no hardware to be concentric with.
const Map<NebaMockupDevice, double> _bareRadius = <NebaMockupDevice, double>{
  NebaMockupDevice.mobile: 42,
  NebaMockupDevice.tablet: 24,
  NebaMockupDevice.desktop: 8,
};

@immutable
class _Finish {
  const _Finish(this.shell, this.edge, this.shade);

  final Color shell;
  final Color edge;
  final Color shade;
}

final Map<NebaMockupFinish, _Finish> _finishes = <NebaMockupFinish, _Finish>{
  NebaMockupFinish.graphite: _Finish(
    oklch(0.27, 0.008, 262),
    _white(0.16),
    oklch(0.17, 0.008, 262),
  ),
  NebaMockupFinish.silver: _Finish(oklch(0.83, 0.004, 262), _white(0.75), oklch(0.66, 0.006, 262)),
  NebaMockupFinish.white: _Finish(oklch(0.96, 0.002, 262), _white(0.9), oklch(0.8, 0.004, 262)),
};

Color _white(double alpha) => Color.from(alpha: alpha, red: 1, green: 1, blue: 1);

/// A CSS `drop-shadow`: an offset down the page and a blur.
@immutable
class _Drop {
  const _Drop(this.y, this.blur);

  final double y;
  final double blur;

  _Drop over(double scale) => _Drop(y / scale, blur / scale);
}

/// The silhouette's shadows at each elevation, the React package's
/// `elevationFilters`.
const List<List<_Drop>> _drops = <List<_Drop>>[
  <_Drop>[],
  <_Drop>[_Drop(1, 2)],
  <_Drop>[_Drop(2, 4), _Drop(8, 12)],
  <_Drop>[_Drop(4, 6), _Drop(18, 28)],
];

void _paintDrops(Canvas canvas, RRect shape, List<_Drop> drops, Color ambient) {
  for (final _Drop drop in drops) {
    canvas.drawRRect(
      shape.shift(Offset(0, drop.y)),
      Paint()
        ..color = ambient
        // A drop-shadow's blur is twice its standard deviation.
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(drop.blur / 2, 0.01)),
    );
  }
}

/* ---------------------------------------------------------------------------
 * The hardware
 * ------------------------------------------------------------------------- */

/// The hardware's surface: the finish, a light top edge and a ring in its
/// own dark tone, with no bevel underneath.
class _ShellPainter extends CustomPainter {
  const _ShellPainter({
    required this.finish,
    required this.radius,
    required this.drops,
    required this.ambient,
  });

  final _Finish finish;
  final BorderRadius radius;
  final List<_Drop> drops;
  final Color ambient;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect shape = radius.toRRect(Offset.zero & size);

    _paintDrops(canvas, shape, drops, ambient);
    canvas.drawRRect(shape, Paint()..color = finish.shell);
    // `inset 0 1px 0`: the shape minus itself moved down a pixel.
    canvas
      ..save()
      ..clipRRect(shape)
      ..drawPath(
        Path.combine(
          PathOperation.difference,
          Path()..addRRect(shape),
          Path()..addRRect(shape.shift(const Offset(0, 1))),
        ),
        Paint()..color = finish.edge,
      )
      ..restore();
    strokeInside(canvas, shape, finish.shade);
  }

  @override
  bool shouldRepaint(_ShellPainter oldDelegate) {
    return oldDelegate.finish != finish ||
        oldDelegate.radius != radius ||
        oldDelegate.ambient != ambient ||
        oldDelegate.drops.length != drops.length ||
        (drops.isNotEmpty && oldDelegate.drops.first.blur != drops.first.blur);
  }
}

/// The screen alone, raised off the page when there is no hardware.
class _Shadowed extends StatelessWidget {
  const _Shadowed({
    required this.shape,
    required this.drops,
    required this.ambient,
    required this.child,
  });

  final BorderRadius shape;
  final List<_Drop> drops;
  final Color ambient;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (drops.isEmpty) {
      return child;
    }

    return CustomPaint(
      painter: _DropPainter(shape: shape, drops: drops, ambient: ambient),
      child: child,
    );
  }
}

class _DropPainter extends CustomPainter {
  const _DropPainter({required this.shape, required this.drops, required this.ambient});

  final BorderRadius shape;
  final List<_Drop> drops;
  final Color ambient;

  @override
  void paint(Canvas canvas, Size size) {
    _paintDrops(canvas, shape.toRRect(Offset.zero & size), drops, ambient);
  }

  @override
  bool shouldRepaint(_DropPainter oldDelegate) => true;
}

/// A shape narrower at one end than the other, by a share of its width.
class _Trapezoid extends CustomClipper<Path> {
  const _Trapezoid({required this.top, required this.bottom});

  final double top;
  final double bottom;

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width * top, 0)
      ..lineTo(size.width * (1 - top), 0)
      ..lineTo(size.width * (1 - bottom), size.height)
      ..lineTo(size.width * bottom, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_Trapezoid oldClipper) {
    return oldClipper.top != top || oldClipper.bottom != bottom;
  }
}

/// A laptop's base, wider than the lid and shallow, with the lip it is
/// opened by: the one detail that says laptop rather than a monitor on a very
/// short stand.
class _Base extends StatelessWidget {
  const _Base({required this.base, required this.lip, required this.finish, required this.drops});

  final Size base;
  final double lip;
  final _Finish finish;
  final List<_Drop> drops;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final double corner = (base.height * 0.55).roundToDouble();
    final double lipCorner = (base.height * 0.2).roundToDouble();

    return CustomPaint(
      painter: _DropPainter(
        shape: BorderRadius.vertical(bottom: Radius.circular(corner)),
        drops: drops,
        ambient: tokens.shadowAmbient,
      ),
      child: ClipPath(
        clipper: const _Trapezoid(top: 0, bottom: 0.015),
        child: CustomPaint(
          size: base,
          painter: _ShellPainter(
            finish: finish,
            radius: BorderRadius.vertical(bottom: Radius.circular(corner)),
            drops: const <_Drop>[],
            ambient: tokens.shadowAmbient,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: lip,
              height: (base.height * 0.34).roundToDouble(),
              decoration: BoxDecoration(
                color: finish.shade,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(lipCorner)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------------------------------------------------------------------------
 * The screen
 * ------------------------------------------------------------------------- */

class _Screen extends StatelessWidget {
  const _Screen({
    required this.metrics,
    required this.system,
    required this.cutout,
    required this.landscape,
    required this.systemUi,
    required this.scroll,
    required this.wallpaper,
    required this.time,
    required this.accent,
    required this.shade,
    required this.child,
  });

  final NebaMockupMetrics metrics;
  final NebaMockupOs system;
  final NebaMockupNotch cutout;
  final bool landscape;
  final bool systemUi;
  final bool scroll;
  final Decoration? wallpaper;
  final String time;
  final Color accent;
  final Color? shade;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final BorderRadius radius = BorderRadius.circular(metrics.screenRadius);
    final _Chrome chrome = systemUi
        ? _chromeOf(system, cutout: cutout, landscape: landscape, time: time, accent: accent)
        : const _Chrome();

    // What is on the screen answers to the screen: the media query below it
    // is the room the content has, with no system insets of the page's.
    final Widget content = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Widget? child = this.child;
        Widget shown = child ?? const SizedBox.shrink();

        if (scroll) {
          shown = SingleChildScrollView(
            primary: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: shown,
            ),
          );
        }

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: constraints.biggest,
            padding: EdgeInsets.zero,
            viewPadding: EdgeInsets.zero,
            viewInsets: EdgeInsets.zero,
          ),
          child: ClipRect(child: shown),
        );
      },
    );

    final Color? shade = this.shade;

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: metrics.screen.width,
        height: metrics.screen.height,
        decoration: wallpaper ?? BoxDecoration(color: tokens.surface),
        // The glass sits a hair below the hardware: a ring in the finish's
        // own dark tone rather than a black line.
        foregroundDecoration: shade == null
            ? null
            : BoxDecoration(
                border: Border.all(color: shade),
                borderRadius: radius,
              ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Column(
                children: <Widget>[
                  ?chrome.top,
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        ?chrome.start,
                        Expanded(child: content),
                      ],
                    ),
                  ),
                  ?chrome.bottom,
                ],
              ),
            ),
            ..._cutout(cutout, metrics.screen, landscape),
          ],
        ),
      ),
    );
  }
}

/// The camera, drawn on the glass over the status bar it is a hole in.
List<Widget> _cutout(NebaMockupNotch notch, Size screen, bool landscape) {
  const Color black = Color(0xFF0D0E10);
  final double along = landscape ? screen.height : screen.width;

  Widget hole(double length, double depth, double offset, BorderRadius radius) {
    final Widget shape = ExcludeSemantics(
      child: IgnorePointer(
        child: Container(
          width: landscape ? depth : length,
          height: landscape ? length : depth,
          decoration: BoxDecoration(color: black, borderRadius: radius),
        ),
      ),
    );

    return landscape
        ? Positioned(
            left: offset,
            top: 0,
            bottom: 0,
            child: Center(child: shape),
          )
        : Positioned(
            top: offset,
            left: 0,
            right: 0,
            child: Center(child: shape),
          );
  }

  switch (notch) {
    case NebaMockupNotch.none:
      return const <Widget>[];
    case NebaMockupNotch.punchHole:
      final double diameter = math.max(16, (along * 0.07).roundToDouble());

      return <Widget>[
        hole(
          diameter,
          diameter,
          (diameter * 0.55).roundToDouble(),
          BorderRadius.circular(diameter),
        ),
      ];
    case NebaMockupNotch.dynamicIsland:
      final double length = math.max(96, (along * 0.32).roundToDouble());
      final double depth = (length * 0.29).roundToDouble();

      return <Widget>[
        hole(length, depth, (depth * 0.32).roundToDouble(), BorderRadius.circular(depth)),
      ];
    case NebaMockupNotch.notch:
      // Cut out of the edge, so rounded only where it is not against it.
      final double length = math.max(120, (along * 0.42).roundToDouble());
      final double depth = (length * 0.23).roundToDouble();
      final Radius corner = Radius.circular((depth * 0.6).roundToDouble());

      return <Widget>[
        hole(
          length,
          depth,
          0,
          landscape
              ? BorderRadius.horizontal(right: corner)
              : BorderRadius.vertical(bottom: corner),
        ),
      ];
  }
}

/* ---------------------------------------------------------------------------
 * The chrome
 * ------------------------------------------------------------------------- */

@immutable
class _Chrome {
  const _Chrome({this.top, this.bottom, this.start});

  final Widget? top;
  final Widget? bottom;

  /// A dock down the leading edge. Only Linux has one.
  final Widget? start;
}

enum _Tone { muted, faint, accent }

_Chrome _chromeOf(
  NebaMockupOs os, {
  required NebaMockupNotch cutout,
  required bool landscape,
  required String time,
  required Color accent,
}) {
  switch (os) {
    case NebaMockupOs.ios:
    case NebaMockupOs.ipados:
      final bool tablet = os == NebaMockupOs.ipados;
      // The island and the notch stand in the middle of the status bar, so the
      // bar has to be tall enough to have a middle; in landscape they have
      // moved to the edge.
      final bool raised =
          !tablet &&
          !landscape &&
          cutout != NebaMockupNotch.none &&
          cutout != NebaMockupNotch.punchHole;

      return _Chrome(
        top: _Bar(
          height: tablet
              ? 30
              : raised
              ? 54
              : 44,
          padding: EdgeInsets.symmetric(horizontal: tablet ? 22 : 26),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _Clock(time, size: 15),
              _StatusGlyphs(height: tablet ? 11 : 12, gap: 6),
            ],
          ),
        ),
        bottom: _Bar(
          height: tablet ? 22 : 34,
          fill: false,
          child: Center(
            child: _Ink(
              alpha: 0.55,
              builder: (Color ink) => Container(
                width: tablet ? 220 : 140,
                height: 5,
                decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(3)),
              ),
            ),
          ),
        ),
      );
    case NebaMockupOs.android:
      return _Chrome(
        top: _Bar(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[_Clock(time, size: 13), const _StatusGlyphs(height: 11, gap: 5)],
          ),
        ),
        bottom: const _Bar(height: 48, child: Center(child: _NavGlyphs(size: 20, gap: 72))),
      );
    case NebaMockupOs.macos:
      return _Chrome(
        top: _Bar(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Row(
                spacing: 16,
                children: <Widget>[
                  _Tile(width: 13, radius: 4),
                  _Tile(width: 34, height: 7, radius: 4),
                  _Tile(width: 26, height: 7, radius: 4, tone: _Tone.faint),
                  _Tile(width: 30, height: 7, radius: 4, tone: _Tone.faint),
                  _Tile(width: 22, height: 7, radius: 4, tone: _Tone.faint),
                ],
              ),
              Row(
                spacing: 14,
                children: <Widget>[
                  const _Tile(width: 11, radius: 3, tone: _Tone.faint),
                  const _Tile(width: 11, radius: 3, tone: _Tone.faint),
                  _Clock(time, size: 13),
                ],
              ),
            ],
          ),
        ),
        // The dock is a sheet of its own floating clear of the edge.
        bottom: SizedBox(
          height: 78,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _Dock(accent: accent),
            ),
          ),
        ),
      );
    case NebaMockupOs.windows:
      return _Chrome(
        bottom: _Bar(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          ruled: true,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: <Widget>[
                  const _Ink(alpha: 0.7, builder: _startGlyph),
                  _Tiles(count: 6, size: 30, radius: 8, gap: 10, accent: accent),
                ],
              ),
              PositionedDirectional(
                end: 0,
                top: 0,
                bottom: 0,
                child: Row(
                  spacing: 12,
                  children: <Widget>[
                    const _Tile(width: 11, radius: 3, tone: _Tone.faint),
                    const _Tile(width: 11, radius: 3, tone: _Tone.faint),
                    _Clock(time, size: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    case NebaMockupOs.linux:
      return _Chrome(
        top: _Bar(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              const PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                child: Center(child: _Tile(width: 52, height: 9, radius: 5)),
              ),
              _Clock(time, size: 13),
              const PositionedDirectional(
                end: 0,
                top: 0,
                bottom: 0,
                child: Row(
                  spacing: 10,
                  children: <Widget>[
                    _Tile(width: 10, radius: 3, tone: _Tone.faint),
                    _Tile(width: 10, radius: 3, tone: _Tone.faint),
                    _Tile(width: 10, radius: 3, tone: _Tone.faint),
                  ],
                ),
              ),
            ],
          ),
        ),
        // The one dock that runs down an edge rather than along one.
        start: _Bar(
          width: 66,
          ruled: true,
          vertical: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            spacing: 10,
            children: <Widget>[
              _Tile(width: 44, radius: 12, tone: _Tone.accent, accent: accent),
              const _Tile(width: 44, radius: 12),
              const _Tile(width: 44, radius: 12),
              const _Tile(width: 44, radius: 12),
            ],
          ),
        ),
      );
  }
}

Widget _startGlyph(Color ink) {
  return CustomPaint(size: const Size.square(22), painter: _StartPainter(ink));
}

/// A bar the system draws, on the page's surface with a little of the
/// wallpaper through it, and no blur: the whole device is scaled, and a blur
/// inside a scale is a blur in the wrong place.
class _Bar extends StatelessWidget {
  const _Bar({
    required this.child,
    this.height,
    this.width,
    this.padding = EdgeInsets.zero,
    this.fill = true,
    this.ruled = false,
    this.vertical = false,
  });

  final Widget child;
  final double? height;
  final double? width;
  final EdgeInsets padding;
  final bool fill;
  final bool ruled;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final BorderSide rule = BorderSide(color: tokens.border);

    return ExcludeSemantics(
      child: Container(
        height: height,
        width: width,
        padding: padding,
        decoration: BoxDecoration(
          color: fill ? mixOklab(tokens.surface, 0.88, tokens.backing) : null,
          border: ruled
              ? vertical
                    ? BorderDirectional(end: rule)
                    : Border(top: rule)
              : null,
        ),
        child: child,
      ),
    );
  }
}

/// The time, the one word the chrome writes.
class _Clock extends StatelessWidget {
  const _Clock(this.time, {required this.size});

  final String time;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      time,
      maxLines: 1,
      softWrap: false,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: NebaTheme.of(context).fg,
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      ),
    );
  }
}

/// The page's ink at a share of itself.
class _Ink extends StatelessWidget {
  const _Ink({required this.alpha, required this.builder});

  final double alpha;
  final Widget Function(Color ink) builder;

  @override
  Widget build(BuildContext context) {
    return builder(mixOklab(NebaTheme.of(context).fg, alpha, transparent));
  }
}

/// An app's icon, a menu's title, a tray glyph: anything the chrome does not
/// name.
class _Tile extends StatelessWidget {
  const _Tile({
    required this.width,
    required this.radius,
    this.height,
    this.tone = _Tone.muted,
    this.accent,
  });

  final double width;
  final double? height;
  final double radius;
  final _Tone tone;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final Color fg = NebaTheme.of(context).fg;
    final Color colour = switch (tone) {
      _Tone.accent => accent ?? fg,
      _Tone.faint => mixOklab(fg, 0.12, transparent),
      _Tone.muted => mixOklab(fg, 0.26, transparent),
    };

    return Container(
      width: width,
      height: height ?? width,
      decoration: BoxDecoration(color: colour, borderRadius: BorderRadius.circular(radius)),
    );
  }
}

/// A row of tiles, the first one in the accent when it has one.
class _Tiles extends StatelessWidget {
  const _Tiles({
    required this.count,
    required this.size,
    required this.radius,
    required this.gap,
    this.accent,
  });

  final int count;
  final double size;
  final double radius;
  final double gap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: gap,
      children: <Widget>[
        for (int index = 0; index < count; index++)
          _Tile(
            width: size,
            radius: radius,
            tone: accent != null && index == 0 ? _Tone.accent : _Tone.muted,
            accent: accent,
          ),
      ],
    );
  }
}

/// macOS's dock: a floating sheet of icons with a rule before the last two.
class _Dock extends StatelessWidget {
  const _Dock({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final BorderRadius radius = BorderRadius.circular(22);

    return CustomPaint(
      foregroundPainter: _PlatePainter(radius: radius, tokens: tokens),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: mixOklab(tokens.surface, 0.88, tokens.backing),
          borderRadius: radius,
          boxShadow: tokens.elevation(2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: <Widget>[
            _Tiles(count: 5, size: 52, radius: 14, gap: 10, accent: accent),
            Container(width: 1, height: 44, color: mixOklab(tokens.fg, 0.16, transparent)),
            const _Tiles(count: 2, size: 52, radius: 14, gap: 10),
          ],
        ),
      ),
    );
  }
}

class _PlatePainter extends CustomPainter {
  const _PlatePainter({required this.radius, required this.tokens});

  final BorderRadius radius;
  final NebaTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    paintPlate(canvas, radius.toRRect(Offset.zero & size), tokens, NebaPlate.glass);
  }

  @override
  bool shouldRepaint(_PlatePainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.tokens != tokens;
  }
}

/// The signal, the network and the battery, on the trailing end of a status
/// bar.
class _StatusGlyphs extends StatelessWidget {
  const _StatusGlyphs({required this.height, required this.gap});

  final double height;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final Color ink = NebaTheme.of(context).fg;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: gap,
      children: <Widget>[
        for (final (double width, _GlyphKind kind) in <(double, _GlyphKind)>[
          (17 / 11, _GlyphKind.signal),
          (16 / 12, _GlyphKind.wifi),
          (25 / 12, _GlyphKind.battery),
        ])
          CustomPaint(size: Size(height * width, height), painter: _StatusPainter(kind, ink)),
      ],
    );
  }
}

enum _GlyphKind { signal, wifi, battery }

class _StatusPainter extends CustomPainter {
  const _StatusPainter(this.kind, this.ink);

  final _GlyphKind kind;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fill = Paint()..color = ink;
    final Paint faint = Paint()..color = ink.withValues(alpha: ink.a * 0.35);

    void rect(double x, double y, double w, double h, double r, Paint paint, double unit) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x * unit, y * unit, w * unit, h * unit),
          Radius.circular(r * unit),
        ),
        paint,
      );
    }

    switch (kind) {
      case _GlyphKind.signal:
        final double unit = size.height / 11;

        rect(0, 7.5, 3, 3.5, 1, fill, unit);
        rect(4.7, 5, 3, 6, 1, fill, unit);
        rect(9.4, 2.5, 3, 8.5, 1, fill, unit);
        rect(14, 0, 3, 11, 1, faint, unit);
      case _GlyphKind.wifi:
        final double unit = size.height / 12;
        final Paint stroke = Paint()
          ..color = ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8 * unit
          ..strokeCap = StrokeCap.round;

        canvas
          ..drawArc(
            Rect.fromCircle(center: Offset(8 * unit, 10.4 * unit), radius: 8.6 * unit),
            math.pi * 1.24,
            math.pi * 0.52,
            false,
            stroke,
          )
          ..drawArc(
            Rect.fromCircle(center: Offset(8 * unit, 11.2 * unit), radius: 5.6 * unit),
            math.pi * 1.26,
            math.pi * 0.48,
            false,
            stroke,
          )
          ..drawCircle(Offset(8 * unit, 10.2 * unit), 1.6 * unit, fill);
      case _GlyphKind.battery:
        final double unit = size.height / 12;
        final Paint outline = Paint()
          ..color = ink.withValues(alpha: ink.a * 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3 * unit;

        rect(0.7, 0.7, 20.6, 10.6, 3.2, outline, unit);
        rect(2.6, 2.6, 12.8, 6.8, 1.8, fill, unit);
        rect(22.8, 4, 1.8, 4, 0.9, Paint()..color = outline.color, unit);
    }
  }

  @override
  bool shouldRepaint(_StatusPainter oldDelegate) {
    return oldDelegate.kind != kind || oldDelegate.ink != ink;
  }
}

/// Android's back, home and recents.
class _NavGlyphs extends StatelessWidget {
  const _NavGlyphs({required this.size, required this.gap});

  final double size;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final Color ink = mixOklab(NebaTheme.of(context).fg, 0.72, transparent);

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: gap,
      children: <Widget>[
        for (int index = 0; index < 3; index++)
          CustomPaint(size: Size.square(size), painter: _NavPainter(index, ink)),
      ],
    );
  }
}

class _NavPainter extends CustomPainter {
  const _NavPainter(this.index, this.ink);

  final int index;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.width / 16;
    final Paint stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * unit
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (index) {
      case 0:
        canvas.drawPath(
          Path()
            ..moveTo(10 * unit, 3 * unit)
            ..lineTo(5 * unit, 8 * unit)
            ..lineTo(10 * unit, 13 * unit),
          stroke,
        );
      case 1:
        canvas.drawCircle(Offset(8 * unit, 8 * unit), 5 * unit, stroke);
      default:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(3.5 * unit, 3.5 * unit, 9 * unit, 9 * unit),
            Radius.circular(1.6 * unit),
          ),
          stroke,
        );
    }
  }

  @override
  bool shouldRepaint(_NavPainter oldDelegate) {
    return oldDelegate.index != index || oldDelegate.ink != ink;
  }
}

/// The four squares at the start of a taskbar.
class _StartPainter extends CustomPainter {
  const _StartPainter(this.ink);

  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.width / 16;
    final Paint fill = Paint()..color = ink;

    for (final Offset at in const <Offset>[
      Offset(1, 1),
      Offset(9, 1),
      Offset(1, 9),
      Offset(9, 9),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(at.dx * unit, at.dy * unit, 6 * unit, 6 * unit),
          Radius.circular(1.4 * unit),
        ),
        fill,
      );
    }
  }

  @override
  bool shouldRepaint(_StartPainter oldDelegate) => oldDelegate.ink != ink;
}
