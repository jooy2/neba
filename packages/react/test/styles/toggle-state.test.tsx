/**
 * An `outline` Toggle that is on, under the pointer, with the stylesheet on.
 *
 * Its plate is the dyed `--n-panel-press`, and hover swapped it for the
 * `--n-soft-hover` wash, which is paler: an on toggle faded towards off the
 * moment the pointer arrived, before anybody had pressed it. The plate stays
 * now, and the edge and the ink are what answer the pointer.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
import { Toggle } from 'neba';
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

describe('an outline toggle that is on', () => {
  it('keeps its plate under the pointer and moves its edge instead', async () => {
    const screen = await render(
      <>
        <Toggle variant="outline" defaultPressed>
          Bold
        </Toggle>
        <span>Elsewhere</span>
      </>
    );
    const toggle = screen.getByRole('button', { name: 'Bold' }).element() as HTMLElement;
    // No transition to wait out: the reading is the rule, not a frame of it.
    toggle.style.transition = 'none';

    await userEvent.hover(screen.getByText('Elsewhere'));
    const resting = getComputedStyle(toggle);
    const plate = resting.backgroundColor;
    const edge = resting.borderTopColor;

    await userEvent.hover(toggle);
    const hovered = getComputedStyle(toggle);

    expect(hovered.backgroundColor).toBe(plate);
    expect(hovered.borderTopColor).not.toBe(edge);
  });
});
