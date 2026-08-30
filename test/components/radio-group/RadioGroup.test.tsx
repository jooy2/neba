import type { ComponentProps } from 'react';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Radio, RadioGroup } from 'neba';

function Plans(props: ComponentProps<typeof RadioGroup>) {
  return (
    <RadioGroup {...props}>
      <Radio value="starter" label="Starter" />
      <Radio value="team" label="Team" />
      <Radio value="enterprise" label="Enterprise" disabled />
    </RadioGroup>
  );
}

describe('RadioGroup', () => {
  describe('rendering', () => {
    it('renders a radio group holding its options', async () => {
      const screen = await render(<Plans label="Plan" />);

      await expect.element(screen.getByRole('radiogroup')).toBeInTheDocument();
      await expect.element(screen.getByRole('radio', { name: 'Starter' })).toBeInTheDocument();
      await expect.element(screen.getByRole('radio', { name: 'Team' })).toBeInTheDocument();
    });

    it('renders the group label and description', async () => {
      const screen = await render(<Plans label="Plan" description="Change it any time." />);

      await expect.element(screen.getByText('Plan')).toBeInTheDocument();
      await expect.element(screen.getByText('Change it any time.')).toBeInTheDocument();
    });

    it('renders a per-option description', async () => {
      const screen = await render(
        <RadioGroup label="Plan">
          <Radio value="team" label="Team" description="Up to twelve seats." />
        </RadioGroup>
      );

      await expect.element(screen.getByText('Up to twelve seats.')).toBeInTheDocument();
    });

    it('stacks the options vertically by default and in a row on request', async () => {
      const screen = await render(<Plans label="Plan" />);

      expect(screen.getByRole('radiogroup').element()).toHaveClass('flex-col');

      await screen.rerender(<Plans label="Plan" orientation="horizontal" />);

      expect(screen.getByRole('radiogroup').element()).toHaveClass('flex-row');
    });

    it('keeps caller-supplied class names on the field wrapper', async () => {
      const screen = await render(<Plans label="Plan" className="my-own-class" />);

      expect(screen.getByText('Plan').element().closest('.my-own-class')).not.toBeNull();
    });
  });

  describe('behaviour', () => {
    it('selects an option when its label is clicked', async () => {
      const screen = await render(<Plans label="Plan" />);

      await screen.getByText('Team').click();

      await expect.element(screen.getByRole('radio', { name: 'Team' })).toBeChecked();
      await expect.element(screen.getByRole('radio', { name: 'Starter' })).not.toBeChecked();
    });

    it('reports the chosen value', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<Plans label="Plan" onValueChange={onValueChange} />);

      await screen.getByText('Team').click();

      expect(onValueChange).toHaveBeenCalledTimes(1);
      expect(onValueChange.mock.calls[0][0]).toBe('team');
    });

    it('honours a controlled value', async () => {
      const screen = await render(<Plans label="Plan" value="team" onValueChange={() => {}} />);

      await expect.element(screen.getByRole('radio', { name: 'Team' })).toBeChecked();

      await screen.rerender(<Plans label="Plan" value="starter" onValueChange={() => {}} />);

      await expect.element(screen.getByRole('radio', { name: 'Starter' })).toBeChecked();
    });

    it('starts from defaultValue when uncontrolled', async () => {
      const screen = await render(<Plans label="Plan" defaultValue="enterprise" />);

      await expect.element(screen.getByRole('radio', { name: 'Enterprise' })).toBeChecked();
    });

    it('leaves a disabled option out of reach', async () => {
      const screen = await render(<Plans label="Plan" />);

      await expect.element(screen.getByRole('radio', { name: 'Enterprise' })).toBeDisabled();
    });

    it('does not change when the group is read-only', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<Plans label="Plan" readOnly onValueChange={onValueChange} />);

      await screen.getByText('Team').click();

      expect(onValueChange).not.toHaveBeenCalled();
    });

    it('takes one tab stop for the whole set', async () => {
      const screen = await render(<Plans label="Plan" defaultValue="team" />);
      const tabbable = [...screen.container.querySelectorAll('[role="radio"]')].filter(
        (radio) => radio.getAttribute('tabindex') === '0'
      );

      expect(tabbable).toHaveLength(1);
    });
  });

  describe('inherited props', () => {
    it('sizes every option from the group', async () => {
      const screen = await render(<Plans label="Plan" size="xl" />);

      expect(screen.getByRole('radio', { name: 'Starter' }).element()).toHaveClass('size-6');
    });

    it('maps the group colour onto the token slots', async () => {
      const screen = await render(<Plans label="Plan" color="success" />);
      const root = screen.getByText('Plan').element().closest('[style]') as HTMLElement;

      expect(root.style.getPropertyValue('--n-fill')).toBe('var(--neba-success-fill)');
    });

    it('re-points the colour family at danger when invalid', async () => {
      const screen = await render(<Plans label="Plan" error="Choose one." />);
      const root = screen.getByText('Plan').element().closest('[style]') as HTMLElement;

      expect(root.style.getPropertyValue('--n-fill')).toBe('var(--neba-danger-fill)');
      await expect.element(screen.getByText('Choose one.')).toBeInTheDocument();
    });

    it('carries the read-only treatment down to every option', async () => {
      const screen = await render(<Plans label="Plan" readOnly />);

      expect(screen.getByRole('radio', { name: 'Starter' }).element()).toHaveClass(
        '[filter:saturate(0.55)]'
      );
    });
  });

  describe('the dot', () => {
    /**
     * Whole pixels rather than a percentage of the ring around it: 38% of an
     * 18px box is 6.08px, and a circle whose diameter falls between two device
     * pixels is antialiased unevenly on its four sides — which is what reads as
     * "the dot is not centred" even when the box says it is.
     */
    it('is sized in whole pixels, and scales with the group', async () => {
      const screen = await render(<Plans label="Plan" defaultValue="team" />);
      const dot = screen.getByRole('radio', { name: 'Team' }).element()
        .firstElementChild as HTMLElement;

      expect(dot).toHaveClass('size-[0.4375rem]');
      expect(dot.className).not.toContain('%');

      await screen.rerender(<Plans label="Plan" defaultValue="team" size="xl" />);

      expect(screen.getByRole('radio', { name: 'Team' }).element().firstElementChild).toHaveClass(
        'size-[0.5625rem]'
      );
    });

    it('wears no plate, chosen or not', async () => {
      const screen = await render(<Plans label="Plan" defaultValue="team" />);

      expect(screen.getByRole('radio', { name: 'Team' }).element().className).not.toContain(
        'neba-plate'
      );
    });

    it('measures against the label’s own line, not the page’s', async () => {
      const screen = await render(<Plans label="Plan" />);
      const row = screen.getByRole('radio', { name: 'Starter' }).element().parentElement
        ?.parentElement as HTMLElement;

      expect(row).toHaveClass('leading-[1.4]');
    });
  });
  describe('slots', () => {
    it('puts a class name on every part of the group it was given one for', async () => {
      const screen = await render(
        <Plans
          label="Plan"
          description="Change it any time."
          error="Required"
          classNames={{
            label: 'slot-label',
            control: 'slot-control',
            description: 'slot-description',
            error: 'slot-error'
          }}
        />
      );

      expect(screen.getByRole('radiogroup').element()).toHaveClass('slot-control');
      expect(screen.getByText('Plan').element()).toHaveClass('slot-label');
      expect(screen.getByText('Change it any time.').element()).toHaveClass('slot-description');
      expect(screen.getByText('Required').element()).toHaveClass('slot-error');
    });

    /** A single option is styled on the Radio, never through the group. */
    it('puts a class name on the parts of one option', async () => {
      const screen = await render(
        <RadioGroup label="Plan" defaultValue="team">
          <Radio
            value="team"
            label="Team"
            description="Up to ten seats."
            classNames={{
              label: 'slot-label',
              control: 'slot-control',
              indicator: 'slot-indicator',
              description: 'slot-description'
            }}
          />
        </RadioGroup>
      );
      const dot = screen.getByRole('radio', { name: /Team/ }).element();

      expect(dot).toHaveClass('slot-control');
      expect(dot.querySelector('.slot-indicator')).not.toBeNull();
      expect(screen.getByText('Team').element()).toHaveClass('slot-label');
      expect(screen.getByText('Up to ten seats.').element()).toHaveClass('slot-description');
    });

    it('leaves the root to `className`', async () => {
      const screen = await render(
        <Plans label="Plan" className="root-class" classNames={{ control: 'control-class' }} />
      );
      const group = screen.getByRole('radiogroup').element();

      expect(group).not.toHaveClass('root-class');
      expect(group.closest('.root-class')).not.toBeNull();
    });
  });
});
