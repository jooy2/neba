import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Pill } from 'neba';

describe('Pill', () => {
  describe('rendering', () => {
    it('renders its content', async () => {
      const screen = await render(<Pill>Recording</Pill>);

      await expect.element(screen.getByText('Recording')).toBeInTheDocument();
    });

    it('places startIcon before the content and endIcon after it', async () => {
      const screen = await render(
        <Pill startIcon={<span>[</span>} endIcon={<span>]</span>} data-testid="pill">
          Recording
        </Pill>
      );

      expect(screen.getByTestId('pill').element().textContent).toBe('[Recording]');
    });

    it('reflects changed content on re-render', async () => {
      const screen = await render(<Pill>Before</Pill>);

      await screen.rerender(<Pill>After</Pill>);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <Pill className="my-own-class" data-testid="pill">
          Recording
        </Pill>
      );

      expect(screen.getByTestId('pill').element()).toHaveClass('my-own-class');
    });
  });

  describe('shape', () => {
    it('is a lozenge — the one radius the rest of the library refuses', async () => {
      const screen = await render(<Pill data-testid="pill">Recording</Pill>);

      // Exactly half the md row height, so a collapsed pill is a true stadium.
      // A length rather than `rounded-full`, so an expanded one keeps the same
      // corner instead of growing one that eats its own text.
      expect(screen.getByTestId('pill').element()).toHaveClass('rounded-[1rem]');
    });

    it('floats by default rather than lying flat on the page', async () => {
      const screen = await render(<Pill data-testid="pill">Recording</Pill>);
      const element = screen.getByTestId('pill').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-2)');
    });

    it('pins itself against the viewport when fixed', async () => {
      const screen = await render(
        <Pill position="fixed" side="bottom" data-testid="pill">
          Recording
        </Pill>
      );
      const element = screen.getByTestId('pill').element();

      expect(element).toHaveClass('fixed');
      expect(element).toHaveClass('bottom-3');
      // Centred with auto margins, never with a transform.
      expect(element).toHaveClass('mx-auto');
      expect(element.className).not.toContain('translate');
    });

    it('sits in the flow by default', async () => {
      const screen = await render(<Pill data-testid="pill">Recording</Pill>);
      const element = screen.getByTestId('pill').element();

      expect(element).not.toHaveClass('fixed');
      expect(element).not.toHaveClass('sticky');
    });
  });

  describe('details', () => {
    it('renders nothing extra without details', async () => {
      const screen = await render(<Pill data-testid="pill">Recording</Pill>);

      expect(screen.getByTestId('pill').element().textContent).toBe('Recording');
    });

    it('holds the details area closed until expanded', async () => {
      const screen = await render(
        <Pill details={<span>02:14 elapsed</span>} data-testid="pill">
          Recording
        </Pill>
      );
      // The animating box is the one carrying an inline height; the div inside
      // it is what gets measured.
      const panel = screen.getByText('02:14 elapsed').element().closest('[style]') as HTMLElement;

      expect(panel.style.height).toBe('0px');
      expect(panel).toHaveAttribute('inert');

      await screen.rerender(
        <Pill details={<span>02:14 elapsed</span>} expanded data-testid="pill">
          Recording
        </Pill>
      );

      expect(panel.style.height).not.toBe('0px');
      expect(panel).not.toHaveAttribute('inert');
    });
  });

  describe('interaction', () => {
    it('is inert markup until onClick makes it a button', async () => {
      const screen = await render(<Pill>Recording</Pill>);

      expect(screen.getByRole('button').query()).toBeNull();
    });

    it('presses through a real button, with endIcon left outside it', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <Pill onClick={onClick} endIcon={<span>x</span>}>
          Recording
        </Pill>
      );
      const button = screen.getByRole('button', { name: 'Recording' });

      await button.click();

      expect(onClick).toHaveBeenCalledTimes(1);
      expect(button.element().textContent).toBe('Recording');
    });
  });

  describe('style props', () => {
    it('takes the tinted control slots, not a container’s undyed ones', async () => {
      const screen = await render(
        <Pill color="danger" data-testid="pill">
          Recording
        </Pill>
      );
      const element = screen.getByTestId('pill').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-danger-fill)');
      expect(element.style.getPropertyValue('--n-panel')).toBe('var(--neba-danger-panel)');
    });

    it('changes height with size but not with density', async () => {
      const screen = await render(
        <Pill size="lg" data-testid="pill">
          Recording
        </Pill>
      );
      const row = screen.getByText('Recording').element().parentElement as HTMLElement;

      expect(row).toHaveClass('h-10');

      await screen.rerender(
        <Pill size="lg" density="compact" data-testid="pill">
          Recording
        </Pill>
      );

      expect(row).toHaveClass('h-10');
      expect(row).toHaveClass('px-3');
    });
  });
});
