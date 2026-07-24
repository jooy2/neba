import { withSidebar } from 'vitepress-sidebar';
import packageJson from '../../package.json' with { type: 'json' };
import { defineConfig, UserConfig } from 'vitepress';
import { withI18n } from 'vitepress-i18n';
import type { VitePressI18nOptions } from 'vitepress-i18n/types';
import type { VitePressSidebarOptions } from 'vitepress-sidebar/types';

const defaultLocale: string = 'ko';
const supportLocales: string[] = [defaultLocale];
const editLinkPattern = `${packageJson.repository.url}/edit/main/docs/:path`;

const commonSidebarConfig: VitePressSidebarOptions = {
  debugPrint: true,
  manualSortFileNameByPriority: ['introduction.md'],
  excludeByGlobPattern: ['changelog.md'],
  collapsed: false,
  capitalizeFirst: true,
  useTitleFromFileHeading: true,
  useTitleFromFrontmatter: true,
  useFolderTitleFromIndexFile: true,
  frontmatterOrderDefaultValue: 9, // For 'CHANGELOG.md'
  sortMenusByFrontmatterOrder: true
};

const vitePressSidebarConfig = [
  ...supportLocales.map((lang) => {
    return {
      ...commonSidebarConfig,
      documentRootPath: `/docs/${lang}`,
      resolvePath: defaultLocale === lang ? '/' : `/${lang}/`,
      ...(defaultLocale === lang ? {} : { basePath: `/${lang}/` })
    };
  })
];

const vitePressI18nConfig: VitePressI18nOptions = {
  locales: supportLocales,
  debugPrint: true,
  rootLocale: defaultLocale,
  searchProvider: 'local',
  description: {
    ko: 'Neba 스타일의 React 컴포넌트 라이브러리'
  },
  themeConfig: {
    ko: {
      nav: [
        {
          text: '가이드',
          link: '/ko/guide/getting-started'
        },
        {
          text: '컴포넌트',
          link: '/ko/components/button'
        }
      ]
    }
  }
};

// Ref: https://vitepress.dev/reference/site-config
const vitePressConfig: UserConfig = {
  title: 'Neba UI',
  lastUpdated: true,
  outDir: '../docs-dist',
  cleanUrls: true,
  metaChunk: true,
  rewrites: {
    'en/:rest*': ':rest*'
  },
  head: [
    ['link', { rel: 'icon', type: 'image/png', sizes: '32x32', href: '/logo-32.png' }],
    ['link', { rel: 'icon', type: 'image/png', sizes: '16x16', href: '/logo-16.png' }],
    ['link', { rel: 'shortcut icon', href: '/favicon.ico' }]
  ],
  sitemap: {
    hostname: packageJson.homepage
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

export default defineConfig(
  withSidebar(withI18n(vitePressConfig, vitePressI18nConfig), vitePressSidebarConfig)
);
