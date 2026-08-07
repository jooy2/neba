import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { BarChart } from 'neba';

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
  });
});
