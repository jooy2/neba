import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';
import 'package:neba_example/demos/registry.dart';
import 'package:neba_example/host_bridge.dart';

/// The gallery: every demo in a list, or one demo on its own.
///
/// `?demo=button/variants` shows that demo alone, which is how the
/// documentation site embeds a Flutter preview: on the page's own backdrop,
/// with its height reported to the page and its theme taken from it.
/// `?theme=dark` or `?theme=light` pins the colour scheme, and `?align=center`
/// centres the demo. Without a demo, the list.
void main() {
  runApp(GalleryApp(query: Uri.base.queryParameters));
}

class GalleryApp extends StatefulWidget {
  const GalleryApp({this.query = const <String, String>{}, super.key});

  /// The page's query parameters.
  final Map<String, String> query;

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  static const HostBridge _bridge = HostBridge();

  late NebaColorScheme _scheme = switch (widget.query['theme']) {
    'dark' => NebaColorScheme.dark,
    'light' => NebaColorScheme.light,
    _ => NebaColorScheme.system,
  };

  @override
  void initState() {
    super.initState();

    if (widget.query.containsKey('demo')) {
      _bridge.onTheme(_onPageTheme);
    }
  }

  void _onPageTheme(Brightness brightness) {
    if (!mounted) {
      return;
    }

    setState(() {
      _scheme = brightness == Brightness.dark ? NebaColorScheme.dark : NebaColorScheme.light;
    });
  }

  void _handleSchemePressed() {
    setState(() {
      _scheme = _scheme == NebaColorScheme.dark ? NebaColorScheme.light : NebaColorScheme.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? key = widget.query['demo'];
    final Widget Function()? single = key == null ? null : demos[key];

    return WidgetsApp(
      title: 'Neba UI gallery',
      color: const Color(0xFF3B5BDB),
      debugShowCheckedModeBanner: false,
      builder: (BuildContext context, Widget? _) {
        final Widget body = single == null
            ? _Page(child: _Gallery(onSchemePressed: _handleSchemePressed))
            : _Embedded(
                center: widget.query['align'] == 'center',
                onHeight: _bridge.reportHeight,
                child: single(),
              );

        return NebaProvider(colorScheme: _scheme, child: body);
      },
    );
  }
}

/// The page under the demos: the theme's surface and its text style.
class _Page extends StatelessWidget {
  const _Page({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return ColoredBox(
      color: tokens.surface,
      child: DefaultTextStyle(
        style: TextStyle(color: tokens.fg, fontSize: NebaScale.controlText[NebaSize.md]),
        child: child,
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.onSchemePressed});

  final VoidCallback onSchemePressed;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final List<MapEntry<String, Widget Function()>> entries = demos.entries.toList();

    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: entries.length + 1,
        separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 32),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Row(
              children: <Widget>[
                const Expanded(child: Text('Neba UI', style: TextStyle(fontSize: 20))),
                GestureDetector(
                  onTap: onSchemePressed,
                  child: Text(
                    tokens.brightness == Brightness.dark ? 'Light' : 'Dark',
                    style: TextStyle(color: tokens.roles(NebaColor.primary).onTint),
                  ),
                ),
              ],
            );
          }

          final MapEntry<String, Widget Function()> entry = entries[index - 1];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(entry.key, style: TextStyle(color: tokens.mutedFg)),
              const SizedBox(height: 12),
              entry.value(),
            ],
          );
        },
      ),
    );
  }
}

/// One demo, the way the documentation site shows it: on the same backdrop as
/// a React preview, laid out at its natural height and reporting that height,
/// so the page can size the frame to it rather than scroll inside it.
class _Embedded extends StatelessWidget {
  const _Embedded({required this.center, required this.onHeight, required this.child});

  final bool center;
  final ValueChanged<double> onHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final AlignmentGeometry alignment = center
        ? Alignment.topCenter
        : AlignmentDirectional.topStart;

    return DefaultTextStyle(
      style: TextStyle(color: tokens.fg, fontSize: NebaScale.controlText[NebaSize.md]),
      child: CustomPaint(
        painter: _Backdrop(tokens),
        child: OverflowBox(
          alignment: Alignment.topCenter,
          minHeight: 0,
          maxHeight: double.infinity,
          child: _Measured(
            onHeight: onHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Align(alignment: alignment, heightFactor: 1, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reports its child's height after every layout that changes it.
class _Measured extends StatefulWidget {
  const _Measured({required this.onHeight, required this.child});

  final ValueChanged<double> onHeight;
  final Widget child;

  @override
  State<_Measured> createState() => _MeasuredState();
}

class _MeasuredState extends State<_Measured> {
  double? _reported;

  void _measure() {
    final RenderObject? box = context.findRenderObject();

    if (!mounted || box is! RenderBox || !box.hasSize || box.size.height == _reported) {
      return;
    }

    _reported = box.size.height;
    widget.onHeight(box.size.height);
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((Duration _) => _measure());
  }

  @override
  Widget build(BuildContext context) {
    _scheduleMeasure();

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (SizeChangedLayoutNotification notification) {
        _scheduleMeasure();
        return true;
      },
      child: SizeChangedLayoutNotifier(child: widget.child),
    );
  }
}

/// The documentation site's preview backdrop, `.neba-demo-canvas` in
/// `docs.css`, drawn from the tokens: a sheet a shade off the surface, two
/// faint glows in the top corners and a 40-pixel grid. A preview has to draw it
/// itself, because a blur inside the frame can only blur what the frame draws.
class _Backdrop extends CustomPainter {
  const _Backdrop(this.tokens);

  final NebaTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    canvas.drawRect(bounds, Paint()..color = Color.lerp(tokens.surface, tokens.fg, 0.035)!);

    void glow(Offset center, Size ellipse, Color color) {
      final double radius = ellipse.width / 2;

      canvas.save();
      canvas.clipRect(bounds);
      canvas.translate(center.dx, center.dy);
      canvas.scale(1, ellipse.height / ellipse.width);
      canvas.drawCircle(
        Offset.zero,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: <Color>[color, color.withValues(alpha: 0)],
            stops: const <double>[0, 0.7],
          ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius)),
      );
      canvas.restore();
    }

    glow(
      Offset(size.width * 0.08, size.height * -0.2),
      const Size(512, 320),
      tokens.roles(NebaColor.primary).accent.withValues(alpha: 0.10),
    );
    glow(
      Offset(size.width * 0.96, 0),
      const Size(448, 288),
      tokens.roles(NebaColor.info).accent.withValues(alpha: 0.09),
    );

    final Paint line = Paint()
      ..color = tokens.fg.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    const double step = 40;

    for (double y = 0; y < size.height; y += step) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), line);
    }

    for (double x = 0; x < size.width; x += step) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 1, size.height), line);
    }
  }

  @override
  bool shouldRepaint(_Backdrop oldDelegate) => oldDelegate.tokens != tokens;
}
