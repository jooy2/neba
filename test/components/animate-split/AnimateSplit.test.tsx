import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateSplit } from 'neba';

/** The visible copy — the clipped one is for a screen reader. */
function pieces(container: HTMLElement): HTMLElement[] {
  return [...container.querySelectorAll<HTMLElement>('[aria-hidden="true"] > span')];
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
