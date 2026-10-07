import { describe, expect, it, vi } from 'vitest';
import { userEvent } from 'vitest/browser';
import { renderToString } from 'react-dom/server';
import { hydrateRoot } from 'react-dom/client';
import { render } from 'vitest-browser-react';
import { AnimateSplit } from 'neba';

/** The visible copy's pieces — the clipped copy is for a screen reader. */
function pieces(container: HTMLElement): HTMLElement[] {
  return [...container.querySelectorAll<HTMLElement>('[aria-hidden="true"] .neba-anim')];
}

/** What each piece draws. It is drawn off an attribute, so it is not text. */
function drawn(container: HTMLElement): string[] {
  return pieces(container).map((piece) => piece.getAttribute('data-text') ?? '');
}

/** Lets a hydration commit, and the render that follows it, run. */
const settle = () => new Promise((resolve) => setTimeout(resolve, 60));

describe('AnimateSplit', () => {
  // A `<div>` by default, which is not allowed inside a paragraph.
  it('renders a span, so it can sit inside a sentence', async () => {
    const screen = await render(
      <p>
        <AnimateSplit data-testid="line">One two three</AnimateSplit>
      </p>
    );

    expect(screen.getByTestId('line').element().tagName).toBe('SPAN');
  });

  describe('splitting', () => {
    it('cuts the line into words by default', async () => {
      const screen = await render(<AnimateSplit>One two three</AnimateSplit>);

      expect(drawn(screen.container)).toEqual(['One ', 'two ', 'three']);
    });

    // A piece keeps the space that followed it, so a line still breaks between
    // words and never inside the gap.
    it('leaves each word the space after it', async () => {
      const screen = await render(<AnimateSplit>One two</AnimateSplit>);

      expect(drawn(screen.container)[0]).toBe('One ');
    });

    it('cuts it into characters when asked', async () => {
      const screen = await render(<AnimateSplit by="character">abc</AnimateSplit>);

      expect(drawn(screen.container)).toEqual(['a', 'b', 'c']);
    });

    // A character piece is an inline block, and a line may break between any
    // two of them, so a word cut into characters broke in its middle.
    it('keeps the characters of a word together on one line', async () => {
      const screen = await render(<AnimateSplit by="character">ab cd</AnimateSplit>);
      const copy = screen.container.querySelector('[aria-hidden="true"]') as HTMLElement;
      const [first, gap, second] = [...copy.children] as HTMLElement[];

      expect(copy.children).toHaveLength(3);
      expect(first).toHaveClass('whitespace-nowrap');
      expect(second).toHaveClass('whitespace-nowrap');
      expect(drawn(first)).toEqual(['a', 'b']);
      expect(drawn(second)).toEqual(['c', 'd']);
      // The space between them sits outside both, which is where the line
      // breaks, and is drawn like the pieces rather than written.
      expect(gap).not.toHaveClass('whitespace-nowrap');
      expect(gap).toHaveAttribute('data-text', ' ');
      expect(copy.textContent).toBe('');
    });

    it('takes the text as a prop over the children', async () => {
      const screen = await render(<AnimateSplit text="from the prop">ignored</AnimateSplit>);

      expect(drawn(screen.container).join('')).toBe('from the prop');
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
    // A first play finds the pieces still on their first frame, so only a
    // second one has anything to rewind.
    it('rewinds its pieces when it is played again', async () => {
      const screen = await render(
        <AnimateSplit trigger="manual" play={1}>
          One two
        </AnimateSplit>
      );
      const piece = pieces(screen.container)[0];
      const records: MutationRecord[] = [];
      const observer = new MutationObserver((list) => records.push(...list));

      observer.observe(piece, {
        attributes: true,
        attributeFilter: ['style'],
        attributeOldValue: true
      });

      await screen.rerender(
        <AnimateSplit trigger="manual" play={2}>
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

  /*
   * The pieces were text beside the clipped line, so the HTML a server sent
   * read "A line arriving a word at a time Alinearrivingawordatatime". They are
   * drawn now, and the line is in the element once, with its spaces.
   */
  describe('its text', () => {
    const line = 'A line arriving a word at a time';

    it.each(['word', 'character'] as const)(
      'is the line once in the HTML a server sends, split by %s',
      (by) => {
        const host = document.createElement('div');

        host.innerHTML = renderToString(<AnimateSplit by={by}>{line}</AnimateSplit>);
        document.body.append(host);

        try {
          expect(host.textContent).toBe(line);
          expect(host.innerText).toBe(line);
        } finally {
          host.remove();
        }
      }
    );

    it.each(['word', 'character'] as const)(
      'is the line once in the browser, split by %s',
      async (by) => {
        const screen = await render(
          <AnimateSplit by={by} data-testid="split">
            {line}
          </AnimateSplit>
        );

        expect(screen.getByTestId('split').element().textContent).toBe(line);
      }
    );
  });

  /*
   * `Intl.Segmenter` cuts a line differently on different engines, so a server
   * and a browser that disagreed rendered a different number of pieces, and
   * React threw the server's line away and drew it again.
   *
   * The stand-in below is two engines in one: while the "server" renders it
   * cuts as the real segmenter does, and afterwards it cuts every character
   * into a word of its own. It decides when it is used rather than when it is
   * built, because the library keeps one segmenter per locale, and one built
   * during the server render is the one the browser would be handed.
   */
  describe('hydration', () => {
    it('hydrates the pieces the server sent, whatever the segmenter says', async () => {
      const scope = Intl as unknown as { Segmenter: typeof Intl.Segmenter };
      const Segmenter = scope.Segmenter;
      let server = true;

      scope.Segmenter = class {
        real: Intl.Segmenter;

        constructor(locale?: string, options?: Intl.SegmenterOptions) {
          this.real = new Segmenter(locale, options);
        }

        segment(text: string) {
          if (server) {
            return this.real.segment(text);
          }

          return [...text].map((segment, index) => ({
            segment,
            index,
            input: text,
            isWordLike: segment.trim() !== ''
          }));
        }
      } as unknown as typeof Intl.Segmenter;

      // A locale nothing else asks for, so the stand-in is the only segmenter
      // ever built for it.
      const element = <AnimateSplit locale="tlh">One two three</AnimateSplit>;
      const host = document.createElement('div');

      try {
        host.innerHTML = renderToString(element);
      } finally {
        server = false;
      }

      document.body.append(host);

      const first = host.querySelector('.neba-anim');
      const recoverable: unknown[] = [];
      const root = hydrateRoot(host, element, {
        onRecoverableError: (error) => recoverable.push(error)
      });

      try {
        await settle();

        expect(recoverable).toEqual([]);
        // The first piece is the element the server sent, not one drawn again.
        expect(host.querySelector('.neba-anim')).toBe(first);
        // And once it has hydrated, the line is cut the browser's way.
        await expect
          .poll(() => drawn(host))
          .toEqual(['O', 'n', 'e ', 't', 'w', 'o ', 't', 'h', 'r', 'e', 'e']);
        expect(host.textContent).toBe('One two three');
      } finally {
        scope.Segmenter = Segmenter;
        root.unmount();
        host.remove();
      }
    });

    it('cuts a tree that was never server-rendered with the segmenter from the start', async () => {
      const screen = await render(<AnimateSplit locale="ja">東京都に住んでいます</AnimateSplit>);

      expect(drawn(screen.container).length).toBeLessThan('東京都に住んでいます'.length);
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
