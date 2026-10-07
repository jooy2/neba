/**
 * A paging DataTable's page-size control, before and after its Select
 * arrives, measured with the stylesheet on.
 *
 * The Select is fetched on demand, and until it is here a stand-in draws the
 * closed control without it: on the server, in the render that hydrates, and
 * for the moment the chunk takes. The stand-in writes the Select's classes out
 * itself, so the two can drift apart without anything else noticing. This is
 * the check that they have not: every box is where it was and the trigger
 * carries the same classes when the Select takes over, whatever the provider
 * says about where a field's label goes.
 */
import { afterAll, afterEach, beforeAll, describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { DataTable, NebaProvider, Select, type NebaLabelPlacement } from 'neba';
import { rowsPerPageChunk } from '../../src/components/data-table/RowsPerPage.js';
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

afterEach(() => {
  vi.restoreAllMocks();
});

interface Row {
  id: string;
  name: string;
}

const items: Row[] = Array.from({ length: 30 }, (_, index) => ({
  id: String(index),
  name: `Row ${index}`
}));

/** Every box the control draws, and the trigger's classes. */
function measure(host: HTMLElement) {
  const trigger = host.querySelector<HTMLElement>('[role="combobox"]')!;
  const root = trigger.closest('div')!;
  const label = root.querySelector<HTMLElement>('label')!;
  const box = (element: Element) => {
    const { x, y, width, height } = element.getBoundingClientRect();

    return { x, y, width, height };
  };

  return {
    root: box(root),
    trigger: box(trigger),
    label: box(label),
    classes: trigger.className
  };
}

describe('the page-size control of a paging DataTable', () => {
  it.each<NebaLabelPlacement>(['top', 'notch', 'float'])(
    'stands in for its Select box for box, with the label %s',
    async (labelPlacement) => {
      let release: (module: { default: typeof Select }) => void = () => {};
      const gate = new Promise<{ default: typeof Select }>((resolve) => {
        release = resolve;
      });

      vi.spyOn(rowsPerPageChunk, 'arrived').mockReturnValue(false);
      vi.spyOn(rowsPerPageChunk, 'load').mockReturnValue(gate);

      const screen = await render(
        <NebaProvider defaults={{ labelPlacement }}>
          <div style={{ width: 640 }}>
            <DataTable<Row>
              headers={[{ key: 'name', label: 'Name' }]}
              items={items}
              getRowKey={(row) => row.id}
              paging="pages"
            />
          </div>
        </NebaProvider>
      );
      const standIn = () => screen.container.querySelector('[data-neba-stand-in]');

      await expect.poll(standIn).not.toBeNull();

      const before = measure(screen.container);

      release({ default: Select });
      await expect.poll(standIn).toBeNull();

      expect(measure(screen.container)).toEqual(before);
    }
  );
});
