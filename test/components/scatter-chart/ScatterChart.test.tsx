import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { ScatterChart } from 'neba';

/** Four points, spread far enough apart that a hit test cannot be ambiguous. */
const CLOUD = [
  { x: 10, y: 10 },
  { x: 20, y: 40 },
  { x: 30, y: 20 },
  { x: 40, y: 50 }
];

const BUBBLES = [
  { x: 10, y: 10, z: 4 },
  { x: 20, y: 40, z: 16 },
  { x: 30, y: 20, z: 64 }
];

/** How many marks the plot drew. Every mark is a path with the surface ring on it. */
const markCount = (plot: Element) =>
  plot.querySelectorAll('path[stroke="var(--neba-chart-gap)"]').length;

const markPaths = (plot: Element) =>
  [...plot.querySelectorAll('path[stroke="var(--neba-chart-gap)"]')].map((path) =>
    path.getAttribute('d')
  );

/** The radius of each circular mark, read back out of its path. */
const markRadii = (plot: Element) =>
  markPaths(plot).map((d) => Number((d ?? '').match(/a([\d.]+) /)![1]));

/**
 * Where each circular mark sits, read back out of its path.
 *
 * A circle is drawn as `M{cx - r} {cy}a{r} {r} …`, so the centre is the start
 * point pushed right by the radius. Hovering a mark has to be aimed at where
 * the mark actually is: the plot is as wide as the window, so any hard-coded
 * pixel would be aiming at the middle of nothing.
 */
const markCentres = (plot: Element) =>
  markPaths(plot).map((d) => {
    const [, x, y, r] = (d ?? '').match(/M(-?[\d.]+) (-?[\d.]+)a([\d.]+) /)!;

    return { x: Number(x) + Number(r), y: Number(y) };
  });

/**
 * A chart is measured before it draws, so nothing reaches the DOM until the
 * host element has a width — `expect.element` retries, which is what makes
 * these assertions stable.
 */
