import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { BottomNavigationItem, FloatingBottomNavigation } from 'neba';

/** Whether a destination's name is being drawn rather than merely said. */
function drawn(screen: Awaited<ReturnType<typeof render>>, name: string) {
  return screen.getByText(name).element().closest('[data-drawn]') !== null;
}

/** The highlight, which is the bar's own rather than the current item's. */
function tile(screen: Awaited<ReturnType<typeof render>>) {
  return screen
    .getByTestId('bar')
    .element()
    .querySelector<HTMLElement>(':scope > span[aria-hidden="true"]');
}

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

    // Two utilities setting `position` is a coin toss decided by the order of
    // the generated stylesheet, and the toss went the wrong way: a bar that was
    // told to pin itself to a region was laid out in the flow instead.
    it('is positioned exactly once, whatever it was told to be', async () => {
      const screen = await render(
        <FloatingBottomNavigation position="absolute" data-testid="bar">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      const bar = screen.getByTestId('bar').element();

      // No component test loads CSS, so what is checked is what was *asked*
      // for: one utility setting `position`, not two arguing about it.
      expect(bar).toHaveClass('absolute');
      expect(bar).not.toHaveClass('relative');
    });

    it('positions itself anyway when it is left in the flow, so the highlight has somewhere to sit', async () => {
      const screen = await render(
        <FloatingBottomNavigation position="static" data-testid="bar">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      expect(screen.getByTestId('bar').element()).toHaveClass('relative');
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

  describe('the highlight', () => {
    // It belongs to the bar rather than to the item that is current, which is
    // the whole of why it can travel: an item painting its own background can
    // only switch it on and off.
    it('is measured off the destination the reader is on', async () => {
      const screen = await render(
        <FloatingBottomNavigation defaultValue="home" data-testid="bar">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
          <BottomNavigationItem value="search">Search</BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      const current = screen.getByRole('button', { name: 'Home' }).element() as HTMLElement;

      await expect
        .poll(() => tile(screen)?.style.getPropertyValue('--n-nav-w'))
        .toBe(`${current.offsetWidth}px`);
      expect(tile(screen)?.style.getPropertyValue('--n-nav-x')).toBe(`${current.offsetLeft}px`);
    });

    it('travels to the destination that was pressed', async () => {
      const screen = await render(
        <FloatingBottomNavigation defaultValue="home" data-testid="bar">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
          <BottomNavigationItem value="search">Search</BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      await screen.getByRole('button', { name: 'Search' }).click();

      const next = screen.getByRole('button', { name: 'Search' }).element() as HTMLElement;

      await expect
        .poll(() => tile(screen)?.style.getPropertyValue('--n-nav-x'))
        .toBe(`${next.offsetLeft}px`);
    });

    it('is not drawn at all until a destination is current', async () => {
      const screen = await render(
        <FloatingBottomNavigation data-testid="bar">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      await expect.element(screen.getByRole('button', { name: 'Home' })).toBeInTheDocument();
      expect(tile(screen)).toBeNull();
    });

    it('leaves the item to carry the colour rather than a second fill', async () => {
      const screen = await render(
        <FloatingBottomNavigation defaultValue="home" data-testid="bar">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      expect(screen.getByRole('button', { name: 'Home' }).element()).not.toHaveClass(
        'bg-(--n-soft)'
      );
      expect(screen.getByRole('button', { name: 'Home' }).element()).toHaveClass(
        'text-(--n-accent)'
      );
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

      // A name the floating bar is not drawing is collapsed rather than
      // clipped: the box it is in travels between nothing and the width of the
      // words, which is what lets the bar re-shape itself around the
      // destination that was pressed.
      expect(drawn(screen, 'Home')).toBe(true);
      expect(drawn(screen, 'Search')).toBe(false);
    });

    it('draws every name when it is asked to', async () => {
      const screen = await render(
        <FloatingBottomNavigation value="home" labels="all">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
          <BottomNavigationItem value="search">Search</BottomNavigationItem>
        </FloatingBottomNavigation>
      );

      expect(drawn(screen, 'Search')).toBe(true);
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
      expect(drawn(screen, 'Home')).toBe(false);
    });
  });
});
