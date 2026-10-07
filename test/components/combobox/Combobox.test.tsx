import * as React from 'react';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
import { Combobox, Form, TextField } from 'neba';
import { ko, registerMessages } from 'neba/locales';
import { readOS } from '../../../src/internal/keys.js';

registerMessages('ko', ko);

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

    it('names the input by an aria-label written on the component', async () => {
      const screen = await render(
        <>
          <Combobox items={FRAMEWORKS} aria-label="Framework" />
          <span id="stack">Stack</span>
          <Combobox items={FRAMEWORKS} multiple aria-labelledby="stack" />
        </>
      );

      await expect.element(screen.getByRole('combobox', { name: 'Framework' })).toBeInTheDocument();
      await expect.element(screen.getByRole('combobox', { name: 'Stack' })).toBeInTheDocument();
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

    it('keeps every row when the filter is off', async () => {
      // What a list narrowed by a server needs: the rows came back matching a
      // keyword the label does not contain, and filtering them again here
      // would drop exactly the results the search was for.
      const screen = await render(<Combobox items={FRAMEWORKS} label="Framework" filter={false} />);

      await screen.getByRole('combobox').fill('vu');

      await expect.element(screen.getByRole('option', { name: 'Svelte' })).toBeInTheDocument();
    });

    it('takes a filter of its own', async () => {
      const screen = await render(
        <Combobox
          items={FRAMEWORKS}
          label="Framework"
          filter={(option, query) => String(option.value).startsWith(query)}
        />
      );

      await screen.getByRole('combobox').fill('re');

      await expect.element(screen.getByRole('option', { name: 'React' })).toBeInTheDocument();
      expect(screen.getByRole('option', { name: 'Vue' }).query()).toBeNull();
    });

    // The functions Base UI was handed were new on every render, so it filtered
    // the whole list again whenever anything above the combobox rendered.
    it('does not filter again when it renders with the same query', async () => {
      const filter = vi.fn((option: { label?: string }, query: string) =>
        (option.label ?? '').toLowerCase().includes(query.toLowerCase())
      );
      const screen = await render(
        <Combobox items={FRAMEWORKS} label="Framework" filter={filter} description="One" />
      );

      await screen.getByRole('combobox').fill('v');
      await expect.element(screen.getByRole('option', { name: 'Vue' })).toBeInTheDocument();

      const calls = filter.mock.calls.length;

      await screen.rerender(
        <Combobox items={FRAMEWORKS} label="Framework" filter={filter} description="Two" />
      );
      await expect.element(screen.getByText('Two')).toBeInTheDocument();

      expect(filter.mock.calls.length).toBe(calls);
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

    // A full list cut the row off, so the typed value could not be added and
    // Enter chose the first option instead.
    it('draws the row beyond the limit, after as many options as the limit allows', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Combobox items={FRAMEWORKS} label="Framework" limit={2} onValueChange={onValueChange} />
      );

      await screen.getByRole('combobox').fill('e');

      const add = screen.getByRole('option', { name: 'Add “e”' });

      await expect.element(add).toBeInTheDocument();
      expect(screen.getByRole('option').elements()).toHaveLength(3);

      await userEvent.keyboard('{ArrowDown}{ArrowDown}{Enter}');

      expect(onValueChange).toHaveBeenCalledWith('e');
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

    it('does not offer an option under another case, or spelled as its value', async () => {
      const screen = await render(
        <Combobox items={[{ value: 'ng', label: 'Angular' }]} label="Framework" />
      );
      const input = screen.getByRole('combobox');

      await input.fill('aNGULAR');
      await expect.element(screen.getByRole('option', { name: 'Angular' })).toBeInTheDocument();
      expect(screen.getByRole('option', { name: 'Add “aNGULAR”' }).query()).toBeNull();

      await input.fill('NG');
      await expect.element(screen.getByRole('option', { name: 'Angular' })).toBeInTheDocument();
      expect(screen.getByRole('option', { name: 'Add “NG”' }).query()).toBeNull();
    });

    it('does not offer a value that has already been chosen', async () => {
      const screen = await render(
        <Combobox multiple items={FRAMEWORKS} label="Framework" defaultValue={['qwik']} />
      );

      await screen.getByRole('combobox').fill('QWIK');

      await expect.element(screen.getByRole('listbox')).toBeInTheDocument();
      expect(screen.getByRole('option', { name: 'Add “QWIK”' }).query()).toBeNull();
    });

    // What the list already has is worked out once per list, so a new list has
    // to be read again rather than answered from the old one.
    it('offers a value again once a new list no longer has it', async () => {
      const screen = await render(<Combobox items={FRAMEWORKS} label="Framework" />);

      await screen.getByRole('combobox').fill('Vue');
      expect(screen.getByRole('option', { name: 'Add “Vue”' }).query()).toBeNull();

      await screen.rerender(
        <Combobox items={FRAMEWORKS.filter((item) => item.value !== 'vue')} label="Framework" />
      );

      await expect.element(screen.getByRole('option', { name: 'Add “Vue”' })).toBeInTheDocument();
    });

    it('takes the row away when allowCustom is turned off', async () => {
      const screen = await render(<Combobox items={FRAMEWORKS} label="Framework" />);

      await screen.getByRole('combobox').fill('qwik');
      await expect.element(screen.getByRole('option', { name: 'Add “qwik”' })).toBeInTheDocument();

      await screen.rerender(<Combobox items={FRAMEWORKS} label="Framework" allowCustom={false} />);

      await expect
        .element(screen.getByRole('option', { name: 'Add “qwik”' }))
        .not.toBeInTheDocument();
    });

    it('offers what was typed in the language it was given', async () => {
      const screen = await render(<Combobox items={FRAMEWORKS} label="Framework" locale="ko" />);

      await screen.getByRole('combobox').fill('qwik');

      await expect.element(screen.getByRole('option', { name: '“qwik” 추가' })).toBeInTheDocument();
    });

    it('names the chevron in the language it was given when there is no label', async () => {
      const screen = await render(
        <Combobox items={FRAMEWORKS} aria-label="Framework" locale="ko" />
      );

      await expect.element(screen.getByRole('button', { name: '열기' })).toBeInTheDocument();
    });

    // The value the list does not have was a new object on every render, which
    // Base UI read as a new choice and wrote its label back over the input.
    it('keeps what is typed after a value the list does not have', async () => {
      const screen = await render(
        <Combobox items={FRAMEWORKS} label="Framework" defaultValue="qwik" />
      );
      const input = screen.getByRole('combobox');

      await expect.element(input).toHaveValue('qwik');

      await input.click();
      await userEvent.keyboard('{End}x');

      await expect.element(input).toHaveValue('qwikx');
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

    // A new value object on every render read to Base UI as a new choice, and a
    // new choice clears the errors a Form put on the field.
    it("keeps a Form's error on a multiple combobox while the form renders again", async () => {
      // Held, as a server's answer would be: a Form takes a new `errors`
      // object as a new set of errors and puts them back.
      const errors = { tags: 'Not those.' };

      function Page() {
        const [other, setOther] = React.useState('');

        return (
          <Form aria-label="Stack" errors={errors}>
            <Combobox items={FRAMEWORKS} label="Tags" name="tags" multiple />
            <TextField
              label="Other"
              name="other"
              value={other}
              onChange={(event) => setOther(event.target.value)}
            />
          </Form>
        );
      }

      const screen = await render(<Page />);
      const tags = screen.getByRole('combobox', { name: 'Tags' });

      await expect.element(tags).toHaveAttribute('aria-invalid', 'true');

      await screen.getByRole('textbox', { name: 'Other' }).fill('hello');
      await expect.element(screen.getByRole('textbox', { name: 'Other' })).toHaveValue('hello');

      await expect.element(tags).toHaveAttribute('aria-invalid', 'true');
      await expect.element(screen.getByText('Not those.')).toBeInTheDocument();
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

      expect(shell).toHaveClass('min-h-8');
      expect(shell).toHaveClass('border');
    });

    it('pads the shell for the chips when multiple', async () => {
      // Both shapes take the ladder as a floor; what a row of chips adds is
      // the vertical padding that keeps them off the hairline as they wrap.
      const screen = await render(<Combobox multiple items={FRAMEWORKS} label="Framework" />);
      const shell = screen.getByRole('combobox').element().closest('.min-h-8');

      expect(shell).not.toBeNull();
      expect(shell).toHaveClass('py-[3px]');
    });

    it('changes height with size but not with density', async () => {
      const screen = await render(<Combobox items={FRAMEWORKS} label="Framework" size="lg" />);

      expect(screen.getByRole('combobox').element().parentElement).toHaveClass('min-h-10');

      await screen.rerender(
        <Combobox items={FRAMEWORKS} label="Framework" size="lg" density="compact" />
      );

      expect(screen.getByRole('combobox').element().parentElement).toHaveClass('min-h-10');
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

  describe('autofill', () => {
    const CITIES = [
      { value: 'icn', label: 'Seoul' },
      { value: 'nrt', label: 'Tokyo' }
    ];

    /** What a browser does to the input it autofills. */
    function autofill(input: HTMLInputElement, text: string) {
      Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value')?.set?.call(input, text);
      input.dispatchEvent(new Event('input', { bubbles: true }));
    }

    it('writes autoComplete on the input that submits the value, not the one typed into', async () => {
      const screen = await render(
        <form aria-label="Address">
          <Combobox items={CITIES} label="City" name="city" autoComplete="address-level2" />
        </form>
      );
      const input = screen.getByRole('form').element().querySelector('input[name="city"]');

      expect(input).toHaveAttribute('autocomplete', 'address-level2');
      await expect.element(screen.getByRole('combobox')).toHaveAttribute('autocomplete', 'off');
    });

    it('chooses the option a browser fills in', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <form aria-label="Address">
          <Combobox
            items={CITIES}
            label="City"
            name="city"
            autoComplete="address-level2"
            onValueChange={onValueChange}
          />
        </form>
      );
      const input = screen
        .getByRole('form')
        .element()
        .querySelector('input[name="city"]') as HTMLInputElement;

      autofill(input, 'Tokyo');

      await expect.element(screen.getByRole('combobox')).toHaveValue('Tokyo');
      expect(onValueChange).toHaveBeenCalledWith('nrt');
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

  describe('label placement', () => {
    it('names the input from a notched label', async () => {
      const screen = await render(
        <Combobox items={FRAMEWORKS} labelPlacement="notch" label="Framework" />
      );

      await expect.element(screen.getByRole('combobox', { name: 'Framework' })).toBeInTheDocument();
      expect(screen.container.querySelector('.neba-notch label')).toHaveTextContent('Framework');
    });

    // The chips are not an input, so the notch is told itself.
    it('says a multiple field is empty only while nothing is chosen', async () => {
      const screen = await render(
        <Combobox multiple items={FRAMEWORKS} labelPlacement="float" label="Stack" />
      );
      const notch = () => screen.container.querySelector('.neba-notch') as HTMLElement;

      expect(notch()).toHaveAttribute('data-empty');

      await screen.rerender(
        <Combobox
          multiple
          items={FRAMEWORKS}
          labelPlacement="float"
          label="Stack"
          value={[FRAMEWORKS[0].value]}
        />
      );
      expect(notch()).not.toHaveAttribute('data-empty');
    });
  });
});
