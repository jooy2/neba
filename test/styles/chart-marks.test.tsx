/**
 * The transition a chart's marks share, checked against the compiled sheet.
 *
 * A class Tailwind cannot read whole in the source is never generated, and
 * nothing fails: the mark simply snaps. No component test loads CSS, so this
 * is the one place that notices.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { ScatterChart } from 'neba';
import { markTransitionClasses } from '../../src/internal/chart-frame.js';
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

describe('a chart mark', () => {
  // Written in three string pieces, the class never reached the sheet, and
  // every mark but a pie's and a heatmap's snapped under the crosshair.
  it('moves on opacity, radius and scale', () => {
    const mark = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
    const host = document.createElementNS('http://www.w3.org/2000/svg', 'svg');

    mark.setAttribute('class', markTransitionClasses);
    host.append(mark);
    document.body.append(host);

    try {
      const moved = getComputedStyle(mark).transitionProperty.split(', ');

      expect(moved).toEqual(['opacity', 'r', 'scale']);
    } finally {
      host.remove();
    }
  });
});

describe('a scatter mark', () => {
  // The transition and the box a mark grows about are said once on the group
  // around the marks, so a rule that never reached the sheet would leave every
  // mark snapping, or growing about the corner of the plot.
  it('moves on opacity, radius and scale, from the group around it', async () => {
    const screen = await render(
      <div style={{ width: 400 }}>
        <ScatterChart label="Spend" height={200} series={[{ name: 'A', data: [{ x: 1, y: 1 }] }]} />
      </div>
    );

    await expect
      .poll(() => screen.container.querySelector('[role="img"] svg g path'))
      .not.toBeNull();

    const mark = screen.container.querySelector('[role="img"] svg g path')!;

    expect(getComputedStyle(mark).transitionProperty.split(', ')).toEqual([
      'opacity',
      'r',
      'scale'
    ]);
    expect(getComputedStyle(mark).transformBox).toBe('fill-box');
  });

  // The origin is a fraction of the mark's own box, which is the middle for
  // four of the shapes and two thirds of the way down for a triangle sat on
  // its circumcircle. Read back against the point the mark was drawn on, a
  // triangle growing about the middle of its box would drift as it grew.
  it('grows about the point it is pinned to, a triangle included', async () => {
    const screen = await render(
      <div style={{ width: 400 }}>
        <ScatterChart
          label="Spend"
          height={200}
          shape="varied"
          series={[
            { name: 'A', data: [{ x: 1, y: 1 }] },
            { name: 'B', data: [{ x: 2, y: 3 }] },
            { name: 'C', data: [{ x: 3, y: 2 }] }
          ]}
        />
      </div>
    );

    const marks = () => [
      ...screen.container.querySelectorAll<SVGPathElement>('[role="img"] svg g[stroke] path')
    ];

    await expect.poll(() => marks().length).toBe(3);

    for (const mark of marks()) {
      const d = mark.getAttribute('d')!;
      const numbers = (d.match(/-?[\d.]+/g) ?? []).map(Number);
      // A circle starts `r` to the left of its point; a triangle starts at its
      // apex, `size` above the point, and its next vertex is `size / 2` below.
      const point = d.includes('a')
        ? { x: numbers[0] + numbers[2], y: numbers[1] }
        : d.includes('L') && d.split('L').length === 3
          ? { x: numbers[0], y: numbers[1] + (numbers[3] - numbers[1]) / 1.5 }
          : null;

      if (!point) {
        continue;
      }

      const box = mark.getBBox();
      const [ox, oy] = getComputedStyle(mark).transformOrigin.split(' ').map(parseFloat);

      expect(box.x + ox).toBeCloseTo(point.x, 1);
      expect(box.y + oy).toBeCloseTo(point.y, 1);
    }

    // Both kinds were checked: the circle of series A and the triangle of C.
    expect(marks().filter((mark) => mark.getAttribute('d')!.split('L').length === 3)).toHaveLength(
      1
    );
  });
});
