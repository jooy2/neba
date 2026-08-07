import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Sparkline } from 'neba';

const DATA = [4, 8, 6, 12, 9, 15];

describe('Sparkline', () => {
  describe('rendering', () => {
    it('draws a single path for a line', async () => {
      const screen = await render(<Sparkline data={DATA} label="Signups" />);

      const strip = screen.getByRole('img', { name: 'Signups' });

      await expect.element(strip).toBeInTheDocument();
      expect(strip.element().querySelectorAll('path').length).toBe(1);
    });

    it('adds a fill under an area', async () => {
      const screen = await render(<Sparkline data={DATA} shape="area" label="Signups" />);

      const strip = screen.getByRole('img', { name: 'Signups' });

      await expect.element(strip).toBeInTheDocument();
      expect(strip.element().querySelectorAll('path').length).toBe(2);
    });

    it('draws one path per bar', async () => {
      const screen = await render(<Sparkline data={DATA} shape="bar" label="Signups" />);

      const strip = screen.getByRole('img', { name: 'Signups' });

      await expect.element(strip).toBeInTheDocument();
      expect(strip.element().querySelectorAll('path').length).toBe(DATA.length);
    });

    it('adds a dot at the end when asked', async () => {
      const screen = await render(<Sparkline data={DATA} label="Signups" endDot />);

      const strip = screen.getByRole('img', { name: 'Signups' });

      await expect.element(strip).toBeInTheDocument();
      expect(strip.element().querySelectorAll('circle').length).toBe(1);
    });

    it('adds a rule at the baseline', async () => {
      const screen = await render(<Sparkline data={DATA} label="Signups" baseline={10} />);

      const strip = screen.getByRole('img', { name: 'Signups' });

      await expect.element(strip).toBeInTheDocument();
      expect(strip.element().querySelectorAll('line').length).toBe(1);
    });

    it('breaks the line at a gap rather than drawing a zero', async () => {
      const screen = await render(<Sparkline data={[4, null, 6]} label="Signups" />);

      const strip = screen.getByRole('img', { name: 'Signups' });

      await expect.element(strip).toBeInTheDocument();

      // Two subpaths, which is one `M` per run either side of the gap.
      const d = strip.element().querySelector('path')?.getAttribute('d') ?? '';

      expect((d.match(/M/g) ?? []).length).toBe(2);
    });

    it('reflects changed data on re-render', async () => {
      const screen = await render(<Sparkline data={DATA} label="Signups" />);

      const before = screen
        .getByRole('img', { name: 'Signups' })
        .element()
        .querySelector('path')
        ?.getAttribute('d');

      await screen.rerender(<Sparkline data={[15, 9, 12, 6, 8, 4]} label="Signups" />);

      const after = screen
        .getByRole('img', { name: 'Signups' })
        .element()
        .querySelector('path')
        ?.getAttribute('d');

      expect(after).not.toBe(before);
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <Sparkline data={DATA} label="Signups" className="my-own-class" />
      );

      const strip = screen.getByRole('img', { name: 'Signups' });

      await expect.element(strip).toBeInTheDocument();
      expect(strip.element().closest('.my-own-class')).not.toBeNull();
    });
  });

  describe('accessibility', () => {
    it('reads its values out when it is given a label', async () => {
      const screen = await render(<Sparkline data={[4, 8, 6]} label="Signups" />);

      await expect.element(screen.getByText('4, 8, 6')).toBeInTheDocument();
    });

    it('is hidden entirely without one', async () => {
      const screen = await render(<Sparkline data={[4, 8, 6]} />);

      expect(screen.getByRole('img').query()).toBeNull();
      expect(screen.getByText('4, 8, 6').query()).toBeNull();
    });
  });
});
