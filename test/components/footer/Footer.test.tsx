import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Footer } from 'neba';

describe('Footer', () => {
  describe('rendering', () => {
    it('renders a contentinfo landmark', async () => {
      const screen = await render(<Footer>© Neba</Footer>);
      const element = screen.getByRole('contentinfo').element();

      expect(element.tagName).toBe('FOOTER');
    });

    it('names the landmark when it is given a label', async () => {
      const screen = await render(<Footer label="Site" />);

      await expect.element(screen.getByRole('contentinfo', { name: 'Site' })).toBeInTheDocument();
    });

    it('draws whatever it was handed, with no slots of its own', async () => {
      const screen = await render(
        <Footer>
          <a href="/privacy">Privacy</a>
        </Footer>
      );

      await expect.element(screen.getByRole('link', { name: 'Privacy' })).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Footer className="my-own-class" />);

      expect(screen.getByRole('contentinfo').element()).toHaveClass('my-own-class');
    });

    it('renders as another element when `render` says so', async () => {
      const screen = await render(<Footer render={<div />} data-testid="bar" />);

      expect(screen.getByTestId('bar').element().tagName).toBe('DIV');
    });
  });

  describe('position', () => {
    // The opposite default from Header's: a footer is the thing at the end of
    // the document, reached by scrolling to it.
    it('sits in the flow by default', async () => {
      const screen = await render(<Footer />);
      const element = screen.getByRole('contentinfo').element();

      expect(element).not.toHaveClass('sticky');
      expect(element).not.toHaveClass('fixed');
    });

    it('holds the bottom edge when it is asked to', async () => {
      const screen = await render(<Footer position="sticky" />);

      expect(screen.getByRole('contentinfo').element()).toHaveClass('sticky', 'bottom-0');
    });

    it('leaves the flow when it is fixed', async () => {
      const screen = await render(<Footer position="fixed" />);

      expect(screen.getByRole('contentinfo').element()).toHaveClass('fixed', 'bottom-0');
    });
  });

  describe('appearance', () => {
    it('draws a hairline along the top edge by default', async () => {
      const screen = await render(<Footer />);

      expect(screen.getByRole('contentinfo').element()).toHaveClass('border-t');
    });

    it('holds the content to a measure without narrowing the sheet', async () => {
      const screen = await render(<Footer maxWidth="md" />);
      const inner = screen.getByRole('contentinfo').element().firstElementChild as HTMLElement;

      expect(inner).toHaveClass('max-w-(--n-max-w)', 'mx-auto');
      expect(inner.style.getPropertyValue('--n-max-w-xs')).toBe('48rem');
    });

    it('drops the gutter when it is turned off', async () => {
      const screen = await render(<Footer padded={false} />);
      const inner = screen.getByRole('contentinfo').element().firstElementChild as HTMLElement;

      expect(inner).not.toHaveClass('px-4');
    });
  });
});
