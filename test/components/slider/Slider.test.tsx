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

    it('renders the description', async () => {
      const screen = await render(<Slider label="Volume" description="Applies to alerts too." />);

      await expect.element(screen.getByText('Applies to alerts too.')).toBeInTheDocument();
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
