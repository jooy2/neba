import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { AnimateTyping } from 'neba';

/** What is actually drawn — the clipped copy for a screen reader is separate. */
function typed(root: Element): string {
  return root.querySelector('[aria-hidden="true"]')?.textContent ?? '';
}

describe('AnimateTyping', () => {
  describe('rendering', () => {
    it('runs a hover handler of the caller beside its own', async () => {
      const onPointerEnter = vi.fn();
      const screen = await render(
        <AnimateTyping trigger="hover" onPointerEnter={onPointerEnter} data-testid="typing">
          Hello there
        </AnimateTyping>
      );

      await userEvent.hover(screen.getByTestId('typing'));

      expect(onPointerEnter).toHaveBeenCalledOnce();
      await expect.element(screen.getByTestId('typing')).toHaveAttribute('data-state', 'running');
    });

    it('says which effect it is running', async () => {
      const screen = await render(<AnimateTyping data-testid="typing">Hello there</AnimateTyping>);

      expect(screen.getByTestId('typing').element()).toHaveAttribute(
        'data-neba-animation',
        'typing'
      );
    });

    // The whole string is in the document from the first frame, so a reader who
    // cannot see the effect is not made to sit through it.
    it('holds the whole text for a screen reader straight away', async () => {
      const screen = await render(
        <AnimateTyping speed={1} data-testid="typing">
          Hello there
        </AnimateTyping>
      );

      await expect.element(screen.getByText('Hello there')).toBeInTheDocument();
    });

    it('takes the text as a prop as readily as a child', async () => {
      const screen = await render(<AnimateTyping text="From a prop" speed={1} />);

      await expect.element(screen.getByText('From a prop')).toBeInTheDocument();
    });

    it('draws a caret unless told not to', async () => {
      const screen = await render(<AnimateTyping data-testid="typing">Hello</AnimateTyping>);

      expect(
        screen.getByTestId('typing').element().querySelector('.neba-typing-caret')
      ).not.toBeNull();

      await screen.rerender(
        <AnimateTyping caret={false} data-testid="typing">
          Hello
        </AnimateTyping>
      );

      expect(screen.getByTestId('typing').element().querySelector('.neba-typing-caret')).toBeNull();
    });

    it('draws the caret it was given', async () => {
      const screen = await render(
        <AnimateTyping caretChar="▌" data-testid="typing">
          Hello
        </AnimateTyping>
      );

      expect(
        screen.getByTestId('typing').element().querySelector('.neba-typing-caret')?.textContent
      ).toBe('▌');
    });
  });

  /*
   * On the fake clock, one step at a time. The typing is a chain of timeouts,
   * and on a real clock every assertion here was a race against it: seven
   * characters at five milliseconds each should be over in a few dozen
   * milliseconds, and a slow CI runner once held a single timeout for longer
   * than the poll waits in total, so the text stopped at two characters and the
   * test failed with nothing wrong in the component. Stepping the clock also
   * lets a test look at every frame rather than only at the last one.
   *
   * The clock is faked before `render`, so the first timeout the effect sets is
   * already on it. React commits on a message-channel task, not a timeout, so
   * the DOM still has to be waited for after each step.
   */
  describe('typing', () => {
    beforeEach(() => {
      vi.useFakeTimers();
    });

    afterEach(() => {
      vi.useRealTimers();
    });

    it('gets to the end of the text', async () => {
      const screen = await render(
        <AnimateTyping speed={200} caret={false} data-testid="typing">
          Hello
        </AnimateTyping>
      );

      await vi.runAllTimersAsync();

      await expect.poll(() => typed(screen.getByTestId('typing').element())).toBe('Hello');
    });

    it('shows nothing at all before it is triggered', async () => {
      const screen = await render(
        <AnimateTyping trigger="manual" caret={false} data-testid="typing">
          Hello
        </AnimateTyping>
      );

      await vi.runAllTimersAsync();
      expect(typed(screen.getByTestId('typing').element())).toBe('');

      await screen.rerender(
        <AnimateTyping trigger="manual" play speed={200} caret={false} data-testid="typing">
          Hello
        </AnimateTyping>
      );
      await vi.runAllTimersAsync();

      await expect.poll(() => typed(screen.getByTestId('typing').element())).toBe('Hello');
    });

    /*
     * A code point is not a character: a family emoji is five of them, and a
     * typewriter that advanced by code points would spend four frames drawing
     * fragments that mean nothing on their own. So every frame is asserted, not
     * just the finished line — the finished line is the same either way.
     *
     * A minute a character, through `duration`, because `expect.poll` moves a
     * fake clock on by its own interval each time it retries. With a step that
     * long, no amount of retrying reaches the next character, and the only thing
     * that does is the step the test takes.
     */
    it('advances by graphemes rather than by code points', async () => {
      const line = '한글 👩‍👩‍👧 ok';
      const frames = ['한', '한글', '한글 ', '한글 👩‍👩‍👧', '한글 👩‍👩‍👧 ', '한글 👩‍👩‍👧 o', line];
      const step = 60_000;
      const screen = await render(
        <AnimateTyping duration={step * frames.length} caret={false} data-testid="typing">
          {line}
        </AnimateTyping>
      );
      const root = screen.getByTestId('typing').element();

      for (const [index, frame] of frames.entries()) {
        // The first character is typed once the delay, which is zero, has run.
        await vi.advanceTimersByTimeAsync(index === 0 ? 0 : step);
        await expect.poll(() => typed(root)).toBe(frame);
      }
    });

    // Typing renders once per character, and a callback ref written inline is
    // detached and attached again on every one of those renders.
    it('attaches a callback ref once rather than on every character', async () => {
      const ref = vi.fn();
      const screen = await render(
        <AnimateTyping ref={ref} speed={200} caret={false} data-testid="typing">
          Hello
        </AnimateTyping>
      );

      await vi.runAllTimersAsync();
      await expect.poll(() => typed(screen.getByTestId('typing').element())).toBe('Hello');

      expect(ref.mock.calls.filter(([node]) => node === null)).toHaveLength(0);
    });

    it('takes only the text out of an element among the children', async () => {
      const screen = await render(
        <AnimateTyping speed={200} caret={false} data-testid="typing">
          {['Half ', 'and half']}
        </AnimateTyping>
      );

      await vi.runAllTimersAsync();

      await expect.poll(() => typed(screen.getByTestId('typing').element())).toBe('Half and half');
    });
  });
});
