import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
import { DataTable, type DataTableColumn } from 'neba';

interface Person {
  id: string;
  name: string;
  city: string;
  score: number;
}

const HEADERS: DataTableColumn<Person>[] = [
  { key: 'name', label: 'Name', width: 160 },
  { key: 'city', label: 'City' },
  { key: 'score', label: 'Score', align: 'end' }
];

const ITEMS: Person[] = [
  { id: 'a', name: 'Ada', city: 'Seoul', score: 30 },
  { id: 'b', name: 'Bo', city: 'Lisbon', score: 10 },
  { id: 'c', name: 'Cy', city: 'Oslo', score: 20 }
];

const key = (row: Person) => row.id;

/** A lot of rows, for the tests that are about not rendering all of them. */
function manyItems(count: number): Person[] {
  return Array.from({ length: count }, (_, index) => ({
    id: String(index),
    name: `Person ${index}`,
    city: `City ${index}`,
    score: index
  }));
}

/** The `<tr>`s that stand for a row, without the two virtual spacers. */
function bodyRows(container: HTMLElement): HTMLElement[] {
  return [...container.querySelectorAll<HTMLElement>('tbody tr[data-neba-row]')];
}

function cellText(container: HTMLElement, column: number): string[] {
  return bodyRows(container).map((row) => row.children[column].textContent ?? '');
}

