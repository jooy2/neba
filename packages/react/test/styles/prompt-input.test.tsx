/**
 * A `PromptInput`'s height under the stylesheet, which is where
 * `field-sizing: content` comes from.
 *
 * Where the browser sizes the field to its text, the field is the height of
 * its text in the server's HTML, before any script has run, and typing costs
 * no measurement. No component test loads the stylesheet, so all of them run
 * the measurement instead.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { renderToString } from 'react-dom/server';
import { render } from 'vitest-browser-react';
import { PromptInput } from 'neba';
import standaloneCss from '../../src/standalone.css?inline';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

const sizes = typeof CSS !== 'undefined' && CSS.supports('field-sizing', 'content');
const FIVE = 'one\ntwo\nthree\nfour\nfive';

/** How many of its own lines tall a field is drawn. */
const linesOf = (control: HTMLTextAreaElement) =>
  control.getBoundingClientRect().height / parseFloat(getComputedStyle(control).lineHeight);

describe('PromptInput under the stylesheet', () => {
  it.skipIf(!sizes)('sizes a field of one row to its text without measuring it', async () => {
    const screen = await render(
      <div style={{ width: 320 }}>
        <PromptInput label="Message" defaultValue={FIVE} />
      </div>
    );
    const control = screen.getByRole('textbox').element() as HTMLTextAreaElement;

    expect(linesOf(control)).toBeGreaterThan(4.5);
    expect(control.style.height).toBe('');
  });

  // A draft restored on the server grew to its height only once the page had
  // hydrated, and pushed what was under it down as it did.
  it.skipIf(!sizes)('is the height of its text in the HTML a server sends', () => {
    const host = document.createElement('div');

    host.style.width = '320px';
    host.innerHTML = renderToString(<PromptInput label="Message" defaultValue={FIVE} />);
    document.body.append(host);

    try {
      expect(linesOf(host.querySelector('textarea')!)).toBeGreaterThan(4.5);
    } finally {
      host.remove();
    }
  });

  // `field-sizing` ignores `rows`, and a field of three rows sized by its
  // `min-height` alone came out short of the three rows `rows` draws.
  it('keeps measuring a field that starts at more than one row', async () => {
    const screen = await render(
      <div style={{ width: 320 }}>
        <PromptInput label="Message" minRows={3} defaultValue={'one\ntwo'} />
      </div>
    );
    const control = screen.getByRole('textbox').element() as HTMLTextAreaElement;

    await expect.poll(() => control.style.height).not.toBe('');
  });
});
