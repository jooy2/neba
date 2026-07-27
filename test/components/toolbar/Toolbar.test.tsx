import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button, Toolbar } from 'neba';

describe('Toolbar', () => {
  describe('rendering', () => {
    it('renders its three slots in order', async () => {
      const screen = await render(
        <Toolbar start={<span>Logo</span>} end={<span>Actions</span>} data-testid="bar">
          Title
        </Toolbar>
      );

      expect(screen.getByTestId('bar').element().textContent).toBe('LogoTitleActions');
    });

    it('renders a div by default and whatever render says otherwise', async () => {
      const screen = await render(<Toolbar data-testid="bar">Title</Toolbar>);

      expect(screen.getByTestId('bar').element().tagName).toBe('DIV');

      await screen.rerender(
        <Toolbar render={<header />} data-testid="bar">
          Title
        </Toolbar>
      );

      expect(screen.getByTestId('bar').element().tagName).toBe('HEADER');
    });

    it('holds the ends apart even with nothing in the middle', async () => {
      const screen = await render(
        <Toolbar start={<span>Logo</span>} end={<span>Actions</span>} data-testid="bar" />
      );
      const element = screen.getByTestId('bar').element();

      // Three children, the middle one growing — otherwise the two ends would
      // collect in the centre of the bar.
      expect(element.children).toHaveLength(3);
      expect(element.children[1]).toHaveClass('flex-1');
    });

    it('reflects changed slots on re-render', async () => {
      const screen = await render(<Toolbar end={<Button>Save</Button>}>Title</Toolbar>);

      await screen.rerender(<Toolbar end={<Button>Publish</Button>}>Title</Toolbar>);

      await expect.element(screen.getByRole('button', { name: 'Publish' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Save' }).query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <Toolbar className="my-own-class" data-testid="bar">
          Title
        </Toolbar>
      );

      expect(screen.getByTestId('bar').element()).toHaveClass('my-own-class');
    });

    it('does not claim a toolbar role it does not implement', async () => {
      const screen = await render(<Toolbar data-testid="bar">Title</Toolbar>);

      expect(screen.getByTestId('bar').element()).not.toHaveAttribute('role');
    });
  });

  describe('position', () => {
    it('sits in the flow by default, with the corners of a sheet', async () => {
      const screen = await render(
        <Toolbar size="md" data-testid="bar">
          Title
        </Toolbar>
      );
      const element = screen.getByTestId('bar').element();

      expect(element).toHaveClass('rounded-(--neba-radius-md)');
      expect(element).not.toHaveClass('sticky');
    });

    it('drops its radius once it spans an edge of the window', async () => {
      const screen = await render(
        <Toolbar position="sticky" data-testid="bar">
          Title
        </Toolbar>
      );
      const element = screen.getByTestId('bar').element();

      expect(element).toHaveClass('sticky');
      expect(element).toHaveClass('top-0');
      expect(element).not.toHaveClass('rounded-(--neba-radius-md)');
    });

    it('moves to the other edge when told to', async () => {
      const screen = await render(
        <Toolbar position="fixed" side="bottom" data-testid="bar">
          Title
        </Toolbar>
      );
      const element = screen.getByTestId('bar').element();

      expect(element).toHaveClass('fixed');
      expect(element).toHaveClass('bottom-0');
    });

    it('turns its rule to face the content', async () => {
      const screen = await render(
        <Toolbar divider data-testid="bar">
          Title
        </Toolbar>
      );
      const element = screen.getByTestId('bar').element();

      expect(element).toHaveClass('border-b');

      await screen.rerender(
        <Toolbar divider side="bottom" data-testid="bar">
          Title
        </Toolbar>
      );

      expect(element).toHaveClass('border-t');
      expect(element).not.toHaveClass('border-b');
    });
  });

  describe('style props', () => {
    it('changes only its padding with density', async () => {
      const screen = await render(
        <Toolbar size="md" data-testid="bar">
          Title
        </Toolbar>
      );
      const element = screen.getByTestId('bar').element();

      expect(element).toHaveClass('py-4');
      expect(element).toHaveClass('px-4');

      await screen.rerender(
        <Toolbar size="md" density="compact" data-testid="bar">
          Title
        </Toolbar>
      );

      expect(element).toHaveClass('py-2.5');
      expect(element).toHaveClass('px-2.5');
    });

    it('keeps its sheet undyed, exactly as a Box does', async () => {
      const screen = await render(
        <Toolbar color="warning" data-testid="bar">
          Title
        </Toolbar>
      );
      const element = screen.getByTestId('bar').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-line')).toBe('var(--neba-warning-line)');
      expect(element.style.getPropertyValue('--n-panel')).toBe('var(--neba-panel)');
    });

    it('is flat by default and maps elevation onto the shadow scale', async () => {
      const screen = await render(<Toolbar data-testid="bar">Title</Toolbar>);
      const element = screen.getByTestId('bar').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-0)');

      await screen.rerender(
        <Toolbar elevation={2} data-testid="bar">
          Title
        </Toolbar>
      );

      expect(element.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-2)');
    });
  });
});
