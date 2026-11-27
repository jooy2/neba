import 'package:flutter_test/flutter_test.dart';
import 'package:neba/src/internal/search.dart';

void main() {
  test('folds the accents of Latin, Greek and Cyrillic letters', () {
    expect(nebaFold('José Ñandú'), 'Jose Nandu');
    expect(nebaFold('Ελλάδα'), 'Ελλαδα');
    expect(nebaFold('ёлка'), 'елка');
    expect(nebaFold('Café'), 'Cafe');
  });

  test('leaves what it has no fold for as it is written', () {
    expect(nebaFold('한국어 ø ł'), '한국어 ø ł');
    expect(nebaFold('plain ASCII'), 'plain ASCII');
  });

  test('says where each folded unit came from', () {
    expect(nebaFoldText('plain'), isNull);

    final NebaFoldedText folded = nebaFoldText('aéb')!;
    expect(folded.text, 'aeb');
    expect(folded.starts, <int>[0, 1, 3]);
    // The combining mark belongs to the `e` before it.
    expect(folded.ends, <int>[1, 3, 4]);
  });

  test('lower-cases a value to match against, and ignores what is not text', () {
    expect(nebaSearchText('SÉOUL'), 'seoul');
    expect(nebaSearchText(42), '42');
    expect(nebaSearchText(null), '');
    expect(nebaSearchText(<String>['a']), '');
  });
}
