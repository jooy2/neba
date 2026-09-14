import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
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

  describe('accessibility', () => {
    it('names itself when no label was given', async () => {
      const screen = await render(<PieChart categories={PLANS} data={[50, 30, 20]} />);

      await expect.element(screen.getByRole('img', { name: 'Chart' })).toBeInTheDocument();
    });

    it('keeps the readout outside the picture', async () => {
      const screen = await render(
        <PieChart label="Accounts" categories={PLANS} data={[50, 30, 20]} />
      );

      const plot = screen.getByRole('img', { name: 'Accounts' });

      await expect.element(plot).toBeInTheDocument();

      // `role="img"` is a leaf: everything under it is cut out of the
      // accessibility tree, so a live region in there would announce to nobody.
      const status = screen.getByRole('status');

      await expect.element(status).toBeInTheDocument();
      expect(plot.element().contains(status.element())).toBe(false);
    });

    it('is described by the slice count and range rather than by its table', async () => {
      const screen = await render(
        <PieChart label="Accounts" categories={PLANS} data={[50, 30, 20]} />
      );

      await expect
        .element(screen.getByRole('img', { name: 'Accounts' }))
        .toHaveAccessibleDescription('Data points: 3. Range: 20 to 50.');
    });

    // The docs promised Escape, Home and End; only the arrows existed.
    it('jumps to the ends with Home and End and lets go with Escape', async () => {
      const screen = await render(
        <PieChart label="Accounts" categories={PLANS} data={[50, 30, 20]} />
      );
      const plot = screen.getByRole('img', { name: 'Accounts' });
      const status = screen.getByRole('status');

      // A mouse left over the plot by an earlier test would pick a slice of its own.
      await userEvent.unhover(plot);
      plot.element().focus();

      await userEvent.keyboard('{End}');
      await expect.element(status).toMatchTextContent(PLANS[2]);

      await userEvent.keyboard('{Home}');
      await expect.element(status).toMatchTextContent(PLANS[0]);

      await userEvent.keyboard('{Escape}');
      await expect.element(status).toBeEmptyDOMElement();
    });

    it('keeps a tapped slice until a press lands elsewhere', async () => {
      const screen = await render(
        <PieChart label="Accounts" categories={PLANS} data={[50, 30, 20]} />
      );
      const plot = screen.getByRole('img', { name: 'Accounts' });

      await expect.element(plot).toBeInTheDocument();

      const slice = plot.element().querySelector('path');

      expect(slice).not.toBeNull();

      const touch = (type: string, target: Element) =>
        target.dispatchEvent(
          new PointerEvent(type, { bubbles: true, pointerType: 'touch', isPrimary: true })
        );

      touch('pointerover', slice!);
      touch('pointerdown', slice!);
      touch('pointerup', slice!);
      touch('pointerout', slice!);

      const status = screen.getByRole('status');

      await expect.element(status).toMatchTextContent(PLANS[0]);

      touch('pointerdown', document.body);

      await expect.element(status).toBeEmptyDOMElement();
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

    // Every share was written in the surface colour, which is about 4:1 on the
    // light theme's slots and vanishes on a caller's pale slice.
    it('writes each share in the ink its slice reads best under', async () => {
      const screen = await render(
        <PieChart
          label="Accounts"
          valueLabels="all"
          size="xl"
          categories={['Slot', 'Yellow', 'Navy']}
          data={[50, { y: 25, color: '#ffe066' }, { y: 25, color: '#1e2a5a' }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Accounts' });

      await expect.element(plot).toBeInTheDocument();

      const fills = [...plot.element().querySelectorAll('text')].map((t) => t.getAttribute('fill'));

      expect(fills).toEqual(['var(--neba-chart-on-1)', '#000000', '#ffffff']);
    });
  });

  // A string `height` is any CSS length, as the type says, and it used to draw
  // nothing or be ignored.
  describe('a CSS length as the height', () => {
    it('draws at the height the length comes to', async () => {
      const screen = await render(
        <div style={{ width: 320, fontSize: 16 }}>
          <PieChart label="Accounts" height="10rem" categories={PLANS} data={[50, 30, 20]} />
        </div>
      );
      const plot = screen.getByRole('img', { name: 'Accounts' });

      await expect.element(plot).toBeInTheDocument();
      await expect
        .poll(() => plot.element().querySelector('svg')?.getAttribute('viewBox')?.split(' ')[3])
        .toBe('160');
    });
  });
});
