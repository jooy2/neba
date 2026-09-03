import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
import { Combobox } from 'neba';
import { readOS } from '../../../src/internal/keys.js';

const FRAMEWORKS = [
  { value: 'react', label: 'React' },
  { value: 'vue', label: 'Vue' },
  { value: 'svelte', label: 'Svelte' },
  { value: 'ember', label: 'Ember', disabled: true }
];

describe('Combobox', () => {
  describe('rendering', () => {
    it('renders a combobox named by its label', async () => {
      const screen = await render(<Combobox items={FRAMEWORKS} label="Framework" />);

      await expect.element(screen.getByRole('combobox', { name: 'Framework' })).toBeInTheDocument();
    });

    it('renders the placeholder while nothing is typed', async () => {
      const screen = await render(
        <Combobox items={FRAMEWORKS} label="Framework" placeholder="Search" />
      );

      await expect.element(screen.getByRole('combobox')).toHaveAttribute('placeholder', 'Search');
    });

    it("shows the chosen option's label rather than its value", async () => {
      const screen = await render(
        <Combobox items={FRAMEWORKS} label="Framework" defaultValue="react" />
      );

      await expect.element(screen.getByRole('combobox')).toHaveValue('React');
    });

    it('falls back to the value when an option has no label', async () => {
      const screen = await render(
        <Combobox items={[{ value: 'kr' }]} label="Country" defaultValue="kr" />
      );

      await expect.element(screen.getByRole('combobox')).toHaveValue('kr');
    });

    it('renders the description', async () => {
      const screen = await render(
        <Combobox items={FRAMEWORKS} label="Framework" description="Pick one." />
      );

      await expect.element(screen.getByText('Pick one.')).toBeInTheDocument();
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(<Combobox items={FRAMEWORKS} label="Before" />);

      await screen.rerender(<Combobox items={FRAMEWORKS} label="After" />);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names on the field wrapper', async () => {
      const screen = await render(
        <Combobox items={FRAMEWORKS} label="Framework" className="my-own-class" />
      );

      expect(screen.getByText('Framework').element().closest('.my-own-class')).not.toBeNull();
    });
  });

  describe('choosing', () => {
    it('opens the list and chooses an option', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Combobox items={FRAMEWORKS} label="Framework" onValueChange={onValueChange} />
      );

      await screen.getByRole('combobox').click();
      await screen.getByRole('option', { name: 'Vue' }).click();

      expect(onValueChange).toHaveBeenCalledWith('vue');
      await expect.element(screen.getByRole('combobox')).toHaveValue('Vue');
    });

    it('marks a disabled option as unavailable', async () => {
      const screen = await render(<Combobox items={FRAMEWORKS} label="Framework" />);

      await screen.getByRole('combobox').click();

      await expect
        .element(screen.getByRole('option', { name: 'Ember' }))
        .toHaveAttribute('aria-disabled', 'true');
    });

    it('filters the list by what was typed', async () => {
      const screen = await render(<Combobox items={FRAMEWORKS} label="Framework" />);

      await screen.getByRole('combobox').fill('vu');

      await expect.element(screen.getByRole('option', { name: 'Vue' })).toBeInTheDocument();
      expect(screen.getByRole('option', { name: 'Svelte' }).query()).toBeNull();
    });

    it('honours a controlled value', async () => {
      const screen = await render(
        <Combobox items={FRAMEWORKS} label="Framework" value="react" onValueChange={() => {}} />
      );

      await expect.element(screen.getByRole('combobox')).toHaveValue('React');

      await screen.rerender(
        <Combobox items={FRAMEWORKS} label="Framework" value="vue" onValueChange={() => {}} />
      );

      await expect.element(screen.getByRole('combobox')).toHaveValue('Vue');
    });

    it('does not open when disabled', async () => {
      const screen = await render(<Combobox items={FRAMEWORKS} label="Framework" disabled />);

      await expect.element(screen.getByRole('combobox')).toBeDisabled();
      expect(screen.getByRole('option', { name: 'Vue' }).query()).toBeNull();
    });
  });

  describe('a value the list does not have', () => {
    it('offers what was typed as a row of its own', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Combobox items={FRAMEWORKS} label="Framework" onValueChange={onValueChange} />
      );

      await screen.getByRole('combobox').fill('qwik');
      await screen.getByRole('option', { name: 'Add “qwik”' }).click();

      expect(onValueChange).toHaveBeenCalledWith('qwik');
    });

    it('lets the row say something else', async () => {
      const screen = await render(
        <Combobox
          items={FRAMEWORKS}
          label="Framework"
          customLabel={(query) => `Use ${query} anyway`}
        />
      );

      await screen.getByRole('combobox').fill('qwik');

      await expect
        .element(screen.getByRole('option', { name: 'Use qwik anyway' }))
        .toBeInTheDocument();
    });

    it('does not offer a value the list already has', async () => {
      const screen = await render(<Combobox items={FRAMEWORKS} label="Framework" />);

      await screen.getByRole('combobox').fill('Vue');

      await expect.element(screen.getByRole('option', { name: 'Vue' })).toBeInTheDocument();
      expect(screen.getByRole('option', { name: 'Add “Vue”' }).query()).toBeNull();
    });

    it('offers nothing at all when allowCustom is off', async () => {
      const screen = await render(
        <Combobox items={FRAMEWORKS} label="Framework" allowCustom={false} emptyMessage="Nope." />
      );

      await screen.getByRole('combobox').fill('qwik');

      expect(screen.getByRole('option', { name: 'Add “qwik”' }).query()).toBeNull();
      await expect.element(screen.getByText('Nope.')).toBeInTheDocument();
    });
  });

  describe('multiple', () => {
    it('renders a chip per chosen value', async () => {
      const screen = await render(
        <Combobox
          multiple
          items={FRAMEWORKS}
          label="Framework"
          defaultValue={['react', 'svelte']}
        />
      );

      await expect.element(screen.getByText('React')).toBeInTheDocument();
      await expect.element(screen.getByText('Svelte')).toBeInTheDocument();
    });

    it('reports an array', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Combobox
          multiple
          items={FRAMEWORKS}
          label="Framework"
          defaultValue={['react']}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('combobox').click();
      await screen.getByRole('option', { name: 'Vue' }).click();

      expect(onValueChange).toHaveBeenCalledWith(['react', 'vue']);
    });

    it('removes a chip through its own button', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Combobox
          multiple
          items={FRAMEWORKS}
          label="Framework"
          defaultValue={['react', 'vue']}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Remove React' }).click();

      expect(onValueChange).toHaveBeenCalledWith(['vue']);
    });

    it('names the remove button from the prop', async () => {
      const screen = await render(
        <Combobox
          multiple
          items={FRAMEWORKS}
          label="Framework"
          defaultValue={['react']}
          removeLabel={(chip) => `${chip} 지우기`}
        />
      );

      await expect
        .element(screen.getByRole('button', { name: 'React 지우기' }))
        .toBeInTheDocument();
    });

    it('takes the remove buttons away while read-only', async () => {
      const screen = await render(
        <Combobox multiple items={FRAMEWORKS} label="Framework" readOnly defaultValue={['react']} />
      );

      expect(screen.getByRole('button', { name: 'Remove React' }).query()).toBeNull();
    });
  });

  describe('clearing', () => {
    it('shows no clear button unless asked', async () => {
      const screen = await render(
        <Combobox items={FRAMEWORKS} label="Framework" defaultValue="react" />
      );

      expect(screen.getByRole('button', { name: 'Clear' }).query()).toBeNull();
    });

    it('empties the field', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Combobox
          clearable
          items={FRAMEWORKS}
          label="Framework"
          defaultValue="react"
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Clear' }).click();

      expect(onValueChange).toHaveBeenCalledWith(null);
      await expect.element(screen.getByRole('combobox')).toHaveValue('');
    });
  });

  describe('validation', () => {
    it('renders the error message', async () => {
      const screen = await render(
        <Combobox items={FRAMEWORKS} label="Framework" error="Choose one." />
      );

      await expect.element(screen.getByText('Choose one.')).toBeInTheDocument();
    });

    it('re-points the colour family at danger when invalid', async () => {
      const screen = await render(
        <Combobox items={FRAMEWORKS} label="Framework" color="success" error="Choose one." />
      );
      const root = screen
        .getByText('Framework', { exact: true })
        .element()
        .closest('[style]') as HTMLElement;

      expect(root.style.getPropertyValue('--n-ring')).toBe('var(--neba-danger-ring)');
    });
  });

  describe('style props', () => {
    it('is drawn on the same shell as a TextField', async () => {
      const screen = await render(<Combobox items={FRAMEWORKS} label="Framework" />);
      const shell = screen.getByRole('combobox').element().parentElement as HTMLElement;

      expect(shell).toHaveClass('h-8');
      expect(shell).toHaveClass('border');
    });

    it('grows instead of fixing a height when multiple', async () => {
      const screen = await render(<Combobox multiple items={FRAMEWORKS} label="Framework" />);
      const shell = screen.getByRole('combobox').element().closest('.min-h-8');

      expect(shell).not.toBeNull();
    });

    it('changes height with size but not with density', async () => {
      const screen = await render(<Combobox items={FRAMEWORKS} label="Framework" size="lg" />);

      expect(screen.getByRole('combobox').element().parentElement).toHaveClass('h-10');

      await screen.rerender(
        <Combobox items={FRAMEWORKS} label="Framework" size="lg" density="compact" />
      );

      expect(screen.getByRole('combobox').element().parentElement).toHaveClass('h-10');
    });

    /** The same portal problem Select has, and the same fix. */
    it('carries its own colour slots, because the popup renders outside the field', async () => {
      const screen = await render(<Combobox items={FRAMEWORKS} label="Framework" color="info" />);

      await screen.getByRole('combobox').click();
      await expect.element(screen.getByRole('listbox')).toBeInTheDocument();

      const popup = screen.getByRole('listbox').element().closest('[style]') as HTMLElement;

      expect(popup.style.getPropertyValue('--n-line')).toBe('var(--neba-info-line)');
      expect(popup.style.getPropertyValue('--n-soft-hover')).toBe('var(--neba-info-soft-hover)');
      expect(popup.style.getPropertyValue('--n-panel-press')).toBe('var(--neba-panel-press)');
    });

    /** The same missing fade Select had, and the same fix. */
    it('fades in and out, the way every other popup does', async () => {
      const screen = await render(<Combobox items={FRAMEWORKS} label="Framework" />);

      await screen.getByRole('combobox').click();
      await expect.element(screen.getByRole('listbox')).toBeInTheDocument();

      const popup = screen.getByRole('listbox').element().closest('[style]') as HTMLElement;

      expect(popup.className).toContain('transition:opacity');
      expect(popup).toHaveClass('data-[starting-style]:opacity-0');
      expect(popup).toHaveClass('data-[ending-style]:opacity-0');
    });

    it('separates the query from the chips it follows, and only then', async () => {
      const screen = await render(
        <Combobox multiple items={FRAMEWORKS} label="Framework" placeholder="Add one" />
      );

      expect(screen.getByRole('combobox').element()).not.toHaveClass('ms-1.5');

      await screen.rerender(
        <Combobox
          multiple
          items={FRAMEWORKS}
          label="Framework"
          placeholder="Add one"
          value={['react']}
        />
      );

      expect(screen.getByRole('combobox').element()).toHaveClass('ms-1.5');
    });

    it('keeps the sheet undyed while colouring the edge', async () => {
      const screen = await render(<Combobox items={FRAMEWORKS} label="Framework" color="info" />);
      const root = screen.getByText('Framework').element().closest('[style]') as HTMLElement;

      expect(root.style.getPropertyValue('--n-panel')).toBe('var(--neba-panel)');
      expect(root.style.getPropertyValue('--n-line')).toBe('var(--neba-info-line)');
    });

    it('stretches to the container when full width', async () => {
      const screen = await render(<Combobox items={FRAMEWORKS} label="Framework" fullWidth />);
      const root = screen.getByText('Framework').element().closest('[style]') as HTMLElement;

      expect(root).toHaveClass('w-full');
      expect(root).not.toHaveClass('inline-flex');
    });
  });

  describe('forwarded props', () => {
    it('passes an unknown prop to the root', async () => {
      const screen = await render(<Combobox items={FRAMEWORKS} data-analytics="framework" />);

      expect(screen.container.querySelector('[data-analytics="framework"]')).not.toBeNull();
    });
  });
  /**
   * The keys a Combobox cares about are the list's, and Base UI acts on them
   * before anything on the root could see them — so `shortcuts` is the only way
   * a caller reaches `Enter` here at all.
   */
  describe('shortcuts', () => {
    it('sees Enter, which never reaches a handler on the root', async () => {
      const onEnter = vi.fn();
      const onKeyDown = vi.fn();
      const screen = await render(
        <Combobox
          label="Framework"
          items={FRAMEWORKS}
          shortcuts={{ Enter: onEnter }}
          onKeyDown={onKeyDown}
        />
      );

      await screen.getByRole('combobox').click();
      await userEvent.keyboard('Re');
      await userEvent.keyboard('{Enter}');

      expect(onEnter).toHaveBeenCalledTimes(1);
      // The same keystroke, through the prop that was there before: it is the
      // letters and not the Enter, which is what made this prop necessary.
      expect(onKeyDown.mock.calls.map((call) => call[0].key)).not.toContain('Enter');
    });

    it('runs before the list acts, and does not replace what it does', async () => {
      const onEnter = vi.fn();
      const onValueChange = vi.fn();
      const screen = await render(
        <Combobox
          label="Framework"
          items={FRAMEWORKS}
          shortcuts={{ Enter: onEnter }}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('combobox').click();
      await userEvent.keyboard('Re');
      await userEvent.keyboard('{Enter}');

      expect(onEnter).toHaveBeenCalledTimes(1);
      expect(onValueChange).toHaveBeenCalledWith('react');
    });

    it('reaches a combination the list has no opinion about', async () => {
      const save = vi.fn();
      const screen = await render(
        <Combobox label="Framework" items={FRAMEWORKS} shortcuts={{ 'Mod+S': save }} />
      );
      const mac = readOS() === 'mac';

      await screen.getByRole('combobox').click();
      await userEvent.keyboard(mac ? '{Meta>}s{/Meta}' : '{Control>}s{/Control}');

      expect(save).toHaveBeenCalledTimes(1);
    });
  });

  describe('slots', () => {
    it('puts a class name on every part it was given one for', async () => {
      const screen = await render(
        <Combobox
          items={FRAMEWORKS}
          label="Framework"
          description="Pick the one you use."
          error="Required"
          classNames={{
            label: 'slot-label',
            shell: 'slot-shell',
            control: 'slot-control',
            description: 'slot-description',
            error: 'slot-error'
          }}
        />
      );
      const control = screen.getByRole('combobox').element();

      expect(control).toHaveClass('slot-control');
      expect(control.closest('.slot-shell')).not.toBeNull();
      expect(screen.getByText('Framework').element()).toHaveClass('slot-label');
      expect(screen.getByText('Pick the one you use.').element()).toHaveClass('slot-description');
      expect(screen.getByText('Required').element()).toHaveClass('slot-error');
    });

    /** The popup is portalled, so nothing written against the root reaches it. */
    it('reaches the portalled popup and its rows', async () => {
      const screen = await render(
        <Combobox
          items={FRAMEWORKS}
          label="Framework"
          classNames={{ popup: 'slot-popup', item: 'slot-item' }}
        />
      );

      await screen.getByRole('combobox').click();

      const row = screen.getByRole('option', { name: 'Vue' });

      await expect.element(row).toHaveClass('slot-item');
      expect(row.element().closest('.slot-popup')).not.toBeNull();
    });

    it('reaches the chips a multiple-selection combobox draws', async () => {
      const screen = await render(
        <Combobox
          items={FRAMEWORKS}
          label="Framework"
          multiple
          defaultValue={['react']}
          classNames={{ chip: 'slot-chip' }}
        />
      );

      await expect.element(screen.getByText('React')).toBeInTheDocument();
      expect(screen.getByText('React').element().closest('.slot-chip')).not.toBeNull();
    });

    it('leaves the root to `className`', async () => {
      const screen = await render(
        <Combobox
          items={FRAMEWORKS}
          label="Framework"
          className="root-class"
          classNames={{ control: 'control-class' }}
        />
      );
      const control = screen.getByRole('combobox').element();

      expect(control).not.toHaveClass('root-class');
      expect(control.closest('.root-class')).not.toBeNull();
    });
  });
});
