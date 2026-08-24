import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { BottomNavigationItem, FloatingBottomNavigation } from 'neba';

describe('FloatingBottomNavigation', () => {
  describe('rendering', () => {
    it('renders a nav holding one control per destination', async () => {
      const screen = await render(
        <FloatingBottomNavigation label="Main">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
          <BottomNavigationItem value="search">Search</BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      await expect.element(screen.getByRole('navigation', { name: 'Main' })).toBeInTheDocument();
      expect(screen.getByRole('button').elements()).toHaveLength(2);
    });

    it('takes the same item a full-width bar takes, with an href and all', async () => {
      const screen = await render(
        <FloatingBottomNavigation>
          <BottomNavigationItem value="home" href="/home">
            Home
          </BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      await expect
        .element(screen.getByRole('link', { name: 'Home' }))
        .toHaveAttribute('href', '/home');
    });

    it('floats clear of the bottom edge, and says how far', async () => {
      const screen = await render(
        <FloatingBottomNavigation offset={24} safeArea={false} data-testid="bar">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      const bar = screen.getByTestId('bar').element() as HTMLElement;

      expect(bar).toHaveClass('fixed', 'bottom-(--n-nav-offset)');
      expect(bar.style.getPropertyValue('--n-nav-offset')).toBe('24px');
    });

    it('adds the safe area to the offset rather than to the sheet', async () => {
      const screen = await render(
        <FloatingBottomNavigation data-testid="bar">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      expect(
        (screen.getByTestId('bar').element() as HTMLElement).style.getPropertyValue(
          '--n-nav-offset'
        )
      ).toBe('calc(16px + env(safe-area-inset-bottom))');
    });

    it('goes back into the flow when it is told to', async () => {
      const screen = await render(
        <FloatingBottomNavigation position="static" data-testid="bar">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      expect(screen.getByTestId('bar').element()).not.toHaveClass('fixed');
      expect(screen.getByTestId('bar').element()).toHaveClass('mx-auto', 'w-fit');
    });

    it('can belong to a region rather than to the window', async () => {
      const screen = await render(
        <FloatingBottomNavigation position="absolute" data-testid="bar">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      expect(screen.getByTestId('bar').element()).toHaveClass(
        'absolute',
        'bottom-(--n-nav-offset)'
      );
    });

    it('is a stadium rather than a sheet with the corners cut', async () => {
      const screen = await render(
        <FloatingBottomNavigation data-testid="bar">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      expect(screen.getByTestId('bar').element()).toHaveClass('rounded-full');
    });

    it('cuts its destinations the same way', async () => {
      const screen = await render(
        <FloatingBottomNavigation>
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      expect(screen.getByRole('button', { name: 'Home' }).element()).toHaveClass('rounded-full');
    });

    it('keeps caller-supplied class names alongside its own, and forwards the rest', async () => {
      const screen = await render(
        <FloatingBottomNavigation className="my-own-class" id="main-nav" data-testid="bar">
          <BottomNavigationItem value="home" className="my-item-class">
            Home
          </BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      expect(screen.getByTestId('bar').element()).toHaveClass('my-own-class');
      expect(screen.getByTestId('bar').element()).toHaveAttribute('id', 'main-nav');
      expect(screen.getByRole('button', { name: 'Home' }).element()).toHaveClass('my-item-class');
    });
  });

  describe('choosing a destination', () => {
    it('marks the current one', async () => {
      const screen = await render(
        <FloatingBottomNavigation value="search">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
          <BottomNavigationItem value="search">Search</BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      await expect
        .element(screen.getByRole('button', { name: 'Search' }))
        .toHaveAttribute('aria-current', 'page');
    });

    it('reports the destination that was pressed', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <FloatingBottomNavigation onValueChange={onValueChange}>
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
          <BottomNavigationItem value="search">Search</BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      await screen.getByRole('button', { name: 'Search' }).click();

      expect(onValueChange).toHaveBeenCalledWith('search');
    });

    it('keeps the choice in an uncontrolled bar', async () => {
      const screen = await render(
        <FloatingBottomNavigation defaultValue="home">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
          <BottomNavigationItem value="search">Search</BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      await screen.getByRole('button', { name: 'Search' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Search' }))
        .toHaveAttribute('aria-current', 'page');
    });

    it('leaves a controlled bar where it was put', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <FloatingBottomNavigation value="home" onValueChange={onValueChange}>
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
          <BottomNavigationItem value="search">Search</BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      await screen.getByRole('button', { name: 'Search' }).click();

      expect(onValueChange).toHaveBeenCalledWith('search');
      await expect
        .element(screen.getByRole('button', { name: 'Home' }))
        .toHaveAttribute('aria-current', 'page');
    });

    it('stops every destination answering when the bar is disabled', async () => {
      const screen = await render(
        <FloatingBottomNavigation disabled>
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      await expect.element(screen.getByRole('button', { name: 'Home' })).toBeDisabled();
    });
  });

  describe('labels', () => {
    // The floating bar is only as wide as what is in it, so it names the
    // destination the reader is on and no other — the names it does not draw
    // are still what give the glyphs beside them an accessible name.
    it('draws only the current name by default', async () => {
      const screen = await render(
        <FloatingBottomNavigation value="home">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
          <BottomNavigationItem value="search">Search</BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      expect(screen.getByText('Home').element()).not.toHaveClass('size-px');
      expect(screen.getByText('Search').element()).toHaveClass('size-px');
    });

    it('draws every name when it is asked to', async () => {
      const screen = await render(
        <FloatingBottomNavigation value="home" labels="all">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
          <BottomNavigationItem value="search">Search</BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      expect(screen.getByText('Search').element()).not.toHaveClass('size-px');
    });

    it('keeps an undrawn name in the document, so the item still has one', async () => {
      const screen = await render(
        <FloatingBottomNavigation labels="none">
          <BottomNavigationItem value="home" icon={<svg />}>
            Home
          </BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      await expect.element(screen.getByRole('button', { name: 'Home' })).toBeInTheDocument();
      expect(screen.getByText('Home').element()).toHaveClass('size-px');
    });
  });
});
