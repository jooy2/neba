import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { withSidebar } from 'vitepress-sidebar';
import packageJson from '../../packages/react/package.json' with { type: 'json' };
import { defineConfig, HeadConfig, SiteData, TransformContext, UserConfig } from 'vitepress';
import { withI18n } from 'vitepress-i18n';
import ReactPlugin from '@vitejs/plugin-react';
import container from 'markdown-it-container';
import type { VitePressI18nOptions } from 'vitepress-i18n/types';
import type { VitePressSidebarOptions } from 'vitepress-sidebar/types';
import { DEFAULT_FRAMEWORK, FRAMEWORK_HEAD_SCRIPT, FRAMEWORK_IDS } from './data/frameworks';

const vitePressDir = dirname(fileURLToPath(import.meta.url));
const rootDir = resolve(vitePressDir, '../..');
const srcDir = resolve(rootDir, 'docs');
/** The React package, whose source the previews render. */
const reactDir = resolve(rootDir, 'packages/react');

const defaultLocale: string = 'en';
const supportLocales: string[] = [defaultLocale, 'ko'];
const siteUrl = packageJson.homepage.replace(/\/+$/, '');
// `repository.url` is in the form npm writes, `git+https://….git`, which is an
// address for git and not a page; `.github/scripts/release-notes.mjs` strips it alike.
const repoUrl = packageJson.repository.url.replace(/^git\+/, '').replace(/\.git$/, '');
const editLinkPattern = `${repoUrl}/edit/main/docs/:path`;
const npmUrl = `https://www.npmjs.com/package/${packageJson.name}`;

/** The card image. A square mark, which is why the Twitter card is `summary`. */
const socialImage = `${siteUrl}/256x256.png`;

/** A glob Vite can read on either platform — `resolve` gives Windows backslashes. */
const glob = (pattern: string) => resolve(rootDir, pattern).replaceAll('\\', '/');

/**
 * Every third-party subpath the library reaches for, read out of `src/`.
 *
 * These are reached only from a demo, which is reached only from a dynamic
 * import — so the dev server discovers them one at a time as previews mount,
 * and each discovery re-runs the dependency optimizer and reloads the page
 * underneath whoever is reading it. Listing them up front makes that one
 * pre-bundle at startup instead. Derived rather than written out, so a
 * component that starts using a new primitive is not a second edit here.
 *
 * The `highlight.js` half is worse than the Base UI half rather than merely the
 * same: CodeBlock imports its grammars with `import()` *at render time*, so an
 * undeclared one is discovered while somebody is reading the page it colours.
 */
function vendorEntries(): string[] {
  const srcDir = resolve(reactDir, 'src');
  const entries = new Set<string>();
  const pattern = /'(@base-ui\/react\/[a-z-]+|highlight\.js\/lib\/(?:core|languages\/[\w.+-]+))'/g;

  for (const file of readdirSync(srcDir, { recursive: true, encoding: 'utf8' })) {
    if (!/\.tsx?$/.test(file)) {
      continue;
    }

    for (const [, entry] of readFileSync(resolve(srcDir, file), 'utf8').matchAll(pattern)) {
      entries.add(entry);
    }
  }

  return [...entries].sort();
}

/** `/` for whichever locale is the default, `/{lang}/` for every other one. */
const localeBase = (lang: string) => (lang === defaultLocale ? '/' : `/${lang}/`);

const commonSidebarConfig: VitePressSidebarOptions = {
  collapsed: false,
  capitalizeFirst: true,
  useTitleFromFileHeading: true,
  useTitleFromFrontmatter: true,
  useFolderTitleFromIndexFile: true,
  // Without this the components group stops linking to the index page that
  // lists them all. `examples/` deliberately has no `index.md`, so it stays a
  // heading with its pages under it — see `groupLabels`.
  useFolderLinkFromIndexFile: true,
  frontmatterOrderDefaultValue: 9,
  sortMenusByFrontmatterOrder: true
};

/**
 * The sidebar groups the folder tree cannot name.
 *
 * `design/` and `examples/` have no `index.md`, and the changelog and the
 * browser support page are loose pages, so none of them can take its heading
 * from a page the way every other group does. Left to the generator, `design/`
 * would be capitalised to "Design" over Korean pages and the loose pages would
 * sit at the root with no heading over them at all.
 *
 * `examples/` has no index on purpose: `/examples/` is not a page, it is four
 * of them — one screen each — and an index that only listed the four would be a
 * row of links standing where the heading already is.
 */
