import { describe, expect, it } from 'vitest';
import { HeatmapChart } from 'neba';
import { render } from 'vitest-browser-react';

const HOURS = ['00', '06', '12', '18'];

const TRAFFIC = [
  { name: 'Mon', data: [1, 20, 40, 8] },
  { name: 'Tue', data: [2, 24, 48, 9] },
  { name: 'Wed', data: [3, 28, 56, 11] }
];

const cells = (plot: Element) => [...plot.querySelectorAll('rect')];
const fills = (plot: Element) => cells(plot).map((rect) => rect.getAttribute('fill'));
const texts = (plot: Element) => [...plot.querySelectorAll('text')].map((node) => node.textContent);

/**
 * What the legend says. Scoped past the hidden table, which holds every one of
 * these numbers too — an unscoped query for `96` finds a table cell first.
 */
const legendText = (plot: Element) =>
  [...(plot.parentElement?.parentElement?.querySelectorAll('span') ?? [])]
    .filter((node) => !node.closest('table'))
    .map((node) => node.textContent);

/**
 * A chart is measured before it draws, so nothing reaches the DOM until the
 * host element has a width — `expect.element` retries, which is what makes
 * these assertions stable.
 */
describe('HeatmapChart', () => {
  describe('rendering', () => {
    it('exposes the plot as an image with its label', async () => {
      const screen = await render(
        <HeatmapChart label="Sessions by hour" categories={HOURS} series={TRAFFIC} />
      );

      await expect
        .element(screen.getByRole('img', { name: 'Sessions by hour' }))
        .toBeInTheDocument();
    });

    it('draws a cell per row and column', async () => {
      const screen = await render(
        <HeatmapChart label="Sessions" categories={HOURS} series={TRAFFIC} />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      expect(cells(plot.element()).length).toBe(12);
    });

    it('leaves a gap undrawn rather than painting it as the bottom of the scale', async () => {
      const screen = await render(
        <HeatmapChart
          label="Sessions"
          categories={HOURS}
          series={[{ name: 'Mon', data: [1, null, 40, 8] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      expect(cells(plot.element()).length).toBe(3);
    });

    it('names the rows and the columns, each in a band of its own', async () => {
      const screen = await render(
        <HeatmapChart label="Sessions" categories={HOURS} series={TRAFFIC} />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      const written = texts(plot.element());

      expect(written).toContain('Mon');
      expect(written).toContain('12');
    });

    it('reflects a changed series on re-render', async () => {
      const screen = await render(
        <HeatmapChart label="Sessions" categories={HOURS} series={TRAFFIC} />
      );

      await expect.element(screen.getByRole('cell', { name: '56' })).toBeInTheDocument();

      await screen.rerender(
        <HeatmapChart
          label="Sessions"
          categories={HOURS}
          series={[{ name: 'Wed', data: [3, 28, 99, 11] }]}
        />
      );

      await expect.element(screen.getByRole('cell', { name: '99' })).toBeInTheDocument();
    });

    it('shows the empty state when there is nothing to draw', async () => {
      const screen = await render(
        <HeatmapChart label="Sessions" series={[]} empty="No sessions yet" />
      );

      await expect.element(screen.getByText('No sessions yet')).toBeInTheDocument();
      expect(screen.getByRole('table').query()).toBeNull();
    });
  });

  describe('colour', () => {
    it('takes the sequential ramp and not the categorical palette', async () => {
      const screen = await render(
        <HeatmapChart label="Sessions" categories={HOURS} series={TRAFFIC} />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      const used = fills(plot.element());

      expect(used.every((fill) => fill?.startsWith('var(--neba-chart-seq-'))).toBe(true);
      // A magnitude is one hue; the eight-slot ramp is for identity.
      expect(used.some((fill) => /--neba-chart-\d/.test(fill ?? ''))).toBe(false);
    });

    it('puts the smallest value on the palest step and the largest on the deepest', async () => {
      const screen = await render(
        <HeatmapChart label="Sessions" categories={['a', 'b']} series={[{ data: [0, 100] }]} />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      expect(fills(plot.element())).toEqual(['var(--neba-chart-seq-1)', 'var(--neba-chart-seq-5)']);
    });

    it('scales one ladder across every row rather than one per row', async () => {
      const screen = await render(
        <HeatmapChart
          label="Sessions"
          categories={['a', 'b']}
          series={[
            { name: 'Small', data: [0, 1] },
            { name: 'Large', data: [99, 100] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      // Per-row scaling would paint the small row's 1 as deeply as the large
      // row's 100, and a cell's colour would stop meaning a number.
      const [, small, , large] = fills(plot.element());

      expect(small).toBe('var(--neba-chart-seq-1)');
      expect(large).toBe('var(--neba-chart-seq-5)');
    });

    it('turns over at the midpoint with a diverging scale', async () => {
      const screen = await render(
        <HeatmapChart
          label="Against target"
          scale="diverging"
          categories={['a', 'b', 'c']}
          series={[{ data: [-10, 0, 10] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Against target' });

      await expect.element(plot).toBeInTheDocument();
      expect(fills(plot.element())).toEqual([
        'var(--neba-chart-div-1)',
        'var(--neba-chart-div-3)',
        'var(--neba-chart-div-5)'
      ]);
    });

    it('moves the turn when midpoint says so', async () => {
      const screen = await render(
        <HeatmapChart
          label="Against target"
          scale="diverging"
          midpoint={50}
          categories={['a', 'b', 'c']}
          series={[{ data: [0, 50, 100] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Against target' });

      await expect.element(plot).toBeInTheDocument();
      expect(fills(plot.element())[1]).toBe('var(--neba-chart-div-3)');
    });

    it('lets a cell keep a colour of its own', async () => {
      const screen = await render(
        <HeatmapChart
          label="Sessions"
          categories={['a', 'b']}
          series={[{ data: [1, { x: 'b', y: 2, color: 'danger' }] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      expect(fills(plot.element())[1]).toBe('var(--neba-danger-accent)');
    });
  });

  describe('the scale legend', () => {
    it('is a bar with its ends labelled, not a list of swatches', async () => {
      const screen = await render(
        <HeatmapChart label="Sessions" categories={['a', 'b']} series={[{ data: [4, 96] }]} />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      expect(legendText(plot.element())).toContain('4');
      expect(legendText(plot.element())).toContain('96');
      // Nothing to click: there is no series to filter, only a magnitude.
      expect(screen.getByRole('button').query()).toBeNull();
    });

    it('names the midpoint on a diverging scale', async () => {
      const screen = await render(
        <HeatmapChart
          label="Against target"
          scale="diverging"
          midpoint={20}
          categories={['a', 'b']}
          series={[{ data: [0, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Against target' });

      await expect.element(plot).toBeInTheDocument();
      expect(legendText(plot.element())).toContain('20');
    });

    it('can be turned off', async () => {
      const screen = await render(
        <HeatmapChart
          label="Sessions"
          legend={false}
          categories={['a', 'b']}
          series={[{ data: [4, 96] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      expect(legendText(plot.element())).not.toContain('96');
    });
  });

  describe('treemap', () => {
    it('draws a tile per datum, sized by its share', async () => {
      const screen = await render(
        <HeatmapChart
          label="Storage"
          shape="treemap"
          height={200}
          series={[
            {
              name: 'Platform',
              data: [
                { x: 'Builds', y: 300 },
                { x: 'Logs', y: 100 }
              ]
            }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Storage' });

      await expect.element(plot).toBeInTheDocument();

      const areas = cells(plot.element()).map(
        (rect) => Number(rect.getAttribute('width')) * Number(rect.getAttribute('height'))
      );

      expect(areas).toHaveLength(2);
      // Three times the value is three times the ink. The 2px gap on each side
      // makes it approximate, so the tolerance is generous rather than exact.
      expect(areas[0] / areas[1]).toBeGreaterThan(2.4);
      expect(areas[0] / areas[1]).toBeLessThan(3.6);
    });

    it('fills the box', async () => {
      const screen = await render(
        <HeatmapChart
          label="Storage"
          shape="treemap"
          height={200}
          series={[
            {
              name: 'Platform',
              data: [
                { x: 'a', y: 3 },
                { x: 'b', y: 2 },
                { x: 'c', y: 1 }
              ]
            }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Storage' });

      await expect.element(plot).toBeInTheDocument();

      const box = plot.element().getBoundingClientRect();
      const covered = cells(plot.element()).reduce(
        (sum, rect) =>
          sum + Number(rect.getAttribute('width')) * Number(rect.getAttribute('height')),
        0
      );

      expect(covered / (box.width * 200)).toBeGreaterThan(0.9);
    });

    it('names each tile after itself rather than after its group', async () => {
      const screen = await render(
        <HeatmapChart
          label="Storage"
          shape="treemap"
          height={220}
          series={[
            {
              name: 'Platform',
              data: [
                { x: 'Builds', y: 300 },
                { x: 'Logs', y: 200 }
              ]
            }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Storage' });

      await expect.element(plot).toBeInTheDocument();

      const written = texts(plot.element());

      expect(written).toContain('Builds');
      expect(written).toContain('Logs');
      expect(written).not.toContain('Platform');
    });

    it('keeps a negative out of the picture and in the table', async () => {
      const screen = await render(
        <HeatmapChart
          label="Storage"
          shape="treemap"
          height={200}
          series={[
            {
              name: 'Platform',
              data: [
                { x: 'a', y: 300 },
                { x: 'b', y: -50 }
              ]
            }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Storage' });

      await expect.element(plot).toBeInTheDocument();
      expect(cells(plot.element()).length).toBe(1);
      await expect.element(screen.getByRole('cell', { name: '-50' })).toBeInTheDocument();
    });
  });

  describe('valueLabels', () => {
    it('writes nothing on a grid cell by default', async () => {
      const screen = await render(
        <HeatmapChart label="Sessions" categories={HOURS} series={TRAFFIC} />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      expect(texts(plot.element())).not.toContain('40');
    });

    it('writes the value on every cell with all', async () => {
      const screen = await render(
        <HeatmapChart label="Sessions" valueLabels="all" categories={HOURS} series={TRAFFIC} />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      expect(texts(plot.element())).toContain('40');
    });
  });

  describe('the table', () => {
    it('is the grid, with the rows and the columns named', async () => {
      const screen = await render(
        <HeatmapChart label="Sessions" categories={HOURS} series={TRAFFIC} />
      );

      const table = screen.getByRole('table', { name: 'Sessions' });

      await expect.element(table).toBeInTheDocument();
      await expect.element(screen.getByRole('rowheader', { name: 'Tue' })).toBeInTheDocument();
      await expect.element(screen.getByRole('columnheader', { name: '18' })).toBeInTheDocument();
      await expect.element(screen.getByRole('cell', { name: '48' })).toBeInTheDocument();
    });
  });

  describe('tooltip', () => {
    it('names both coordinates of the cell under the pointer', async () => {
      const screen = await render(
        <HeatmapChart label="Sessions" height={200} categories={HOURS} series={TRAFFIC} />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      // Row-major, four columns a row: the ninth is the third row's first cell.
      const cell = cells(plot.element())[8];

      await plot.hover({
        position: {
          x: Number(cell.getAttribute('x')) + Number(cell.getAttribute('width')) / 2,
          y: Number(cell.getAttribute('y')) + Number(cell.getAttribute('height')) / 2
        }
      });

      const status = screen.getByRole('status');

      await expect.element(status).toBeInTheDocument();
      expect(status.element().textContent).toContain('Wed');
      expect(status.element().textContent).toContain('00');
    });

    it('is not reachable when it is turned off', async () => {
      const screen = await render(
        <HeatmapChart
          label="Sessions"
          height={200}
          tooltip={false}
          categories={HOURS}
          series={TRAFFIC}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      const cell = cells(plot.element())[0];

      await plot.hover({
        position: {
          x: Number(cell.getAttribute('x')) + 4,
          y: Number(cell.getAttribute('y')) + 4
        }
      });

      expect(screen.getByRole('status').query()).toBeNull();
    });
  });
});
