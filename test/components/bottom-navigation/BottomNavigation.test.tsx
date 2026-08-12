import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { BottomNavigation, BottomNavigationItem } from 'neba';

describe('BottomNavigation', () => {
  describe('rendering', () => {
    it('renders a nav holding one control per destination', async () => {
      const screen = await render(
        <BottomNavigation label="Main">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
          <BottomNavigationItem value="search">Search</BottomNavigationItem>
        </BottomNavigation>
      );

      await expect.element(screen.getByRole('navigation', { name: 'Main' })).toBeInTheDocument();
      expect(screen.getByRole('button').elements()).toHaveLength(2);
    });

    it('renders an item with an href as a link', async () => {
      const screen = await render(
        <BottomNavigation>
          <BottomNavigationItem value="home" href="/home">
            Home
          </BottomNavigationItem>
        </BottomNavigation>
      );

      await expect
        .element(screen.getByRole('link', { name: 'Home' }))
        .toHaveAttribute('href', '/home');
    });

    it('reflects a changed name on re-render', async () => {
      const screen = await render(
        <BottomNavigation>
          <BottomNavigationItem value="home">Before</BottomNavigationItem>
        </BottomNavigation>
      );

      await screen.rerender(
        <BottomNavigation>
          <BottomNavigationItem value="home">After</BottomNavigationItem>
        </BottomNavigation>
      );

      await expect.element(screen.getByRole('button', { name: 'After' })).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <BottomNavigation className="my-own-class" data-testid="bar">
          <BottomNavigationItem value="home" className="my-item-class">
            Home
          </BottomNavigationItem>
        </BottomNavigation>
      );

      expect(screen.getByTestId('bar').element()).toHaveClass('my-own-class');
      expect(screen.getByRole('button', { name: 'Home' }).element()).toHaveClass('my-item-class');
    });

    it('forwards unknown props to the root', async () => {
      const screen = await render(
        <BottomNavigation data-testid="bar" id="main-nav">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
        </BottomNavigation>
      );

      expect(screen.getByTestId('bar').element()).toHaveAttribute('id', 'main-nav');
    });
  });

  describe('position', () => {
    it('is fixed to the bottom edge by default', async () => {
      const screen = await render(
        <BottomNavigation data-testid="bar">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
        </BottomNavigation>
      );

      expect(screen.getByTestId('bar').element()).toHaveClass('fixed', 'bottom-0', 'inset-x-0');
    });

    it('goes back into the flow when it is told to', async () => {
      const screen = await render(
        <BottomNavigation position="static" data-testid="bar">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
        </BottomNavigation>
      );

      expect(screen.getByTestId('bar').element()).not.toHaveClass('fixed');
    });

    it('holds itself clear of the home indicator, and stops when asked', async () => {
      const screen = await render(
        <BottomNavigation data-testid="bar">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
        </BottomNavigation>
      );

      expect(screen.getByTestId('bar').element()).toHaveClass('pb-[env(safe-area-inset-bottom)]');

      await screen.rerender(
        <BottomNavigation safeArea={false} data-testid="bar">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
        </BottomNavigation>
      );

      expect(screen.getByTestId('bar').element()).not.toHaveClass(
        'pb-[env(safe-area-inset-bottom)]'
      );
    });
  });

  describe('choosing a destination', () => {
    it('marks the current destination', async () => {
      const screen = await render(
        <BottomNavigation value="search">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
          <BottomNavigationItem value="search">Search</BottomNavigationItem>
        </BottomNavigation>
      );

      await expect
        .element(screen.getByRole('button', { name: 'Search' }))
        .toHaveAttribute('aria-current', 'page');
      expect(
        screen.getByRole('button', { name: 'Home' }).element().getAttribute('aria-current')
      ).toBeNull();
    });

    it('reports the destination that was pressed', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <BottomNavigation onValueChange={onValueChange}>
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
          <BottomNavigationItem value="search">Search</BottomNavigationItem>
        </BottomNavigation>
      );

      await screen.getByRole('button', { name: 'Search' }).click();

      expect(onValueChange).toHaveBeenCalledWith('search');
    });

    it('keeps the choice in an uncontrolled bar', async () => {
      const screen = await render(
        <BottomNavigation defaultValue="home">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
          <BottomNavigationItem value="search">Search</BottomNavigationItem>
        </BottomNavigation>
      );

      await screen.getByRole('button', { name: 'Search' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Search' }))
        .toHaveAttribute('aria-current', 'page');
    });

    it('leaves a controlled bar where it was put', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <BottomNavigation value="home" onValueChange={onValueChange}>
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
          <BottomNavigationItem value="search">Search</BottomNavigationItem>
        </BottomNavigation>
      );

      await screen.getByRole('button', { name: 'Search' }).click();

      expect(onValueChange).toHaveBeenCalledWith('search');
      await expect
        .element(screen.getByRole('button', { name: 'Home' }))
        .toHaveAttribute('aria-current', 'page');
    });

    it('stops every destination answering when the bar is disabled', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <BottomNavigation disabled onValueChange={onValueChange}>
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
        </BottomNavigation>
      );

      await expect.element(screen.getByRole('button', { name: 'Home' })).toBeDisabled();
      expect(onValueChange).not.toHaveBeenCalled();
    });

    it('disables one destination on its own', async () => {
      const screen = await render(
        <BottomNavigation>
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
          <BottomNavigationItem value="search" disabled>
            Search
          </BottomNavigationItem>
        </BottomNavigation>
      );

      await expect.element(screen.getByRole('button', { name: 'Search' })).toBeDisabled();
      await expect.element(screen.getByRole('button', { name: 'Home' })).toBeEnabled();
    });
  });

  describe('labels', () => {
    it('draws every name by default', async () => {
      const screen = await render(
        <BottomNavigation value="home">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
          <BottomNavigationItem value="search">Search</BottomNavigationItem>
        </BottomNavigation>
      );

      expect(screen.getByText('Search').element()).not.toHaveClass('size-px');
    });

    // Undrawn is not unsaid: the name a hidden label carried is what gives the
    // glyph beside it an accessible name at all.
    it('keeps an undrawn name in the document, so the item still has one', async () => {
      const screen = await render(
        <BottomNavigation value="home" labels="none">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
          <BottomNavigationItem value="search">Search</BottomNavigationItem>
        </BottomNavigation>
      );

      await expect.element(screen.getByRole('button', { name: 'Search' })).toBeInTheDocument();
      expect(screen.getByText('Search').element()).toHaveClass('size-px');
    });

    it('draws only the current one when it is told to', async () => {
      const screen = await render(
        <BottomNavigation value="home" labels="selected">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
          <BottomNavigationItem value="search">Search</BottomNavigationItem>
        </BottomNavigation>
      );

      expect(screen.getByText('Home').element()).not.toHaveClass('size-px');
      expect(screen.getByText('Search').element()).toHaveClass('size-px');
    });
  });
});
