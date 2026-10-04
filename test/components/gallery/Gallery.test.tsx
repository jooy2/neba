/**
 * A Gallery is four layouts over one list, and what is worth testing is the
 * arithmetic each of them does before anything has loaded — the spans, the flex
 * proportions, the column a masonry deals an item into. None of it measures the
 * DOM, so all of it can be asserted on the markup.
 *
 * The sources are data URIs so nothing depends on the network.
 */
import type * as React from 'react';
import { describe, expect, it, vi } from 'vitest';
import { renderToString } from 'react-dom/server';
import { hydrateRoot } from 'react-dom/client';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
import { Gallery, type NebaGalleryItem } from 'neba';
import { viewerChunk } from '../../../src/components/gallery/Gallery.js';

const OK = 'data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==';

const items: NebaGalleryItem[] = [
  { src: `${OK}#1`, alt: 'A ridge', title: 'Ridge', description: 'Dawn', ratio: '3 / 2' },
  { src: `${OK}#2`, alt: 'A cliff', title: 'Cliff', ratio: '2 / 3' },
  { src: `${OK}#3`, alt: 'A bowl', title: 'Bowl', ratio: 1 },
  { src: `${OK}#4`, alt: 'A field', ratio: '3 / 2' }
];

/** The tiles, in the order the list holds them. */
function tiles(container: HTMLElement) {
  return [...container.querySelectorAll('li[class*="group/tile"]')] as HTMLElement[];
}

