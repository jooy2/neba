import { readdirSync, readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { withSidebar } from 'vitepress-sidebar';
import packageJson from '../../package.json' with { type: 'json' };
import { defineConfig, UserConfig } from 'vitepress';
import { withI18n } from 'vitepress-i18n';
import ReactPlugin from '@vitejs/plugin-react-swc';
import type { VitePressI18nOptions } from 'vitepress-i18n/types';
import type { VitePressSidebarOptions } from 'vitepress-sidebar/types';

const vitePressDir = dirname(fileURLToPath(import.meta.url));
const rootDir = resolve(vitePressDir, '../..');

const defaultLocale: string = 'en';
const supportLocales: string[] = [defaultLocale, 'ko'];
const editLinkPattern = `${packageJson.repository.url}/edit/main/docs/:path`;

/** A glob Vite can read on either platform — `resolve` gives Windows backslashes. */
const glob = (pattern: string) => resolve(rootDir, pattern).replaceAll('\\', '/');

/**
 * Every `@base-ui/react` subpath the library imports, read out of `src/`.
 *
 * These are reached only from a demo, which is reached only from a dynamic
 * import — so the dev server discovers them one at a time as previews mount,
 * and each discovery re-runs the dependency optimizer and reloads the page
 * underneath whoever is reading it. Listing them up front makes that one
 * pre-bundle at startup instead. Derived rather than written out, so a
 * component that starts using a new primitive is not a second edit here.
 */
function baseUiEntries(): string[] {
  const srcDir = resolve(rootDir, 'src');
  const entries = new Set<string>();

  for (const file of readdirSync(srcDir, { recursive: true, encoding: 'utf8' })) {
    if (!/\.tsx?$/.test(file)) {
      continue;
    }

    for (const [, entry] of readFileSync(resolve(srcDir, file), 'utf8').matchAll(
      /from '(@base-ui\/react\/[a-z-]+)'/g
    )) {
      entries.add(entry);
    }
  }

  return [...entries].sort();
}

/** `/` for whichever locale is the default, `/{lang}/` for every other one. */
const localeBase = (lang: string) => (lang === defaultLocale ? '/' : `/${lang}/`);

const commonSidebarConfig: VitePressSidebarOptions = {
  debugPrint: true,
  manualSortFileNameByPriority: ['introduction.md'],
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
 * `design/` and `examples/` have no `index.md` and the changelog is a loose
 * page, so none of them can take its heading from a page the way every other
 * group does. Left to the generator, `design/` would be capitalised to "Design"
 * over Korean pages and the changelog would sit at the root with no heading
 * over it at all.
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
      documentRootPath: `/docs/${lang}`,
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
  debugPrint: true,
  rootLocale: defaultLocale,
  searchProvider: 'local',
  description: {
    ko: '버튼, 입력란, 메뉴, 대화상자, 테이블 등 다양한 요소를 아우르는 포괄적인 React UI 컴포넌트 라이브러리입니다. 접근성이 뛰어나고 테마 적용이 가능하며, 하나의 프로프 어휘와 반투명한 아크릴 디자인 언어를 공유합니다. ESM 전용이며, 타입 정의가 포함되어 있고 다크 모드가 기본으로 지원됩니다.',
    en: 'A comprehensive React UI component library — buttons, fields, menus, dialogs, tables and much more — accessible and themeable, sharing one prop vocabulary and a translucent acrylic design language. ESM only, types included, dark mode built in.'
  },
  themeConfig: {
    ko: { nav: navFor('ko', ['가이드', '컴포넌트', '예제']) },
    en: { nav: navFor('en', ['Guide', 'Components', 'Examples']) }
  }
};

// Ref: https://vitepress.dev/reference/site-config
const vitePressConfig: UserConfig = {
  title: 'Neba UI',
  lastUpdated: true,
  outDir: '../docs-dist',
  cleanUrls: true,
  metaChunk: true,
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
    ['link', { rel: 'icon', type: 'image/png', sizes: '32x32', href: '/logo-32.png' }],
    ['link', { rel: 'icon', type: 'image/png', sizes: '16x16', href: '/logo-16.png' }],
    ['link', { rel: 'shortcut icon', href: '/favicon.ico' }]
  ],
  sitemap: {
    hostname: packageJson.homepage
  },
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
        { find: /^neba$/, replacement: resolve(rootDir, 'src/index.ts') }
      ]
    },
    css: {
      // VitePress's Vite root is `docs/`; the Tailwind plugin lives in the
      // repository root's `postcss.config.mjs`.
      postcss: rootDir
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
        ...baseUiEntries()
      ]
    },
    server: {
      warmup: {
        // The library is behind a dynamic import too, so the dev server would
        // not transform a single file of it until the first preview asks — and
        // then it asks for all hundred and ten at once, through the barrel.
        // The demos are left out on purpose: there are two hundred of them and
        // a session touches a handful, whereas `src/` is what every one of them
        // pulls in.
        clientFiles: [glob('src/**/*.{ts,tsx}')]
      }
    }
  },
  themeConfig: {
    logo: { src: '/logo-32.png', width: 24, height: 24 },
    editLink: {
      pattern: editLinkPattern
    },
    socialLinks: [
      { icon: 'npm', link: 'https://www.npmjs.com/package/neba' },
      { icon: 'github', link: packageJson.repository.url.replace('.git', '') }
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
 *   input and a Card is a surface, and fifty component pages in one list say
 *   nothing at all. What is flattened is only what is *inside* a group: the
 *   generator would otherwise nest a page one level deeper than the group it is
 *   in whenever a folder gains a subfolder.
 * - **Design and Discover more** are named here rather than by an `index.md`,
 *   for the reason `groupLabels` explains.
 *
 * Inside a group the pages are sorted by name rather than by their `order`
 * frontmatter. A group holds up to nineteen components and nobody remembers
 * where Slider sits in a curated order.
 */
function arrangeSidebar<T extends GeneratedSidebarItem>(items: T[], lang: string): T[] {
  const labels = groupLabels[lang] ?? groupLabels[defaultLocale];

  const guide = items.find(startsWith('guide/'));
  const components = items.find(startsWith('components/'));
  const examples = items.find(startsWith('examples/'));
  const design = items.find(startsWith('design/'));
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

  // A loose page has no group of its own, so it is given one — the place
  // anything that is neither a guide nor a component ends up.
  const more = changelog ? ({ text: labels.more, items: [changelog] } as unknown as T) : undefined;

  const moved = new Set([guide, components, examples, design, changelog].filter(Boolean));

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
