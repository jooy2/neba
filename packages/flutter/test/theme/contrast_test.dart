// The contrast the design language promises, checked on the tokens in both
// themes: the ink on every solid fill in every state at 4.5:1, every focus
// ring at 3:1 against the page, and muted text at 4.5:1 on the page and on
// the sheets it is set on, and the same with the translucency taken away for
// a reader who asked for less. The React package checks the first two in
// `test/styles/fill-contrast.test.ts` and `focus-ring.test.tsx`.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/color.dart';

/// [top] laid over the opaque [bottom], as a translucent colour is drawn.
Color _over(Color top, Color bottom) {
  final double a = top.a;

  return Color.from(
    alpha: 1,
    red: top.r * a + bottom.r * (1 - a),
    green: top.g * a + bottom.g * (1 - a),
    blue: top.b * a + bottom.b * (1 - a),
  );
}

void main() {
  final Map<String, NebaTokens> themes = <String, NebaTokens>{
    'light': NebaTokens.light(),
    'dark': NebaTokens.dark(),
    'light, less transparent': NebaTokens.light().withReducedTransparency(),
    'dark, less transparent': NebaTokens.dark().withReducedTransparency(),
  };

  for (final MapEntry<String, NebaTokens> theme in themes.entries) {
    final NebaTokens tokens = theme.value;
    final Color page = tokens.surface;

    group('the ${theme.key} theme', () {
      for (final NebaColor color in NebaColor.values) {
        final NebaColorRoles roles = tokens.roles(color);

        test('writes ${color.name} ink on its solid fill at 4.5:1 in every state', () {
          for (final (String state, Color fill) in <(String, Color)>[
            ('rest', roles.fill),
            ('hover', roles.fillHover),
            ('active', roles.fillActive),
          ]) {
            final Color laid = _over(fill, page);

            expect(
              contrastRatio(_over(roles.onSolid, laid), laid),
              greaterThanOrEqualTo(4.5),
              reason: '${color.name} $state',
            );
          }
        });

        test('draws the ${color.name} focus ring at 3:1 against the page', () {
          expect(contrastRatio(_over(roles.ring, page), page), greaterThanOrEqualTo(3));
        });
      }

      test('sets muted text at 4.5:1 on the page and on the sheets it sits on', () {
        for (final (String sheet, Color under) in <(String, Color)>[
          ('page', page),
          ('panel', _over(tokens.panel, page)),
          ('pressed panel', _over(tokens.panelPress, page)),
        ]) {
          expect(
            contrastRatio(_over(tokens.mutedFg, under), under),
            greaterThanOrEqualTo(4.5),
            reason: sheet,
          );
        }
      });
    });
  }
}
