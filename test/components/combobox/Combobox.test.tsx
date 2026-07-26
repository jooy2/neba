import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Combobox } from 'neba';

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
});