describe('DataTable', () => {
  describe('rendering', () => {
    it('renders a table with one column per header', async () => {
      const screen = await render(<DataTable headers={HEADERS} items={ITEMS} getRowKey={key} />);

      await expect.element(screen.getByRole('table')).toBeInTheDocument();
      expect(screen.container.querySelectorAll('thead th')).toHaveLength(3);
    });

    it('renders one row per item and reads each cell off its key', async () => {
      const screen = await render(<DataTable headers={HEADERS} items={ITEMS} getRowKey={key} />);

      expect(bodyRows(screen.container)).toHaveLength(3);
      expect(cellText(screen.container, 1)).toEqual(['Seoul', 'Lisbon', 'Oslo']);
    });

    it('falls back to the key when a header has no label', async () => {
      const screen = await render(<DataTable headers={[{ key: 'city' }]} items={ITEMS} />);

      await expect.element(screen.getByRole('columnheader', { name: 'city' })).toBeInTheDocument();
    });

    it('hands the renderer the row and its place in the displayed order', async () => {
      const draw = vi.fn((row: Person, index: number) => `${index}:${row.name}`);
      const screen = await render(
        <DataTable headers={[{ key: 'name', render: draw }]} items={ITEMS} getRowKey={key} />
      );

      expect(cellText(screen.container, 0)).toEqual(['0:Ada', '1:Bo', '2:Cy']);
    });

    it('leaves a hidden column out', async () => {
      const screen = await render(
        <DataTable
          headers={[...HEADERS.slice(0, 2), { ...HEADERS[2], hidden: true }]}
          items={ITEMS}
          getRowKey={key}
        />
      );

      expect(screen.container.querySelectorAll('thead th')).toHaveLength(2);
    });

    it('reflects changed items on re-render', async () => {
      const screen = await render(<DataTable headers={HEADERS} items={ITEMS} getRowKey={key} />);

      await screen.rerender(<DataTable headers={HEADERS} items={[ITEMS[0]]} getRowKey={key} />);

      expect(bodyRows(screen.container)).toHaveLength(1);
    });

    it('says so when there are no rows', async () => {
      const screen = await render(<DataTable headers={HEADERS} items={[]} empty="Nobody here." />);

      await expect.element(screen.getByText('Nobody here.')).toBeInTheDocument();
    });

    it('states a column width on a col element', async () => {
      const screen = await render(<DataTable headers={HEADERS} items={ITEMS} getRowKey={key} />);
      const cols = [...screen.container.querySelectorAll<HTMLElement>('col')];

      expect(cols[0].style.width).toBe('160px');
      expect(cols[1].style.width).toBe('');
    });

    it('tints the rows the stripe names', async () => {
      const screen = await render(
        <DataTable headers={HEADERS} items={ITEMS} getRowKey={key} striped />
      );
      const rows = bodyRows(screen.container);

      expect(rows[0]).not.toHaveClass('[--n-row:var(--n-stripe)]');
      expect(rows[1]).toHaveClass('[--n-row:var(--n-stripe)]');

      await screen.rerender(
        <DataTable headers={HEADERS} items={ITEMS} getRowKey={key} striped="odd" />
      );

      expect(bodyRows(screen.container)[0]).toHaveClass('[--n-row:var(--n-stripe)]');
    });

    it('is drawn on a Box, so the sheet props pass through', async () => {
      const screen = await render(
        <DataTable
          headers={HEADERS}
          items={ITEMS}
          getRowKey={key}
          color="danger"
          elevation={2}
          data-testid="grid"
        />
      );
      const sheet = screen.getByTestId('grid').element() as HTMLElement;

      expect(sheet.style.getPropertyValue('--n-line')).toBe('var(--neba-danger-line)');
      expect(sheet.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-2)');
    });
  });

  describe('column groups', () => {
    const GROUPED: DataTableColumn<Person>[] = [
      { key: 'name', label: 'Name' },
      { key: 'city', label: 'City', group: 'Where' },
      { key: 'score', label: 'Score', group: 'Where' }
    ];

    it('merges adjacent columns under one heading', async () => {
      const screen = await render(<DataTable headers={GROUPED} items={ITEMS} getRowKey={key} />);
      const group = screen.container.querySelector('thead tr:first-child th:last-of-type');

      expect(screen.container.querySelectorAll('thead tr')).toHaveLength(2);
      expect(group).toHaveAttribute('colspan', '2');
    });

    it('spans an ungrouped column across both header rows', async () => {
      const screen = await render(<DataTable headers={GROUPED} items={ITEMS} getRowKey={key} />);

      expect(screen.getByRole('columnheader', { name: 'Name' }).element()).toHaveAttribute(
        'rowspan',
        '2'
      );
    });
  });

  describe('sorting', () => {
    it('does nothing until a column is sortable', async () => {
      const screen = await render(<DataTable headers={HEADERS} items={ITEMS} getRowKey={key} />);

      expect(screen.getByRole('button', { name: 'City' }).query()).toBeNull();
    });

    it('cycles ascending, descending and back to the original order', async () => {
      const screen = await render(
        <DataTable headers={HEADERS} items={ITEMS} getRowKey={key} sortable />
      );
      const heading = screen.getByRole('button', { name: 'City' });

      await heading.click();
      expect(cellText(screen.container, 1)).toEqual(['Lisbon', 'Oslo', 'Seoul']);

      await heading.click();
      expect(cellText(screen.container, 1)).toEqual(['Seoul', 'Oslo', 'Lisbon']);

      await heading.click();
      expect(cellText(screen.container, 1)).toEqual(['Seoul', 'Lisbon', 'Oslo']);
    });

    it('marks the sorted column with aria-sort', async () => {
      const screen = await render(
        <DataTable headers={HEADERS} items={ITEMS} getRowKey={key} sortable />
      );

      await screen.getByRole('button', { name: 'City' }).click();

      await expect
        .element(screen.getByRole('columnheader', { name: 'City' }))
        .toHaveAttribute('aria-sort', 'ascending');
    });

    it('sorts numbers as numbers', async () => {
      const screen = await render(
        <DataTable headers={HEADERS} items={ITEMS} getRowKey={key} sortable />
      );

      await screen.getByRole('button', { name: 'Score' }).click();

      expect(cellText(screen.container, 2)).toEqual(['10', '20', '30']);
    });

    it('uses the column comparator when one is given', async () => {
      const order = ['Oslo', 'Seoul', 'Lisbon'];
      const headers: DataTableColumn<Person>[] = [
        {
          key: 'city',
          label: 'City',
          compare: (a, b) => order.indexOf(a.city) - order.indexOf(b.city)
        }
      ];
      const screen = await render(
        <DataTable headers={headers} items={ITEMS} getRowKey={key} sortable />
      );

      await screen.getByRole('button', { name: 'City' }).click();

      expect(cellText(screen.container, 0)).toEqual(order);
    });

    it('reports the sort and honours a controlled one', async () => {
      const onSortChange = vi.fn();
      const screen = await render(
        <DataTable
          headers={HEADERS}
          items={ITEMS}
          getRowKey={key}
          sortable
          sort={[{ key: 'score', direction: 'desc' }]}
          onSortChange={onSortChange}
        />
      );

      expect(cellText(screen.container, 2)).toEqual(['30', '20', '10']);

      await screen.getByRole('button', { name: 'Score' }).click();

      expect(onSortChange).toHaveBeenCalledWith([]);
      // Controlled: the rows do not move until the caller says so.
      expect(cellText(screen.container, 2)).toEqual(['30', '20', '10']);
    });

    it('leaves the rows alone when the caller has already sorted', async () => {
      const screen = await render(
        <DataTable headers={HEADERS} items={ITEMS} getRowKey={key} sortable manual={['sort']} />
      );

      await screen.getByRole('button', { name: 'City' }).click();

      expect(cellText(screen.container, 1)).toEqual(['Seoul', 'Lisbon', 'Oslo']);
    });
  });

  describe('search and filter', () => {
    it('matches every searchable column, ignoring case and accents', async () => {
      const screen = await render(
        <DataTable headers={HEADERS} items={ITEMS} getRowKey={key} search="LISBON" />
      );

      expect(cellText(screen.container, 0)).toEqual(['Bo']);
    });

    it('skips a column that opts out', async () => {
      const headers: DataTableColumn<Person>[] = [HEADERS[0], { ...HEADERS[1], searchable: false }];
      const screen = await render(
        <DataTable headers={headers} items={ITEMS} getRowKey={key} search="Lisbon" />
      );

      expect(bodyRows(screen.container)).toHaveLength(0);
    });

    it('types into its own field and reports the query', async () => {
      const onSearchChange = vi.fn();
      const screen = await render(
        <DataTable
          headers={HEADERS}
          items={ITEMS}
          getRowKey={key}
          searchable
          onSearchChange={onSearchChange}
        />
      );

      await screen.getByRole('searchbox').fill('Oslo');

      expect(onSearchChange).toHaveBeenLastCalledWith('Oslo');
      expect(cellText(screen.container, 0)).toEqual(['Cy']);
    });

    it('applies the caller’s own filter after the search', async () => {
      const screen = await render(
        <DataTable
          headers={HEADERS}
          items={ITEMS}
          getRowKey={key}
          filter={(row) => row.score >= 20}
        />
      );

      expect(cellText(screen.container, 0)).toEqual(['Ada', 'Cy']);
    });
  });

  describe('paging', () => {
    it('cuts the rows into pages and steps through them', async () => {
      const screen = await render(
        <DataTable
          headers={HEADERS}
          items={manyItems(10)}
          getRowKey={key}
          paging="pages"
          defaultPageSize={4}
        />
      );

      expect(bodyRows(screen.container)).toHaveLength(4);

      await screen.getByRole('button', { name: 'Page 2' }).click();

      expect(cellText(screen.container, 0)).toEqual([
        'Person 4',
        'Person 5',
        'Person 6',
        'Person 7'
      ]);
    });

    it('counts the rows in the footer', async () => {
      const screen = await render(
        <DataTable
          headers={HEADERS}
          items={manyItems(10)}
          getRowKey={key}
          paging="pages"
          defaultPageSize={4}
        />
      );

      await expect.element(screen.getByText('1–4 of 10')).toBeInTheDocument();
    });

    it('takes the total from rowCount when the caller is paging', async () => {
      const screen = await render(
        <DataTable
          headers={HEADERS}
          items={ITEMS}
          getRowKey={key}
          paging="pages"
          manual={['pages']}
          rowCount={120}
          defaultPageSize={3}
        />
      );

      expect(bodyRows(screen.container)).toHaveLength(3);
      await expect.element(screen.getByText('1–3 of 120')).toBeInTheDocument();
    });

    it('moves back into range when a search shortens the table', async () => {
      const screen = await render(
        <DataTable
          headers={HEADERS}
          items={manyItems(10)}
          getRowKey={key}
          paging="pages"
          defaultPageSize={4}
          page={3}
        />
      );

      await screen.rerender(
        <DataTable
          headers={HEADERS}
          items={manyItems(10)}
          getRowKey={key}
          paging="pages"
          defaultPageSize={4}
          page={3}
          search="Person 1"
        />
      );

      // One row matches, so there is one page. Left on page 3 the slice would
      // start past the end and the search would answer with nothing.
      expect(cellText(screen.container, 0)).toEqual(['Person 1']);
    });
  });

  describe('virtual scrolling', () => {
    it('renders a window of the rows rather than all of them', async () => {
      const screen = await render(
        <DataTable headers={HEADERS} items={manyItems(5000)} getRowKey={key} height={200} />
      );

      await expect.poll(() => bodyRows(screen.container).length).toBeLessThan(60);
      expect(bodyRows(screen.container).length).toBeGreaterThan(0);
    });

    it('stands the missing rows up as spacers, so the scrollbar is honest', async () => {
      const screen = await render(
        <DataTable
          headers={HEADERS}
          items={manyItems(1000)}
          getRowKey={key}
          height={200}
          rowHeight={24}
        />
      );
      const table = screen.container.querySelector('table')!;

      await expect.poll(() => table.getBoundingClientRect().height).toBeGreaterThan(1000 * 24);
    });

    it('renders every row when nothing bounds the height', async () => {
      const screen = await render(
        <DataTable headers={HEADERS} items={manyItems(120)} getRowKey={key} />
      );

      expect(bodyRows(screen.container)).toHaveLength(120);
    });

    it('renders every row when virtual is off', async () => {
      const screen = await render(
        <DataTable
          headers={HEADERS}
          items={manyItems(120)}
          getRowKey={key}
          height={200}
          virtual={false}
        />
      );

      expect(bodyRows(screen.container)).toHaveLength(120);
    });
  });

  describe('selection', () => {
    it('chooses nothing until a mode is set', async () => {
      const onSelectedChange = vi.fn();
      const screen = await render(
        <DataTable
          headers={HEADERS}
          items={ITEMS}
          getRowKey={key}
          onSelectedChange={onSelectedChange}
        />
      );

      await screen.getByText('Seoul').click();

      expect(onSelectedChange).not.toHaveBeenCalled();
    });

    it('reports the keys and the rows behind them', async () => {
      const onSelectedChange = vi.fn();
      const screen = await render(
        <DataTable
          headers={HEADERS}
          items={ITEMS}
          getRowKey={key}
          selectionMode="single"
          onSelectedChange={onSelectedChange}
        />
      );

      await screen.getByText('Lisbon').click();

      expect(onSelectedChange).toHaveBeenCalledWith(['b'], [ITEMS[1]]);
      await expect.element(screen.getByRole('row', { selected: true })).toBeInTheDocument();
    });

    it('drops the previous row on a plain click', async () => {
      const screen = await render(
        <DataTable headers={HEADERS} items={ITEMS} getRowKey={key} selectionMode="multiple" />
      );

      await screen.getByText('Seoul').click();
      await screen.getByText('Oslo').click();

      expect(screen.container.querySelectorAll('tr[aria-selected="true"]')).toHaveLength(1);
    });

    it('adds a row with the meta key and takes a run with shift', async () => {
      const onSelectedChange = vi.fn();
      const screen = await render(
        <DataTable
          headers={HEADERS}
          items={ITEMS}
          getRowKey={key}
          selectionMode="multiple"
          onSelectedChange={onSelectedChange}
        />
      );

      await screen.getByText('Seoul').click();
      await userEvent.keyboard('{Control>}');
      await screen.getByText('Oslo').click();
      await userEvent.keyboard('{/Control}');

      expect(onSelectedChange).toHaveBeenLastCalledWith(['a', 'c'], [ITEMS[0], ITEMS[2]]);

      await screen.getByText('Seoul').click();
      await userEvent.keyboard('{Shift>}');
      await screen.getByText('Oslo').click();
      await userEvent.keyboard('{/Shift}');

      expect(onSelectedChange).toHaveBeenLastCalledWith(
        ['a', 'b', 'c'],
        [ITEMS[0], ITEMS[1], ITEMS[2]]
      );
    });

    it('keeps a single-select table to one row however it is clicked', async () => {
      const onSelectedChange = vi.fn();
      const screen = await render(
        <DataTable
          headers={HEADERS}
          items={ITEMS}
          getRowKey={key}
          selectionMode="single"
          onSelectedChange={onSelectedChange}
        />
      );

      await screen.getByText('Seoul').click();
      await userEvent.keyboard('{Control>}');
      await screen.getByText('Oslo').click();
      await userEvent.keyboard('{/Control}');

      expect(onSelectedChange).toHaveBeenLastCalledWith(['c'], [ITEMS[2]]);
    });

    it('walks the rows with the arrow keys, choosing as it goes', async () => {
      const screen = await render(
        <DataTable headers={HEADERS} items={ITEMS} getRowKey={key} selectionMode="multiple" />
      );

      await screen.getByText('Seoul').click();
      await userEvent.keyboard('{ArrowDown}');

      await expect
        .element(screen.getByRole('row', { selected: true }))
        .toHaveAttribute('data-neba-row', 'b');

      await userEvent.keyboard('{Shift>}{ArrowDown}{/Shift}');

      expect(screen.container.querySelectorAll('tr[aria-selected="true"]')).toHaveLength(2);
    });

    it('takes everything with Ctrl+A and lets go with Escape', async () => {
      const screen = await render(
        <DataTable headers={HEADERS} items={ITEMS} getRowKey={key} selectionMode="multiple" />
      );

      await screen.getByText('Seoul').click();
      await userEvent.keyboard('{Control>}a{/Control}');

      expect(screen.container.querySelectorAll('tr[aria-selected="true"]')).toHaveLength(3);

      await userEvent.keyboard('{Escape}');

      expect(screen.container.querySelectorAll('tr[aria-selected="true"]')).toHaveLength(0);
    });

    it('opens a row on Enter and on a double click', async () => {
      const onRowActivate = vi.fn();
      const screen = await render(
        <DataTable
          headers={HEADERS}
          items={ITEMS}
          getRowKey={key}
          selectionMode="single"
          onRowActivate={onRowActivate}
        />
      );

      await screen.getByText('Lisbon').dblClick();
      expect(onRowActivate).toHaveBeenLastCalledWith(ITEMS[1], 1);

      await userEvent.keyboard('{Enter}');
      expect(onRowActivate).toHaveBeenLastCalledWith(ITEMS[1], 1);
    });

    // Nothing loads Tailwind into the test run, so a tick renders at zero size
    // and Playwright will not click something it cannot see. These press it
    // with the keyboard instead, which is a path a real reader takes and which
    // the tick — a `<span role="checkbox" tabindex="0">` — has to answer anyway.
    async function pressTick(element: HTMLElement) {
      element.focus();
      await userEvent.keyboard(' ');
    }

    it('ticks a row and every row from the header', async () => {
      const screen = await render(
        <DataTable
          headers={HEADERS}
          items={ITEMS}
          getRowKey={key}
          selectionMode="multiple"
          checkboxes
        />
      );

      const all = screen.getByRole('checkbox', { name: 'Select all rows' }).element();

      await pressTick(
        screen.getByRole('checkbox', { name: 'Select row' }).first().element() as HTMLElement
      );
      expect(screen.container.querySelectorAll('tr[aria-selected="true"]')).toHaveLength(1);

      await expect
        .element(screen.getByRole('checkbox', { name: 'Select all rows' }))
        .toHaveAttribute('aria-checked', 'mixed');

      await pressTick(all as HTMLElement);
      expect(screen.container.querySelectorAll('tr[aria-selected="true"]')).toHaveLength(3);

      await pressTick(all as HTMLElement);
      expect(screen.container.querySelectorAll('tr[aria-selected="true"]')).toHaveLength(0);
    });

    it('honours a controlled selection', async () => {
      const screen = await render(
        <DataTable
          headers={HEADERS}
          items={ITEMS}
          getRowKey={key}
          selectionMode="multiple"
          selected={['c']}
        />
      );

      await expect
        .element(screen.getByRole('row', { selected: true }))
        .toHaveAttribute('data-neba-row', 'c');

      await screen.getByText('Seoul').click();

      // Still `c`: a controlled table shows what it was told to show.
      await expect
        .element(screen.getByRole('row', { selected: true }))
        .toHaveAttribute('data-neba-row', 'c');
    });

    it('is a grid with one tab stop, so a virtual row never holds the focus', async () => {
      const screen = await render(
        <DataTable headers={HEADERS} items={ITEMS} getRowKey={key} selectionMode="multiple" />
      );
      const table = screen.container.querySelector('table')!;

      expect(table).toHaveAttribute('role', 'grid');
      expect(table).toHaveAttribute('tabindex', '0');
      expect(bodyRows(screen.container)[0]).not.toHaveAttribute('tabindex');
    });
  });

  describe('resizing', () => {
    it('draws no handle until it is asked for', async () => {
      const screen = await render(<DataTable headers={HEADERS} items={ITEMS} getRowKey={key} />);

      expect(screen.container.querySelector('.cursor-col-resize')).toBeNull();
    });

    it('drags a column wider and freezes the rest where they were', async () => {
      const screen = await render(
        <DataTable headers={HEADERS} items={ITEMS} getRowKey={key} resizable />
      );
      const handle = screen.container.querySelector<HTMLElement>('.cursor-col-resize')!;
      const from = handle.getBoundingClientRect();

      handle.setPointerCapture = () => {};
      handle.dispatchEvent(
        new PointerEvent('pointerdown', {
          bubbles: true,
          clientX: from.x,
          pointerId: 1,
          button: 0
        })
      );
      handle.dispatchEvent(
        new PointerEvent('pointermove', { bubbles: true, clientX: from.x + 60 })
      );
      handle.dispatchEvent(new PointerEvent('pointerup', { bubbles: true }));

      const cols = [...screen.container.querySelectorAll<HTMLElement>('col')];

      await expect.poll(() => cols[0].style.width).toBe('220px');
      expect(cols[1].style.width).not.toBe('');
    });

    // The three other components that drag something have always done this;
    // the column resize was the copy that did not, so dragging a boundary in
    // Safari selected the text of every cell the pointer crossed.
    it('takes the page\u2019s text selection for the length of the drag', async () => {
      const screen = await render(
        <DataTable headers={HEADERS} items={ITEMS} getRowKey={key} resizable />
      );
      const handle = screen.container.querySelector<HTMLElement>('.cursor-col-resize')!;
      const from = handle.getBoundingClientRect();
      const held = () => document.body.style.getPropertyValue('-webkit-user-select');

      expect(held()).toBe('');

      handle.setPointerCapture = () => {};
      handle.dispatchEvent(
        new PointerEvent('pointerdown', {
          bubbles: true,
          clientX: from.x,
          pointerId: 1,
          button: 0
        })
      );

      expect(held()).toBe('none');
      expect(handle).toHaveAttribute('data-dragging');

      handle.dispatchEvent(new PointerEvent('pointerup', { bubbles: true }));

      // Removed rather than blanked, so a page that never wrote the property
      // inline is left with the declaration it actually had.
      expect(held()).toBe('');
      expect(handle).not.toHaveAttribute('data-dragging');
    });

    it('reports the widths and honours controlled ones', async () => {
      const screen = await render(
        <DataTable
          headers={HEADERS}
          items={ITEMS}
          getRowKey={key}
          resizable
          columnWidths={{ city: 90 }}
        />
      );
      const cols = [...screen.container.querySelectorAll<HTMLElement>('col')];

      expect(cols[1].style.width).toBe('90px');
    });
  });
});
