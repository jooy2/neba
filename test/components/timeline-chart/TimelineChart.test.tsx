import { describe, expect, it } from 'vitest';
import { TimelineChart } from 'neba';
import { render } from 'vitest-browser-react';

const at = (iso: string) => new Date(iso);

/** Two rows, three spans, all inside one quarter. */
const PLAN = [
  {
    name: 'Design',
    data: [
      { start: at('2026-03-02T00:00:00'), end: at('2026-03-16T00:00:00'), label: 'Wireframes' },
      { start: at('2026-03-16T00:00:00'), end: at('2026-04-06T00:00:00'), label: 'Visual' }
    ]
  },
  {
    name: 'Build',
    data: [{ start: at('2026-04-06T00:00:00'), end: at('2026-05-18T00:00:00'), label: 'API' }]
  }
];

const bars = (plot: Element) => [...plot.querySelectorAll('rect')];

/**
 * A chart is measured before it draws, so nothing reaches the DOM until the
 * host element has a width — `expect.element` retries, which is what makes
 * these assertions stable.
 */
describe('TimelineChart', () => {
  describe('rendering', () => {
    it('exposes the plot as an image with its label', async () => {
      const screen = await render(<TimelineChart label="Release plan" series={PLAN} />);

      await expect.element(screen.getByRole('img', { name: 'Release plan' })).toBeInTheDocument();
    });

    it('draws one bar per span', async () => {
      const screen = await render(<TimelineChart label="Plan" series={PLAN} />);

      const plot = screen.getByRole('img', { name: 'Plan' });

      await expect.element(plot).toBeInTheDocument();
      expect(bars(plot.element()).length).toBe(3);
    });

    it('starts each bar at its own date rather than at a baseline', async () => {
      const screen = await render(
        <TimelineChart
          label="Plan"
          min={at('2026-03-01T00:00:00')}
          max={at('2026-05-01T00:00:00')}
          series={[
            {
              name: 'Row',
              data: [
                { start: at('2026-03-01T00:00:00'), end: at('2026-03-15T00:00:00') },
                { start: at('2026-04-01T00:00:00'), end: at('2026-04-15T00:00:00') }
              ]
            }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Plan' });

      await expect.element(plot).toBeInTheDocument();

      const [first, second] = bars(plot.element()).map((rect) => ({
        x: Number(rect.getAttribute('x')),
        width: Number(rect.getAttribute('width'))
      }));

      // The second span is a month later and the same fortnight long, so it is
      // to the right of the first and no wider. A chart growing both from a
      // shared baseline would make the second one twice the length.
      expect(second.x).toBeGreaterThan(first.x + first.width);
      expect(second.width).toBeCloseTo(first.width, 0);
    });

    it('draws a backwards span the right way round', async () => {
      const screen = await render(
        <TimelineChart
          label="Plan"
          series={[
            {
              name: 'Row',
              data: [{ start: at('2026-03-15T00:00:00'), end: at('2026-03-01T00:00:00') }]
            }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Plan' });

      await expect.element(plot).toBeInTheDocument();
      expect(Number(bars(plot.element())[0].getAttribute('width'))).toBeGreaterThan(1);
    });

    it('reflects a changed series on re-render', async () => {
      const screen = await render(<TimelineChart label="Plan" series={PLAN} />);

      await expect.element(screen.getByRole('rowheader', { name: 'Build' })).toBeInTheDocument();

      await screen.rerender(<TimelineChart label="Plan" series={[{ ...PLAN[1], name: 'Ship' }]} />);

      await expect.element(screen.getByRole('rowheader', { name: 'Ship' })).toBeInTheDocument();
      expect(screen.getByRole('rowheader', { name: 'Build' }).query()).toBeNull();
    });

    it('shows the empty state when no row has a span', async () => {
      const screen = await render(
        <TimelineChart
          label="Plan"
          empty="Nothing scheduled"
          series={[{ name: 'Design', data: [] }]}
        />
      );

      await expect.element(screen.getByText('Nothing scheduled')).toBeInTheDocument();
      expect(screen.getByRole('table').query()).toBeNull();
    });

    it('resolves a colour family on a span', async () => {
      const screen = await render(
        <TimelineChart
          label="Plan"
          series={[
            {
              name: 'Row',
              data: [
                {
                  start: at('2026-03-01T00:00:00'),
                  end: at('2026-03-15T00:00:00'),
                  color: 'success'
                }
              ]
            }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Plan' });

      await expect.element(plot).toBeInTheDocument();
      // Not the literal word, which an SVG renders as black.
      expect(bars(plot.element())[0].getAttribute('fill')).toBe('var(--neba-success-accent)');
    });

    it('gives overlapping spans a lane each rather than stacking them', async () => {
      const screen = await render(
        <TimelineChart
          label="Plan"
          height={200}
          series={[
            {
              name: 'Row',
              data: [
                { start: at('2026-03-01T00:00:00'), end: at('2026-03-20T00:00:00') },
                { start: at('2026-03-10T00:00:00'), end: at('2026-03-30T00:00:00') }
              ]
            }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Plan' });

      await expect.element(plot).toBeInTheDocument();

      const [first, second] = bars(plot.element()).map((rect) => ({
        y: Number(rect.getAttribute('y')),
        height: Number(rect.getAttribute('height'))
      }));

      // Two lanes: they do not sit at the same height, and neither covers the
      // other. Drawn on top of each other, two facts become one smudge.
      expect(second.y).toBeGreaterThanOrEqual(first.y + first.height);
    });

    it('leaves a row whose spans do not overlap in one lane', async () => {
      const screen = await render(
        <TimelineChart
          label="Plan"
          height={200}
          series={[
            {
              name: 'Row',
              data: [
                { start: at('2026-03-01T00:00:00'), end: at('2026-03-10T00:00:00') },
                { start: at('2026-03-10T00:00:00'), end: at('2026-03-20T00:00:00') }
              ]
            }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Plan' });

      await expect.element(plot).toBeInTheDocument();

      const [first, second] = bars(plot.element()).map((rect) => ({
        y: Number(rect.getAttribute('y')),
        height: Number(rect.getAttribute('height'))
      }));

      expect(second.y).toBe(first.y);
      expect(second.height).toBe(first.height);
    });

    it('shows no legend — the rows are the axis', async () => {
      const screen = await render(<TimelineChart label="Plan" series={PLAN} />);

      await expect.element(screen.getByRole('img', { name: 'Plan' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Design' }).query()).toBeNull();
    });
  });

  describe('the time axis', () => {
    it('ticks where a calendar ticks, not on a 1-2-5 step', async () => {
      const screen = await render(
        <TimelineChart
          label="Plan"
          locale="en-GB"
          min={at('2026-01-01T00:00:00')}
          max={at('2026-07-01T00:00:00')}
          series={PLAN}
        />
      );

      const plot = screen.getByRole('img', { name: 'Plan' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      // Month starts, with the year named once — an axis inside one year needs
      // it on the first tick and nowhere else. And nothing anywhere that is a
      // raw count of milliseconds, which is what a 1-2-5 step would produce.
      expect(texts).toContain('Jan 2026');
      expect(texts.filter((text) => text?.includes('2026')).length).toBe(1);
      expect(texts.some((text) => /^[\d,]{10,}$/.test(text ?? ''))).toBe(false);
    });

    it('names the year on every tick once the axis crosses one', async () => {
      const screen = await render(
        <TimelineChart
          label="Plan"
          locale="en-GB"
          min={at('2025-10-01T00:00:00')}
          max={at('2026-04-01T00:00:00')}
          series={PLAN}
        />
      );

      const plot = screen.getByRole('img', { name: 'Plan' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      const dates = texts.filter((text) => /\b(Oct|Nov|Dec|Jan|Feb|Mar|Apr)\b/.test(text ?? ''));

      // Whichever of them the stride keeps, each one says which year it is in.
      expect(dates.length).toBeGreaterThan(1);
      expect(dates.every((text) => /20\d{2}/.test(text ?? ''))).toBe(true);
      expect(texts).toContain('Oct 2025');
    });

    it('names the rows down the side', async () => {
      const screen = await render(<TimelineChart label="Plan" series={PLAN} />);

      const plot = screen.getByRole('img', { name: 'Plan' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).toContain('Design');
      expect(texts).toContain('Build');
    });

    it('takes a tickFormat of its own on yAxis, the value axis', async () => {
      const screen = await render(
        <TimelineChart
          label="Plan"
          min={at('2026-01-01T00:00:00')}
          max={at('2026-07-01T00:00:00')}
          yAxis={{ tickFormat: (value) => `w${new Date(Number(value)).getMonth() + 1}` }}
          series={PLAN}
        />
      );

      const plot = screen.getByRole('img', { name: 'Plan' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).toContain('w1');
      expect(texts).not.toContain('Jan 2026');
    });
  });

  describe('the table', () => {
    it('gives every span a row of its own, under its row name', async () => {
      const screen = await render(<TimelineChart label="Plan" locale="en-GB" series={PLAN} />);

      const table = screen.getByRole('table', { name: 'Plan' });

      await expect.element(table).toBeInTheDocument();
      expect(table.element().querySelectorAll('tbody tr').length).toBe(3);
      await expect.element(screen.getByRole('columnheader', { name: 'start' })).toBeInTheDocument();
      await expect.element(screen.getByRole('cell', { name: 'Wireframes' })).toBeInTheDocument();
    });

    it('drops the label column when no span carries one', async () => {
      const screen = await render(
        <TimelineChart
          label="Plan"
          series={[
            {
              name: 'Row',
              data: [{ start: at('2026-03-01T00:00:00'), end: at('2026-03-15T00:00:00') }]
            }
          ]}
        />
      );

      await expect.element(screen.getByRole('columnheader', { name: 'end' })).toBeInTheDocument();
      expect(screen.getByRole('columnheader', { name: 'label' }).query()).toBeNull();
    });
  });

  describe('tooltip', () => {
    it('names the span the pointer is on, and its dates', async () => {
      const screen = await render(
        <TimelineChart label="Plan" locale="en-GB" height={200} series={PLAN} />
      );

      const plot = screen.getByRole('img', { name: 'Plan' });

      await expect.element(plot).toBeInTheDocument();

      const first = bars(plot.element())[0];
      const box = {
        x: Number(first.getAttribute('x')) + Number(first.getAttribute('width')) / 2,
        y: Number(first.getAttribute('y')) + Number(first.getAttribute('height')) / 2
      };

      await plot.hover({ position: box });

      const status = screen.getByRole('status');

      await expect.element(status).toBeInTheDocument();
      expect(status.element().textContent).toContain('Wireframes');
      expect(status.element().textContent).toContain('Design');
      expect(status.element().textContent).toContain('–');
    });

    it('picks the span the pointer is inside, not the one with the nearer centre', async () => {
      const screen = await render(
        <TimelineChart
          label="Plan"
          height={160}
          min={at('2026-01-01T00:00:00')}
          max={at('2026-12-31T00:00:00')}
          series={[
            {
              name: 'Row',
              data: [
                // A long span, and a short one just past its right-hand end.
                {
                  start: at('2026-01-05T00:00:00'),
                  end: at('2026-08-01T00:00:00'),
                  label: 'Long'
                },
                {
                  start: at('2026-08-20T00:00:00'),
                  end: at('2026-09-01T00:00:00'),
                  label: 'Short'
                }
              ]
            }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Plan' });

      await expect.element(plot).toBeInTheDocument();

      const [long] = bars(plot.element());
      // Just inside the long bar's right-hand end, which is far from its own
      // centre and close to the short bar's.
      const spot = {
        x: Number(long.getAttribute('x')) + Number(long.getAttribute('width')) - 4,
        y: Number(long.getAttribute('y')) + Number(long.getAttribute('height')) / 2
      };

      await plot.hover({ position: spot });

      const status = screen.getByRole('status');

      await expect.element(status).toBeInTheDocument();
      expect(status.element().textContent).toContain('Long');
      expect(status.element().textContent).not.toContain('Short');
    });

    it('is not reachable when it is turned off', async () => {
      const screen = await render(
        <TimelineChart label="Plan" height={200} tooltip={false} series={PLAN} />
      );

      const plot = screen.getByRole('img', { name: 'Plan' });

      await expect.element(plot).toBeInTheDocument();

      const first = bars(plot.element())[0];

      await plot.hover({
        position: {
          x: Number(first.getAttribute('x')) + 4,
          y: Number(first.getAttribute('y')) + 4
        }
      });

      expect(screen.getByRole('status').query()).toBeNull();
    });
  });
});
