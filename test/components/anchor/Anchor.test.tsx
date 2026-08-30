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

      expect(link.style.marginInlineStart).toBe('12px');
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

    it('maps color onto the accent slot', async () => {
      const screen = await render(<Page items={ITEMS} color="success" />);
      const element = screen.getByRole('navigation').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-success-accent)');
    });
  });
});
