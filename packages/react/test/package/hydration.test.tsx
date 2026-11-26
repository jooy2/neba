/**
 * Server-rendering every component that formats a date or a number, on a server
 * whose runtime speaks another language than the reader's browser, and then
 * hydrating what it sent.
 *
 * A `locale` the caller leaves out means "whatever the runtime defaults to", and
 * a server and a browser rarely default to the same thing. Before the library
 * pinned the hydrating render, a server in one language and a browser in another
 * wrote "July 2026" and "Juli 2026" into the same element, React reported the
 * two renders disagreeing, threw the server's HTML away and rendered the whole
 * tree again on the client — every SSR page with a date on it, for every reader
 * whose browser was not in the server's language.
 *
 * This file cannot change the browser's real default, so it stands one in: the
 * `Intl` constructors and the `toLocale*String` methods are wrapped, and a
 * formatter built without a locale answers in `SERVER_DEFAULT` while the server
 * render runs and in `BROWSER_DEFAULT` the rest of the time. The answer is
 * decided when the formatter is *used* rather than when it is built, because
 * the library memoises formatters by locale: one built during the server render
 * is the one the hydrating render reuses, and a wrapper decided at construction
 * would hand both renders the server's language and hide the very disagreement
 * this file is about.
 *
 * The two defaults are chosen to disagree about numbers as well as dates — Korean
 * writes `48,210` and German `48.210` — and neither is `en-US`, which is what an
 * unnamed locale formats as on the server and in the hydrating render, so every
 * assertion below says which of the three it saw.
 */
import * as React from 'react';
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { renderToString } from 'react-dom/server';
import { createRoot, hydrateRoot } from 'react-dom/client';
import { flushSync } from 'react-dom';
import {
  AgentStep,
  AgentSteps,
  AnimateCounter,
  BarChart,
  Calendar,
  ColorPicker,
  ContextWindow,
  DataTable,
  DatePicker,
  DateRangePicker,
  DateTimePicker,
  GaugeChart,
  HeatmapChart,
  LineChart,
  Meter,
  NumberField,
  PieChart,
  ProgressBox,
  ProgressCircular,
  ProgressLinear,
  Reasoning,
  ScatterChart,
  Slider,
  Statistic,
  TimePicker,
  TimelineChart,
  ToolCall
} from 'neba';

const SERVER_DEFAULT = 'ko-KR';
const BROWSER_DEFAULT = 'de-DE';

let phase: 'server' | 'browser' = 'browser';

const currentDefault = () => (phase === 'server' ? SERVER_DEFAULT : BROWSER_DEFAULT);

type Constructor = new (...args: unknown[]) => object;

const INTL_CONSTRUCTORS = [
  'DateTimeFormat',
  'NumberFormat',
  'Collator',
  'PluralRules',
  'RelativeTimeFormat',
  'ListFormat',
  'Segmenter',
  'DisplayNames'
] as const;

const originalIntl = new Map<string, Constructor>();
const originalMethods: [object, string, unknown][] = [];

/** A constructor whose instances built without a locale answer in the current default. */
function standIn(Original: Constructor): Constructor {
  return new Proxy(Original, {
    construct(target, args: unknown[]) {
      const [locales, ...rest] = args;

      if (locales !== undefined) {
        return Reflect.construct(target, args);
      }

      const server = Reflect.construct(target, [SERVER_DEFAULT, ...rest]) as object;
      const browser = Reflect.construct(target, [BROWSER_DEFAULT, ...rest]) as object;

      return new Proxy(browser, {
        get(_, key) {
          const source = phase === 'server' ? server : browser;
          const value: unknown = Reflect.get(source, key, source);

          return typeof value === 'function'
            ? (value as (...args: unknown[]) => unknown).bind(source)
            : value;
        }
      });
    }
  });
}

