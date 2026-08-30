import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Transfer } from 'neba';

const ITEMS = [
  { value: 'status', label: 'Status' },
  { value: 'duration', label: 'Duration' },
  { value: 'commit', label: 'Commit' },
  { value: 'author', label: 'Author' },
  { value: 'region', label: 'Region', disabled: true }
];

// Nothing loads Tailwind into the test run, so a tick renders at zero size and
// cannot be clicked. Its label is both the reachable target and the real user
// path; the select-all has only an `aria-label`, so that one is forced.
describe('Transfer', () => {
  describe('rendering', () => {
    it('renders both lists and the two buttons', async () => {
      const screen = await render(<Transfer items={ITEMS} />);

      await expect.element(screen.getByText('Available')).toBeInTheDocument();
      await expect.element(screen.getByText('Selected')).toBeInTheDocument();
      await expect
        .element(screen.getByRole('button', { name: 'Move to selected' }))
        .toBeInTheDocument();
      await expect
        .element(screen.getByRole('button', { name: 'Move to available' }))
        .toBeInTheDocument();
    });

    it('starts everything on the left', async () => {
      const screen = await render(<Transfer items={ITEMS} />);

      await expect.element(screen.getByRole('checkbox', { name: 'Status' })).toBeInTheDocument();
      await expect.element(screen.getByText('0/5')).toBeInTheDocument();
      await expect.element(screen.getByText('0/0')).toBeInTheDocument();
    });

    it('puts the default value on the right', async () => {
      const screen = await render(<Transfer items={ITEMS} defaultValue={['commit', 'author']} />);

      await expect.element(screen.getByText('0/3')).toBeInTheDocument();
      await expect.element(screen.getByText('0/2')).toBeInTheDocument();
    });

    it('takes headings of its own', async () => {
      const screen = await render(
        <Transfer items={ITEMS} sourceLabel="All columns" targetLabel="Shown" />
      );

      await expect.element(screen.getByText('All columns')).toBeInTheDocument();
      await expect.element(screen.getByText('Shown')).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <Transfer items={ITEMS} className="my-own-class" data-testid="transfer" />
      );

      expect(screen.getByTestId('transfer').element()).toHaveClass('my-own-class');
    });
  });

  describe('moving', () => {
    it('sends the ticked rows across', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<Transfer items={ITEMS} onValueChange={onValueChange} />);

      await screen.getByText('Status').click();
      await screen.getByText('Commit').click();
      await screen.getByRole('button', { name: 'Move to selected' }).click();

      expect(onValueChange).toHaveBeenCalledWith(['status', 'commit']);
      await expect.element(screen.getByText('0/3')).toBeInTheDocument();
    });

    it('sends them back again', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Transfer items={ITEMS} defaultValue={['status']} onValueChange={onValueChange} />
      );

      await screen.getByText('Status').click();
      await screen.getByRole('button', { name: 'Move to available' }).click();

      expect(onValueChange).toHaveBeenCalledWith([]);
    });

    it('keeps the order of items whichever side a row is on', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<Transfer items={ITEMS} onValueChange={onValueChange} />);

      await screen.getByText('Commit').click();
      await screen.getByText('Status').click();
      await screen.getByRole('button', { name: 'Move to selected' }).click();

      expect(onValueChange).toHaveBeenCalledWith(['status', 'commit']);
    });

    it('leaves the buttons unavailable while nothing is ticked', async () => {
      const screen = await render(<Transfer items={ITEMS} />);

      await expect.element(screen.getByRole('button', { name: 'Move to selected' })).toBeDisabled();
    });

    it('never moves a disabled row', async () => {
      const screen = await render(<Transfer items={ITEMS} />);

      await expect.element(screen.getByRole('checkbox', { name: 'Region' })).toBeDisabled();
    });

    it('stays where the controlled value puts it', async () => {
      const screen = await render(<Transfer items={ITEMS} value={[]} onValueChange={() => {}} />);

      await screen.getByText('Status').click();
      await screen.getByRole('button', { name: 'Move to selected' }).click();

      await expect.element(screen.getByText('0/5')).toBeInTheDocument();
    });
  });

  describe('select all', () => {
    it('ticks every movable row on that side', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<Transfer items={ITEMS} onValueChange={onValueChange} />);

      // A native click rather than a driven one: the tick is a zero-size box
      // without Tailwind, and it has no label to press instead.
      (
        screen.getByRole('checkbox', { name: 'Select all' }).first().element() as HTMLElement
      ).click();
      await screen.getByRole('button', { name: 'Move to selected' }).click();

      expect(onValueChange).toHaveBeenCalledWith(['status', 'duration', 'commit', 'author']);
    });
  });

  describe('searchable', () => {
    it('filters a list without changing what is on which side', async () => {
      const screen = await render(<Transfer items={ITEMS} searchable />);

      await screen.getByRole('textbox', { name: 'Search' }).first().fill('com');

      await expect.element(screen.getByRole('checkbox', { name: 'Commit' })).toBeInTheDocument();
      expect(screen.getByRole('checkbox', { name: 'Status' }).query()).toBeNull();
    });

    // The same fold a DataTable's search box uses. A reader who has learned
    // what one search box in a product does has learned what the others do.
    it('ignores case and accents, exactly as a table does', async () => {
      const screen = await render(
        <Transfer
          items={[{ value: 'region', label: 'Région' }, ...ITEMS.slice(0, -1)]}
          searchable
        />
      );

      await screen.getByRole('textbox', { name: 'Search' }).first().fill('REGION');

      await expect.element(screen.getByRole('checkbox', { name: 'Région' })).toBeInTheDocument();
      expect(screen.getByRole('checkbox', { name: 'Commit' }).query()).toBeNull();
    });

    it('keeps a row whose label is not a string', async () => {
      // There is no text to match, and a row that vanished from a filter it
      // could never satisfy is a row a reader cannot reach.
      const screen = await render(
        <Transfer items={[{ value: 'chip', label: <span>Chipped</span> }, ...ITEMS]} searchable />
      );

      await screen.getByRole('textbox', { name: 'Search' }).first().fill('zzzz');

      await expect.element(screen.getByText('Chipped')).toBeInTheDocument();
      expect(screen.getByRole('checkbox', { name: 'Status' }).query()).toBeNull();
    });
  });
});
