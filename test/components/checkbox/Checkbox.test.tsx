import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Checkbox } from 'neba';

describe('Checkbox', () => {
  describe('rendering', () => {
    it('renders a checkbox named by its label', async () => {
      const screen = await render(<Checkbox label="Remember me" />);

      await expect
        .element(screen.getByRole('checkbox', { name: 'Remember me' }))
        .toBeInTheDocument();
    });

    it('renders without a label', async () => {
      const screen = await render(<Checkbox aria-label="Select row" />);

      await expect
        .element(screen.getByRole('checkbox', { name: 'Select row' }))
        .toBeInTheDocument();
    });

    it('renders the description', async () => {
      const screen = await render(<Checkbox label="Emails" description="About once a week." />);

      await expect.element(screen.getByText('About once a week.')).toBeInTheDocument();
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(<Checkbox label="Before" />);

      await screen.rerender(<Checkbox label="After" />);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names on the field wrapper', async () => {
      const screen = await render(<Checkbox label="Tick" className="my-own-class" />);

      expect(screen.getByText('Tick').element().closest('.my-own-class')).not.toBeNull();
    });
  });

  // Nothing loads Tailwind into the test run, so the tick renders at zero size
  // and cannot be clicked directly. Every interaction below goes through the
  // label, which is the path a real user takes anyway — and the fact that it
  // works is what proves Base UI's Field wired the two together.
  describe('behaviour', () => {
    it('toggles when its label is clicked', async () => {
      const screen = await render(<Checkbox label="Remember me" />);
      const checkbox = screen.getByRole('checkbox', { name: 'Remember me' });

      await expect.element(checkbox).not.toBeChecked();

      await screen.getByText('Remember me').click();

      await expect.element(checkbox).toBeChecked();
    });

    it('reports the new state', async () => {
      const onCheckedChange = vi.fn();
      const screen = await render(
        <Checkbox label="Remember me" onCheckedChange={onCheckedChange} />
      );

      await screen.getByText('Remember me').click();

      expect(onCheckedChange).toHaveBeenCalledTimes(1);
      expect(onCheckedChange.mock.calls[0][0]).toBe(true);
    });

    it('honours a controlled checked prop', async () => {
      const screen = await render(
        <Checkbox label="Remember me" checked onCheckedChange={() => {}} />
      );

      await expect.element(screen.getByRole('checkbox')).toBeChecked();

      await screen.rerender(
        <Checkbox label="Remember me" checked={false} onCheckedChange={() => {}} />
      );

      await expect.element(screen.getByRole('checkbox')).not.toBeChecked();
    });

    it('is out of reach when disabled', async () => {
      const screen = await render(<Checkbox label="Remember me" disabled />);
      const checkbox = screen.getByRole('checkbox').element();

      await expect.element(screen.getByRole('checkbox')).toBeDisabled();
      expect(checkbox).toHaveAttribute('tabindex', '-1');
      expect(checkbox).toHaveClass('text-(--neba-disabled-fg)');
    });

    it('does not toggle when read-only', async () => {
      const onCheckedChange = vi.fn();
      const screen = await render(
        <Checkbox label="Remember me" readOnly onCheckedChange={onCheckedChange} />
      );

      await screen.getByText('Remember me').click();

      expect(onCheckedChange).not.toHaveBeenCalled();
    });

    it('reports a mixed state', async () => {
      const screen = await render(<Checkbox label="All" indeterminate />);

      await expect.element(screen.getByRole('checkbox')).toHaveAttribute('aria-checked', 'mixed');
    });
  });

  describe('validation', () => {
    it('renders the error message', async () => {
      const screen = await render(<Checkbox label="Terms" error="You have to agree." />);

      await expect.element(screen.getByText('You have to agree.')).toBeInTheDocument();
    });

    it('re-points the colour family at danger when invalid', async () => {
      const screen = await render(<Checkbox label="Terms" color="success" error="Required" />);
      const root = screen.getByText('Terms').element().closest('[style]') as HTMLElement;

      expect(root.style.getPropertyValue('--n-fill')).toBe('var(--neba-danger-fill)');
    });

    it('can be made invalid without a message', async () => {
      const screen = await render(<Checkbox label="Terms" invalid />);

      await expect.element(screen.getByRole('checkbox')).toHaveAttribute('aria-invalid', 'true');
      expect(screen.getByText('Required').query()).toBeNull();
    });
  });

  describe('style props', () => {
    it('maps colour onto the token slots', async () => {
      const screen = await render(<Checkbox label="Tick" color="success" />);
      const root = screen.getByText('Tick').element().closest('[style]') as HTMLElement;

      expect(root.style.getPropertyValue('--n-fill')).toBe('var(--neba-success-fill)');
      expect(root.style.getPropertyValue('--n-ring')).toBe('var(--neba-success-ring)');
    });

    it('keeps the sheet undyed', async () => {
      const screen = await render(<Checkbox label="Tick" color="success" />);
      const root = screen.getByText('Tick').element().closest('[style]') as HTMLElement;

      expect(root.style.getPropertyValue('--n-panel')).toBe('var(--neba-panel)');
    });

    it('scales the tick with size', async () => {
      const screen = await render(<Checkbox label="Tick" size="xl" />);

      expect(screen.getByRole('checkbox').element()).toHaveClass('size-6');
    });

    it('never applies a transform', async () => {
      const screen = await render(
        <Checkbox label="Tick" description="Note" error="Bad" indeterminate />
      );
      const root = screen.getByText('Tick').element().closest('[style]') as HTMLElement;

      expect(root.outerHTML).not.toContain('scale');
      expect(root.outerHTML).not.toContain('translate');
    });
  });
});
