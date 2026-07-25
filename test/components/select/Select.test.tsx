import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Select } from 'neba';

const PLANS = [
  { value: 'starter', label: 'Starter' },
  { value: 'team', label: 'Team' },
  { value: 'enterprise', label: 'Enterprise', disabled: true }
];

describe('Select', () => {
  describe('rendering', () => {
    it('renders a combobox named by its label', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" />);

      await expect.element(screen.getByRole('combobox', { name: 'Plan' })).toBeInTheDocument();
    });

    it('shows the placeholder while nothing is chosen', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" placeholder="Pick one" />);

      await expect.element(screen.getByText('Pick one')).toBeInTheDocument();
    });

    it("shows the chosen option's label rather than its value", async () => {
      const screen = await render(<Select items={PLANS} label="Plan" defaultValue="team" />);

      await expect.element(screen.getByRole('combobox')).toHaveTextContent('Team');
      expect(screen.getByRole('combobox').element().textContent).not.toContain('team');
    });

    it('falls back to the value when an option has no label', async () => {
      const screen = await render(
        <Select items={[{ value: 'kr' }]} label="Country" defaultValue="kr" />
      );

      await expect.element(screen.getByText('kr')).toBeInTheDocument();
    });

    it('renders the description', async () => {
      const screen = await render(
        <Select items={PLANS} label="Plan" description="Change it any time." />
      );

      await expect.element(screen.getByText('Change it any time.')).toBeInTheDocument();
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(<Select items={PLANS} label="Before" />);

      await screen.rerender(<Select items={PLANS} label="After" />);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names on the field wrapper', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" className="my-own-class" />);

      expect(screen.getByText('Plan').element().closest('.my-own-class')).not.toBeNull();
    });
  });

  describe('behaviour', () => {
    it('opens the list and chooses an option', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Select items={PLANS} label="Plan" placeholder="Pick one" onValueChange={onValueChange} />
      );

      await screen.getByRole('combobox').click();

      await expect.element(screen.getByRole('option', { name: 'Team' })).toBeInTheDocument();

      await screen.getByRole('option', { name: 'Team' }).click();

      expect(onValueChange).toHaveBeenCalledWith('team');
      await expect.element(screen.getByRole('combobox')).toHaveTextContent('Team');
    });

    it('marks a disabled option as unavailable', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" />);

      await screen.getByRole('combobox').click();

      await expect
        .element(screen.getByRole('option', { name: 'Enterprise' }))
        .toHaveAttribute('aria-disabled', 'true');
    });

    it('honours a controlled value', async () => {
      const screen = await render(
        <Select items={PLANS} label="Plan" value="team" onValueChange={() => {}} />
      );

      await expect.element(screen.getByRole('combobox')).toHaveTextContent('Team');

      await screen.rerender(
        <Select items={PLANS} label="Plan" value="starter" onValueChange={() => {}} />
      );

      await expect.element(screen.getByRole('combobox')).toHaveTextContent('Starter');
    });

    it('does not open when disabled', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" disabled />);

      await expect.element(screen.getByRole('combobox')).toBeDisabled();
      expect(screen.getByRole('option', { name: 'Team' }).query()).toBeNull();
    });
  });

  describe('validation', () => {
    it('renders the error message', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" error="Choose a plan." />);

      await expect.element(screen.getByText('Choose a plan.')).toBeInTheDocument();
    });

    it('re-points the colour family at danger when invalid', async () => {
      const screen = await render(
        <Select items={PLANS} label="Plan" color="success" error="Choose a plan." />
      );
      const root = screen
        .getByText('Plan', { exact: true })
        .element()
        .closest('[style]') as HTMLElement;

      expect(root.style.getPropertyValue('--n-ring')).toBe('var(--neba-danger-ring)');
    });
  });

  describe('style props', () => {
    it('is drawn on the same shell as a TextField', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" />);
      const trigger = screen.getByRole('combobox').element();

      expect(trigger).toHaveClass('h-8');
      expect(trigger).toHaveClass('px-4');
      expect(trigger).toHaveClass('border');
    });

    it('changes height with size but not with density', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" size="lg" />);

      expect(screen.getByRole('combobox').element()).toHaveClass('h-10');

      await screen.rerender(<Select items={PLANS} label="Plan" size="lg" density="compact" />);
      const trigger = screen.getByRole('combobox').element();

      expect(trigger).toHaveClass('h-10');
      expect(trigger).toHaveClass('px-3');
    });

    it('keeps the sheet undyed while colouring the edge', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" color="info" />);
      const root = screen.getByText('Plan').element().closest('[style]') as HTMLElement;

      expect(root.style.getPropertyValue('--n-panel')).toBe('var(--neba-panel)');
      expect(root.style.getPropertyValue('--n-line')).toBe('var(--neba-info-line)');
    });

    it('stretches to the container when full width', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" fullWidth />);
      const root = screen.getByText('Plan').element().closest('[style]') as HTMLElement;

      expect(root).toHaveClass('w-full');
      expect(root).not.toHaveClass('inline-flex');
    });
  });
});
