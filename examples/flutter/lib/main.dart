import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';
import 'package:neba_example/demos/registry.dart';

/// The sample app: Neba UI for Flutter the way a consumer uses it, on a phone
/// or a tablet.
///
/// For now it lists the gallery's demos under a theme switch. The screens of a
/// real app join them as the widgets they need are ported; `TODO.md` at the
/// repository root keeps the order.
void main() {
  runApp(const ShowcaseApp());
}

class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({this.colorScheme = NebaColorScheme.system, super.key});

  /// The colour scheme the app starts in.
  final NebaColorScheme colorScheme;

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  late NebaColorScheme _scheme = widget.colorScheme;

  void _handleSchemePressed(Brightness current) {
    setState(() {
      _scheme = current == Brightness.dark ? NebaColorScheme.light : NebaColorScheme.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Neba UI',
      color: const Color(0xFF3B5BDB),
      debugShowCheckedModeBanner: false,
      builder: (BuildContext context, Widget? _) {
        return NebaProvider(
          colorScheme: _scheme,
          child: _Home(onSchemePressed: _handleSchemePressed),
        );
      },
    );
  }
}

class _Home extends StatelessWidget {
  const _Home({required this.onSchemePressed});

  final ValueChanged<Brightness> onSchemePressed;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final List<MapEntry<String, Widget Function()>> entries = demos.entries.toList();
    final String switchLabel = tokens.brightness == Brightness.dark ? 'Light' : 'Dark';

    return ColoredBox(
      color: tokens.surface,
      child: DefaultTextStyle(
        // The gallery's Inter, which a package's font is reached through.
        style: TextStyle(
          fontFamily: 'Inter',
          package: 'neba_example',
          color: tokens.fg,
          fontSize: NebaScale.controlText[NebaSize.md],
        ),
        child: SafeArea(
          child: ListView.separated(
            key: const Key('demos'),
            padding: const EdgeInsets.all(20),
            itemCount: entries.length + 1,
            separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 28),
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Row(
                  children: <Widget>[
                    const Expanded(child: Text('Neba UI', style: TextStyle(fontSize: 22))),
                    Semantics(
                      button: true,
                      label: 'Switch to the ${switchLabel.toLowerCase()} theme',
                      child: GestureDetector(
                        key: const Key('scheme'),
                        onTap: () => onSchemePressed(tokens.brightness),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            switchLabel,
                            style: TextStyle(color: tokens.roles(NebaColor.primary).onTint),
                          ),
                        ),
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
        ),
      ),
    );
  }
}