/** `Date#toLocaleString` and its kin read the runtime default too. */
function standInMethod(owner: object, name: string) {
  const original = (owner as Record<string, (...args: unknown[]) => string>)[name];

  originalMethods.push([owner, name, original]);
  (owner as Record<string, unknown>)[name] = function (
    this: unknown,
    locales?: unknown,
    ...rest: unknown[]
  ) {
    return original.call(this, locales ?? currentDefault(), ...rest);
  };
}

beforeAll(() => {
  for (const name of INTL_CONSTRUCTORS) {
    const Original = (Intl as unknown as Record<string, Constructor | undefined>)[name];

    if (Original) {
      originalIntl.set(name, Original);
      (Intl as unknown as Record<string, Constructor>)[name] = standIn(Original);
    }
  }

  for (const name of ['toLocaleString', 'toLocaleDateString', 'toLocaleTimeString']) {
    standInMethod(Date.prototype, name);
  }

  standInMethod(Number.prototype, 'toLocaleString');
});

afterAll(() => {
  for (const [name, Original] of originalIntl) {
    (Intl as unknown as Record<string, Constructor>)[name] = Original;
  }

  for (const [owner, name, original] of originalMethods) {
    (owner as Record<string, unknown>)[name] = original;
  }
});

/** Lets a hydration commit, and the render that follows it, run. */
const settle = () => new Promise((resolve) => setTimeout(resolve, 60));

/**
 * Renders on the "server", puts the HTML in the page, hydrates it, and reports
 * what React had to say about the two renders disagreeing.
 *
 * `serverNow` stands the server's clock at another instant for the server
 * render alone, as a page built once and served for weeks has it, and
 * `browserNow` the browser's for the rest, until `cleanup`.
 */
async function serverThenHydrate(element: React.ReactElement, serverNow?: Date, browserNow?: Date) {
  phase = 'server';

  if (serverNow) {
    vi.useFakeTimers({ toFake: ['Date'], now: serverNow });
  }

  let html: string;

  try {
    html = renderToString(element);
  } finally {
    phase = 'browser';
    vi.useRealTimers();

    if (browserNow) {
      vi.useFakeTimers({ toFake: ['Date'], now: browserNow });
    }
  }

  const host = document.createElement('div');

  host.innerHTML = html;
  document.body.append(host);

  const recoverable: string[] = [];
  const root = hydrateRoot(host, element, {
    onRecoverableError: (error) => recoverable.push(String((error as Error)?.message ?? error))
  });

  await settle();

  return {
    html,
    host,
    recoverable,
    cleanup() {
      root.unmount();
      host.remove();
      vi.useRealTimers();
    }
  };
}

interface Build {
  name: string;
  shipped: Date;
  size: number;
}

const JULY_27 = new Date(2026, 6, 27);
const MORNING = new Date(2026, 6, 27, 9, 30);

/** The same instant written by the real `Intl`, in a locale this file names. */
function written(locale: string, value: Date | number, options?: object): string {
  const Original = (value instanceof Date
    ? originalIntl.get('DateTimeFormat')
    : originalIntl.get('NumberFormat')) as unknown as new (
    locale: string,
    options?: object
  ) => { format(value: Date | number): string };

  return new Original(locale, options).format(value);
}