const groupLabels: Record<
  string,
  { overview: string; examples: string; design: string; more: string }
> = {
  en: {
    overview: 'All components',
    examples: 'Examples',
    design: 'Design',
    more: 'Discover more'
  },
  ko: { overview: '모든 컴포넌트', examples: '예제', design: '디자인', more: '더 알아보기' }
};

const vitePressSidebarConfig = [
  ...supportLocales.map((lang) => {
    return {
      ...commonSidebarConfig,
      // Resolved from the working directory, which is this site's folder: the
      // site is its own npm project and every script runs from `docs/`.
      documentRootPath: `/${lang}`,
      resolvePath: localeBase(lang),
      ...(defaultLocale === lang ? {} : { basePath: localeBase(lang) })
    };
  })
];

/** The same three destinations in every locale, prefixed with its base. */
const navFor = (lang: string, labels: [string, string, string]) => [
  { text: labels[0], link: `${localeBase(lang)}guide/getting-started` },
  { text: labels[1], link: `${localeBase(lang)}components/` },
  // `/examples/` is a group heading rather than a page, so the nav points at
  // the one page inside it that shows everything at once.
  { text: labels[2], link: `${localeBase(lang)}examples/overview` }
];

const vitePressI18nConfig: VitePressI18nOptions = {
  locales: supportLocales,
  rootLocale: defaultLocale,
  searchProvider: 'local',
  description: {
    ko: '버튼, 입력란, 메뉴, 대화상자, 테이블 등 다양한 요소를 아우르는 포괄적인 React UI 컴포넌트 라이브러리입니다. 접근성이 뛰어나고 테마 적용이 가능하며, 하나의 prop 어휘와 반투명한 아크릴 디자인 언어를 공유합니다. ESM 전용이며, 타입 정의가 포함되어 있고 다크 모드가 기본으로 지원됩니다.',
    en: 'A comprehensive React UI component library — buttons, fields, menus, dialogs, tables and much more — accessible and themeable, sharing one prop vocabulary and a translucent acrylic design language. ESM only, types included, dark mode built in.'
  },
  themeConfig: {
    ko: { nav: navFor('ko', ['가이드', '컴포넌트', '예제']) },
    en: { nav: navFor('en', ['Guide', 'Components', 'Examples']) }
  }
};

/* ---------------------------------------------------------------------------
 * Search engines
 *
 * Two things a documentation site gets wrong by default, and both of them are
 * per page rather than per site:
 *
 * - **Every page ships the same description.** VitePress falls back to the
 *   site's own whenever a page declares none, so every page carries the same
 *   sentence and not one of them says what it is about. There is
 *   already a better sentence on nearly every page — the lede under the title,
 *   which is written to be exactly this — so it is read out of the source.
 * - **Nothing says the two locales are the same page.** Without `hreflang` a
 *   crawler has no reason to connect `/components/inputs/button` to its Korean
 *   counterpart, and treats them as two documents competing for one query.
 * ------------------------------------------------------------------------- */

/**
 * The BCP-47 tag the site itself declares for a locale — `en` → `en-US`.
 *
 * Read back off the resolved config rather than written out again, because
 * VitePress's own sitemap already emits `hreflang` from exactly these values.
 * Two spellings of the same locale across the two files is the one thing a
 * crawler reads as a contradiction, and a hand-kept copy would be the way to
 * get one.
 */
function langTagOf(siteData: SiteData, lang: string): string {
  return siteData.locales[lang === defaultLocale ? 'root' : lang]?.lang ?? lang;
}

/** `en/components/inputs/button.md` → `/components/inputs/button`. */
function pathOf(filePath: string): string {
  const [lang, ...rest] = filePath.split('/');
  const page = rest
    .join('/')
    .replace(/(^|\/)index\.md$/, '$1')
    .replace(/\.md$/, '');

  return `${localeBase(lang)}${page}`;
}

/** Everything below the locale folder — the part two locales have in common. */
function pageOf(filePath: string): string {
  return filePath.split('/').slice(1).join('/');
}