describe('Gallery', () => {
  describe('rendering', () => {
    it('is a named list of the pictures it was given', async () => {
      const screen = await render(<Gallery items={items} label="Field notes" />);

      await expect.element(screen.getByRole('list', { name: 'Field notes' })).toBeInTheDocument();
      expect(tiles(screen.container)).toHaveLength(4);
    });

    it("falls back to the locale's word when it is not named", async () => {
      const screen = await render(<Gallery items={items} />);

      await expect.element(screen.getByRole('list', { name: 'Gallery' })).toBeInTheDocument();
    });

    it('draws every picture with its own alt', async () => {
      const screen = await render(<Gallery items={items} />);

      await expect.element(screen.getByRole('img', { name: 'A cliff' })).toBeInTheDocument();
    });

    it('draws nothing but the empty state for an empty set', async () => {
      const screen = await render(<Gallery items={[]} empty={<p>No pictures</p>} />);

      await expect.element(screen.getByText('No pictures')).toBeInTheDocument();
      expect(screen.getByRole('list').query()).toBeNull();
    });

    it('keeps the class names it was handed, on the root and on the parts', async () => {
      const screen = await render(
        <Gallery
          items={items}
          className="my-own-class"
          classNames={{ item: 'my-item', title: 'my-title' }}
          caption="below"
        />
      );

      expect(screen.container.querySelector('ul')).toHaveClass('my-own-class');
      expect(screen.container.querySelector('.my-item')).not.toBeNull();
      expect(screen.container.querySelector('.my-title')).not.toBeNull();
    });
  });

  describe('layout', () => {
    /*
     * A contact sheet is a contact sheet: `grid` gives every tile the Gallery's
     * own `ratio` whatever shape the file is, which is the whole difference
     * between it and a masonry.
     */
    it('grid holds one shape whatever shape the files are', async () => {
      const screen = await render(<Gallery items={items} ratio="4 / 3" columns={2} />);
      const boxes = screen.container.querySelectorAll('[style*="aspect-ratio"]');

      expect(boxes).toHaveLength(4);
      for (const box of boxes) {
        expect((box as HTMLElement).style.aspectRatio).toBe('4 / 3');
      }
    });

    it('masonry keeps each picture in its own proportion', async () => {
      const screen = await render(<Gallery items={items} layout="masonry" columns={2} />);
      const shapes = [...screen.container.querySelectorAll('[style*="aspect-ratio"]')].map(
        (box) => (box as HTMLElement).style.aspectRatio
      );

      expect(shapes).toContain('3 / 2');
      expect(shapes).toContain('2 / 3');
    });

    /*
     * Dealt shortest column first rather than filled one column at a time, so
     * the first row a reader meets is the first pictures they were given. With
     * two lanes and a 3:2 leading, the second item lands in the empty lane.
     */
    it('masonry deals into the shortest column rather than down the first', async () => {
      const screen = await render(<Gallery items={items} layout="masonry" columns={2} />);
      const lanes = [...screen.container.querySelectorAll('ul ul')];

      expect(lanes).toHaveLength(2);
      expect(lanes[0].querySelector('img')?.getAttribute('alt')).toBe('A ridge');
      expect(lanes[1].querySelector('img')?.getAttribute('alt')).toBe('A cliff');
    });

    /*
     * A server does not know how wide the window is, so it dealt for the
     * narrowest width and the page redrew itself into more columns as it
     * hydrated, moving every tile on it. Until hydration it draws one deal per
     * width the columns change at, each behind the classes that show it only
     * there; afterwards only the reader's is left, as the same elements.
     */
    it('server-renders a masonry deal for every width its columns change at', () => {
      const html = renderToString(
        <Gallery items={items} layout="masonry" columns={{ xs: 2, md: 3, lg: 4 }} />
      );
      const host = document.createElement('div');

      host.innerHTML = html;

      expect(host.querySelectorAll('ul ul')).toHaveLength(2 + 3 + 4);
      expect(host.querySelectorAll('.md\\:hidden')).toHaveLength(2);
      expect(host.querySelectorAll('.max-md\\:hidden.lg\\:hidden')).toHaveLength(3);
      expect(host.querySelectorAll('.max-lg\\:hidden')).toHaveLength(4);
    });

    it("keeps only the reader's deal once hydrated, as the elements the server drew", async () => {
      const element = <Gallery items={items} layout="masonry" columns={{ xs: 2, md: 3, lg: 4 }} />;
      const host = document.createElement('div');

      host.innerHTML = renderToString(element);
      document.body.append(host);

      const drawn = new Set(host.querySelectorAll(':scope > ul > li'));
      const expected = matchMedia('(min-width: 64rem)').matches
        ? 4
        : matchMedia('(min-width: 48rem)').matches
          ? 3
          : 2;
      const recoverable = vi.fn();
      const root = hydrateRoot(host, element, { onRecoverableError: recoverable });

      try {
        await vi.waitFor(() => expect(host.querySelectorAll('ul ul')).toHaveLength(expected));

        const kept = [...host.querySelectorAll(':scope > ul > li')];

        expect(kept.every((lane) => drawn.has(lane))).toBe(true);
        expect(kept.some((lane) => /hidden/.test(lane.className))).toBe(false);
        expect(recoverable).not.toHaveBeenCalled();
      } finally {
        root.unmount();
        host.remove();
      }
    });

    it('draws a single deal in a tree that was never server-rendered', async () => {
      const screen = await render(
        <Gallery items={items} layout="masonry" columns={{ xs: 2, md: 3, lg: 4 }} />
      );
      const expected = matchMedia('(min-width: 64rem)').matches
        ? 4
        : matchMedia('(min-width: 48rem)').matches
          ? 3
          : 2;

      expect(screen.container.querySelectorAll('ul ul')).toHaveLength(expected);
    });

    /*
     * Grown and based in proportion to the picture's own width, which is what
     * makes every tile in a row come out the same height once the row has been
     * stretched to the edge. The browser does the arithmetic; nothing here is
     * measured.
     */
    it('justified grows each tile in proportion to its own ratio', async () => {
      const screen = await render(<Gallery items={items} layout="justified" rowHeight={200} />);
      const [first, second] = tiles(screen.container);

      expect(Number(first.style.flexGrow)).toBeCloseTo(1.5);
      expect(first.style.flexBasis).toBe('300px');
      expect(Number(second.style.flexGrow)).toBeCloseTo(0.667, 2);
    });

    it('quilted lets a tile take more than one cell', async () => {
      const screen = await render(
        <Gallery
          items={[{ ...items[0], cols: 2, rows: 2 }, ...items.slice(1)]}
          layout="quilted"
          columns={3}
          rowHeight={120}
        />
      );
      const [first, second] = tiles(screen.container);

      expect(first.style.gridColumn).toBe('span 2');
      expect(first.style.gridRow).toBe('span 2');
      expect(second.style.gridColumn).toBe('span 1');
      expect(screen.container.querySelector('ul')?.style.gridAutoRows).toBe('120px');
    });
  });

  /*
   * An item's `ratio` is the file's, so one turned onto its side has to be laid
   * out on its side by the arithmetic that runs before anything loads — or a
   * masonry would reserve a landscape slot for a portrait and crop it.
   */
  describe('a turned item', () => {
    const turned: NebaGalleryItem[] = [{ ...items[0], rotate: 90 }, ...items.slice(1)];

    it('masonry reserves it on its side', async () => {
      const screen = await render(<Gallery items={turned} layout="masonry" columns={2} />);
      const box = tiles(screen.container)[0].querySelector<HTMLElement>('[style*="aspect-ratio"]');
      const [width, height = '1'] = (box?.style.aspectRatio ?? '').split('/');

      expect(Number(width) / Number(height)).toBeCloseTo(2 / 3);
    });

    it('justified grows it in proportion to its turned width', async () => {
      const screen = await render(<Gallery items={turned} layout="justified" rowHeight={200} />);

      expect(Number(tiles(screen.container)[0].style.flexGrow)).toBeCloseTo(2 / 3);
    });

    it('grid keeps the layout shape and turns the picture inside it', async () => {
      const screen = await render(<Gallery items={turned} ratio={1} />);
      const picture = screen.getByRole('img', { name: 'A ridge' }).element() as HTMLImageElement;

      expect(picture.style.rotate).toBe('90deg');
      expect(picture.closest<HTMLElement>('[style*="aspect-ratio"]')?.style.aspectRatio).toMatch(
        /^1( \/ 1)?$/
      );
    });
  });

  describe('what reaches each picture', () => {
    it('hands an item its own turn, mirror, position and stand-in', async () => {
      const screen = await render(
        <Gallery
          items={[
            {
              ...items[0],
              rotate: 180,
              flip: 'horizontal',
              position: 'top',
              placeholder: { src: OK }
            }
          ]}
        />
      );
      const tile = tiles(screen.container)[0];
      const picture = screen.getByRole('img', { name: 'A ridge' }).element() as HTMLImageElement;

      expect(picture.style.rotate).toBe('180deg');
      expect(picture.style.scale).toBe('-1 1');
      // Read on the picture as it is shown, so through the half turn and the
      // mirror the top of what the reader sees is the bottom of the file.
      expect(picture.style.objectPosition).toBe('50% 100%');
      expect(tile.querySelector('img[aria-hidden="true"]')).toHaveAttribute('src', OK);
    });

    it('hands every picture the fit, the letterbox and the loading', async () => {
      const screen = await render(
        <Gallery items={items} fit="contain" letterbox="blur" loading="eager" />
      );
      const tile = tiles(screen.container)[0];
      const picture = screen.getByRole('img', { name: 'A ridge' }).element();

      expect(picture).toHaveClass('object-contain');
      expect(picture).toHaveAttribute('loading', 'eager');
      expect(tile.querySelectorAll('img')).toHaveLength(2);
    });

    // A wall of photographs asks for the few a reader can see, not all of them.
    it('loads every tile lazily by default', async () => {
      const screen = await render(<Gallery items={items} fit="contain" letterbox="blur" />);

      for (const picture of screen.container.querySelectorAll('img')) {
        expect(picture).toHaveAttribute('loading', 'lazy');
      }
    });

    it('covers each tile by default', async () => {
      const screen = await render(<Gallery items={items} />);

      await expect
        .element(screen.getByRole('img', { name: 'A ridge' }))
        .toHaveClass('object-cover');
    });

    // A gallery above the fold was lazy and faded in, tile by tile, with no way
    // to say which of its pictures the page is judged by.
    it('fetches the first tiles early and draws them unhidden when told how many', async () => {
      const screen = await render(<Gallery items={items} priority={2} />);
      const pictures = items.map(
        (item) => screen.getByRole('img', { name: item.alt }).element() as HTMLImageElement
      );

      for (const picture of pictures.slice(0, 2)) {
        expect(picture).toHaveAttribute('loading', 'eager');
        expect(picture.getAttribute('fetchpriority')).toBe('high');
        expect(picture).toHaveClass('opacity-100');
      }

      for (const picture of pictures.slice(2)) {
        expect(picture).toHaveAttribute('loading', 'lazy');
        expect(picture.getAttribute('fetchpriority')).toBeNull();
      }
    });

    it('prioritises nothing by default', async () => {
      const screen = await render(<Gallery items={items} loading="eager" />);

      for (const picture of screen.container.querySelectorAll('img')) {
        expect(picture.getAttribute('fetchpriority')).toBeNull();
      }
    });

    // A tile drawn 300 pixels wide downloaded the full-size original.
    it("hands a tile's picture the item's own candidates", async () => {
      const screen = await render(
        <Gallery
          items={[{ ...items[0], srcSet: `${OK} 1x, ${OK} 2x`, sizes: '25vw' }, ...items.slice(1)]}
        />
      );
      const picture = screen.getByRole('img', { name: 'A ridge' }).element();

      expect(picture).toHaveAttribute('srcset', `${OK} 1x, ${OK} 2x`);
      expect(picture).toHaveAttribute('sizes', '25vw');
      expect(screen.getByRole('img', { name: 'A cliff' }).element()).not.toHaveAttribute('srcset');
    });
  });

  describe('columns and gap', () => {
    // The column count travels as the `--n-cols` slots the stylesheet cascade
    // reads, which is what lets a breakpoint change it without React hearing.
    it('writes the column count into the slots per breakpoint', async () => {
      const screen = await render(<Gallery items={items} columns={{ xs: 2, md: 5 }} />);
      const list = screen.container.querySelector('ul') as HTMLElement;

      expect(list).toHaveClass('neba-gallery');
      expect(list.style.getPropertyValue('--n-cols-xs')).toBe('2');
      expect(list.style.getPropertyValue('--n-cols-md')).toBe('5');
    });

    // A partial map says "from here up, use this instead" and not "and nothing
    // below", so the default has to survive under the first entry the caller named.
    it('keeps a baseline under a map that starts higher up', async () => {
      const screen = await render(<Gallery items={items} columns={{ md: 5 }} />);
      const list = screen.container.querySelector('ul') as HTMLElement;

      expect(list.style.getPropertyValue('--n-cols-xs')).toBe('2');
    });

    it('takes a gap as a step, a number or a length', async () => {
      const screen = await render(<Gallery items={items} gap="xl" />);
      const list = () => screen.container.querySelector('ul') as HTMLElement;

      expect(list().style.gap).toBe('1rem');

      await screen.rerender(<Gallery items={items} gap={20} />);
      expect(list().style.gap).toBe('20px');

      await screen.rerender(<Gallery items={items} gap="2.5vw" />);
      expect(list().style.gap).toBe('2.5vw');
    });
  });

  describe('caption', () => {
    it('draws none by default', async () => {
      const screen = await render(<Gallery items={items} />);

      expect(screen.getByText('Ridge').query()).toBeNull();
    });

    it('writes the words under the picture', async () => {
      const screen = await render(<Gallery items={items} caption="below" />);

      await expect.element(screen.getByText('Ridge')).toBeInTheDocument();
      await expect.element(screen.getByText('Dawn')).toBeInTheDocument();
    });

    // Drawn from the start and only kept out of sight, so nothing about the
    // tile's size depends on where the pointer is.
    it('keeps a hover caption in the document and hides it', async () => {
      const screen = await render(
        <Gallery items={items} caption="hover" classNames={{ caption: 'legend' }} />
      );
      const legend = screen.container.querySelector('.legend') as HTMLElement;

      expect(legend).toHaveClass('opacity-0');
      expect(legend.className).toContain('group-hover/tile:opacity-100');
      // A touch screen never hovers, so there the caption is always up.
      expect(legend.className).toContain('[@media(hover:none)]:opacity-100');
    });

    // The words on the tile are what a voice-control user says to press it.
    it('names a tile by the caption drawn on it, and its place in the set', async () => {
      const screen = await render(<Gallery items={items} caption="below" preview />);
      const ridge = screen.getByRole('button', { name: 'Ridge Image 1 of 4' });

      await expect.element(ridge).toBeInTheDocument();
      await expect.element(ridge).toHaveAccessibleDescription('Dawn');
      // A tile with no words to draw keeps the picture's own.
      await expect
        .element(screen.getByRole('button', { name: 'A field — Image 4 of 4' }))
        .toBeInTheDocument();
    });

    // Drawn below the picture or over it, the caption is inside the tile's
    // button, which takes phrasing content only — and a `<div>` there is a
    // hydration error waiting on the first page that server-renders it.
    it('draws its caption with phrasing content only, inside the button', async () => {
      for (const caption of ['below', 'overlay'] as const) {
        const screen = await render(<Gallery items={items} caption={caption} preview />);
        const ridge = screen.getByRole('button', { name: 'Ridge Image 1 of 4' });

        await expect.element(ridge).toBeInTheDocument();
        expect(ridge.element().querySelectorAll('div'), caption).toHaveLength(0);
        await screen.unmount();
      }
    });
  });

  describe('hover', () => {
    // Every treatment answers the focus as well as the pointer: a tile that
    // only responds to a pointer responds to half the readers.
    it('answers the focus wherever it answers the pointer', async () => {
      const screen = await render(<Gallery items={items} hover="zoom" preview />);
      const picture = screen.container.querySelector('img') as HTMLImageElement;

      expect(picture.className).toContain('group-hover/tile:[transform:scale(1.06)]');
      // Asked of the tile as `has a focused button`: the tile itself, an `<li>`,
      // never holds the focus, so a plain focus variant on it never applied.
      expect(picture.className).toContain(
        'group-has-[:focus-visible]/tile:[transform:scale(1.06)]'
      );
      expect(picture.className).not.toContain('group-focus-visible/tile');
    });

    // The Gallery wrote a `transition` of its own on the picture beside the
    // Image's, and the Image's won by stylesheet order, so the zoom jumped.
    it('travels on the one transition the picture carries', async () => {
      const screen = await render(<Gallery items={items} hover="zoom" />);
      const picture = screen.container.querySelector('img') as HTMLImageElement;
      const shorthands = [...picture.classList].filter((name) => name.startsWith('[transition:'));

      expect(shorthands).toHaveLength(1);
      expect(shorthands[0]).toContain('transform_');
    });

    it('scales nothing when it is told to do nothing', async () => {
      const screen = await render(<Gallery items={items} hover="none" />);
      const picture = screen.container.querySelector('img') as HTMLImageElement;

      expect(picture.className).not.toContain('scale');
      expect(picture.className).not.toContain('brightness');
    });
  });

  describe('choosing a tile', () => {
    it('draws no button at all when there is nothing to choose', async () => {
      const screen = await render(<Gallery items={items} />);

      expect(screen.getByRole('button').query()).toBeNull();
    });

    it('names a tile by its picture and its place in the set', async () => {
      const screen = await render(<Gallery items={items} preview />);

      await expect
        .element(screen.getByRole('button', { name: 'A cliff — Image 2 of 4' }))
        .toBeInTheDocument();
      // A ring colour with a fallback, since nothing above a Gallery declares one.
      expect(
        screen.getByRole('button', { name: 'A cliff — Image 2 of 4' }).element().className
      ).toContain('var(--n-ring,var(--neba-primary-ring))');
    });

    it('reports the item and its index', async () => {
      const onItemSelect = vi.fn();
      const screen = await render(<Gallery items={items} onItemSelect={onItemSelect} />);

      await screen.getByRole('button', { name: /A bowl/ }).click();

      expect(onItemSelect).toHaveBeenCalledWith(items[2], 2);
    });

    it('says a tile opens a dialog only when it opens the viewer', async () => {
      const screen = await render(<Gallery items={items} preview />);

      await expect
        .element(screen.getByRole('button', { name: /A bowl/ }))
        .toHaveAttribute('aria-haspopup', 'dialog');

      await screen.rerender(<Gallery items={items} onItemSelect={() => {}} />);

      await expect
        .element(screen.getByRole('button', { name: /A bowl/ }))
        .not.toHaveAttribute('aria-haspopup');
    });
  });

  describe('the viewer', () => {
    it('opens the picture that was chosen', async () => {
      const screen = await render(<Gallery items={items} preview />);

      await screen.getByRole('button', { name: /A cliff/ }).click();

      await expect.element(screen.getByRole('dialog', { name: 'Cliff' })).toBeInTheDocument();
      await expect.element(screen.getByText('Image 2 of 4')).toBeInTheDocument();
    });

    it('moves between pictures on the arrow keys', async () => {
      const screen = await render(<Gallery items={items} preview />);

      await screen.getByRole('button', { name: /A ridge/ }).click();
      await expect.element(screen.getByText('Image 1 of 4')).toBeInTheDocument();

      await screen
        .getByRole('dialog')
        .element()
        .dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true }));

      await expect.element(screen.getByText('Image 2 of 4')).toBeInTheDocument();
    });

    // The focus stays on the arrow, so the position was all that was read and
    // never what the picture shows.
    it('says what the picture is as well as where it is', async () => {
      const screen = await render(<Gallery items={items} preview />);

      await screen.getByRole('button', { name: /A ridge/ }).click();
      await expect.element(screen.getByText('Image 1 of 4')).toBeInTheDocument();

      screen
        .getByRole('dialog')
        .element()
        .dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true }));

      await expect
        .poll(() => document.querySelector('[aria-live="polite"][aria-atomic="true"]')?.textContent)
        .toBe('Cliff, Image 2 of 4');
    });

    // The buttons swap sides under RTL and the keys did not follow them.
    it('moves to the next picture on the left arrow under RTL', async () => {
      document.documentElement.dir = 'rtl';

      try {
        const screen = await render(<Gallery items={items} preview />);

        await screen.getByRole('button', { name: /A ridge/ }).click();
        await expect.element(screen.getByText('Image 1 of 4')).toBeInTheDocument();

        screen
          .getByRole('dialog')
          .element()
          .dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowLeft', bubbles: true }));

        await expect.element(screen.getByText('Image 2 of 4')).toBeInTheDocument();
      } finally {
        document.documentElement.removeAttribute('dir');
      }
    });

    // It stops at the ends rather than looping: a gallery is one picture with a
    // way to the next, not a carousel showing a set in order.
    it('stops at the two ends', async () => {
      const screen = await render(<Gallery items={items} preview />);

      await screen.getByRole('button', { name: /A ridge/ }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Previous image' }))
        .toHaveAttribute('aria-disabled', 'true');
      await expect.element(screen.getByRole('button', { name: 'Next image' })).toBeEnabled();
    });

    // Pressing Next onto the last picture disabled the button under the focus,
    // which a dialog hands back to nothing.
    it('keeps the focus on a button the press ran out', async () => {
      const screen = await render(<Gallery items={items} preview />);

      await screen.getByRole('button', { name: /A bowl/ }).click();
      await expect.element(screen.getByText('Image 3 of 4')).toBeInTheDocument();

      const next = screen.getByRole('button', { name: 'Next image' });

      (next.element() as HTMLElement).focus();
      await userEvent.keyboard('{Enter}');

      await expect.element(screen.getByText('Image 4 of 4')).toBeInTheDocument();
      await expect.element(next).toHaveAttribute('aria-disabled', 'true');
      await expect.element(next).toHaveFocus();
    });

    /*
     * Turned, a picture is out of the flow and cannot size the viewer by its
     * own content, so the viewer gives it the turned shape from the item's
     * ratio and a width to hold it.
     */
    it('opens a turned picture turned, in a box of its turned shape', async () => {
      const screen = await render(
        <Gallery items={[{ ...items[0], rotate: 90, flip: 'vertical' }]} preview />
      );

      await screen.getByRole('button', { name: /A ridge/ }).click();

      const dialog = screen.getByRole('dialog').element();

      await vi.waitFor(() => expect(dialog.querySelector('img')).not.toBeNull());

      const picture = dialog.querySelector('img') as HTMLImageElement;
      const box = picture.closest<HTMLElement>('[style*="aspect-ratio"]');
      const [width, height = '1'] = (box?.style.aspectRatio ?? '').split('/');

      expect(picture.style.rotate).toBe('90deg');
      expect(Number(width) / Number(height)).toBeCloseTo(2 / 3);
      // Capped at the height the unturned picture may take, which the browser
      // folds into a single `vh` length.
      expect(box?.style.width).toMatch(/^min\(100%, .*vh\)$/);
    });

    it('opens the larger file when the item has one', async () => {
      const screen = await render(
        <Gallery items={[{ ...items[0], full: `${OK}#full` }]} preview />
      );

      await screen.getByRole('button', { name: /A ridge/ }).click();

      const dialog = screen.getByRole('dialog').element();

      await vi.waitFor(() =>
        expect(dialog.querySelector('img')?.getAttribute('src')).toBe(`${OK}#full`)
      );
    });

    // The candidates go with the picture, and the browser picks one for the
    // viewer's size; the tile's `sizes` would pick the tile's.
    it("opens a picture from the item's candidates when it names no larger file", async () => {
      const srcSet = `${OK}#small 1x, ${OK}#large 2x`;
      const screen = await render(
        <Gallery
          items={[
            { ...items[0], srcSet, sizes: '25vw' },
            { ...items[1], srcSet, full: `${OK}#full` }
          ]}
          preview
        />
      );

      await screen.getByRole('button', { name: /A ridge/ }).click();

      const dialog = screen.getByRole('dialog').element();

      await vi.waitFor(() => expect(dialog.querySelector('img')).not.toBeNull());
      expect(dialog.querySelector('img')).toHaveAttribute('srcset', srcSet);
      expect(dialog.querySelector('img')).not.toHaveAttribute('sizes');

      dialog.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true }));

      // A `full` is the file to show, and a `srcset` beside it would outrank it.
      await vi.waitFor(() =>
        expect(dialog.querySelector('img')?.getAttribute('src')).toBe(`${OK}#full`)
      );
      expect(dialog.querySelector('img')).not.toHaveAttribute('srcset');
    });
  });

  /*
   * The viewer is a lazy chunk, and a lazy component in a server render is a
   * boundary `renderToString` cannot wait for: it gave up and sent a marker for
   * the browser to finish, and React reported that at hydration. The viewer is
   * now mounted by the first press, so a server render has nothing to wait for.
   */
  /*
   * Mounted only by the press, the viewer was downloaded by the press too, and
   * the first picture opened only once the network had answered. The download
   * starts when a reader reaches for the gallery instead, and still nothing is
   * mounted until the press.
   */
  describe('fetching the viewer', () => {
    // Held below where earlier tests left the pointer, so it is not already
    // over the gallery when the gallery appears.
    const below = (child: React.ReactNode) => <div style={{ paddingTop: 320 }}>{child}</div>;

    it('starts when a pointer arrives over the gallery, and not before', async () => {
      const load = vi.spyOn(viewerChunk, 'load');

      try {
        const screen = await render(below(<Gallery items={items} preview />));

        await new Promise(requestAnimationFrame);
        expect(load).not.toHaveBeenCalled();

        await screen.getByRole('list').hover();
        expect(load).toHaveBeenCalledTimes(1);

        // Once per gallery: every reach after the first does nothing.
        (screen.getByRole('button', { name: /A cliff/ }).element() as HTMLElement).focus();
        expect(load).toHaveBeenCalledTimes(1);
        expect(screen.getByRole('dialog').query()).toBeNull();
      } finally {
        load.mockRestore();
      }
    });

    it('starts when the focus reaches a tile', async () => {
      const load = vi.spyOn(viewerChunk, 'load');

      try {
        const screen = await render(below(<Gallery items={items} preview />));

        (screen.getByRole('button', { name: /A bowl/ }).element() as HTMLElement).focus();

        expect(load).toHaveBeenCalledTimes(1);
      } finally {
        load.mockRestore();
      }
    });

    it('is not asked for without a viewer to open', async () => {
      const load = vi.spyOn(viewerChunk, 'load');

      try {
        const screen = await render(below(<Gallery items={items} onItemSelect={() => {}} />));

        await screen.getByRole('list').hover();
        (screen.getByRole('button', { name: /A bowl/ }).element() as HTMLElement).focus();

        expect(load).not.toHaveBeenCalled();
      } finally {
        load.mockRestore();
      }
    });

    it("keeps a caller's own handlers on the list", async () => {
      const onFocus = vi.fn();
      const screen = await render(<Gallery items={items} preview onFocus={onFocus} />);

      (screen.getByRole('button', { name: /A bowl/ }).element() as HTMLElement).focus();

      expect(onFocus).toHaveBeenCalledTimes(1);
    });

    it('is not asked for by a server render, which holds no boundary', () => {
      const load = vi.spyOn(viewerChunk, 'load');

      try {
        const html = renderToString(<Gallery items={items} preview />);

        expect(load).not.toHaveBeenCalled();
        expect(html).not.toContain('<!--$');
      } finally {
        load.mockRestore();
      }
    });

    // The press is handed the request a reach already started, rather than
    // making a second one.
    it('hands every caller the one request', () => {
      expect(viewerChunk.load()).toBe(viewerChunk.load());
    });
  });

  describe('on a served page', () => {
    // No boundary at all rather than no failed one: once an earlier test has
    // fetched the chunk, a boundary around it renders, and a check for the
    // failure marker alone would pass for the wrong reason.
    it('leaves nothing in a server render for the browser to finish', () => {
      const html = renderToString(<Gallery items={items} preview />);

      expect(html).not.toContain('<!--$');
      expect(html).not.toContain('<template');
    });

    it('hydrates without an error and opens on the first press', async () => {
      const element = <Gallery items={items} preview />;
      const host = document.createElement('div');

      host.innerHTML = renderToString(element);
      document.body.append(host);

      const recoverable = vi.fn();
      const root = hydrateRoot(host, element, { onRecoverableError: recoverable });

      try {
        // A tile's press is wired once the page has hydrated.
        await vi.waitFor(() => {
          (host.querySelector('button') as HTMLButtonElement).click();
          expect(document.querySelector('[role="dialog"]')).not.toBeNull();
        });
        expect(recoverable).not.toHaveBeenCalled();
      } finally {
        root.unmount();
        host.remove();
      }
    });
  });
});
