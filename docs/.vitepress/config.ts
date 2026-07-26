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

/** `/` for whichever locale is the default, `/{lang}/` for every other one. */
const localeBase = (lang: string) => (lang === defaultLocale ? '/' : `/${lang}/`);

const commonSidebarConfig: VitePressSidebarOptions = {
  debugPrint: true,
  manualSortFileNameByPriority: ['introduction.md'],
  excludeByGlobPattern: ['changelog.md'],
  collapsed: false,
  capitalizeFirst: true,
  useTitleFromFileHeading: true,
  useTitleFromFrontmatter: true,
  useFolderTitleFromIndexFile: true,
  // Without this a folder whose only child is its `index.md` — `examples/` —
  // becomes a sidebar label that goes nowhere, and the components group stops
  // linking to the index page that lists them all.
  useFolderLinkFromIndexFile: true,
  frontmatterOrderDefaultValue: 9, // For 'CHANGELOG.md'
  sortMenusByFrontmatterOrder: true
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
  { text: labels[2], link: `${localeBase(lang)}examples/` }
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
      // Both are only ever reached through a dynamic import inside a demo, so
      // Vite would otherwise discover them mid-session and force a reload.
      include: ['react', 'react-dom/client']
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

/**
 * Guide first, then Components — with the Examples page as the first entry
 * inside it.
 *
 * Examples keeps its own top-level URL (`/examples/`), so the folder tree
 * cannot express this: a page nested in the menu but not in the filesystem is
 * exactly the case a generated sidebar has no way to state.
 */
function arrangeSidebar<T extends GeneratedSidebarItem>(items: T[]): T[] {
  const guide = items.find(startsWith('guide/'));
  const components = items.find(startsWith('components/'));
  const examples = items.find(startsWith('examples/'));

  if (examples && components) {
    components.items = [examples, ...(components.items ?? [])];
  }

  const moved = new Set([guide, components, examples].filter(Boolean));

  return [
    ...([guide, components].filter(Boolean) as T[]),
    ...items.filter((item) => !moved.has(item))
  ];
}

const config = withSidebar(withI18n(vitePressConfig, vitePressI18nConfig), vitePressSidebarConfig);

const sidebar = config.themeConfig?.sidebar as
  Record<string, { items?: GeneratedSidebarItem[] } | GeneratedSidebarItem[]> | undefined;

if (sidebar) {
  for (const [path, group] of Object.entries(sidebar)) {
    if (Array.isArray(group)) {
      sidebar[path] = arrangeSidebar(cleanUpItems(group));
    } else if (group?.items) {
      group.items = arrangeSidebar(cleanUpItems(group.items));
    }
  }
}

export default defineConfig(config);
