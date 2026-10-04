/**
 * The two looping sweeps — a Skeleton's highlight and an indeterminate
 * ProgressLinear's segment — checked against the stylesheet.
 *
 * A box moved by a layout property is a layout shift to the browser, reported on
 * every frame for as long as it runs, and a consumer's CLS adds them up: a
 * full-width placeholder sweeping on `inset-inline-start` scored 0.27 on a page
 * that was otherwise standing still. Nothing in a component test would notice,
 * because no component test loads CSS.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { ProgressLinear, Skeleton } from 'neba';
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

/** Every property a keyframe of the named animation sets. */
function keyframeProperties(name: string): string[] {
  for (const styleSheet of document.styleSheets) {
    for (const rule of styleSheet.cssRules) {
      if (rule instanceof CSSKeyframesRule && rule.name === name) {
        return [...rule.cssRules].flatMap((frame) => [...(frame as CSSKeyframeRule).style]);
      }
    }
  }

  return [];
}

/** How many layout shifts the browser reports in the next `wait` milliseconds. */
async function shiftsDuring(wait: number): Promise<number> {
  let count = 0;
  const observer = new PerformanceObserver((list) => {
    count += list.getEntries().length;
  });

  observer.observe({ type: 'layout-shift' });
  await new Promise((resolve) => setTimeout(resolve, wait));
  observer.disconnect();

  return count;
}

describe('the looping sweeps', () => {
  it.each(['neba-skeleton-sweep', 'neba-sweep'])('%s moves on translate alone', (name) => {
    const properties = keyframeProperties(name);

    expect(properties.length).toBeGreaterThan(0);
    expect(new Set(properties)).toEqual(new Set(['translate']));
  });

  it('reports no layout shift while a placeholder sweeps', async () => {
    await render(
      <div style={{ width: 800 }}>
        <Skeleton shape="rect" height={120} />
      </div>
    );

    expect(await shiftsDuring(700)).toBe(0);
  });

  it('reports no layout shift while an indeterminate bar sweeps', async () => {
    await render(
      <div style={{ width: 800 }}>
        <ProgressLinear label="Loading" />
      </div>
    );

    expect(await shiftsDuring(700)).toBe(0);
  });

  it('turns the sweep around under right-to-left, and back for an island inside it', async () => {
    const screen = await render(
      <div dir="rtl">
        <Skeleton data-testid="rtl" />
        <div dir="ltr">
          <Skeleton data-testid="island" />
        </div>
      </div>
    );
    const direction = (testId: string) =>
      getComputedStyle(screen.getByTestId(testId).element(), '::after')
        .getPropertyValue('--n-sweep-dir')
        .trim();

    expect(direction('rtl')).toBe('-1');
    expect(direction('island')).toBe('1');
  });
});
