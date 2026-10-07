/**
 * The two text effects' boxes, checked against the stylesheet. What reserves the
 * final text's size is CSS, and no component test loads it.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateScramble, AnimateTyping } from 'neba';
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

const LINE = 'A line long enough to wrap onto more than one line in a narrow box';

describe('the text effects under the stylesheet', () => {
  // Nothing typed was a box with no height, and every character that arrived
  // pushed whatever came after it down the page.
  it('holds the height of the whole line before a character has been typed', async () => {
    const screen = await render(
      <div style={{ width: 120 }}>
        <AnimateTyping text={LINE} trigger="manual" caret={false} data-testid="typing" />
        <AnimateScramble text={LINE} trigger="manual" data-testid="scramble" />
      </div>
    );
    const height = (id: string) => screen.getByTestId(id).element().getBoundingClientRect().height;

    expect(height('typing')).toBeGreaterThan(40);
    expect(height('scramble')).toBeGreaterThan(40);
  });

  // A line the text fills exactly has no room left for the caret, which then
  // wrapped onto a line of its own as the last character arrived.
  it('holds the room the caret takes at the end of a line the text fills', async () => {
    const words = 'Exactly as wide';
    const probe = await render(<span style={{ whiteSpace: 'pre' }}>{words}</span>);
    const width = Math.ceil(probe.container.querySelector('span')!.getBoundingClientRect().width);

    probe.unmount();

    const screen = await render(
      <div style={{ width }}>
        <AnimateTyping text={words} trigger="manual" duration={60} data-testid="typing" />
      </div>
    );
    const typing = screen.getByTestId('typing');
    const before = typing.element().getBoundingClientRect().height;

    await screen.rerender(
      <div style={{ width }}>
        <AnimateTyping text={words} trigger="manual" play duration={60} data-testid="typing" />
      </div>
    );

    await expect
      .poll(() => typing.element().querySelector('[data-text]')?.getAttribute('data-text'))
      .toBe(words);
    expect(typing.element().getBoundingClientRect().height).toBe(before);
  });
});
