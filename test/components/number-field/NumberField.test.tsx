import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { NumberField } from 'neba';

describe('NumberField', () => {
  describe('rendering', () => {
    it('renders a text box named by its label', async () => {
      const screen = await render(<NumberField label="Seats" />);

      await expect.element(screen.getByRole('textbox', { name: 'Seats' })).toBeInTheDocument();
    });

    it('shows the initial value', async () => {
      const screen = await render(<NumberField label="Seats" defaultValue={3} />);

      await expect.element(screen.getByRole('textbox')).toHaveValue('3');
    });

    it('says what kind of field it is', async () => {
      const screen = await render(<NumberField label="Seats" />);

      await expect
        .element(screen.getByRole('textbox'))
        .toHaveAttribute('aria-roledescription', 'Number field');
      await expect.element(screen.getByRole('textbox')).toHaveAttribute('inputmode', 'numeric');
    });

    it('carries the range on the input a form submits', async () => {
      const screen = await render(<NumberField label="Seats" defaultValue={3} min={1} max={20} />);
      const hidden = screen
        .getByText('Seats')
        .element()
        .closest('[style]')!
        .querySelector('input[type="number"]') as HTMLInputElement;

      expect(hidden.min).toBe('1');
      expect(hidden.max).toBe('20');
      expect(hidden.value).toBe('3');
    });

    it('renders both steppers by default', async () => {
      const screen = await render(<NumberField label="Seats" />);

      await expect.element(screen.getByRole('button', { name: 'Increase' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Decrease' })).toBeInTheDocument();
    });

    it('names the steppers from the props', async () => {
      const screen = await render(
        <NumberField label="Seats" incrementLabel="더하기" decrementLabel="빼기" />
      );

      await expect.element(screen.getByRole('button', { name: '더하기' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: '빼기' })).toBeInTheDocument();
    });

    it('drops the steppers when asked', async () => {
      const screen = await render(<NumberField label="Seats" steppers="none" />);

      expect(screen.getByRole('button', { name: 'Increase' }).query()).toBeNull();
      expect(screen.getByRole('button', { name: 'Decrease' }).query()).toBeNull();
    });

    it('renders the description', async () => {
      const screen = await render(<NumberField label="Seats" description="Up to twelve." />);

      await expect.element(screen.getByText('Up to twelve.')).toBeInTheDocument();
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(<NumberField label="Before" />);

      await screen.rerender(<NumberField label="After" />);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names on the field wrapper', async () => {
      const screen = await render(<NumberField label="Seats" className="my-own-class" />);

      expect(screen.getByText('Seats').element().closest('.my-own-class')).not.toBeNull();
    });
  });

  describe('behaviour', () => {
    it('steps up and reports a number, not a string', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <NumberField label="Seats" defaultValue={3} onValueChange={onValueChange} />
      );

      await screen.getByRole('button', { name: 'Increase' }).click();

      expect(onValueChange).toHaveBeenCalledWith(4);
      await expect.element(screen.getByRole('textbox')).toHaveValue('4');
    });

    it('steps down', async () => {
      const screen = await render(<NumberField label="Seats" defaultValue={3} />);

      await screen.getByRole('button', { name: 'Decrease' }).click();

      await expect.element(screen.getByRole('textbox')).toHaveValue('2');
    });

    it('steps by the step it was given', async () => {
      const screen = await render(<NumberField label="Seats" defaultValue={10} step={5} />);

      await screen.getByRole('button', { name: 'Increase' }).click();

      await expect.element(screen.getByRole('textbox')).toHaveValue('15');
    });

    it('disables the stepper that has run into the range', async () => {
      const screen = await render(<NumberField label="Seats" defaultValue={1} min={1} max={2} />);

      await expect.element(screen.getByRole('button', { name: 'Decrease' })).toBeDisabled();
      await expect.element(screen.getByRole('button', { name: 'Increase' })).not.toBeDisabled();
    });

    it('honours a controlled value', async () => {
      const screen = await render(<NumberField label="Seats" value={2} onValueChange={() => {}} />);

      await expect.element(screen.getByRole('textbox')).toHaveValue('2');

      await screen.rerender(<NumberField label="Seats" value={9} onValueChange={() => {}} />);

      await expect.element(screen.getByRole('textbox')).toHaveValue('9');
    });

    it('takes typed digits', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<NumberField label="Seats" onValueChange={onValueChange} />);

      await screen.getByRole('textbox').fill('42');

      expect(onValueChange).toHaveBeenLastCalledWith(42);
    });

    it('does not step while disabled', async () => {
      const screen = await render(<NumberField label="Seats" defaultValue={3} disabled />);

      await expect.element(screen.getByRole('textbox')).toBeDisabled();
      await expect.element(screen.getByRole('button', { name: 'Increase' })).toBeDisabled();
    });

    it('takes the steppers away while read-only', async () => {
      const screen = await render(<NumberField label="Seats" defaultValue={3} readOnly />);

      await expect.element(screen.getByRole('textbox')).toHaveAttribute('readonly');
      expect(screen.getByRole('button', { name: 'Increase' }).query()).toBeNull();
    });
  });

  describe('formatting', () => {
    it('writes the value through Intl and still reports the number', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <NumberField
          label="Budget"
          defaultValue={1240}
          locale="en-US"
          format={{ style: 'currency', currency: 'USD', maximumFractionDigits: 0 }}
          onValueChange={onValueChange}
        />
      );

      await expect.element(screen.getByRole('textbox')).toHaveValue('$1,240');

      await screen.getByRole('button', { name: 'Increase' }).click();

      expect(onValueChange).toHaveBeenCalledWith(1241);
    });
  });

  describe('validation', () => {
    it('renders the error message', async () => {
      const screen = await render(<NumberField label="Seats" error="At least one seat." />);

      await expect.element(screen.getByText('At least one seat.')).toBeInTheDocument();
    });

    it('re-points the colour family at danger when invalid', async () => {
      const screen = await render(
        <NumberField label="Seats" color="success" error="At least one seat." />
      );
      const root = screen
        .getByText('Seats', { exact: true })
        .element()
        .closest('[style]') as HTMLElement;

      expect(root.style.getPropertyValue('--n-ring')).toBe('var(--neba-danger-ring)');
    });
  });

  describe('style props', () => {
    it('is drawn on the same shell as a TextField', async () => {
      const screen = await render(<NumberField label="Seats" />);
      const shell = screen.getByRole('textbox').element().parentElement as HTMLElement;

      expect(shell).toHaveClass('h-8');
      expect(shell).toHaveClass('border');
    });

    it('changes height with size but not with density', async () => {
      const screen = await render(<NumberField label="Seats" size="lg" />);

      expect(screen.getByRole('textbox').element().parentElement).toHaveClass('h-10');

      await screen.rerender(<NumberField label="Seats" size="lg" density="compact" />);

      expect(screen.getByRole('textbox').element().parentElement).toHaveClass('h-10');
    });

    it('keeps the sheet undyed while colouring the edge', async () => {
      const screen = await render(<NumberField label="Seats" color="info" />);
      const root = screen.getByText('Seats').element().closest('[style]') as HTMLElement;

      expect(root.style.getPropertyValue('--n-panel')).toBe('var(--neba-panel)');
      expect(root.style.getPropertyValue('--n-line')).toBe('var(--neba-info-line)');
    });

    it('stretches to the container when full width', async () => {
      const screen = await render(<NumberField label="Seats" fullWidth />);
      const root = screen.getByText('Seats').element().closest('[style]') as HTMLElement;

      expect(root).toHaveClass('w-full');
      expect(root).not.toHaveClass('inline-flex');
    });
  });

  describe('locale', () => {
    it('names the two steppers in the language it was given', async () => {
      const screen = await render(<NumberField locale="ko" label="수량" />);

      await expect.element(screen.getByRole('button', { name: '값 늘리기' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: '값 줄이기' })).toBeInTheDocument();
    });

    it('takes words of its own over the locale', async () => {
      const screen = await render(
        <NumberField locale="ko" label="수량" incrementLabel="Up" decrementLabel="Down" />
      );

      await expect.element(screen.getByRole('button', { name: 'Up' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Down' })).toBeInTheDocument();
    });
  });
});
