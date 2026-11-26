/// How a widget finds its tokens and its defaults.
///
/// A Neba widget works with no setup: with nothing above it, [NebaTheme.of]
/// answers with the tokens of the platform's brightness, the way the React
/// package's stylesheet follows `prefers-color-scheme` with no provider. A
/// [NebaTheme] in the tree pins the tokens for its subtree, and `NebaProvider`
/// adds the defaults and the colour scheme on top.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Defaults for every widget in a subtree, the `defaults` of the React
/// package's `NebaProvider`.
///
/// Every field is optional, and a widget's own argument always wins over it:
/// a widget resolves an axis as its argument, then its group, then these
/// defaults, then its own default.
@immutable
class NebaDefaults {
  /// Defaults for a subtree. Leave a field out to keep what is above.
  const NebaDefaults({
    this.size,
    this.density,
    this.variant,
    this.locale,
    this.labelPlacement,
    this.spacing,
  });

  /// No defaults at all.
  static const NebaDefaults none = NebaDefaults();

  /// The size every widget that takes one starts from.
  final NebaSize? size;

  /// The density every widget that takes one starts from.
  final NebaDensity? density;

  /// The variant every widget that takes one starts from.
  final NebaVariant? variant;

  /// The language of the words the library says on its own behalf, and of the
  /// dates and numbers it formats.
  final Locale? locale;

  /// Where every field-shaped widget draws its label.
  final NebaLabelPlacement? labelPlacement;

  /// The gap between the fields of a form and a fieldset, on the spacing
  /// scale: `4` is 16 logical pixels. It applies to those two and nothing
  /// else.
  final double? spacing;

  /// These defaults with every field [other] sets taking its place.
  NebaDefaults merge(NebaDefaults? other) {
    if (other == null) {
      return this;
    }

    return NebaDefaults(
      size: other.size ?? size,
      density: other.density ?? density,
      variant: other.variant ?? variant,
      locale: other.locale ?? locale,
      labelPlacement: other.labelPlacement ?? labelPlacement,
      spacing: other.spacing ?? spacing,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NebaDefaults &&
        other.size == size &&
        other.density == density &&
        other.variant == variant &&
        other.locale == locale &&
        other.labelPlacement == labelPlacement &&
        other.spacing == spacing;
  }

  @override
  int get hashCode => Object.hash(size, density, variant, locale, labelPlacement, spacing);
}

/// Pins the tokens, and the defaults, for a subtree.
///
/// Most apps never write one: `NebaProvider` puts one in the tree, and with
/// none at all the tokens follow the platform's brightness.
class NebaTheme extends InheritedWidget {
  /// The [tokens] and [defaults] for [child] and everything under it.
  const NebaTheme({
    required this.tokens,
    this.defaults = NebaDefaults.none,
    required super.child,
    super.key,
  });

  /// The tokens for this subtree.
  final NebaTokens tokens;

  /// The defaults for this subtree.
  final NebaDefaults defaults;

  /// The nearest [NebaTheme], or `null` when there is none.
  static NebaTheme? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NebaTheme>();
  }

  /// The tokens for [context]: the nearest [NebaTheme]'s, or the platform
  /// brightness's when there is none.
  ///
  /// A reader who turned on the platform's high-contrast setting gets the
  /// opaque sheets [NebaTokens.withReducedTransparency] describes: Flutter
  /// exposes no reduced-transparency setting of its own, and on iOS the two
  /// are the accessibility settings that ask for less see-through chrome.
  static NebaTokens of(BuildContext context) {
    final NebaTheme? theme = maybeOf(context);
    final NebaTokens tokens =
        theme?.tokens ??
        NebaTokens.of(MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.light);

    if (MediaQuery.maybeHighContrastOf(context) ?? false) {
      return tokens.withReducedTransparency();
    }

    return tokens;
  }

  /// The defaults for [context], or [NebaDefaults.none] when nothing set any.
  static NebaDefaults defaultsOf(BuildContext context) {
    return maybeOf(context)?.defaults ?? NebaDefaults.none;
  }

  @override
  bool updateShouldNotify(NebaTheme oldWidget) {
    return tokens != oldWidget.tokens || defaults != oldWidget.defaults;
  }
}
