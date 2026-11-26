/**
 * The two packages the site documents, and the one axis of the site that is
 * not a language.
 *
 * A component page says the same things about `Button` whichever package a
 * reader installs: the same variants, the same sizes, the same behaviour. Only
 * the code, a few prop names and the install line differ. So the two are not
 * two sites and not two folders of pages. They are one page with the parts
 * that differ marked `::: fw react` or `::: fw flutter`, and this file is the
 * list those marks are checked against.
 *
 * Adding a framework is an entry here and the blocks on whatever pages have
 * something to say about it.
 */
export interface FrameworkInfo {
  id: string;
  /** What the sidebar's switch says. */
  label: string;
  /** The package name in that framework's registry. */
  pkg: string;
  /** The fence language its code samples are written in. */
  lang: string;
}

export const FRAMEWORKS: FrameworkInfo[] = [
  { id: 'react', label: 'React', pkg: 'neba', lang: 'tsx' },
  { id: 'flutter', label: 'Flutter', pkg: 'neba', lang: 'dart' }
];

export type Framework = string;

export const FRAMEWORK_IDS: string[] = FRAMEWORKS.map((framework) => framework.id);

/**
 * The framework a reader who has not chosen sees, and the one a page without
 * JavaScript shows.
 *
 * React, because every page was written for it first, and because the Flutter
 * port is still under way: a page whose Flutter half is not written yet still
 * has a React half to show.
 */
export const DEFAULT_FRAMEWORK: Framework = 'react';

/**
 * Where the choice is remembered.
 *
 * Not in the URL. A reader who picked Flutter picked it for the whole site,
 * and a query string would have to be carried by every link on every page,
 * the ones written by hand in the prose included.
 */
export const FRAMEWORK_STORAGE_KEY = 'neba-framework';

/**
 * The choice, applied to `<html data-fw>` before the page paints.
 *
 * A blocking inline script in `<head>` rather than code in the app, for the
 * reason every no-flash theme switch is one: the attribute decides which half
 * of a page is displayed, and a reader who picked Flutter would otherwise
 * watch the React half render and then vanish. A string, because it is
 * inlined into the document rather than imported.
 */
export const FRAMEWORK_HEAD_SCRIPT =
  `(function(){var ids=${JSON.stringify(FRAMEWORK_IDS)},value;` +
  `try{value=localStorage.getItem(${JSON.stringify(FRAMEWORK_STORAGE_KEY)})}catch(e){}` +
  `document.documentElement.dataset.fw=ids.indexOf(value)<0?${JSON.stringify(DEFAULT_FRAMEWORK)}:value})()`;
