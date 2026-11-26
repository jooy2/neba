// The shared glyphs: every one reads, fits its box, and takes the ambient
// colour.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/svg_path.dart';

import '../support/host.dart';

void main() {
  final Map<String, List<NebaGlyphPart>> all = <String, List<NebaGlyphPart>>{
    'close': NebaGlyphs.close,
    'chevron': NebaGlyphs.chevron,
    'check': NebaGlyphs.check,
    'minus': NebaGlyphs.minus,
    'plus': NebaGlyphs.plus,
    'dot': NebaGlyphs.dot,
    'spinner': NebaGlyphs.spinner,
    'note': NebaGlyphs.note,
    'success': NebaGlyphs.success,
    'warning': NebaGlyphs.warning,
    'danger': NebaGlyphs.danger,
  };

  for (final MapEntry<String, List<NebaGlyphPart>> glyph in all.entries) {
    test('${glyph.key} stays inside its 16-unit box', () {
      for (final NebaGlyphPart part in glyph.value) {
        final Rect bounds = parseSvgPath(part.data).getBounds();

        expect(bounds.left, greaterThanOrEqualTo(0));
        expect(bounds.top, greaterThanOrEqualTo(0));
        expect(bounds.right, lessThanOrEqualTo(16));
        expect(bounds.bottom, lessThanOrEqualTo(16));
      }
    });
  }

  test('a family says its severity in a shape, and only three families have one', () {
    expect(NebaGlyphs.severity(NebaColor.success), same(NebaGlyphs.success));
    expect(NebaGlyphs.severity(NebaColor.warning), same(NebaGlyphs.warning));
    expect(NebaGlyphs.severity(NebaColor.danger), same(NebaGlyphs.danger));

    for (final NebaColor color in <NebaColor>[
      NebaColor.primary,
      NebaColor.secondary,
      NebaColor.info,
    ]) {
      expect(NebaGlyphs.severity(color), same(NebaGlyphs.note));
    }
  });

  testWidgets('takes the ambient icon size', (WidgetTester tester) async {
    await tester.pumpWidget(
      host(
        const IconTheme(
          data: IconThemeData(size: 20, color: Color(0xFF123456)),
          child: Center(child: NebaGlyph(<NebaGlyphPart>[NebaGlyphPart.stroke('M4 4h8')])),
        ),
      ),
    );

    expect(tester.getSize(find.byType(NebaGlyph)), const Size(20, 20));
  });
}
