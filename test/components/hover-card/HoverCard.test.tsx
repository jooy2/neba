import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { HoverCard, TextLink } from 'neba';

describe('HoverCard', () => {
  describe('rendering', () => {
    it('renders nothing until it is open', async () => {
      const screen = await render(
        <HoverCard trigger={<TextLink href="#neba">neba</TextLink>} title="Neba">
          A React component library.
        </HoverCard>
      );

      expect(screen.getByText('A React component library.').query()).toBeNull();
    });

    it('renders its title, description and body when open', async () => {
      const screen = await render(
        <HoverCard
          defaultOpen
          trigger={<TextLink href="#neba">the library</TextLink>}
          title="Neba"
          description="1.8.1"
        >
          A React component library.
        </HoverCard>
      );

      await expect.element(screen.getByText('Neba')).toBeInTheDocument();
      await expect.element(screen.getByText('1.8.1')).toBeInTheDocument();
      await expect.element(screen.getByText('A React component library.')).toBeInTheDocument();
    });

    // The trigger merges onto the element rather than wrapping it, so the card
    // costs the layout nothing and the link stays a link.
    it('adds no element of its own around the trigger', async () => {
      const screen = await render(
        <HoverCard trigger={<TextLink href="#neba">neba</TextLink>}>Body</HoverCard>
      );
      const trigger = screen.getByRole('link', { name: 'neba' }).element();

      expect(trigger.tagName).toBe('A');
      expect(trigger).toHaveAttribute('href', '#neba');
    });

    it('reflects changed content on re-render', async () => {
      const screen = await render(
        <HoverCard defaultOpen trigger={<TextLink href="#a">a</TextLink>} title="Before" />
      );

      await screen.rerender(
        <HoverCard defaultOpen trigger={<TextLink href="#a">a</TextLink>} title="After" />
      );

      await expect.element(screen.getByText('After')).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <HoverCard defaultOpen trigger={<TextLink href="#a">a</TextLink>} className="my-own-class">
          Body
        </HoverCard>
      );

      expect(screen.getByText('Body').element().parentElement).toHaveClass('my-own-class');
    });
  });

  describe('behaviour', () => {
    it('opens when the pointer rests on the trigger', async () => {
      const screen = await render(
        <HoverCard delay={0} trigger={<TextLink href="#a">a</TextLink>}>
          Body
        </HoverCard>
      );

      await screen.getByRole('link', { name: 'a' }).hover();

      await expect.element(screen.getByText('Body')).toBeInTheDocument();
    });

    it('reports opening to the caller', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <HoverCard delay={0} onOpenChange={onOpenChange} trigger={<TextLink href="#a">a</TextLink>}>
          Body
        </HoverCard>
      );

      await screen.getByRole('link', { name: 'a' }).hover();
      await expect.element(screen.getByText('Body')).toBeInTheDocument();

      expect(onOpenChange).toHaveBeenCalledWith(true);
    });

    it('honours a controlled open', async () => {
      const screen = await render(
        <HoverCard open={false} onOpenChange={() => {}} trigger={<TextLink href="#a">a</TextLink>}>
          Body
        </HoverCard>
      );

      expect(screen.getByText('Body').query()).toBeNull();

      await screen.rerender(
        <HoverCard open onOpenChange={() => {}} trigger={<TextLink href="#a">a</TextLink>}>
          Body
        </HoverCard>
      );

      await expect.element(screen.getByText('Body')).toBeInTheDocument();
    });
  });

  describe('the sheet', () => {
    it('carries the portal hook, because it leaves the scoped subtree', async () => {
      const screen = await render(
        <HoverCard defaultOpen trigger={<TextLink href="#a">a</TextLink>}>
          Body
        </HoverCard>
      );
      const popup = screen.getByText('Body').element().parentElement as HTMLElement;

      expect(popup.parentElement).toHaveClass('neba-portal');
    });

    it('maps color onto the surface slots', async () => {
      const screen = await render(
        <HoverCard defaultOpen color="success" trigger={<TextLink href="#a">a</TextLink>}>
          Body
        </HoverCard>
      );
      const popup = screen.getByText('Body').element().parentElement as HTMLElement;

      expect(popup.style.getPropertyValue('--n-line')).toBe('var(--neba-success-line)');
    });

    it('takes a width of its own instead of the one size implies', async () => {
      const screen = await render(
        <HoverCard defaultOpen width={200} trigger={<TextLink href="#a">a</TextLink>}>
          Body
        </HoverCard>
      );
      const popup = screen.getByText('Body').element().parentElement as HTMLElement;

      expect(popup.style.maxWidth).toBe('200px');
      expect(popup).not.toHaveClass('max-w-84');
    });
  });
});
