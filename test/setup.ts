import { beforeAll } from 'vitest';

/*
 * Every test file starts with its own document holding the focus, as a page
 * in a tab does.
 *
 * A file runs in a frame of its own, and Firefox 157 starts that frame without
 * the focus: the page around it keeps it. A test whose first use of the focus
 * is a `focus()` call then failed some of the time, depending on whether
 * anything had moved the focus into the frame yet, and never when its file
 * ran alone. Focusing the frame's window brings it back before any test runs,
 * and a frame that already has the focus is left alone.
 */
beforeAll(() => {
  if (!document.hasFocus()) {
    window.focus();
  }
});
