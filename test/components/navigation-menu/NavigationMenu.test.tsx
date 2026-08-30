import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { NavigationMenu, NavigationMenuItem, NavigationMenuLink } from 'neba';

function Nav(props: React.ComponentProps<typeof NavigationMenu>) {
  return (
    <NavigationMenu aria-label="Main" {...props}>
      <NavigationMenuItem label="Product" value="product">
        <NavigationMenuLink href="/analytics" title="Analytics" description="Every number." />
        <NavigationMenuLink href="/pipelines" title="Pipelines" />
      </NavigationMenuItem>
      <NavigationMenuItem label="Pricing" href="/pricing" />
      <NavigationMenuItem label="Docs" value="docs" disabled>
        <NavigationMenuLink href="/guide" title="Guide" />
      </NavigationMenuItem>
    </NavigationMenu>
  );
}

describe('NavigationMenu', () => {
  describe('rendering', () => {
    it('renders a nav of items', async () => {
      const screen = await render(<Nav />);

      await expect.element(screen.getByRole('navigation', { name: 'Main' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: /Product/ })).toBeInTheDocument();
    });

    // The whole reason this is not a Menu: a destination has to be a link.
    it('renders an item with an href as a real link', async () => {
      const screen = await render(<Nav />);
      const link = screen.getByRole('link', { name: 'Pricing' });

      await expect.element(link).toHaveAttribute('href', '/pricing');
      expect(link.element().tagName).toBe('A');
    });

    it('opens no panel until an item is asked', async () => {
      const screen = await render(<Nav />);

      expect(screen.getByRole('link', { name: /Analytics/ }).query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Nav className="my-own-class" />);

      expect(screen.getByRole('navigation').element()).toHaveClass('my-own-class');
    });
  });

  describe('behaviour', () => {
    it('opens the panel behind an item', async () => {
      const screen = await render(<Nav />);

      await screen.getByRole('button', { name: /Product/ }).click();

      await expect
        .element(screen.getByRole('link', { name: /Analytics/ }))
        .toHaveAttribute('href', '/analytics');
    });

    it('reports which item is open', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<Nav onValueChange={onValueChange} />);

      await screen.getByRole('button', { name: /Product/ }).click();
      await expect.element(screen.getByRole('link', { name: /Analytics/ })).toBeInTheDocument();

      expect(onValueChange).toHaveBeenCalledWith('product');
    });

    it('honours a controlled value', async () => {
      const screen = await render(<Nav value="product" onValueChange={() => {}} />);

      await expect.element(screen.getByRole('link', { name: /Analytics/ })).toBeInTheDocument();
    });

    it('leaves a disabled item unopenable', async () => {
      const screen = await render(<Nav />);
      const docs = screen.getByRole('button', { name: /Docs/ });

      await expect.element(docs).toBeDisabled();

      await docs.click({ force: true });

      expect(screen.getByRole('link', { name: 'Guide' }).query()).toBeNull();
    });
  });

  describe('shared props', () => {
    it('sets the size once for every item', async () => {
      const screen = await render(<Nav size="lg" />);

      expect(screen.getByRole('button', { name: /Product/ }).element()).toHaveClass('h-10');
      expect(screen.getByRole('link', { name: 'Pricing' }).element()).toHaveClass('h-10');
    });

    it('maps color onto the surface slots', async () => {
      const screen = await render(<Nav color="success" />);
      const element = screen.getByRole('navigation').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-line')).toBe('var(--neba-success-line)');
    });

    it('turns the row on its side when vertical', async () => {
      const screen = await render(<Nav orientation="vertical" />);
      const list = screen.getByRole('button', { name: /Product/ }).element().parentElement
        ?.parentElement as HTMLElement;

      expect(list).toHaveClass('flex-col');
    });
  });
});