/** Inline Markdown and HTML dropped: a `<meta>` carries text and nothing else. */
function plainText(source: string): string {
  return source
    .replace(/<[^>]+>/g, ' ')
    .replace(/!\[[^\]]*]\([^)]*\)/g, ' ')
    .replace(/\[([^\]]*)]\([^)]*\)/g, '$1')
    .replace(/[`*_]/g, '')
    .replace(/\s+/g, ' ')
    .trim();
}

/** Cut at a word boundary, to about what a result page will show whole. */
function clamp(text: string, limit = 160): string {
  if (text.length <= limit) {
    return text;
  }

  const cut = text.slice(0, limit);

  return `${cut.slice(0, cut.lastIndexOf(' ')).trimEnd()}…`;
}

/**
 * A page's own one-line summary.
 *
 * The lede is what a component page opens with, and it already says what the
 * component is and what it is for in one or two sentences. The pages that have
 * none — the guide, the design notes — open with the same thing written as
 * prose, so their first paragraph stands in.
 */
function summaryOf(filePath: string): string | undefined {
  const file = resolve(srcDir, filePath);

  if (!existsSync(file)) {
    return undefined;
  }

  const source = readFileSync(file, 'utf8');
  const lede = source.match(/<p class="neba-lede">([\s\S]*?)<\/p>/);

  if (lede) {
    return clamp(plainText(lede[1]));
  }

  // Frontmatter off, then the first block that is prose: not the title, not a
  // fenced example, not one of the Vue components a page is built out of.
  for (const block of source.replace(/^---\r?\n[\s\S]*?\r?\n---/, '').split(/\n\s*\n/)) {
    const trimmed = block.trim();

    if (!trimmed || /^[#<`:|>-]/.test(trimmed)) {
      continue;
    }

    const text = plainText(trimmed);

    if (text) {
      return clamp(text);
    }
  }

  return undefined;
}

/** The locales that actually have this page — a mirror is not a guarantee. */
function localesWith(filePath: string): string[] {
  const page = pageOf(filePath);

  return supportLocales.filter((lang) => existsSync(resolve(srcDir, lang, page)));
}

/** What the package is, for the one page in each locale that is about it. */
function structuredData(description: string, url: string) {
  return {
    '@context': 'https://schema.org',
    '@type': 'SoftwareSourceCode',
    name: 'Neba',
    description,
    url,
    codeRepository: repoUrl,
    programmingLanguage: 'TypeScript',
    runtimePlatform: 'React',
    license: 'https://opensource.org/licenses/MIT',
    author: { '@type': 'Organization', name: 'CDGet', url: 'https://cdget.com' },
    sameAs: [repoUrl, npmUrl]
  };
}

/**
 * The half of the metadata that is different on every page.
 *
 * Only runs at build time — `transformPageData` is what the dev server sees —
 * so the tags below are checked by reading a built page, not the preview.
 */
function transformHead({ pageData, siteData, title, description }: TransformContext): HeadConfig[] {
  const { filePath } = pageData;

  // A dynamic route, or the built-in 404: no source file, so no canonical URL
  // and nothing to point an alternate at.
  if (!filePath) {
    return [];
  }

  const lang = filePath.split('/')[0];
  const url = `${siteUrl}${pathOf(filePath)}`;
  const translations = localesWith(filePath);

  // Open Graph writes a BCP-47 tag with an underscore in it, and nothing else.
  const ogLocale = (of: string) => langTagOf(siteData, of).replace('-', '_');

  const head: HeadConfig[] = [
    ['link', { rel: 'canonical', href: url }],
    ['meta', { property: 'og:url', content: url }],
    ['meta', { property: 'og:title', content: title }],
    ['meta', { property: 'og:description', content: description }],
    ['meta', { property: 'og:locale', content: ogLocale(lang) }],
    ['meta', { name: 'twitter:title', content: title }],
    ['meta', { name: 'twitter:description', content: description }]
  ];

  for (const other of translations) {
    head.push([
      'link',
      {
        rel: 'alternate',
        hreflang: langTagOf(siteData, other),
        href: `${siteUrl}${pathOf(`${other}/${pageOf(filePath)}`)}`
      }
    ]);

    if (other !== lang) {
      head.push(['meta', { property: 'og:locale:alternate', content: ogLocale(other) }]);
    }
  }

  // Which one a crawler should serve to a reader it cannot place. The default
  // locale is the one that is served from `/`.
  if (translations.includes(defaultLocale)) {
    head.push([
      'link',
      {
        rel: 'alternate',
        hreflang: 'x-default',
        href: `${siteUrl}${pathOf(`${defaultLocale}/${pageOf(filePath)}`)}`
      }
    ]);
  }

  if (pageData.frontmatter.layout === 'home') {
    head.push([
      'script',
      { type: 'application/ld+json' },
      JSON.stringify(structuredData(description, url))
    ]);
  }

  return head;
}

