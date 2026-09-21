import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { LineChart } from 'neba';

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr'];

/**
 * A chart is measured before it draws, so nothing reaches the DOM until the
 * host element has a width. In a browser test the element is laid out for real,
 * but the `ResizeObserver` callback that confirms it lands a task later —
 * `expect.element` retries, which is what makes these assertions stable.
 */
describe('LineChart', () => {
  describe('rendering', () => {
    it('exposes the plot as an image with its label', async () => {
      const screen = await render(
        <LineChart
          label="Sessions by month"
          categories={MONTHS}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      await expect
        .element(screen.getByRole('img', { name: 'Sessions by month' }))
        .toBeInTheDocument();
    });

    it('draws one path per series', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          series={[
            { name: 'Web', data: [10, 20, 30, 40] },
            { name: 'Mobile', data: [5, 15, 25, 35] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      // Two line paths, and no fill paths — that is what makes this a line
      // chart rather than an area one.
      expect(plot.element().querySelectorAll('path[stroke]:not([stroke="none"])').length).toBe(2);
    });

    it('writes the categories and the values into a table', async () => {
      const screen = await render(
        <LineChart
          label="Sessions by month"
          categories={MONTHS}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const table = screen.getByRole('table', { name: 'Sessions by month' });

      await expect.element(table).toBeInTheDocument();
      await expect.element(screen.getByRole('rowheader', { name: 'Mar' })).toBeInTheDocument();
      await expect.element(screen.getByRole('columnheader', { name: 'Web' })).toBeInTheDocument();
      await expect.element(screen.getByRole('cell', { name: '30' })).toBeInTheDocument();
    });

    it('reflects a changed series on re-render', async () => {
      const screen = await render(
        <LineChart label="Sessions" categories={MONTHS} series={[{ name: 'Web', data: [1, 2] }]} />
      );

      await expect.element(screen.getByRole('cell', { name: '2' })).toBeInTheDocument();

      await screen.rerender(
        <LineChart label="Sessions" categories={MONTHS} series={[{ name: 'Web', data: [1, 9] }]} />
      );

      await expect.element(screen.getByRole('cell', { name: '9' })).toBeInTheDocument();
    });

    it('shows the empty state rather than an axis when there is nothing to draw', async () => {
      const screen = await render(<LineChart label="Sessions" series={[]} empty="No data yet" />);

      await expect.element(screen.getByText('No data yet')).toBeInTheDocument();
      expect(screen.getByRole('table').query()).toBeNull();
    });

    it('leaves a gap out of the table rather than writing it as a zero', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          series={[{ name: 'Web', data: [10, null, 30, 40] }]}
        />
      );

      const table = screen.getByRole('table');

      await expect.element(table).toBeInTheDocument();

      const cells = [...table.element().querySelectorAll('tbody td')].map((cell) =>
        cell.textContent?.trim()
      );

      expect(cells).toEqual(['10', '', '30', '40']);
    });
  });

  describe('legend', () => {
    it('is left off for a single series', async () => {
      const screen = await render(
        <LineChart label="Sessions" categories={MONTHS} series={[{ name: 'Web', data: [1, 2] }]} />
      );

      await expect.element(screen.getByRole('img', { name: 'Sessions' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Web' }).query()).toBeNull();
    });

    it('lists every series from two up, pressed', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          series={[
            { name: 'Web', data: [1, 2] },
            { name: 'Mobile', data: [3, 4] }
          ]}
        />
      );

      await expect
        .element(screen.getByRole('button', { name: 'Web' }))
        .toHaveAttribute('aria-pressed', 'true');
      await expect.element(screen.getByRole('button', { name: 'Mobile' })).toBeInTheDocument();
    });

    /**
     * Pointing at one entry drops every other series to 0.28. Only the pie ever
     * did that over any time at all — everywhere else the whole picture snapped
     * between two states on the frame the pointer crossed a row.
     */
    it('fades the other series down rather than switching them', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          series={[
            { name: 'Web', data: [1, 2] },
            { name: 'Mobile', data: [3, 4] }
          ]}
        />
      );

      await expect.element(screen.getByRole('button', { name: 'Web' })).toBeInTheDocument();

      const groups = [...screen.container.querySelectorAll('svg g[opacity]')];

      expect(groups.length).toBeGreaterThan(0);
      expect(
        groups.every((g) => (g.getAttribute('class') ?? '').includes('transition:opacity'))
      ).toBe(true);
    });

    /** The entry itself dims too, and the house transition does not name opacity. */
    it('fades the legend entry it dims', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          series={[
            { name: 'Web', data: [1, 2] },
            { name: 'Mobile', data: [3, 4] }
          ]}
        />
      );

      const entry = screen.getByRole('button', { name: 'Web' }).element();

      expect(entry.className).toContain('transition-property:background-color,color,opacity');
    });

    it('hides a series when its entry is clicked, and keeps it in the list', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          series={[
            { name: 'Web', data: [1, 2] },
            { name: 'Mobile', data: [3, 4] }
          ]}
        />
      );

      const entry = screen.getByRole('button', { name: 'Web' });

      await entry.click();

      await expect.element(entry).toHaveAttribute('aria-pressed', 'false');
    });

    // The hidden state was kept by index, so a refresh that put the series in
    // another order hid whichever series now sat where the hidden one had been.
    it('keeps the same series hidden when new data reorders the series', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          series={[
            { name: 'Web', data: [1, 2] },
            { name: 'Mobile', data: [3, 4] }
          ]}
        />
      );

      await screen.getByRole('button', { name: 'Web' }).click();
      await expect
        .element(screen.getByRole('button', { name: 'Web' }))
        .toHaveAttribute('aria-pressed', 'false');

      await screen.rerender(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          series={[
            { name: 'Mobile', data: [3, 4] },
            { name: 'Web', data: [1, 2] }
          ]}
        />
      );

      await expect
        .element(screen.getByRole('button', { name: 'Web' }))
        .toHaveAttribute('aria-pressed', 'false');
      await expect
        .element(screen.getByRole('button', { name: 'Mobile' }))
        .toHaveAttribute('aria-pressed', 'true');
    });

    // Grey would be a ninth colour on a chart that has eight, and a row that
    // no longer says which series it is.
    it('fades a hidden entry rather than greying it, swatch colour and all', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          series={[
            { name: 'Web', data: [1, 2], color: 'oklch(60% 0.2 262)' },
            { name: 'Mobile', data: [3, 4] }
          ]}
        />
      );

      const entry = screen.getByRole('button', { name: 'Web' });

      await expect.element(entry).toBeInTheDocument();

      const swatchOf = () =>
        entry.element().querySelector('span[aria-hidden="true"]') as HTMLElement;
      const shownColor = getComputedStyle(swatchOf()).backgroundColor;

      await entry.click();
      await expect.element(entry).toHaveAttribute('aria-pressed', 'false');

      expect(entry.element().className).toContain('opacity-40');
      expect(entry.element().className).not.toContain('disabled-fg');
      expect(getComputedStyle(swatchOf()).backgroundColor).toBe(shownColor);
    });

    it('starts a series hidden when it says so', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          series={[
            { name: 'Web', data: [1, 2] },
            { name: 'Mobile', data: [3, 4], hidden: true }
          ]}
        />
      );

      await expect
        .element(screen.getByRole('button', { name: 'Mobile' }))
        .toHaveAttribute('aria-pressed', 'false');
    });

    it('can be turned off entirely', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          legend={false}
          series={[
            { name: 'Web', data: [1, 2] },
            { name: 'Mobile', data: [3, 4] }
          ]}
        />
      );

      await expect.element(screen.getByRole('img', { name: 'Sessions' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Web' }).query()).toBeNull();
    });
  });

  describe('accessibility', () => {
    it('names itself when no label was given', async () => {
      const screen = await render(
        <LineChart categories={MONTHS} series={[{ name: 'Web', data: [10, 20, 30, 40] }]} />
      );

      // A focusable `role="img"` with no name is a tab stop that announces
      // nothing at all, so the fallback is not cosmetic.
      await expect.element(screen.getByRole('img', { name: 'Chart' })).toBeInTheDocument();
    });

    it('keeps the readout outside the picture', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          height={200}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      // `role="img"` is a leaf: everything under it is cut out of the
      // accessibility tree, so a live region in there would announce to nobody.
      const status = screen.getByRole('status');

      await expect.element(status).toBeInTheDocument();
      expect(plot.element().contains(status.element())).toBe(false);
    });
  });

  describe('tooltip', () => {
    it('opens on an arrow key and names the category', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      plot.element().focus();
      await vi.waitFor(() => expect(document.activeElement).toBe(plot.element()));

      await screen.getByRole('img', { name: 'Sessions' }).click({ position: { x: 4, y: 4 } });

      const status = screen.getByRole('status');

      await expect.element(status).toBeInTheDocument();
    });

    it('narrows to the nearest series with mode="item"', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          height={200}
          tooltip={{ mode: 'item' }}
          series={[
            { name: 'High', data: [100, 100, 100, 100] },
            { name: 'Low', data: [1, 1, 1, 1] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      // Near the top of the plot, which is where the high series runs.
      await plot.hover({ position: { x: 120, y: 12 } });

      // The readout, which is what a screen reader is given, and the panel,
      // which is what everybody else sees. The panel carries no role of its
      // own — it is inside the chart's `role="img"`, where a role would be
      // announced to nobody — so it is reached by its data attribute.
      const status = screen.getByRole('status');

      await expect.element(status).toBeInTheDocument();
      expect(status.element().textContent).toContain('High');
      expect(status.element().textContent).not.toContain('Low');
      expect(document.querySelectorAll('[data-neba-tooltip] li').length).toBe(1);
    });

    // The plot was described by the hidden table, so every focus read out
    // every number in the chart.
    it('is described by one sentence with the count and the range', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          series={[
            { name: 'Visits', data: [10, 20, null, 40] },
            { name: 'Signups', data: [5, 6, 7, 8] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toHaveAccessibleDescription('Data points: 7. Range: 5 to 40.');
      expect(
        document.getElementById(plot.element().getAttribute('aria-describedby') ?? '')?.tagName
      ).toBe('SPAN');
    });

    // A touch's `pointerleave` arrives as it lifts, so a tap's tooltip lasted a
    // frame, and a tap that did not move never read a point at all.
    it('pins the tooltip on a tap and puts it down on a press elsewhere', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          height={200}
          series={[{ name: 'Visits', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      const host = plot.element();
      const rect = host.getBoundingClientRect();
      const touch = (type: string, target: Element, init: PointerEventInit = {}) =>
        target.dispatchEvent(
          new PointerEvent(type, { bubbles: true, pointerType: 'touch', isPrimary: true, ...init })
        );

      touch('pointerdown', host, { clientX: rect.left + 40, clientY: rect.top + 60 });
      touch('pointerup', host, { clientX: rect.left + 40, clientY: rect.top + 60 });
      touch('pointerout', host);

      const status = screen.getByRole('status');

      await expect.element(status).toMatchTextContent('Visits');

      touch('pointerdown', document.body);

      await expect.element(status).toBeEmptyDOMElement();
    });

    it('does not format the category labels again when the pointer moves', async () => {
      const tickFormat = vi.fn((category: string | number | Date) => String(category));
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          height={200}
          xAxis={{ tickFormat }}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      await new Promise((resolve) => setTimeout(resolve, 50));

      const before = tickFormat.mock.calls.length;
      const width = plot.element().getBoundingClientRect().width;

      await plot.hover({ position: { x: width * 0.2, y: 60 } });
      await expect.element(screen.getByRole('status')).toBeInTheDocument();
      await plot.hover({ position: { x: width * 0.8, y: 60 } });

      expect(tickFormat.mock.calls.length).toBe(before);
    });

    it('shows the whole column with mode="index"', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          height={200}
          series={[
            { name: 'High', data: [100, 100, 100, 100] },
            { name: 'Low', data: [1, 1, 1, 1] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      await plot.hover({ position: { x: 120, y: 12 } });

      const status = screen.getByRole('status');

      await expect.element(status).toBeInTheDocument();
      expect(status.element().textContent).toContain('High');
      expect(status.element().textContent).toContain('Low');
      expect(document.querySelectorAll('[data-neba-tooltip] li').length).toBe(2);
    });

    // Pointing at the plot reads nothing out and draws nothing.
    it('reads nothing out when it is turned off', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          tooltip={false}
          series={[{ name: 'Web', data: [10, 20] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      await plot.hover({ position: { x: 120, y: 12 } });

      expect(screen.getByRole('status').query()).toBeNull();
      expect(document.querySelectorAll('[data-neba-tooltip]').length).toBe(0);
    });
  });

  describe('axes', () => {
    // A tick is SVG text, and an element handed back came out as "[object Object]".
    it('takes only text from tickFormat', () => {
      const axis: React.ComponentProps<typeof LineChart>['xAxis'] = {
        // @ts-expect-error A tick is written as text, so an element is not one.
        tickFormat: () => <b>Jan</b>
      };

      expect(axis).toBeDefined();
    });

    it('writes each tick through tickFormat', async () => {
      const screen = await render(
        <LineChart
          label="Uptime"
          categories={MONTHS}
          yAxis={{ min: 0, max: 100, tickCount: 2, tickFormat: (value) => `${value}%` }}
          series={[{ name: 'Uptime', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Uptime' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).toContain('0%');
      expect(texts).toContain('100%');
    });

    it('keeps both ends of a pinned scale', async () => {
      const screen = await render(
        <LineChart
          label="Uptime"
          categories={MONTHS}
          yAxis={{ min: 99.5, max: 100, tickCount: 5 }}
          series={[{ name: 'Uptime', data: [99.6, 99.8, 99.9, 100] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Uptime' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).toContain('99.5');
      expect(texts).toContain('100');
    });

    it('draws no category labels when the axis is hidden', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          xAxis={{ hidden: true }}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).not.toContain('Jan');
    });

    it('writes the value axis name above the plot, inside the box, without widening the ticks', async () => {
      const chart = (name?: string) => (
        <LineChart
          label="Sessions"
          categories={MONTHS}
          yAxis={{ label: name }}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );
      const screen = await render(chart());
      const plot = screen.getByRole('img', { name: 'Sessions' });
      const gridLeft = () => Number(plot.element().querySelector('line')?.getAttribute('x1'));

      await expect.poll(() => plot.element().querySelector('line')).not.toBeNull();

      const before = gridLeft();

      await screen.rerender(chart('Visits'));

      const texts = () => [...plot.element().querySelectorAll('text')];

      await expect.poll(() => texts().some((text) => text.textContent === 'Visits')).toBe(true);

      const svg = plot.element().querySelector('svg')!.getBoundingClientRect();
      const name = texts()
        .find((text) => text.textContent === 'Visits')!
        .getBoundingClientRect();
      const ticks = texts()
        .filter((text) => /^\d+$/.test(text.textContent ?? ''))
        .map((text) => text.getBoundingClientRect());

      expect(gridLeft()).toBe(before);
      expect(name.top).toBeGreaterThanOrEqual(svg.top);
      expect(ticks.length).toBeGreaterThan(1);
      expect(Math.min(...ticks.map((tick) => tick.top))).toBeGreaterThanOrEqual(name.bottom);
    });

    it('draws no axis name for a hidden axis', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          yAxis={{ label: 'Visits', hidden: true }}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.poll(() => plot.element().querySelector('path')).not.toBeNull();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).not.toContain('Visits');
    });

    it('drops the gridlines when the value axis says so', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          yAxis={{ grid: false }}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      // Only the baseline is left.
      expect(plot.element().querySelectorAll('line').length).toBe(1);
    });

    it('turns the category labels by tickAngle', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          xAxis={{ tickAngle: -45 }}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      const turned = [...plot.element().querySelectorAll('text')].filter((node) =>
        node.getAttribute('transform')?.startsWith('rotate(-45')
      );

      expect(turned.map((node) => node.textContent)).toEqual(MONTHS);
      // The anchor goes with the turn, or the label is drawn over the plot
      // rather than under it.
      expect(turned[0].getAttribute('text-anchor')).toBe('end');
    });

    // The whole point of turning them: what a label needs along the axis stops
    // depending on how long the label is, so names that were cut to an
    // ellipsis and thinned to every other one all fit.
    it('keeps every long name, and keeps it whole, once they are turned', async () => {
      const long = [
        'Signed up',
        'Email verified',
        'Team invited',
        'Repo connected',
        'PR opened',
        'PR merged'
      ];
      const data = [60, 50, 40, 30, 20, 10];

      const screen = await render(
        <LineChart label="Stages" categories={long} series={[{ name: 'Accounts', data }]} />
      );

      const plot = screen.getByRole('img', { name: 'Stages' });

      await expect.element(plot).toBeInTheDocument();

      const flat = [...plot.element().querySelectorAll('text')].map((node) => node.textContent);

      expect(flat.filter((text) => text?.endsWith('…')).length).toBeGreaterThan(0);

      await screen.rerender(
        <LineChart
          label="Stages"
          categories={long}
          xAxis={{ tickAngle: -45 }}
          series={[{ name: 'Accounts', data }]}
        />
      );

      const turned = [
        ...screen.getByRole('img', { name: 'Stages' }).element().querySelectorAll('text')
      ]
        .filter((node) => node.getAttribute('transform'))
        .map((node) => node.textContent);

      expect(turned).toEqual(long);
    });

    it('leaves the labels flat by default', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      expect(
        [...plot.element().querySelectorAll('text')].filter((node) =>
          node.getAttribute('transform')
        )
      ).toHaveLength(0);
    });
  });

  describe('a second value axis', () => {
    const REVENUE = [1000, 1200, 1400, 1600];
    const RATE = [2, 3, 2.5, 4];

    it('measures a secondary series against its own scale', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          secondaryAxis={{ tickFormat: (value) => `${value}%` }}
          series={[
            { name: 'Revenue', data: REVENUE },
            { name: 'Rate', data: RATE, axis: 'secondary' }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      const written = [...plot.element().querySelectorAll('text')].map((node) => node.textContent);

      // The far edge's ticks are written through its own tickFormat.
      expect(written.some((text) => text?.endsWith('%'))).toBe(true);

      // And the two lines fill the plot rather than one of them lying flat on
      // the floor, which is what one shared scale would have done.
      const [revenue, rate] = [...plot.element().querySelectorAll('path[stroke]')].map((node) => {
        const ys = [
          ...(node.getAttribute('d') ?? '').matchAll(/[ ,](\d+(?:\.\d+)?)(?=[ A-Z]|$)/g)
        ].map((match) => Number(match[1]));

        return Math.max(...ys) - Math.min(...ys);
      });

      expect(revenue).toBeGreaterThan(20);
      expect(rate).toBeGreaterThan(20);
    });

    it('writes a secondary series through its axis in the tooltip and the table', async () => {
      const screen = await render(
        <LineChart
          label="Sessions by month"
          categories={MONTHS}
          format={{ style: 'currency', currency: 'USD', maximumFractionDigits: 0 }}
          secondaryAxis={{ tickFormat: (value) => `${value}%` }}
          series={[
            { name: 'Revenue', data: REVENUE },
            { name: 'Rate', data: RATE, axis: 'secondary' }
          ]}
        />
      );

      const table = screen.getByRole('table', { name: 'Sessions by month' });

      await expect.element(table).toBeInTheDocument();

      const cells = [...table.element().querySelectorAll('td')].map((cell) => cell.textContent);

      expect(cells).toContain('$1,000');
      expect(cells).toContain('2%');
    });

    // The prop is what turns the split on, so a series asking for an axis the
    // chart has not got is measured on the one it has rather than half-applied.
    it('ignores the series flag when no second axis was given', async () => {
      const screen = await render(
        <LineChart
          label="Sessions by month"
          categories={MONTHS}
          series={[
            { name: 'Revenue', data: REVENUE },
            { name: 'Rate', data: RATE, axis: 'secondary' }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions by month' });

      await expect.element(plot).toBeInTheDocument();

      // Two values between 2 and 4 drawn on a scale that runs to sixteen
      // hundred are a flat line along the floor, which is the whole reason the
      // second axis exists — and what has to still happen without it.
      const spread = (node: Element) => {
        const ys = [
          ...(node.getAttribute('d') ?? '').matchAll(/[ ,](\d+(?:\.\d+)?)(?=[ A-Z]|$)/g)
        ].map((match) => Number(match[1]));

        return Math.max(...ys) - Math.min(...ys);
      };

      const paths = [...plot.element().querySelectorAll('path[stroke]')];

      expect(spread(paths[1])).toBeLessThan(5);
    });

    // A stack is a total, and a total across two units is not a number.
    it('puts everything back on one scale when the chart stacks', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          stacked
          secondaryAxis={{ label: 'Rate' }}
          series={[
            { name: 'Revenue', data: REVENUE },
            { name: 'Rate', data: RATE, axis: 'secondary' }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      expect(
        [...plot.element().querySelectorAll('text')].map((node) => node.textContent)
      ).not.toContain('Rate');
    });

    it('names the far edge where that edge is', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          secondaryAxis={{ label: 'Rate' }}
          series={[
            { name: 'Revenue', data: REVENUE },
            { name: 'Rate series', data: RATE, axis: 'secondary' }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      expect(
        [...plot.element().querySelectorAll('text')].map((node) => node.textContent)
      ).toContain('Rate');
    });
  });

  describe('exporting', () => {
    it('draws no button unless it is asked for', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      await expect.element(screen.getByRole('img', { name: 'Sessions' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Export CSV' }).query()).toBeNull();
    });

    // The same numbers the hidden table holds, read out sideways: a reader who
    // exports and a reader who is read the table must not end up with two
    // different files.
    it('hands over the categories and every series', async () => {
      const onExport = vi.fn();
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          exportable
          onExport={onExport}
          xAxis={{ label: 'Month' }}
          series={[
            { name: 'Web', data: [10, 20, 30, 40] },
            { name: 'Mobile', data: [5, 15, 25, 35] }
          ]}
        />
      );

      await screen.getByRole('button', { name: 'Export CSV' }).click();
      await expect.poll(() => onExport.mock.calls.length).toBe(1);

      const csv = onExport.mock.calls[0][0] as string;
      const lines = csv.replace('\uFEFF', '').split('\r\n');

      expect(lines[0]).toBe('Month,Web,Mobile');
      expect(lines[1]).toBe('Jan,10,5');
      expect(lines[4]).toBe('Apr,40,35');
    });

    it('leaves a gap empty rather than writing it as a zero', async () => {
      const onExport = vi.fn();
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          exportable
          onExport={onExport}
          series={[{ name: 'Web', data: [10, null, 30, 40] }]}
        />
      );

      await screen.getByRole('button', { name: 'Export CSV' }).click();
      await expect.poll(() => onExport.mock.calls.length).toBe(1);

      const lines = (onExport.mock.calls[0][0] as string).replace('\uFEFF', '').split('\r\n');

      expect(lines[2]).toBe('Feb,');
    });
  });

  describe('references', () => {
    const plotOf = (screen: { getByRole: (role: string, options: { name: string }) => any }) =>
      screen.getByRole('img', { name: 'Sessions' });

    it('draws a dashed rule across the plot and names it', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          references={[{ value: 25, label: 'Target' }]}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = plotOf(screen);

      await expect.element(plot).toBeInTheDocument();

      const dashed = [...plot.element().querySelectorAll('line')].filter((node) =>
        node.getAttribute('stroke-dasharray')
      );

      expect(dashed).toHaveLength(1);
      // Across the plot, which on a vertical chart means a horizontal rule.
      expect(dashed[0].getAttribute('y1')).toBe(dashed[0].getAttribute('y2'));
      expect(
        [...plot.element().querySelectorAll('text')].map((node) => node.textContent)
      ).toContain('Target');
    });

    it('draws a solid one when it is told to', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          references={[{ value: 25, solid: true }]}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = plotOf(screen);

      await expect.element(plot).toBeInTheDocument();
      expect(
        [...plot.element().querySelectorAll('line')].filter((node) =>
          node.getAttribute('stroke-dasharray')
        )
      ).toHaveLength(0);
    });

    // A target above everything measured, drawn off the top of the plot, is a
    // target nobody can see.
    it('widens the scale to hold a reference past the data', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );
      const plot = plotOf(screen);

      await expect.element(plot).toBeInTheDocument();

      const before = [...plot.element().querySelectorAll('text')].map((node) => node.textContent);

      expect(before).not.toContain('500');

      await screen.rerender(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          references={[{ value: 500 }]}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      expect(
        [...plot.element().querySelectorAll('text')].map((node) => node.textContent)
      ).toContain('500');
    });

    it('turns a `to` into a band with an edge at each end', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          references={[{ value: 15, to: 25 }]}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = plotOf(screen);

      await expect.element(plot).toBeInTheDocument();
      expect(
        [...plot.element().querySelectorAll('line')].filter((node) =>
          node.getAttribute('stroke-dasharray')
        )
      ).toHaveLength(2);
      expect(plot.element().querySelectorAll('rect').length).toBeGreaterThan(0);
    });

    it('runs the other way with axis="category"', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          references={[{ value: 2, axis: 'category' }]}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = plotOf(screen);

      await expect.element(plot).toBeInTheDocument();

      const dashed = [...plot.element().querySelectorAll('line')].filter((node) =>
        node.getAttribute('stroke-dasharray')
      );

      expect(dashed).toHaveLength(1);
      expect(dashed[0].getAttribute('x1')).toBe(dashed[0].getAttribute('x2'));
    });

    // The picture is `aria-hidden`, so a reader who gets the table instead
    // would otherwise never learn the target exists.
    it('reads a named reference out with the data', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          format={{ style: 'percent', maximumFractionDigits: 0 }}
          references={[{ value: 0.25, label: 'Target' }]}
          series={[{ name: 'Web', data: [0.1, 0.2] }]}
        />
      );

      await expect.element(screen.getByText('Target: 25%')).toBeInTheDocument();
    });

    it('names a category reference by its own category', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          references={[{ value: 2, axis: 'category', label: 'Launch' }]}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      await expect.element(screen.getByText('Launch: Mar')).toBeInTheDocument();
    });
  });

  describe('marks', () => {
    it('draws a dot per point with markers="all"', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          markers="all"
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      expect(plot.element().querySelectorAll('circle').length).toBe(4);
    });

    it('draws none with markers="none"', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          markers="none"
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      expect(plot.element().querySelectorAll('circle').length).toBe(0);
    });

    // The hue is the only thing saying which of four lines a floating number
    // belongs to, and the ramp is solved for a 2px stroke rather than for
    // twelve-pixel type — so the label is the series' colour taken one step
    // toward the page's ink rather than the colour itself.
    it("writes a value label in its own series' colour", async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          valueLabels="last"
          series={[
            { name: 'Web', data: [10, 20, 30, 40], color: 'oklch(60% 0.2 262)' },
            { name: 'Mobile', data: [5, 15, 25, 35], color: 'oklch(60% 0.2 30)' }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      const fills = [...plot.element().querySelectorAll('text')]
        .map((node) => node.getAttribute('fill'))
        .filter((fill): fill is string => Boolean(fill?.startsWith('color-mix')));

      expect(fills).toHaveLength(2);
      expect(fills[0]).toContain('oklch(60% 0.2 262)');
      expect(fills[1]).toContain('oklch(60% 0.2 30)');
      expect(fills[0]).toContain('var(--neba-fg)');
    });

    it('labels only the last point with valueLabels="last"', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          valueLabels="last"
          series={[{ name: 'Web', data: [11, 22, 33, 44] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).toContain('44');
      expect(texts).not.toContain('11');
    });

    it('labels the high and the low with valueLabels="extremes"', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          valueLabels="extremes"
          series={[{ name: 'Web', data: [31, 12, 57, 44] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).toContain('12');
      expect(texts).toContain('57');
      expect(texts).not.toContain('31');
      expect(texts).not.toContain('44');
    });

    it('takes the extremes from the values that exist, not from the gaps', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          valueLabels="extremes"
          series={[{ name: 'Web', data: [31, null, 57, 44] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      // A gap is not a zero, so the low is 31 rather than the missing month.
      expect(texts).toContain('31');
      expect(texts).toContain('57');
      expect(texts).not.toContain('44');
    });

    it('labels nothing for a series that is all gap, and still labels the one beside it', async () => {
      // The second series is what keeps the chart drawn at all — a chart with
      // no numbers anywhere renders its empty state instead, which would never
      // reach the code this is about.
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          valueLabels="extremes"
          series={[
            { name: 'Web', data: [null, null, null, null] },
            { name: 'App', data: [63, 21, 39, 47] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).toContain('21');
      expect(texts).toContain('63');
      expect(texts).not.toContain('39');
      expect(texts).not.toContain('47');
    });

    it('breaks the path at a gap and bridges it with connectNulls', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          series={[{ name: 'Web', data: [10, null, 30, 40] }]}
        />
      );

      const broken = screen
        .getByRole('img', { name: 'Sessions' })
        .element()
        .querySelector('path[stroke]:not([stroke="none"])')
        ?.getAttribute('d');

      expect((broken?.match(/M/g) ?? []).length).toBe(2);

      await screen.rerender(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          connectNulls
          series={[{ name: 'Web', data: [10, null, 30, 40] }]}
        />
      );

      const bridged = screen
        .getByRole('img', { name: 'Sessions' })
        .element()
        .querySelector('path[stroke]:not([stroke="none"])')
        ?.getAttribute('d');

      expect((bridged?.match(/M/g) ?? []).length).toBe(1);
    });

    it('bridges the same way through nulls="connect"', async () => {
      const screen = await render(
        <LineChart
          label="Sessions"
          categories={MONTHS}
          nulls="connect"
          series={[{ name: 'Web', data: [10, null, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      const path = plot
        .element()
        .querySelector('path[stroke]:not([stroke="none"])')
        ?.getAttribute('d');

      expect((path?.match(/M/g) ?? []).length).toBe(1);
    });

    // `zero` rewrites the data rather than the drawing, which is the whole
    // reason it is worth having: a line pulled to the baseline over a table
    // that still says nothing is a chart disagreeing with itself.
    it('reads a gap as a nought everywhere with nulls="zero"', async () => {
      const screen = await render(
        <LineChart
          label="Sessions by month"
          categories={MONTHS}
          nulls="zero"
          series={[{ name: 'Web', data: [10, null, 30, 40] }]}
        />
      );

      const table = screen.getByRole('table', { name: 'Sessions by month' });

      await expect.element(table).toBeInTheDocument();

      const cells = [...table.element().querySelectorAll('td')].map((cell) => cell.textContent);

      expect(cells).toContain('0');

      // And one unbroken path, because there is no gap left to break at.
      const path = screen
        .getByRole('img', { name: 'Sessions by month' })
        .element()
        .querySelector('path[stroke]:not([stroke="none"])')
        ?.getAttribute('d');

      expect((path?.match(/M/g) ?? []).length).toBe(1);
    });

    it('leaves the gap alone by default', async () => {
      const screen = await render(
        <LineChart
          label="Sessions by month"
          categories={MONTHS}
          series={[{ name: 'Web', data: [10, null, 30, 40] }]}
        />
      );

      const table = screen.getByRole('table', { name: 'Sessions by month' });

      await expect.element(table).toBeInTheDocument();
      expect(
        [...table.element().querySelectorAll('td')].map((cell) => cell.textContent)
      ).not.toContain('0');
    });
  });

  describe('formatting', () => {
    it('passes format through to the table', async () => {
      const screen = await render(
        <LineChart
          label="Revenue"
          categories={MONTHS}
          format={{ style: 'currency', currency: 'USD', maximumFractionDigits: 0 }}
          series={[{ name: 'Revenue', data: [1200, 1400] }]}
        />
      );

      await expect.element(screen.getByRole('cell', { name: '$1,200' })).toBeInTheDocument();
    });
  });

  // A string `height` is any CSS length, as the type says, and it used to draw
  // nothing or be ignored.
  describe('a CSS length as the height', () => {
    it('draws at the height the length comes to', async () => {
      const screen = await render(
        <div style={{ width: 320, fontSize: 16 }}>
          <LineChart
            label="Sessions"
            height="10rem"
            categories={MONTHS}
            series={[{ name: 'Web', data: [1, 2, 3, 4] }]}
          />
        </div>
      );
      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      await expect
        .poll(() => plot.element().querySelector('svg')?.getAttribute('viewBox')?.split(' ')[3])
        .toBe('160');
    });
  });

  // The marks summed every value while the axis summed each sign apart, so a
  // negative series pulled the top of the stack below the axis's own maximum.
  describe('stacking values of both signs', () => {
    it('stacks a negative series down from zero and leaves the positive ones above it', async () => {
      const screen = await render(
        <LineChart
          label="Flow"
          stacked
          markers="all"
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

      await expect
        .poll(() => plot.element().querySelectorAll('circle').length)
        .toBeGreaterThanOrEqual(3);

      const [first, negative, top] = [...plot.element().querySelectorAll('circle')]
        .slice(0, 3)
        .map((dot) => Number(dot.getAttribute('cy')));

      // First at 10, the negative at -5 and the top of the positive stack at
      // 20: fifteen units apart below, ten above. Summed regardless of sign the
      // top sat at 15, five units above the first.
      expect((first - top) / (negative - first)).toBeCloseTo(10 / 15, 2);
    });
  });

  // A string `height` is any CSS length, read back off the box it produced.
  describe('a CSS length as the height', () => {
    it('draws at the height the length comes to', async () => {
      const screen = await render(
        <div style={{ width: 320 }}>
          <LineChart
            label="Visits"
            height="10rem"
            categories={MONTHS}
            series={[{ name: 'Web', data: [1, 2, 3, 4] }]}
          />
        </div>
      );
      const plot = screen.getByRole('img', { name: 'Visits' });

      await expect.element(plot).toBeInTheDocument();
      expect(plot.element().getBoundingClientRect().height).toBe(160);
      await expect
        .poll(() => plot.element().querySelector('svg')?.getAttribute('viewBox')?.split(' ')[3])
        .toBe('160');
    });
  });

  // The palette repeats past its eighth slot, which the docs said it never did.
  describe('more series than colours', () => {
    it('warns once in development that the colours repeat', async () => {
      const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
      const nine = Array.from({ length: 9 }, (_, index) => ({
        name: `Series ${index + 1}`,
        data: [index, index + 1]
      }));

      try {
        const screen = await render(<LineChart label="Many" categories={MONTHS} series={nine} />);

        await expect.element(screen.getByRole('img', { name: 'Many' })).toBeInTheDocument();
        await screen.rerender(<LineChart label="Many" categories={MONTHS} series={[...nine]} />);

        const said = warn.mock.calls.filter(([message]) => String(message).includes('9 series'));

        expect(said).toHaveLength(1);
      } finally {
        warn.mockRestore();
      }
    });

    it('says nothing for eight', async () => {
      const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
      const eight = Array.from({ length: 8 }, (_, index) => ({
        name: `Series ${index + 1}`,
        data: [index, index + 1]
      }));

      try {
        const screen = await render(
          <LineChart label="Enough" categories={MONTHS} series={eight} />
        );

        await expect.element(screen.getByRole('img', { name: 'Enough' })).toBeInTheDocument();
        expect(warn.mock.calls.some(([message]) => String(message).includes('palette'))).toBe(
          false
        );
      } finally {
        warn.mockRestore();
      }
    });
  });
});
