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

    it('tells a screen reader that pressing it reveals the details', async () => {
      const screen = await render(
        <Pill details={<span>02:14 elapsed</span>} onClick={() => {}}>
          Recording
        </Pill>
      );
      const button = screen.getByRole('button', { name: 'Recording' });

      await expect.element(button).toHaveAttribute('aria-expanded', 'false');
      const panel = document.getElementById(button.element().getAttribute('aria-controls')!);
      expect(panel?.textContent).toBe('02:14 elapsed');

      await screen.rerender(
        <Pill details={<span>02:14 elapsed</span>} expanded onClick={() => {}}>
          Recording
        </Pill>
      );

      await expect.element(button).toHaveAttribute('aria-expanded', 'true');
    });

    it('says nothing about expanding when there is nothing to expand', async () => {
      const screen = await render(<Pill onClick={() => {}}>Recording</Pill>);

      expect(screen.getByRole('button', { name: 'Recording' }).element()).not.toHaveAttribute(
        'aria-expanded'
      );
    });

    it('follows details that grow while it is open', async () => {
      const pill = (height: number) => (
        <Pill details={<div style={{ height }}>Log</div>} expanded data-testid="pill">
          Recording
        </Pill>
      );
      const screen = await render(pill(40));
      const panel = screen.getByText('Log').element().parentElement!.parentElement as HTMLElement;

      await expect.poll(() => parseFloat(panel.style.height)).toBeGreaterThanOrEqual(40);

      await screen.rerender(pill(160));

      await expect.poll(() => parseFloat(panel.style.height)).toBeGreaterThanOrEqual(160);
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
      const screen = await render(<Pill size="lg" title="Recording" data-testid="pill" />);
      const row = screen.getByTestId('pill').element().firstElementChild as HTMLElement;

      expect(row).toHaveClass('min-h-10');

      await screen.rerender(
        <Pill size="lg" density="compact" title="Recording" data-testid="pill" />
      );

      expect(row).toHaveClass('min-h-10');
      expect(row).toHaveClass('px-3');
    });
  });

  describe('title and description', () => {
    it('renders both, title first', async () => {
      const screen = await render(
        <Pill title="Recording" description="02:14 elapsed" data-testid="pill" />
      );

      expect(screen.getByTestId('pill').element().textContent).toBe('Recording02:14 elapsed');
    });

    it('renders either one on its own', async () => {
      const screen = await render(<Pill title="Recording" data-testid="pill" />);

      expect(screen.getByTestId('pill').element().textContent).toBe('Recording');

      await screen.rerender(<Pill description="02:14 elapsed" data-testid="pill" />);

      expect(screen.getByTestId('pill').element().textContent).toBe('02:14 elapsed');
    });

    it('reflects a changed title on re-render', async () => {
      const screen = await render(<Pill title="Before" />);

      await screen.rerender(<Pill title="After" />);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('centres them between the two slots, well clear of both', async () => {
      const screen = await render(
        <Pill startIcon={<span>[</span>} endIcon={<span>]</span>} title="Recording" />
      );
      const middle = screen.getByText('Recording').element().parentElement as HTMLElement;

      expect(middle).toHaveClass('items-center');
      expect(middle).toHaveClass('text-center');
      // Roughly double the control padding, so the middle is the thing the eye
      // lands on rather than a word wedged between two glyphs.
      expect(middle).toHaveClass('px-5');
    });

    it('keeps `title` out of the DOM attribute of the same name', async () => {
      const screen = await render(<Pill title="Recording" data-testid="pill" />);

      expect(screen.getByTestId('pill').element()).not.toHaveAttribute('title');
    });

    it('puts children in the same centred column, after both', async () => {
      const screen = await render(
        <Pill title="Recording" description="02:14" data-testid="pill">
          <span>live</span>
        </Pill>
      );

      expect(screen.getByTestId('pill').element().textContent).toBe('Recording02:14live');
      expect(screen.getByText('live').element().parentElement).toBe(
        screen.getByText('Recording').element().parentElement
      );
    });

    it('gives the leading slot a round box of its own, so an image can fill it', async () => {
      const screen = await render(<Pill startIcon={<span>[</span>} title="Recording" />);
      const media = screen.getByText('[').element().parentElement as HTMLElement;

      expect(media).toHaveClass('rounded-full');
      expect(media).toHaveClass('overflow-hidden');
      expect(media).toHaveClass('size-5');
    });
  });

  /* `--n-on-solid` on `--n-fill` is 4.6:1 at full strength, so a dimmed copy of
     it cannot clear 4.5:1 on a `solid` pill at any percentage worth having. The
     step down is size and weight, and the ink is left alone. */
  describe('the description ink', () => {
    it('is not dimmed out of the title ink', async () => {
      const screen = await render(<Pill title="Recording" description="02:14 elapsed" />);
      const element = screen.getByText('02:14 elapsed').element();

      expect(element.className).not.toContain('color-mix');
      expect(element).toHaveClass('font-normal');
    });
  });
});