describe('ScatterChart', () => {
  describe('rendering', () => {
    it('exposes the plot as an image with its label', async () => {
      const screen = await render(
        <ScatterChart label="Spend against revenue" series={[{ name: 'Q1', data: CLOUD }]} />
      );

      await expect
        .element(screen.getByRole('img', { name: 'Spend against revenue' }))
        .toBeInTheDocument();
    });

    it('draws one mark per point', async () => {
      const screen = await render(
        <ScatterChart label="Spend" series={[{ name: 'Q1', data: CLOUD }]} />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();
      expect(markCount(plot.element())).toBe(4);
    });

    it('draws marks for every series', async () => {
      const screen = await render(
        <ScatterChart
          label="Spend"
          series={[
            { name: 'Q1', data: CLOUD },
            { name: 'Q2', data: BUBBLES }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();
      expect(markCount(plot.element())).toBe(7);
    });

    it('draws no mark for a gap', async () => {
      const screen = await render(
        <ScatterChart
          label="Spend"
          series={[
            {
              name: 'Q1',
              data: [
                { x: 1, y: 1 },
                { x: 2, y: null },
                { x: 3, y: 3 }
              ]
            }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();
      expect(markCount(plot.element())).toBe(2);
    });

    it('reflects a changed series on re-render', async () => {
      const screen = await render(
        <ScatterChart label="Spend" series={[{ name: 'Q1', data: CLOUD }]} />
      );

      await expect.element(screen.getByRole('cell', { name: '50' })).toBeInTheDocument();

      await screen.rerender(
        <ScatterChart
          label="Spend"
          series={[{ name: 'Q1', data: [...CLOUD.slice(0, 3), { x: 40, y: 99 }] }]}
        />
      );

      await expect.element(screen.getByRole('cell', { name: '99' })).toBeInTheDocument();
    });

    it('shows the empty state rather than an axis when there is nothing to draw', async () => {
      const screen = await render(<ScatterChart label="Spend" series={[]} empty="No data yet" />);

      await expect.element(screen.getByText('No data yet')).toBeInTheDocument();
      expect(screen.getByRole('table').query()).toBeNull();
    });

    it('shows the empty state when x is not a number', async () => {
      const screen = await render(
        <ScatterChart
          label="Spend"
          empty="No data yet"
          series={[{ name: 'Q1', data: [{ x: 'Seoul', y: 10 }] }]}
        />
      );

      await expect.element(screen.getByText('No data yet')).toBeInTheDocument();
    });
  });

  describe('the value x axis', () => {
    it('ticks at numbers rather than at the points', async () => {
      const screen = await render(
        <ScatterChart
          label="Spend"
          xAxis={{ min: 0, max: 100, tickCount: 4 }}
          series={[{ name: 'Q1', data: CLOUD }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).toContain('0');
      expect(texts).toContain('100');
    });

    it('writes each x tick through the axis tickFormat', async () => {
      const screen = await render(
        <ScatterChart
          label="Spend"
          xAxis={{ min: 2000, max: 2020, tickCount: 2, tickFormat: (value) => `Y${value}` }}
          series={[{ name: 'Q1', data: CLOUD }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).toContain('Y2000');
      expect(texts).toContain('Y2020');
    });

    it('does not drag the scale down to zero', async () => {
      const screen = await render(
        <ScatterChart label="Spend" series={[{ name: 'Q1', data: CLOUD }]} />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();

      // The data runs 10..40 on x and 10..50 on y. A scale forced through zero
      // would put every mark in one corner, and a `0` on both axes is how that
      // shows up in the ticks.
      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).not.toContain('0');
    });

    it('places a mark by its own x rather than by its index', async () => {
      const screen = await render(
        <ScatterChart
          label="Spend"
          height={200}
          yAxis={{ hidden: true }}
          series={[
            {
              name: 'Q1',
              data: [
                { x: 0, y: 5 },
                { x: 100, y: 5 }
              ]
            }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();

      // Two points at the same y, at opposite ends of the x scale: the marks
      // have to differ in x and agree in y.
      const [first, second] = markPaths(plot.element()).map((d) =>
        (d ?? '')
          .match(/M(-?[\d.]+) (-?[\d.]+)/)!
          .slice(1)
          .map(Number)
      );

      expect(second[0]).toBeGreaterThan(first[0]);
      expect(second[1]).toBeCloseTo(first[1], 5);
    });

    it('casts a grid in both directions', async () => {
      const screen = await render(
        <ScatterChart
          label="Spend"
          xAxis={{ tickCount: 2 }}
          yAxis={{ tickCount: 2 }}
          series={[{ name: 'Q1', data: CLOUD }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();

      const lines = [...plot.element().querySelectorAll('line')];
      const vertical = lines.filter((line) => line.getAttribute('x1') === line.getAttribute('x2'));
      const horizontal = lines.filter(
        (line) => line.getAttribute('y1') === line.getAttribute('y2')
      );

      expect(vertical.length).toBeGreaterThan(0);
      expect(horizontal.length).toBeGreaterThan(0);
    });

    it('drops the x grid when the axis says so', async () => {
      const screen = await render(
        <ScatterChart
          label="Spend"
          xAxis={{ grid: false }}
          series={[{ name: 'Q1', data: CLOUD }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();

      const vertical = [...plot.element().querySelectorAll('line')].filter(
        (line) => line.getAttribute('x1') === line.getAttribute('x2')
      );

      expect(vertical.length).toBe(0);
    });
  });

  describe('bubbles', () => {
    it('scales a radius by the square root of z, not by z', async () => {
      const screen = await render(
        <ScatterChart label="Spend" maxRadius={40} series={[{ name: 'Q1', data: BUBBLES }]} />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();

      // A circle is drawn as `M(cx - r) cy a r r …`, so the radius is the third
      // number in the path. z of 4, 16 and 64 is a sixteenfold range, which as
      // an area is a fourfold range of radius: 10, 20, 40.
      const radii = markRadii(plot.element()).sort((a, b) => a - b);

      expect(radii).toHaveLength(3);
      expect(radii[2]).toBeCloseTo(40, 4);
      expect(radii[1]).toBeCloseTo(20, 4);
      expect(radii[0]).toBeCloseTo(10, 4);
    });

    it('paints the largest first, so a nested bubble stays visible', async () => {
      const screen = await render(
        <ScatterChart label="Spend" maxRadius={40} series={[{ name: 'Q1', data: BUBBLES }]} />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();

      const radii = markRadii(plot.element());

      expect(radii).toEqual([...radii].sort((a, b) => b - a));
    });

    it('draws a point with no z at the plain radius', async () => {
      const screen = await render(
        <ScatterChart label="Spend" pointRadius={7} series={[{ name: 'Q1', data: CLOUD }]} />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();

      const radii = markRadii(plot.element());

      expect(radii).toEqual([7, 7, 7, 7]);
    });

    it('keeps the z scale steady when a series is hidden', async () => {
      const screen = await render(
        <ScatterChart
          label="Spend"
          maxRadius={40}
          series={[
            { name: 'Small', data: [{ x: 1, y: 1, z: 4 }] },
            { name: 'Large', data: [{ x: 2, y: 2, z: 64 }] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();

      // z of 4 against a top of 64 is a quarter of the radius.
      expect(Math.min(...markRadii(plot.element()))).toBeCloseTo(10, 4);

      await screen.getByRole('button', { name: 'Large' }).click();

      // The largest z is gone from the picture but not from the scale, so the
      // bubble that is left is exactly the size it always was — a size that
      // changed on a legend click would be a legend that rewrites the data.
      await expect
        .element(screen.getByRole('button', { name: 'Large' }))
        .toHaveAttribute('aria-pressed', 'false');
      expect(markRadii(plot.element())).toEqual([expect.closeTo(10, 4)]);
    });
  });

  describe('shape', () => {
    it('draws circles for three series', async () => {
      const screen = await render(
        <ScatterChart
          label="Spend"
          series={[
            { name: 'A', data: [{ x: 1, y: 1 }] },
            { name: 'B', data: [{ x: 2, y: 2 }] },
            { name: 'C', data: [{ x: 3, y: 3 }] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();
      // An arc command is what makes a path a circle.
      expect(markPaths(plot.element()).every((d) => d?.includes('a'))).toBe(true);
    });

    it('varies the shape from the fourth series on', async () => {
      const screen = await render(
        <ScatterChart
          label="Spend"
          series={[
            { name: 'A', data: [{ x: 1, y: 1 }] },
            { name: 'B', data: [{ x: 2, y: 2 }] },
            { name: 'C', data: [{ x: 3, y: 3 }] },
            { name: 'D', data: [{ x: 4, y: 4 }] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();

      const shapes = new Set(markPaths(plot.element()));

      expect(shapes.size).toBe(4);
      // Only the first is still a circle.
      expect(markPaths(plot.element()).filter((d) => d?.includes('a')).length).toBe(1);
    });

    it('leaves them circles when every series brought its own colour', async () => {
      const screen = await render(
        <ScatterChart
          label="Spend"
          series={[
            { name: 'A', color: 'primary', data: [{ x: 1, y: 1 }] },
            { name: 'B', color: 'success', data: [{ x: 2, y: 2 }] },
            { name: 'C', color: 'warning', data: [{ x: 3, y: 3 }] },
            { name: 'D', color: 'danger', data: [{ x: 4, y: 4 }] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();
      expect(markPaths(plot.element()).every((d) => d?.includes('a'))).toBe(true);
    });

    it('takes one shape for every mark when it is named', async () => {
      const screen = await render(
        <ScatterChart label="Spend" shape="square" series={[{ name: 'Q1', data: CLOUD }]} />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();
      expect(markPaths(plot.element()).every((d) => d?.startsWith('M') && !d.includes('a'))).toBe(
        true
      );
    });

    it('gives the legend the same shape as the marks', async () => {
      const screen = await render(
        <ScatterChart
          label="Spend"
          shape="varied"
          series={[
            { name: 'A', data: [{ x: 1, y: 1 }] },
            { name: 'B', data: [{ x: 2, y: 2 }] }
          ]}
        />
      );

      const entry = screen.getByRole('button', { name: 'B' });

      await expect.element(entry).toBeInTheDocument();
      // A square, which is what slot two is handed — not the default swatch.
      expect(entry.element().querySelector('svg path')?.getAttribute('d')).not.toContain('a');
    });
  });

  describe('the table', () => {
    it('gives every point a row of its own', async () => {
      const screen = await render(
        <ScatterChart label="Spend" series={[{ name: 'Q1', data: CLOUD }]} />
      );

      const table = screen.getByRole('table', { name: 'Spend' });

      await expect.element(table).toBeInTheDocument();
      expect(table.element().querySelectorAll('tbody tr').length).toBe(4);
      await expect.element(screen.getByRole('cell', { name: '40' }).first()).toBeInTheDocument();
    });

    it('names its columns from the axis labels', async () => {
      const screen = await render(
        <ScatterChart
          label="Spend"
          xAxis={{ label: 'Spend' }}
          yAxis={{ label: 'Revenue' }}
          series={[{ name: 'Q1', data: CLOUD }]}
        />
      );

      await expect
        .element(screen.getByRole('columnheader', { name: 'Revenue' }))
        .toBeInTheDocument();
    });

    it('falls back to x and y when the axes are unnamed', async () => {
      const screen = await render(
        <ScatterChart label="Spend" series={[{ name: 'Q1', data: CLOUD }]} />
      );

      await expect.element(screen.getByRole('columnheader', { name: 'x' })).toBeInTheDocument();
      await expect.element(screen.getByRole('columnheader', { name: 'y' })).toBeInTheDocument();
      expect(screen.getByRole('columnheader', { name: 'z' }).query()).toBeNull();
    });

    it('adds a z column only when a point has one', async () => {
      const screen = await render(
        <ScatterChart label="Spend" series={[{ name: 'Q1', data: BUBBLES }]} />
      );

      await expect.element(screen.getByRole('columnheader', { name: 'z' })).toBeInTheDocument();
      await expect.element(screen.getByRole('cell', { name: '64' })).toBeInTheDocument();
    });

    it('leaves a gap out rather than writing it as a zero', async () => {
      const screen = await render(
        <ScatterChart
          label="Spend"
          series={[
            {
              name: 'Q1',
              data: [
                { x: 1, y: 1 },
                { x: 2, y: null }
              ]
            }
          ]}
        />
      );

      const table = screen.getByRole('table', { name: 'Spend' });

      await expect.element(table).toBeInTheDocument();

      const cells = [...table.element().querySelectorAll('tbody tr')].map((row) =>
        [...row.querySelectorAll('td')].map((cell) => cell.textContent?.trim())
      );

      expect(cells).toEqual([
        ['1', '1'],
        ['2', '']
      ]);
    });

    it('passes format through to the values', async () => {
      const screen = await render(
        <ScatterChart
          label="Revenue"
          format={{ style: 'currency', currency: 'USD', maximumFractionDigits: 0 }}
          series={[{ name: 'Q1', data: [{ x: 1, y: 1200 }] }]}
        />
      );

      await expect.element(screen.getByRole('cell', { name: '$1,200' })).toBeInTheDocument();
    });
  });

  describe('tooltip', () => {
    it('opens on the mark nearest the pointer and names its series', async () => {
      const screen = await render(
        <ScatterChart
          label="Spend"
          height={200}
          yAxis={{ hidden: true }}
          xAxis={{ hidden: true }}
          series={[
            { name: 'High', data: [{ x: 50, y: 100 }] },
            { name: 'Low', data: [{ x: 50, y: 0 }] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();

      // The two marks share an x, so the higher of them is the one nearer the
      // top of the plot — and that is the one the pointer is put on.
      const [high] = markCentres(plot.element()).sort((a, b) => a.y - b.y);

      await plot.hover({ position: high });

      const status = screen.getByRole('status');

      await expect.element(status).toBeInTheDocument();
      expect(status.element().querySelectorAll('li').length).toBe(1);
      expect(status.element().textContent).toContain('High');
    });

    it('says nothing when the pointer is nowhere near a mark', async () => {
      const screen = await render(
        <ScatterChart
          label="Spend"
          height={200}
          series={[{ name: 'Q1', data: [{ x: 0, y: 0 }] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();

      const [mark] = markCentres(plot.element());

      // Well past the hit radius, which tops out at the mark's own size plus 24.
      await plot.hover({ position: { x: mark.x, y: mark.y - 80 } });

      expect(screen.getByRole('status').query()).toBeNull();
    });

    it('draws no crosshair', async () => {
      const screen = await render(
        <ScatterChart
          label="Spend"
          height={200}
          xAxis={{ hidden: true }}
          yAxis={{ hidden: true }}
          series={[{ name: 'Q1', data: [{ x: 50, y: 50 }] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();

      const before = plot.element().querySelectorAll('line').length;

      await plot.hover({ position: markCentres(plot.element())[0] });
      await expect.element(screen.getByRole('status')).toBeInTheDocument();

      expect(plot.element().querySelectorAll('line').length).toBe(before);
    });

    it('is not reachable when it is turned off', async () => {
      const screen = await render(
        <ScatterChart label="Spend" tooltip={false} series={[{ name: 'Q1', data: CLOUD }]} />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();

      await plot.hover({ position: { x: 60, y: 60 } });

      expect(screen.getByRole('status').query()).toBeNull();
    });
  });

  describe('legend', () => {
    it('is left off for a single series', async () => {
      const screen = await render(
        <ScatterChart label="Spend" series={[{ name: 'Q1', data: CLOUD }]} />
      );

      await expect.element(screen.getByRole('img', { name: 'Spend' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Q1' }).query()).toBeNull();
    });

    it('hides a series when its entry is clicked', async () => {
      const screen = await render(
        <ScatterChart
          label="Spend"
          series={[
            { name: 'Q1', data: CLOUD },
            { name: 'Q2', data: BUBBLES }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();
      expect(markCount(plot.element())).toBe(7);

      await screen.getByRole('button', { name: 'Q2' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Q2' }))
        .toHaveAttribute('aria-pressed', 'false');
      expect(markCount(plot.element())).toBe(4);
    });
  });
});
