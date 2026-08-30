import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { ScrollArea } from 'neba';

/** Nothing loads Tailwind into the test run, so the bounds are set inline. */
function Tall() {
  return <div style={{ height: 400 }}>A hundred rows of something.</div>;
}

function Wide() {
  return <div style={{ width: 1200, height: 20 }}>A very long line.</div>;
}

describe('ScrollArea', () => {
  describe('rendering', () => {
    it('renders its children', async () => {
      const screen = await render(
        <ScrollArea height={80}>
          <Tall />
        </ScrollArea>
      );

      await expect.element(screen.getByText('A hundred rows of something.')).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <ScrollArea height={80} className="my-own-class" data-testid="area">
          <Tall />
        </ScrollArea>
      );

      expect(screen.getByTestId('area').element()).toHaveClass('my-own-class');
    });

    it('takes a height and a ceiling as inline lengths', async () => {
      const screen = await render(
        <ScrollArea height={80} maxHeight="12rem" data-testid="area">
          <Tall />
        </ScrollArea>
      );
      const element = screen.getByTestId('area').element() as HTMLElement;

      expect(element.style.height).toBe('80px');
      expect(element.style.maxHeight).toBe('12rem');
    });

    it('reflects changed children on re-render', async () => {
      const screen = await render(<ScrollArea height={80}>Before</ScrollArea>);

      await screen.rerender(<ScrollArea height={80}>After</ScrollArea>);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
    });
  });

  describe('orientation', () => {
    it('draws a vertical scrollbar when the content is taller', async () => {
      const screen = await render(
        <ScrollArea height={80} data-testid="area">
          <Tall />
        </ScrollArea>
      );
      const root = screen.getByTestId('area').element();

      await expect.element(screen.getByTestId('area')).toHaveAttribute('data-has-overflow-y');
      expect(root.querySelector('[data-orientation="vertical"]')).not.toBeNull();
      expect(root.querySelector('[data-orientation="horizontal"]')).toBeNull();
    });

    it('draws a horizontal one instead when asked for', async () => {
      const screen = await render(
        <ScrollArea orientation="horizontal" data-testid="area" style={{ width: 120 }}>
          <Wide />
        </ScrollArea>
      );
      const root = screen.getByTestId('area').element();

      await expect.element(screen.getByTestId('area')).toHaveAttribute('data-has-overflow-x');
      expect(root.querySelector('[data-orientation="horizontal"]')).not.toBeNull();
      expect(root.querySelector('[data-orientation="vertical"]')).toBeNull();
    });

    it('draws both when told both', async () => {
      const screen = await render(
        <ScrollArea orientation="both" height={80} data-testid="area" style={{ width: 120 }}>
          <div style={{ width: 1200, height: 400 }}>Both ways.</div>
        </ScrollArea>
      );
      const root = screen.getByTestId('area').element();

      expect(root.querySelector('[data-orientation="vertical"]')).not.toBeNull();
      expect(root.querySelector('[data-orientation="horizontal"]')).not.toBeNull();
    });
  });

  describe('appearance', () => {
    it('maps color onto the thumb slots', async () => {
      const screen = await render(
        <ScrollArea height={80} color="success" data-testid="area">
          <Tall />
        </ScrollArea>
      );
      const element = screen.getByTestId('area').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-thumb')).toContain('--neba-success-accent');
    });

    it('sizes the rail off the size ladder', async () => {
      const screen = await render(
        <ScrollArea height={80} size="xl" data-testid="area">
          <Tall />
        </ScrollArea>
      );
      const element = screen.getByTestId('area').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-rail')).toBe('0.625rem');
    });

    it('does not fade the edges unless asked', async () => {
      const screen = await render(
        <ScrollArea height={80} data-testid="area">
          <Tall />
        </ScrollArea>
      );
      const root = screen.getByTestId('area').element();

      expect(root.querySelector('.neba-scroll-fade')).toBeNull();
    });

    it('hangs the fade off the viewport when it is', async () => {
      const screen = await render(
        <ScrollArea height={80} fade data-testid="area">
          <Tall />
        </ScrollArea>
      );
      const root = screen.getByTestId('area').element();

      expect(root.querySelector('.neba-scroll-fade')).not.toBeNull();
    });
  });
});