/* ---------------------------------------------------------------------------
 * The framework switch, in the Markdown
 * ------------------------------------------------------------------------- */

/**
 * The words a heading's `id` is made from.
 *
 * `markdown-it-anchor` reads a heading's plain text and inline code and
 * nothing else, so a heading written as an `<Fw>` phrase, which is inline
 * HTML, would get an empty `id`: a `#` link to the top of the page and no entry
 * in the outline. The default framework's variant is read in its place, so
 * `### <Fw react="onClick" flutter="onPressed" />` is `#onclick` whichever
 * framework the reader chose, and a link to it holds when they switch.
 */
const fwVariant = new RegExp(`<Fw\\b[^>]*\\b${DEFAULT_FRAMEWORK}="([^"]*)"`);

function headingText(tokens: { type: string; content: string }[]): string {
  return tokens
    .map((token) => {
      if (token.type === 'text' || token.type === 'code_inline') {
        return token.content;
      }

      return token.type === 'html_inline' ? (fwVariant.exec(token.content)?.[1] ?? '') : '';
    })
    .join('');
}

/**
 * `::: fw react` … `:::`, a block only one framework sees.
 *
 * Both frameworks' blocks are in the page and `theme/styles/framework.css`
 * displays one, which makes the switch instant and keeps the two halves one
 * page rather than two that drift apart. Both are in the search index too, so
 * a reader looking up `onPressed` finds the page whichever framework is on.
 *
 * `::: fw react flutter` is a block both see. An id the site does not know is
 * dropped rather than kept, so a typo hides the block from everyone instead of
 * showing it to everyone.
 */
type MarkdownRenderer = Parameters<NonNullable<NonNullable<UserConfig['markdown']>['config']>>[0];

function frameworkBlocks(md: MarkdownRenderer): void {
  md.use(container, 'fw', {
    validate: (params: string) => /^fw(\s+\S+)+$/.test(params.trim()),
    render(tokens: { nesting: number; info: string }[], index: number) {
      const token = tokens[index];

      if (token.nesting !== 1) {
        return '</div>\n';
      }

      const wanted = token.info
        .trim()
        .split(/\s+/)
        .slice(1)
        .filter((id) => FRAMEWORK_IDS.includes(id));

      return `<div class="neba-fw" data-fw="${wanted.join(' ')}">\n`;
    }
  });
}

/**
 * Every `:::` container that will not open or close where the page means it to.
 *
 * Three mistakes break a `::: fw` block without failing the build, and each
 * one swallows the rest of the page into one framework's half or leaves it
 * open:
 *
 * - **A container inside another with as many colons.**
 *   `markdown-it-container` closes the outer one at the inner one's closing
 *   fence, because it looks for the first fence long enough rather than the
 *   matching one. The outer block needs one more colon.
 * - **A fence on the same line as prose.** Prettier joins a fence to the
 *   paragraph it touches when no blank line separates them, and
 *   `text ::: fw react` is text.
 * - **A page whose containers do not balance**, which either of the two above
 *   leaves behind.
 *
 * Code fences are skipped, so a container shown as an example is not read as
 * one. The generated changelog is skipped as well.
 */
