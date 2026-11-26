/**
 * The letters that stand in for a picture that is not there.
 *
 * One function, in `internal/` for the reason `button-group.ts` is: two
 * components draw it — an [Avatar] with no photograph and an [AppLogo] with no
 * artwork — and neither should have to import the other to say what "the first
 * letter of a name" means. It is a rule about names rather than about pictures,
 * and a library with two of them would spell the same person's initials two
 * ways on the same page.
 */

import { graphemesOf } from './text.js';

/**
 * The first character of the first word, plus the first of the last.
 *
 * A grapheme rather than `[0]` or a code point, so a name that starts with an
 * emoji is not cut apart: `👩‍💻` is three code points and `🇰🇷` is two, and
 * taking the first of them drew `👩` and a lone `🇰`. `normalize('NFC')` first, so a name whose accents arrived decomposed —
 * which is what a macOS filename and a good many APIs hand you — yields `Ä`
 * rather than a bare `A`.
 *
 * One word gives one character on purpose. Korean, Japanese and Chinese names
 * are a single token, and two of their characters at 32px is a smudge where one
 * is a name.
 *
 * `toUpperCase()` rather than `toLocaleUpperCase()`, which with no argument
 * takes the runtime's language: a server in one locale and a browser in Turkish
 * would draw `I` and `İ` for the same name, and React reports the difference as
 * a hydration mismatch.
 */
export function initialsOf(name: string): string {
  const words = name.normalize('NFC').trim().split(/\s+/).filter(Boolean);

  if (words.length === 0) {
    return '';
  }

  const first = graphemesOf(words[0])[0] ?? '';
  const last = words.length > 1 ? (graphemesOf(words[words.length - 1])[0] ?? '') : '';

  return (first + last).toUpperCase();
}
