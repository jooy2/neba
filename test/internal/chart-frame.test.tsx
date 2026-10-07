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
  // Asked twice: with no `locale` the chart also renders once more straight
  // after hydration, to write in the reader's language, and the drawing must
  // stay out of that render as well. React 19 only: React 18 does not reliably
  // keep a transition started in a layout effect out of the task that is
  // hydrating, so there the chart may still draw inside it, as it always did.
  it.skipIf(React.version.startsWith('18.')).each([
    ['with a locale', 'en-US'],
    ['with no locale', undefined]
  ] as const)('draws a hydrated chart after the hydration has committed, %s', async (_, locale) => {
    const hydrated = (
      <div style={{ width: 320 }}>
        <CartesianChart label="Load" locale={locale} series={[{ name: 'A', data: [1, 4, 2] }]}>
          {() => null}
        </CartesianChart>
      </div>
    );
    const host = document.createElement('div');
    let drawnInCommit: boolean | null = null;

    /** Looks, once the commit that hydrated the chart has returned. */
    function Probe() {
      React.useLayoutEffect(() => {
        queueMicrotask(() => {
          drawnInCommit = host.querySelector('svg') !== null;
        });
      }, []);

      return null;
    }

    host.innerHTML = renderToString(hydrated);
    document.body.append(host);

    const recoverable = vi.fn();
    const root = hydrateRoot(
      host,
      <>
        {hydrated}
        <Probe />
      </>,
      { onRecoverableError: recoverable }
    );

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
