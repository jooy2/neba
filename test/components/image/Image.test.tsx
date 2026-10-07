/**
 * The three things an `<img>` does not do — hold its space, say it is loading,
 * say it failed — are the three things worth testing here.
 *
 * The sources are data URIs so nothing depends on the network: a 1×1 GIF that
 * always decodes, and a string that never will.
 */
import * as React from 'react';
import { describe, expect, it, vi } from 'vitest';
import { renderToString } from 'react-dom/server';
import { hydrateRoot } from 'react-dom/client';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
import { Image } from 'neba';
import { previewChunk } from '../../../src/components/image/Image.js';

const OK = 'data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==';
const BROKEN = 'data:image/gif;base64,not-a-picture';

/**
 * The names of an element's attributes in some server HTML, in the order they
 * were written. A server render writes them in the order the props were, which
 * is the order React 18 sets them in the browser — and React 19 reorders `src`
 * there itself, so the browser's own DOM would hide what this looks for.
 */
const attributesIn = (html: string, selector: string) =>
  new DOMParser().parseFromString(html, 'text/html').querySelector(selector)?.getAttributeNames() ??
  [];

/**
 * Renders something only once the render that hydrated it is over, the way
 * `useHydrated` answers — so a test can wait for the render after hydration
 * rather than for an arbitrary amount of time.
 */
function PastHydration() {
  const past = React.useSyncExternalStore(
    () => () => {},
    () => true,
    () => false
  );

  return past ? <i data-past-hydration="" /> : null;
}

/**
 * Renders on the "server", puts the HTML in the page, and hydrates it. `before`
 * is a copy of what the server sent, taken before React has touched it.
 */
async function serve(element: React.ReactElement) {
  const host = document.createElement('div');
  const tree = (
    <>
      {element}
      <PastHydration />
    </>
  );

  host.innerHTML = renderToString(tree);
  document.body.append(host);

  const before = host.cloneNode(true) as HTMLElement;
  const recoverable = vi.fn();
  const root = hydrateRoot(host, tree, { onRecoverableError: recoverable });

  await vi.waitFor(() => expect(host.querySelector('[data-past-hydration]')).not.toBeNull());

  return {
    host,
    before,
    recoverable,
    done: () => {
      root.unmount();
      host.remove();
    }
  };
}

/*
 * Read as a number rather than as the string that was written. A browser
 * normalises `aspect-ratio: 1.5` into a `<ratio>` of its own choosing — `1.5 / 1`
 * in Chromium — and the three engines the suite runs on do not have to agree on
 * how they spell it.
 */
const ratioOf = (element: HTMLElement | null | undefined) => {
  const [left, right = '1'] = (element?.style.aspectRatio ?? '').split('/');

  return Number(left) / Number(right);
};

