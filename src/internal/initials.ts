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

/**
 * The first character of the first word, plus the first of the last.
 *
 * `Array.from` rather than `[0]`, so a name that starts with an emoji or with
 * any character outside the basic plane is not cut in half between its two code
 * units. `normalize('NFC')` first, so a name whose accents arrived decomposed —
 * which is what a macOS filename and a good many APIs hand you — yields `Ä`
 * rather than a bare `A`.
 *
 * One word gives one character on purpose. Korean, Japanese and Chinese names
 * are a single token, and two of their characters at 32px is a smudge where one
 * is a name.
 */
export function initialsOf(name: string): string {
  const words = name.normalize('NFC').trim().split(/\s+/).filter(Boolean);

  if (words.length === 0) {
    return '';
  }

  const first = Array.from(words[0])[0] ?? '';
  const last = words.length > 1 ? (Array.from(words[words.length - 1])[0] ?? '') : '';

  return (first + last).toLocaleUpperCase();
}
