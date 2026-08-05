import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateAppear } from 'neba';

describe('AnimateAppear', () => {
  describe('rendering', () => {
    it('renders every child', async () => {
      const screen = await render(
        <AnimateAppear>
          <p>First</p>
          <p>Second</p>
          <p>Third</p>
        </AnimateAppear>
      );

      await expect.element(screen.getByText('First')).toBeInTheDocument();
      await expect.element(screen.getByText('Third')).toBeInTheDocument();
    });

    it('says which effect it is running', async () => {
      const screen = await render(
        <AnimateAppear data-testid="appear">
          <p>First</p>
        </AnimateAppear>
      );

      expect(screen.getByTestId('appear').element()).toHaveAttribute(
        'data-neba-animation',
        'appear'
      );
    });

    // The animation is written onto the children rather than onto wrappers, so
    // a list stays the shape it was — this is the whole reason `cloneElement`
    // is used instead of a `<span>` around each one.
    it('animates the children themselves rather than wrapping them', async () => {
      const screen = await render(
        <AnimateAppear data-testid="appear">
          <p>First</p>
          <p>Second</p>
        </AnimateAppear>
      );
      const root = screen.getByTestId('appear').element();

      expect(root.children).toHaveLength(2);
      expect(root.children[0].tagName).toBe('P');
      expect(root.children[0]).toHaveClass('neba-anim');
    });

    it('keeps a child’s own class names', async () => {
      const screen = await render(
        <AnimateAppear data-testid="appear">
          <p className="my-own-class">First</p>
        </AnimateAppear>
      );
      const root = screen.getByTestId('appear').element();

      expect(root.children[0]).toHaveClass('my-own-class');
      expect(root.children[0]).toHaveClass('neba-anim');
    });

    it('wraps a bare string, which has no element to write onto', async () => {
      const screen = await render(<AnimateAppear data-testid="appear">Loose text</AnimateAppear>);
      const root = screen.getByTestId('appear').element();

      expect(root.children[0].tagName).toBe('SPAN');
      expect(root.children[0]).toHaveClass('neba-anim');
    });
  });

  describe('the stagger', () => {
    it('holds each child back by its own position', async () => {
      const screen = await render(
        <AnimateAppear stagger={100} data-testid="appear">
          <p>First</p>
          <p>Second</p>
          <p>Third</p>
        </AnimateAppear>
      );
      const root = screen.getByTestId('appear').element();
      const delayOf = (index: number) =>
        (root.children[index] as HTMLElement).style.getPropertyValue('--n-anim-delay');

      expect(delayOf(0)).toBe('0ms');
      expect(delayOf(1)).toBe('100ms');
      expect(delayOf(2)).toBe('200ms');
    });

    it('counts from the delay it was given', async () => {
      const screen = await render(
        <AnimateAppear delay={500} stagger={100} data-testid="appear">
          <p>First</p>
          <p>Second</p>
        </AnimateAppear>
      );
      const root = screen.getByTestId('appear').element();

      expect((root.children[0] as HTMLElement).style.getPropertyValue('--n-anim-delay')).toBe(
        '500ms'
      );
      expect((root.children[1] as HTMLElement).style.getPropertyValue('--n-anim-delay')).toBe(
        '600ms'
      );
    });

    it('runs the list backwards when told to', async () => {
      const screen = await render(
        <AnimateAppear reverse stagger={100} data-testid="appear">
          <p>First</p>
          <p>Second</p>
        </AnimateAppear>
      );
      const root = screen.getByTestId('appear').element();

      expect((root.children[0] as HTMLElement).style.getPropertyValue('--n-anim-delay')).toBe(
        '100ms'
      );
      expect((root.children[1] as HTMLElement).style.getPropertyValue('--n-anim-delay')).toBe(
        '0ms'
      );
    });

    // Short on purpose: this is a settling rather than an entrance from off
    // screen, which is what separates it from AnimateSlide.
    it('drifts only a little way', async () => {
      const screen = await render(
        <AnimateAppear data-testid="appear">
          <p>First</p>
        </AnimateAppear>
      );
      const root = screen.getByTestId('appear').element();

      expect((root.children[0] as HTMLElement).style.getPropertyValue('--n-anim-y')).toBe(
        '0.75rem'
      );
    });
  });

  describe('triggers', () => {
    it('passes its play state down to the children through the root', async () => {
      const screen = await render(
        <AnimateAppear trigger="manual" data-testid="appear">
          <p>First</p>
        </AnimateAppear>
      );
      const root = screen.getByTestId('appear').element() as HTMLElement;

      expect(root.style.getPropertyValue('--n-anim-state')).toBe('paused');

      await screen.rerender(
        <AnimateAppear trigger="manual" play data-testid="appear">
          <p>First</p>
        </AnimateAppear>
      );

      await expect.element(screen.getByTestId('appear')).toHaveAttribute('data-state', 'running');
    });
  });
});
