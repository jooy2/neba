import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AreaChart } from 'neba';

const MONTHS = ['Jan', 'Feb', 'Mar'];

describe('AreaChart', () => {
  describe('rendering', () => {
    it('fills under each series as well as drawing it', async () => {
      const screen = await render(
        <AreaChart
          label="Storage"
          categories={MONTHS}
          series={[{ name: 'Hot', data: [10, 20, 30] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Storage' });

      await expect.element(plot).toBeInTheDocument();
      // One filled path and one stroked one — the wash and the edge.
      expect(plot.element().querySelectorAll('path[fill^="url("]').length).toBe(1);
      expect(plot.element().querySelectorAll('path[stroke]:not([stroke="none"])').length).toBe(1);
    });

    it('writes its data into a table', async () => {
      const screen = await render(
        <AreaChart
          label="Storage by tier"
          categories={MONTHS}
          series={[{ name: 'Hot', data: [10, 20, 30] }]}
        />
      );

      await expect
        .element(screen.getByRole('table', { name: 'Storage by tier' }))
        .toBeInTheDocument();
      await expect.element(screen.getByRole('cell', { name: '20' })).toBeInTheDocument();
    });

    it('reflects a changed curve on re-render', async () => {
      const screen = await render(
        <AreaChart
          label="Storage"
          categories={MONTHS}
          series={[{ name: 'Hot', data: [1, 2, 3] }]}
        />
      );

      const before = screen
        .getByRole('img', { name: 'Storage' })
        .element()
        .querySelector('path[fill^="url("]')
        ?.getAttribute('d');

      await screen.rerender(
        <AreaChart
          label="Storage"
          curve="smooth"
          categories={MONTHS}
          series={[{ name: 'Hot', data: [1, 2, 3] }]}
        />
      );

      const after = screen
        .getByRole('img', { name: 'Storage' })
        .element()
        .querySelector('path[fill^="url("]')
        ?.getAttribute('d');

      expect(after).not.toBe(before);
      expect(after).toContain('C');
    });
  });

  describe('nulls', () => {
    const WITH_GAP = [1, null, 3];

    it('breaks the band at a gap by default', async () => {
      const screen = await render(
        <AreaChart label="Storage" categories={MONTHS} series={[{ name: 'Hot', data: WITH_GAP }]} />
      );

      const plot = screen.getByRole('img', { name: 'Storage' });

      await expect.element(plot).toBeInTheDocument();

      const fill = plot.element().querySelector('path[fill^="url("]')?.getAttribute('d');

      expect((fill?.match(/M/g) ?? []).length).toBeGreaterThan(1);
    });

    it('closes the band across a gap with connect', async () => {
      const screen = await render(
        <AreaChart
          label="Storage"
          categories={MONTHS}
          nulls="connect"
          series={[{ name: 'Hot', data: WITH_GAP }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Storage' });

      await expect.element(plot).toBeInTheDocument();

      const fill = plot.element().querySelector('path[fill^="url("]')?.getAttribute('d');

      expect((fill?.match(/M/g) ?? []).length).toBe(1);
    });

    // A stacked band that breaks takes the bands above it with it, which is
    // why `zero` is usually what a caller of one actually meant.
    it('reads the gap as a nought everywhere with zero', async () => {
      const screen = await render(
        <AreaChart
          label="Storage used"
          categories={MONTHS}
          nulls="zero"
          series={[{ name: 'Hot', data: WITH_GAP }]}
        />
      );

      const table = screen.getByRole('table', { name: 'Storage used' });

      await expect.element(table).toBeInTheDocument();
      expect([...table.element().querySelectorAll('td')].map((cell) => cell.textContent)).toContain(
        '0'
      );
    });

    it('still answers to the old connectNulls spelling', async () => {
      const screen = await render(
        <AreaChart
          label="Storage"
          categories={MONTHS}
          connectNulls
          series={[{ name: 'Hot', data: WITH_GAP }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Storage' });

      await expect.element(plot).toBeInTheDocument();
      expect(
        (plot.element().querySelector('path[fill^="url("]')?.getAttribute('d')?.match(/M/g) ?? [])
          .length
      ).toBe(1);
    });

    it('lets nulls win over connectNulls when both are passed', async () => {
      const screen = await render(
        <AreaChart
          label="Storage"
          categories={MONTHS}
          connectNulls
          nulls="gap"
          series={[{ name: 'Hot', data: WITH_GAP }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Storage' });

      await expect.element(plot).toBeInTheDocument();
      expect(
        (plot.element().querySelector('path[fill^="url("]')?.getAttribute('d')?.match(/M/g) ?? [])
          .length
      ).toBeGreaterThan(1);
    });
  });

  describe('stacked', () => {
    it('swaps the wash for a flat tint and separates the bands', async () => {
      const screen = await render(
        <AreaChart
          label="Storage"
          stacked
          categories={MONTHS}
          series={[
            { name: 'Hot', data: [10, 20, 30] },
            { name: 'Archive', data: [40, 50, 60] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Storage' });

      await expect.element(plot).toBeInTheDocument();
      // No gradient fills once stacked, and one surface-coloured rule between
      // the two bands.
      expect(plot.element().querySelectorAll('path[fill^="url("]').length).toBe(0);
      expect(plot.element().querySelectorAll('path[stroke="var(--neba-chart-gap)"]').length).toBe(
        1
      );
    });

    it('turns the value axis into a percentage with full', async () => {
      const screen = await render(
        <AreaChart
          label="Mix"
          stacked="full"
          categories={['Jan']}
          series={[
            { name: 'New', data: [40] },
            { name: 'Renewed', data: [160] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Mix' });

      await expect.element(plot).toBeInTheDocument();

      const ticks = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(ticks).toContain('100%');
      expect(ticks).toContain('0%');
    });

    // The original went through `String()`, ignoring `format` and the locale.
    it("writes the caller's numbers through format when stacking to full", async () => {
      const screen = await render(
        <AreaChart
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

    it('keeps the caller’s own numbers in the table when stacking to full', async () => {
      const screen = await render(
        <AreaChart
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

      const cells = [...table.element().querySelectorAll('tbody td')].map((cell) =>
        cell.textContent?.trim()
      );

      expect(cells).toEqual(['40', '160']);
    });
  });
});
