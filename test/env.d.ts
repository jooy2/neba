/// <reference types="vite/client" />

/**
 * The reference above is for `import.meta.glob`, which `test/package` uses to
 * read every module under `src/` as text. It also declares `*.css`, but not the
 * `?inline` query — Vite serves that as the transformed stylesheet's text
 * rather than as a side effect that adds a `<style>` to the page, so the one
 * form the suite uses is declared here.
 */
declare module '*.css?inline' {
  const css: string;
  export default css;
}