describe('Image', () => {
  it('renders an img with the alt it was given', async () => {
    const screen = await render(<Image src={OK} alt="A ridge of hills" />);

    await expect.element(screen.getByRole('img', { name: 'A ridge of hills' })).toBeInTheDocument();
  });

  it('reports when the file arrives', async () => {
    const onLoadingStatusChange = vi.fn();
    await render(<Image src={OK} alt="A ridge" onLoadingStatusChange={onLoadingStatusChange} />);

    await vi.waitFor(() => expect(onLoadingStatusChange).toHaveBeenCalledWith('loaded'));
  });

  it('reports and draws a fallback when it does not', async () => {
    const onLoadingStatusChange = vi.fn();
    const screen = await render(
      <Image src={BROKEN} alt="A ridge" onLoadingStatusChange={onLoadingStatusChange} />
    );

    await vi.waitFor(() => expect(onLoadingStatusChange).toHaveBeenCalledWith('failed'));
    // Something rather than nothing: the browser's own torn-page glyph tells a
    // reader the site is broken rather than that one file is missing.
    await expect.element(screen.getByText('A ridge')).toBeInTheDocument();
  });

  it('names a failed picture once, through its img', async () => {
    const screen = await render(<Image src={BROKEN} alt="A ridge" />);

    await expect.element(screen.getByText('A ridge')).toBeInTheDocument();
    // The words over the box are for sight; the img still carries the name.
    expect(screen.getByText('A ridge').element()).toHaveAttribute('aria-hidden', 'true');
    await expect.element(screen.getByRole('img', { name: 'A ridge' })).toBeInTheDocument();
  });

  it('names the preview of a picture with an empty alt by what it does', async () => {
    const screen = await render(<Image src={OK} alt="" preview />);

    await screen.getByRole('button', { name: 'Enlarge image' }).click();

    await expect.element(screen.getByRole('dialog', { name: 'Enlarge image' })).toBeInTheDocument();
  });

  // Named after the picture, the button said nothing about opening anything.
  it('says that its preview button opens a dialog', async () => {
    const screen = await render(<Image src={OK} alt="A ridge" preview />);

    await expect
      .element(screen.getByRole('button', { name: 'A ridge' }))
      .toHaveAttribute('aria-haspopup', 'dialog');
  });

  it('still shows the picture when a caller listens for the load', async () => {
    // A file served over the network rather than a data URI: a data URI has
    // already decoded by the time the component looks, and that path never
    // reaches the `load` listener this is about.
    const onLoad = vi.fn();
    const screen = await render(
      <Image src="/docs/public/samples/photos/alpine-lake-dawn.jpg" alt="A lake" onLoad={onLoad} />
    );

    await vi.waitFor(() => expect(onLoad).toHaveBeenCalled());
    await expect.element(screen.getByRole('img', { name: 'A lake' })).toHaveClass('opacity-100');
  });

  // The type named `loading` and nothing ever reported it, so a caller could not
  // tell a file on its way from one that had not been asked for.
  it('reports loading before the file arrives', async () => {
    const onLoadingStatusChange = vi.fn();
    await render(
      <Image
        src="/docs/public/samples/photos/alpine-lake-dawn.jpg?status"
        alt="A lake"
        onLoadingStatusChange={onLoadingStatusChange}
      />
    );

    await vi.waitFor(() => expect(onLoadingStatusChange).toHaveBeenCalledWith('loaded'));

    expect(onLoadingStatusChange.mock.calls.map(([status]) => status)).toEqual([
      'loading',
      'loaded'
    ]);
  });

  it('draws a fallback of its own when given one', async () => {
    const screen = await render(
      <Image src={BROKEN} alt="A ridge" fallback={<span>Could not load</span>} />
    );

    await expect.element(screen.getByText('Could not load')).toBeInTheDocument();
  });

  /*
   * An empty `alt` says the picture carries nothing a reader needs, so the box
   * has to invent a word — and a word the library invents is a word it has to
   * be able to say in the reader's language. English is what it says when the
   * page has not registered one.
   */
  it('names its own absence when there is no alt to put there', async () => {
    const screen = await render(<Image src={BROKEN} alt="" />);

    await expect.element(screen.getByText('Image unavailable')).toBeInTheDocument();
  });

  it('takes a wording of its own over the locale', async () => {
    const screen = await render(<Image src={BROKEN} alt="" unavailableLabel="Gone" />);

    await expect.element(screen.getByText('Gone')).toBeInTheDocument();
  });

  it('starts over when the src changes', async () => {
    // Without this a second file inherits the first one's success and never
    // shows a placeholder — and a second file that fails inherits it too.
    const onLoadingStatusChange = vi.fn();
    const screen = await render(
      <Image src={OK} alt="A ridge" onLoadingStatusChange={onLoadingStatusChange} />
    );

    await vi.waitFor(() => expect(onLoadingStatusChange).toHaveBeenCalledWith('loaded'));

    await screen.rerender(
      <Image src={BROKEN} alt="A ridge" onLoadingStatusChange={onLoadingStatusChange} />
    );

    await vi.waitFor(() => expect(onLoadingStatusChange).toHaveBeenLastCalledWith('failed'));
  });

  /*
   * No `src` at all, rather than one that is going to fail. `BROKEN` never
   * reaches the loading phase in WebKit: a malformed data URI needs no network
   * and no decode, so `error` is dispatched before the first assertion can
   * look, and what this found was the fallback. An `<img>` with nothing to
   * fetch fires neither `load` nor `error` in any browser, which is the loading
   * phase held still — and holding it still is the only way to assert on it.
   */
  it('stands a placeholder in while the file is arriving', async () => {
    const screen = await render(<Image alt="A ridge" placeholder={<span>loading…</span>} />);

    await expect.element(screen.getByText('loading…')).toBeInTheDocument();
  });

  // Held in the loading phase for the reason above, and here it is the whole
  // test: with a `src` that fails immediately the phase is `failed` before this
  // looks, and an assertion that no placeholder was drawn passes without the
  // prop under test having been read at all.
  it('draws no placeholder when told not to', async () => {
    const screen = await render(<Image alt="A ridge" placeholder={false} />);

    expect(screen.container.querySelectorAll('[class*="animate"]').length).toBe(0);
  });

  describe('a picture as the placeholder', () => {
    const standInOf = (container: HTMLElement) =>
      container.querySelector<HTMLImageElement>('img[aria-hidden="true"]');

    // Held in the loading phase with no `src`, for the reason given above.
    it('draws the picture it was given instead of a Skeleton', async () => {
      const screen = await render(<Image alt="A ridge" ratio={1} placeholder={{ src: OK }} />);
      const standIn = standInOf(screen.container);

      expect(standIn).toHaveAttribute('src', OK);
      expect(standIn).toHaveAttribute('alt', '');
      expect(standIn).toHaveClass('opacity-100', 'object-cover');
      expect(screen.container.querySelectorAll('[class*="animate"]').length).toBe(0);
      // Positioned, so the picture paints over it when it arrives.
      await expect.element(screen.getByRole('img', { name: 'A ridge' })).toHaveClass('relative');
    });

    it('blurs it, and grows it past the box so the blur has no edge', async () => {
      const screen = await render(
        <Image alt="A ridge" ratio={1} placeholder={{ src: OK, blur: true }} />
      );
      const standIn = standInOf(screen.container) as HTMLImageElement;

      expect(standIn.style.filter).toBe('blur(20px)');
      expect(standIn.style.width).toBe('calc(100% + 80px)');

      await screen.rerender(<Image alt="A ridge" ratio={1} placeholder={{ src: OK, blur: 6 }} />);
      expect((standInOf(screen.container) as HTMLImageElement).style.filter).toBe('blur(6px)');
    });

    // A lazy Gallery of forty tiles fetched forty stand-ins with the page, for
    // tiles nobody had scrolled to yet.
    it('fetches it no sooner than the picture', async () => {
      const screen = await render(
        <Image src={OK} alt="A ridge" ratio={1} loading="lazy" placeholder={{ src: OK }} />
      );

      expect(standInOf(screen.container)).toHaveAttribute('loading', 'lazy');

      await screen.rerender(<Image src={OK} alt="A ridge" ratio={1} placeholder={{ src: OK }} />);

      expect(standInOf(screen.container)).not.toHaveAttribute('loading');
    });

    it('turns and places it the way the picture will be', async () => {
      const screen = await render(
        <Image
          alt="A ridge"
          ratio={1}
          fit="contain"
          position="top"
          rotate={180}
          placeholder={{ src: OK }}
        />
      );
      const standIn = standInOf(screen.container) as HTMLImageElement;

      expect(standIn).toHaveClass('object-contain');
      expect(standIn.style.rotate).toBe('180deg');
      expect(standIn.style.objectPosition).toBe('50% 100%');
    });

    it('draws a Blob through an object URL and releases it when it is gone', async () => {
      const revoke = vi.spyOn(URL, 'revokeObjectURL');
      const blob = await (await fetch(OK)).blob();
      const screen = await render(<Image alt="A ridge" ratio={1} placeholder={{ src: blob }} />);

      await vi.waitFor(() =>
        expect(standInOf(screen.container)?.getAttribute('src')).toMatch(/^blob:/)
      );

      const url = standInOf(screen.container)?.getAttribute('src');

      await screen.unmount();

      expect(revoke).toHaveBeenCalledWith(url);
      revoke.mockRestore();
    });

    /*
     * Taken away only once the picture has faded in over it: gone at once, the
     * two would be half there together and the page would show through.
     */
    it('waits for the picture to finish arriving before it goes', async () => {
      const screen = await render(
        <Image src={OK} alt="A ridge" ratio={1} placeholder={{ src: OK }} />
      );

      await vi.waitFor(() => expect(standInOf(screen.container)).toHaveClass('opacity-0'));
      expect(standInOf(screen.container)?.className).toContain(
        'transition:opacity_0ms_linear_var(--neba-duration-fill)'
      );
    });

    it('is taken away when the file fails', async () => {
      const screen = await render(
        <Image src={BROKEN} alt="A ridge" ratio={1} placeholder={{ src: OK }} />
      );

      await expect.element(screen.getByText('A ridge')).toBeInTheDocument();
      expect(standInOf(screen.container)).toBeNull();
    });
  });

  /*
   * The fade was written down and never ran: the picture carried the house
   * transition, whose property list is the four a control answers a pointer
   * with, and `opacity` is not one of them. Held in the loading phase, because
   * that is the end of the fade that is still visible.
   */
  it('fades the picture in on a transition that names opacity', async () => {
    const screen = await render(<Image alt="A ridge" />);
    const picture = screen.container.querySelector('img') as HTMLImageElement;

    expect(picture.className).toContain('transition:opacity');
    expect(picture).toHaveClass('opacity-0');
    expect(picture.className).not.toContain('transition-property:background-color');
  });

  // Held in the loading phase, which is what a server render arrives in: a
  // priority picture is drawn then, with nothing over it.
  it('draws a priority picture from the first paint, with no fade and no cover', async () => {
    const screen = await render(<Image alt="A ridge" priority />);
    const picture = screen.container.querySelector('img') as HTMLImageElement;

    expect(picture).toHaveClass('opacity-100');
    expect(picture).not.toHaveClass('opacity-0');
    expect(screen.container.querySelectorAll('[class*="animate"]').length).toBe(0);
  });

  it('reserves a box for a ratio it was given', async () => {
    const screen = await render(<Image src={OK} alt="A ridge" ratio="16 / 9" />);
    const framed = screen.container.querySelector('[style*="aspect-ratio"]');

    expect(framed).not.toBeNull();
  });

  /*
   * `width` and `height` are the platform's own answer to layout shift, and
   * they were omitted from the props — so the one component that exists to hold
   * a picture's space had no way to be told what that space was except by
   * working the ratio out by hand.
   */
  describe('width and height', () => {
    it('puts them on the img', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" width={1200} height={800} />);
      const picture = screen.getByRole('img', { name: 'A ridge' }).element();

      expect(picture).toHaveAttribute('width', '1200');
      expect(picture).toHaveAttribute('height', '800');
    });

    it('reserves the box they describe', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" width={1200} height={800} />);
      const framed = screen.container.querySelector<HTMLElement>('[style*="aspect-ratio"]');

      expect(ratioOf(framed)).toBeCloseTo(1.5);
    });

    // The attribute takes a string, so a numeric one counts. A percentage is a
    // length and says nothing about the shape.
    it('reads a numeric string and refuses a length', async () => {
      const numeric = await render(<Image src={OK} alt="A ridge" width="1200" height="800" />);
      expect(
        ratioOf(numeric.container.querySelector<HTMLElement>('[style*="aspect-ratio"]'))
      ).toBeCloseTo(1.5);

      const length = await render(<Image src={OK} alt="A ridge" width="50%" height="20rem" />);
      expect(length.container.querySelector('[style*="aspect-ratio"]')).toBeNull();
    });

    /*
     * A proportion needs two numbers, so one on its own is read as the length it
     * looks like: the size of the box on that axis, with `fit` deciding what the
     * picture does inside.
     */
    describe('one on its own', () => {
      const boxIn = (container: HTMLElement) => container.firstElementChild as HTMLElement;

      it('sizes the box to a lone height and reserves no proportion', async () => {
        const screen = await render(<Image src={OK} alt="A ridge" height={200} />);
        const box = boxIn(screen.container);

        expect(box.style.height).toBe('200px');
        expect(box.style.width).toBe('');
        expect(screen.container.querySelector('[style*="aspect-ratio"]')).toBeNull();
        await expect
          .element(screen.getByRole('img', { name: 'A ridge' }))
          .toHaveAttribute('height', '200');
      });

      it('sizes the box to a lone width, capped at its container', async () => {
        const screen = await render(<Image src={OK} alt="A ridge" width={320} />);
        const box = boxIn(screen.container);

        expect(box.style.width).toBe('320px');
        expect(box.style.maxWidth).toBe('100%');
        expect(box.style.height).toBe('');
      });

      // The attribute is written as digits, and a CSS length is a CSS length.
      it('reads digits as pixels and passes a length through', async () => {
        const digits = await render(<Image src={OK} alt="A ridge" height="180" />);
        expect(boxIn(digits.container).style.height).toBe('180px');

        const length = await render(<Image src={OK} alt="A ridge" width="20rem" />);
        expect(boxIn(length.container).style.width).toBe('20rem');
      });

      it('takes the width from a ratio beside a lone height', async () => {
        const screen = await render(<Image src={OK} alt="A ridge" height={120} ratio="4 / 3" />);
        const box = boxIn(screen.container);

        expect(box.style.height).toBe('120px');
        expect(box.style.width).toBe('auto');
        expect(ratioOf(box)).toBeCloseTo(4 / 3);
      });

      // A mount or a button stretched to the container would draw its mat, its
      // shadow or its focus ring out past a picture narrower than that.
      it('shrinks a frame and a preview button to a narrowed box', async () => {
        const framed = await render(
          <Image
            src={OK}
            alt="A ridge"
            width={240}
            frame={{ mat: 8 }}
            classNames={{ frame: 'mount' }}
          />
        );
        expect((framed.container.querySelector('.mount') as HTMLElement).style.width).toBe(
          'fit-content'
        );

        const previewed = await render(<Image src={OK} alt="A ridge" width={240} preview />);
        await expect
          .element(previewed.getByRole('button', { name: 'A ridge' }))
          .toHaveClass('[:where(&)]:w-fit');
      });
    });

    // `ratio` is the layout's shape and these two are the picture's, so an
    // explicit one wins.
    it('gives way to a ratio it was given', async () => {
      const screen = await render(
        <Image src={OK} alt="A ridge" width={1200} height={800} ratio="16 / 9" />
      );
      const framed = screen.container.querySelector<HTMLElement>('[style*="aspect-ratio"]');

      expect(ratioOf(framed)).toBeCloseTo(16 / 9);
    });
  });

  describe('fit', () => {
    it('covers by default', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" />);

      await expect
        .element(screen.getByRole('img', { name: 'A ridge' }))
        .toHaveClass('object-cover');
    });

    // `contain` that never enlarges, for a file that may be smaller than its box.
    it('takes scale-down', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" fit="scale-down" />);

      await expect
        .element(screen.getByRole('img', { name: 'A ridge' }))
        .toHaveClass('object-scale-down');
    });
  });

  describe('position', () => {
    const placedIn = (container: HTMLElement) =>
      (container.querySelector('img') as HTMLImageElement).style.objectPosition;

    it('writes nothing when it is not asked for', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" />);

      expect(placedIn(screen.container)).toBe('');
    });

    // Percentages whatever was written, so every engine spells it one way.
    it('writes a keyword, a corner or a pair of percentages as percentages', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" position="top" />);
      expect(placedIn(screen.container)).toBe('50% 0%');

      await screen.rerender(<Image src={OK} alt="A ridge" position="bottom right" />);
      expect(placedIn(screen.container)).toBe('100% 100%');

      await screen.rerender(<Image src={OK} alt="A ridge" position="30% 20%" />);
      expect(placedIn(screen.container)).toBe('30% 20%');
    });

    /*
     * `object-position` is laid out before the element is turned or mirrored,
     * so each of these would keep the opposite edge if it were passed through.
     * What is asserted is the edge the reader sees kept.
     */
    it('keeps the side of the picture the reader sees, through a turn', async () => {
      const upsideDown = await render(
        <Image src={OK} alt="A ridge" ratio={1} position="top" rotate={180} />
      );
      expect(placedIn(upsideDown.container)).toBe('50% 100%');

      // A quarter clockwise draws the element's bottom edge down the left.
      const onItsSide = await render(
        <Image src={OK} alt="A ridge" ratio={1} position="left" rotate={90} />
      );
      expect(placedIn(onItsSide.container)).toBe('50% 100%');
    });

    it('keeps the side of the picture the reader sees, through a mirror', async () => {
      const screen = await render(
        <Image src={OK} alt="A ridge" position="25% 10%" flip="horizontal" />
      );

      expect(placedIn(screen.container)).toBe('75% 10%');
    });

    it('hands a value it cannot read straight through', async () => {
      const screen = await render(
        <Image src={OK} alt="A ridge" position={'left 10px top 20px' as 'top'} />
      );

      expect(placedIn(screen.container)).toBe('left 10px top 20px');
    });
  });

  describe('priority and loading', () => {
    it('leaves when to load to the browser by default', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" />);
      const picture = screen.getByRole('img', { name: 'A ridge' }).element();

      expect(picture).not.toHaveAttribute('loading');
      expect(picture.getAttribute('fetchpriority')).toBeNull();
    });

    it('fetches the picture a page is judged by early and eagerly', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" priority />);
      const picture = screen.getByRole('img', { name: 'A ridge' }).element();

      expect(picture).toHaveAttribute('loading', 'eager');
      // An HTML attribute name is case-insensitive, so this reads it whichever
      // spelling the installed React wrote.
      expect(picture.getAttribute('fetchpriority')).toBe('high');
    });

    it('lets an attribute written out win over what priority implies', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" priority loading="lazy" />);

      await expect
        .element(screen.getByRole('img', { name: 'A ridge' }))
        .toHaveAttribute('loading', 'lazy');
    });

    it('passes the native loading attributes through', async () => {
      const screen = await render(
        <Image src={OK} alt="A ridge" loading="lazy" decoding="async" fetchPriority="low" />
      );
      const picture = screen.getByRole('img', { name: 'A ridge' }).element();

      expect(picture).toHaveAttribute('loading', 'lazy');
      expect(picture).toHaveAttribute('decoding', 'async');
      expect(picture.getAttribute('fetchpriority')).toBe('low');
    });
  });

  it('becomes a button when it can be previewed', async () => {
    const screen = await render(<Image src={OK} alt="A ridge" preview />);

    // Reachable by keyboard: a picture that only a pointer can enlarge is one
    // half the readers cannot enlarge.
    await expect.element(screen.getByRole('button', { name: 'A ridge' })).toBeInTheDocument();
    // And visibly focused when it is reached. Nothing above an Image declares a
    // ring colour, so the outline carries its own fallback or is dropped whole.
    expect(screen.getByRole('button', { name: 'A ridge' }).element().className).toContain(
      'var(--n-ring,var(--neba-primary-ring))'
    );
  });

  // They landed on the picture inside, so the button spanned the whole line
  // and the empty space beside a smaller picture opened it.
  it('puts className and style on the preview button', async () => {
    const screen = await render(
      <Image src={OK} alt="A ridge" preview className="thumb" style={{ width: 120 }} />
    );
    const button = screen.getByRole('button', { name: 'A ridge' }).element() as HTMLElement;

    expect(button).toHaveClass('thumb');
    expect(button.style.width).toBe('120px');
    expect(button.querySelector('.thumb')).toBeNull();
    expect(button.querySelector<HTMLElement>('[style*="width"]')).toBeNull();
  });

  it('opens the full picture when previewed', async () => {
    const screen = await render(<Image src={OK} alt="A ridge" preview />);

    await screen.getByRole('button', { name: 'A ridge' }).click();

    await expect.element(screen.getByRole('dialog', { name: 'A ridge' })).toBeInTheDocument();
  });

  /*
   * The Dialog is a lazy chunk, and a lazy component in a server render is a
   * boundary `renderToString` cannot wait for: it gave up, sent a marker for
   * the browser to render it instead, and React reported that at hydration.
   * The Dialog is now mounted by the first press, so there is nothing to wait
   * for until somebody asks.
   */
  /*
   * Mounted only by the press, the Dialog was downloaded by the press too, and
   * the first preview opened only once the network had answered. The download
   * starts when a reader reaches for the picture instead, and still nothing is
   * mounted until the press.
   */
  describe('fetching the preview', () => {
    // Held below where earlier tests left the pointer, so it is not already
    // over the picture when the picture appears.
    const below = (child: React.ReactNode) => <div style={{ paddingTop: 320 }}>{child}</div>;

    it('starts when a pointer arrives over the picture, and not before', async () => {
      const load = vi.spyOn(previewChunk, 'load');

      try {
        const screen = await render(below(<Image src={OK} alt="A ridge" preview />));
        const button = screen.getByRole('button', { name: 'A ridge' });

        await new Promise(requestAnimationFrame);
        expect(load).not.toHaveBeenCalled();

        await button.hover();
        expect(load).toHaveBeenCalledTimes(1);

        // Once per picture: every reach after the first does nothing.
        (button.element() as HTMLElement).focus();
        expect(load).toHaveBeenCalledTimes(1);
        expect(screen.getByRole('dialog').query()).toBeNull();
      } finally {
        load.mockRestore();
      }
    });

    it('starts when the focus reaches the picture', async () => {
      const load = vi.spyOn(previewChunk, 'load');

      try {
        const screen = await render(below(<Image src={OK} alt="A ridge" preview />));

        (screen.getByRole('button', { name: 'A ridge' }).element() as HTMLElement).focus();

        expect(load).toHaveBeenCalledTimes(1);
      } finally {
        load.mockRestore();
      }
    });

    it('is not asked for by a server render, which holds no boundary', () => {
      const load = vi.spyOn(previewChunk, 'load');

      try {
        const html = renderToString(<Image src={OK} alt="A ridge" preview />);

        expect(load).not.toHaveBeenCalled();
        expect(html).not.toContain('<!--$');
      } finally {
        load.mockRestore();
      }
    });

    // The press is handed the request a reach already started, rather than
    // making a second one.
    it('hands every caller the one request', () => {
      expect(previewChunk.load()).toBe(previewChunk.load());
    });
  });

  describe('the preview on a served page', () => {
    // No boundary at all rather than no failed one: once an earlier test has
    // fetched the chunk, a boundary around it renders, and a check for the
    // failure marker alone would pass for the wrong reason.
    it('leaves nothing in a server render for the browser to finish', () => {
      const html = renderToString(<Image src={OK} alt="A ridge" preview />);

      expect(html).not.toContain('<!--$');
      expect(html).not.toContain('<template');
    });

    it('hydrates without an error and opens on the first press', async () => {
      const page = await serve(<Image src={OK} alt="A ridge" preview />);

      try {
        expect(page.recoverable).not.toHaveBeenCalled();

        (page.host.querySelector('button') as HTMLButtonElement).click();

        await expect
          .poll(() => document.querySelector('[role="dialog"]')?.getAttribute('aria-labelledby'))
          .toBeTruthy();
      } finally {
        page.done();
      }
    });
  });

  it('opens from the keyboard on the first press and hands the focus back', async () => {
    const screen = await render(<Image src={OK} alt="A ridge" preview />);
    const button = screen.getByRole('button', { name: 'A ridge' });

    (button.element() as HTMLElement).focus();
    await userEvent.keyboard('{Enter}');

    const dialog = screen.getByRole('dialog', { name: 'A ridge' });

    await expect.element(dialog).toBeInTheDocument();
    await expect.poll(() => dialog.element().contains(document.activeElement)).toBe(true);

    await userEvent.keyboard('{Escape}');

    await expect.element(dialog).not.toBeInTheDocument();
    await expect.element(button).toHaveFocus();
  });

  // The preview took only `src`, so a picture given a `srcSet` alone opened an
  // empty dialog, and one behind a CORS rule was fetched again without it.
  it('opens the preview from the same sources and request settings', async () => {
    const screen = await render(
      <Image
        srcSet={`${OK} 1x`}
        sizes="120px"
        crossOrigin="anonymous"
        referrerPolicy="no-referrer"
        alt="A ridge"
        preview
      />
    );

    await screen.getByRole('button', { name: 'A ridge' }).click();

    const dialog = screen.getByRole('dialog', { name: 'A ridge' });
    await expect.element(dialog).toBeInTheDocument();

    const enlarged = dialog.element().querySelector('img') as HTMLImageElement;

    expect(enlarged.getAttribute('srcset')).toBe(`${OK} 1x`);
    expect(enlarged.getAttribute('crossorigin')).toBe('anonymous');
    expect(enlarged.getAttribute('referrerpolicy')).toBe('no-referrer');
    // The thumbnail's `sizes` would choose the thumbnail's candidate.
    expect(enlarged.hasAttribute('sizes')).toBe(false);
  });

  it('is not a button without preview', async () => {
    const screen = await render(<Image src={OK} alt="A ridge" />);

    expect(screen.getByRole('button').query()).toBeNull();
  });

  describe('filter', () => {
    it('names the CSS a named filter stands for', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" filter="grayscale" />);
      const picture = screen.container.querySelector('img') as HTMLImageElement;

      expect(picture.style.filter).toBe('grayscale(1)');
    });

    it('passes a chain of its own straight through', async () => {
      const screen = await render(
        <Image src={OK} alt="A ridge" filter="hue-rotate(40deg) contrast(1.1)" />
      );
      const picture = screen.container.querySelector('img') as HTMLImageElement;

      expect(picture.style.filter).toBe('hue-rotate(40deg) contrast(1.1)');
    });

    // The fade and the treatment ride one declaration, so a filter a caller
    // changes under the pointer travels rather than snapping.
    it('travels on the same transition as the fade', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" filter="sepia" />);
      const picture = screen.container.querySelector('img') as HTMLImageElement;

      expect(picture.className).toContain('transition:opacity');
      expect(picture.className).toContain('filter_var(--neba-duration-fill)');
    });

    it('writes nothing at all when it is none', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" />);
      const picture = screen.container.querySelector('img') as HTMLImageElement;

      expect(picture.style.filter).toBe('');
    });
  });

  describe('letterbox', () => {
    const picturesIn = (container: HTMLElement) =>
      Array.from(container.querySelectorAll('img')) as HTMLImageElement[];

    it('draws nothing by default', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" fit="contain" />);
      const [picture] = picturesIn(screen.container);

      expect(picturesIn(screen.container)).toHaveLength(1);
      expect(picture.parentElement?.style.background).toBe('');
    });

    it('paints a CSS background behind the picture', async () => {
      const screen = await render(
        <Image src={OK} alt="A ridge" fit="contain" letterbox="rgb(10, 20, 30)" />
      );
      const [picture] = picturesIn(screen.container);

      expect(picturesIn(screen.container)).toHaveLength(1);
      expect(picture.parentElement?.style.background).toContain('rgb(10, 20, 30)');
    });

    /*
     * The copy is decoration and nothing else: out of the accessibility tree,
     * out of the pointer's way, and drawn from exactly what the picture is drawn
     * from so it is the same request.
     */
    it('draws the picture blurred behind itself', async () => {
      const screen = await render(
        <Image
          src={OK}
          srcSet={`${OK} 1x`}
          alt="A ridge"
          fit="contain"
          letterbox="blur"
          loading="lazy"
        />
      );
      const [copy, picture] = picturesIn(screen.container);

      expect(picturesIn(screen.container)).toHaveLength(2);
      await expect.element(screen.getByRole('img', { name: 'A ridge' })).toBeInTheDocument();
      expect(copy).toHaveAttribute('aria-hidden', 'true');
      expect(copy).toHaveAttribute('alt', '');
      expect(copy).toHaveAttribute('srcset', `${OK} 1x`);
      expect(copy).toHaveAttribute('loading', 'lazy');
      expect(copy).toHaveClass('pointer-events-none', 'object-cover');
      expect(copy.style.filter).toContain('blur(');
      // Positioned, so the picture paints over the copy rather than under it.
      expect(picture).toHaveClass('relative');
    });

    // The copy comes before the picture, so it is the `<img>` a browser meets
    // first and the one React 19 preloads from: a `priority` picture was
    // preloaded and fetched at the low priority of its blurred backdrop.
    it('asks for the copy as urgently as the picture', async () => {
      const screen = await render(
        <Image src={OK} alt="A ridge" fit="contain" letterbox="blur" priority />
      );
      const [copy] = picturesIn(screen.container);

      expect(copy).toHaveAttribute('aria-hidden', 'true');
      expect(copy).toHaveAttribute('loading', 'eager');
      expect(copy.getAttribute('fetchpriority')).toBe('high');
    });

    it('preloads a priority picture at high priority on a server', () => {
      const html = renderToString(
        <Image src="/ridge.jpg" alt="A ridge" fit="contain" letterbox="blur" priority />
      );
      const preloads = new DOMParser()
        .parseFromString(html, 'text/html')
        .querySelectorAll('link[rel="preload"][as="image"]');

      // React 18 preloads nothing on its own, and has nothing to get wrong.
      for (const preload of preloads) {
        expect(preload.getAttribute('fetchpriority')).toBe('high');
      }

      if (Number.parseInt(React.version, 10) >= 19) {
        expect(preloads).toHaveLength(1);
      }
    });

    it('draws no copy where the fit leaves no space for one', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" letterbox="blur" />);

      expect(picturesIn(screen.container)).toHaveLength(1);
    });

    it('turns, mirrors and tints the copy with the picture', async () => {
      const screen = await render(
        <Image
          src={OK}
          alt="A ridge"
          ratio={1}
          fit="contain"
          letterbox="blur"
          filter="grayscale"
          rotate={90}
          flip="vertical"
        />
      );
      const [copy, picture] = picturesIn(screen.container);

      expect(copy.style.rotate).toBe(picture.style.rotate);
      expect(copy.style.scale).toBe(picture.style.scale);
      expect(copy.style.filter).toContain('grayscale(1)');
      // Grown past the box, so the blur's transparent fringe is clipped away.
      expect(copy.style.width).toContain('100cqh');
      expect(copy.style.width).toContain('+');
    });
  });

  describe('rotate and flip', () => {
    /** A file twice as wide as it is tall, so a turn has a shape to change. */
    const WIDE =
      "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='40' height='20'%3E%3C/svg%3E";

    const pictureIn = (container: HTMLElement) =>
      container.querySelector('img') as HTMLImageElement;

    // A browser writes a uniform `scale` back as one number, so `-1 -1` reads
    // `-1`; spelled out, both axes can be compared.
    const scaleOf = (picture: HTMLImageElement) => {
      const [x, y = x] = picture.style.scale.split(' ');

      return `${x} ${y}`;
    };

    it('writes nothing at all when neither is asked for', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" />);
      const picture = pictureIn(screen.container);

      expect(picture.style.scale).toBe('');
      expect(picture.style.rotate).toBe('');
      expect(picture.parentElement?.style.containerType).toBe('');
    });

    it('mirrors along the axis it names', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" flip="horizontal" />);

      expect(scaleOf(pictureIn(screen.container))).toBe('-1 1');

      await screen.rerender(<Image src={OK} alt="A ridge" flip="vertical" />);
      expect(scaleOf(pictureIn(screen.container))).toBe('1 -1');

      await screen.rerender(<Image src={OK} alt="A ridge" flip="both" />);
      expect(scaleOf(pictureIn(screen.container))).toBe('-1 -1');
    });

    /*
     * The individual properties rather than `transform`, so a Gallery's zoom —
     * which is a `transform` class on the same element — still applies on top.
     */
    it('turns on the rotate property and leaves transform alone', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" rotate={180} />);
      const picture = pictureIn(screen.container);

      expect(picture.style.rotate).toBe('180deg');
      expect(picture.style.transform).toBe('');
      // Upside down is the same footprint, so the picture stays in the flow.
      expect(picture.style.position).toBe('');
    });

    it('reads any number as the nearest quarter turn', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" rotate={-90 as 270} />);

      expect(pictureIn(screen.container).style.rotate).toBe('270deg');

      await screen.rerender(<Image src={OK} alt="A ridge" rotate={450 as 90} />);
      expect(pictureIn(screen.container).style.rotate).toBe('90deg');
    });

    /*
     * Scale is applied before rotate, so on its side a mirror along the
     * picture's own horizontal axis would come out as a vertical one on the
     * screen. What a caller wrote is what the screen does.
     */
    it('mirrors along the screen rather than the file once on its side', async () => {
      const screen = await render(
        <Image src={OK} alt="A ridge" ratio={1} rotate={90} flip="horizontal" />
      );

      expect(scaleOf(pictureIn(screen.container))).toBe('1 -1');
    });

    /*
     * Laid out at the box's height by its width and turned into place, which is
     * what lets `fit` work on its side at all. No component test loads the
     * stylesheet, so this reads the declarations rather than measuring the
     * result.
     */
    it('lays a picture on its side out at the swapped size of its box', async () => {
      const screen = await render(<Image src={WIDE} alt="A ridge" ratio="3 / 2" rotate={90} />);
      const picture = pictureIn(screen.container);

      expect(picture.parentElement?.style.containerType).toBe('size');
      expect(picture.style.position).toBe('absolute');
      expect(picture.style.width).toBe('100cqh');
      expect(picture.style.height).toBe('100cqw');
      expect(picture.style.translate).toBe('-50% -50%');
      // Every reset caps an img at its parent's width, which on a tall box is
      // shorter than the turned picture's length.
      expect(picture.style.maxWidth).toBe('none');
    });

    it('reserves the turned shape of the file it was told about', async () => {
      const screen = await render(
        <Image src={OK} alt="A ridge" width={1200} height={800} rotate={270} />
      );
      const framed = screen.container.querySelector<HTMLElement>('[style*="aspect-ratio"]');

      expect(ratioOf(framed)).toBeCloseTo(800 / 1200);
    });

    it('takes the turned shape of a file nobody described, once it arrives', async () => {
      const screen = await render(<Image src={WIDE} alt="A ridge" rotate={90} />);

      await vi.waitFor(() => {
        const framed = screen.container.querySelector<HTMLElement>('[style*="aspect-ratio"]');

        expect(ratioOf(framed)).toBeCloseTo(20 / 40);
      });
    });

    it('carries the turn and the mirror into the preview', async () => {
      const screen = await render(
        <Image src={OK} alt="A ridge" preview rotate={180} flip="horizontal" />
      );

      await screen.getByRole('button', { name: 'A ridge' }).click();

      const dialog = screen.getByRole('dialog', { name: 'A ridge' });
      await expect.element(dialog).toBeInTheDocument();

      const enlarged = dialog.element().querySelector('img') as HTMLImageElement;

      expect(enlarged.style.rotate).toBe('180deg');
      expect(enlarged.style.scale).toBe('-1 1');
    });

    it('gives the preview a box of the turned shape when it is on its side', async () => {
      const screen = await render(<Image src={WIDE} alt="A ridge" preview rotate={90} />);
      const picture = pictureIn(screen.container);

      await vi.waitFor(() => expect(picture).toHaveClass('opacity-100'));
      await screen.getByRole('button', { name: 'A ridge' }).click();

      const dialog = screen.getByRole('dialog', { name: 'A ridge' });
      await expect.element(dialog).toBeInTheDocument();

      const enlarged = dialog.element().querySelector('img') as HTMLImageElement;

      expect(enlarged.parentElement?.style.containerType).toBe('size');
      expect(ratioOf(enlarged.parentElement)).toBeCloseTo(20 / 40);
    });
  });

  describe('frame', () => {
    // An Image with no frame is the two elements it has always been. The mount
    // is drawn only for a caller who asked for one.
    it('draws no extra element without one', async () => {
      const plain = await render(<Image src={OK} alt="A ridge" data-testid="plain" />);
      const before = plain.container.querySelectorAll('span').length;

      await plain.rerender(<Image src={OK} alt="A ridge" frame="circle" data-testid="plain" />);

      expect(plain.container.querySelectorAll('span').length).toBe(before + 1);
    });

    it('cuts the silhouette a shape names', async () => {
      const screen = await render(
        <Image src={OK} alt="A ridge" frame="circle" classNames={{ frame: 'mount' }} />
      );
      const mount = screen.container.querySelector('.mount') as HTMLElement;

      expect(mount.style.borderRadius).toBe('50%');
    });

    it('chamfers a cut corner with a clip path, which a radius cannot', async () => {
      const screen = await render(
        <Image
          src={OK}
          alt="A ridge"
          frame={{ shape: 'cut', corner: 12 }}
          classNames={{ frame: 'mount' }}
        />
      );
      const mount = screen.container.querySelector('.mount') as HTMLElement;

      expect(mount.style.clipPath).toContain('polygon(12px 0');
    });

    /*
     * The line is an inset shadow rather than a border — which is what lets it
     * follow a cut corner or a circle, and what keeps it out of the layout —
     * and it is on a layer over the picture rather than on the mount itself. An
     * inset shadow paints under its own box's content, so on a frame with no
     * `mat` the picture covers the whole element and the line goes with it.
     */
    it('draws the line over the picture and the shadow under the mount', async () => {
      const screen = await render(
        <Image
          src={OK}
          alt="A ridge"
          frame={{ border: 2, borderColor: 'red', elevation: 2 }}
          classNames={{ frame: 'mount' }}
        />
      );
      const mount = screen.container.querySelector('.mount') as HTMLElement;
      const ring = mount.lastElementChild as HTMLElement;

      expect(mount.style.boxShadow).toBe('var(--neba-shadow-2)');
      // Normalized by the browser, which reorders the shadow's parts.
      expect(ring.style.boxShadow).toContain('inset');
      expect(ring.style.boxShadow).toContain('2px');
      expect(ring.style.boxShadow).toContain('red');
      expect(ring).toHaveAttribute('aria-hidden', 'true');
    });

    it('takes the corner from rounded when the frame does not say', async () => {
      const screen = await render(
        <Image src={OK} alt="A ridge" rounded="xl" frame={{}} classNames={{ frame: 'mount' }} />
      );
      const mount = screen.container.querySelector('.mount') as HTMLElement;

      expect(mount.style.borderRadius).toBe('var(--neba-radius-xl)');
    });
  });

  describe('watermark', () => {
    it('draws a string as a mark the picture keeps to itself', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" watermark="© Neba" />);
      const mark = screen.getByText('© Neba').element();

      // Out of the accessibility tree and out of the way of the pointer: what
      // it says belongs in the `alt`, not read twice.
      expect(mark.closest('[aria-hidden="true"]')).not.toBeNull();
      expect(mark.parentElement).toHaveClass('pointer-events-none');
    });

    it('tiles it instead when it is asked to repeat', async () => {
      const screen = await render(
        <Image
          src={OK}
          alt="A ridge"
          watermark={{ content: 'PROOF', repeat: true }}
          classNames={{ watermark: 'mark' }}
        />
      );
      const mark = screen.container.querySelector('.mark') as SVGSVGElement;
      const pattern = mark.querySelector('pattern') as SVGPatternElement;

      expect(mark.closest('[aria-hidden="true"]')).not.toBeNull();
      expect(pattern.querySelector('text')?.textContent).toBe('PROOF');
      expect(mark.querySelector('rect')?.getAttribute('fill')).toBe(`url(#${pattern.id})`);
      // The tile is sized in ems, and a browser that could not read them would
      // resolve it to nothing and draw no mark at all.
      expect(pattern.width.baseVal.value).toBeGreaterThan(0);
      // Turned as a whole layer rather than per tile, so the tiling has no seam.
      expect(mark.style.transform).toBe('rotate(-24deg)');
    });

    // It was a data URI, a document of its own where the token resolved to
    // nothing, so the mark drew black.
    it('draws a tiled mark in a colour token', async () => {
      const screen = await render(
        <div style={{ '--probe': 'rgb(1, 2, 3)' } as React.CSSProperties}>
          <Image
            src={OK}
            alt="A ridge"
            watermark={{ content: 'PROOF', repeat: true, color: 'var(--probe)' }}
            classNames={{ watermark: 'mark' }}
          />
        </div>
      );
      const text = screen.container.querySelector('.mark text') as SVGTextElement;

      expect(getComputedStyle(text).fill).toBe('rgb(1, 2, 3)');
    });

    it('places a node once rather than trying to tile it', async () => {
      const screen = await render(
        <Image
          src={OK}
          alt="A ridge"
          watermark={{ content: <b>Neba</b>, repeat: true }}
          classNames={{ watermark: 'mark' }}
        />
      );
      const mark = screen.container.querySelector('.mark') as HTMLElement;

      expect(mark.style.backgroundImage).toBe('');
      await expect.element(screen.getByText('Neba')).toBeInTheDocument();
    });
  });

  describe('protect', () => {
    it('takes the picture out of a drag and a selection', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" protect />);
      const picture = screen.container.querySelector('img') as HTMLImageElement;

      expect(picture).toHaveAttribute('draggable', 'false');
      expect(picture).toHaveClass('select-none');
      /*
       * `-webkit-touch-callout: none` goes on with them and is the one that
       * matters most on a phone — without it a long press offers "Save Image"
       * whatever the context menu was told. It is not asserted here because it
       * cannot be: the property is WebKit's alone, and every other engine drops
       * it out of the CSSOM on the way in, so the assertion would be a test of
       * which browser the suite happened to run in.
       */
    });

    it('swallows the context menu', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" protect />);
      const picture = screen.container.querySelector('img') as HTMLImageElement;
      const event = new MouseEvent('contextmenu', { bubbles: true, cancelable: true });

      picture.dispatchEvent(event);

      expect(event.defaultPrevented).toBe(true);
    });

    it('keeps swallowing the context menu when a caller listens for it', async () => {
      const onContextMenu = vi.fn();
      const screen = await render(
        <Image src={OK} alt="A ridge" protect onContextMenu={onContextMenu} />
      );
      const picture = screen.container.querySelector('img') as HTMLImageElement;
      const event = new MouseEvent('contextmenu', { bubbles: true, cancelable: true });

      picture.dispatchEvent(event);

      expect(event.defaultPrevented).toBe(true);
      expect(onContextMenu).toHaveBeenCalled();
      expect(picture).toHaveAttribute('draggable', 'false');
    });

    it('leaves the parts it was told to leave', async () => {
      const screen = await render(
        <Image src={OK} alt="A ridge" protect={{ select: false, drag: false }} />
      );
      const picture = screen.container.querySelector('img') as HTMLImageElement;

      expect(picture).not.toHaveClass('select-none');
      expect(picture).not.toHaveAttribute('draggable');
    });

    it('does none of it by default', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" />);
      const picture = screen.container.querySelector('img') as HTMLImageElement;
      const event = new MouseEvent('contextmenu', { bubbles: true, cancelable: true });

      picture.dispatchEvent(event);

      expect(event.defaultPrevented).toBe(false);
      expect(picture).not.toHaveAttribute('draggable');
    });
  });

  it('keeps the class names it was handed, on the root and on the parts', async () => {
    const screen = await render(
      <Image
        src={OK}
        alt="A ridge"
        className="my-own-class"
        classNames={{ image: 'my-image-class' }}
      />
    );

    expect(screen.container.querySelector('.my-own-class')).not.toBeNull();
    await expect
      .element(screen.getByRole('img', { name: 'A ridge' }))
      .toHaveClass('my-image-class');
  });

  it('passes an unknown prop through to the img', async () => {
    const screen = await render(<Image src={OK} alt="A ridge" data-analytics="hero" />);

    expect(screen.container.querySelector('img[data-analytics="hero"]')).not.toBeNull();
  });

  // A picture that loaded before hydration is asked after the fact, and the
  // question was only put to one with a `src`: given only a `srcSet`, it was
  // never reported as loaded and kept its placeholder for good. A served
  // picture is drawn whether or not the question is asked, so what is asserted
  // is the answer.
  it('settles a picture given only a srcSet that loaded before hydration', async () => {
    const onLoadingStatusChange = vi.fn();
    const element = (
      <Image srcSet={`${OK} 1x`} alt="A ridge" onLoadingStatusChange={onLoadingStatusChange} />
    );
    const host = document.createElement('div');

    host.innerHTML = renderToString(element);
    document.body.append(host);

    const served = host.querySelector('img') as HTMLImageElement;

    await vi.waitFor(() => expect(served.complete && served.naturalWidth > 0).toBe(true));

    const root = hydrateRoot(host, element);

    try {
      await vi.waitFor(() => expect(onLoadingStatusChange).toHaveBeenCalledWith('loaded'));
      expect(host.querySelector('img')).toHaveClass('opacity-100');
    } finally {
      root.unmount();
      host.remove();
    }
  });

  /*
   * A served picture that waited for hydration to lift its cover was a page
   * whose largest picture could not count as painted until the JavaScript had
   * run, and one that never showed at all with the JavaScript off. Each is held
   * in the loading phase with no `src`, which is the phase a server render is
   * always in.
   */
  describe('a picture the server sent', () => {
    it('is never hidden, before hydration or after', async () => {
      const page = await serve(<Image alt="A ridge" ratio={1} />);

      try {
        expect(page.before.querySelector('img')).toHaveClass('opacity-100');
        expect(page.before.querySelector('img')).not.toHaveClass('opacity-0');
        expect(page.host.querySelector('img')).toHaveClass('opacity-100');
        expect(page.host.querySelector('img')).not.toHaveClass('opacity-0');
        expect(page.recoverable).not.toHaveBeenCalled();
      } finally {
        page.done();
      }
    });

    // An `<img>` paints nothing until it has a file, so a placeholder under it
    // shows until the file arrives and is covered the moment it does.
    it('draws its placeholder under the picture rather than over it', async () => {
      const page = await serve(
        <Image alt="A ridge" ratio={1} classNames={{ placeholder: 'wait' }} />
      );

      try {
        for (const html of [page.before, page.host]) {
          const placeholder = html.querySelector('.wait') as HTMLElement;
          const picture = html.querySelector('img') as HTMLImageElement;

          expect(placeholder.compareDocumentPosition(picture)).toBe(
            Node.DOCUMENT_POSITION_FOLLOWING
          );
          // Positioned, so it paints over the absolutely positioned layer
          // before it rather than beneath it.
          expect(picture).toHaveClass('relative');
        }
      } finally {
        page.done();
      }
    });

    it('draws its blurred copy and its stand-in picture unhidden, under it', async () => {
      const page = await serve(
        <Image
          src={OK}
          alt="A ridge"
          ratio={1}
          fit="contain"
          letterbox="blur"
          placeholder={{ src: OK }}
        />
      );

      try {
        const [copy, standIn, picture] = [...page.before.querySelectorAll('img')];

        expect(copy).toHaveClass('opacity-100');
        expect(standIn).toHaveClass('opacity-100');
        expect(picture).toHaveAttribute('alt', 'A ridge');
        expect(picture).toHaveClass('opacity-100', 'relative');
      } finally {
        page.done();
      }
    });

    // A picture first mounted in the browser is hidden by the same script that
    // lifts the cover, so it keeps its fade and the placeholder over it.
    it('still fades in where it was first mounted in the browser', async () => {
      const screen = await render(
        <Image alt="A ridge" ratio={1} classNames={{ placeholder: 'wait' }} />
      );
      const placeholder = screen.container.querySelector('.wait') as HTMLElement;
      const picture = screen.container.querySelector('img') as HTMLImageElement;

      expect(picture).toHaveClass('opacity-0');
      expect(picture.compareDocumentPosition(placeholder)).toBe(Node.DOCUMENT_POSITION_FOLLOWING);
    });

    it('still draws the fallback over a served picture that fails', async () => {
      const page = await serve(
        <Image src={BROKEN} alt="A ridge" ratio={1} classNames={{ fallback: 'broke' }} />
      );

      try {
        await vi.waitFor(() => expect(page.host.querySelector('.broke')).not.toBeNull());

        const fallback = page.host.querySelector('.broke') as HTMLElement;
        const picture = page.host.querySelector('img') as HTMLImageElement;

        expect(fallback).toHaveTextContent('A ridge');
        expect(picture.compareDocumentPosition(fallback)).toBe(Node.DOCUMENT_POSITION_FOLLOWING);
      } finally {
        page.done();
      }
    });
  });

  /*
   * React 18 sets an element's attributes in the order its props were
   * written, and Firefox and Safari start the request the moment `src` is set:
   * a `loading="lazy"`, a `srcset` or a `crossorigin` written after it is read
   * too late, and the full file is already on its way.
   */
  describe('the order of the request', () => {
    const lazy = {
      src: '/ridge.jpg',
      srcSet: '/ridge-640.jpg 640w, /ridge-1280.jpg 1280w',
      sizes: '50vw',
      loading: 'lazy',
      decoding: 'async',
      fetchPriority: 'low',
      crossOrigin: 'anonymous',
      referrerPolicy: 'no-referrer'
    } as const;

    const expectSourcesLast = (names: string[], before: string[]) => {
      expect(names.at(-1)).toBe('src');
      expect(names.at(-2)).toBe('srcset');

      for (const name of before) {
        expect(names, name).toContain(name);
        expect(names.indexOf(name), name).toBeLessThan(names.indexOf('srcset'));
      }
    };

    it('writes src last on the picture, after everything that shapes the request', () => {
      const html = renderToString(<Image {...lazy} alt="A ridge" />);

      expectSourcesLast(attributesIn(html, 'img[alt="A ridge"]'), [
        'loading',
        'decoding',
        'fetchpriority',
        'sizes',
        'crossorigin',
        'referrerpolicy'
      ]);
    });

    // Written whether the caller spelled them out or `priority` implied them.
    it('writes src last on a priority picture', () => {
      const html = renderToString(
        <Image src="/ridge.jpg" srcSet="/ridge.jpg 1x" alt="A ridge" priority />
      );

      expectSourcesLast(attributesIn(html, 'img[alt="A ridge"]'), ['loading', 'fetchpriority']);
    });

    it('writes src last on the blurred copy', () => {
      const html = renderToString(<Image {...lazy} alt="A ridge" fit="contain" letterbox="blur" />);

      expectSourcesLast(attributesIn(html, 'img[alt=""]'), [
        'loading',
        'decoding',
        'fetchpriority',
        'sizes',
        'crossorigin',
        'referrerpolicy'
      ]);
    });

    it('writes src last on a picture placeholder', () => {
      const html = renderToString(
        <Image src="/ridge.jpg" alt="A ridge" loading="lazy" placeholder={{ src: '/tiny.jpg' }} />
      );
      const names = attributesIn(html, 'img[alt=""]');

      expect(names.at(-1)).toBe('src');
      expect(names.indexOf('loading')).toBeGreaterThan(-1);
      expect(names.indexOf('loading')).toBeLessThan(names.indexOf('src'));
    });
  });

  // A Markdown renderer puts an Image inside a `<p>`, where the `<div>` its
  // proportion box and its placeholder were drawn in is a hydration error.
  describe('inside a paragraph', () => {
    it('draws no block element while it loads, with or without a ratio', () => {
      const html = renderToString(
        <p>
          <Image src="/cliff.jpg" alt="A cliff" ratio={4 / 3} />
          <Image src="/ridge.jpg" alt="A ridge" width={320} height={240} />
        </p>
      );

      expect(html).toContain('<img');
      expect(html).not.toContain('<div');
    });
  });
});
