import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Slider } from 'neba';

describe('Slider', () => {
  describe('rendering', () => {
    it('renders a slider', async () => {
      const screen = await render(<Slider aria-label="Volume" defaultValue={40} />);
      const control = screen.getByRole('slider').element();

      expect(control).toHaveAttribute('aria-valuenow', '40');
    });

    it('renders a label and names the slider with it', async () => {
      const screen = await render(<Slider label="Volume" defaultValue={40} />);

      await expect.element(screen.getByRole('slider', { name: 'Volume' })).toBeInTheDocument();
    });

    it('renders the description and describes the thumb with it', async () => {
      const screen = await render(<Slider label="Volume" description="Applies to alerts too." />);

      await expect.element(screen.getByText('Applies to alerts too.')).toBeInTheDocument();
      await expect
        .element(screen.getByRole('slider', { name: 'Volume' }))
        .toHaveAccessibleDescription('Applies to alerts too.');
    });

    // With no visible label the name is written on the component, and the
    // component is not the control.
    it('names the thumb by an aria-label written on the component', async () => {
      const screen = await render(<Slider aria-label="Volume" defaultValue={40} />);

      await expect.element(screen.getByRole('slider', { name: 'Volume' })).toBeInTheDocument();
    });

    it('names each thumb and reads each value the way it is told to', async () => {
      const screen = await render(
        <Slider
          label="Price"
          defaultValue={[20, 80]}
          getAriaLabel={(index) => (index === 0 ? 'Minimum price' : 'Maximum price')}
          getAriaValueText={(formatted) => `${formatted} dollars`}
        />
      );

      await expect
        .element(screen.getByRole('slider', { name: 'Minimum price' }))
        .toHaveAttribute('aria-valuetext', '20 dollars');
      await expect
        .element(screen.getByRole('slider', { name: 'Maximum price' }))
        .toHaveAttribute('aria-valuetext', '80 dollars');
    });

    it('shows the value only when asked', async () => {
      const screen = await render(<Slider label="Volume" defaultValue={40} />);

      expect(screen.getByText('40').query()).toBeNull();

      await screen.rerender(<Slider label="Volume" defaultValue={40} showValue />);

      await expect.element(screen.getByText('40')).toBeInTheDocument();
    });

    it('formats the shown value when given a function', async () => {
      const screen = await render(
        <Slider
          label="Volume"
          defaultValue={40}
          showValue={(formatted) => `${formatted[0]} per cent`}
        />
      );

      await expect.element(screen.getByText('40 per cent')).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <Slider aria-label="Volume" className="my-own-class" data-testid="slider" />
      );

      expect(screen.getByTestId('slider').element()).toHaveClass('my-own-class');
    });
  });

  describe('range', () => {
    it('renders one thumb for a single value', async () => {
      const screen = await render(<Slider aria-label="Volume" defaultValue={40} />);

      expect(screen.container.querySelectorAll('input[type="range"]')).toHaveLength(1);
    });

    it('renders one thumb per value in an array', async () => {
      const screen = await render(<Slider aria-label="Range" defaultValue={[20, 80]} />);

      expect(screen.container.querySelectorAll('input[type="range"]')).toHaveLength(2);
    });

    it('follows the controlled value on re-render', async () => {
      const screen = await render(
        <Slider aria-label="Volume" value={20} onValueChange={() => {}} />
      );

      expect(screen.getByRole('slider').element()).toHaveAttribute('aria-valuenow', '20');

      await screen.rerender(<Slider aria-label="Volume" value={70} onValueChange={() => {}} />);

      expect(screen.getByRole('slider').element()).toHaveAttribute('aria-valuenow', '70');
    });
  });

  describe('behaviour', () => {
    // The thumb's hit target is a visually hidden `<input type="range">`, which
    // Playwright will not click. Driving the input the way the browser does —
    // set the value, fire `input` — is what a keypress or a drag ends up doing
    // anyway, and it is the only path available without a stylesheet.
    it('reports a new value and moves to it', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Slider label="Volume" defaultValue={40} step={5} onValueChange={onValueChange} />
      );
      const input = screen.getByRole('slider').element() as HTMLInputElement;
      const setValue = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value')!.set!;

      setValue.call(input, '45');
      input.dispatchEvent(new Event('input', { bubbles: true }));

      expect(onValueChange).toHaveBeenCalled();
      expect(onValueChange.mock.calls.at(-1)![0]).toBe(45);
      await expect.element(screen.getByRole('slider')).toHaveAttribute('aria-valuenow', '45');
    });

    it('respects min, max and step', async () => {
      const screen = await render(
        <Slider aria-label="Volume" defaultValue={4} min={0} max={10} step={2} />
      );
      const input = screen.getByRole('slider').element();

      expect(input).toHaveAttribute('min', '0');
      expect(input).toHaveAttribute('max', '10');
      expect(input).toHaveAttribute('step', '2');
    });

    it('is out of reach when disabled', async () => {
      const screen = await render(<Slider aria-label="Volume" defaultValue={40} disabled />);

      await expect.element(screen.getByRole('slider')).toBeDisabled();
    });

    // It was the whole slider at 70% opacity, which fades the label with it and
    // is the one axis a state is never carried on.
    it('shows disabled in colour rather than by fading', async () => {
      const screen = await render(
        <Slider
          label="Volume"
          defaultValue={40}
          disabled
          data-testid="slider"
          classNames={{ track: 'a-track', indicator: 'a-fill' }}
        />
      );
      const root = screen.getByTestId('slider').element();

      expect(root.className).not.toMatch(/opacity/);
      expect(root.querySelector('.a-track')).toHaveClass('bg-(--neba-disabled-bg)');
      expect(root.querySelector('.a-fill')).toHaveClass('bg-(--neba-disabled-fg)');
    });
  });

  describe('marks', () => {
    const LEVELS = [
      { value: 1, label: 'One' },
      { value: 250, label: 'Some' },
      { value: 500, label: 'Every' }
    ];

    it('draws none unless asked', async () => {
      const screen = await render(
        <Slider aria-label="Count" min={1} max={500} data-testid="slider" />
      );

      expect(screen.container.querySelector('[aria-hidden="true"]')).toBeNull();
    });

    it('writes each mark at its share of the range', async () => {
      const screen = await render(
        <Slider
          aria-label="Count"
          min={1}
          max={500}
          marks={LEVELS}
          classNames={{ mark: 'a-mark' }}
        />
      );
      const marks = [...screen.container.querySelectorAll<HTMLElement>('.a-mark')];

      expect(marks).toHaveLength(3);
      expect(marks[0].style.insetInlineStart).toBe('0%');
      expect(marks[2].style.insetInlineStart).toBe('100%');
      await expect.element(screen.getByText('Some')).toBeInTheDocument();
    });

    it('measures a vertical slider from the bottom', async () => {
      const screen = await render(
        <Slider
          aria-label="Count"
          orientation="vertical"
          marks={LEVELS}
          classNames={{ mark: 'a-mark' }}
        />
      );
      const mark = screen.container.querySelector<HTMLElement>('.a-mark');

      expect(mark?.style.insetBlockEnd).toBe('1%');
      expect(mark?.style.insetInlineStart).toBe('');
    });

    it('takes a tick at every step when told to', async () => {
      const screen = await render(
        <Slider
          aria-label="Volume"
          min={0}
          max={100}
          step={25}
          marks
          classNames={{ mark: 'a-mark' }}
        />
      );

      expect(screen.container.querySelectorAll('.a-mark')).toHaveLength(5);
    });

    it('keeps the mark at the top of a range stepped in tenths', async () => {
      const screen = await render(
        <Slider
          aria-label="Opacity"
          min={0}
          max={0.6}
          step={0.1}
          marks
          classNames={{ mark: 'a-mark' }}
        />
      );

      const marks = [...screen.container.querySelectorAll<HTMLElement>('.a-mark')];

      expect(marks).toHaveLength(7);
      expect(parseFloat(marks[6].style.insetInlineStart)).toBeCloseTo(100, 5);
    });

    it('draws none at all rather than a thousand of them', async () => {
      // A step nobody chose over a range nobody bounded is the one case where
      // "a tick at every step" is not what the caller meant.
      const screen = await render(
        <Slider
          aria-label="Ratio"
          min={0}
          max={100}
          step={0.01}
          marks
          classNames={{ mark: 'a-mark' }}
        />
      );

      expect(screen.container.querySelectorAll('.a-mark')).toHaveLength(0);
    });

    it('keeps the marks out of the accessibility tree', async () => {
      // The thumb announces the value and the range; the same numbers read
      // again as loose text ahead of it are noise.
      const screen = await render(<Slider aria-label="Count" min={1} max={500} marks={LEVELS} />);
      const row = screen.getByText('Some').element().closest('[aria-hidden="true"]');

      expect(row).not.toBeNull();
    });
  });

  describe('style props', () => {
    it('maps colour onto the token slots', async () => {
      const screen = await render(
        <Slider aria-label="Volume" color="danger" data-testid="slider" />
      );
      const element = screen.getByTestId('slider').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-danger-fill)');
      expect(element.style.getPropertyValue('--n-ring')).toBe('var(--neba-danger-ring)');
    });

    it('turns the track on its side when vertical', async () => {
      const screen = await render(
        <Slider aria-label="Volume" orientation="vertical" data-testid="slider" />
      );
      const element = screen.getByTestId('slider').element();

      expect(element).toHaveClass('flex-col');
      expect(screen.getByRole('slider').element()).toHaveAttribute('aria-orientation', 'vertical');
    });

    it('grows the thumb with size', async () => {
      const screen = await render(<Slider aria-label="Volume" size="xl" data-testid="slider" />);

      expect(screen.container.querySelector('.size-6')).not.toBeNull();
    });
  });
});
