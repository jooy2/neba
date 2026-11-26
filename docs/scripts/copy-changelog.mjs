/**
 * Puts both packages' changelogs on the docs site, as one page.
 *
 * Each changelog lives beside its package, in `packages/react/` and
 * `packages/flutter/`, where a reader browsing the repository, npm and pub.dev
 * already expect to find it. Keeping a second copy under `docs/` would be two
 * files that say the same thing until the day one of them does not, so the
 * docs' copy is generated instead — written before VitePress starts and
 * ignored by git.
 *
 * Each package's history goes into a `::: fw` block of its own, so the page
 * shows the changelog of the framework the reader chose. The React history
 * comes first, which keeps every anchor it had before the Flutter one joined
 * it: VitePress numbers a repeated heading's id in order, so the Flutter
 * history's `#added` is the one that becomes `#added-1`.
 *
 * Three things are added. The frontmatter, because the sidebar reads `title`
 * for the label and `order` for where it sits and the source file cannot carry
 * either without npm and GitHub rendering it as a stray table at the top; the
 * page's own heading; and a `v-pre` on the inline code spans that contain a
 * `{{`.
 */
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

/** This site's folder, `docs/`. */
const site = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const repository = resolve(site, '..');

/** One entry per locale served by the docs. Keep in step with `supportLocales`. */
const titles = {
  en: 'Changelog',
  ko: '변경 기록'
};

/**
 * Marks the inline code spans Vue would otherwise read as an interpolation.
 *
 * VitePress compiles Markdown to Vue, and `{{ … }}` is an expression there. A
 * fenced block is already `v-pre` by the time it gets that far; an inline span
 * is not, so a changelog entry quoting a responsive prop — `columnSpacing={{ md:
 * 6 }}` is the one that did it — takes the whole site's build down with a Vue
 * syntax error pointing at a line of a generated file, which reads as anything
 * but "a backtick in the changelog".
 *
 * Done on the copy rather than in `CHANGELOG.md`, which npm and GitHub also read
 * and which stays plain Markdown for that reason. `<code>` is what markdown-it
 * would have emitted anyway, so nothing about the rendering changes.
 */
function guardInterpolation(markdown) {
  const escape = (text) => text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

  let fenced = false;

  return markdown
    .split('\n')
    .map((line) => {
      if (/^\s*(```|~~~)/.test(line)) {
        fenced = !fenced;
        return line;
      }

      if (fenced || !line.includes('{{')) return line;

      return line.replace(
        /`([^`\n]*\{\{[^`\n]*)`/g,
        (_, code) => `<code v-pre>${escape(code)}</code>`
      );
    })
    .join('\n');
}

/**
 * A changelog's releases, from its first `## ` heading to the end: the file's
 * own `#` heading and the note under it belong to the file, and the page has
 * a heading of its own.
 */
function historyOf(path) {
  const text = readFileSync(resolve(repository, path), 'utf8');
  const start = text.search(/^## /m);

  return guardInterpolation(start === -1 ? '' : text.slice(start)).trim();
}

const histories = [
  ['react', historyOf('packages/react/CHANGELOG.md')],
  ['flutter', historyOf('packages/flutter/CHANGELOG.md')]
];
const body = histories
  .map(([framework, history]) => `::: fw ${framework}\n\n${history}\n\n:::`)
  .join('\n\n');

for (const [locale, title] of Object.entries(titles)) {
  const target = resolve(site, locale, 'changelog.md');
  mkdirSync(dirname(target), { recursive: true });
  writeFileSync(
    target,
    `---\ntitle: ${title}\norder: 1\neditLink: false\n---\n\n# ${title}\n\n${body}\n`,
    'utf8'
  );
}
