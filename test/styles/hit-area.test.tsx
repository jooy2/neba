/**
 * The target a small control is pressed by, measured with the stylesheet on.
 *
 * WCAG 2.5.8 asks 24 CSS pixels. A dismiss ×, a stepper, a position dot and a
 * resize handle are drawn smaller than that on purpose, so the target is grown
 * with a pseudo element and nothing drawn moves. In a tight row the target grows
 * to full height and along the row only into the gaps, or each one would lie
 * over its neighbour and take its presses.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Alert, Carousel, NumberField, Panes, Pane } from 'neba';
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

/** The box a press lands on: the element and its `::before`, in page pixels. */
function target(element: Element): DOMRect {
  const own = element.getBoundingClientRect();
  const styles = getComputedStyle(element);
  const before = getComputedStyle(element, '::before');
  const px = (declaration: CSSStyleDeclaration, name: string) =>
    parseFloat(declaration.getPropertyValue(name)) || 0;
  const left = own.left + px(styles, 'border-left-width');
  const top = own.top + px(styles, 'border-top-width');

  const x0 = Math.min(own.left, left + px(before, 'left'));
  const x1 = Math.max(own.right, left + element.clientWidth - px(before, 'right'));
  const y0 = Math.min(own.top, top + px(before, 'top'));
  const y1 = Math.max(own.bottom, top + element.clientHeight - px(before, 'bottom'));

  return new DOMRect(x0, y0, x1 - x0, y1 - y0);
}

describe('the target under a small control', () => {
  it('reaches the × that dismisses an alert', async () => {
    const screen = await render(<Alert title="Saved" onClose={() => {}} />);
    const box = target(screen.getByRole('button').element());

    expect(box.width).toBeGreaterThanOrEqual(24);
    expect(box.height).toBeGreaterThanOrEqual(24);
  });

  it('grows a small stepper to a finger’s height and no further than its neighbour', async () => {
    const screen = await render(<NumberField size="xs" aria-label="Seats" />);
    const [down, up] = [
      screen.getByRole('button', { name: 'Decrease' }).element(),
      screen.getByRole('button', { name: 'Increase' }).element()
    ];

    expect(target(down).height).toBeGreaterThanOrEqual(24);
    expect(target(down).right).toBeLessThanOrEqual(target(up).left + 0.5);
  });

  it('grows a position dot to a finger’s height and no further than its neighbour', async () => {
    const screen = await render(
      <Carousel>
        <p>Alpha</p>
        <p>Bravo</p>
        <p>Charlie</p>
      </Carousel>
    );
    const first = screen.getByRole('button', { name: 'Slide 1 of 3' }).element();
    const second = screen.getByRole('button', { name: 'Slide 2 of 3' }).element();

    expect(target(second).height).toBeGreaterThanOrEqual(24);
    expect(target(first).right).toBeLessThanOrEqual(target(second).left + 0.5);
  });

  it('grabs a thin resize handle across 24px', async () => {
    const screen = await render(
      <div style={{ width: 400, height: 200 }}>
        <Panes resizable>
          <Pane>One</Pane>
          <Pane>Two</Pane>
        </Panes>
      </div>
    );
    const handle = screen.getByRole('separator').element();

    expect(handle.getBoundingClientRect().width).toBeLessThan(24);
    expect(target(handle).width).toBeGreaterThanOrEqual(24);
  });
});
