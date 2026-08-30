import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { GaugeChart } from 'neba';

/** The chart measures its host, which needs a width to measure. */
function Tile(props: React.ComponentProps<typeof GaugeChart>) {
  return (
    <div style={{ width: 320 }}>
      <GaugeChart {...props} />
    </div>
  );
}

describe('GaugeChart', () => {
  describe('rendering', () => {
    it('draws the reading as real text', async () => {
      const screen = await render(<Tile value={64} label="CPU" />);

      await expect.element(screen.getByText('64')).toBeInTheDocument();
    });

    it('names itself with the reading and the top of the range', async () => {
      const screen = await render(<Tile value={64} label="CPU" />);

      await expect.element(screen.getByRole('img', { name: 'CPU: 64 / 100' })).toBeInTheDocument();
    });

    it('writes the two ends of the scale', async () => {
      const screen = await render(<Tile value={5} min={0} max={8} label="Seats" />);

      await expect.element(screen.getByText('0')).toBeInTheDocument();
      await expect.element(screen.getByText('8')).toBeInTheDocument();
    });

    it('leaves them off when asked', async () => {
      const screen = await render(<Tile value={5} min={0} max={8} showRange={false} />);

      expect(screen.getByText('8').query()).toBeNull();
    });

    it('writes the value through format', async () => {
      const screen = await render(
        <Tile value={0.62} min={0} max={1} format={{ style: 'percent' }} />
      );

      await expect.element(screen.getByText('62%')).toBeInTheDocument();
    });

    it('takes a caption under the value', async () => {
      const screen = await render(<Tile value={64} caption="of 8 vCPU" />);

      await expect.element(screen.getByText('of 8 vCPU')).toBeInTheDocument();
    });

    it('takes something else in the middle entirely', async () => {
      const screen = await render(<Tile value={64} center="Healthy" />);

      await expect.element(screen.getByText('Healthy')).toBeInTheDocument();
      expect(screen.getByText('64').query()).toBeNull();
    });

    it('reflects a changed reading on re-render', async () => {
      const screen = await render(<Tile value={64} label="CPU" />);

      await screen.rerender(<Tile value={91} label="CPU" />);

      await expect.element(screen.getByText('91')).toBeInTheDocument();
    });
  });

  describe('no reading', () => {
    it('draws a dash rather than a zero', async () => {
      const screen = await render(<Tile value={null} label="CPU" />);

      await expect.element(screen.getByText('—')).toBeInTheDocument();
    });

    it('names itself with nothing but the label', async () => {
      const screen = await render(<Tile value={null} label="CPU" />);

      await expect.element(screen.getByRole('img', { name: 'CPU' })).toBeInTheDocument();
    });
  });

  describe('thresholds', () => {
    const thresholds = [
      { from: 70, color: 'warning' },
      { from: 90, color: 'danger' }
    ] as const;

    it('keeps its own family below every threshold', async () => {
      const screen = await render(<Tile value={40} thresholds={thresholds} label="CPU" />);
      const arc = screen.getByRole('img').element().querySelectorAll('path')[1];

      expect(arc?.getAttribute('fill')).toBe('var(--neba-primary-fill)');
    });

    it('takes the family of the last one it has reached', async () => {
      const screen = await render(<Tile value={95} thresholds={thresholds} label="CPU" />);
      const arc = screen.getByRole('img').element().querySelectorAll('path')[1];

      expect(arc?.getAttribute('fill')).toBe('var(--neba-danger-fill)');
    });
  });

  describe('shape', () => {
    it('draws no marks unless it is asked for them', async () => {
      const screen = await render(<Tile value={40} label="CPU" />);

      expect(screen.getByRole('img').element().querySelectorAll('line')).toHaveLength(0);
    });

    it('draws the marks it was asked for', async () => {
      const screen = await render(<Tile value={40} ticks={5} label="CPU" />);

      expect(screen.getByRole('img').element().querySelectorAll('line')).toHaveLength(5);
    });

    it('draws only the track when the reading is empty', async () => {
      const screen = await render(<Tile value={null} label="CPU" />);

      expect(screen.getByRole('img').element().querySelectorAll('path')).toHaveLength(1);
    });
  });
});
