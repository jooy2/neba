/**
 * A Tour's mask, checked against the stylesheet.
 *
 * The hole in the mask follows its target on every frame the page scrolls. It
 * moved on `top` and `left`, and a box moved by a layout property is a layout
 * shift to the browser on each of those frames: a second and a half of
 * scrolling under an open tour added 0.73 to the page's CLS. Nothing in a
 * component test would notice, because no component test loads CSS and the
 * mask is only `fixed` with it.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Tour } from 'neba';
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

const nextFrame = () => new Promise((resolve) => requestAnimationFrame(resolve));

describe("a Tour's mask", () => {
  it('follows a scrolled target without a layout shift', async () => {
    const screen = await render(
      <div>
        <div style={{ height: 600 }} />
        <button id="tour-mask-target" type="button" style={{ width: 200, height: 40 }}>
          Target
        </button>
        <div style={{ height: 2000 }} />
        <Tour
          defaultOpen
          scrollIntoView={false}
          steps={[{ target: '#tour-mask-target', title: 'Here', content: 'This one.' }]}
        />
      </div>
    );

    await expect.element(screen.getByText('This one.')).toBeInTheDocument();

    const mask = () => document.querySelector<HTMLElement>('[aria-hidden="true"].fixed.z-40');

    await expect.poll(() => mask()?.style.width).toBe('212px');

    let shifts = 0;
    const observer = new PerformanceObserver((list) => {
      shifts += list.getEntries().length;
    });

    observer.observe({ type: 'layout-shift' });

    try {
      for (let frame = 0; frame < 30; frame += 1) {
        window.scrollBy(0, 8);
        await nextFrame();
      }
      await new Promise((resolve) => setTimeout(resolve, 100));
    } finally {
      observer.disconnect();
      window.scrollTo(0, 0);
    }

    expect(shifts).toBe(0);
  });

  it('cuts the hole where the target is, padding included', async () => {
    const screen = await render(
      <div>
        <div style={{ height: 300 }} />
        <button id="tour-mask-placed" type="button" style={{ width: 200, height: 40 }}>
          Target
        </button>
        <Tour
          defaultOpen
          scrollIntoView={false}
          steps={[{ target: '#tour-mask-placed', title: 'Here', content: 'That one.', padding: 4 }]}
        />
      </div>
    );

    await expect.element(screen.getByText('That one.')).toBeInTheDocument();

    const target = screen.getByRole('button', { name: 'Target' }).element().getBoundingClientRect();

    await expect
      .poll(() => {
        const hole = document
          .querySelector('[aria-hidden="true"].fixed.z-40')
          ?.getBoundingClientRect();

        return hole && [hole.x, hole.y, hole.width, hole.height].map(Math.round);
      })
      .toEqual([target.x - 4, target.y - 4, target.width + 8, target.height + 8].map(Math.round));
  });
});
