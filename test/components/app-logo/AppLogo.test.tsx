import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AppLogo } from 'neba';

describe('AppLogo', () => {
  describe('rendering', () => {
    it('is a logo with nothing but a name', async () => {
      const screen = await render(<AppLogo name="Neba" />);

      await expect.element(screen.getByText('Neba')).toBeInTheDocument();
    });

    it('draws the artwork it was handed as markup', async () => {
      const screen = await render(
        <AppLogo name="Neba" data-testid="logo">
          <svg data-testid="mark" viewBox="0 0 24 24" />
        </AppLogo>
      );

      await expect.element(screen.getByTestId('mark')).toBeInTheDocument();
    });

    it('draws an image when it is given one, named by the product', async () => {
      const screen = await render(<AppLogo src="/logo.svg" name="Neba" />);

      await expect.element(screen.getByRole('img', { name: 'Neba' })).toBeInTheDocument();
    });

    it('prefers markup to a file, so a project can inline its own mark', async () => {
      const screen = await render(
        <AppLogo src="/logo.svg" name="Neba" data-testid="logo">
          <svg data-testid="mark" viewBox="0 0 24 24" />
        </AppLogo>
      );

      await expect.element(screen.getByTestId('mark')).toBeInTheDocument();
      expect(screen.getByTestId('logo').element().querySelector('img')).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <AppLogo name="Neba" className="my-own-class" data-testid="logo" />
      );

      expect(screen.getByTestId('logo').element()).toHaveClass('my-own-class');
    });

    it('renders as another element when `render` says so', async () => {
      const screen = await render(<AppLogo name="Neba" render={<h1 />} />);

      await expect.element(screen.getByRole('heading', { name: 'Neba' })).toBeInTheDocument();
    });
  });

  describe('shape', () => {
    it('draws no tile at all on `bare`', async () => {
      const screen = await render(
        <AppLogo name="Neba" data-testid="logo">
          <svg viewBox="0 0 24 24" />
        </AppLogo>
      );

      const mark = screen.getByTestId('logo').element().firstElementChild as HTMLElement;

      expect(mark).not.toHaveClass('bg-(--n-fill)');
      expect(mark).toHaveClass('w-auto');
    });

    it('puts the artwork on a filled tile on `app`', async () => {
      const screen = await render(
        <AppLogo name="Neba" shape="app" data-testid="logo">
          <svg viewBox="0 0 24 24" />
        </AppLogo>
      );

      const mark = screen.getByTestId('logo').element().firstElementChild as HTMLElement;

      expect(mark).toHaveClass('bg-(--n-fill)');
      expect(mark.style.getPropertyValue('--n-fill')).toBe('var(--neba-primary-fill)');
    });

    it('rounds the tile all the way on `circle`', async () => {
      const screen = await render(<AppLogo name="Neba" shape="circle" data-testid="logo" />);
      const mark = screen.getByTestId('logo').element().firstElementChild as HTMLElement;

      expect(mark).toHaveClass('rounded-full');
    });

    // The inset used to be a percentage padding on the tile, and a percentage
    // padding resolves against the containing block's *width* — which is the
    // lockup, not the tile. So the same icon was held 4px off its own edges
    // alone and 11px off them with the product's name beside it, and the inset
    // grew with the length of the name.
    it('insets the artwork by a share of the tile, never by padding on it', async () => {
      const screen = await render(
        <AppLogo name="Neba Studio Cloud" shape="app" showName data-testid="logo">
          <svg viewBox="0 0 24 24" />
        </AppLogo>
      );

      const mark = screen.getByTestId('logo').element().firstElementChild as HTMLElement;

      expect(mark).toHaveClass('[&_svg]:h-[72%]');
      expect(mark.className).not.toMatch(/\bp-\[\d+(\.\d+)?%\]/);
    });

    it('lets the artwork reach the tile when it is told not to inset it', async () => {
      const screen = await render(
        <AppLogo name="Neba" shape="app" padded={false} data-testid="logo">
          <svg viewBox="0 0 24 24" />
        </AppLogo>
      );

      const mark = screen.getByTestId('logo').element().firstElementChild as HTMLElement;

      expect(mark).toHaveClass('[&_svg]:h-full');
      expect(mark).not.toHaveClass('[&_svg]:h-[72%]');
    });

    it('falls back to the name initials on a tile', async () => {
      const screen = await render(<AppLogo name="Acme Corp" shape="app" data-testid="logo" />);
      const mark = screen.getByTestId('logo').element().firstElementChild as HTMLElement;

      expect(mark.textContent).toBe('AC');
    });

    it('takes written-out initials over the ones the rule derives', async () => {
      const screen = await render(
        <AppLogo name="Acme Corp" initials="A" shape="app" data-testid="logo" />
      );
      const mark = screen.getByTestId('logo').element().firstElementChild as HTMLElement;

      expect(mark.textContent).toBe('A');
    });

    // "AC" read out loud is two letters, not a product — so once the initials
    // are standing in for a picture, the name is what is actually said.
    it('names an initials tile by the product rather than by its letters', async () => {
      const screen = await render(<AppLogo name="Acme Corp" shape="app" href="/" />);

      await expect.element(screen.getByRole('link', { name: 'Acme Corp' })).toBeInTheDocument();
    });
  });

  describe('the name', () => {
    it('draws the name beside the mark when it is asked to', async () => {
      const screen = await render(
        <AppLogo name="Neba" showName shape="app">
          <svg viewBox="0 0 24 24" />
        </AppLogo>
      );

      await expect.element(screen.getByText('Neba')).toBeInTheDocument();
    });

    // A lockup whose name is drawn is one name, not two: the picture beside the
    // words says the same thing, so it stops saying it out loud.
    it('says the name once when it is both drawn and pictured', async () => {
      const screen = await render(
        <AppLogo src="/logo.svg" name="Neba" showName data-testid="logo" />
      );
      const image = screen.getByTestId('logo').element().querySelector('img');

      expect(image).toHaveAttribute('alt', '');
      await expect.element(screen.getByText('Neba')).toBeInTheDocument();
    });

    it('names a mark made of markup for a reader who cannot see it', async () => {
      const screen = await render(
        <AppLogo name="Neba" href="/">
          <svg viewBox="0 0 24 24" />
        </AppLogo>
      );

      await expect.element(screen.getByRole('link', { name: 'Neba' })).toBeInTheDocument();
    });

    it('takes `alt` over `name` for what the artwork says', async () => {
      const screen = await render(<AppLogo src="/logo.svg" name="Neba" alt="Neba home" />);

      await expect.element(screen.getByRole('img', { name: 'Neba home' })).toBeInTheDocument();
    });
  });

  describe('href', () => {
    it('becomes a link', async () => {
      const screen = await render(<AppLogo name="Neba" href="/" />);
      const element = screen.getByRole('link', { name: 'Neba' }).element();

      expect(element.tagName).toBe('A');
      expect(element).toHaveAttribute('href', '/');
    });

    it('is a plain span without one', async () => {
      const screen = await render(<AppLogo name="Neba" data-testid="logo" />);

      expect(screen.getByTestId('logo').element().tagName).toBe('SPAN');
    });

    // The mark in a header is very often the link to the marketing site, and
    // that link is very often `target="_blank"`. The same merge a TextLink and
    // a Menu row make.
    it('merges noopener into a link that leaves this tab', async () => {
      const screen = await render(
        <AppLogo name="Neba" href="https://example.com" target="_blank" />
      );
      const rel = screen.getByRole('link').element().getAttribute('rel') ?? '';

      expect(rel.split(' ').sort()).toEqual(['noopener', 'noreferrer']);
    });

    it('keeps a rel the caller wrote alongside it', async () => {
      const screen = await render(
        <AppLogo name="Neba" href="https://example.com" target="_blank" rel="nofollow" />
      );
      const rel = screen.getByRole('link').element().getAttribute('rel') ?? '';

      expect(rel.split(' ').sort()).toEqual(['nofollow', 'noopener', 'noreferrer']);
    });

    it('leaves a link that stays in this tab alone', async () => {
      const screen = await render(<AppLogo name="Neba" href="/" />);

      expect(screen.getByRole('link').element()).not.toHaveAttribute('rel');
    });
  });

  describe('height', () => {
    it('takes an exact height over the size ladder', async () => {
      const screen = await render(<AppLogo name="Neba" height={44} data-testid="logo" />);
      const mark = screen.getByTestId('logo').element().firstElementChild as HTMLElement;

      expect(mark.style.height).toBe('44px');
      expect(mark).not.toHaveClass('h-8');
    });

    it('squares the tile at that height', async () => {
      const screen = await render(
        <AppLogo name="Neba" shape="app" height="3rem" data-testid="logo" />
      );
      const mark = screen.getByTestId('logo').element().firstElementChild as HTMLElement;

      expect(mark.style.height).toBe('3rem');
      expect(mark.style.width).toBe('3rem');
    });
  });
});
