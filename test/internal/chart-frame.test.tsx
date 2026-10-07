/**
 * The frame every cartesian chart is drawn in, rendered on its own.
 *
 * What is tested here is a promise the frame makes to the charts built on it
 * rather than anything a reader sees: that the layout a chart's marks are built
 * from keeps its identity while the pointer moves. A chart memoises its paths
 * and its marks on that layout, so a fresh object on each move is every path on
 * the plot traced again for a picture that has not changed.
 */
import * as React from 'react';
import { describe, expect, it, vi } from 'vitest';
import { flushSync } from 'react-dom';
import { renderToString } from 'react-dom/server';
import { createRoot, hydrateRoot } from 'react-dom/client';
import { render } from 'vitest-browser-react';
import {
  AreaChart,
  BarChart,
  GaugeChart,
  HeatmapChart,
  LineChart,
  PieChart,
  ScatterChart,
  Sparkline,
  TimelineChart
} from 'neba';
import {
  CartesianChart,
  ChartDataTable,
  type CartesianContext,
  type CartesianLayout,
  type ChartMark
} from '../../src/internal/chart-frame.js';

/** Moves a pointer to a point inside the plot, in the plot's own pixels. */
function pointAt(host: Element, x: number, y: number) {
  const rect = host.getBoundingClientRect();

  host.dispatchEvent(
    new PointerEvent('pointermove', {
      bubbles: true,
      clientX: rect.left + x,
      clientY: rect.top + y
    })
  );
}

/** The parts of the context that do not depend on the pointer. */
const layoutOf = (context: CartesianContext) => [
  context.plot,
  context.values,
  context.visible,
  context.colors,
  context.scale,
  context.band,
  context.valuePx,
  context.categoryPx,
  context.point,
  context.categoryValuePx,
  context.zeroPxOf,
  context.formatFor,
  context.marks
];

