import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateTyping } from 'neba';

/** What is actually drawn — the clipped copy for a screen reader is separate. */
function typed(root: Element): string {
  return root.querySelector('[aria-hidden="true"]')?.textContent ?? '';
}

describe('AnimateTyping', () => {
  describe('rendering', () => {
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

  describe('typing', () => {
    it('gets to the end of the text', async () => {
      const screen = await render(
        <AnimateTyping speed={200} caret={false} data-testid="typing">
          Hello
        </AnimateTyping>
      );

      await expect.poll(() => typed(screen.getByTestId('typing').element())).toBe('Hello');
    });

    it('shows nothing at all before it is triggered', async () => {
      const screen = await render(
        <AnimateTyping trigger="manual" caret={false} data-testid="typing">
          Hello
        </AnimateTyping>
      );

      expect(typed(screen.getByTestId('typing').element())).toBe('');

      await screen.rerender(
        <AnimateTyping trigger="manual" play speed={200} caret={false} data-testid="typing">
          Hello
        </AnimateTyping>
      );

      await expect.poll(() => typed(screen.getByTestId('typing').element())).toBe('Hello');
    });

    // A code point is not a character: a family emoji is seven of them, and a
    // typewriter that advanced by code points would spend four frames drawing
    // fragments that mean nothing on their own.
    it('advances by graphemes rather than by code points', async () => {
      const screen = await render(
        <AnimateTyping speed={200} caret={false} data-testid="typing">
          한글 👩‍👩‍👧 ok
        </AnimateTyping>
      );

      await expect.poll(() => typed(screen.getByTestId('typing').element())).toBe('한글 👩‍👩‍👧 ok');
    });

    it('takes only the text out of an element among the children', async () => {
      const screen = await render(
        <AnimateTyping speed={200} caret={false} data-testid="typing">
          {['Half ', 'and half']}
        </AnimateTyping>
      );

      await expect.poll(() => typed(screen.getByTestId('typing').element())).toBe('Half and half');
    });
  });
});
