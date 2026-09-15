import { createRef } from 'react';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Anchor } from 'neba';

const ITEMS = [
  { href: '#install', label: 'Install' },
  { href: '#setup', label: 'Setup', depth: 1 },
  { href: '#usage', label: 'Usage' }
];

/** The headings the list watches, given real heights so the scroll is real. */
function Page(props: React.ComponentProps<typeof Anchor>) {
  return (
    <div>
      <Anchor {...props} />
      <div>
        {ITEMS.map((item) => (
          <section key={item.href} id={item.href.slice(1)} style={{ height: 600 }}>
            <h2>{item.label}</h2>
          </section>
        ))}
      </div>
    </div>
  );
}

describe('Anchor', () => {
  describe('rendering', () => {
    it('renders a nav of real fragment links', async () => {
      const screen = await render(<Page items={ITEMS} />);

      await expect
        .element(screen.getByRole('navigation', { name: 'On this page' }))
        .toBeInTheDocument();

      const link = screen.getByRole('link', { name: 'Setup' });

      await expect.element(link).toHaveAttribute('href', '#setup');
      expect(link.element().tagName).toBe('A');
    });

    it('names the nav in the language it was given', async () => {
      const screen = await render(<Page items={ITEMS} locale="ko" />);

      // Nothing has registered Korean, so it falls back to English.
      await expect
        .element(screen.getByRole('navigation', { name: 'On this page' }))
        .toBeInTheDocument();
    });

    it('takes a label of its own', async () => {
      const screen = await render(<Page items={ITEMS} label="Contents" />);

      await expect
        .element(screen.getByRole('navigation', { name: 'Contents' }))
        .toBeInTheDocument();
    });

    it('indents a deeper heading', async () => {
      const screen = await render(<Page items={ITEMS} />);
      const link = screen.getByRole('link', { name: 'Setup' }).element() as HTMLElement;

      // On the rail, the default, the indent is inside the row: its own 0.75rem
      // and one step of 12px.
      // The browser is free to reorder the terms of a `calc()` it serializes.
      expect(link.style.paddingInlineStart).toContain('0.75rem');
      expect(link.style.paddingInlineStart).toContain('12px');
    });

    it('reflects a changed list on re-render', async () => {
      const screen = await render(<Page items={ITEMS} />);

      await screen.rerender(<Page items={[{ href: '#other', label: 'Other' }]} />);

      await expect.element(screen.getByRole('link', { name: 'Other' })).toBeInTheDocument();
      expect(screen.getByRole('link', { name: 'Usage' }).query()).toBeNull();
    });
  });

  describe('the active row', () => {
    // Nothing is marked while the reader is still above the first heading —
    // a hero, a lede, a table of contents itself all sit up there, and none of
    // them belongs to a section yet.
    it('marks nothing until the first heading has been reached', async () => {
      const screen = await render(<Page items={ITEMS} />);

      await expect
        .element(screen.getByRole('link', { name: 'Install' }))
        .not.toHaveAttribute('aria-current');
    });

    it('marks the row the reader is in', async () => {
      const screen = await render(<Page items={ITEMS} />);

      window.scrollTo(0, 200);

      await expect
        .element(screen.getByRole('link', { name: 'Install' }))
        .toHaveAttribute('aria-current', 'location');

      window.scrollTo(0, 0);
    });

    it('says what it is told when it is controlled', async () => {
      const screen = await render(<Page items={ITEMS} activeHref="#usage" />);

      await expect
        .element(screen.getByRole('link', { name: 'Usage' }))
        .toHaveAttribute('aria-current', 'location');
      await expect
        .element(screen.getByRole('link', { name: 'Install' }))
        .not.toHaveAttribute('aria-current');
    });

    // Passing `activeHref` turned the tracking off, so `onActiveChange` never
    // told a controlled caller where the reader had got to.
    it('keeps reporting the row the reader is in while it is controlled', async () => {
      const onActiveChange = vi.fn();
      const screen = await render(
        <Page items={ITEMS} activeHref="#usage" onActiveChange={onActiveChange} />
      );

      window.scrollTo(0, 200);

      await expect.poll(() => onActiveChange.mock.calls.at(-1)?.[0]).toBe('#install');
      await expect
        .element(screen.getByRole('link', { name: 'Usage' }))
        .toHaveAttribute('aria-current', 'location');

      window.scrollTo(0, 0);
    });

    // On a page with nothing to scroll the "at the bottom" rule held from the
    // first frame, so the last heading was marked on a page opened at the first.
    it('starts on the first heading when nothing scrolls', async () => {
      // Its own scroller, with room to spare, so the test does not depend on how
      // tall the page running it happens to be.
      const box = createRef<HTMLDivElement>();
      const screen = await render(
        <div>
          <Anchor items={ITEMS} container={box} />
          <div ref={box} style={{ height: 400, overflowY: 'auto' }}>
            {ITEMS.map((item) => (
              <section key={item.href} id={item.href.slice(1)} style={{ height: 20 }}>
                <h2>{item.label}</h2>
              </section>
            ))}
          </div>
        </div>
      );

      await expect
        .element(screen.getByRole('link', { name: 'Install' }))
        .toHaveAttribute('aria-current', 'location');
      expect(screen.getByRole('link', { name: 'Usage' }).element()).not.toHaveAttribute(
        'aria-current'
      );
    });

    it('follows the scroll of the container it was given', async () => {
      const box = createRef<HTMLDivElement>();
      const screen = await render(
        <div>
          <Anchor items={ITEMS} container={box} />
          <div ref={box} style={{ height: 300, overflowY: 'auto' }}>
            {ITEMS.map((item) => (
              <section key={item.href} id={item.href.slice(1)} style={{ height: 600 }}>
                <h2>{item.label}</h2>
              </section>
            ))}
          </div>
        </div>
      );

      box.current?.scrollTo(0, 1300);

      await expect
        .element(screen.getByRole('link', { name: 'Usage' }))
        .toHaveAttribute('aria-current', 'location');
      // The window did not move, so the container's own scroll is what was heard.
      expect(window.scrollY).toBe(0);
    });

    it('follows a controlled value as it changes', async () => {
      const screen = await render(<Page items={ITEMS} activeHref="#usage" />);

      await screen.rerender(<Page items={ITEMS} activeHref="#setup" />);

      await expect
        .element(screen.getByRole('link', { name: 'Setup' }))
        .toHaveAttribute('aria-current', 'location');
    });

    it('reports the row as the page is scrolled', async () => {
      const onActiveChange = vi.fn();
      const screen = await render(<Page items={ITEMS} onActiveChange={onActiveChange} />);

      window.scrollTo(0, 1300);
      await expect
        .element(screen.getByRole('link', { name: 'Usage' }))
        .toHaveAttribute('aria-current', 'location');

      expect(onActiveChange).toHaveBeenCalledWith('#usage');
      window.scrollTo(0, 0);
    });

    /*
     * The headings are looked up once and kept, because the lookup happens on
     * every frame of a scroll. Kept and *checked*: a section rendered after the
     * trail — a route that swapped its content, a list that arrived late — has
     * to be found the next time the reader scrolls rather than never.
     */
    it('finds a heading that arrived after it did', async () => {
      const screen = await render(
        <div>
          <Anchor items={ITEMS} />
        </div>
      );

      window.scrollTo(0, 200);

      await expect
        .element(screen.getByRole('link', { name: 'Install' }))
        .not.toHaveAttribute('aria-current');

      await screen.rerender(<Page items={ITEMS} />);

      window.scrollTo(0, 200);

      await expect
        .element(screen.getByRole('link', { name: 'Install' }))
        .toHaveAttribute('aria-current', 'location');

      window.scrollTo(0, 0);
    });
  });

  describe('appearance', () => {
    it('draws the rail by default and drops it on request', async () => {
      const screen = await render(<Page items={ITEMS} />);
      const list = screen.getByRole('navigation').element().firstElementChild as HTMLElement;

      expect(list).toHaveClass('border-s');

      await screen.rerender(<Page items={ITEMS} rail={false} />);

      expect(
        (screen.getByRole('navigation').element().firstElementChild as HTMLElement).className
      ).not.toContain('border-s');
    });

    // A margin moved the nested row's box, and the `border-s` highlight with it,
    // a step away from the rail.
    it('indents a nested row on the rail inside its box, not by moving the box', async () => {
      const screen = await render(<Page items={ITEMS} />);
      const nested = screen.getByRole('link', { name: 'Setup' }).element() as HTMLElement;

      expect(nested.style.marginInlineStart).toBe('');
      expect(nested.style.paddingInlineStart).toContain('0.75rem');

      await screen.rerender(<Page items={ITEMS} rail={false} />);

      expect(nested.style.paddingInlineStart).toBe('');
      expect(nested.style.marginInlineStart).not.toBe('');
    });

    it('maps color onto the accent slot', async () => {
      const screen = await render(<Page items={ITEMS} color="success" />);
      const element = screen.getByRole('navigation').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-success-accent)');
    });
  });
});
