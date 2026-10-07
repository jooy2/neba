/**
 * A server-rendered Tabs bar, checked against the stylesheet.
 *
 * Base UI keeps the indicator `hidden` until it has measured the chosen tab,
 * which only a running browser can do, so before hydration the chosen tab
 * draws the indicator's look itself. Whether it does, and whether it hands
 * over to the indicator in the same frame, is decided by rules no component
 * test loads.
 */
import * as React from 'react';
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { renderToString } from 'react-dom/server';
import { hydrateRoot } from 'react-dom/client';
import { Tab, TabPanel, Tabs, type TabsProps } from 'neba';
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

const bar = (props: Partial<TabsProps>) => (
  <Tabs defaultValue="b" {...props}>
    <Tab value="a">Overview</Tab>
    <Tab value="b">Activity</Tab>
    <Tab value="c">Settings</Tab>
    <TabPanel value="b">Panel</TabPanel>
  </Tabs>
);

function serve(element: React.ReactElement) {
  const host = document.createElement('div');

  host.innerHTML = renderToString(element);
  document.body.append(host);

  const chosen = host.querySelector<HTMLElement>('[role="tab"][data-active]')!;
  const indicator = host.querySelector<HTMLElement>('.neba-tabs-indicator')!;

  return { host, chosen, indicator };
}

const transparent = 'rgba(0, 0, 0, 0)';

describe('a server-rendered Tabs bar under the stylesheet', () => {
  it('draws the tile on the chosen tab of a solid bar while the indicator is hidden', () => {
    const { host, chosen, indicator } = serve(bar({ variant: 'solid' }));

    try {
      const tile = getComputedStyle(chosen, '::after');

      expect(indicator).toHaveAttribute('hidden');
      expect(tile.content).not.toBe('none');
      expect(tile.opacity).toBe('1');
      expect(tile.backgroundColor).not.toBe(transparent);
      expect(tile.boxShadow).not.toBe('none');
      expect(tile.zIndex).toBe('-1');
    } finally {
      host.remove();
    }
  });

  it.each(['outline', 'text'] as const)(
    'draws the line under the chosen tab of a %s bar, and beside it when vertical',
    (variant) => {
      const across = serve(bar({ variant }));
      const down = serve(bar({ variant, orientation: 'vertical' }));

      try {
        const under = getComputedStyle(across.chosen, '::after');
        const beside = getComputedStyle(down.chosen, '::after');

        expect(under.height).toBe('2px');
        expect(under.bottom).toBe('0px');
        expect(under.backgroundColor).not.toBe(transparent);
        expect(beside.width).toBe('2px');
        expect(beside.backgroundColor).not.toBe(transparent);
      } finally {
        across.host.remove();
        down.host.remove();
      }
    }
  );

  it('draws the line along the tab itself on a bar that wraps', () => {
    const { host, chosen } = serve(bar({ variant: 'outline', overflow: 'wrap' }));

    try {
      const line = getComputedStyle(chosen, '::after');

      expect(line.borderBottomWidth).toBe('2px');
      expect(line.backgroundColor).toBe(transparent);
    } finally {
      host.remove();
    }
  });

  it('leaves the other tabs alone', () => {
    const { host } = serve(bar({ variant: 'solid' }));

    try {
      const other = host.querySelector<HTMLElement>('[role="tab"]:not([data-active])')!;

      expect(getComputedStyle(other, '::after').backgroundColor).toBe(transparent);
    } finally {
      host.remove();
    }
  });

  it('hands over to the indicator on hydration without moving anything', async () => {
    const element = bar({ variant: 'solid' });
    const { host, chosen, indicator } = serve(element);
    let shifts = 0;
    const observer = new PerformanceObserver((list) => {
      shifts += list.getEntries().length;
    });

    observer.observe({ type: 'layout-shift' });

    const root = hydrateRoot(host, element);

    try {
      await vi.waitFor(() => expect(indicator).not.toHaveAttribute('hidden'));

      // Back to the afterglow, which a tab leaves without a colour.
      const after = getComputedStyle(chosen, '::after');

      expect(after.backgroundColor).toBe(transparent);
      expect(after.boxShadow).toBe('none');
      expect(getComputedStyle(indicator).display).not.toBe('none');

      await new Promise((resolve) => setTimeout(resolve, 100));

      expect(shifts).toBe(0);
    } finally {
      observer.disconnect();
      root.unmount();
      host.remove();
    }
  });
});