function misplacedContainers(): string[] {
  const found: string[] = [];
  const opener = /^(:{3,})\s*(\S.*)?$/;
  const names = 'fw|tip|warning|info|danger|details|v-pre';
  const gluedAfter = new RegExp(`\\S\\s+:{3,}\\s*(?:(?:${names})\\b.*)?$`);
  const gluedBefore = new RegExp(`^:{3,}\\s+(?!(?:${names})\\b)\\S`);

  const walk = (directory: string) => {
    for (const entry of readdirSync(directory, { withFileTypes: true })) {
      const path = resolve(directory, entry.name);

      if (entry.isDirectory()) {
        if (
          entry.name !== 'node_modules' &&
          entry.name !== 'public' &&
          !entry.name.startsWith('.')
        ) {
          walk(path);
        }

        continue;
      }

      if (!entry.name.endsWith('.md') || entry.name === 'changelog.md') {
        continue;
      }

      const where = path.slice(srcDir.length + 1);
      const open: { colons: number; line: number }[] = [];
      let fence: string | null = null;

      readFileSync(path, 'utf8')
        .split('\n')
        .forEach((line, index) => {
          const marker = /^\s{0,3}(`{3,}|~{3,})/.exec(line)?.[1]?.[0];

          if (marker) {
            fence = fence === null ? marker : fence === marker ? null : fence;
            return;
          }

          if (fence !== null) {
            return;
          }

          if (gluedAfter.test(line) || gluedBefore.test(line)) {
            found.push(`${where}:${index + 1}  a fence shares its line with prose`);
            return;
          }

          const match = opener.exec(line);

          if (!match) {
            return;
          }

          const colons = match[1].length;

          if (match[2]) {
            const outer = open.at(-1);

            if (outer && outer.colons <= colons) {
              found.push(
                `${where}:${index + 1}  opens inside the container from line ${outer.line} ` +
                  'with as many colons; give the outer one more'
              );
            }

            open.push({ colons, line: index + 1 });
          } else if (open.pop() === undefined) {
            found.push(`${where}:${index + 1}  closes a container that was never opened`);
          }
        });

      for (const left of open) {
        found.push(`${where}:${left.line}  opens a container that is never closed`);
      }
    }
  };

  walk(srcDir);

  return found;
}

// Ref: https://vitepress.dev/reference/site-config
const vitePressConfig: UserConfig = {
  title: 'Neba UI',
  lastUpdated: true,
  outDir: '../docs-dist',
  cleanUrls: true,
  metaChunk: true,
  /**
   * `public/` is copied to the site as it is, and it is not a folder of pages.
   * The note under `public/samples` that records where each picture came from
   * is Markdown, so without this it was built into a page of its own and listed
   * in the sitemap at `/public/samples/README`.
   */
  srcExclude: ['public/**'],
  /**
   * The default locale is served from `/`, not from `/{lang}/`.
   *
   * This has to agree with two other things or every sidebar link 404s:
   * `vitepress-i18n` puts the root locale in `locales.root` (no path prefix),
   * and `vitepress-sidebar` is told to resolve its links against `/`. The
   * rewrite is what actually moves `docs/{defaultLocale}/**` there. Every other
   * locale keeps its folder as its prefix — `docs/ko/guide/x.md` at
   * `/ko/guide/x`. Switching `defaultLocale` swings all three together.
   */
  rewrites: {
    [`${defaultLocale}/:rest*`]: ':rest*'
  },
  head: [
    // Before anything paints: which framework's half of every page is shown.
    ['script', {}, FRAMEWORK_HEAD_SCRIPT],
    ['link', { rel: 'icon', type: 'image/png', sizes: '32x32', href: '/logo-32.png' }],
    ['link', { rel: 'icon', type: 'image/png', sizes: '16x16', href: '/logo-16.png' }],
    ['link', { rel: 'icon', type: 'image/png', sizes: '256x256', href: '/256x256.png' }],
    ['link', { rel: 'apple-touch-icon', sizes: '180x180', href: '/256x256.png' }],
    ['link', { rel: 'shortcut icon', href: '/favicon.ico' }],
    // `--neba-primary-solid`, as a literal: a `<meta>` cannot read a custom
    // property, and this is the one place in the site that has to repeat one.
    ['meta', { name: 'theme-color', content: '#1a58d1' }],
    // The half of the metadata that is the same on every page. The other half —
    // the canonical URL, the title, the description, the locale alternates — is
    // per page and lives in `transformHead`.
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:site_name', content: 'Neba UI' }],
    ['meta', { property: 'og:image', content: socialImage }],
    ['meta', { property: 'og:image:width', content: '256' }],
    ['meta', { property: 'og:image:height', content: '256' }],
    ['meta', { property: 'og:image:alt', content: 'Neba' }],
    // `summary` and not `summary_large_image`: the image is a square mark, and
    // a wide card would letterbox it into a strip of background.
    ['meta', { name: 'twitter:card', content: 'summary' }],
    ['meta', { name: 'twitter:image', content: socialImage }]
  ],
  sitemap: {
    hostname: packageJson.homepage
  },
  markdown: {
    anchor: {
      /**
       * Heading ids a Korean link can be written against.
       *
       * VitePress slugs a heading through `NFKD` and drops the combining marks,
       * which is how `Café` becomes `cafe`. Hangul has no combining marks: `NFKD`
       * splits every syllable into its jamo and all of them survive, so `서버`
       * came out as five code points that look like `서버` and are not the two
       * anybody types. Every Korean `#anchor` written by hand in the Markdown
       * landed at the top of its page instead of at its heading, and neither the
       * link nor the id looked wrong.
       *
       * Composing the result puts the syllables back. `NFC` undoes only the
       * canonical half of `NFKD`, so the compatibility folding the slug relies on
       * stays, and an id with no Hangul in it is what it was: `Café` is still
       * `cafe`, because the accent was dropped before this runs. The rest is
       * VitePress's own slug, repeated because it is not exported (VitePress 1.6).
       */
      slugify: (text: string) =>
        text
          .normalize('NFKD')
          .replace(/[\u0300-\u036F]/g, '')
          .replace(/[\u0000-\u001f]/g, '')
          .replace(/[\s~`!@#$%^&*()\-_+=[\]{}|\\;:"'\u201c\u201d\u2018\u2019<>,.?/]+/g, '-')
          .replace(/-{2,}/g, '-')
          .replace(/^-+|-+$/g, '')
          .replace(/^(\d)/, '_$1')
          .toLowerCase()
          .normalize('NFC'),
      getTokensText: headingText
    },
    config(md) {
      frameworkBlocks(md);
    }
  },
  /**
   * `robots.txt`, written rather than committed.
   *
   * It exists to name the sitemap, and the sitemap's own URL is already derived
   * from `package.json`. A copy of that host sitting in `public/` would be one
   * more place to forget when the site moves — and a robots file pointing at a
   * sitemap that is not there is worse than no robots file.
   */
  async buildEnd({ outDir }) {
    const containers = misplacedContainers();

    if (containers.length > 0) {
      throw new Error(
        'These containers do not open or close where the page means them to, so one ' +
          "framework's half of the page swallows what follows it or never closes:\n" +
          containers.map((one) => `  ${one}`).join('\n')
      );
    }

    await writeFile(
      resolve(outDir, 'robots.txt'),
      `User-agent: *\nAllow: /\n\nSitemap: ${siteUrl}/sitemap.xml\n`
    );
  },
  /**
   * A description that is about this page rather than about the library.
   *
   * Runs in the dev server as well as in the build, which is what makes it the
   * right place for the description — `transformHead` would have to repeat the
   * fallback chain VitePress already applies to `pageData.description`, and
   * would only be right in a production build.
   */
  transformPageData(pageData) {
    if (!pageData.description && pageData.filePath) {
      pageData.description = summaryOf(pageData.filePath) ?? '';
    }
  },
  transformHead,
  /**
   * The docs render the real components, and the components are React. Every
   * live preview is a React island mounted by `theme/components/Demo.vue`, so
   * the site's Vite pipeline needs three things Vue alone does not give it: the
   * React plugin for the `.tsx` demos, an alias so those demos can `import
   * { Button } from 'neba'` exactly as a consumer would, and the repository's
   * PostCSS config so Tailwind compiles the classes the library ships.
   */
  vite: {
    // Cast because VitePress 1.x ships its own copy of Vite: its `Plugin` type
    // is a different instance of the same shape from the one the React plugin
    // is built against, so the two are structurally identical and nominally
    // incompatible. Drops when VitePress and the repo share one Vite.
    plugins: [ReactPlugin() as never],
    resolve: {
      alias: [
        // Anchored, so `neba/styles.css` is not rewritten into the barrel too.
        // Pointing at the source rather than `dist/` is what lets a component
        // edit show up in the docs without a rebuild.
        { find: /^neba$/, replacement: resolve(reactDir, 'src/index.ts') }
      ],
      // `packages/react` has a `node_modules` of its own, and a module the
      // library imports would otherwise resolve to that copy while a demo's
      // resolves to this site's: two Reacts on one page, and every hook throws.
      dedupe: ['react', 'react-dom', '@base-ui/react', 'highlight.js']
    },
    css: {
      // The site's own `postcss.config.mjs`, beside this folder.
      postcss: srcDir
    },
    optimizeDeps: {
      // Every one of these is only ever reached through a dynamic import inside
      // a demo, so Vite would otherwise discover them mid-session and force a
      // reload. `react/jsx-dev-runtime` is what the demos' JSX compiles to.
      include: [
        'react',
        'react-dom/client',
        'react/jsx-runtime',
        'react/jsx-dev-runtime',
        ...vendorEntries()
      ]
    },
    server: {
      // The previews import the library from `packages/react/src`, which is
      // outside this project's root.
      fs: { allow: [rootDir] },
      warmup: {
        // The library is behind a dynamic import too, so the dev server would
        // not transform a single file of it until the first preview asks — and
        // then it asks for all of it at once, through the barrel. The demos are
        // left out on purpose: a session touches a handful of them, whereas
        // `src/` is what every one of them pulls in.
        clientFiles: [glob('packages/react/src/**/*.{ts,tsx}')]
      }
    }
  },
  themeConfig: {
    logo: { src: '/logo-32.png', width: 24, height: 24 },
    /**
     * `h2` and `h3`, nested.
     *
     * A component page is one `h2` — Examples — with a dozen `h3`s under it,
     * one per prop. At the default depth the outline lists four words for a
     * page that is forty screens long, and the thing a reader came for, the
     * prop they are looking up, is never in it.
     *
     * Only `level` is set: `vitepress-i18n` puts the localised `label` on each
     * locale's own `themeConfig`, and its merge is deep, so the two survive
     * together.
     */
    outline: { level: [2, 3] },
    editLink: {
      pattern: editLinkPattern
    },
    socialLinks: [
      { icon: 'npm', link: 'https://www.npmjs.com/package/neba' },
      { icon: 'github', link: repoUrl }
    ],
    footer: {
      message: 'Released under the MIT License',
      copyright: '© <a href="https://cdget.com">CDGet</a>'
    }
  }
};

/* ---------------------------------------------------------------------------
 * Sidebar post-processing
 *
 * `vitepress-sidebar` derives the menu from the folder tree, which gets three
 * things wrong for this site — and none of the three can be fixed by moving
 * files around without also changing a URL. So the generated tree is reshaped
 * here instead, once, for every locale.
 * ------------------------------------------------------------------------- */

interface GeneratedSidebarItem {
  text?: string;
  link?: string;
  items?: GeneratedSidebarItem[];
  collapsed?: boolean;
}

/**
 * `useFolderLinkFromIndexFile` points a folder at `components/index.md`, which
 * VitePress resolves to `/components/index` — a URL that only works because the
 * SPA router is forgiving about it. The canonical one, and the only one a
 * static host serves directly, is `/components/`.
 *
 * `collapsed` goes at the same time: VitePress draws the expand/collapse caret
 * for any item where `collapsed != null`, so the only way to have permanently
 * open groups with no toggle is for the key to be absent entirely.
 */
function cleanUpItems<T extends GeneratedSidebarItem>(items: T[]): T[] {
  return items.map((item) => {
    const cleaned = {
      ...item,
      ...(item.link ? { link: item.link.replace(/(^|\/)index\.md$/, '$1') } : {}),
      ...(item.items ? { items: cleanUpItems(item.items) } : {})
    };

    delete cleaned.collapsed;

    return cleaned;
  });
}

/** The first link anywhere in a subtree — how a group is identified below. */
function firstLink(item: GeneratedSidebarItem): string | undefined {
  return item.link ?? item.items?.map(firstLink).find(Boolean);
}

const startsWith = (prefix: string) => (item: GeneratedSidebarItem) =>
  firstLink(item)?.startsWith(prefix) ?? false;

/** Every page in a subtree, with the folder headings above them dropped. */
function flattenItems<T extends GeneratedSidebarItem>(items: T[]): T[] {
  return items.flatMap((item) => (item.items?.length ? flattenItems(item.items as T[]) : [item]));
}

/** By label, so a flat list of fifty components can be scanned for a name. */
function byText(a: GeneratedSidebarItem, b: GeneratedSidebarItem): number {
  return (a.text ?? '').localeCompare(b.text ?? '');
}

/**
 * Guide, Components, Design, Discover more — with the component groups kept as
 * headings inside Components.
 *
 * Most of that cannot be stated by the folder tree, which is what this function
 * is for:
 *
 * - **The index page is an entry rather than the heading's link.** Left to the
 *   generator, `/components/` is only reachable by clicking the word
 *   "Components" above the menu, which does not look like a link and is easy to
 *   miss. It becomes a row of its own and the heading above it stops being
 *   clickable. `groupLabels` names it, because the
 *   page's own title is "Components" and a row reading the same word as the
 *   heading directly above it says nothing.
 * - **Examples** keeps its own top-level URLs (`/examples/*`) but reads as part
 *   of Components. A group nested in the menu and not in the filesystem is
 *   exactly the case a generated sidebar has no way to state. It is the one
 *   subgroup that is *not* flattened, since its pages are whole screens rather
 *   than components and there are only four of them.
 * - **The component groups stay.** They are what say that a Combobox is an
 *   input and a Card is a surface, and every component page in one list says
 *   nothing at all. What is flattened is only what is *inside* a group: the
 *   generator would otherwise nest a page one level deeper than the group it is
 *   in whenever a folder gains a subfolder.
 * - **Design and Discover more** are named here rather than by an `index.md`,
 *   for the reason `groupLabels` explains.
 *
 * Inside a group the pages are sorted by name rather than by their `order`
 * frontmatter. The inputs group alone holds thirty-five components, and nobody
 * remembers where Slider sits in a curated order.
 *
 * The groups themselves are sorted by name too, except `agent/` and `charts/`,
 * which are placed: `agent/` under `surfaces/` and `charts/` last. The comment
 * where that happens says why.
 */
function arrangeSidebar<T extends GeneratedSidebarItem>(items: T[], lang: string): T[] {
  const labels = groupLabels[lang] ?? groupLabels[defaultLocale];

  const guide = items.find(startsWith('guide/'));
  const components = items.find(startsWith('components/'));
  const examples = items.find(startsWith('examples/'));
  const design = items.find(startsWith('design/'));
  const browserSupport = items.find(startsWith('browser-support'));
  const changelog = items.find(startsWith('changelog'));

  if (components) {
    // A child with children of its own is a group folder; a child with only a
    // link is a page sitting loose in `components/`, which stays where it is.
    const children = components.items ?? [];
    const groups = children.filter((item) => item.items?.length) as T[];
    const loose = children.filter((item) => !item.items?.length) as T[];

    for (const group of groups) {
      group.items = flattenItems(group.items ?? []).sort(byText);
    }
    groups.sort(byText);

    /*
     * Two groups are placed rather than sorted, and for the same reason: each
     * is a set a reader either came for or has no use for at all. Left to the
     * alphabet, `agent` would open the list and `charts` would sit in the
     * middle of it, and in both cases somebody looking for a Button scrolls
     * past a group that is not about buttons to get to one that is.
     *
     * `agent` goes under `surfaces`, which is the last of the groups that say
     * what a component *is*; `charts` goes last. The order below matters —
     * moving `agent` first leaves `charts` where the second step expects it.
     */
    for (const [name, after] of [
      ['components/agent/', 'components/surfaces/'],
      ['components/charts/', null]
    ] as const) {
      const at = groups.findIndex(startsWith(name));

      if (at < 0) {
        continue;
      }

      const [group] = groups.splice(at, 1);
      const before = after === null ? -1 : groups.findIndex(startsWith(after));

      groups.splice(before < 0 ? groups.length : before + 1, 0, group);
    }

    const overview = components.link
      ? ({ text: labels.overview, link: components.link } as unknown as T)
      : undefined;
    delete components.link;

    components.items = [
      ...([overview].filter(Boolean) as T[]),
      ...(examples ? [examples as T] : []),
      ...loose,
      ...groups
    ];
  }

  if (examples) {
    examples.text = labels.examples;
  }

  if (design) {
    design.text = labels.design;
  }

  // A loose page has no group of its own, so the loose pages are given one —
  // the place anything that is neither a guide nor a component ends up. The
  // changelog goes last, because it is the one page there that keeps growing.
  const loose = [browserSupport, changelog].filter(Boolean) as T[];
  const more = loose.length ? ({ text: labels.more, items: loose } as unknown as T) : undefined;

  const moved = new Set([guide, components, examples, design, ...loose].filter(Boolean));

  return [
    ...([guide, components, design, more].filter(Boolean) as T[]),
    ...items.filter((item) => !moved.has(item))
  ];
}

const config = withSidebar(withI18n(vitePressConfig, vitePressI18nConfig), vitePressSidebarConfig);

const sidebar = config.themeConfig?.sidebar as
  Record<string, { items?: GeneratedSidebarItem[] } | GeneratedSidebarItem[]> | undefined;

if (sidebar) {
  for (const [path, group] of Object.entries(sidebar)) {
    // `/` is the default locale and `/{lang}/` is every other one — the same
    // mapping `localeBase` makes, read back the other way.
    const lang = path === '/' ? defaultLocale : path.replaceAll('/', '');

    if (Array.isArray(group)) {
      sidebar[path] = arrangeSidebar(cleanUpItems(group), lang);
    } else if (group?.items) {
      group.items = arrangeSidebar(cleanUpItems(group.items), lang);
    }
  }
}

export default defineConfig(config);