const cases: [string, React.ReactElement][] = [
  ['Calendar', <Calendar defaultValue={JULY_27} />],
  ['DatePicker', <DatePicker label="Ships on" defaultValue={JULY_27} />],
  [
    'DateRangePicker',
    <DateRangePicker label="Stay" defaultValue={{ start: JULY_27, end: new Date(2026, 7, 3) }} />
  ],
  ['DateTimePicker', <DateTimePicker label="Publish at" defaultValue={MORNING} />],
  ['TimePicker', <TimePicker label="Starts at" defaultValue={MORNING} />],
  [
    'LineChart',
    <LineChart
      label="Sign-ups"
      categories={[new Date(2026, 2, 3), new Date(2026, 2, 10), new Date(2026, 2, 17)]}
      series={[{ name: 'Web', data: [48210, 51020, 49870] }]}
    />
  ],
  [
    'BarChart',
    <BarChart
      label="Revenue"
      format={{ maximumFractionDigits: 1 }}
      categories={['Q1', 'Q2', 'Q3']}
      series={[{ name: 'EU', data: [1234.5, 2345.5, 3456.5] }]}
    />
  ],
  [
    'TimelineChart',
    <TimelineChart
      label="Plan"
      series={[
        {
          name: 'Design',
          data: [{ start: new Date(2026, 1, 3, 9, 30), end: new Date(2026, 2, 3, 17, 45) }]
        }
      ]}
    />
  ],
  [
    'PieChart',
    <PieChart
      label="Sessions"
      format={{ maximumFractionDigits: 0 }}
      categories={['Organic', 'Direct']}
      data={[18420, 9260]}
    />
  ],
  ['GaugeChart', <GaugeChart label="Load" value={1234.5} max={5000} />],
  [
    'HeatmapChart',
    <HeatmapChart
      label="Sessions"
      format={{ maximumFractionDigits: 1 }}
      categories={['00', '02']}
      series={[{ name: 'Mon', data: [1234.5, 2345.5] }]}
    />
  ],
  [
    'ScatterChart',
    <ScatterChart
      label="Pages"
      series={[
        {
          name: 'Organic',
          data: [
            { x: 1234.5, y: 2 },
            { x: 2345.5, y: 3 }
          ]
        }
      ]}
    />
  ],
  ['Statistic', <Statistic label="Revenue" value={48210} />],
  ['AnimateCounter', <AnimateCounter value={48210} />],
  ['Meter', <Meter label="Storage" value={38} showValue />],
  ['ProgressLinear', <ProgressLinear label="Uploading" value={64} showValue />],
  ['ProgressCircular', <ProgressCircular label="Uploading" value={64} showValue />],
  ['ProgressBox', <ProgressBox label="Uploading" value={64} showValue />],
  ['Slider', <Slider label="Budget" defaultValue={1234} max={5000} showValue />],
  ['NumberField', <NumberField label="Budget" defaultValue={1240.5} />],
  [
    'ContextWindow',
    <ContextWindow max={200_000} tokens={{ input: 94_200, output: 12_400 }} cost={0.42} />
  ],
  ['ColorPicker', <ColorPicker defaultValue="#1a58d1" />],
  [
    'DataTable',
    <DataTable<Build>
      label="Builds"
      headers={[
        { key: 'name', label: 'Name' },
        { key: 'shipped', label: 'Shipped' },
        { key: 'size', label: 'Size' }
      ]}
      items={[
        { name: 'web', shipped: JULY_27, size: 48210 },
        { name: 'api', shipped: new Date(2026, 6, 28), size: 1234.5 }
      ]}
      getRowKey={(row: Build) => row.name}
      paging="pages"
    />
  ],
  ['Reasoning', <Reasoning duration={2400}>Weighed the two options.</Reasoning>],
  ['ToolCall', <ToolCall name="deploy" status="success" duration={1840} />],
  [
    'AgentSteps',
    <AgentSteps>
      <AgentStep title="Read the request" duration={1840} />
    </AgentSteps>
  ]
];

/** Formats with the runtime default, as the library used to, and builds its formatter every render. */
function RuntimeDefault() {
  return <span>{new Intl.NumberFormat().format(48210)}</span>;
}

let remembered: Intl.NumberFormat | undefined;

/** The same, with the formatter memoised the way `internal/format.ts` does it. */
function RememberedRuntimeDefault() {
  remembered ??= new Intl.NumberFormat();

  return <span>{remembered.format(48210)}</span>;
}

describe('the stand-in runtime defaults', () => {
  // These two are what the library did before an unnamed locale was pinned: if
  // they hydrated cleanly, every assertion below would prove nothing.
  it('makes a component that formats with the runtime default fail to hydrate', async () => {
    const page = await serverThenHydrate(<RuntimeDefault />);

    try {
      expect(page.recoverable).not.toEqual([]);
    } finally {
      page.cleanup();
    }
  });

  it('still does when the formatter is memoised between the two renders', async () => {
    const page = await serverThenHydrate(<RememberedRuntimeDefault />);

    try {
      expect(page.recoverable).not.toEqual([]);
    } finally {
      page.cleanup();
    }
  });
});

