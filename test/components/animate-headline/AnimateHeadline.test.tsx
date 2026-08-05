import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateHeadline } from 'neba';

const LINES = [
  <span key="a">Faster</span>,
  <span key="b">Simpler</span>,
  <span key="c">Quieter</span>
];

describe('AnimateHeadline', () => {
  describe('rendering', () => {
    it('says which effect it is running', async () => {
      const screen = await render(
        <AnimateHeadline data-testid="headline">{LINES}</AnimateHeadline>
      );

      expect(screen.getByTestId('headline').element()).toHaveAttribute(
        'data-neba-animation',
        'headline'
      );
    });

    // Every line keeps its space, so the box is as tall as the longest of them
    // from the first frame and never resizes as the reel turns.
    it('keeps every line in the document', async () => {
      const screen = await render(
        <AnimateHeadline data-testid="headline">{LINES}</AnimateHeadline>
      );
      const items = screen
        .getByTestId('headline')
        .element()
        .querySelectorAll('.neba-headline-item');

      expect(items).toHaveLength(3);
    });

    it('marks only one line as showing', async () => {
      const screen = await render(
        <AnimateHeadline data-testid="headline">{LINES}</AnimateHeadline>
      );
      const root = screen.getByTestId('headline').element();

      expect(root.querySelectorAll('[data-state="active"]')).toHaveLength(1);
      expect(root.children[0]).toHaveAttribute('data-state', 'active');
    });

    it('keeps a line’s own class names', async () => {
      const screen = await render(
        <AnimateHeadline data-testid="headline">
          <span className="my-own-class">Faster</span>
        </AnimateHeadline>
      );
      const root = screen.getByTestId('headline').element();

      expect(root.children[0]).toHaveClass('my-own-class');
      expect(root.children[0]).toHaveClass('neba-headline-item');
    });
  });

  describe('turning', () => {
    it('starts on the line it was given', async () => {
      const screen = await render(
        <AnimateHeadline defaultIndex={1} data-testid="headline">
          {LINES}
        </AnimateHeadline>
      );
      const root = screen.getByTestId('headline').element();

      expect(root.children[1]).toHaveAttribute('data-state', 'active');
    });

    it('moves on after the interval', async () => {
      const onIndexChange = vi.fn();
      const screen = await render(
        <AnimateHeadline
          interval={60}
          duration={20}
          onIndexChange={onIndexChange}
          data-testid="headline"
        >
          {LINES}
        </AnimateHeadline>
      );

      await expect
        .poll(() => screen.getByTestId('headline').element().children[1].getAttribute('data-state'))
        .toBe('active');

      expect(onIndexChange).toHaveBeenCalledWith(1);
    });

    it('comes back to the first line', async () => {
      const screen = await render(
        <AnimateHeadline interval={40} duration={10} data-testid="headline">
          {LINES}
        </AnimateHeadline>
      );

      await expect
        .poll(
          () => screen.getByTestId('headline').element().children[2].getAttribute('data-state'),
          { timeout: 3000 }
        )
        .toBe('active');

      await expect
        .poll(
          () => screen.getByTestId('headline').element().children[0].getAttribute('data-state'),
          { timeout: 3000 }
        )
        .toBe('active');
    });

    it('stops on the last line when loop is off', async () => {
      const onIndexChange = vi.fn();
      const screen = await render(
        <AnimateHeadline
          loop={false}
          defaultIndex={2}
          interval={30}
          duration={10}
          onIndexChange={onIndexChange}
          data-testid="headline"
        >
          {LINES}
        </AnimateHeadline>
      );

      await new Promise((resolve) => setTimeout(resolve, 150));

      expect(onIndexChange).not.toHaveBeenCalled();
      expect(screen.getByTestId('headline').element().children[2]).toHaveAttribute(
        'data-state',
        'active'
      );
    });

    // A controlled Headline is somebody else's timer; a second one running
    // underneath it would fight for the same state.
    it('does not turn itself when it is handed an index', async () => {
      const onIndexChange = vi.fn();
      const screen = await render(
        <AnimateHeadline
          index={0}
          interval={30}
          onIndexChange={onIndexChange}
          data-testid="headline"
        >
          {LINES}
        </AnimateHeadline>
      );

      await new Promise((resolve) => setTimeout(resolve, 150));

      expect(onIndexChange).not.toHaveBeenCalled();

      await screen.rerender(
        <AnimateHeadline
          index={2}
          interval={30}
          onIndexChange={onIndexChange}
          data-testid="headline"
        >
          {LINES}
        </AnimateHeadline>
      );

      expect(screen.getByTestId('headline').element().children[2]).toHaveAttribute(
        'data-state',
        'active'
      );
    });
  });
});
