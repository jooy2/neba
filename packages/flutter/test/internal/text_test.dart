// The cut of a text into characters and words, which the text effects share:
// the React package's portable cut in `internal/text.ts`, case for case.

import 'package:flutter_test/flutter_test.dart';
import 'package:neba/src/internal/text.dart';

void main() {
  group('nebaGraphemesOf', () {
    test('counts what a reader counts as one character as one', () {
      expect(nebaGraphemesOf('ok'), <String>['o', 'k']);
      // A family is five code points; a flag is two regional indicators.
      expect(nebaGraphemesOf('👩\u200D👩\u200D👧 🇰🇷'), <String>[
        '👩\u200D👩\u200D👧',
        ' ',
        '🇰🇷',
      ]);
      // An accent typed after its letter, and a waving hand with a skin tone.
      expect(nebaGraphemesOf('e\u0301👋🏽'), <String>['e\u0301', '👋🏽']);
    });

    test('keeps a Hangul syllable whole, typed as one or as its jamo', () {
      expect(nebaGraphemesOf('한글'), <String>['한', '글']);
      expect(nebaGraphemesOf('\u1112\u1161\u11AB'), <String>['\u1112\u1161\u11AB']);
    });

    test('stacks a consonant after a virama onto the one before it', () {
      expect(nebaGraphemesOf('नमस\u094Dत\u0947'), <String>['न', 'म', 'स\u094Dत\u0947']);
    });

    test('keeps a carriage return and a line feed together', () {
      expect(nebaGraphemesOf('a\r\nb'), <String>['a', '\r\n', 'b']);
    });

    test('cuts nothing out of nothing', () {
      expect(nebaGraphemesOf(''), isEmpty);
    });
  });

  group('nebaWordsOf', () {
    test('cuts at spaces, each word keeping the space after it', () {
      expect(nebaWordsOf('One two three'), <String>['One ', 'two ', 'three']);
    });

    test('keeps punctuation with the word in front of it', () {
      expect(nebaWordsOf('Wait, what?'), <String>['Wait, ', 'what?']);
    });

    test('keeps a contraction and a number one word', () {
      expect(nebaWordsOf("don't 1,234.5 e.g"), <String>["don't ", '1,234.5 ', 'e.', 'g']);
    });

    test('makes what comes before the first word a piece of its own', () {
      expect(nebaWordsOf('  hello'), <String>['  ', 'hello']);
    });

    test('makes each character of a script written without spaces a piece', () {
      expect(nebaWordsOf('東京へ行く'), <String>['東', '京', 'へ', '行', 'く']);
      expect(nebaWordsOf('안녕 세계'), <String>['안녕 ', '세계']);
    });
  });

  test('nebaStandsAlone tells a script written without spaces from one with them', () {
    expect(nebaStandsAlone('漢'), isTrue);
    expect(nebaStandsAlone('ก'), isTrue);
    expect(nebaStandsAlone('한'), isFalse);
    expect(nebaStandsAlone('a'), isFalse);
    expect(nebaStandsAlone('。'), isFalse);
  });
}
