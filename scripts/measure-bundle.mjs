/**
 * What a consumer's bundle actually weighs, checked against a committed budget.
 *
 * A component library's size is not its `unpackedSize` and not what a badge on
 * the README reports. It is how many bytes land in the bundle of someone who
 * imports *some* of it — and that number is decided by things that fail
 * silently. One shared object literal reintroduced into `internal/`, one
 * `sideEffects` widened, one pure annotation lost to a minifier setting, and a
 * two-kilobyte component starts dragging thirty behind it. None of that breaks
 * a build, fails a type check or turns a test red. It ships.
 *
 * `test/package/resolution.test.ts` guards the *structure* those numbers rest
 * on — the extensions, the barrel, the subpath exports, `sideEffects`, one
 * message table per namespace. This guards the numbers themselves, which is the
 * only way to catch a regression that keeps every invariant and still doubles
 * what a consumer downloads.
 *
 *   npm run size           # check, and fail if a scenario is over
 *   npm run size:update    # rewrite the budgets
 *
 * It measures `dist/`, so `npm run build` has to have run first. The scenarios
 * and their budgets are in `bundle-budget.json` beside this file — one file, so
 * that changing what is measured and changing what it is allowed to weigh are
 * the same edit.
 *
 * The bundler is rollup, driven through Vite's library build, with terser and
 * gzip -9, and `react`/`react-dom` external because every consumer already has
 * them. That is a choice worth stating rather than assuming: esbuild shakes the
 * same graph five to ten per cent heavier, so a budget recorded under one and
 * checked under the other would drift for no reason anybody could find. Rollup
 * is what Vite, and therefore most of this library's consumers, actually runs.
 *
 * A budget is an upper bound, not a target. Going *under* one is reported and
 * does not fail — but the number is then stale, and the note says to bring it
 * down, because a budget with slack in it stops catching anything.
 */
import { existsSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { gzipSync } from 'node:zlib';
import { build } from 'vite';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const budgetFile = resolve(root, 'scripts/bundle-budget.json');
const dist = resolve(root, 'dist');
const update = process.argv.includes('--update');

/**
 * The entry a scenario stands for, as a consumer would have written it.
 *
 * The sink at the end is load-bearing: an import whose bindings are never read
 * is an import rollup is entitled to delete, and a scenario that measured an
 * empty file would pass every budget it has.
 */
function entrySource({ imports, locales }) {
  const lines = [];
  const sinks = [];

  if (imports === null) {
    lines.push("import * as everything from 'neba';");
    sinks.push('Object.keys(everything).length');
  } else {
    lines.push(`import { ${imports.join(', ')} } from 'neba';`);
    sinks.push(`[${imports.join(', ')}]`);
  }

  if (locales?.length) {
    lines.push(`import { registerMessages, ${locales.join(', ')} } from 'neba/locales';`);

    for (const binding of locales) {
      // A language is registered under the name of its file, which is not
      // always its binding: `zhHans` answers to `zh-hans`.
      const tag = binding.replace(/[A-Z]/g, (letter) => `-${letter.toLowerCase()}`);

      lines.push(`registerMessages('${tag}', ${binding});`);
    }
  }

  lines.push(`globalThis.__neba = [${sinks.join(', ')}];`);

  return `${lines.join('\n')}\n`;
}

/** One scenario, bundled and weighed. */
async function measure(scenario, work) {
  const entry = join(work, `${scenario.id}.js`);
  const outDir = join(work, `out-${scenario.id}`);

  writeFileSync(entry, entrySource(scenario));

  await build({
    root,
    logLevel: 'error',
    define: { 'process.env.NODE_ENV': '"production"' },
    resolve: {
      alias: {
        // The longer specifier is listed first: Vite matches these in order,
        // and `neba` alone would swallow `neba/locales`.
        'neba/locales': join(dist, 'locales/index.js'),
        neba: join(dist, 'index.js')
      }
    },
    build: {
      outDir,
      emptyOutDir: true,
      minify: 'terser',
      lib: { entry, formats: ['es'], fileName: 'bundle' },
      rollupOptions: {
        external: ['react', 'react-dom', 'react/jsx-runtime', 'react-dom/client']
      }
    }
  });

  return gzipSync(readFileSync(join(outDir, 'bundle.js')), { level: 9 }).length / 1024;
}

const kb = (bytes) => `${bytes.toFixed(1)} kB`;

/** What to look at first when a number has gone up, likeliest cause first. */
const suspects = [
  'a shared module in src/internal/ gained a table every importer now pays for in full',
  "sideEffects in package.json got widened past '**/*.css'",
  'output.preserve_annotations was dropped from terser.config.json, so the pure',
  "annotations no longer reach the consumer's bundler",
  'a new dependency, or a heavier @base-ui/react'
];

/**
 * The whole run, as a function so a failure can `return`.
 *
 * The exit code is set rather than forced: `process.exit` truncates whatever
 * stdout has not flushed, and on a run that is nothing but a report, that is
 * the report.
 */
async function main() {
  if (!existsSync(join(dist, 'index.js'))) {
    console.error(
      'dist/ is missing or empty. This measures the built package, not the source:\n\n  npm run build\n'
    );
    process.exitCode = 1;

    return;
  }

  const config = JSON.parse(readFileSync(budgetFile, 'utf8'));
  const work = mkdtempSync(join(tmpdir(), 'neba-bundle-'));
  const width = Math.max(...config.scenarios.map((scenario) => scenario.label.length));
  const results = [];

  console.log(`\n${config.bundler} — ${config.unit}\n`);

  try {
    for (const scenario of config.scenarios) {
      const measured = await measure(scenario, work);
      const over = measured > scenario.budget * (1 + config.tolerancePercent / 100);
      // Enough under that the budget has stopped meaning anything.
      const stale = !over && measured < scenario.budget * (1 - config.tolerancePercent / 100);
      const delta = measured - scenario.budget;

      results.push({ scenario, measured, over, stale });

      console.log(
        `  ${over ? 'OVER ' : stale ? 'under' : '  ok '}  ${scenario.label.padEnd(width)}  ` +
          `${kb(measured).padStart(9)}   budget ${kb(scenario.budget).padStart(9)}   ` +
          `${delta >= 0 ? '+' : '−'}${Math.abs(delta).toFixed(1)}`
      );
    }
  } finally {
    rmSync(work, { recursive: true, force: true });
  }

  if (update) {
    for (const { scenario, measured } of results) {
      scenario.budget = Number(measured.toFixed(1));
    }

    writeFileSync(budgetFile, `${JSON.stringify(config, null, 2)}\n`);
    console.log('\nbudgets rewritten: scripts/bundle-budget.json\n');

    return;
  }

  const stale = results.filter((result) => result.stale);
  const over = results.filter((result) => result.over);

  if (stale.length > 0) {
    console.log(
      `\n${stale.length} scenario${stale.length === 1 ? ' is' : 's are'} more than ` +
        `${config.tolerancePercent}% under budget. That is the good direction, but a budget ` +
        'with slack in it catches nothing — bring it down with:\n\n  npm run size:update\n'
    );
  }

  if (over.length === 0) {
    console.log('\nEvery scenario is within budget.\n');

    return;
  }

  console.error(
    `\n${over.length} scenario${over.length === 1 ? '' : 's'} over budget by more than ` +
      `${config.tolerancePercent}%:\n`
  );

  for (const { scenario, measured } of over) {
    const percent = ((measured - scenario.budget) / scenario.budget) * 100;

    console.error(
      `  ${scenario.label}: ${kb(measured)}, budget ${kb(scenario.budget)} (+${percent.toFixed(1)}%)`
    );
  }

  console.error(
    '\nSomething stopped being tree-shakeable, or a component genuinely grew. The usual\n' +
      `causes, in the order they are worth checking:\n\n${suspects
        .map((line, index) => (index === 3 ? `    ${line}` : `  - ${line}`))
        .join('\n')}\n\n` +
      'If the growth is real and wanted, record it: npm run size:update\n'
  );

  process.exitCode = 1;
}

await main();
