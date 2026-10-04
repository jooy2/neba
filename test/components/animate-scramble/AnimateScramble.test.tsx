import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { renderToString } from 'react-dom/server';
import { hydrateRoot } from 'react-dom/client';
import { render } from 'vitest-browser-react';
import { AnimateScramble } from 'neba';

/*
 * The reduced-motion answer, under the test's control. The library keeps one
 * `MediaQueryList` per query and reads its `matches` live, so a stand-in handed
 * out before the first render is the one every render in this file asks.
 */
let reduceMotion = false;
const matchMedia = window.matchMedia.bind(window);

window.matchMedia = (query: string) => {
  const list = matchMedia(query);

  if (!query.includes('prefers-reduced-motion')) {
    return list;
  }

  return new Proxy(list, {
    get(target, key) {
      if (key === 'matches') {
        return reduceMotion;
      }
      const value = Reflect.get(target, key, target);
      return typeof value === 'function' ? value.bind(target) : value;
    }
  });
};

/** The layer the line is laid out in, a word and a gap at a time. */
function layer(root: Element): Element[] {
  return [...(root.querySelector('[aria-hidden="true"]')?.children ?? [])];
}

/**
 * What a sighted reader sees: the noise of each word still settling, the final
 * text of each word that has, and the whitespace between them — all drawn off
 * attributes, so none of it is text.
 */
function shown(root: Element): string {
  return layer(root)
    .map((part) => part.getAttribute('data-text') ?? part.getAttribute('data-sample'))
    .join('');
}

/*
 * On the fake clock. The letters settle on a chain of timeouts while an
 * interval redraws the noise, and on a real clock both kinds of test raced it:
 * a short run against a one-second poll, and a long one the other way — a
 * reading of the first frame that a slow runner had already moved past, so a
 * letter had settled and `####` read `A###`. React still commits on a task of
 * its own, so the DOM is waited for after the clock moves.
 */
