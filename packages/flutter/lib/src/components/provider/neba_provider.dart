/// `NebaProvider`, the one place a product sets its defaults and its colour
/// scheme.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Defaults, the colour scheme and the direction for a whole subtree.
///
/// The React package's `NebaProvider`, the Flutter way: the colour scheme is
/// a value the app owns rather than state the provider keeps, so persisting a
/// reader's choice is the app's to do with whatever storage it already has.
///
/// ```dart
/// NebaProvider(
///   defaults: const NebaDefaults(size: NebaSize.lg, density: NebaDensity.compact),
///   colorScheme: NebaColorScheme.dark,
///   child: app,
/// )
/// ```
///
/// A provider inside another one keeps every default it does not set itself.
class NebaProvider extends StatelessWidget {
  /// Defaults and a colour scheme for [child].
  const NebaProvider({
    this.defaults = NebaDefaults.none,
    this.colorScheme = NebaColorScheme.system,
    this.light,
    this.dark,
    this.textDirection,
    required this.child,
    super.key,
  });

  /// Defaults for every widget under this one.
  final NebaDefaults defaults;

  /// Whether the colours follow the platform's brightness or are pinned.
  final NebaColorScheme colorScheme;

  /// The light tokens, when a product brings its own colours. Defaults to
  /// [NebaTokens.light].
  final NebaTokens? light;

  /// The dark tokens, when a product brings its own colours. Defaults to
  /// [NebaTokens.dark].
  final NebaTokens? dark;

  /// The writing direction of the subtree, or `null` to keep the one above.
  final TextDirection? textDirection;

  /// The subtree.
  final Widget child;

  /// The brightness [colorScheme] resolves to in [context].
  Brightness _brightnessOf(BuildContext context) {
    switch (colorScheme) {
      case NebaColorScheme.light:
        return Brightness.light;
      case NebaColorScheme.dark:
        return Brightness.dark;
      case NebaColorScheme.system:
        return MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.light;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = _brightnessOf(context);
    final NebaTokens tokens = brightness == Brightness.dark
        ? (dark ?? NebaTokens.dark())
        : (light ?? NebaTokens.light());
    final Widget themed = NebaTheme(
      tokens: tokens,
      defaults: NebaTheme.defaultsOf(context).merge(defaults),
      child: child,
    );
    final TextDirection? direction = textDirection;

    if (direction == null) {
      return themed;
    }

    return Directionality(textDirection: direction, child: themed);
  }
}
