import { describe, expect, it, vi } from 'vitest';
import { renderToString } from 'react-dom/server';
import { hydrateRoot } from 'react-dom/client';
import { render } from 'vitest-browser-react';
import { StreamingText } from 'neba';

/** Every element a word was given to fade in. */
const words = () => [...document.querySelectorAll('.neba-stream-word')];

/** `count` distinct words, so a word's element can be found by its text. */
const wordsUpTo = (count: number) =>
  Array.from({ length: count }, (_, index) => `w${index + 1}`).join(' ');

describe('StreamingText', () => {
  describe('rendering', () => {
    it('draws the text it has so far', async () => {
      const screen = await render(<StreamingText>A sheet of cut acrylic.</StreamingText>);

      await expect
        .element(screen.getByText('A sheet of cut acrylic.', { exact: false }))
        .toBeInTheDocument();
    });

    it('keeps the whole string, whitespace and all', async () => {
      const screen = await render(<StreamingText>{'One\ntwo  three'}</StreamingText>);

      expect(screen.getByText('One', { exact: false }).first().element().textContent).toBeTruthy();
      expect(document.body.textContent).toContain('One\ntwo  three');
    });

    it('renders something that is not a string untouched', async () => {
      const screen = await render(
        <StreamingText>
          <em>Already an element</em>
        </StreamingText>
      );

      await expect.element(screen.getByText('Already an element')).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<StreamingText className="my-own-class">Hello</StreamingText>);

      expect(document.querySelector('.my-own-class')).not.toBeNull();
    });

    it('renders something other than a div when it is asked to', async () => {
      await render(<StreamingText render={<p />}>Hello</StreamingText>);

      expect(document.querySelector('p')).not.toBeNull();
    });
  });

  describe('the words', () => {
    it('gives every word that streams in an element of its own to arrive in', async () => {
      await render(<StreamingText streaming>A sheet of cut acrylic</StreamingText>);

      expect(words()).toHaveLength(5);
    });

    // Words are keyed by position, so one already on screen keeps its element
    // as the text grows and never fades a second time.
    it('keeps the element a word already had when the text grows', async () => {
      const screen = await render(<StreamingText streaming>A sheet</StreamingText>);
      const first = document.querySelector('.neba-stream-word');

      await screen.rerender(<StreamingText streaming>A sheet of cut acrylic</StreamingText>);

      expect(document.querySelector('.neba-stream-word')).toBe(first);
      expect(words()).toHaveLength(5);
    });

    // Split on whitespace, a paragraph of Japanese or Thai was one token, so it
    // faded in once and every word after the first arrived without a fade.
    it('cuts a script written without spaces into words too', async () => {
      const text = '今日はとても良い天気です';
      await render(<StreamingText streaming>{text}</StreamingText>);

      // Chromium and WebKit segment it; a runtime with no Segmenter keeps it
      // whole, which is what every runtime did before.
      if ('Segmenter' in Intl) {
        expect(words().length).toBeGreaterThan(1);
      }
      expect(
        words()
          .map((word) => word.textContent)
          .join('')
      ).toBe(text);
    });

    it('leaves the text in one piece when the fade is off', async () => {
      await render(
        <StreamingText streaming fade={false}>
          A sheet of cut acrylic
        </StreamingText>
      );

      expect(words()).toHaveLength(0);
      expect(document.body.textContent).toContain('A sheet of cut acrylic');
    });
  });

  /**
   * A message loaded from history is not arriving, and fifty of them drawn a
   * word to an element were fifteen thousand elements and fifteen thousand
   * animations on the way in. Only what arrives while the block streams fades.
   */
  describe('text that is not streaming in', () => {
    it('draws the text it mounts with as plain text', async () => {
      await render(<StreamingText>A sheet of cut acrylic</StreamingText>);

      expect(words()).toHaveLength(0);
      expect(document.body.textContent).toContain('A sheet of cut acrylic');
    });

    it('draws text that arrives while nothing streams as plain text', async () => {
      const screen = await render(<StreamingText>A sheet</StreamingText>);

      await screen.rerender(<StreamingText>A sheet of cut acrylic</StreamingText>);

      expect(words()).toHaveLength(0);
      expect(document.body.textContent).toContain('A sheet of cut acrylic');
    });

    it('fades only what arrives once a stream starts', async () => {
      const screen = await render(<StreamingText>A sheet</StreamingText>);

      await screen.rerender(<StreamingText streaming>A sheet of cut acrylic</StreamingText>);

      expect(words().map((word) => word.textContent)).toEqual(['of', 'cut', 'acrylic']);
      expect(document.body.textContent).toContain('A sheet of cut acrylic');
    });

    // A stream very often switches on in the same render as its first words.
    it('fades the words that arrive with the stream starting', async () => {
      const screen = await render(<StreamingText>{''}</StreamingText>);

      await screen.rerender(<StreamingText streaming>A sheet</StreamingText>);

      expect(words().map((word) => word.textContent)).toEqual(['A', 'sheet']);
    });

    // A word cut in two by the stream keeps its first half plain and its second
    // half with it, rather than fading half a word in.
    it('does not fade the rest of a word the plain text had started', async () => {
      const screen = await render(<StreamingText>A she</StreamingText>);

      await screen.rerender(<StreamingText streaming>A she</StreamingText>);
      await screen.rerender(<StreamingText streaming>A sheet of</StreamingText>);

      expect(words().map((word) => word.textContent)).toEqual(['of']);
      expect(document.body.textContent).toContain('A sheet of');
    });

    // The last words of an answer often land in the same render that ends the
    // stream, and they fade like every word before them.
    it('fades the words that arrive as the stream ends', async () => {
      const screen = await render(<StreamingText streaming>A sheet</StreamingText>);

      await screen.rerender(<StreamingText>A sheet of cut acrylic</StreamingText>);

      expect(words()).toHaveLength(5);
    });

    // A long session kept an element per word for every answer it had ever
    // streamed in. Once the stream is over and the last word has faded, the
    // answer is plain text, as a message loaded from history is.
    it('draws a streamed answer as plain text once its last words have faded in', async () => {
      const screen = await render(
        <StreamingText streaming data-testid="answer">
          A sheet
        </StreamingText>
      );

      await screen.rerender(
        <StreamingText data-testid="answer">A sheet of cut acrylic</StreamingText>
      );

      const answer = screen.getByTestId('answer').element();

      await expect.poll(() => words()).toHaveLength(0);
      expect([...answer.childNodes].map((node) => node.nodeType)).toEqual([Node.TEXT_NODE]);
      expect(answer.textContent).toBe('A sheet of cut acrylic');
    });

    it('keeps the words of a stream that starts again before they are let go', async () => {
      const screen = await render(<StreamingText streaming>A sheet</StreamingText>);

      await screen.rerender(<StreamingText>A sheet of</StreamingText>);
      await screen.rerender(<StreamingText streaming>A sheet of cut acrylic</StreamingText>);
      await new Promise((resolve) => setTimeout(resolve, 400));

      expect(words()).toHaveLength(5);
    });

    it('draws a text that replaces a streamed one plain once nothing streams', async () => {
      const screen = await render(<StreamingText streaming>A sheet</StreamingText>);

      await screen.rerender(<StreamingText>Something else entirely</StreamingText>);

      expect(words()).toHaveLength(0);
      expect(document.body.textContent).toContain('Something else entirely');
    });

    it('fades a new answer streaming in over an old one', async () => {
      const screen = await render(<StreamingText streaming>First answer</StreamingText>);

      await screen.rerender(<StreamingText streaming>{''}</StreamingText>);
      await screen.rerender(<StreamingText streaming>Second one</StreamingText>);

      expect(words().map((word) => word.textContent)).toEqual(['Second', 'one']);
    });
  });

  /**
   * A token landing used to redraw every word of the answer. The words are
   * held in blocks that close once full, and only the last one is redrawn.
   */
  describe('a long answer', () => {
    it('keeps every word it has drawn as the answer grows past a block', async () => {
      const screen = await render(<StreamingText streaming>{wordsUpTo(150)}</StreamingText>);
      const before = words();

      await screen.rerender(<StreamingText streaming>{wordsUpTo(300)}</StreamingText>);

      const after = words();

      expect(after).toHaveLength(300);
      expect(after.slice(0, 150)).toEqual(before);
      expect(document.body.textContent).toContain(wordsUpTo(300));
    });

    it('keeps the word growing at the end in the element it already had', async () => {
      const text = wordsUpTo(64);
      const screen = await render(<StreamingText streaming>{`${text} acr`}</StreamingText>);
      const growing = words().at(-1);

      await screen.rerender(<StreamingText streaming>{`${text} acrylic sheet`}</StreamingText>);

      expect(growing?.textContent).toBe('acrylic');
      expect(words().at(-2)).toBe(growing);
      expect(words().at(-1)?.textContent).toBe('sheet');
    });

    it('starts again from the beginning when the text is replaced', async () => {
      const screen = await render(<StreamingText streaming>{wordsUpTo(150)}</StreamingText>);

      await screen.rerender(<StreamingText streaming>{'Short and new'}</StreamingText>);

      expect(words().map((word) => word.textContent)).toEqual(['Short', 'and', 'new']);
    });
  });

  /**
   * `Intl.Segmenter` cuts Japanese differently in different engines, and not
   * at all in a runtime without one, so words cut on the server and again in
   * the browser could disagree about where the elements go. The server and the
   * render that hydrates it both draw plain text instead.
   */
  describe('hydration', () => {
    const TEXT = '今日はとても良い天気です';

    for (const streaming of [false, true]) {
      it(`hydrates Japanese text without a mismatch${streaming ? ' while streaming' : ''}`, async () => {
        const host = document.createElement('div');
        const intl = Intl as { Segmenter?: unknown };
        const Segmenter = intl.Segmenter;
        const onRecoverableError = vi.fn();

        document.body.append(host);

        // A server with no segmenter cuts the run differently from this browser.
        delete intl.Segmenter;

        try {
          host.innerHTML = renderToString(
            <StreamingText streaming={streaming}>{TEXT}</StreamingText>
          );
        } finally {
          intl.Segmenter = Segmenter;
        }

        const root = hydrateRoot(
          host,
          <StreamingText streaming={streaming}>{TEXT}</StreamingText>,
          {
            onRecoverableError
          }
        );

        try {
          await expect.poll(() => host.textContent).toContain(TEXT);
          await new Promise((resolve) => setTimeout(resolve, 50));

          expect(onRecoverableError).not.toHaveBeenCalled();
          expect(host.querySelectorAll('.neba-stream-word')).toHaveLength(0);

          // And once it has hydrated, what streams in after fades as ever.
          root.render(<StreamingText streaming>{`${TEXT} next words`}</StreamingText>);

          await expect
            .poll(() =>
              [...host.querySelectorAll('.neba-stream-word')].map((word) => word.textContent)
            )
            .toEqual(['next', 'words']);
        } finally {
          root.unmount();
          host.remove();
        }
      });
    }
  });

  describe('the caret', () => {
    it('draws one while the stream runs', async () => {
      await render(<StreamingText streaming>A sheet</StreamingText>);

      expect(document.querySelector('.neba-stream-caret')).not.toBeNull();
    });

    it('takes it away when the stream stops', async () => {
      const screen = await render(<StreamingText streaming>A sheet</StreamingText>);

      await screen.rerender(<StreamingText>A sheet</StreamingText>);

      expect(document.querySelector('.neba-stream-caret')).toBeNull();
    });

    it('draws a caret of its own when it is handed one', async () => {
      const screen = await render(
        <StreamingText streaming cursor={<span>typing…</span>}>
          A sheet
        </StreamingText>
      );

      await expect.element(screen.getByText('typing…')).toBeInTheDocument();
      expect(document.querySelector('.neba-stream-caret')).toBeNull();
    });

    it('draws none at all when it is turned off', async () => {
      await render(
        <StreamingText streaming cursor={false}>
          A sheet
        </StreamingText>
      );

      expect(document.querySelector('.neba-stream-caret')).toBeNull();
    });

    it('marks itself busy while the stream runs', async () => {
      await render(<StreamingText streaming>A sheet</StreamingText>);

      expect(document.querySelector('[data-streaming][aria-busy="true"]')).not.toBeNull();
    });
  });

  describe('reserving the height', () => {
    it('holds one line before anything has arrived', async () => {
      await render(<StreamingText streaming />);
      const element = document.querySelector('[data-streaming]') as HTMLElement;

      expect(element.style.getPropertyValue('--n-reserve')).toBe('calc(1 * 1lh)');
    });

    it('holds as many as it was asked for', async () => {
      await render(<StreamingText lines={3} />);
      const element = document.querySelector('.min-h-\\(--n-reserve\\)') as HTMLElement;

      expect(element.style.getPropertyValue('--n-reserve')).toBe('calc(3 * 1lh)');
    });
  });
});
