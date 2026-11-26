/**
 * The strip under a brushed chart, rendered on its own.
 *
 * Through a chart, a series long enough to matter here would also be a hidden
 * table of that many rows, which is a test of the table rather than the strip.
 */
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { ChartBrush } from '../../src/internal/chart-brush.js';

describe('ChartBrush', () => {
  // `Math.min(...values)` passes every value as an argument, and V8 gives up
  // somewhere between a hundred and two hundred thousand of them.
  it('draws the outline of a series too long to spread into arguments', async () => {
    const count = 200_000;
    const screen = await render(
      <ChartBrush
        outline={Array.from({ length: count }, (_, index) =>
          index % 50 === 0 ? null : index % 97
        )}
        count={count}
        range={[0, 999]}
        onRange={() => {}}
        color="currentColor"
        height={32}
        words={{ start: 'Start', end: 'End' }}
        label="Readings"
        categories={[]}
        width={400}
      />
    );

    const strip = screen.getByRole('group', { name: 'Readings' });

    await expect.element(strip).toBeInTheDocument();
    expect(strip.element().querySelector('path')?.getAttribute('d')).toBeTruthy();
  });
});
