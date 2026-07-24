/**
 * `tsc` only emits JavaScript, so the design tokens in `src/styles.css` would
 * never reach `dist/` on their own. Copy them as the last step of the build.
 */
import { copyFileSync, mkdirSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');

mkdirSync(resolve(root, 'dist'), { recursive: true });
copyFileSync(resolve(root, 'src/styles.css'), resolve(root, 'dist/styles.css'));
