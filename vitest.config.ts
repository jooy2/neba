import { defineConfig } from 'vitest/config';
import ReactPlugin from '@vitejs/plugin-react';
import { playwright } from '@vitest/browser-playwright';
import { dirname, resolve } from 'path';
import { fileURLToPath } from 'url';

const rootDir = dirname(fileURLToPath(import.meta.url));

const SUPPORTED_BROWSERS = ['chromium', 'firefox', 'webkit'] as const;

type SupportedBrowser = (typeof SUPPORTED_BROWSERS)[number];

// Locally we only run Chromium so a plain `npm test` needs a single browser
// installed. CI fans out across all three via the `VITEST_BROWSER` env var,
// which also accepts a comma-separated list.
function resolveBrowsers(): SupportedBrowser[] {
  const requested = process.env.VITEST_BROWSER;

  if (!requested) {
    return ['chromium'];
  }

  const names = requested
    .split(',')
    .map((name) => name.trim())
    .filter(Boolean);
  const unsupported = names.filter(
    (name) => !SUPPORTED_BROWSERS.includes(name as SupportedBrowser)
  );

  if (unsupported.length > 0) {
    throw new Error(
      `Unsupported VITEST_BROWSER value(s): ${unsupported.join(', ')}. ` +
        `Supported browsers are: ${SUPPORTED_BROWSERS.join(', ')}.`
    );
  }

  return names as SupportedBrowser[];
}

export default defineConfig({
  plugins: [ReactPlugin()],
  resolve: {
    alias: {
      // Tests import from 'neba' exactly as a consumer would. The longer
      // specifier is listed first: Vite matches these in order, and `neba`
      // alone would swallow `neba/locales`.
      'neba/hooks': resolve(rootDir, 'src/hooks/index.ts'),
      'neba/locales': resolve(rootDir, 'src/locales/index.ts'),
      neba: resolve(rootDir, 'src/index.ts')
    }
  },
  // Pre-bundled up front. A test that hydrates server HTML imports it directly,
  // and a dependency Vite first meets in the middle of a run is optimised then,
  // which reloads the page under the file that was running: a second React, an
  // invalid hook call, and the next test file never becoming ready.
  optimizeDeps: {
    include: ['react-dom/client']
  },
  test: {
    include: ['test/**/*.test.{ts,tsx}'],
    // One file at a time. Test files run as frames of one browser, and a
    // browser has a single focus to hand out: a click in one file takes it from
    // whichever file was holding it. That is not a nuisance the assertions can
    // work around, because focus is half of what these components do — a toast
    // stops its dismissal timer while the window is blurred, and a keystroke
    // aimed at a menu goes wherever the focus went. Both showed up as failures
    // that only ever appeared in a full run and never on their own. The suite
    // takes about twice as long and stops lying.
    fileParallelism: false,
    // Components are built on Base UI, which relies on real browser APIs
    // (ResizeObserver, popover, dialog). Run them in a real browser rather
    // than polyfilling a DOM emulator.
    browser: {
      enabled: true,
      // Every browser reads the same locale, whatever the machine running it
      // is set to. WebKit otherwise takes the host's, so a table cell a chart
      // writes as `24K` came out as `2.4만` on a Korean Mac and nowhere else.
      provider: playwright({ contextOptions: { locale: 'en-US' } }),
      headless: true,
      screenshotFailures: false,
      instances: resolveBrowsers().map((browser) => ({ browser }))
    }
  }
});
