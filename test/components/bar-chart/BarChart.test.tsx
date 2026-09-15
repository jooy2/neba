import { describe, expect, it } from 'vitest';
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
