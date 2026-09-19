import { describe, expect, it, vi } from 'vitest';
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
    });
  });

  describe('folding', () => {
    it('starts closed', async () => {
      const screen = await render(<Sources items={ITEMS} />);

      expect(screen.getByRole('listitem').query()).toBeNull();
    });

    it('opens when the heading is pressed', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(<Sources items={ITEMS} onOpenChange={onOpenChange} />);

      await screen.getByRole('button').click();

      await expect
        .element(screen.getByRole('link', { name: 'Design language', exact: false }))
        .toBeInTheDocument();
      expect(onOpenChange).toHaveBeenCalledWith(true);
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
