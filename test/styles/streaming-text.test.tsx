/**
 * A `StreamingText`'s words under the stylesheet, which is where their fade is.
 *
 * Each word that streams in is an element with an animation on it. What those
 * animations leave behind once they are over, and whether the answer waits for
 * them before it goes back to plain text, can only be seen with the fade
 * running, and no component test loads the stylesheet.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { StreamingText } from 'neba';
import standaloneCss from '../../src/standalone.css?inline';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  // Slow enough to look at a fade while it runs.
  sheet.textContent = `${standaloneCss}\n:root { --neba-duration: 600ms; }`;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

const words = () => [...document.querySelectorAll('.neba-stream-word')];

describe('StreamingText under the stylesheet', () => {
  // `both` held every finished fade on its last frame, which is the word's own
  // opacity: nothing to see, and an effect the browser kept for every word.
  it('leaves nothing on a word once its fade is over', async () => {
    await render(<StreamingText streaming>A sheet</StreamingText>);

    const [word] = words();

    expect(word.getAnimations()).toHaveLength(1);
    await word.getAnimations()[0].finished;
    expect(word.getAnimations()).toHaveLength(0);
  });

  it('lets the last words finish fading before it draws the answer plain', async () => {
    const screen = await render(<StreamingText streaming>A sheet</StreamingText>);

    await screen.rerender(<StreamingText>A sheet of cut acrylic</StreamingText>);
    await new Promise((resolve) => setTimeout(resolve, 300));

    expect(words()).toHaveLength(5);
    expect(words().at(-1)!.getAnimations()).toHaveLength(1);

    await expect.poll(() => words(), { timeout: 3000 }).toHaveLength(0);
  });
});
