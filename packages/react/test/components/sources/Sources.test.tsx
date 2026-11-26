import { describe, expect, it, vi } from 'vitest';
import { renderToString } from 'react-dom/server';
import { render } from 'vitest-browser-react';
import { Sources } from 'neba';

const ITEMS = [
  { title: 'Design language', href: 'https://example.com/design', site: 'example.com' },
  { title: 'Breakpoints', href: 'https://example.com/breakpoints' },
  { title: 'An unlinked note', description: 'From the working document' }
];

describe('Sources', () => {
  describe('rendering', () => {
    it('names itself when it was not given a name', async () => {
      const screen = await render(<Sources items={ITEMS} />);

      await expect
        .element(screen.getByRole('button', { name: 'Sources', exact: false }))
        .toBeInTheDocument();
    });

    it('counts what it holds on the closed header', async () => {
      const screen = await render(<Sources items={ITEMS.slice(0, 2)} title="Read" />);

      const header = screen.getByRole('button', { name: 'Read', exact: false });

      await expect.element(header).toBeInTheDocument();
      // The count is the whole point of the closed state.
      expect(header.element().textContent).toContain('2');
    });

    it('numbers the rows in the order they were given', async () => {
      const screen = await render(<Sources items={ITEMS} defaultOpen />);
      const numbers = screen.getByRole('listitem').all();

      expect(numbers[0].element().textContent).toContain('1');
      expect(numbers[1].element().textContent).toContain('2');
    });

    it('takes a number a source claims for itself', async () => {
      const screen = await render(
        <Sources items={[{ title: 'Only one cited', index: 4 }]} defaultOpen />
      );

      expect(screen.getByRole('listitem').element().textContent).toContain('4');
    });

    it('drops the numbers when it is asked to', async () => {
      const screen = await render(<Sources items={ITEMS} numbered={false} defaultOpen />);

      expect(screen.getByRole('listitem').first().element().textContent).not.toContain('1');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Sources items={ITEMS} className="my-own-class" />);

      expect(screen.getByRole('button').element().closest('.my-own-class')).not.toBeNull();
    });
  });

  describe('links', () => {
    it('links the rows that have an address', async () => {
      const screen = await render(<Sources items={ITEMS} defaultOpen />);

      await expect
        .element(screen.getByRole('link', { name: 'Design language', exact: false }))
        .toHaveAttribute('href', 'https://example.com/design');
    });

    it('leaves a row without one as plain text', async () => {
      const screen = await render(<Sources items={ITEMS} defaultOpen />);

      expect(screen.getByRole('link', { name: 'An unlinked note' }).query()).toBeNull();
      await expect.element(screen.getByText('An unlinked note')).toBeInTheDocument();
    });

    // A URL in a search result was not written by the page's author.
    it('refuses an address whose scheme is not one of the four', async () => {
      const screen = await render(
        <Sources items={[{ title: 'Trouble', href: 'javascript:alert(1)' }]} defaultOpen />
      );

      expect(screen.getByRole('link').query()).toBeNull();
    });

    it('protects a link that leaves the tab', async () => {
      const screen = await render(
        <Sources
          items={[{ title: 'Away', href: 'https://example.com', target: '_blank' }]}
          defaultOpen
        />
      );

      await expect
        .element(screen.getByRole('link', { name: 'Away', exact: false }))
        .toHaveAttribute('rel', 'noopener noreferrer');
      expect(
        screen.getByRole('link', { name: 'Away', exact: false }).element().textContent
      ).toMatch(/\(opens in a new tab\)$/);
    });
  });

  describe('folding', () => {
    it('starts closed', async () => {
      const screen = await render(<Sources items={ITEMS} />);

      await expect.element(screen.getByRole('button')).toHaveAttribute('aria-expanded', 'false');
      // The panel's `hidden` rather than the rows' absence from the role tree:
      // WebKit's check does not count a `content-visibility: hidden` ancestor,
      // which is how `hidden="until-found"` hides them.
      expect(screen.getByText('Breakpoints').element().closest('[hidden]')).not.toBeNull();
    });

    // In the markup, and so in a server render and a crawler's index, but
    // hidden until the browser's page search finds something in it.
    it('keeps a folded list in the document, hidden until it is found', async () => {
      const screen = await render(<Sources items={ITEMS} />);
      const row = screen.getByText('Breakpoints').element();

      expect(row.closest('[hidden]')).toHaveAttribute('hidden', 'until-found');
    });

    it('writes the links of a folded list into a server render', () => {
      const html = renderToString(<Sources items={ITEMS} />);

      expect(html).toContain('href="https://example.com/design"');
      expect(html).toContain('href="https://example.com/breakpoints"');
    });

    it('leaves a folded list out of the document when it is not to be found', async () => {
      const screen = await render(<Sources items={ITEMS} hiddenUntilFound={false} />);

      await expect.element(screen.getByRole('button')).toHaveAttribute('aria-expanded', 'false');
      expect(screen.getByText('Breakpoints').query()).toBeNull();
      expect(renderToString(<Sources items={ITEMS} hiddenUntilFound={false} />)).not.toContain(
        'https://example.com/design'
      );
    });

    it('opens when the heading is pressed', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(<Sources items={ITEMS} onOpenChange={onOpenChange} />);

      await screen.getByRole('button').click();

      await expect.element(screen.getByRole('button')).toHaveAttribute('aria-expanded', 'true');
      await expect
        .element(screen.getByRole('link', { name: 'Design language', exact: false }))
        .toBeVisible();
      expect(screen.getByText('Breakpoints').element().closest('[hidden]')).toBeNull();
      expect(onOpenChange).toHaveBeenCalledWith(true);
    });

    it('folds again when the heading is pressed a second time', async () => {
      const screen = await render(<Sources items={ITEMS} defaultOpen />);

      await screen.getByRole('button').click();

      await expect.element(screen.getByRole('button')).toHaveAttribute('aria-expanded', 'false');
      await expect
        .poll(() => screen.getByText('Breakpoints').element().closest('[hidden]'))
        .not.toBeNull();
    });

    it('is not a disclosure at all when it was told not to be', async () => {
      const screen = await render(<Sources items={ITEMS} collapsible={false} />);

      expect(screen.getByRole('button').query()).toBeNull();
      await expect
        .element(screen.getByRole('link', { name: 'Design language', exact: false }))
        .toBeInTheDocument();
    });
  });
});
