import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateFade } from 'neba';

describe('AnimateFade', () => {
  describe('rendering', () => {
    it('renders what it was given', async () => {
      const screen = await render(<AnimateFade>Arriving</AnimateFade>);

      await expect.element(screen.getByText('Arriving')).toBeInTheDocument();
    });

    it('says which effect it is running', async () => {
      const screen = await render(<AnimateFade data-testid="fade">Arriving</AnimateFade>);

      expect(screen.getByTestId('fade').element()).toHaveAttribute('data-neba-animation', 'fade');
    });

    it('renders something other than a div when told', async () => {
      const screen = await render(
        <AnimateFade render={<section />} data-testid="fade">
          Arriving
        </AnimateFade>
      );

      expect(screen.getByTestId('fade').element().tagName).toBe('SECTION');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <AnimateFade className="my-own-class" data-testid="fade">
          Arriving
        </AnimateFade>
      );

      expect(screen.getByTestId('fade').element()).toHaveClass('my-own-class');
      expect(screen.getByTestId('fade').element()).toHaveClass('neba-anim');
    });
  });

  /*
   * `stagger` moves the effect off the box and onto the things inside it, one
   * after another. It is the same helper `AnimateAppear` runs on — which is why
   * it is asserted once, here, rather than six times over.
   */
  describe('a step per child', () => {
    it('animates the box itself while there is no step', async () => {
      const screen = await render(
        <AnimateFade data-testid="fade">
          <span>one</span>
          <span>two</span>
        </AnimateFade>
      );
      const root = screen.getByTestId('fade').element();

      expect(root).toHaveClass('neba-anim');
      expect(root.children[0]).not.toHaveClass('neba-anim');
    });

    it('hands each child the effect, held back by its place in the list', async () => {
      const screen = await render(
        <AnimateFade delay={100} stagger={60} data-testid="fade">
          <span>one</span>
          <span>two</span>
          <span>three</span>
        </AnimateFade>
      );
      const root = screen.getByTestId('fade').element();
      const delays = [...root.children].map((child) =>
        (child as HTMLElement).style.getPropertyValue('--n-anim-delay')
      );

      // Nothing on the root: a box fading in over three children fading in is
      // the same content faded twice.
      expect(root).not.toHaveClass('neba-anim');
      expect([...root.children].every((child) => child.classList.contains('neba-anim'))).toBe(true);
      expect(delays).toEqual(['100ms', '160ms', '220ms']);
    });

    it('lengthens each child by durationStep, and never past zero', async () => {
      const screen = await render(
        <AnimateFade duration={300} durationStep={-200} data-testid="fade">
          <span>one</span>
          <span>two</span>
          <span>three</span>
        </AnimateFade>
      );
      const durations = [...screen.getByTestId('fade').element().children].map((child) =>
        (child as HTMLElement).style.getPropertyValue('--n-anim-duration')
      );

      expect(durations).toEqual(['300ms', '100ms', '0ms']);
    });

    it('runs the list the other way when reversed', async () => {
      const screen = await render(
        <AnimateFade stagger={50} reverse data-testid="fade">
          <span>one</span>
          <span>two</span>
        </AnimateFade>
      );
      const delays = [...screen.getByTestId('fade').element().children].map((child) =>
        (child as HTMLElement).style.getPropertyValue('--n-anim-delay')
      );

      expect(delays).toEqual(['50ms', '0ms']);
    });

    it('leaves a child its own class and style', async () => {
      const screen = await render(
        <AnimateFade stagger={40} data-testid="fade">
          <span className="mine" style={{ color: 'red' }}>
            one
          </span>
        </AnimateFade>
      );
      const child = screen.getByTestId('fade').element().children[0] as HTMLElement;

      expect(child).toHaveClass('mine');
      expect(child).toHaveClass('neba-anim');
      expect(child.style.color).toBe('red');
    });

    // A bare string has no element to write onto, so it gets one.
    it('wraps a bare string in a span', async () => {
      const screen = await render(
        <AnimateFade stagger={40} data-testid="fade">
          {'plain'}
        </AnimateFade>
      );
      const child = screen.getByTestId('fade').element().children[0];

      expect(child.tagName).toBe('SPAN');
      expect(child).toHaveClass('neba-anim');
    });
  });

  /*
   * `timeline="view"` swaps the clock for the scrollbar. Asserted here rather
   * than on all nine, because it is two slots filled by one shared table.
   */
  describe('driven by the scroll instead of the clock', () => {
    it('fills no timeline slot while it runs on time', async () => {
      const screen = await render(<AnimateFade data-testid="fade">A</AnimateFade>);
      const element = screen.getByTestId('fade').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-timeline')).toBe('');
    });

    it('points the effect at the view timeline when asked', async () => {
      const screen = await render(
        <AnimateFade timeline="view" data-testid="fade">
          A
        </AnimateFade>
      );
      const element = screen.getByTestId('fade').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-timeline')).toBe('view()');
      expect(element.style.getPropertyValue('--n-anim-range')).toBe('entry 0% cover 45%');
    });

    it('takes a range of its own', async () => {
      const screen = await render(
        <AnimateFade timeline="view" range="cover 20% cover 80%" data-testid="fade">
          A
        </AnimateFade>
      );

      expect(
        (screen.getByTestId('fade').element() as HTMLElement).style.getPropertyValue(
          '--n-anim-range'
        )
      ).toBe('cover 20% cover 80%');
    });

    // A scroll-driven animation has no clock to be paused against, and a paused
    // one shows nothing at all: the scroll position is the trigger.
    it('never waits for a trigger', async () => {
      const screen = await render(
        <AnimateFade timeline="view" trigger="manual" data-testid="fade">
          A
        </AnimateFade>
      );

      expect(screen.getByTestId('fade').element()).toHaveAttribute('data-state', 'running');
    });
  });

  describe('settings', () => {
    it('writes the timings into the slots the stylesheet reads', async () => {
      const screen = await render(
        <AnimateFade duration={800} delay={120} repeat={3} data-testid="fade">
          Arriving
        </AnimateFade>
      );
      const element = screen.getByTestId('fade').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-duration')).toBe('800ms');
      expect(element.style.getPropertyValue('--n-anim-delay')).toBe('120ms');
      expect(element.style.getPropertyValue('--n-anim-repeat')).toBe('3');
    });

    it('writes an endless repeat as the word CSS uses', async () => {
      const screen = await render(
        <AnimateFade repeat="infinite" data-testid="fade">
          Arriving
        </AnimateFade>
      );
      const element = screen.getByTestId('fade').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-repeat')).toBe('infinite');
    });

    it('starts from the opacity it was given', async () => {
      const screen = await render(
        <AnimateFade from={0.3} data-testid="fade">
          Arriving
        </AnimateFade>
      );
      const element = screen.getByTestId('fade').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-opacity')).toBe('0.3');
    });

    it('runs the same animation backwards for mode="out"', async () => {
      const screen = await render(
        <AnimateFade mode="out" data-testid="fade">
          Leaving
        </AnimateFade>
      );
      const element = screen.getByTestId('fade').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-direction')).toBe('reverse');
    });

    it('combines alternate with the direction rather than replacing it', async () => {
      const screen = await render(
        <AnimateFade mode="out" alternate data-testid="fade">
          Leaving
        </AnimateFade>
      );
      const element = screen.getByTestId('fade').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-direction')).toBe('alternate-reverse');
    });
  });

  describe('triggers', () => {
    it('runs on mount by default', async () => {
      const screen = await render(<AnimateFade data-testid="fade">Arriving</AnimateFade>);

      expect(screen.getByTestId('fade').element()).toHaveAttribute('data-state', 'running');
    });

    it('waits to be told when the trigger is manual', async () => {
      const screen = await render(
        <AnimateFade trigger="manual" data-testid="fade">
          Arriving
        </AnimateFade>
      );

      await expect.element(screen.getByTestId('fade')).toHaveAttribute('data-state', 'paused');

      await screen.rerender(
        <AnimateFade trigger="manual" play data-testid="fade">
          Arriving
        </AnimateFade>
      );

      await expect.element(screen.getByTestId('fade')).toHaveAttribute('data-state', 'running');
    });

    it('holds where it is when paused', async () => {
      const screen = await render(
        <AnimateFade paused data-testid="fade">
          Arriving
        </AnimateFade>
      );
      const element = screen.getByTestId('fade').element() as HTMLElement;

      expect(element).toHaveAttribute('data-state', 'paused');
      expect(element.style.getPropertyValue('--n-anim-state')).toBe('paused');
    });
  });
});
