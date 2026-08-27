import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Pagination } from 'neba';
import { ko, registerMessages } from 'neba/locales';

/* The library ships English; a `locale` prop answers for a language the
   project has registered. These assertions are about the prop, so the
   languages they name are registered here the way a consumer would. */
registerMessages('ko', ko);

/** The page buttons, in the order they are rendered. */
function pages(screen: { container: HTMLElement }) {
  return [...screen.container.querySelectorAll('nav button')]
    .map((button) => button.textContent?.trim())
    .filter((text) => text !== '');
}

describe('Pagination', () => {
  describe('rendering', () => {
    it('renders a named navigation landmark holding a list', async () => {
      const screen = await render(<Pagination count={5} />);

      await expect
        .element(screen.getByRole('navigation', { name: 'Pagination' }))
        .toBeInTheDocument();
      await expect.element(screen.getByRole('list')).toBeInTheDocument();
    });

    it('takes the landmark name it is given', async () => {
      const screen = await render(<Pagination count={5} label="Search results" />);

      await expect
        .element(screen.getByRole('navigation', { name: 'Search results' }))
        .toBeInTheDocument();
    });

    // A row that renders a lone disabled "1" is a control advertising that it
    // has nothing to do.
    it('renders nothing when there is only one page', async () => {
      const screen = await render(<Pagination count={1} />);

      expect(screen.getByRole('navigation').query()).toBeNull();
    });

    it('renders nothing when there are no pages', async () => {
      const screen = await render(<Pagination count={0} />);

      expect(screen.getByRole('navigation').query()).toBeNull();
    });

    it('renders every page when they all fit', async () => {
      const screen = await render(<Pagination count={5} showArrows={false} />);

      expect(pages(screen)).toEqual(['1', '2', '3', '4', '5']);
    });

    it('reflects a changed count on re-render', async () => {
      const screen = await render(<Pagination count={3} showArrows={false} />);

      await screen.rerender(<Pagination count={4} showArrows={false} />);

      expect(pages(screen)).toEqual(['1', '2', '3', '4']);
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Pagination count={5} className="my-own-class" />);

      expect(screen.getByRole('navigation').element()).toHaveClass('my-own-class');
    });
  });

  describe('the range it shows', () => {
    it('puts an ellipsis where pages are hidden', async () => {
      const screen = await render(<Pagination count={20} page={10} showArrows={false} />);

      expect(pages(screen)).toEqual(['1', '9', '10', '11', '20']);
      expect(screen.container.textContent).toContain('…');
    });

    it('shows more neighbours when siblingCount is raised', async () => {
      const screen = await render(
        <Pagination count={20} page={10} siblingCount={2} showArrows={false} />
      );

      expect(pages(screen)).toEqual(['1', '8', '9', '10', '11', '12', '20']);
    });

    it('shows more of each end when boundaryCount is raised', async () => {
      const screen = await render(
        <Pagination count={20} page={10} boundaryCount={2} showArrows={false} />
      );

      expect(pages(screen)).toEqual(['1', '2', '9', '10', '11', '19', '20']);
    });

    // `1 … 3 … 9` hides a single number behind a symbol wider than the number
    // it replaced.
    it('fills a gap of exactly one page with the page itself', async () => {
      const screen = await render(<Pagination count={7} page={4} showArrows={false} />);

      expect(pages(screen)).toEqual(['1', '2', '3', '4', '5', '6', '7']);
      expect(screen.container.textContent).not.toContain('…');
    });

    // Walking through the pages must not change how many slots are on the row,
    // or every button under the pointer moves out from under it. A slot may be
    // a page or an ellipsis — which of the two it is changes, the count does not.
    it('keeps the row the same length as the page walks', async () => {
      const slots = (screen: { container: HTMLElement }) =>
        screen.container.querySelectorAll('nav li').length;

      const screen = await render(<Pagination count={20} page={1} showArrows={false} />);
      const width = slots(screen);

      for (const page of [2, 10, 19, 20]) {
        await screen.rerender(<Pagination count={20} page={page} showArrows={false} />);
        expect(slots(screen)).toBe(width);
      }
    });
  });

  describe('choosing a page', () => {
    it('starts on the first page', async () => {
      const screen = await render(<Pagination count={5} />);

      await expect
        .element(screen.getByRole('button', { name: 'Page 1' }))
        .toHaveAttribute('aria-current', 'page');
    });

    it('starts on the page it is told to', async () => {
      const screen = await render(<Pagination count={5} defaultPage={3} />);

      await expect
        .element(screen.getByRole('button', { name: 'Page 3' }))
        .toHaveAttribute('aria-current', 'page');
    });

    it('moves when a page is pressed', async () => {
      const onPageChange = vi.fn();
      const screen = await render(<Pagination count={5} onPageChange={onPageChange} />);

      await screen.getByRole('button', { name: 'Page 3' }).click();

      expect(onPageChange).toHaveBeenCalledWith(3);
      await expect
        .element(screen.getByRole('button', { name: 'Page 3' }))
        .toHaveAttribute('aria-current', 'page');
    });

    it('does not report a press on the page it is already on', async () => {
      const onPageChange = vi.fn();
      const screen = await render(<Pagination count={5} onPageChange={onPageChange} />);

      await screen.getByRole('button', { name: 'Page 1' }).click();

      expect(onPageChange).not.toHaveBeenCalled();
    });

    it('follows a controlled page', async () => {
      const screen = await render(<Pagination count={5} page={2} />);

      await screen.getByRole('button', { name: 'Page 4' }).click();

      // Controlled: the row reports the press and waits to be told.
      await expect
        .element(screen.getByRole('button', { name: 'Page 2' }))
        .toHaveAttribute('aria-current', 'page');

      await screen.rerender(<Pagination count={5} page={4} />);

      await expect
        .element(screen.getByRole('button', { name: 'Page 4' }))
        .toHaveAttribute('aria-current', 'page');
    });

    /**
     * The window recentres on whichever page was chosen, so almost every number
     * moves one place along. Keyed by page number, React would move the DOM
     * nodes to match and the button under the pointer would become a different
     * element from the one that was pressed — its hover bloom fading out while a
     * freshly mounted neighbour's faded in from a centre it has no pointer
     * position for. That reads as a flicker. Keying by position keeps every node
     * where it is and changes only its label.
     */
    it('reuses the button in each slot rather than moving it', async () => {
      const screen = await render(<Pagination count={24} page={7} />);
      const slots = () => [...screen.container.querySelectorAll('nav ul > li')];
      const before = slots();

      expect(before.map((slot) => slot.textContent)).toEqual([
        '',
        '1',
        '…',
        '6',
        '7',
        '8',
        '…',
        '24',
        ''
      ]);

      await screen.rerender(<Pagination count={24} page={6} />);
      const after = slots();

      expect(after.map((slot) => slot.textContent)).toEqual([
        '',
        '1',
        '…',
        '5',
        '6',
        '7',
        '…',
        '24',
        ''
      ]);
      // Same nodes, in the same places, holding different numbers.
      after.forEach((slot, index) => expect(slot).toBe(before[index]));
    });
  });

  describe('the steppers', () => {
    it('steps forward and back', async () => {
      const onPageChange = vi.fn();
      const screen = await render(
        <Pagination count={5} defaultPage={2} onPageChange={onPageChange} />
      );

      await screen.getByRole('button', { name: 'Next page' }).click();
      expect(onPageChange).toHaveBeenLastCalledWith(3);

      await screen.getByRole('button', { name: 'Previous page' }).click();
      expect(onPageChange).toHaveBeenLastCalledWith(2);
    });

    it('turns off the stepper that has nowhere to go', async () => {
      const screen = await render(<Pagination count={5} page={1} />);

      await expect.element(screen.getByRole('button', { name: 'Previous page' })).toBeDisabled();
      await expect.element(screen.getByRole('button', { name: 'Next page' })).not.toBeDisabled();

      await screen.rerender(<Pagination count={5} page={5} />);

      await expect.element(screen.getByRole('button', { name: 'Next page' })).toBeDisabled();
    });

    it('leaves out the steppers when told to', async () => {
      const screen = await render(<Pagination count={5} showArrows={false} />);

      expect(screen.getByRole('button', { name: 'Next page' }).query()).toBeNull();
    });

    it('jumps to an end when the edge steppers are shown', async () => {
      const onPageChange = vi.fn();
      const screen = await render(
        <Pagination count={20} defaultPage={10} showEdges onPageChange={onPageChange} />
      );

      await screen.getByRole('button', { name: 'Last page' }).click();
      expect(onPageChange).toHaveBeenLastCalledWith(20);

      await screen.getByRole('button', { name: 'First page' }).click();
      expect(onPageChange).toHaveBeenLastCalledWith(1);
    });

    it('hides the edge steppers by default', async () => {
      const screen = await render(<Pagination count={20} />);

      expect(screen.getByRole('button', { name: 'First page' }).query()).toBeNull();
    });
  });

  describe('inert states', () => {
    it('turns every button off when disabled', async () => {
      const screen = await render(<Pagination count={5} defaultPage={3} disabled />);

      await expect.element(screen.getByRole('button', { name: 'Page 1' })).toBeDisabled();
      await expect.element(screen.getByRole('button', { name: 'Next page' })).toBeDisabled();
    });
  });

  describe('as links', () => {
    it('renders every page a reader is not on as a real link', async () => {
      const screen = await render(
        <Pagination count={5} page={2} getPageHref={(page) => `/posts?page=${page}`} />
      );

      await expect
        .element(screen.getByRole('link', { name: 'Page 3' }))
        .toHaveAttribute('href', '/posts?page=3');
      await expect
        .element(screen.getByRole('link', { name: 'Page 1' }))
        .toHaveAttribute('href', '/posts?page=1');
    });

    // The page being read is not somewhere to go, and it is the one number in
    // the row that carries `aria-current`.
    it('leaves the current page as a button', async () => {
      const screen = await render(
        <Pagination count={5} page={2} getPageHref={(page) => `/posts?page=${page}`} />
      );

      await expect
        .element(screen.getByRole('button', { name: 'Page 2' }))
        .toHaveAttribute('aria-current', 'page');
      expect(screen.getByRole('link', { name: 'Page 2' }).query()).toBeNull();
    });

    it('marks the two arrows with the rel a crawler reads', async () => {
      const screen = await render(
        <Pagination count={5} page={3} getPageHref={(page) => `/posts?page=${page}`} />
      );

      await expect
        .element(screen.getByRole('link', { name: 'Previous page' }))
        .toHaveAttribute('rel', 'prev');
      await expect
        .element(screen.getByRole('link', { name: 'Next page' }))
        .toHaveAttribute('rel', 'next');
    });

    // `disabled` is not something an `<a>` can be: a stepper left as a link at
    // the end of the row is one a keyboard still lands on and a crawler follows.
    it('keeps a stepper with nowhere to go as a button', async () => {
      const screen = await render(
        <Pagination count={5} page={1} showEdges getPageHref={(page) => `/posts?page=${page}`} />
      );

      await expect.element(screen.getByRole('button', { name: 'Previous page' })).toBeDisabled();
      expect(screen.getByRole('link', { name: 'Previous page' }).query()).toBeNull();
      await expect.element(screen.getByRole('button', { name: 'First page' })).toBeDisabled();
    });

    it('cancels the navigation when a handler is there to answer it', async () => {
      const onPageChange = vi.fn();
      let reachedParent: boolean | null = null;
      const screen = await render(
        <div
          onClick={(event) => {
            reachedParent = event.defaultPrevented;
            // Nothing should actually leave the page mid-test.
            event.preventDefault();
          }}
        >
          <Pagination
            count={5}
            page={1}
            getPageHref={(page) => `/posts?page=${page}`}
            onPageChange={onPageChange}
          />
        </div>
      );

      await screen.getByRole('link', { name: 'Page 2' }).click();

      expect(onPageChange).toHaveBeenCalledWith(2);
      expect(reachedParent).toBe(true);
    });

    it('leaves the navigation to the browser when nothing answers it', async () => {
      let reachedParent: boolean | null = null;
      const screen = await render(
        <div
          onClick={(event) => {
            reachedParent = event.defaultPrevented;
            event.preventDefault();
          }}
        >
          <Pagination count={5} page={1} getPageHref={(page) => `/posts?page=${page}`} />
        </div>
      );

      await screen.getByRole('link', { name: 'Page 2' }).click();

      expect(reachedParent).toBe(false);
    });

    it('is a row of buttons with no `getPageHref`', async () => {
      const screen = await render(<Pagination count={5} page={2} />);

      expect(screen.getByRole('link').query()).toBeNull();
      await expect.element(screen.getByRole('button', { name: 'Page 3' })).toBeInTheDocument();
    });
  });

  describe('style props', () => {
    // The current page is always filled, whatever the row's resting variant is.
    it('fills the current page and leaves the rest at rest', async () => {
      const screen = await render(<Pagination count={5} defaultPage={2} />);

      expect(screen.getByRole('button', { name: 'Page 2' }).element()).toHaveClass('bg-(--n-fill)');
      expect(screen.getByRole('button', { name: 'Page 1' }).element()).toHaveClass(
        'bg-transparent'
      );
    });

    it('takes the resting variant it is given', async () => {
      const screen = await render(<Pagination count={5} defaultPage={2} variant="outline" />);

      expect(screen.getByRole('button', { name: 'Page 1' }).element()).toHaveClass('border');
      expect(screen.getByRole('button', { name: 'Page 2' }).element()).toHaveClass('bg-(--n-fill)');
    });

    it('hands its size down to every button', async () => {
      const screen = await render(<Pagination count={5} size="xl" />);

      expect(screen.getByRole('button', { name: 'Page 1' }).element()).toHaveClass('h-12');
    });

    it('maps its colour onto the token slots', async () => {
      const screen = await render(<Pagination count={5} color="success" />);
      const element = screen.getByRole('button', { name: 'Page 1' }).element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-success-fill)');
    });

    it('never applies a transform', async () => {
      const screen = await render(<Pagination count={20} defaultPage={10} showEdges />);

      expect(screen.getByRole('navigation').element().outerHTML).not.toContain('translate');
    });
  });

  describe('locale', () => {
    it('names the row and its steppers in the language it was given', async () => {
      const screen = await render(<Pagination count={5} page={2} locale="ko" />);

      await expect
        .element(screen.getByRole('navigation', { name: '페이지 매기기' }))
        .toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: '이전 페이지' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: '2페이지' })).toBeInTheDocument();
    });

    // The one string here that is a whole sentence, and the reason it is one:
    // "Page 2 of 5" puts its two numbers the other way round in Korean.
    it('reads where the reader is as one sentence', async () => {
      const screen = await render(<Pagination count={5} page={2} locale="ko" />);

      await expect.element(screen.getByText('전체 5페이지 중 2페이지')).toBeInTheDocument();
    });

    it('takes words of its own over the locale', async () => {
      const screen = await render(
        <Pagination count={5} page={2} locale="ko" label="Pages" previousLabel="Back" />
      );

      await expect.element(screen.getByRole('navigation', { name: 'Pages' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Back' })).toBeInTheDocument();
    });
  });
});
