import { describe, expect, it, vi } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { AnimateSplit } from 'neba';

/** The visible copy's pieces — the clipped copy is for a screen reader. */
function pieces(container: HTMLElement): HTMLElement[] {
  return [...container.querySelectorAll<HTMLElement>('[aria-hidden="true"] .neba-anim')];
}

describe('AnimateSplit', () => {
  describe('splitting', () => {
    it('cuts the line into words by default', async () => {
      const screen = await render(<AnimateSplit>One two three</AnimateSplit>);

      expect(pieces(screen.container).map((piece) => piece.textContent)).toEqual([
        'One ',
        'two ',
        'three'
      ]);
    });

    // A piece keeps the space that followed it, so a line still breaks between
    // words and never inside the gap.
    it('leaves each word the space after it', async () => {
      const screen = await render(<AnimateSplit>One two</AnimateSplit>);

      expect(pieces(screen.container)[0].textContent).toBe('One ');
    });

    it('cuts it into characters when asked', async () => {
      const screen = await render(<AnimateSplit by="character">abc</AnimateSplit>);

      expect(pieces(screen.container).map((piece) => piece.textContent)).toEqual(['a', 'b', 'c']);
    });

    // A character piece is an inline block, and a line may break between any
    // two of them, so a word cut into characters broke in its middle.
    it('keeps the characters of a word together on one line', async () => {
      const screen = await render(<AnimateSplit by="character">ab cd</AnimateSplit>);
      const copy = screen.container.querySelector('[aria-hidden="true"]') as HTMLElement;
      const words = [...copy.children] as HTMLElement[];

      expect(words.map((word) => word.textContent)).toEqual(['ab', 'cd']);
      expect(words.every((word) => word.classList.contains('whitespace-nowrap'))).toBe(true);
      // The space between them is text, which is where the line breaks.
      expect(copy.textContent).toBe('ab cd');
      expect(pieces(screen.container).map((piece) => piece.textContent)).toEqual([
        'a',
        'b',
        'c',
        'd'
      ]);
    });

    it('takes the text as a prop over the children', async () => {
      const screen = await render(<AnimateSplit text="from the prop">ignored</AnimateSplit>);

      expect(
        pieces(screen.container)
          .map((piece) => piece.textContent)
          .join('')
      ).toBe('from the prop');
    });
  });

  describe('the effect', () => {
    it('runs a hover handler of the caller beside its own', async () => {
      const onPointerEnter = vi.fn();
      const screen = await render(
        <AnimateSplit trigger="hover" onPointerEnter={onPointerEnter} data-testid="split">
          One two three
        </AnimateSplit>
      );

      await userEvent.hover(screen.getByTestId('split'));

      expect(onPointerEnter).toHaveBeenCalledOnce();
      await expect.element(screen.getByTestId('split')).toHaveAttribute('data-state', 'running');
    });

    it('holds each piece back by its place in the line', async () => {
      const screen = await render(
        <AnimateSplit stagger={50} delay={10}>
          One two three
        </AnimateSplit>
      );

      expect(
        pieces(screen.container).map((piece) => piece.style.getPropertyValue('--n-anim-delay'))
      ).toEqual(['10ms', '60ms', '110ms']);
    });

    it('slides each piece by default and takes any other effect', async () => {
      const sliding = await render(<AnimateSplit>One two</AnimateSplit>);

      expect(pieces(sliding.container)[0]).toHaveClass('neba-anim-slide');

      const fading = await render(<AnimateSplit effect="fade">One two</AnimateSplit>);

      expect(pieces(fading.container)[0]).toHaveClass('neba-anim-fade');
    });

    // A blink that ran once was a flicker, where the same effect named anywhere
    // else blinks until it is told to stop.
    it('blinks without end unless it is given a repeat', async () => {
      const screen = await render(<AnimateSplit effect="blink">One two</AnimateSplit>);

      expect(pieces(screen.container)[0].style.getPropertyValue('--n-anim-repeat')).toBe(
        'infinite'
      );
    });

    it('runs the line the other way when reversed', async () => {
      const screen = await render(
        <AnimateSplit stagger={50} reverse>
          One two
        </AnimateSplit>
      );

      expect(
        pieces(screen.container).map((piece) => piece.style.getPropertyValue('--n-anim-delay'))
      ).toEqual(['50ms', '0ms']);
    });

    // What it animates is its pieces, so a replay has to reach them.
    it('rewinds its pieces when it is played again', async () => {
      const screen = await render(<AnimateSplit trigger="manual">One two</AnimateSplit>);
      const piece = pieces(screen.container)[0];
      const records: MutationRecord[] = [];
      const observer = new MutationObserver((list) => records.push(...list));

      observer.observe(piece, {
        attributes: true,
        attributeFilter: ['style'],
        attributeOldValue: true
      });

      await screen.rerender(
        <AnimateSplit trigger="manual" play>
          One two
        </AnimateSplit>
      );

      records.push(...observer.takeRecords());
      observer.disconnect();

      expect(records.some((record) => record.oldValue?.includes('animation-name: none'))).toBe(
        true
      );
    });

    // A scroll-driven animation has no clock to wait against, and one held for
    // a trigger showed nothing at all.
    it('never waits for a trigger when the scroll drives it', async () => {
      const screen = await render(
        <AnimateSplit timeline="view" trigger="manual" data-testid="split">
          One two
        </AnimateSplit>
      );
      const root = screen.getByTestId('split').element() as HTMLElement;

      expect(root).toHaveAttribute('data-state', 'running');
      expect(root.style.getPropertyValue('--n-anim-state')).toBe('running');
    });

    // An inline box cannot be translated up.
    it('makes every piece an inline block', async () => {
      const screen = await render(<AnimateSplit>One two</AnimateSplit>);

      expect(
        pieces(screen.container).every((piece) => piece.classList.contains('inline-block'))
      ).toBe(true);
    });
  });

  describe('what a reader is told', () => {
    /*
     * The whole string is in the document once, for a screen reader, and the
     * pieces are hidden from it — otherwise the sentence is read as a list of
     * forty-six separate letters, and a find-in-page matches nothing.
     */
    it('keeps the whole line for a screen reader and hides the pieces', async () => {
      const screen = await render(
        <AnimateSplit by="character" data-testid="s">
          Hello
        </AnimateSplit>
      );
      const root = screen.getByTestId('s').element();

      expect(root.children[0].textContent).toBe('Hello');
      expect(root.children[0]).not.toHaveAttribute('aria-hidden');
      expect(root.children[1]).toHaveAttribute('aria-hidden', 'true');
    });
  });
});
