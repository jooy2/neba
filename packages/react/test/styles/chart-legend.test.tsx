/**
 * A legend with `showValue`, checked against the stylesheet.
 *
 * The number beside each series' name only has a value while a column is
 * active, and the room the row keeps for it is held by a sizer whose width is
 * generated content. Whether the row is the same size at rest and in use is
 * decided by rules no component test loads.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { LineChart } from 'neba';
import standaloneCss from '../../src/standalone.css?inline';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

const categories = Array.from({ length: 24 }, (_, index) => `M${index}`);
const series = ['North America', 'Europe', 'Asia Pacific', 'Latin America'].map((name, k) => ({
  name,
  data: categories.map((_, index) => 1200 + 900 * Math.sin(index / 3 + k) * (k + 1))
}));

describe('a legend that shows the value at the active column', () => {
  // A legend beside the plot grew when the pointer entered and took its width
  // from the plot, which laid every mark out again; one under the plot pushed
  // the page below it down by a line and back up when the pointer left.
  it.each(['right', 'bottom'] as const)(
    'is the same size on the %s with a column active as without',
    async (side) => {
      const screen = await render(
        <div style={{ width: 460 }}>
          <LineChart
            label="Revenue"
            height={220}
            series={series}
            categories={categories}
            legend={{ showValue: true, side }}
            format={{ style: 'currency', currency: 'USD' }}
          />
          <p>Below the chart</p>
        </div>
      );
      const plot = screen.getByRole('img', { name: 'Revenue' });

      await expect.poll(() => plot.element().querySelector('svg')).not.toBeNull();

      const below = screen.getByText('Below the chart').element();
      const measure = () => ({
        plot: plot.element().getBoundingClientRect().width,
        below: below.getBoundingClientRect().top
      });
      const rest = measure();

      await plot.hover({ position: { x: rest.plot / 2, y: 100 } });
      await expect.element(screen.getByRole('status')).not.toBeEmptyDOMElement();

      expect(measure()).toEqual(rest);
    }
  );
});
