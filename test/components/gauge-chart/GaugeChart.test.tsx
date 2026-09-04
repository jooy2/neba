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

    // The reading is a stroke along the groove rather than a second wedge inside
    // it, so the family lands on `stroke`.
    it('keeps its own family below every threshold', async () => {
      const screen = await render(<Tile value={40} thresholds={thresholds} label="CPU" />);
      const arc = screen.getByRole('img').element().querySelectorAll('path')[1];

      expect(arc?.getAttribute('stroke')).toBe('var(--neba-primary-fill)');
    });

    it('takes the family of the last one it has reached', async () => {
      const screen = await render(<Tile value={95} thresholds={thresholds} label="CPU" />);
      const arc = screen.getByRole('img').element().querySelectorAll('path')[1];

      expect(arc?.getAttribute('stroke')).toBe('var(--neba-danger-fill)');
    });
  });

  describe('the reading', () => {
    /**
     * A wedge is a closed shape, so moving the value rewrites its `d` — and `d`
     * is not a property CSS can travel along, which is why the dial jumped to
     * each new reading while the Meter it is a bent copy of swept to it. A
     * stroke's drawn length is `stroke-dashoffset`, and `pathLength="1"` makes
     * that number the fraction itself.
     */
    it('sweeps to a new value rather than jumping to it', async () => {
      const screen = await render(<Tile value={25} label="CPU" />);
      const arc = () => screen.getByRole('img').element().querySelectorAll('path')[1];

      expect(arc()?.getAttribute('pathLength')).toBe('1');
      expect(arc()?.getAttribute('stroke-dasharray')).toBe('1');
      expect(parseFloat(arc()?.getAttribute('stroke-dashoffset') ?? '')).toBeCloseTo(0.75);
      expect(arc()?.getAttribute('style')).toContain('stroke-dashoffset');

      await screen.rerender(<Tile value={80} label="CPU" />);

      // The same path, a different offset — which is the whole point: nothing
      // about the geometry changed, so there is something to travel along.
      expect(parseFloat(arc()?.getAttribute('stroke-dashoffset') ?? '')).toBeCloseTo(0.2);
    });

    it('draws none of the arc at zero, and all of it at full', async () => {
      const screen = await render(<Tile value={0} label="CPU" />);
      const arc = () => screen.getByRole('img').element().querySelectorAll('path')[1];

      expect(parseFloat(arc()?.getAttribute('stroke-dashoffset') ?? '')).toBeCloseTo(1);

      await screen.rerender(<Tile value={100} label="CPU" />);

      expect(parseFloat(arc()?.getAttribute('stroke-dashoffset') ?? '')).toBeCloseTo(0);
    });
  });

  describe('fitting the box', () => {
    /** The two ends used to be written from the arc's mid radius, which laid
        them over the band on any dial thick enough, and ran them off the tile
        whenever `format` spelled the number out. */
    it('keeps the range labels inside the box', async () => {
      const screen = await render(
        <Tile value={0.38} min={0} max={1} format={{ style: 'percent' }} label="CPU" />
      );
      const svg = screen.getByRole('img').element().querySelector('svg');
      const box = svg?.getBoundingClientRect();

      expect(svg?.querySelectorAll('text')).toHaveLength(2);

      for (const label of svg?.querySelectorAll('text') ?? []) {
        const drawn = label.getBoundingClientRect();

        expect(drawn.left).toBeGreaterThanOrEqual((box?.left ?? 0) - 0.5);
        expect(drawn.right).toBeLessThanOrEqual((box?.right ?? 0) + 0.5);
      }
    });

    it('writes no range on a closed ring, where the two ends are one point', async () => {
      const screen = await render(<Tile value={64} sweep={360} label="CPU" />);

      expect(screen.getByRole('img').element().querySelectorAll('text')).toHaveLength(0);
    });

    it('shrinks a long reading rather than running it over the arc', async () => {
      // A dashboard tile rather than a card: on 320px even nine digits fit at
      // the cap, and what this is about is the tile that cannot.
      const narrow = (props: React.ComponentProps<typeof GaugeChart>) => (
        <div style={{ width: 150 }}>
          <GaugeChart {...props} />
        </div>
      );
      const screen = await render(narrow({ value: 64, label: 'CPU' }));
      const short = parseFloat(getComputedStyle(screen.getByText('64').element()).fontSize);

      await screen.rerender(
        narrow({
          value: 1234567,
          max: 2000000,
          format: { maximumFractionDigits: 0 },
          label: 'CPU'
        })
      );

      const long = parseFloat(getComputedStyle(screen.getByText('1,234,567').element()).fontSize);

      expect(long).toBeLessThan(short);
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
