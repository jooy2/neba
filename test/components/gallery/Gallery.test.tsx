/**
 * A Gallery is four layouts over one list, and what is worth testing is the
 * arithmetic each of them does before anything has loaded — the spans, the flex
 * proportions, the column a masonry deals an item into. None of it measures the
 * DOM, so all of it can be asserted on the markup.
 *
 * The sources are data URIs so nothing depends on the network.
 */
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Gallery, type NebaGalleryItem } from 'neba';

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
    });
  });

  describe('hover', () => {
    // Every treatment answers the focus as well as the pointer: a tile that
    // only responds to a pointer responds to half the readers.
    it('answers the focus wherever it answers the pointer', async () => {
      const screen = await render(<Gallery items={items} hover="zoom" preview />);
      const picture = screen.container.querySelector('img') as HTMLImageElement;

      expect(picture.className).toContain('group-hover/tile:[transform:scale(1.06)]');
      expect(picture.className).toContain('group-focus-visible/tile:[transform:scale(1.06)]');
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
    });

    it('reports the item and its index', async () => {
      const onItemSelect = vi.fn();
      const screen = await render(<Gallery items={items} onItemSelect={onItemSelect} />);

      await screen.getByRole('button', { name: /A bowl/ }).click();

      expect(onItemSelect).toHaveBeenCalledWith(items[2], 2);
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

    // It stops at the ends rather than looping: a gallery is one picture with a
    // way to the next, not a carousel showing a set in order.
    it('stops at the two ends', async () => {
      const screen = await render(<Gallery items={items} preview />);

      await screen.getByRole('button', { name: /A ridge/ }).click();

      await expect.element(screen.getByRole('button', { name: 'Previous image' })).toBeDisabled();
      await expect.element(screen.getByRole('button', { name: 'Next image' })).toBeEnabled();
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
  });
});
