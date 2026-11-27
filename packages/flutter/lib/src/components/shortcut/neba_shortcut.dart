/// `NebaShortcut`, a keyboard shortcut drawn as key caps.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Which keyboard a [NebaShortcut] names its keys for.
enum NebaShortcutOS {
  /// The platform the app runs on, from `defaultTargetPlatform`: macOS and
  /// iOS are [mac], Windows is [windows], everything else [linux]. On the web
  /// it is the browser's platform.
  auto,

  /// Command, Option and Control as the symbols macOS draws, run together.
  mac,

  /// Ctrl, Alt and Win, joined with a plus.
  windows,

  /// Ctrl, Alt and Super, joined with a plus.
  linux,
}

/// A keyboard key, or a combination of them, drawn as key caps.
///
/// `Mod` is the token for the modifier shortcuts are built on, which is
/// Command on a Mac and Control everywhere else, so one string is right for
/// every reader; [os] names a platform for a page that has to describe one. A
/// key macOS draws as a symbol is announced by its name, so a screen reader
/// says "Command K" rather than "place of interest sign K".
///
/// ```dart
/// const NebaShortcut(keys: 'Mod+K')
/// ```
class NebaShortcut extends StatelessWidget {
  /// The keys in [keys], split on `+`.
  const NebaShortcut({
    required String this.keys,
    this.os = NebaShortcutOS.auto,
    this.separator,
    this.variant,
    this.size,
    this.color = NebaColor.secondary,
    this.density,
    this.elevation = 0,
    super.key,
  }) : assert(elevation >= nebaElevationMin && elevation <= nebaElevationMax);

  /// The keys in [keys], one to an entry, for a shortcut whose key is itself
  /// a plus: `<String>['Ctrl', '+']`.
  const NebaShortcut.split({
    required List<String> this.keys,
    this.os = NebaShortcutOS.auto,
    this.separator,
    this.variant,
    this.size,
    this.color = NebaColor.secondary,
    this.density,
    this.elevation = 0,
    super.key,
  }) : assert(elevation >= nebaElevationMin && elevation <= nebaElevationMax);

  /// The keys: a [String] split on `+`, or a [List] of them, by the
  /// constructor. A single letter is drawn in capitals and a token the widget
  /// does not know is drawn as written.
  final Object keys;

  /// Which keyboard to name the modifiers for.
  final NebaShortcutOS os;

  /// What goes between two keys. Left out, the platform's own convention: a
  /// `+` on Windows and Linux, and nothing on macOS, where a shortcut is a run
  /// of symbols. A [SizedBox.shrink] puts nothing between them anywhere.
  final Widget? separator;

  /// The weight of a key cap. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline], the hairline box a key cap is in every manual.
  final NebaVariant? variant;

  /// The shortcut's size. A key cap is one step down the control ladder, as a
  /// chip is. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of a key cap.
  final NebaColor color;

