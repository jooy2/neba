/**
 * What a phone-width box does to a layout, measured with the stylesheet on.
 *
 * No component test loads CSS, so a track that cannot shrink passes every one
 * of them and still pushes a page sideways on a phone.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { DataList, DataListItem } from 'neba';
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

describe('a narrow box', () => {
  // The label track was `max-content`, which cannot shrink: a long or
  // translated label made the list wider than the screen.
  it('wraps a DataList label rather than pushing the values out', async () => {
    const screen = await render(
      <div style={{ width: 300 }}>
        <DataList data-testid="list">
          <DataListItem label="Estimated monthly infrastructure spend after discounts">
            $1,204
          </DataListItem>
        </DataList>
      </div>
    );
    const list = screen.getByTestId('list').element() as HTMLElement;
    const value = screen.getByText('$1,204').element() as HTMLElement;

    await expect.element(screen.getByText('$1,204')).toBeInTheDocument();

    expect(list.scrollWidth).toBeLessThanOrEqual(300);
    expect(value.getBoundingClientRect().width).toBeGreaterThan(40);
  });
});
