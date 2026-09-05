/**
 * The three things an `<img>` does not do — hold its space, say it is loading,
 * say it failed — are the three things worth testing here.
 *
 * The sources are data URIs so nothing depends on the network: a 1×1 GIF that
 * always decodes, and a string that never will.
 */
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Image } from 'neba';

const OK = 'data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==';
const BROKEN = 'data:image/gif;base64,not-a-picture';

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
    /*
     * Read as a number rather than as the string that was written. A browser
     * normalises `aspect-ratio: 1.5` into a `<ratio>` of its own choosing —
     * `1.5 / 1` in Chromium — and the three engines the suite runs on do not
     * have to agree on how they spell it.
     */
    const ratioOf = (element: HTMLElement | null | undefined) => {
      const [left, right = '1'] = (element?.style.aspectRatio ?? '').split('/');

      return Number(left) / Number(right);
    };

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

    // A proportion needs two numbers.
    it('reserves nothing for one on its own', async () => {
      const screen = await render(<Image src={OK} alt="A ridge" width={1200} />);

      expect(screen.container.querySelector('[style*="aspect-ratio"]')).toBeNull();
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

  it('becomes a button when it can be previewed', async () => {
    const screen = await render(<Image src={OK} alt="A ridge" preview />);

    // Reachable by keyboard: a picture that only a pointer can enlarge is one
    // half the readers cannot enlarge.
    await expect.element(screen.getByRole('button', { name: 'A ridge' })).toBeInTheDocument();
  });

  it('opens the full picture when previewed', async () => {
    const screen = await render(<Image src={OK} alt="A ridge" preview />);

    await screen.getByRole('button', { name: 'A ridge' }).click();

    await expect.element(screen.getByRole('dialog', { name: 'A ridge' })).toBeInTheDocument();
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
      const mark = screen.container.querySelector('.mark') as HTMLElement;

      expect(mark.style.backgroundImage).toContain('data:image/svg+xml');
      expect(decodeURIComponent(mark.style.backgroundImage)).toContain('>PROOF<');
      // Turned as a whole layer rather than per tile, so the tiling has no seam.
      expect(mark.style.transform).toBe('rotate(-24deg)');
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
});