describe('AnimateScramble', () => {
  // A `<div>` by default, which is not allowed inside a paragraph.
  it('renders a span, so it can sit inside a sentence', async () => {
    const screen = await render(
      <p>
        Now <AnimateScramble data-testid="word" text="shipping" trigger="manual" />
      </p>
    );

    expect(screen.getByTestId('word').element().tagName).toBe('SPAN');
  });

  // The docs said the box never changed size, and in a proportional font the
  // noise was wider or narrower than the text it settled into.
  it('lays its box out from the final text', async () => {
    const screen = await render(
      <AnimateScramble text="Hello there" trigger="manual" data-testid="scramble" />
    );
    const root = screen.getByTestId('scramble').element();

    expect(layer(root).map((part) => part.getAttribute('data-sample'))).toEqual([
      'Hello',
      ' ',
      'there'
    ]);
    expect(root.querySelector('[aria-hidden="true"]')?.textContent).toBe('');
  });

  /*
   * The noise was a text node beside the clipped string, so the HTML a server
   * sent read "RESOLVING SIGNAL 7@W5#IBM$ KUUWHI". The noise is drawn, not
   * written, and the text is in the element once.
   */
  it('holds the text once, and none of the noise, in the HTML a server sends', () => {
    const host = document.createElement('div');

    host.innerHTML = renderToString(<AnimateScramble text="RESOLVING SIGNAL" />);
    document.body.append(host);

    try {
      expect(host.textContent).toBe('RESOLVING SIGNAL');
      expect(host.innerText).toBe('RESOLVING SIGNAL');
      expect(shown(host)).toHaveLength('RESOLVING SIGNAL'.length);
      expect(shown(host)).not.toBe('RESOLVING SIGNAL');
    } finally {
      host.remove();
    }
  });

  /*
   * The noise shared a grid cell with the final text, so the box took the wider
   * of the two and a heading could gain a line while it settled. Each word's
   * noise sits over that word now, positioned against it, so only the final
   * text is laid out.
   */
  it('lays the noise over the final text rather than beside it', async () => {
    const screen = await render(
      <AnimateScramble text="Hello there" trigger="manual" data-testid="scramble" />
    );
    const root = screen.getByTestId('scramble').element();
    const words = layer(root).filter((part) => part.hasAttribute('data-text'));

    expect(words).toHaveLength(2);

    for (const word of words) {
      // The noise is the word's own `::after`, positioned against the word.
      expect(word).toHaveClass('relative', 'after:absolute');
      expect(word.children).toHaveLength(0);
      expect(word.getAttribute('data-text')).toHaveLength(
        word.getAttribute('data-sample')?.length ?? -1
      );
    }

    // The clipped copy and the final text: nothing else is laid out in the box.
    expect(root.children).toHaveLength(2);
  });

  // A finished line is drawn as the text itself, wherever the browser puts it,
  // rather than as noise that has come to rest over it.
  it('draws a word that has settled as the text itself', async () => {
    const screen = await render(
      <AnimateScramble text="Hello there" duration={0} data-testid="scramble" />
    );
    const root = screen.getByTestId('scramble').element();

    await expect.poll(() => shown(root)).toBe('Hello there');

    for (const part of layer(root)) {
      expect(part).not.toHaveAttribute('data-text');
    }

    expect(layer(root)[0]).toHaveClass('visible');
  });

  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  // `hover` and `manual` may never be triggered, and noise waiting for them is
  // motion the reader asked not to see.
  it('shows the text itself, untriggered, to a reader who asked for less motion', async () => {
    reduceMotion = true;

    try {
      const screen = await render(<AnimateScramble text="NEBA" trigger="manual" data-testid="s" />);

      expect(shown(screen.getByTestId('s').element())).toBe('NEBA');
    } finally {
      reduceMotion = false;
    }
  });

  it('settles on the text it was given', async () => {
    const screen = await render(<AnimateScramble text="NEBA" duration={80} data-testid="s" />);

    await vi.runAllTimersAsync();

    await expect.poll(() => shown(screen.getByTestId('s').element())).toBe('NEBA');
  });

  // `play` going up is a caller pressing go again, and the text stayed settled:
  // the loop was keyed on having started, which it still had.
  it('scrambles the text again when play goes up', async () => {
    const step = 60_000;
    const scramble = (play: number) => (
      <AnimateScramble
        text="ABCD"
        characters="#"
        trigger="manual"
        play={play}
        duration={step * 4}
        tick={step * 100}
        data-testid="s"
      />
    );
    const screen = await render(scramble(1));
    const root = screen.getByTestId('s').element();

    await vi.runAllTimersAsync();
    await expect.poll(() => shown(root)).toBe('ABCD');

    await screen.rerender(scramble(2));
    await expect.poll(() => shown(root)).toBe('####');

    await vi.runAllTimersAsync();
    await expect.poll(() => shown(root)).toBe('ABCD');
  });

  /*
   * A minute a letter, and noise that never redraws, because `expect.poll`
   * moves a fake clock on by its own interval each time it retries: with a step
   * that long no retry reaches the next letter, and with the pool a single
   * character what has not settled can only read `#`.
   */
  it('settles one letter at a time from the left', async () => {
    const step = 60_000;
    const screen = await render(
      <AnimateScramble
        text="ABCD"
        characters="#"
        duration={step * 4}
        tick={step * 100}
        data-testid="s"
      />
    );
    const root = screen.getByTestId('s').element();

    for (const frame of ['A###', 'AB##', 'ABC#', 'ABCD']) {
      await vi.advanceTimersByTimeAsync(step);
      await expect.poll(() => shown(root)).toBe(frame);
    }
  });

  // Pausing tore the settling down, and resuming started it again from the
  // first letter, so a paused heading went back to noise.
  it('picks up where it was paused rather than starting over', async () => {
    const step = 60_000;
    const props = { text: 'ABCD', characters: '#', duration: step * 4, tick: step * 100 };
    const screen = await render(<AnimateScramble {...props} data-testid="s" />);
    const root = screen.getByTestId('s').element();

    await vi.advanceTimersByTimeAsync(step * 2);
    await expect.poll(() => shown(root)).toBe('AB##');

    await screen.rerender(<AnimateScramble {...props} paused data-testid="s" />);
    await screen.rerender(<AnimateScramble {...props} data-testid="s" />);

    await expect.poll(() => shown(root)).toBe('AB##');

    await vi.advanceTimersByTimeAsync(step);
    await expect.poll(() => shown(root)).toBe('ABC#');
  });

  // The box never changes size, which is the whole reason to reach for this
  // rather than for a typewriter.
  it('is the finished length from the first frame', async () => {
    const screen = await render(<AnimateScramble text="NEBA UI" duration={4000} data-testid="s" />);

    expect(shown(screen.getByTestId('s').element())).toHaveLength(7);
  });

  /* A space that flickered into a letter would read as the words having moved. */
  it('never scrambles whitespace', async () => {
    const screen = await render(<AnimateScramble text="AB CD" duration={4000} data-testid="s" />);

    expect(shown(screen.getByTestId('s').element())[2]).toBe(' ');
  });

  it('draws the noise from the pool it was given', async () => {
    const screen = await render(
      <AnimateScramble text="ABCD" characters="#" duration={4000} data-testid="s" />
    );

    expect(shown(screen.getByTestId('s').element())).toBe('####');
  });

  /*
   * The noise is picked during the render, so with a random source every
   * re-render from anywhere above — a parent's state, a route change, a resize
   * — reshuffled every unsettled letter at whatever moment that render landed.
   * The effect is a clock and was answering to the whole page.
   */
  it('does not reshuffle on a render that is not a tick', async () => {
    const screen = await render(
      <AnimateScramble text="ABCDEFGH" tick={100000} duration={100000} data-testid="s" />
    );
    const before = shown(screen.getByTestId('s').element());

    await screen.rerender(
      <AnimateScramble
        text="ABCDEFGH"
        tick={100000}
        duration={100000}
        data-testid="s"
        className="a-change-that-is-not-a-tick"
      />
    );

    expect(shown(screen.getByTestId('s').element())).toBe(before);
  });

  it('tells a screen reader the finished text', async () => {
    const screen = await render(<AnimateScramble text="NEBA" duration={4000} data-testid="s" />);

    expect(screen.getByTestId('s').element().children[0].textContent).toBe('NEBA');
  });

  it('holds the text once while it settles and after', async () => {
    const step = 60_000;
    const screen = await render(
      <AnimateScramble
        text="AB CD"
        characters="#"
        duration={step * 5}
        tick={step * 100}
        data-testid="s"
      />
    );
    const root = screen.getByTestId('s').element();

    await vi.advanceTimersByTimeAsync(step);
    await expect.poll(() => shown(root)).toBe('A# ##');
    expect(root.textContent).toBe('AB CD');

    await vi.runAllTimersAsync();
    await expect.poll(() => shown(root)).toBe('AB CD');
    expect(root.textContent).toBe('AB CD');
  });

  it('takes the text from its children too', async () => {
    const screen = await render(
      <AnimateScramble duration={60} data-testid="s">
        Hello
      </AnimateScramble>
    );

    await vi.runAllTimersAsync();

    await expect.poll(() => shown(screen.getByTestId('s').element())).toBe('Hello');
  });
});

