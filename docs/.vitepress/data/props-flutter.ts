/**
 * Every Flutter props table, gathered from `props-flutter/*.ts`.
 *
 * One file per component page rather than one file for the site, because the
 * components are ported one at a time and a single file would be a merge
 * conflict per port. Each file's default export is `{ Button: PropRow[] }`,
 * keyed by the same name `<PropsTable name>` uses, and this flattens them into
 * the shape of `propTables` in `props.ts`.
 *
 * `shared.ts` holds the helpers those files are written with, so it is left out
 * of the glob. `import.meta.glob` is Vite's, so `config.ts`, which runs outside
 * Vite, cannot import this; `theme/components/PropsTable.vue` is its reader.
 */
import type { PropRow } from './props';

const pages = import.meta.glob<Record<string, PropRow[]>>(
  ['./props-flutter/*.ts', '!./props-flutter/shared.ts'],
  { eager: true, import: 'default' }
);

function gather(): Record<string, PropRow[]> {
  const tables: Record<string, PropRow[]> = {};

  // Sorted, so that which file wins a clash does not depend on the glob.
  for (const path of Object.keys(pages).sort()) {
    for (const [component, rows] of Object.entries(pages[path] ?? {})) {
      if (tables[component]) {
        console.warn(`[neba docs] ${component} has a Flutter props table twice; ${path} wins`);
      }

      tables[component] = rows;
    }
  }

  return tables;
}

export const flutterPropTables: Record<string, PropRow[]> = gather();
