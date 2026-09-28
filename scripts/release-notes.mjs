/**
 * The body of a GitHub release, cut out of `CHANGELOG.md`.
 *
 *   node scripts/release-notes.mjs 1.17.0 > notes.md
 *
 * The version's own section is the body, whole, from the line under its
 * heading to the next `## `, with a pointer to the full history under it. A
 * release is refused rather than written from a section that is not ready: one
 * still called `vNext`, one with no date, or one that is empty.
 *
 * GitHub cuts a release body off at 125,000 characters, and a cut body ends in
 * the middle of an entry. So when the section will not fit, the body is as
 * much of it as fits, from the top, in whole pieces: the summary the section
 * opens with, then each `### ` heading and the entries under it, one entry at
 * a time. The first piece that does not fit ends it, and the pointer says the
 * rest is in the changelog. `release.yml` is what calls this; it is a script
 * of its own so the body can be read before a tag is pushed.
 */
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const LIMIT = 125000;

/**
 * Counted in UTF-8 bytes rather than in characters: a changelog is full of em
 * dashes and arrows, and bytes are the stricter of the two ways the limit
 * could be counted.
 */
const size = (text) => Buffer.byteLength(text, 'utf8');

const version = (process.argv[2] ?? '').replace(/^v/, '');

if (!/^\d+\.\d+\.\d+(-[0-9A-Za-z.-]+)?$/.test(version)) {
  throw new Error(`release-notes: "${process.argv[2] ?? ''}" is not a version such as 1.17.0`);
}

const changelog = readFileSync(resolve(root, 'CHANGELOG.md'), 'utf8');
const pkg = JSON.parse(readFileSync(resolve(root, 'package.json'), 'utf8'));
const lines = changelog.split('\n');
const escaped = version.replace(/[.+-]/g, (char) => `\\${char}`);
const start = lines.findIndex((line) => new RegExp(`^## ${escaped}( |$)`).test(line));

if (start === -1) {
  throw new Error(`release-notes: CHANGELOG.md has no "## ${version}" section`);
}

if (!/^## \S+ \(\d{4}-\d{2}-\d{2}\)$/.test(lines[start])) {
  throw new Error(
    `release-notes: "${lines[start]}" is not dated as "## ${version} (YYYY-MM-DD)" — cut the release first`
  );
}

const next = lines.findIndex((line, index) => index > start && /^## /.test(line));
const section = lines
  .slice(start + 1, next === -1 ? undefined : next)
  .join('\n')
  .trim();

if (section === '') {
  throw new Error(`release-notes: the ${version} section is empty`);
}

const repository = (typeof pkg.repository === 'string' ? pkg.repository : pkg.repository?.url)
  ?.replace(/^git\+/, '')
  .replace(/\.git$/, '');
const where = [
  pkg.homepage
    ? `[the changelog on the docs site](${pkg.homepage.replace(/\/$/, '')}/changelog)`
    : null,
  repository ? `[\`CHANGELOG.md\` at this tag](${repository}/blob/v${version}/CHANGELOG.md)` : null
].filter(Boolean);
const pointer = where.length > 0 ? `Every release is in ${where.join(' and in ')}.` : '';

const whole = pointer ? `${section}\n\n---\n\n${pointer}\n` : `${section}\n`;

if (size(whole) <= LIMIT) {
  process.stdout.write(whole);
} else {
  const more = `This release has more changes than fit on a release page; the rest are in ${
    where.length > 0 ? where.join(' and in ') : '`CHANGELOG.md`'
  }.`;
  // Room for the rule and the pointer, so the pieces are counted against what
  // is really left.
  const room = LIMIT - size(more) - 16;

  // The summary is one piece, and so is every entry: a list item runs from its
  // `- ` to the next one, and a paragraph or a table under a heading is a piece
  // of its own. A heading travels with the first piece after it, so a heading
  // is never left standing over nothing.
  const pieces = [];

  for (const block of section.split(/\n(?=### )/)) {
    const [head, ...rest] = block.startsWith('### ')
      ? block.split('\n')
      : [null, ...block.split('\n')];
    const units = rest
      .join('\n')
      .trim()
      .split(/\n(?=- )|\n\n(?=[^\s-])/)
      .map((unit) => unit.trim())
      .filter(Boolean);

    units.forEach((unit, index) => {
      pieces.push(index === 0 && head ? `${head}\n\n${unit}` : unit);
    });
  }

  let body = '';

  for (const piece of pieces) {
    const next = body ? `${body}\n\n${piece}` : piece;

    if (size(next) > room) break;
    body = next;
  }

  process.stdout.write(body ? `${body}\n\n---\n\n${more}\n` : `${more}\n`);
}