describe('server-rendered and hydrated in another language', () => {
  it.each(cases)('%s hydrates without React reporting a mismatch', async (_, element) => {
    const page = await serverThenHydrate(element);

    try {
      expect(page.recoverable).toEqual([]);
    } finally {
      page.cleanup();
    }
  });

  it('writes an unnamed locale as en-US on the server, whatever the server speaks', async () => {
    const page = await serverThenHydrate(<DatePicker label="Ships on" defaultValue={JULY_27} />);

    try {
      expect(page.html).toContain(written('en-US', JULY_27, { dateStyle: 'medium' }));
      expect(page.html).not.toContain(written(SERVER_DEFAULT, JULY_27, { dateStyle: 'medium' }));
    } finally {
      page.cleanup();
    }
  });

  it("switches to the browser's language once hydration is over", async () => {
    const page = await serverThenHydrate(<Statistic label="Revenue" value={48210} />);

    try {
      await expect.poll(() => page.host.textContent).toContain(written(BROWSER_DEFAULT, 48210));
    } finally {
      page.cleanup();
    }
  });

  it("formats in the browser's language from the first frame of a tree that was never server-rendered", () => {
    const host = document.createElement('div');
    const root = createRoot(host);

    document.body.append(host);

    try {
      flushSync(() => root.render(<Statistic label="Revenue" value={48210} />));

      expect(host.textContent).toContain(written(BROWSER_DEFAULT, 48210));
      expect(host.textContent).not.toContain(written('en-US', 48210));
    } finally {
      root.unmount();
      host.remove();
    }
  });

  it('leaves a locale the caller named alone, on the server and after it', async () => {
    const page = await serverThenHydrate(
      <Statistic label="Revenue" value={48210} locale="fr-FR" />
    );

    try {
      const french = written('fr-FR', 48210);

      expect(page.html).toContain(french);
      expect(page.host.textContent).toContain(french);
      expect(page.recoverable).toEqual([]);
    } finally {
      page.cleanup();
    }
  });

  it('renders a component with a named locale once, and not again after hydration', async () => {
    const commits = (locale?: string) => {
      const phases: string[] = [];
      const element = (
        <React.Profiler id="statistic" onRender={(_, phase) => phases.push(phase)}>
          <Statistic label="Revenue" value={48210} locale={locale} />
        </React.Profiler>
      );

      return { phases, element };
    };

    // The unnamed locale has to change once hydration is over, which is the
    // render this test would miss if the Profiler could not see one.
    const unnamed = commits();
    const first = await serverThenHydrate(unnamed.element);

    first.cleanup();
    expect(unnamed.phases).toEqual(['mount', 'update']);

    const named = commits('fr-FR');
    const second = await serverThenHydrate(named.element);

    second.cleanup();
    expect(named.phases).toEqual(['mount']);
  });

  it("writes a run's duration in the language of the sentence around it", async () => {
    const page = await serverThenHydrate(
      <Reasoning duration={2400}>Weighed the two options.</Reasoning>
    );

    try {
      // English words around an English unit, on the server and in a German browser.
      expect(page.html).toContain('2.4s');
      expect(page.host.textContent).toContain('2.4s');
      expect(page.host.textContent).not.toContain('Sek');
    } finally {
      page.cleanup();
    }
  });
});

/** The strings a picker's trigger is held open by, in the order they are drawn. */
function samplesIn(root: ParentNode): string[] {
  return [...root.querySelectorAll('[data-sample]')].map(
    (node) => node.getAttribute('data-sample') ?? ''
  );
}

const pickers: [string, React.ReactElement<{ locale?: string }>][] = [
  ['DatePicker', <DatePicker label="Ships on" defaultValue={JULY_27} />],
  ['TimePicker', <TimePicker label="Starts at" defaultValue={MORNING} />],
  ['DateTimePicker', <DateTimePicker label="Publish at" defaultValue={MORNING} />],
  [
    'DateRangePicker',
    <DateRangePicker label="Stay" defaultValue={{ start: JULY_27, end: new Date(2026, 7, 3) }} />
  ]
];

