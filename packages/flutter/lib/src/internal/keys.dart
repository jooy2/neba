/// A key combination read rather than drawn: the React package's
/// `internal/keys.ts`, the side of it that binds a key.
///
/// `NebaShortcut` draws `Mod+K` and a CommandPalette binds it, and both have
/// to agree on which key a token means, or a key cap is drawn over a shortcut
/// that never fires. The aliases here are the ones `NebaShortcut` folds its
/// tokens with, written out once more because it keeps its own table; the two
/// belong in this one module.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Every spelling one key has, folded into the one the matcher uses.
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

/// [token] reduced to the name the matcher knows it by. It folds a key's own
/// label too, so `Esc` written by a caller and `Escape` reported by the
/// keyboard meet as `escape`.
String nebaCanonicalKey(String token) {
  if (token == ' ') {
    return 'space';
  }

  final String folded = token.toLowerCase().replaceAll(_foldable, '');

  return _aliases[folded] ?? folded;
}

/// The USB HID usage of the key a letter or a digit is printed on in the US
/// layout, which a key pressed with Option on a Mac still reports when the
/// character it types has changed.
int? _physicalUsage(String key) {
  if (key.length != 1) {
    return null;
  }

  final int unit = key.codeUnitAt(0);

  if (unit >= 0x61 && unit <= 0x7a) {
    return 0x00070004 + unit - 0x61;
  }

  if (unit >= 0x31 && unit <= 0x39) {
    return 0x0007001e + unit - 0x31;
  }

  return unit == 0x30 ? 0x00070027 : null;
}

/// A key combination such as `Mod+K`, parsed once.
///
/// `Mod` is Command on macOS and iOS and Control everywhere else. The
/// modifiers are matched exactly, so `K` and `Mod+K` never both fire.
@immutable
class NebaKeyCombo {
  const NebaKeyCombo._({
    required this.key,
    required this.meta,
    required this.control,
    required this.alt,
    required this.shift,
  });

  /// [keys] written as `NebaShortcut` writes them, `+` between the tokens.
  factory NebaKeyCombo.parse(String keys) {
    final bool mac =
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final List<String> tokens = <String>[
      for (final String part in keys.split('+'))
        if (part.trim().isNotEmpty) nebaCanonicalKey(part.trim()),
    ];
    String key = '';
    bool meta = false;
    bool control = false;
    bool alt = false;
    bool shift = false;

    for (final String token in tokens) {
      switch (token) {
        case 'mod':
          meta = meta || mac;
          control = control || !mac;
        case 'meta':
          meta = true;
        case 'ctrl':
          control = true;
        case 'alt':
          alt = true;
        case 'shift':
          shift = true;
        default:
          key = token;
      }
    }

    return NebaKeyCombo._(key: key, meta: meta, control: control, alt: alt, shift: shift);
  }

  /// The key that is not a modifier, canonical.
  final String key;

  /// Whether Command, Windows or Super is held.
  final bool meta;

  /// Whether Control is held.
  final bool control;

  /// Whether Alt or Option is held.
  final bool alt;

  /// Whether Shift is held.
  final bool shift;

  /// Whether [event], with what [keyboard] says is held, is this combination.
  bool accepts(KeyEvent event, HardwareKeyboard keyboard) {
    if (event is! KeyDownEvent || key.isEmpty) {
      return false;
    }

    if (keyboard.isMetaPressed != meta ||
        keyboard.isControlPressed != control ||
        keyboard.isAltPressed != alt ||
        keyboard.isShiftPressed != shift) {
      return false;
    }

    if (nebaCanonicalKey(event.logicalKey.keyLabel) == key) {
      return true;
    }

    final int? usage = _physicalUsage(key);

    return usage != null && event.physicalKey.usbHidUsage == usage;
  }
}
