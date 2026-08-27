import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Header } from 'neba';

describe('Header', () => {
  describe('rendering', () => {
    it('renders a banner landmark', async () => {
      const screen = await render(<Header>Docs</Header>);
      const element = screen.getByRole('banner').element();

      expect(element.tagName).toBe('HEADER');
    });

    it('names the landmark when it is given a label', async () => {
      const screen = await render(<Header label="Site" />);

      await expect.element(screen.getByRole('banner', { name: 'Site' })).toBeInTheDocument();
    });

    it('draws all three slots', async () => {
      const screen = await render(
        <Header brand={<span>Neba</span>} actions={<button type="button">Sign in</button>}>
          <a href="/docs">Docs</a>
        </Header>
      );

      await expect.element(screen.getByText('Neba')).toBeInTheDocument();
      await expect.element(screen.getByRole('link', { name: 'Docs' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Sign in' })).toBeInTheDocument();
    });

    it('draws nothing for a slot it was given nothing for', async () => {
      const screen = await render(<Header data-testid="bar">Docs</Header>);
      const row = screen.getByTestId('bar').element().firstElementChild as HTMLElement;

      expect(row.children).toHaveLength(1);
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Header className="my-own-class" />);

      expect(screen.getByRole('banner').element()).toHaveClass('my-own-class');
    });

    it('renders as another element when `render` says so', async () => {
      const screen = await render(<Header render={<div />} data-testid="bar" />);

      expect(screen.getByTestId('bar').element().tagName).toBe('DIV');
    });
  });

  describe('align', () => {
    // Centring the middle in the space *left over* puts it wherever the brand
    // happens to end, so both ends are given equal shares instead.
    it('gives both ends an equal share so the middle lands on the midline', async () => {
      const screen = await render(
        <Header align="center" brand={<span>Neba</span>} actions={<span>Sign in</span>}>
          Docs
        </Header>
      );

      const row = screen.getByRole('banner').element().firstElementChild as HTMLElement;
      const [start, , end] = Array.from(row.children) as HTMLElement[];

      expect(start.getBoundingClientRect().width).toBeCloseTo(end.getBoundingClientRect().width, 0);
    });

    it('keeps the ends in place even when one of them is empty', async () => {
      const screen = await render(
        <Header align="center" actions={<span>Sign in</span>}>
          Docs
        </Header>
      );

      const row = screen.getByRole('banner').element().firstElementChild as HTMLElement;

      expect(row.children).toHaveLength(3);
    });

    it('packs the middle against the brand by default', async () => {
      const screen = await render(<Header brand={<span>Neba</span>}>Docs</Header>);
      const row = screen.getByRole('banner').element().firstElementChild as HTMLElement;

      expect(row.children[0]).toHaveClass('shrink-0');
    });
  });

  describe('position', () => {
    it('is sticky against the top of the window by default', async () => {
      const screen = await render(<Header />);

      expect(screen.getByRole('banner').element()).toHaveClass('sticky', 'top-0');
    });

    it('scrolls away with the page when it is static', async () => {
      const screen = await render(<Header position="static" />);
      const element = screen.getByRole('banner').element();

      expect(element).not.toHaveClass('sticky');
      expect(element).not.toHaveClass('fixed');
    });

    it('leaves the flow when it is fixed', async () => {
      const screen = await render(<Header position="fixed" />);

      expect(screen.getByRole('banner').element()).toHaveClass('fixed', 'top-0');
    });
  });

  describe('appearance', () => {
    it('draws a hairline along the bottom edge by default', async () => {
      const screen = await render(<Header />);

      expect(screen.getByRole('banner').element()).toHaveClass('border-b');
    });

    it('drops the hairline when it is turned off', async () => {
      const screen = await render(<Header divider={false} />);

      expect(screen.getByRole('banner').element()).not.toHaveClass('border-b');
    });

    it('holds the row to a measure without narrowing the sheet', async () => {
      const screen = await render(<Header maxWidth="lg" />);
      const element = screen.getByRole('banner').element();
      const row = element.firstElementChild as HTMLElement;

      expect(element).toHaveClass('w-full');
      expect(row).toHaveClass('max-w-[64rem]', 'mx-auto');
    });

    it('carries the colour family in its slots rather than in its fill', async () => {
      const screen = await render(<Header color="success" />);
      const element = screen.getByRole('banner').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-line')).toBe('var(--neba-success-line)');
      expect(element.style.getPropertyValue('--n-panel')).toBe('var(--neba-panel)');
    });
  });
});
