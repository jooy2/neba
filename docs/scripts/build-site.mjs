/**
 * Builds the site, with the heap raised.
 *
 * Two locales of about a hundred and fifty pages each, with over six hundred
 * React demos behind them, are more than Node's default heap, and the failure
 * is a V8 abort in the middle of Rollup rather than anything that names a page,
 * so it reads as a broken document. `NODE_OPTIONS` set on the npm script does
 * not reach the process VitePress starts, so its own bin is run through `node`
 * here with the flag on the command line. A heap a caller already chose in
 * `NODE_OPTIONS` is left alone.
 */
import { spawnSync } from 'node:child_process';
import { createRequire } from 'node:module';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const site = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const vitepress = resolve(dirname(require.resolve('vitepress/package.json')), 'bin/vitepress.js');
const heap = /--max-old-space-size/.test(process.env.NODE_OPTIONS ?? '')
  ? []
  : ['--max-old-space-size=8192'];

const { status } = spawnSync(process.execPath, [...heap, vitepress, 'build'], {
  cwd: site,
  stdio: 'inherit'
});

process.exitCode = status ?? 1;
