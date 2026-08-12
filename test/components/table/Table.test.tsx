import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
import { Table, type TableColumn } from 'neba';

interface Deploy {
  id: string;
  env: string;
  status: string;
  minutes: number;
}

const HEADERS: TableColumn<Deploy>[] = [
  { key: 'env', label: 'Environment', width: 160 },
  { key: 'status', label: 'Status' },
  { key: 'minutes', label: 'Duration', align: 'end', render: (row) => `${row.minutes} min` }
];

const ITEMS: Deploy[] = [
  { id: 'a', env: 'production', status: 'Live', minutes: 4 },
  { id: 'b', env: 'staging', status: 'Building', minutes: 2 }
];

describe('Table', () => {
  describe('rendering', () => {
    it('renders a table with one column per header', async () => {
      const screen = await render(<Table headers={HEADERS} items={ITEMS} />);

      await expect.element(screen.getByRole('table')).toBeInTheDocument();
      expect(screen.container.querySelectorAll('th')).toHaveLength(3);
    });

    it('renders the headings', async () => {
      const screen = await render(<Table headers={HEADERS} items={ITEMS} />);

      await expect
        .element(screen.getByRole('columnheader', { name: 'Environment' }))
        .toBeInTheDocument();
    });

    it('falls back to the key when a header has no label', async () => {
      const screen = await render(<Table headers={[{ key: 'env' }]} items={ITEMS} />);

      await expect.element(screen.getByRole('columnheader', { name: 'env' })).toBeInTheDocument();
    });

    it('renders one row per item', async () => {
      const screen = await render(<Table headers={HEADERS} items={ITEMS} />);

      expect(screen.container.querySelectorAll('tbody tr')).toHaveLength(2);
    });

    it('reads each cell off the row by the column key', async () => {
      const screen = await render(<Table headers={HEADERS} items={ITEMS} />);

      await expect.element(screen.getByText('production')).toBeInTheDocument();
      await expect.element(screen.getByText('Building')).toBeInTheDocument();
    });

    it('uses the column renderer when one is given', async () => {
      const screen = await render(<Table headers={HEADERS} items={ITEMS} />);

      await expect.element(screen.getByText('4 min')).toBeInTheDocument();
    });

    it('hands the renderer the row and its index', async () => {
      const render_ = vi.fn((row: Deploy, index: number) => `${index}:${row.env}`);
      const screen = await render(
        <Table headers={[{ key: 'env', render: render_ }]} items={ITEMS} />
      );

      await expect.element(screen.getByText('0:production')).toBeInTheDocument();
      await expect.element(screen.getByText('1:staging')).toBeInTheDocument();
    });

    it('renders a caption when given one', async () => {
      const screen = await render(
        <Table headers={HEADERS} items={ITEMS} caption="Recent deploys" />
      );

      await expect.element(screen.getByText('Recent deploys')).toBeInTheDocument();
      expect(screen.container.querySelector('caption')).not.toBeNull();
    });

    it('reflects changed items on re-render', async () => {
      const screen = await render(<Table headers={HEADERS} items={ITEMS} />);

      await screen.rerender(<Table headers={HEADERS} items={[ITEMS[0]]} />);

      expect(screen.container.querySelectorAll('tbody tr')).toHaveLength(1);
      expect(screen.getByText('staging').query()).toBeNull();
    });
  });

  describe('widths', () => {
    it('states a column width once, on a col element', async () => {
      const screen = await render(<Table headers={HEADERS} items={ITEMS} />);
      const cols = [...screen.container.querySelectorAll('col')];

      expect(cols).toHaveLength(3);
      expect((cols[0] as HTMLElement).style.width).toBe('160px');
      expect((cols[1] as HTMLElement).style.width).toBe('');
    });

    it('takes a CSS length as well as a number', async () => {
      const screen = await render(<Table headers={[{ key: 'env', width: '40%' }]} items={ITEMS} />);

      expect((screen.container.querySelector('col') as HTMLElement).style.width).toBe('40%');
    });

    // Padding, alignment, backgrounds and the row rules are written inline
    // rather than as utilities: a `<td>` is styled by tag name in every host
    // stylesheet that has an opinion about prose, at a specificity no utility
    // can outrank. These assertions are on `style` for exactly that reason.
    it('aligns a column the way the header says', async () => {
      const screen = await render(<Table headers={HEADERS} items={ITEMS} />);
      const cells = screen.container.querySelectorAll<HTMLElement>('tbody tr:first-child td');

      expect(cells[0].style.textAlign).toBe('start');
      expect(cells[2].style.textAlign).toBe('end');
    });

    it('draws the rule between rows inline, so a host stylesheet cannot erase it', async () => {
      const screen = await render(<Table headers={HEADERS} items={ITEMS} />);
      const row = screen.container.querySelector('tbody tr') as HTMLElement;

      expect(row.style.borderTop).toBe('1px solid var(--n-line)');
    });
  });

  describe('empty', () => {
    it('says so when there are no rows', async () => {
      const screen = await render(<Table headers={HEADERS} items={[]} />);

      await expect.element(screen.getByText('No data')).toBeInTheDocument();
    });

    it('takes a custom empty state spanning every column', async () => {
      const screen = await render(
        <Table headers={HEADERS} items={[]} empty="Nothing deployed yet." />
      );

      await expect.element(screen.getByText('Nothing deployed yet.')).toBeInTheDocument();
      expect(screen.container.querySelector('tbody td')).toHaveAttribute('colspan', '3');
    });
  });

  describe('behaviour', () => {
    it('reports the clicked row and its index', async () => {
      const onRowClick = vi.fn();
      const screen = await render(
        <Table headers={HEADERS} items={ITEMS} onRowClick={onRowClick} />
      );

      await screen.getByText('staging').click();

      expect(onRowClick).toHaveBeenCalledTimes(1);
      expect(onRowClick).toHaveBeenCalledWith(ITEMS[1], 1);
    });

    it('puts a pressable row in the tab order and answers Enter and Space', async () => {
      const onRowClick = vi.fn();
      const screen = await render(
        <Table headers={HEADERS} items={ITEMS} onRowClick={onRowClick} />
      );

      const row = screen.container.querySelectorAll('tbody tr')[1] as HTMLElement;
      expect(row).toHaveAttribute('tabindex', '0');

      row.focus();
      await userEvent.keyboard('{Enter}');

      expect(onRowClick).toHaveBeenCalledTimes(1);
      expect(onRowClick).toHaveBeenCalledWith(ITEMS[1], 1);

      await userEvent.keyboard(' ');

      expect(onRowClick).toHaveBeenCalledTimes(2);
    });

    it('keeps a row nobody can press out of the tab order', async () => {
      const screen = await render(<Table headers={HEADERS} items={ITEMS} hoverable />);

      expect(screen.container.querySelector('tbody tr')).not.toHaveAttribute('tabindex');
    });

    /*
     * A cell can hold a control of its own, and that control's Enter belongs to
     * it. The row's key handler stays out of the way entirely: what still
     * reaches the row is the click the button raises, which is the same thing a
     * pointer press on it has always sent up — so the row fires once, not twice.
     */
    it('does not answer a key pressed on a control inside a cell twice', async () => {
      const onRowClick = vi.fn();
      const onOpen = vi.fn();
      const headers: TableColumn<Deploy>[] = [
        ...HEADERS,
        {
          key: 'action',
          label: 'Action',
          render: (row) => (
            <button type="button" onClick={onOpen}>
              {`Open ${row.env}`}
            </button>
          )
        }
      ];
      const screen = await render(
        <Table headers={headers} items={ITEMS} onRowClick={onRowClick} />
      );

      await screen.getByRole('button', { name: 'Open staging' }).element().focus();
      await userEvent.keyboard('{Enter}');

      expect(onOpen).toHaveBeenCalledTimes(1);
      expect(onRowClick).toHaveBeenCalledTimes(1);
    });

    it('lights the row under the pointer only when it is meant to', async () => {
      const screen = await render(<Table headers={HEADERS} items={ITEMS} />);
      const row = screen.container.querySelector('tbody tr')!;

      expect(row).not.toHaveClass('hover:[--n-row:var(--n-soft)]');

      await screen.rerender(<Table headers={HEADERS} items={ITEMS} hoverable />);

      expect(screen.container.querySelector('tbody tr')).toHaveClass(
        'hover:[--n-row:var(--n-soft)]'
      );
    });

    it('tints every other row when striped', async () => {
      const screen = await render(<Table headers={HEADERS} items={ITEMS} striped />);
      const rows = screen.container.querySelectorAll('tbody tr');

      expect(rows[0]).not.toHaveClass('[--n-row:var(--n-panel-hover)]');
      expect(rows[1]).toHaveClass('[--n-row:var(--n-panel-hover)]');
    });

    it('pins the header only when asked', async () => {
      const screen = await render(<Table headers={HEADERS} items={ITEMS} />);

      expect(screen.container.querySelector('th')).not.toHaveClass('sticky');

      await screen.rerender(<Table headers={HEADERS} items={ITEMS} stickyHeader />);

      expect(screen.container.querySelector('th')).toHaveClass('sticky');
    });
  });

  describe('style props', () => {
    it('is drawn on a Box, so the sheet props pass through', async () => {
      const screen = await render(
        <Table headers={HEADERS} items={ITEMS} color="danger" elevation={2} data-testid="table" />
      );
      const sheet = screen.getByTestId('table').element() as HTMLElement;

      expect(sheet.style.getPropertyValue('--n-line')).toBe('var(--neba-danger-line)');
      expect(sheet.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-2)');
      expect(sheet).toHaveClass('border');
      expect(sheet).toHaveClass('overflow-x-auto');
    });

    it('scales the cell padding with size and density', async () => {
      const screen = await render(<Table headers={HEADERS} items={ITEMS} size="xl" />);

      expect((screen.container.querySelector('tbody td') as HTMLElement).style.padding).toBe(
        '0.875rem 1.5rem'
      );

      await screen.rerender(<Table headers={HEADERS} items={ITEMS} size="xl" density="compact" />);

      expect((screen.container.querySelector('tbody td') as HTMLElement).style.padding).toBe(
        '0.625rem 1rem'
      );
    });

    it('keeps caller-supplied class names on the sheet', async () => {
      const screen = await render(
        <Table headers={HEADERS} items={ITEMS} className="my-own-class" data-testid="table" />
      );

      expect(screen.getByTestId('table').element()).toHaveClass('my-own-class');
    });
  });
});
