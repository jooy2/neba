import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PieChart } from 'neba';

const PLANS = ['Free', 'Pro', 'Team'];

describe('PieChart', () => {
  describe('rendering', () => {
    it('draws one arc per slice', async () => {
      const screen = await render(
        <PieChart label="Accounts by plan" categories={PLANS} data={[50, 30, 20]} />
      );

      const plot = screen.getByRole('img', { name: 'Accounts by plan' });

      await expect.element(plot).toBeInTheDocument();
      expect(plot.element().querySelectorAll('path').length).toBe(3);
    });

    it('leaves out a slice with no value', async () => {
      const screen = await render(
        <PieChart label="Accounts" categories={PLANS} data={[50, null, 20]} />
      );

      const plot = screen.getByRole('img', { name: 'Accounts' });

      await expect.element(plot).toBeInTheDocument();
      expect(plot.element().querySelectorAll('path').length).toBe(2);
    });

    it('names every slice in its table', async () => {
      const screen = await render(
        <PieChart label="Accounts by plan" categories={PLANS} data={[50, 30, 20]} />
      );

      await expect
        .element(screen.getByRole('table', { name: 'Accounts by plan' }))
        .toBeInTheDocument();
      await expect.element(screen.getByRole('rowheader', { name: 'Pro' })).toBeInTheDocument();
      await expect.element(screen.getByRole('cell', { name: '30' })).toBeInTheDocument();
    });

    it('takes a slice’s name off its own point', async () => {
      const screen = await render(
        <PieChart
          label="Outcomes"
          data={[
            { x: 'Passed', y: 90 },
            { x: 'Failed', y: 10 }
          ]}
        />
      );

      await expect.element(screen.getByRole('button', { name: 'Passed' })).toBeInTheDocument();
    });

    it('shows the empty state when everything is zero', async () => {
      const screen = await render(
        <PieChart label="Accounts" categories={PLANS} data={[0, 0, 0]} empty="Nothing to show" />
      );

      await expect.element(screen.getByText('Nothing to show')).toBeInTheDocument();
      expect(screen.getByRole('table').query()).toBeNull();
    });

    it('reflects changed data on re-render', async () => {
      const screen = await render(
        <PieChart label="Accounts" categories={PLANS} data={[50, 30, 20]} />
      );

      await expect.element(screen.getByRole('cell', { name: '30' })).toBeInTheDocument();

      await screen.rerender(<PieChart label="Accounts" categories={PLANS} data={[50, 45, 20]} />);

      await expect.element(screen.getByRole('cell', { name: '45' })).toBeInTheDocument();
    });
  });

  describe('shape', () => {
    it('cuts a hole for a donut and none for a pie', async () => {
      const screen = await render(
        <PieChart label="Accounts" categories={PLANS} data={[50, 30, 20]} />
      );

      const pie = screen
        .getByRole('img', { name: 'Accounts' })
        .element()
        .querySelector('path')
        ?.getAttribute('d');

      await screen.rerender(
        <PieChart label="Accounts" shape="donut" categories={PLANS} data={[50, 30, 20]} />
      );

      const donut = screen
        .getByRole('img', { name: 'Accounts' })
        .element()
        .querySelector('path')
        ?.getAttribute('d');

      // A pie's slice runs to the centre and back; a donut's runs along a
      // second, inner arc instead — so the donut path has two arcs in it.
      expect((pie?.match(/A/g) ?? []).length).toBe(1);
      expect((donut?.match(/A/g) ?? []).length).toBe(2);
    });

    it('draws a semicircle rather than a full one', async () => {
      const screen = await render(
        <PieChart label="Accounts" shape="semi" data={[{ x: 'All', y: 100 }]} />
      );

      const plot = screen.getByRole('img', { name: 'Accounts' });

      await expect.element(plot).toBeInTheDocument();
      // A single slice sweeping 180° is one arc, not the two a full circle
      // has to be split into.
      expect(
        (plot.element().querySelector('path')?.getAttribute('d')?.match(/A/g) ?? []).length
      ).toBe(2);
    });
  });

  describe('legend', () => {
    it('hides a slice when its entry is clicked', async () => {
      const screen = await render(
        <PieChart label="Accounts" categories={PLANS} data={[50, 30, 20]} />
      );

      const entry = screen.getByRole('button', { name: 'Pro' });

      await entry.click();

      await expect.element(entry).toHaveAttribute('aria-pressed', 'false');

      const plot = screen.getByRole('img', { name: 'Accounts' });

      expect(plot.element().querySelectorAll('path').length).toBe(2);
    });
  });

  describe('valueLabels', () => {
    it('writes each slice’s share on it', async () => {
      const screen = await render(
        <PieChart
          label="Accounts"
          valueLabels="all"
          size="xl"
          categories={['Half', 'Quarter', 'Quarter again']}
          data={[50, 25, 25]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Accounts' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).toContain('50%');
      expect(texts).toContain('25%');
    });
  });
});
