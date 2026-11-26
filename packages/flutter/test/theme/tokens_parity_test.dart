// That the Dart tokens are the React package's stylesheet, value for value.
//
// This reads `packages/react/src/styles.css`, evaluates every token the
// Flutter theme exposes the way a browser would — `oklch()`, `rgb()`,
// `var()` and `color-mix()` — and compares the result with `NebaTokens`, in
// both themes and under reduced transparency. A value changed on one side
// only fails here, and so does a new derived role in a colour family that
// the Dart side has not learned yet.

import 'dart:io';
import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/color.dart';

final String _stylesheet = File('../react/src/styles.css').readAsStringSync();

void main() {
  final Map<String, String> light = _block(':root,\n.light,');
  final Map<String, String> dark = _block(".dark,\n[data-theme='dark'] {");
  final Map<String, String> derived = _block(':root,\n.dark,\n.light,');

  final Map<String, Map<String, String>> themes = <String, Map<String, String>>{
    'light': <String, String>{...light, ...derived},
    'dark': <String, String>{...light, ...dark, ...derived},
  };

  for (final MapEntry<String, Map<String, String>> theme in themes.entries) {
    final NebaTokens tokens = theme.key == 'dark' ? NebaTokens.dark() : NebaTokens.light();
    final _Css css = _Css(theme.value);

    group('the ${theme.key} theme', () {
      test('has every neutral token the stylesheet declares', () {
        _expectColors(css, _neutrals(tokens));
      });

      test('has every colour family, base and derived', () {
        _expectColors(css, _families(tokens));
      });

      test('reads the same numbers', () {
        expect(css.number('--neba-fill-alpha'), closeTo(tokens.fillAlpha, 1e-9));
        expect(css.number('--neba-ring-alpha'), closeTo(tokens.ringAlpha, 1e-9));

        final RegExpMatch blur = RegExp(
          r'blur\(([\d.]+)px\) saturate\(([\d.]+)\)',
        ).firstMatch(css.raw('--neba-blur'))!;
        expect(double.parse(blur.group(1)!), tokens.blurSigma);
        expect(double.parse(blur.group(2)!), tokens.saturation);

        for (final NebaSize size in NebaSize.values) {
          expect(
            css.length('--neba-radius-${size.name}'),
            tokens.radius[size],
            reason: 'radius ${size.name}',
          );
        }
      });

      test('starts the sheen with the same light', () {
        final String sheen = css.raw('--neba-sheen');
        final String first = RegExp(r'rgb\([^)]*\)').firstMatch(sheen)!.group(0)!;
        _expectColor(css.color(first), tokens.sheen, '--neba-sheen');
        expect(sheen, startsWith('linear-gradient(148deg,'));
        expect(sheen, endsWith('52%)'));
      });

      test('draws charts in the same colours, with the same ink on each', () {
        void ramp(String name, List<Color> colours, List<NebaInkTone> inks, int length) {
          expect(colours, hasLength(length), reason: name);
          expect(inks, hasLength(length), reason: name);

          for (int i = 0; i < length; i++) {
            final String step = name.isEmpty ? '${i + 1}' : '$name-${i + 1}';
            final String on = name.isEmpty ? 'on-${i + 1}' : '$name-on-${i + 1}';

            _expectColor(css.color('var(--neba-chart-$step)'), colours[i], '--neba-chart-$step');
            _expectColor(
              css.color('var(--neba-chart-$on)'),
              tokens.ink(inks[i]),
              '--neba-chart-$on',
            );
          }
        }

        final NebaChartPalette chart = tokens.chart;
        ramp('', chart.series, chart.seriesInk, 8);
        ramp('seq', chart.sequential, chart.sequentialInk, 5);
        ramp('div', chart.diverging, chart.divergingInk, 5);

        _expectColors(css, <String, Color>{
          '--neba-chart-grid': tokens.chartGrid,
          '--neba-chart-axis': tokens.chartAxis,
          '--neba-chart-baseline': tokens.chartBaseline,
          '--neba-chart-gap': tokens.chartGap,
        });
      });

      test('colours code in the same palette', () {
        const List<String> names = <String>[
          'bg',
          'fg',
          'comment',
          'keyword',
          'string',
          'number',
          'function',
          'type',
          'variable',
          'tag',
          'attr',
          'meta',
          'add',
          'del',
        ];
        final List<Color> palette = tokens.code.all;

        for (int i = 0; i < names.length; i++) {
          _expectColor(
            css.color('var(--neba-code-auto-${names[i]})'),
            palette[i],
            '--neba-code-auto-${names[i]}',
          );
        }
      });

      test('makes the same sheets opaque under reduced transparency', () {
        final _Css opaque = _Css(<String, String>{
          ...theme.value,
          '--neba-backing': 'var(--neba-surface)',
        });
        final NebaTokens reduced = tokens.withReducedTransparency();

        _expectColors(opaque, _neutrals(reduced));
        _expectColors(opaque, _families(reduced));
        expect(reduced.blurSigma, 0);
      });
    });
  }

  test('every role a family derives in the stylesheet is one the Dart side has', () {
    final Set<String> roles = <String>{
      for (final RegExpMatch match in RegExp(r'--neba-primary-([a-z-]+):').allMatches(_stylesheet))
        match.group(1)!,
    };

    expect(roles, unorderedEquals(_roleNames));
  });

  test('the motion tokens are the scale\'s', () {
    final _Css css = _Css(light);

    expect(css.raw('--neba-duration'), '${NebaScale.duration.inMilliseconds}ms');
    expect(css.raw('--neba-duration-fill'), '${NebaScale.durationFill.inMilliseconds}ms');
    expect(css.raw('--neba-duration-window'), '${NebaScale.durationWindow.inMilliseconds}ms');
    expect(css.raw('--neba-ease'), 'cubic-bezier(0.32, 0.72, 0, 1)');
  });
}

