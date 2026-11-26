/**
 * Which framework the reader is here for, as one value the whole site shares.
 *
 * The choice lives in `localStorage`, and it is applied in two places that are
 * not redundant:
 *
 * - `<html data-fw>` is what displays a page. Every `::: fw` block is in the
 *   DOM and `theme/styles/framework.css` hides the ones that are not wanted,
 *   so switching is one attribute write and no re-render. In a built site the
 *   script in `<head>` sets it before the first paint.
 * - The `ref` is for the parts that are components rather than content: the
 *   switch itself, and anything that has to decide what to mount rather than
 *   draw both halves and hide one.
 *
 * `setFramework` writes the attribute, the ref and the storage together, so
 * nothing else has to remember the order.
 */
import { readonly, ref } from 'vue';
import {
  DEFAULT_FRAMEWORK,
  FRAMEWORK_IDS,
  FRAMEWORK_STORAGE_KEY,
  type Framework
} from './frameworks';

const current = ref<Framework>(DEFAULT_FRAMEWORK);

/**
 * The current framework. Read-only: it is written through `setFramework`, which
 * keeps `<html data-fw>` and the ref from drifting apart.
 *
 * On the server this is always the default, which is also what the
 * pre-rendered HTML is written as. `syncFramework` corrects it in the browser.
 */
export const framework = readonly(current);

function isKnown(value: unknown): value is Framework {
  return typeof value === 'string' && FRAMEWORK_IDS.includes(value);
}

export function setFramework(next: Framework): void {
  if (!isKnown(next) || next === current.value) {
    return;
  }

  current.value = next;

  if (typeof document !== 'undefined') {
    document.documentElement.dataset.fw = next;
  }

  try {
    localStorage.setItem(FRAMEWORK_STORAGE_KEY, next);
  } catch {
    // Private mode, or storage that is full. The choice still applies to this
    // page; it does not survive a reload.
  }
}

/**
 * Reads the stored choice into the ref, and writes it back onto `<html>`.
 *
 * Called once, from the theme's `enhanceApp`. It reads storage rather than the
 * attribute because the dev server applies the site's `head` config from the
 * client after the app boots, so there the inline script runs after this does:
 * reading the attribute would pick up nothing, and the ref and the page would
 * disagree for the rest of the session. Writing the attribute here is what
 * makes them agree either way.
 */
export function syncFramework(): void {
  if (typeof document === 'undefined') {
    return;
  }

  let stored: string | null = null;

  try {
    stored = localStorage.getItem(FRAMEWORK_STORAGE_KEY);
  } catch {
    // Private mode: the attribute is the next best guess.
  }

  const applied = isKnown(stored)
    ? stored
    : isKnown(document.documentElement.dataset.fw)
      ? document.documentElement.dataset.fw
      : DEFAULT_FRAMEWORK;

  current.value = applied;
  document.documentElement.dataset.fw = applied;
}
