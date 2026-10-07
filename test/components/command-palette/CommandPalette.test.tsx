import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
import { renderToString } from 'react-dom/server';
import { hydrateRoot } from 'react-dom/client';
import { CommandPalette, type CommandItem } from 'neba';
import { sheetChunk } from '../../../src/components/command-palette/CommandPalette.js';
import { readOS } from '../../../src/internal/keys.js';

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

    // A heading drawn between rows named nothing, so arrowing into a group
    // never said which group it was.
    it('puts each group of rows in a group named by its heading', async () => {
      const screen = await render(<CommandPalette items={ITEMS} shortcut={false} defaultOpen />);
      const navigate = screen.getByRole('group', { name: 'Navigate' });

      await expect.element(navigate).toBeInTheDocument();
      expect(
        navigate
          .element()
          .contains(screen.getByRole('option', { name: /Go to deployments/ }).element())
      ).toBe(true);
      await expect.element(screen.getByRole('group', { name: 'Actions' })).toBeInTheDocument();
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

    it('starts empty again after a command ran and closed it', async () => {
      const screen = await render(<CommandPalette items={ITEMS} shortcut="Alt+P" defaultOpen />);

      await screen.getByRole('combobox').fill('overview');
      await expect
        .element(screen.getByRole('option', { name: /Go to overview/ }))
        .toBeInTheDocument();
      await userEvent.keyboard('{ArrowDown}{Enter}');
      await expect.element(screen.getByRole('dialog')).not.toBeInTheDocument();

      await userEvent.keyboard('{Alt>}p{/Alt}');

      await expect.element(screen.getByRole('combobox')).toHaveValue('');
      await expect.element(screen.getByText('Deploy production')).toBeInTheDocument();
    });

    // Escape from the field is the third way out, and the one a reader uses
    // most: it closes the palette whatever is typed, and takes the query too.
    it('closes on Escape from the field, and starts empty again', async () => {
      const screen = await render(<CommandPalette items={ITEMS} shortcut="Alt+P" defaultOpen />);

      await screen.getByRole('combobox').fill('overview');
      await expect.element(screen.getByText('Deploy production')).not.toBeInTheDocument();

      await userEvent.keyboard('{Escape}');
      await expect.element(screen.getByRole('dialog')).not.toBeInTheDocument();

      await userEvent.keyboard('{Alt>}p{/Alt}');

      await expect.element(screen.getByRole('combobox')).toHaveValue('');
      await expect.element(screen.getByText('Deploy production')).toBeInTheDocument();
    });

    it('starts empty again after a controlled open was turned off', async () => {
      const screen = await render(<CommandPalette items={ITEMS} shortcut={false} open />);

      await screen.getByRole('combobox').fill('overview');
      await expect.element(screen.getByText('Deploy production')).not.toBeInTheDocument();

      await screen.rerender(<CommandPalette items={ITEMS} shortcut={false} open={false} />);
      await expect.element(screen.getByRole('dialog')).not.toBeInTheDocument();
      await screen.rerender(<CommandPalette items={ITEMS} shortcut={false} open />);

      await expect.element(screen.getByRole('combobox')).toHaveValue('');
      await expect.element(screen.getByText('Deploy production')).toBeInTheDocument();
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

    it('walks the highlight from one group into the next', async () => {
      const onSelect = vi.fn();
      await render(
        <CommandPalette items={ITEMS} shortcut={false} defaultOpen onSelect={onSelect} />
      );

      await userEvent.keyboard('{ArrowDown}{ArrowDown}{ArrowDown}{Enter}');

      expect(onSelect).toHaveBeenCalledWith(expect.objectContaining({ value: 'deploy' }));
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
    // An inline `onOpenChange` was a new `setOpen`, and so a new window
    // listener, on every render of the component around the palette.
    it('binds its key once however often the page around it renders', async () => {
      const added = vi.spyOn(window, 'addEventListener');

      function Page({ tick }: { tick: number }) {
        return (
          <>
            <span>{tick}</span>
            <CommandPalette items={ITEMS} open={false} onOpenChange={() => {}} />
          </>
        );
      }

      try {
        const screen = await render(<Page tick={0} />);
        const keydowns = () => added.mock.calls.filter(([type]) => type === 'keydown').length;
        const bound = keydowns();

        for (const tick of [1, 2, 3]) {
          await screen.rerender(<Page tick={tick} />);
        }

        expect(keydowns()).toBe(bound);
      } finally {
        added.mockRestore();
      }
    });

    it('opens on the keystroke it was given', async () => {
      const screen = await render(<CommandPalette items={ITEMS} shortcut="Alt+P" />);

      expect(screen.getByRole('dialog').query()).toBeNull();

      await userEvent.keyboard('{Alt>}p{/Alt}');

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    });

    // `Mod` is the one token whose meaning changes with the platform, so the
    // test asks `readOS()` rather than re-deriving the answer. A second reading
    // of the platform is a second chance to disagree with the one that binds
    // the key, and disagreeing is exactly what it did.
    it('opens on the modifier this platform builds shortcuts on', async () => {
      const screen = await render(<CommandPalette items={ITEMS} />);
      const mac = readOS() === 'mac';

      await userEvent.keyboard(mac ? '{Meta>}k{/Meta}' : '{Control>}k{/Control}');

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    });

    /*
     * Every spelling below draws a correct key cap through `Shortcut`, and none
     * of them used to fire: the display side knew the aliases and the binding
     * side did not, so the label on the screen was the only evidence a reader
     * had that the key existed at all.
     *
     * One test each rather than a loop inside one — two palettes rendered in
     * the same test are two palettes bound to the same key, and the second
     * `getByRole('dialog')` then has two to choose from.
     */
    const MAC = readOS() === 'mac';

    for (const shortcut of MAC ? ['Cmd+K', 'Command+K', 'Meta+K'] : ['Ctrl+K', 'Control+K']) {
      it(`binds ${shortcut}, which Shortcut already drew`, async () => {
        const screen = await render(<CommandPalette items={ITEMS} shortcut={shortcut} />);

        await userEvent.keyboard(MAC ? '{Meta>}k{/Meta}' : '{Control>}k{/Control}');

        await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
      });
    }

    // A controlled palette heard another open request for every press of the
    // key while it was already up.
    it('asks to open only while it is shut', async () => {
      const onOpenChange = vi.fn();
      await render(
        <CommandPalette items={ITEMS} shortcut="Alt+P" open onOpenChange={onOpenChange} />
      );

      await userEvent.keyboard('{Alt>}p{/Alt}');

      expect(onOpenChange).not.toHaveBeenCalledWith(true);
    });

    it('binds a key named the short way', async () => {
      const screen = await render(<CommandPalette items={ITEMS} shortcut="Alt+Esc" />);

      await userEvent.keyboard('{Alt>}{Escape}{/Alt}');

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    });

    it('binds nothing when it is turned off', async () => {
      const screen = await render(<CommandPalette items={ITEMS} shortcut={false} />);

      await userEvent.keyboard('{Control>}k{/Control}');
      await userEvent.keyboard('{Meta>}k{/Meta}');

      expect(screen.getByRole('dialog').query()).toBeNull();
    });
  });
  describe('slots', () => {
    it('puts a class name on the sheet and on every part it was given one for', async () => {
      const screen = await render(
        <CommandPalette
          items={ITEMS}
          shortcut={false}
          defaultOpen
          className="sheet-class"
          classNames={{
            backdrop: 'slot-backdrop',
            viewport: 'slot-viewport',
            input: 'slot-input',
            list: 'slot-list',
            group: 'slot-group',
            item: 'slot-item'
          }}
        />
      );

      await expect.element(screen.getByRole('dialog')).toHaveClass('sheet-class');
      expect(screen.getByRole('combobox').element()).toHaveClass('slot-input');
      expect(screen.getByText('Navigate').element()).toHaveClass('slot-group');
      expect(screen.getByText('Go to overview').element().closest('.slot-item')).not.toBeNull();
      expect(screen.getByRole('dialog').element().querySelector('.slot-list')).not.toBeNull();
    });

    /** Both render outside the sheet, so nothing written against it finds them. */
    it('reaches the backdrop and the viewport', async () => {
      const screen = await render(
        <CommandPalette
          items={ITEMS}
          shortcut={false}
          defaultOpen
          classNames={{ backdrop: 'slot-backdrop', viewport: 'slot-viewport' }}
        />
      );
      const sheet = screen.getByRole('dialog').element();

      expect(sheet.closest('.slot-viewport')).not.toBeNull();
      expect(sheet.querySelector('.slot-backdrop')).toBeNull();
      expect(document.querySelector('.slot-backdrop')).not.toBeNull();
    });

    it('reaches the line that stands in for no matches', async () => {
      const screen = await render(
        <CommandPalette
          items={ITEMS}
          shortcut={false}
          defaultOpen
          classNames={{ empty: 'slot-empty' }}
        />
      );

      await screen.getByRole('combobox').fill('nothing matches this');

      await expect.element(screen.getByText('No commands found')).toHaveClass('slot-empty');
    });
  });

  /*
   * The sheet — Base UI's Dialog and Autocomplete — is a chunk of its own. It
   * was in the bundle every page with a palette needed before it could draw,
   * for a popup that starts shut.
   */
  describe('the sheet', () => {
    it('is fetched once the page is idle, and mounted only by an open', async () => {
      const load = vi.spyOn(sheetChunk, 'load');

      try {
        const screen = await render(<CommandPalette items={ITEMS} shortcut="Alt+P" />);

        await vi.waitFor(() => expect(load).toHaveBeenCalled());
        expect(screen.getByRole('dialog').query()).toBeNull();

        await userEvent.keyboard('{Alt>}p{/Alt}');

        await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
      } finally {
        load.mockRestore();
      }
    });

    // Mounted by the open, the dialog mounted already open, and Base UI plays
    // no enter transition for a popup that does.
    it('fades the first open in, as it does every later one', async () => {
      let started = false;
      const observer = new MutationObserver((records) => {
        for (const record of records) {
          const nodes = record.type === 'attributes' ? [record.target] : [...record.addedNodes];

          started ||= nodes.some(
            (node) =>
              node instanceof Element &&
              (node.matches('[data-starting-style]') ||
                node.querySelector('[data-starting-style]') !== null)
          );
        }
      });

      observer.observe(document.body, {
        childList: true,
        subtree: true,
        attributes: true,
        attributeFilter: ['data-starting-style']
      });

      try {
        const screen = await render(<CommandPalette items={ITEMS} shortcut="Alt+P" />);

        await userEvent.keyboard('{Alt>}p{/Alt}');
        await expect.element(screen.getByRole('dialog')).toBeInTheDocument();

        expect(started).toBe(true);
      } finally {
        observer.disconnect();
      }
    });

    // A component fetched on demand suspends in a server render, where
    // `renderToString` gives up on its boundary.
    it('draws nothing on a server, and opens one that starts open once it has hydrated', async () => {
      const element = <CommandPalette items={ITEMS} shortcut={false} defaultOpen />;
      const host = document.createElement('div');
      const recoverable = vi.fn();

      host.innerHTML = renderToString(element);
      document.body.append(host);

      expect(host.innerHTML).toBe('');

      const root = hydrateRoot(host, element, { onRecoverableError: recoverable });

      try {
        await expect
          .poll(() => document.querySelector('[role="dialog"][aria-label="Command palette"]'))
          .not.toBeNull();
        expect(recoverable).not.toHaveBeenCalled();
      } finally {
        root.unmount();
        host.remove();
      }
    });

    // Folding a command for the search normalizes every word it answers to,
    // and a page that hands a shut palette a new list did it for nothing.
    it('folds the commands for searching only while it is open', async () => {
      const commands = (...labels: string[]): CommandItem[] =>
        labels.map((label) => ({ value: label, label, keywords: ['other words'] }));
      const screen = await render(
        <CommandPalette items={commands('Alpha', 'Beta')} shortcut={false} open />
      );

      await expect.element(screen.getByText('Alpha')).toBeInTheDocument();
      await screen.rerender(
        <CommandPalette items={commands('Alpha', 'Beta')} shortcut={false} open={false} />
      );
      await expect.element(screen.getByRole('dialog')).not.toBeInTheDocument();

      const normalize = vi.spyOn(String.prototype, 'normalize');

      try {
        await screen.rerender(
          <CommandPalette items={commands('Gamma', 'Delta')} shortcut={false} open={false} />
        );

        expect(normalize).not.toHaveBeenCalled();

        await screen.rerender(
          <CommandPalette items={commands('Gamma', 'Delta')} shortcut={false} open />
        );
        await expect.element(screen.getByText('Gamma')).toBeInTheDocument();

        expect(normalize).toHaveBeenCalled();
      } finally {
        normalize.mockRestore();
      }
    });
  });
});
