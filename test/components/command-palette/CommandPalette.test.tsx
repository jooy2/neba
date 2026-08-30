import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
import { CommandPalette } from 'neba';

const ITEMS = [
  { value: 'home', label: 'Go to overview', group: 'Navigate', shortcut: 'G H' },
  { value: 'deploys', label: 'Go to deployments', group: 'Navigate' },
  {
    value: 'deploy',
    label: 'Deploy production',
    group: 'Actions',
    keywords: ['ship', 'release']
  },
  { value: 'rollback', label: 'Roll back', group: 'Actions', disabled: true }
];

describe('CommandPalette', () => {
  describe('rendering', () => {
    it('draws nothing until it is open', async () => {
      const screen = await render(<CommandPalette items={ITEMS} shortcut={false} />);

      expect(screen.getByRole('dialog').query()).toBeNull();
    });

    it('draws a named dialog with a field and every command', async () => {
      const screen = await render(<CommandPalette items={ITEMS} shortcut={false} defaultOpen />);

      await expect
        .element(screen.getByRole('dialog', { name: 'Command palette' }))
        .toBeInTheDocument();
      await expect.element(screen.getByRole('combobox')).toBeInTheDocument();
      await expect.element(screen.getByText('Go to overview')).toBeInTheDocument();
      await expect.element(screen.getByText('Deploy production')).toBeInTheDocument();
    });

    it('draws a heading each time the group changes', async () => {
      const screen = await render(<CommandPalette items={ITEMS} shortcut={false} defaultOpen />);

      await expect.element(screen.getByText('Navigate')).toBeInTheDocument();
      await expect.element(screen.getByText('Actions')).toBeInTheDocument();
    });

    it('draws the keystroke a command already has', async () => {
      const screen = await render(<CommandPalette items={ITEMS} shortcut={false} defaultOpen />);

      await expect.element(screen.getByText('G H')).toBeInTheDocument();
    });

    it('takes a placeholder and an empty line of its own', async () => {
      const screen = await render(
        <CommandPalette
          items={[]}
          shortcut={false}
          defaultOpen
          placeholder="What now?"
          emptyMessage="Nothing to run"
        />
      );

      await expect.element(screen.getByPlaceholder('What now?')).toBeInTheDocument();
      await expect.element(screen.getByText('Nothing to run')).toBeInTheDocument();
    });
  });

  describe('searching', () => {
    it('filters on the label', async () => {
      const screen = await render(<CommandPalette items={ITEMS} shortcut={false} defaultOpen />);

      await screen.getByRole('combobox').fill('overview');

      await expect.element(screen.getByText('Go to overview')).toBeInTheDocument();
      expect(screen.getByText('Deploy production').query()).toBeNull();
    });

    it('filters on keywords nobody can see', async () => {
      const screen = await render(<CommandPalette items={ITEMS} shortcut={false} defaultOpen />);

      await screen.getByRole('combobox').fill('ship');

      await expect.element(screen.getByText('Deploy production')).toBeInTheDocument();
      expect(screen.getByText('Go to overview').query()).toBeNull();
    });

    // The same fold a DataTable's search box uses. A reader who has learned
    // what one search box in a product does has learned what the others do.
    it('ignores case and accents, exactly as a table does', async () => {
      const screen = await render(
        <CommandPalette
          items={[{ value: 'cafe', label: 'Café settings' }, ...ITEMS]}
          shortcut={false}
          defaultOpen
        />
      );

      await screen.getByRole('combobox').fill('CAFE');

      await expect.element(screen.getByText('Café settings')).toBeInTheDocument();
      expect(screen.getByText('Deploy production').query()).toBeNull();
    });

    it('says so when nothing matched', async () => {
      const screen = await render(<CommandPalette items={ITEMS} shortcut={false} defaultOpen />);

      await screen.getByRole('combobox').fill('zzzz');

      await expect.element(screen.getByText('No commands found')).toBeInTheDocument();
    });
  });

  describe('running a command', () => {
    it('runs the command and closes', async () => {
      const onSelect = vi.fn();
      const onOpenChange = vi.fn();
      const own = vi.fn();
      const screen = await render(
        <CommandPalette
          items={ITEMS.map((item) => (item.value === 'home' ? { ...item, onSelect: own } : item))}
          shortcut={false}
          defaultOpen
          onSelect={onSelect}
          onOpenChange={onOpenChange}
        />
      );

      // The keyboard is the palette's real path, and the only one available
      // here: nothing loads Tailwind, so the sheet has no stacking of its own
      // and Base UI's modal blocker sits over every row.
      await userEvent.keyboard('{ArrowDown}{Enter}');

      expect(own).toHaveBeenCalledTimes(1);
      expect(onSelect).toHaveBeenCalledWith(expect.objectContaining({ value: 'home' }));
      expect(onOpenChange).toHaveBeenCalledWith(false);
      // The retrying form: the sheet is leaving rather than gone, and Base UI
      // keeps it mounted for as long as an exit transition might still run.
      await expect.element(screen.getByRole('dialog')).not.toBeInTheDocument();
    });

    it('never runs a disabled one', async () => {
      const onSelect = vi.fn();
      const screen = await render(
        <CommandPalette items={ITEMS} shortcut={false} defaultOpen onSelect={onSelect} />
      );

      await screen.getByText('Roll back').click({ force: true });

      expect(onSelect).not.toHaveBeenCalled();
    });
  });

  describe('the shortcut', () => {
    it('opens on the keystroke it was given', async () => {
      const screen = await render(<CommandPalette items={ITEMS} shortcut="Alt+P" />);

      expect(screen.getByRole('dialog').query()).toBeNull();

      await userEvent.keyboard('{Alt>}p{/Alt}');

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    });

    // `Mod` is the one token whose meaning changes with the platform, so the
    // test has to ask the platform the same question the component does.
    it('opens on the modifier this platform builds shortcuts on', async () => {
      const screen = await render(<CommandPalette items={ITEMS} />);
      const mac = /mac|iphone|ipad/i.test(navigator.platform || navigator.userAgent);

      await userEvent.keyboard(mac ? '{Meta>}k{/Meta}' : '{Control>}k{/Control}');

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    });

    it('binds nothing when it is turned off', async () => {
      const screen = await render(<CommandPalette items={ITEMS} shortcut={false} />);

      await userEvent.keyboard('{Control>}k{/Control}');
      await userEvent.keyboard('{Meta>}k{/Meta}');

      expect(screen.getByRole('dialog').query()).toBeNull();
    });
  });
});