/// The roles every family has in the stylesheet, by suffix.
const List<String> _roleNames = <String>[
  'solid',
  'solid-hover',
  'solid-active',
  'on-solid',
  'accent',
  'fill',
  'fill-hover',
  'fill-active',
  'soft',
  'soft-hover',
  'soft-press',
  'on-tint',
  'panel',
  'panel-hover',
  'panel-press',
  'line',
  'line-hover',
  'ring',
];

Map<String, Color> _neutrals(NebaTokens tokens) {
  return <String, Color>{
    '--neba-surface': tokens.surface,
    '--neba-fg': tokens.fg,
    '--neba-muted-fg': tokens.mutedFg,
    '--neba-border': tokens.border,
    '--neba-disabled-bg': tokens.disabledBg,
    '--neba-disabled-fg': tokens.disabledFg,
    '--neba-disabled-border': tokens.disabledBorder,
    '--neba-backing': tokens.backing,
    '--neba-plate-edge': tokens.plateEdge,
    '--neba-plate-top': tokens.plateTop,
    '--neba-glass-bg': tokens.glassBg,
    '--neba-panel': tokens.panel,
    '--neba-panel-hover': tokens.panelHover,
    '--neba-panel-press': tokens.panelPress,
    '--neba-groove': tokens.groove,
    '--neba-groove-hover': tokens.grooveHover,
    '--neba-glow-on-fill': tokens.glowOnFill,
    '--neba-flash-on-fill': tokens.flashOnFill,
    '--neba-scrim': tokens.scrim,
    '--neba-shadow-ambient': tokens.shadowAmbient,
  };
}

Map<String, Color> _families(NebaTokens tokens) {
  final Map<String, Color> colors = <String, Color>{};

  for (final NebaColor color in NebaColor.values) {
    final NebaColorRoles roles = tokens.roles(color);
    final NebaColorFamily family = roles.family;
    final Map<String, Color> byRole = <String, Color>{
      'solid': family.solid,
      'solid-hover': family.solidHover,
      'solid-active': family.solidActive,
      'on-solid': family.onSolid,
      'accent': family.accent,
      'fill': roles.fill,
      'fill-hover': roles.fillHover,
      'fill-active': roles.fillActive,
      'soft': roles.soft,
      'soft-hover': roles.softHover,
      'soft-press': roles.softPress,
      'on-tint': roles.onTint,
      'panel': roles.panel,
      'panel-hover': roles.panelHover,
      'panel-press': roles.panelPress,
      'line': roles.line,
      'line-hover': roles.lineHover,
      'ring': roles.ring,
    };

    for (final MapEntry<String, Color> entry in byRole.entries) {
      colors['--neba-${color.name}-${entry.key}'] = entry.value;
    }
  }

  return colors;
}

void _expectColors(_Css css, Map<String, Color> expected) {
  for (final MapEntry<String, Color> entry in expected.entries) {
    _expectColor(css.color('var(${entry.key})'), entry.value, entry.key);
  }
}

/// Equal to within one step of an 8-bit channel, which is the precision a
/// browser draws with.
void _expectColor(Color css, Color dart, String name) {
  const double step = 1.01 / 255;
  final bool transparentBoth = css.a == 0 && dart.a == 0;

  expect((css.a - dart.a).abs(), lessThan(0.005), reason: '$name alpha: css $css, dart $dart');

  if (transparentBoth) {
    return;
  }

  expect((css.r - dart.r).abs(), lessThan(step), reason: '$name red: css $css, dart $dart');
  expect((css.g - dart.g).abs(), lessThan(step), reason: '$name green: css $css, dart $dart');
  expect((css.b - dart.b).abs(), lessThan(step), reason: '$name blue: css $css, dart $dart');
}

