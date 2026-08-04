import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AspectRatio } from 'neba';

describe('AspectRatio', () => {
  describe('rendering', () => {
    it('renders a div holding its children', async () => {
      const screen = await render(
        <AspectRatio>
          <span>Reserved</span>
        </AspectRatio>
      );
      const box = screen.getByText('Reserved').element().parentElement as HTMLElement;

      expect(box.tagName).toBe('DIV');
      await expect.element(screen.getByText('Reserved')).toBeInTheDocument();
    });

    it('renders something else through render', async () => {
      const screen = await render(
        <AspectRatio render={<figure />}>
          <span>Reserved</span>
        </AspectRatio>
      );

      expect(screen.getByText('Reserved').element().parentElement?.tagName).toBe('FIGURE');
    });

    it('passes native attributes through', async () => {
      const screen = await render(
        <AspectRatio data-testid="box" id="hero">
          <span>Reserved</span>
        </AspectRatio>
      );

      expect(screen.getByTestId('box').element().id).toBe('hero');
    });
  });

  describe('the proportion', () => {
    // The browser normalises a bare number to a pair, so `1` reads back as
    // `1 / 1` — which is the same ratio and the same square.
    it('is square by default', async () => {
      const screen = await render(<AspectRatio data-testid="box" />);

      expect((screen.getByTestId('box').element() as HTMLElement).style.aspectRatio).toBe('1 / 1');
    });

    it('takes a number', async () => {
      const screen = await render(<AspectRatio data-testid="box" ratio={16 / 9} />);

      expect((screen.getByTestId('box').element() as HTMLElement).style.aspectRatio).not.toBe(
        '1 / 1'
      );
    });

    it('takes a CSS ratio verbatim', async () => {
      const screen = await render(<AspectRatio data-testid="box" ratio="16 / 9" />);

      expect((screen.getByTestId('box').element() as HTMLElement).style.aspectRatio).toBe('16 / 9');
    });

    it('reflects a changed ratio on re-render', async () => {
      const screen = await render(<AspectRatio data-testid="box" ratio="4 / 3" />);

      await screen.rerender(<AspectRatio data-testid="box" ratio="21 / 9" />);

      expect((screen.getByTestId('box').element() as HTMLElement).style.aspectRatio).toBe('21 / 9');
    });

    it('lets an inline style override it', async () => {
      const screen = await render(
        <AspectRatio data-testid="box" ratio="4 / 3" style={{ aspectRatio: '2' }} />
      );

      expect((screen.getByTestId('box').element() as HTMLElement).style.aspectRatio).toBe('2 / 1');
    });
  });

  describe('fit', () => {
    it('covers by default', async () => {
      const screen = await render(<AspectRatio data-testid="box" />);

      expect(screen.getByTestId('box').element()).toHaveClass('[&>img]:object-cover');
    });

    it('takes the other object-fit values', async () => {
      const screen = await render(<AspectRatio data-testid="box" fit="contain" />);

      expect(screen.getByTestId('box').element()).toHaveClass('[&>img]:object-contain');
      expect(screen.getByTestId('box').element()).not.toHaveClass('[&>img]:object-cover');
    });

    // Whatever the fit, the media has to fill the box first — `object-fit` has
    // nothing to act on until the element is the size of the proportion.
    it('stretches the media to the box whatever the fit', async () => {
      const screen = await render(<AspectRatio data-testid="box" fit="none" />);

      expect(screen.getByTestId('box').element()).toHaveClass('[&>img]:size-full');
    });
  });

  describe('rounded', () => {
    it('draws nothing by default', async () => {
      const screen = await render(<AspectRatio data-testid="box" />);

      expect(screen.getByTestId('box').element().className).not.toContain('rounded');
    });

    it('takes the size step of the radius ladder when asked', async () => {
      const screen = await render(<AspectRatio data-testid="box" rounded size="lg" />);

      expect(screen.getByTestId('box').element()).toHaveClass('rounded-(--neba-radius-lg)');
    });
  });

  it('keeps a caller class alongside its own', async () => {
    const screen = await render(<AspectRatio data-testid="box" className="w-64" />);

    expect(screen.getByTestId('box').element()).toHaveClass('w-64');
    expect(screen.getByTestId('box').element()).toHaveClass('overflow-hidden');
  });
});
