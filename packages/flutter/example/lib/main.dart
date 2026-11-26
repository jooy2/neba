import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';
import 'package:neba_example/demos/registry.dart';

/// The gallery: every demo in a list, or one demo on its own.
///
/// `?demo=button/variants` shows that demo alone, which is how the
/// documentation site embeds a Flutter preview, and `?theme=dark` or
/// `?theme=light` pins the colour scheme. Without them, the list.
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
  late NebaColorScheme _scheme = switch (widget.query['theme']) {
    'dark' => NebaColorScheme.dark,
    'light' => NebaColorScheme.light,
    _ => NebaColorScheme.system,
  };

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
        return NebaProvider(
          colorScheme: _scheme,
          child: _Page(
            child: single == null
                ? _Gallery(onSchemePressed: _handleSchemePressed)
                : Padding(padding: const EdgeInsets.all(24), child: single()),
          ),
        );
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