describe('CartesianChart', () => {
  it('keeps the layout while the crosshair moves from column to column', async () => {
    const seen: CartesianContext[] = [];
    const screen = await render(
      <CartesianChart
        label="Load"
        inset
        series={[
          { name: 'A', data: [1, 4, 2, 8, 5, 7] },
          { name: 'B', data: [3, 1, 6, 2, 4, 3] }
        ]}
      >
        {(context) => {
          seen.push(context);

          return null;
        }}
      </CartesianChart>
    );

    const plot = screen.getByRole('img', { name: 'Load' });

    await expect.element(plot).toBeInTheDocument();
    await expect.poll(() => seen.length).toBeGreaterThan(0);

    const before = seen[seen.length - 1];
    const width = plot.element().getBoundingClientRect().width;

    pointAt(plot.element(), width * 0.1, 40);
    await expect.poll(() => seen[seen.length - 1].activeIndex).not.toBeNull();

    const first = seen[seen.length - 1].activeIndex;

    pointAt(plot.element(), width * 0.9, 40);
    await expect.poll(() => seen[seen.length - 1].activeIndex).not.toBe(first);

    const after = seen[seen.length - 1];

    layoutOf(after).forEach((part, index) => expect(part).toBe(layoutOf(before)[index]));
  });

  it('builds the marks once, and not again as the pointer goes from one to the next', async () => {
    const seen: CartesianContext[] = [];
    const build = vi.fn((layout: CartesianLayout): ChartMark[] =>
      layout.values[0].map((value, index) => ({
        series: 0,
        index,
        x: layout.categoryValuePx(index),
        y: layout.valuePx(value.value ?? 0),
        r: 4
      }))
    );
    const screen = await render(
      <CartesianChart
        label="Spend"
        height={200}
        xScale="value"
        includeZero={false}
        xAxis={{ hidden: true }}
        yAxis={{ hidden: true }}
        series={[
          {
            name: 'A',
            data: [
              { x: 0, y: 0 },
              { x: 1, y: 10 }
            ]
          }
        ]}
        marks={build}
      >
        {(context) => {
          seen.push(context);

          return null;
        }}
      </CartesianChart>
    );

    const plot = screen.getByRole('img', { name: 'Spend' });

    await expect.element(plot).toBeInTheDocument();
    await expect.poll(() => seen.length).toBeGreaterThan(0);

    const calls = build.mock.calls.length;
    const marks = seen[seen.length - 1].marks;

    expect(marks).toHaveLength(2);

    pointAt(plot.element(), marks[0].x, marks[0].y);
    await expect.poll(() => seen[seen.length - 1].activeMark).toBe(marks[0]);

    pointAt(plot.element(), marks[1].x, marks[1].y);
    await expect.poll(() => seen[seen.length - 1].activeMark).toBe(marks[1]);

    expect(build.mock.calls.length).toBe(calls);
    expect(seen[seen.length - 1].marks).toBe(marks);
  });

  // A server render has no width, so marks built there were laid out against a
  // plot no pixels wide and thrown away when the measurement arrived.
  it('builds no marks before there is a width to place them in', () => {
    const build = vi.fn((): ChartMark[] => []);

    renderToString(
      <CartesianChart
        label="Spend"
        xScale="value"
        series={[{ name: 'A', data: [{ x: 0, y: 4 }] }]}
        marks={build}
      >
        {() => null}
      </CartesianChart>
    );

    expect(build).not.toHaveBeenCalled();
  });

  // `item` mode stored the pointer's own offset, a fresh pixel on every move,
  // and the whole chart rendered again for each pixel it moved inside a bar.
  it('does not render again while the pointer stays on one reading in item mode', async () => {
    const seen: CartesianContext[] = [];
    const screen = await render(
      <CartesianChart
        label="Load"
        height={220}
        tooltip={{ mode: 'item' }}
        series={[
          { name: 'A', data: [10, 20] },
          { name: 'B', data: [90, 80] }
        ]}
      >
        {(context) => {
          seen.push(context);

          return null;
        }}
      </CartesianChart>
    );

    const plot = screen.getByRole('img', { name: 'Load' });

    await expect.element(plot).toBeInTheDocument();
    await expect.poll(() => seen.length).toBeGreaterThan(0);

    const width = plot.element().getBoundingClientRect().width;
    const status = screen.getByRole('status');

    // Near the top of the first column, which is B's reading of 90.
    pointAt(plot.element(), width * 0.25, 20);
    await expect.element(status).toMatchTextContent('B: 90');

    const renders = seen.length;

    for (let pixel = 1; pixel <= 10; pixel++) {
      pointAt(plot.element(), width * 0.25, 20 + pixel);
    }

    await new Promise((resolve) => setTimeout(resolve, 100));

    expect(seen.length).toBe(renders);
    await expect.element(status).toMatchTextContent('B: 90');
  });

  it('keeps the layout while the legend is pointed at', async () => {
    const seen: CartesianContext[] = [];
    const screen = await render(
      <CartesianChart
        label="Load"
        inset
        series={[
          { name: 'A', data: [1, 4, 2] },
          { name: 'B', data: [3, 1, 6] }
        ]}
      >
        {(context) => {
          seen.push(context);

          return null;
        }}
      </CartesianChart>
    );

    await expect.element(screen.getByRole('img', { name: 'Load' })).toBeInTheDocument();
    await expect.poll(() => seen.length).toBeGreaterThan(0);

    const before = seen[seen.length - 1];

    await screen.getByRole('button', { name: 'B' }).hover();
    await expect.poll(() => seen[seen.length - 1].hovered).toBe(1);

    layoutOf(seen[seen.length - 1]).forEach((part, index) =>
      expect(part).toBe(layoutOf(before)[index])
    );
  });
});

/**
 * The table every chart carries, past the point where its rows are added after
 * the first paint.
 */
