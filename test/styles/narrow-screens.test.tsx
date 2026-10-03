/**
 * What a phone-width box does to a layout, measured with the stylesheet on.
 *
 * No component test loads CSS, so a track that cannot shrink passes every one
 * of them and still pushes a page sideways on a phone.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { DataList, DataListItem, Slider } from 'neba';
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

  // Centred on their ticks, the labels at `min` and `max` hung half their width
  // past the track, and in a narrow column past the edge of the column too.
  it('keeps the labels at either end of a Slider inside its box', async () => {
    const screen = await render(
      <div data-testid="column" style={{ width: 200 }}>
        <Slider
          aria-label="Temperature"
          marks={[
            { value: 0, label: 'Precise' },
            { value: 50, label: 'Balanced' },
            { value: 100, label: 'Creative' }
          ]}
        />
      </div>
    );

    await expect.element(screen.getByText('Creative')).toBeInTheDocument();

    const column = screen.getByTestId('column').element().getBoundingClientRect();
    const first = screen.getByText('Precise').element().getBoundingClientRect();
    const last = screen.getByText('Creative').element().getBoundingClientRect();

    expect(first.left).toBeGreaterThanOrEqual(column.left);
    expect(last.right).toBeLessThanOrEqual(column.right);
  });
});
