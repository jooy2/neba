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
 * the middle of an entry. So when the section will not fit, the body is the
 * summary the section opens with — everything before its first `### ` — and
 * the pointer says where the rest is. `release.yml` is what calls this; it is
 * a script of its own so the body can be read before a tag is pushed.
 */
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const LIMIT = 125000;

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

if (whole.length <= LIMIT) {
  process.stdout.write(whole);
} else {
  // Only prose that comes before the first heading is a summary; a section
  // that opens straight on `### Added` has none, and its first list is not one.
  const summary = section.startsWith('### ') ? '' : section.split(/\n(?=### )/)[0].trim();
  const cut = `The list of changes is too long for a release page; ${
    where.length > 0 ? `read it in ${where.join(' or in ')}` : 'read it in `CHANGELOG.md`'
  }.`;

  process.stdout.write(summary ? `${summary}\n\n---\n\n${cut}\n` : `${cut}\n`);
}