describe("a picker's width across hydration", () => {
  // The server sized the trigger by its en-US dates and the browser re-sized it
  // by its own as soon as hydration was over, so a picker that is not
  // `fullWidth` narrowed under a German reader and the row beside it moved.
  it.each(pickers)('%s keeps every width the server sized it by', async (_, element) => {
    const page = await serverThenHydrate(element);

    try {
      const served = samplesIn(new DOMParser().parseFromString(page.html, 'text/html'));

      // Some of the browser's own by now, so hydration is over.
      await expect
        .poll(() => samplesIn(page.host).some((sample) => !served.includes(sample)))
        .toBe(true);

      expect(samplesIn(page.host)).toEqual(expect.arrayContaining(served));
      expect(page.recoverable).toEqual([]);
    } finally {
      page.cleanup();
    }
  });

  it.each(pickers)('%s mounted in the browser is sized by its own language alone', (_, element) => {
    const host = document.createElement('div');
    const named = document.createElement('div');
    const root = createRoot(host);
    const namedRoot = createRoot(named);

    document.body.append(host, named);

    try {
      flushSync(() => {
        root.render(element);
        namedRoot.render(React.cloneElement(element, { locale: BROWSER_DEFAULT }));
      });

      expect(samplesIn(host)).toEqual(samplesIn(named));
    } finally {
      root.unmount();
      namedRoot.unmount();
      host.remove();
      named.remove();
    }
  });
});

describe('a Calendar with nothing to say which month it opens on', () => {
  // A month the server's clock was in and the browser's is not: a page built
  // once and served the month after, which is every visitor to it.
  const now = new Date();
  const lastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 15);

  it("hydrates the month the server drew, whatever the browser's clock says", async () => {
    const page = await serverThenHydrate(<Calendar />, lastMonth);

    try {
      expect(page.html).toContain(written('en-US', lastMonth, { year: 'numeric', month: 'long' }));
      expect(page.recoverable).toEqual([]);
    } finally {
      page.cleanup();
    }
  });

  it("moves to the reader's month once hydration is over", async () => {
    const page = await serverThenHydrate(<Calendar />, lastMonth);

    try {
      // The caption the grid is named by, in the browser's language by now.
      await expect
        .poll(() => page.host.textContent)
        .toContain(written(BROWSER_DEFAULT, now, { year: 'numeric', month: 'long' }));
      expect(page.host.textContent).not.toContain(
        written(BROWSER_DEFAULT, lastMonth, { year: 'numeric', month: 'long' })
      );
      expect(page.recoverable).toEqual([]);
    } finally {
      page.cleanup();
    }
  });

  // The month moved one render after the grid placed its tab stop, so the
  // stop followed the month to its 1st rather than to today.
  it('puts the tab stop on today, as a calendar mounted in this browser does', async () => {
    const page = await serverThenHydrate(
      <Calendar />,
      new Date(2026, 7, 20),
      new Date(2026, 8, 17, 10)
    );

    try {
      await expect
        .poll(() => page.host.querySelector('[role="gridcell"][tabindex="0"]')?.textContent)
        .toBe('17');
      expect(
        page.host.querySelector('[role="gridcell"][tabindex="0"]')?.getAttribute('aria-current')
      ).toBe('date');
      expect(page.recoverable).toEqual([]);
    } finally {
      page.cleanup();
    }
  });

  it('stays on a month it was given', async () => {
    const page = await serverThenHydrate(<Calendar defaultMonth={lastMonth} />, lastMonth);

    try {
      await settle();

      expect(page.recoverable).toEqual([]);
      expect(page.host.textContent).toContain(
        written(BROWSER_DEFAULT, lastMonth, { year: 'numeric', month: 'long' })
      );
    } finally {
      page.cleanup();
    }
  });
});
