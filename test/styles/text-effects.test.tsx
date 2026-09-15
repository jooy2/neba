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
});
