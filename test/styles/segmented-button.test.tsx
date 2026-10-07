/**
 * A server-rendered SegmentedButton, checked against the stylesheet.
 *
 * The tile under the chosen segment is placed by a measurement only a running
 * browser can make, so before hydration the chosen segment draws the same fill
 * itself. Whether it does, whether the unplaced tile stays out of sight, and
 * whether the hand-over moves anything are all decided by rules no component
 * test loads.
 */
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { renderToString } from 'react-dom/server';
import { hydrateRoot } from 'react-dom/client';
import { Segment, SegmentedButton } from 'neba';
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

const element = (
  <SegmentedButton aria-label="Range" variant="solid" defaultValue="week">
    <Segment value="day">Day</Segment>
    <Segment value="week">Week</Segment>
    <Segment value="month">Month</Segment>
  </SegmentedButton>
);

function serve() {
  const host = document.createElement('div');

  host.innerHTML = renderToString(element);
  document.body.append(host);

  const group = host.querySelector('[role="radiogroup"]')!;
  const chosen = group.querySelector('[data-checked]')!;
  const tile = group.querySelector(':scope > span[aria-hidden="true"]')!;

  return { host, group, chosen, tile };
}

describe('a server-rendered SegmentedButton under the stylesheet', () => {
  it('fills the chosen segment and keeps the unplaced tile out of sight', () => {
    const { host, chosen, tile } = serve();

    try {
      const fill = getComputedStyle(chosen, '::before');

      expect(fill.content).not.toBe('none');
      // The pointer light shares the pseudo-element and rests at nothing.
      expect(fill.opacity).toBe('1');
      expect(fill.backgroundColor).not.toBe('rgba(0, 0, 0, 0)');
      expect(getComputedStyle(tile).visibility).toBe('hidden');
    } finally {
      host.remove();
    }
  });

  it('hands the fill over to the tile on hydration without moving anything', async () => {
    const { host, group, chosen, tile } = serve();
    let shifts = 0;
    const observer = new PerformanceObserver((list) => {
      shifts += list.getEntries().length;
    });

    observer.observe({ type: 'layout-shift' });

    const root = hydrateRoot(host, element);

    try {
      await vi.waitFor(() => expect(group).toHaveAttribute('data-placed'));

      // Back to the pointer light, which has no colour of its own, and with no
      // fade out of the fill's opacity, which drew the light as a bloom. Asked
      // of the transitions rather than of the opacity: a pointer left over the
      // segment by an earlier file holds the light at 1 on hover.
      expect(getComputedStyle(chosen, '::before').backgroundColor).toBe('rgba(0, 0, 0, 0)');
      expect(
        document
          .getAnimations()
          .filter(
            (animation) =>
              animation instanceof CSSTransition &&
              animation.effect instanceof KeyframeEffect &&
              animation.effect.target === chosen &&
              animation.effect.pseudoElement === '::before'
          )
      ).toHaveLength(0);
      expect(getComputedStyle(tile).visibility).toBe('visible');

      await new Promise((resolve) => setTimeout(resolve, 100));

      expect(shifts).toBe(0);
    } finally {
      observer.disconnect();
      root.unmount();
      host.remove();
    }
  });
});