describe('ChartDataTable', () => {
  // Each idle slice re-rendered the table to add its rows, and every row
  // already written was drawn again with it: the fill was quadratic in the
  // number of rows, and each slice took longer than the one before.
  it('draws each row once while its rows are added in slices', async () => {
    const count = 1500;
    const categories = Array.from({ length: count }, (_, index) => `D${index}`);
    const series = [{ name: 'A', data: categories.map((_, index) => index) }];
    const values = [series[0].data.map((value) => ({ value }))];
    const format = vi.fn((value: number) => String(value));

    const screen = await render(
      <ChartDataTable
        id="load"
        caption="Load"
        categories={categories}
        series={series}
        values={values}
        format={format}
      />
    );

    const table = screen.getByRole('table', { name: 'Load' });

    await expect
      .poll(() => table.element().querySelectorAll('tbody tr').length, { timeout: 5000 })
      .toBe(count);
    await expect.element(table).not.toHaveAttribute('aria-busy');

    expect(format).toHaveBeenCalledTimes(count);
    expect(
      [...table.element().querySelectorAll('tbody th')].map((cell) => cell.textContent)
    ).toEqual(categories);
  });
});

/**
 * When the measurement the drawing waits for is applied.
 */
describe('measuring the width', () => {
  const chart = (
    <div style={{ width: 320 }}>
      <CartesianChart label="Load" series={[{ name: 'A', data: [1, 4, 2] }]}>
        {() => null}
      </CartesianChart>
    </div>
  );

  // Mounted in the browser, the chart is drawn before anything is painted, so
  // the empty box never reaches the screen.
  it('draws a chart mounted in the browser in the commit that mounts it', () => {
    const host = document.createElement('div');
    const root = createRoot(host);

    document.body.append(host);

    try {
      flushSync(() => root.render(chart));

      expect(host.querySelector('svg')).not.toBeNull();
    } finally {
      root.unmount();
      host.remove();
    }
  });

  // After a hydration the empty box has already been painted from the server's
  // HTML, and drawing every chart on the page inside the hydration's own task
  // kept the page from answering anything the reader did meanwhile.
  //
  // The page takes longer to hydrate than the 5 ms slice React's scheduler
  // works in, as any page with a chart worth moving out of the way does. That
  // matters on React 18, which schedules a transition started in a layout
  // effect from the commit itself: its scheduler starts the next piece of work
  // in the same task while that task's slice lasts, so the drawing can follow
  // a hydration quicker than one slice in the same task — still no long task,
  // and still rendered in slices. React 19 schedules it from a microtask, and
  // draws in a later task either way.
  //
  // Asked twice: with no `locale` the chart also renders once more straight
  // after hydration, to write in the reader's language, and the drawing must
  // stay out of that render as well.
  it.each([
    ['with a locale', 'en-US'],
    ['with no locale', undefined]
  ] as const)('draws a hydrated chart after the hydration has committed, %s', async (_, locale) => {
    const host = document.createElement('div');
    let drawnInCommit: boolean | null = null;

    /** The rest of the page, which spends a slice and more hydrating. */
    function Page() {
      const until = performance.now() + 20;

      while (performance.now() < until) {
        // Busy, the way a page's own components are.
      }

      return null;
    }

    /** Looks, once the commit that hydrated the chart has returned. */
    function Probe() {
      React.useLayoutEffect(() => {
        queueMicrotask(() => {
          drawnInCommit = host.querySelector('svg') !== null;
        });
      }, []);

      return null;
    }

    // The same tree on both sides, so that `useId` agrees on both.
    const hydrated = (
      <>
        <div style={{ width: 320 }}>
          <CartesianChart label="Load" locale={locale} series={[{ name: 'A', data: [1, 4, 2] }]}>
            {() => null}
          </CartesianChart>
        </div>
        <Page />
        <Probe />
      </>
    );

    host.innerHTML = renderToString(hydrated);
    document.body.append(host);

    const recoverable = vi.fn();
    const root = hydrateRoot(host, hydrated, { onRecoverableError: recoverable });

    try {
      await vi.waitFor(() => expect(host.querySelector('svg')).not.toBeNull());

      expect(drawnInCommit).toBe(false);
      expect(recoverable).not.toHaveBeenCalled();
    } finally {
      root.unmount();
      host.remove();
    }
  });
});

/**
 * `initialWidth`, which every chart that measures itself takes: the width it is
 * drawn at before it has a box to measure.
 */