/// The declarations of the first rule whose selector starts with [selector],
/// comments taken out and values on one line.
Map<String, String> _block(String selector) {
  final String source = _stylesheet.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
  final int start = source.indexOf(selector);

  if (start == -1) {
    throw StateError('styles.css has no rule starting "$selector"');
  }

  final int open = source.indexOf('{', start);
  int depth = 0;
  int end = open;

  for (int i = open; i < source.length; i++) {
    if (source[i] == '{') {
      depth++;
    } else if (source[i] == '}') {
      depth--;

      if (depth == 0) {
        end = i;
        break;
      }
    }
  }

  final Map<String, String> declarations = <String, String>{};

  for (final RegExpMatch match in RegExp(
    r'(--neba-[\w-]+)\s*:\s*([^;]+);',
  ).allMatches(source.substring(open + 1, end))) {
    declarations[match.group(1)!] = match.group(2)!.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  return declarations;
}

/// A browser's reading of the custom properties, as far as the tokens need.
class _Css {
  _Css(this.properties);

  final Map<String, String> properties;

  String raw(String name) {
    final String? value = properties[name];

    if (value == null) {
      throw StateError('styles.css does not declare $name');
    }

    return value;
  }

  double number(String name) => _percent(_resolve(raw(name)));

  double length(String name) {
    final String value = _resolve(raw(name));

    if (value.endsWith('rem')) {
      return double.parse(value.substring(0, value.length - 3)) * 16;
    }

    return double.parse(value.replaceAll('px', ''));
  }

  Color color(String expression) => _color(expression.trim());

  String _resolve(String value) {
    final RegExpMatch? match = RegExp(r'^var\((--[\w-]+)\)$').firstMatch(value.trim());

    return match == null ? value.trim() : _resolve(raw(match.group(1)!));
  }

  double _percent(String value) {
    final String resolved = _resolve(value);

    return resolved.endsWith('%')
        ? double.parse(resolved.substring(0, resolved.length - 1)) / 100
        : double.parse(resolved);
  }

  Color _color(String expression) {
    final String value = _resolve(expression);

    if (value == 'transparent') {
      return transparent;
    }

    if (value == 'white') {
      return white;
    }

    final RegExpMatch? call = RegExp(r'^([a-z-]+)\((.*)\)$').firstMatch(value);

    if (call == null) {
      throw StateError('cannot read the colour "$value"');
    }

    final String name = call.group(1)!;
    final String body = call.group(2)!;

    switch (name) {
      case 'oklch':
        final List<String> parts = body.split('/');
        final List<String> channels = parts[0].trim().split(RegExp(r'\s+'));

        return oklch(
          _percent(channels[0]),
          double.parse(channels[1]),
          double.parse(channels[2]),
          parts.length > 1 ? _percent(parts[1]) : 1,
        );
      case 'rgb':
        final List<String> parts = body.split('/');
        final List<int> channels = parts[0].trim().split(RegExp(r'\s+')).map(int.parse).toList();

        return rgb(
          channels[0],
          channels[1],
          channels[2],
          parts.length > 1 ? _percent(parts[1]) : 1,
        );
      case 'color-mix':
        final List<String> arguments = _splitTopLevel(body);
        final String space = arguments[0].replaceFirst('in ', '').trim();
        final List<String> first = _splitAmount(arguments[1]);
        final Color a = _color(first[0]);
        final Color b = _color(arguments[2]);
        final double amount = _percent(first[1]);

        return space == 'oklab' ? mixOklab(a, amount, b) : mixSrgb(a, amount, b);
      default:
        throw StateError('cannot read the colour function $name()');
    }
  }

  /// `var(--x) 72%` into the colour and the amount.
  List<String> _splitAmount(String argument) {
    final String trimmed = argument.trim();
    final int space = trimmed.lastIndexOf(' ');

    return <String>[trimmed.substring(0, space), trimmed.substring(space + 1)];
  }

  /// Splits on the commas that are not inside parentheses.
  List<String> _splitTopLevel(String body) {
    final List<String> parts = <String>[];
    int depth = 0;
    int start = 0;

    for (int i = 0; i < body.length; i++) {
      final String char = body[i];

      if (char == '(') {
        depth++;
      } else if (char == ')') {
        depth--;
      } else if (char == ',' && depth == 0) {
        parts.add(body.substring(start, i).trim());
        start = i + 1;
      }
    }

    parts.add(body.substring(start).trim());

    return parts;
  }
}
