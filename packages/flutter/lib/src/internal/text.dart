/// Cutting a text the way a reader would cut it: into characters, and into
/// words. The React package's `src/internal/text.ts`, which three effects
/// read, so that they never disagree about where a character ends.
///
/// Dart's SDK has no grapheme segmenter: a `String` is UTF-16 code units, its
/// `runes` are code points, and `String.characters` comes from
/// `package:characters`, which the package does not depend on. The engine's
/// ICU is reachable only through a laid-out paragraph, which would tie the cut
/// to a text style and a layout pass. So the cut here is the React package's
/// portable one, a regular expression over Unicode properties that every Dart
/// runtime and every browser reads the same way: what React itself draws
/// before a page hydrates, and on a runtime without `Intl.Segmenter`. Where it
/// differs from a segmenter it cuts finer, never coarser.
///
/// The library talking to itself: nothing here is exported.
library;

/// One character as a regular expression finds it, which is close to what a
/// grapheme segmenter finds and the same on every runtime: a base followed by
/// everything that cannot stand on its own (combining marks and spacing
/// vowels, emoji modifiers and variation selectors, a zero-width joiner and
/// the pictograph it joins, and the consonant after a virama in the scripts
/// that stack one onto the next). Two regional indicators are one flag, a run
/// of Hangul jamo is one syllable, and `\r\n` is one line break.
final RegExp _cluster = RegExp(
  // The analyzer's check does not know the emoji properties `EMod` and
  // `ExtPict`, which the Dart VM and every browser read.
  // ignore: valid_regexps
  r'\r\n|\p{RI}\p{RI}|[\u1100-\u115F\uA960-\uA97C]*(?:[\uAC00-\uD7A3]|[\u1160-\u11A7\uD7B0-\uD7C6])'
  r'[\u1160-\u11A7\uD7B0-\uD7C6]*[\u11A8-\u11FF\uD7CB-\uD7FB]*|[\u1100-\u115F\uA960-\uA97C]+|'
  r'[\s\S](?:[\u094D\u09CD\u0ACD\u0B4D\u0C4D\u0D4D\u17D2]\p{L}|[\p{Gr_Ext}\p{EMod}\p{Mc}\u0E33\u0EB3]|'
  r'\u200D\p{ExtPict}|\u200D)*',
  unicode: true,
);

/// [text] split into characters the way a reader would count them: a `한`
/// typed as three jamo is one, and so is a family emoji of five code points.
List<String> nebaGraphemesOf(String text) {
  return <String>[for (final RegExpMatch match in _cluster.allMatches(text)) match[0]!];
}

final RegExp _alone = RegExp(
  r'^(?=\p{L})[\p{scx=Han}\p{scx=Hiragana}\p{scx=Katakana}\p{scx=Thai}\p{scx=Lao}'
  r'\p{scx=Khmer}\p{scx=Myanmar}]',
  unicode: true,
);

/// Whether [grapheme] belongs to a script written without spaces, where a run
/// of letters is not one word and a line may break inside it: each one is a
/// piece of its own, which is never coarser than a segmenter's word.
bool nebaStandsAlone(String grapheme) => _alone.hasMatch(grapheme);

final RegExp _letter = RegExp(r'^[\p{Alphabetic}\p{Pc}]', unicode: true);
final RegExp _digit = RegExp(r'^\p{Nd}', unicode: true);

// What keeps `don't` one word and `1,234.5` one number: only the joins every
// engine makes, so a full stop between letters is a cut.
final RegExp _betweenLetters = RegExp('^[\'’]\$', unicode: true);
final RegExp _betweenDigits = RegExp('^[.\',;’]\$', unicode: true);

enum _Kind { alone, letter, digit, other }

_Kind _kindOf(String cluster) {
  if (nebaStandsAlone(cluster)) {
    return _Kind.alone;
  }

  if (_letter.hasMatch(cluster)) {
    return _Kind.letter;
  }

  if (_digit.hasMatch(cluster)) {
    return _Kind.digit;
  }

  return _Kind.other;
}

/// [text] split into words, each keeping the punctuation and the space that
/// follow it, so a line still breaks between the pieces and never inside a
/// gap, and a piece is never a lone comma. What comes before the first word is
/// a piece of its own, and each character of a script written without spaces
/// is one.
List<String> nebaWordsOf(String text) {
  final List<String> clusters = nebaGraphemesOf(text);
  final List<_Kind> kinds = <_Kind>[for (final String cluster in clusters) _kindOf(cluster)];
  final List<String> pieces = <String>[];
  bool inWord = false;

  for (int index = 0; index < clusters.length; index++) {
    final String cluster = clusters[index];
    final _Kind kind = kinds[index];
    final _Kind? before = index > 0 ? kinds[index - 1] : null;
    final _Kind? after = index + 1 < clusters.length ? kinds[index + 1] : null;
    final bool joins =
        kind == _Kind.other &&
        before == after &&
        ((before == _Kind.letter && _betweenLetters.hasMatch(cluster)) ||
            (before == _Kind.digit && _betweenDigits.hasMatch(cluster)));
    final bool inside = kind == _Kind.letter || kind == _Kind.digit || joins;

    if (pieces.isEmpty || kind == _Kind.alone || (inside && !inWord)) {
      pieces.add(cluster);
    } else {
      pieces[pieces.length - 1] += cluster;
    }

    inWord = inside;
  }

  return pieces;
}