describe('initialWidth', () => {
  const charts: [string, (initialWidth?: number) => React.ReactElement][] = [
    [
      'LineChart',
      (initialWidth) => (
        <LineChart label="Chart" initialWidth={initialWidth} series={[{ data: [1, 4, 2] }]} />
      )
    ],
    [
      'AreaChart',
      (initialWidth) => (
        <AreaChart label="Chart" initialWidth={initialWidth} series={[{ data: [1, 4, 2] }]} />
      )
    ],
    [
      'BarChart',
      (initialWidth) => (
        <BarChart label="Chart" initialWidth={initialWidth} series={[{ data: [1, 4, 2] }]} />
      )
    ],
    [
      'ScatterChart',
      (initialWidth) => (
        <ScatterChart
          label="Chart"
          initialWidth={initialWidth}
          series={[
            {
              data: [
                { x: 1, y: 2 },
                { x: 3, y: 5 }
              ]
            }
          ]}
        />
      )
    ],
    [
      'TimelineChart',
      (initialWidth) => (
        <TimelineChart
          label="Chart"
          initialWidth={initialWidth}
          series={[
            {
              name: 'Build',
              data: [{ start: new Date(2026, 0, 5), end: new Date(2026, 0, 9) }]
            }
          ]}
        />
      )
    ],
    [
      'HeatmapChart',
      (initialWidth) => (
        <HeatmapChart label="Chart" initialWidth={initialWidth} series={[{ data: [1, 4, 2] }]} />
      )
    ],
    [
      'PieChart',
      (initialWidth) => <PieChart label="Chart" initialWidth={initialWidth} data={[3, 5, 2]} />
    ],
    [
      'GaugeChart',
      (initialWidth) => <GaugeChart label="Chart" initialWidth={initialWidth} value={42} />
    ],
    [
      'Sparkline',
      (initialWidth) => <Sparkline label="Chart" initialWidth={initialWidth} data={[1, 4, 2]} />
    ]
  ];

  /** The drawing: the `<svg>` inside the element named after the chart. */
  const drawing = (root: ParentNode) => root.querySelector('[aria-label="Chart"] svg');

  it.each(charts)('%s draws at it in a server render', (_, chart) => {
    const page = new DOMParser().parseFromString(renderToString(chart(480)), 'text/html');

    expect(drawing(page)?.getAttribute('width')).toBe('480');
  });

  it.each(charts)('%s leaves its server render undrawn without it', (_, chart) => {
    const page = new DOMParser().parseFromString(renderToString(chart()), 'text/html');

    expect(page.querySelector('[aria-label="Chart"]')).not.toBeNull();
    expect(drawing(page)).toBeNull();
  });

  it.each(charts)(
    '%s hydrates what it drew and then draws at the width it measures',
    async (_, chart) => {
      const element = <div style={{ width: 320 }}>{chart(480)}</div>;
      const host = document.createElement('div');

      host.innerHTML = renderToString(element);
      document.body.append(host);

      const recoverable = vi.fn();
      const root = hydrateRoot(host, element, { onRecoverableError: recoverable });

      try {
        await vi.waitFor(() => expect(drawing(host)?.getAttribute('width')).toBe('320'));
        expect(recoverable).not.toHaveBeenCalled();
      } finally {
        root.unmount();
        host.remove();
      }
    }
  );

  // A height written as a CSS length is read off the box too, so on the server
  // there is no height to draw into.
  it('is not read when the height is a CSS length', () => {
    const html = renderToString(
      <LineChart label="Chart" height="16rem" initialWidth={480} series={[{ data: [1, 4, 2] }]} />
    );

    expect(drawing(new DOMParser().parseFromString(html, 'text/html'))).toBeNull();
  });

  // Mounted in the browser, the chart measures itself before it paints, so a
  // drawing at the guess would only be thrown away.
  it('is not drawn at by a chart mounted in the browser', () => {
    const host = document.createElement('div');
    const root = createRoot(host);

    document.body.append(host);

    try {
      flushSync(() =>
        root.render(
          <div style={{ width: 320 }}>
            <LineChart label="Chart" initialWidth={480} series={[{ data: [1, 4, 2] }]} />
          </div>
        )
      );

      expect(drawing(host)?.getAttribute('width')).toBe('320');
    } finally {
      root.unmount();
      host.remove();
    }
  });
});
