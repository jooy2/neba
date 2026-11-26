import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { BarChart, NebaProvider } from 'neba';

const TEAMS = ['Platform', 'Payments', 'Growth'];

describe('BarChart', () => {
  describe('rendering', () => {
    it('draws one filled path per value', async () => {
      const screen = await render(
        <BarChart
          label="Deploys per team"
          categories={TEAMS}
          series={[{ name: 'Deploys', data: [10, 20, 30] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Deploys per team' });

      await expect.element(plot).toBeInTheDocument();
      expect(plot.element().querySelectorAll('path[fill]:not([fill="none"])').length).toBe(3);
    });

    it('draws nothing for a gap', async () => {
      const screen = await render(
        <BarChart
          label="Deploys"
          categories={TEAMS}
          series={[{ name: 'Deploys', data: [10, null, 30] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Deploys' });

      await expect.element(plot).toBeInTheDocument();
      expect(plot.element().querySelectorAll('path[fill]:not([fill="none"])').length).toBe(2);
    });

    it('writes its data into a table', async () => {
      const screen = await render(
        <BarChart
          label="Deploys per team"
          categories={TEAMS}
          series={[{ name: 'Deploys', data: [10, 20, 30] }]}
        />
      );

      await expect
        .element(screen.getByRole('table', { name: 'Deploys per team' }))
        .toBeInTheDocument();
      await expect.element(screen.getByRole('rowheader', { name: 'Payments' })).toBeInTheDocument();
    });

    it('reflects a changed orientation on re-render', async () => {
      const screen = await render(
        <BarChart
          label="Deploys"
          categories={TEAMS}
          series={[{ name: 'Deploys', data: [1, 2, 3] }]}
        />
      );

      await expect.element(screen.getByRole('img', { name: 'Deploys' })).toBeInTheDocument();

      await screen.rerender(
        <BarChart
          label="Deploys"
          orientation="horizontal"
          categories={TEAMS}
          series={[{ name: 'Deploys', data: [1, 2, 3] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Deploys' });

      await expect.element(plot).toBeInTheDocument();
      expect(plot.element().querySelectorAll('path[fill]:not([fill="none"])').length).toBe(3);
    });
  });

  describe('axes', () => {
    it("writes a horizontal chart's category axis name above the plot", async () => {
      const screen = await render(
        <BarChart
          label="Deploys"
          orientation="horizontal"
          xAxis={{ label: 'Team' }}
          categories={TEAMS}
          series={[{ name: 'Deploys', data: [1, 2, 3] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Deploys' });
      const texts = () => [...plot.element().querySelectorAll('text')];

      await expect.poll(() => texts().some((text) => text.textContent === 'Team')).toBe(true);

      const svg = plot.element().querySelector('svg')!.getBoundingClientRect();
      const name = texts()
        .find((text) => text.textContent === 'Team')!
        .getBoundingClientRect();
      const rows = texts()
        .filter((text) => TEAMS.includes(text.textContent ?? ''))
        .map((text) => text.getBoundingClientRect());

      expect(name.top).toBeGreaterThanOrEqual(svg.top);
      expect(rows).toHaveLength(3);
      expect(Math.min(...rows.map((row) => row.top))).toBeGreaterThanOrEqual(name.bottom);
    });
  });

  describe('valueLabels', () => {
    it('writes nothing on the bars by default', async () => {
      const screen = await render(
        <BarChart
          label="Deploys"
          categories={TEAMS}
          series={[{ name: 'Deploys', data: [11, 22, 33] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Deploys' });

      await expect.element(plot).toBeInTheDocument();
      expect([...plot.element().querySelectorAll('text')].map((t) => t.textContent)).not.toContain(
        '11'
      );
    });

    // Only the final category was labelled, and a series whose final value is a
    // gap had no label anywhere.
    it('labels the last value there is when the series ends in a gap', async () => {
      const screen = await render(
        <BarChart
          label="Deploys"
          valueLabels="last"
          categories={TEAMS}
          series={[{ name: 'Deploys', data: [37, 41, null] }]}
        />
      );
      const plot = screen.getByRole('img', { name: 'Deploys' });

      await expect.poll(() => plot.element().querySelectorAll('path').length).toBeGreaterThan(0);

      const written = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(written).toContain('41');
      expect(written).not.toContain('37');
    });

    it('writes every value with all', async () => {
      const screen = await render(
        <BarChart
          label="Deploys"
          valueLabels="all"
          categories={TEAMS}
          series={[{ name: 'Deploys', data: [11, 22, 33] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Deploys' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).toContain('11');
      expect(texts).toContain('22');
      expect(texts).toContain('33');
    });

    it('writes only the high and the low with extremes', async () => {
      const screen = await render(
        <BarChart
          label="Deploys"
          valueLabels="extremes"
          categories={TEAMS}
          series={[{ name: 'Deploys', data: [11, 22, 33] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Deploys' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).toContain('11');
      expect(texts).toContain('33');
      expect(texts).not.toContain('22');
    });

    // On a grouped chart the label sits over the gap between two bands, so the
    // hue is what says which of the two it belongs to.
    it("writes a label in its own bar's colour rather than in the page ink", async () => {
      const screen = await render(
        <BarChart
          label="Deploys"
          valueLabels="all"
          categories={TEAMS}
          series={[
            { name: 'Web', data: [11, 22, 33], color: 'oklch(60% 0.2 262)' },
            { name: 'Mobile', data: [13, 24, 35], color: 'oklch(60% 0.2 30)' }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Deploys' });

      await expect.element(plot).toBeInTheDocument();

      const fillOf = (text: string) =>
        [...plot.element().querySelectorAll('text')]
          .find((node) => node.textContent === text)
          ?.getAttribute('fill');

      expect(fillOf('11')).toBe('color-mix(in oklab, oklch(60% 0.2 262) 85%, var(--neba-fg))');
      expect(fillOf('13')).toBe('color-mix(in oklab, oklch(60% 0.2 30) 85%, var(--neba-fg))');
    });

    it("takes a single point's own colour over its series'", async () => {
      const screen = await render(
        <BarChart
          label="Deploys"
          valueLabels="all"
          categories={TEAMS}
          series={[
            {
              name: 'Web',
              color: 'oklch(60% 0.2 262)',
              data: [11, { y: 22, color: 'oklch(60% 0.2 30)' }, 33]
            }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Deploys' });

      await expect.element(plot).toBeInTheDocument();

      const marked = [...plot.element().querySelectorAll('text')].find(
        (node) => node.textContent === '22'
      );

      expect(marked?.getAttribute('fill')).toContain('oklch(60% 0.2 30)');
    });

    it('writes a bar on the far edge through that axis', async () => {
      const screen = await render(
        <BarChart
          label="Deploys"
          valueLabels="all"
          categories={TEAMS}
          format={{ style: 'currency', currency: 'USD', maximumFractionDigits: 0 }}
          secondaryAxis={{ tickFormat: (value) => `${value}%` }}
          series={[
            { name: 'Cost', data: [1000, 1200, 1400] },
            { name: 'Failure rate', data: [2, 3.7, 2.5], axis: 'secondary' }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Deploys' });

      await expect.element(plot).toBeInTheDocument();

      const written = [...plot.element().querySelectorAll('text')].map((node) => node.textContent);

      expect(written).toContain('3.7%');
      expect(written).toContain('$1,200');
    });
  });

  describe('references', () => {
    // A bar's column is a band, and the plot reaches half an index past the
    // first and last centres. A band shading a whole column was cut at the
    // centre as though the chart were a line.
    it('reaches a whole column with a band on the category axis', async () => {
      const screen = await render(
        <BarChart
          label="Deploys"
          categories={TEAMS}
          references={[{ value: -0.5, to: 0.5, axis: 'category' }]}
          series={[{ name: 'Deploys', data: [10, 20, 30] }]}
        />
      );
      const plot = screen.getByRole('img', { name: 'Deploys' });

      await expect.element(plot).toBeInTheDocument();
      expect(
        [...plot.element().querySelectorAll('line')].filter((node) =>
          node.getAttribute('stroke-dasharray')
        )
      ).toHaveLength(2);
    });
  });

  describe('stacked', () => {
    it('keeps the caller’s own numbers in the table when stacking to full', async () => {
      const screen = await render(
        <BarChart
          label="Mix"
          stacked="full"
          categories={['Jan']}
          series={[
            { name: 'New', data: [40] },
            { name: 'Renewed', data: [160] }
          ]}
        />
      );

      const table = screen.getByRole('table', { name: 'Mix' });

      await expect.element(table).toBeInTheDocument();

      // The bars are drawn as 20% and 80%; the table still says 40 and 160,
      // which is what the caller actually has.
      const cells = [...table.element().querySelectorAll('tbody td')].map((cell) =>
        cell.textContent?.trim()
      );

      expect(cells).toEqual(['40', '160']);
    });

    // The original went through `String()`, so a table of money read `1234.5678`.
    it("writes the caller's numbers through format when stacking to full", async () => {
      const screen = await render(
        <BarChart
          label="Mix"
          stacked="full"
          format={{ maximumFractionDigits: 0 }}
          categories={['Jan']}
          series={[
            { name: 'New', data: [1234.5678] },
            { name: 'Renewed', data: [100] }
          ]}
        />
      );

      const table = screen.getByRole('table', { name: 'Mix' });

      await expect.element(table).toBeInTheDocument();

      const cells = [...table.element().querySelectorAll('tbody td')].map((cell) =>
        cell.textContent?.trim()
      );

      expect(cells).toEqual(['1,235', '100']);
    });

    // A hidden series still counted towards the hundred, so the bars that were
    // left stopped short of the top.
    it('shares the hundred between the series still shown', async () => {
      const screen = await render(
        <BarChart
          label="Mix"
          stacked="full"
          height={200}
          categories={['Jan']}
          series={[
            { name: 'New', data: [1] },
            { name: 'Renewed', data: [3] }
          ]}
        />
      );
      const plot = screen.getByRole('img', { name: 'Mix' });
      const bar = () =>
        plot.element().querySelector('path[fill="var(--neba-chart-1)"]') as SVGPathElement | null;

      await expect.poll(() => bar()?.getBoundingClientRect().height ?? 0).toBeGreaterThan(0);

      const quarter = bar()!.getBoundingClientRect().height;

      await screen.getByRole('button', { name: 'Renewed' }).click();

      await expect
        .poll(() => (bar()?.getBoundingClientRect().height ?? 0) / quarter)
        .toBeGreaterThan(3.5);
    });

    // The file held the shares the bars are drawn at, worked out against the
    // series that were shown, so hiding one rewrote the numbers of the rest.
    it("exports the caller's numbers when stacking to full, whatever is hidden", async () => {
      const onExport = vi.fn();
      const screen = await render(
        <BarChart
          label="Mix"
          stacked="full"
          exportable
          onExport={onExport}
          categories={['Jan']}
          series={[
            { name: 'New', data: [20] },
            { name: 'Renewed', data: [60] }
          ]}
        />
      );
      const exported = async (calls: number) => {
        await screen.getByRole('button', { name: 'Export CSV' }).click();
        await expect.poll(() => onExport.mock.calls.length).toBe(calls);

        return (onExport.mock.calls[calls - 1][0] as string).replace('\uFEFF', '').split('\r\n')[1];
      };

      expect(await exported(1)).toBe('Jan,20,60');

      await screen.getByRole('button', { name: 'Renewed' }).click();

      expect(await exported(2)).toBe('Jan,20,60');
    });

    it('puts the percentage on the value axis in either orientation', async () => {
      const mix = (orientation: 'vertical' | 'horizontal') => (
        <BarChart
          label="Mix"
          stacked="full"
          orientation={orientation}
          categories={['Seoul', 'Tokyo']}
          series={[
            { name: 'New', data: [1, 2] },
            { name: 'Renewed', data: [3, 4] }
          ]}
        />
      );

      const screen = await render(mix('vertical'));
      const plot = screen.getByRole('img', { name: 'Mix' });

      const texts = async () => {
        await expect.element(plot).toBeInTheDocument();

        return [...plot.element().querySelectorAll('text')].map((t) => t.textContent);
      };

      expect(await texts()).toContain('100%');

      await screen.rerender(mix('horizontal'));

      // Still on the value axis, and nowhere near the category names. `xAxis`
      // is the category axis and `yAxis` the value axis whichever way the bars
      // run, so turning the chart on its side must not send the tick format to
      // the other one.
      const turned = await texts();

      expect(turned).toContain('100%');
      expect(turned).toContain('Seoul');
      expect(turned).not.toContain('Seoul%');
    });

    // Each series was measured at its own value, so two segments of 10 were
    // both "at 10" and the first always won, whichever one the pointer was on.
    it('narrows mode="item" to the segment under the pointer', async () => {
      const chart = (orientation: 'vertical' | 'horizontal') => (
        <BarChart
          label="Deploys"
          stacked
          orientation={orientation}
          height={200}
          tooltip={{ mode: 'item' }}
          categories={['Platform']}
          series={[
            { name: 'Manual', data: [10] },
            { name: 'Scheduled', data: [10] }
          ]}
        />
      );
      const screen = await render(chart('vertical'));
      const plot = screen.getByRole('img', { name: 'Deploys' });

      await expect.element(plot).toBeInTheDocument();

      /** Hovers the middle of the nth segment and reads which series is named. */
      const nameAt = async (segment: number) => {
        const bars = [...plot.element().querySelectorAll('path[fill]:not([fill="none"])')];
        const box = bars[segment].getBoundingClientRect();
        const origin = plot.element().getBoundingClientRect();

        await plot.hover({
          position: {
            x: box.left - origin.left + box.width / 2,
            y: box.top - origin.top + box.height / 2
          }
        });

        const status = screen.getByRole('status');

        await expect.element(status).toBeInTheDocument();

        return status.element().textContent ?? '';
      };

      expect(await nameAt(1)).toContain('Scheduled');
      expect(await nameAt(0)).toContain('Manual');

      await screen.rerender(chart('horizontal'));

      expect(await nameAt(1)).toContain('Scheduled');
      expect(await nameAt(0)).toContain('Manual');
    });
  });

  describe('the highlight', () => {
    /**
     * Two states, one sentence at two scales: a whole series drops to 0.28 when
     * the legend is pointed at another, and a single bar sits at 0.92 until the
     * crosshair reaches it. Only the pie and the heatmap ever faded either of
     * them; everywhere else the picture snapped between two states on the frame
     * the pointer crossed something.
     */
    it('fades both the series and the bar under the crosshair', async () => {
      const screen = await render(
        <BarChart
          label="Deploys per team"
          categories={TEAMS}
          series={[
            { name: 'Deploys', data: [10, 20, 30] },
            { name: 'Rollbacks', data: [1, 2, 3] }
          ]}
        />
      );

      await expect.element(screen.getByRole('button', { name: 'Deploys' })).toBeInTheDocument();

      const series = screen.container.querySelector('svg g[opacity]') as SVGGElement;
      const bar = series.querySelector('path') as SVGPathElement;

      expect(series.getAttribute('class')).toContain('transition:opacity');
      expect(bar.getAttribute('class')).toContain('transition:opacity');
    });
  });

  describe('the crosshair', () => {
    // Every bar was laid out again, and every label on it written again, each
    // time the crosshair moved from one column to the next.
    it('writes no bar again as it moves from one column to the next', async () => {
      const categories = Array.from({ length: 24 }, (_, index) => `C${index}`);
      const screen = await render(
        <BarChart
          label="Deploys"
          height={240}
          valueLabels="all"
          categories={categories}
          series={[
            { name: 'Deploys', data: categories.map((_, index) => index + 1) },
            { name: 'Rollbacks', data: categories.map((_, index) => index + 30) }
          ]}
        />
      );
      const plot = screen.getByRole('img', { name: 'Deploys' });
      const status = screen.getByRole('status');

      await expect.element(plot).toBeInTheDocument();

      const width = plot.element().getBoundingClientRect().width;

      await plot.hover({ position: { x: width * 0.2, y: 120 } });
      await expect.element(status).not.toBeEmptyDOMElement();

      const before = status.element().textContent;
      // `format` is a getter that hands back a bound function, so each number
      // the chart writes is one read of it.
      const formats = vi.spyOn(Intl.NumberFormat.prototype as { format: unknown }, 'format', 'get');

      try {
        await plot.hover({ position: { x: width * 0.7, y: 120 } });
        await expect.poll(() => status.element().textContent).not.toBe(before);

        // The two numbers the new column is read out with, and no more: the
        // forty-eight labels on the bars written again would be forty-eight.
        expect(formats.mock.calls.length).toBeLessThan(10);
      } finally {
        formats.mockRestore();
      }
    });

    // `item` mode stored the pointer's offset on every move, so a pointer
    // travelling up one segment drew the whole chart again for every pixel. It
    // stores the series it is nearest now, which has to stay the same one.
    it('names the same series as the pointer travels along one segment in mode="item"', async () => {
      const screen = await render(
        <BarChart
          label="Deploys"
          stacked
          height={240}
          tooltip={{ mode: 'item' }}
          categories={['Platform']}
          series={[
            { name: 'Manual', data: [90] },
            { name: 'Scheduled', data: [10] }
          ]}
        />
      );
      const plot = screen.getByRole('img', { name: 'Deploys' });
      const status = screen.getByRole('status');

      await expect.element(plot).toBeInTheDocument();

      const bars = [...plot.element().querySelectorAll('path[fill]:not([fill="none"])')];
      const box = bars[0].getBoundingClientRect();
      const origin = plot.element().getBoundingClientRect();
      const x = box.left - origin.left + box.width / 2;

      for (const y of [0.2, 0.5, 0.8]) {
        await plot.hover({ position: { x, y: box.top - origin.top + box.height * y } });
        await expect.element(status).toMatchTextContent('Manual');
      }
    });
  });

  // A negative segment grows down from zero while the positive ones grow up, so
  // it neither eats into the stack above the axis nor moves where it starts.
  describe('stacking values of both signs', () => {
    it('stacks a negative series down from zero and the positive ones on each other', async () => {
      const screen = await render(
        <BarChart
          label="Flow"
          stacked
          height={240}
          categories={['Jan']}
          series={[
            { name: 'In', data: [10] },
            { name: 'Out', data: [-5] },
            { name: 'More in', data: [10] }
          ]}
        />
      );
      const plot = screen.getByRole('img', { name: 'Flow' });
      const box = (slot: number) =>
        plot
          .element()
          .querySelector(`path[fill="var(--neba-chart-${slot})"]`)
          ?.getBoundingClientRect();

      await expect.poll(() => box(1)?.height ?? 0).toBeGreaterThan(0);

      const [first, negative, top] = [box(1)!, box(2)!, box(3)!];

      expect(negative.top).toBeGreaterThanOrEqual(first.bottom - 1);
      expect(top.bottom).toBeLessThanOrEqual(first.top + 1);
      expect(negative.height / first.height).toBeCloseTo(0.5, 1);
    });
  });

  describe('under a provider', () => {
    it('takes its size and its locale from the provider', async () => {
      const chart = (label: string, size?: 'xs') => (
        <BarChart
          label={label}
          size={size}
          categories={['Jan']}
          series={[{ name: 'Revenue', data: [1234.5] }]}
        />
      );
      const screen = await render(
        <div>
          <NebaProvider defaults={{ size: 'xs', locale: 'de-DE' }}>
            {chart('Provided')}
          </NebaProvider>
          {chart('Given', 'xs')}
          {chart('Default')}
        </div>
      );
      const height = (label: string) =>
        screen.getByRole('img', { name: label }).element().getBoundingClientRect().height;
      const table = screen.getByRole('table', { name: 'Provided' });

      await expect.element(table).toBeInTheDocument();

      expect(height('Provided')).toBe(height('Given'));
      expect(height('Provided')).not.toBe(height('Default'));
      expect(table.element().querySelector('tbody td')?.textContent?.trim()).toBe('1.234,5');
    });
  });
});