  /// How much padding a key cap has. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.compact].
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`. This is a picture of a key, not a key.
  final NebaElevation elevation;

  /// The narrowest a key cap is at each step, so `⌘` and `K` are one square.
  static const Map<NebaSize, double> keyMinWidth = <NebaSize, double>{
    NebaSize.xs: 22,
    NebaSize.sm: 26,
    NebaSize.md: 32,
    NebaSize.lg: 40,
    NebaSize.xl: 48,
  };

  /// The space between two keys, and between a key and a separator.
  static const double gap = 4;

  /// The platform [os] resolves to.
  static NebaShortcutOS resolve(NebaShortcutOS os) {
    if (os != NebaShortcutOS.auto) {
      return os;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.macOS || TargetPlatform.iOS => NebaShortcutOS.mac,
      TargetPlatform.windows => NebaShortcutOS.windows,
      _ => NebaShortcutOS.linux,
    };
  }

  /// What each key in [keys] is drawn as and what it is called, on [os], in
  /// the order the platform writes them.
  static List<({String symbol, String name})> labelsOf(Object keys, NebaShortcutOS os) {
    final NebaShortcutOS platform = resolve(os);
    final List<String> tokens = _tokenize(keys);
    final List<String> ordered = platform == NebaShortcutOS.mac ? _inMacOrder(tokens) : tokens;

    return <({String symbol, String name})>[
      for (final String token in ordered) _labelFor(token, platform),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = this.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = this.density ?? defaults.density ?? NebaDensity.compact;
    final NebaColorRoles roles = tokens.roles(color);
    final NebaSize step = _keyStep[size]!;
    final NebaShortcutOS platform = resolve(os);
    final List<({String symbol, String name})> labels = labelsOf(keys, platform);
    final BorderRadius radius = BorderRadius.circular(tokens.radius[step]!);
    final double height = NebaScale.controlHeight[step]!;

    final (Color fill, Color? edge, NebaPlate plate, Color ink) = switch (variant) {
      NebaVariant.solid => (roles.fill, null, NebaPlate.solid, roles.family.onSolid),
      NebaVariant.outline => (roles.panel, roles.line, NebaPlate.glass, roles.onTint),
      NebaVariant.text => (roles.soft, null, NebaPlate.none, roles.onTint),
    };
    final bool textured = variant != NebaVariant.text;

    final TextStyle capText = TextStyle(
      fontFamily: NebaScale.monoFonts.first,
      fontFamilyFallback: NebaScale.monoFonts.sublist(1),
      fontSize: NebaScale.controlText[step],
      fontWeight: FontWeight.w500,
      height: 1,
      color: ink,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );

    Widget cap(String symbol) {
      return NebaSheet(
        fill: fill,
        edge: edge,
        plate: plate,
        elevation: elevation,
        borderRadius: radius,
        blur: textured,
        texture: textured,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: NebaShortcut.keyMinWidth[step]! - (edge == null ? 0 : 2),
            minHeight: height - (edge == null ? 0 : 2),
            maxHeight: height - (edge == null ? 0 : 2),
          ),
          child: Padding(
            // Inside the hairline, as CSS pads inside a border.
            padding: EdgeInsets.symmetric(horizontal: NebaScale.paddingX[density]![step]!),
            child: Center(
              widthFactor: 1,
              child: Text(symbol, style: capText, maxLines: 1, softWrap: false),
            ),
          ),
        ),
      );
    }

    final Widget joiner =
        separator ?? (platform == NebaShortcutOS.mac ? const SizedBox.shrink() : const Text('+'));
    final bool joined = separator != null || platform != NebaShortcutOS.mac;

    return Semantics(
      container: true,
      label: labels.map((({String symbol, String name}) label) => label.name).join(' '),
      child: ExcludeSemantics(
        child: DefaultTextStyle.merge(
          style: TextStyle(color: tokens.mutedFg),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: gap,
            children: <Widget>[
              for (int index = 0; index < labels.length; index++) ...<Widget>[
                if (index > 0 && joined) joiner,
                cap(labels[index].symbol),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// A key cap one step down the control ladder.
  static const Map<NebaSize, NebaSize> _keyStep = <NebaSize, NebaSize>{
    NebaSize.xs: NebaSize.xs,
    NebaSize.sm: NebaSize.xs,
    NebaSize.md: NebaSize.sm,
    NebaSize.lg: NebaSize.md,
    NebaSize.xl: NebaSize.lg,
  };
}

/// Every spelling one key has, folded into the one the tables use, as the
/// React package's `internal/keys.ts` folds them.
const Map<String, String> _aliases = <String, String>{
  'cmdorctrl': 'mod',
  'commandorcontrol': 'mod',
  'cmd': 'meta',
  'command': 'meta',
  'super': 'meta',
  'win': 'meta',
  'windows': 'meta',
  'control': 'ctrl',
  'option': 'alt',
  'opt': 'alt',
  'return': 'enter',
  'esc': 'escape',
  'del': 'delete',
  'caps': 'capslock',
  'spacebar': 'space',
  'up': 'arrowup',
  'down': 'arrowdown',
  'left': 'arrowleft',
  'right': 'arrowright',
};

final RegExp _foldable = RegExp(r'[\s_-]');

List<String> _tokenize(Object keys) {
  final List<String> parts = keys is String ? keys.split('+') : keys as List<String>;

  return <String>[
    for (final String part in parts)
      if (part.trim().isNotEmpty) part.trim(),
  ];
}

String _canonical(String token) {
  if (token == ' ') {
    return 'space';
  }

  final String folded = token.toLowerCase().replaceAll(_foldable, '');

  return _aliases[folded] ?? folded;
}

({String symbol, String name}) _word(String text) => (symbol: text, name: text);

/// The keys spelled differently somewhere, by platform.
final Map<String, Map<NebaShortcutOS, ({String symbol, String name})>> _labels =
    <String, Map<NebaShortcutOS, ({String symbol, String name})>>{
      'mod': _byPlatform((symbol: '⌘', name: 'Command'), 'Ctrl', 'Ctrl'),
      'meta': _byPlatform((symbol: '⌘', name: 'Command'), 'Win', 'Super'),
      'ctrl': _byPlatform((symbol: '⌃', name: 'Control'), 'Ctrl', 'Ctrl'),
      'alt': _byPlatform((symbol: '⌥', name: 'Option'), 'Alt', 'Alt'),
      'shift': _byPlatform((symbol: '⇧', name: 'Shift'), 'Shift', 'Shift'),
      'enter': _byPlatform((symbol: '↩', name: 'Enter'), 'Enter', 'Enter'),
      'tab': _byPlatform((symbol: '⇥', name: 'Tab'), 'Tab', 'Tab'),
      'escape': _byPlatform((symbol: '⎋', name: 'Escape'), 'Esc', 'Esc'),
      'backspace': _byPlatform((symbol: '⌫', name: 'Backspace'), 'Backspace', 'Backspace'),
      'delete': _byPlatform((symbol: '⌦', name: 'Delete'), 'Del', 'Del'),
      'capslock': _byPlatform((symbol: '⇪', name: 'Caps Lock'), 'Caps Lock', 'Caps Lock'),
    };

Map<NebaShortcutOS, ({String symbol, String name})> _byPlatform(
  ({String symbol, String name}) mac,
  String windows,
  String linux,
) {
  return <NebaShortcutOS, ({String symbol, String name})>{
    NebaShortcutOS.mac: mac,
    NebaShortcutOS.windows: _word(windows),
    NebaShortcutOS.linux: _word(linux),
  };
}

/// The keys drawn as arrows on every platform: an arrow is what is printed on
/// the key.
const Map<String, ({String symbol, String name})> _arrows =
    <String, ({String symbol, String name})>{
      'arrowup': (symbol: '↑', name: 'Arrow up'),
      'arrowdown': (symbol: '↓', name: 'Arrow down'),
      'arrowleft': (symbol: '←', name: 'Arrow left'),
      'arrowright': (symbol: '→', name: 'Arrow right'),
    };

/// Apple's order for modifiers, which macOS draws the same way in every menu.
const Map<String, int> _macRank = <String, int>{
  'ctrl': 0,
  'alt': 1,
  'shift': 2,
  'meta': 3,
  'mod': 3,
};

/// A Mac shortcut in the order macOS writes it, `⇧⌘P` for `Mod+Shift+P`. Left
/// alone when something other than a modifier comes before the last key.
List<String> _inMacOrder(List<String> tokens) {
  if (tokens.isEmpty) {
    return tokens;
  }

  final List<String> modifiers = tokens.sublist(0, tokens.length - 1);

  if (!modifiers.every((String token) => _macRank.containsKey(_canonical(token)))) {
    return tokens;
  }

  // A stable sort: two tokens of one rank keep the order they were written in.
  final List<(int, String)> ranked =
      <(int, String)>[for (int i = 0; i < modifiers.length; i++) (i, modifiers[i])]
        ..sort(((int, String) a, (int, String) b) {
          final int byRank = _macRank[_canonical(a.$2)]!.compareTo(_macRank[_canonical(b.$2)]!);

          return byRank != 0 ? byRank : a.$1.compareTo(b.$1);
        });

  return <String>[for (final (int, String) entry in ranked) entry.$2, tokens.last];
}

({String symbol, String name}) _labelFor(String token, NebaShortcutOS os) {
  final String canonical = _canonical(token);
  final ({String symbol, String name})? arrow = _arrows[canonical];

  if (arrow != null) {
    return arrow;
  }

  final ({String symbol, String name})? known = _labels[canonical]?[os];

  if (known != null) {
    return known;
  }

  // Printed as written, but a single letter in capitals, as it is on the key.
  return _word(token.length == 1 ? token.toUpperCase() : token);
}
