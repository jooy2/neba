import 'package:flutter_test/flutter_test.dart';
import 'package:neba/src/internal/csv.dart';

void main() {
  test('quotes a field only when it holds the separator, a quote or a line break', () {
    expect(nebaCsvField('plain'), 'plain');
    expect(nebaCsvField('a,b'), '"a,b"');
    expect(nebaCsvField('say "hi"'), '"say ""hi"""');
    expect(nebaCsvField('two\nlines'), '"two\nlines"');
    expect(nebaCsvField('a;b', separator: ';'), '"a;b"');
  });

  test('writes nothing for null, a date as an instant and a map as JSON', () {
    expect(nebaCsvField(null), '');
    expect(nebaCsvField(DateTime.utc(2026, 1, 5, 10)), '2026-01-05T10:00:00.000Z');
    expect(nebaCsvField(<String, int>{'a': 1}), '"{""a"":1}"');
    expect(nebaCsvField(42), '42');
  });

  test('keeps a text a spreadsheet would run from running, and leaves numbers alone', () {
    expect(nebaCsvField('=SUM(A1)'), "'=SUM(A1)");
    expect(nebaCsvField('+1'), "'+1");
    expect(nebaCsvField('@user'), "'@user");
    expect(nebaCsvField(-3), '-3');
    expect(nebaCsvField('=SUM(A1)', escapeFormulas: false), '=SUM(A1)');
  });

  test('writes rows with CRLF and a byte-order mark', () {
    final String csv = nebaToCsv(<List<Object?>>[
      <Object?>['Name', 'Size'],
      <Object?>['react', 132],
    ]);

    expect(csv, '\uFEFFName,Size\r\nreact,132');
    expect(
      nebaToCsv(<List<Object?>>[
        <Object?>['a'],
      ], bom: false),
      'a',
    );
  });
}