/*
 * The noise is picked per character, and `Intl.Segmenter` counts characters
 * differently on different engines, so a server and a browser that disagreed
 * drew two different opening frames. The stand-in is two engines in one: the
 * real segmenter while the "server" renders, and one that cuts every code
 * point apart afterwards. It decides when it is used rather than when it is
 * built, because the library keeps one segmenter per locale.
 */
describe('AnimateScramble hydration', () => {
  it('hydrates the frame the server drew, whatever the segmenter says', async () => {
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

        return [...text].map((segment, index) => ({ segment, index, input: text }));
      }
    } as unknown as typeof Intl.Segmenter;

    const errors = vi.spyOn(console, 'error').mockImplementation(() => {});
    // A locale nothing else asks for, so the stand-in is the only segmenter
    // ever built for it.
    const element = (
      <AnimateScramble text="é 👩‍👩‍👧 NEBA" locale="tlh" tick={60_000} duration={60_000} />
    );
    const host = document.createElement('div');

    try {
      host.innerHTML = renderToString(element);
    } finally {
      server = false;
    }

    document.body.append(host);

    const recoverable: unknown[] = [];
    const root = hydrateRoot(host, element, {
      onRecoverableError: (error) => recoverable.push(error)
    });

    try {
      await new Promise((resolve) => setTimeout(resolve, 60));

      expect(recoverable).toEqual([]);
      expect(errors.mock.calls.flat().join(' ')).not.toMatch(/did ?n.t match/);
      expect(host.textContent).toBe('é 👩‍👩‍👧 NEBA');
    } finally {
      scope.Segmenter = Segmenter;
      errors.mockRestore();
      root.unmount();
      host.remove();
    }
  });
});
