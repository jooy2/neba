import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Skeleton } from 'neba';

describe('Skeleton', () => {
  describe('rendering', () => {
    // Unlabelled it is scenery: a dozen placeholders each announcing themselves
    // is worse than silence, so the default is to say nothing at all.
    it('is hidden from the accessibility tree by default', async () => {
      const screen = await render(<Skeleton data-testid="bar" />);

      expect(screen.getByTestId('bar').element()).toHaveAttribute('aria-hidden', 'true');
      expect(screen.getByRole('status').query()).toBeNull();
    });

    // A live region is announced by what it holds, so the label is text inside
    // it rather than an `aria-label`, and `aria-busy` — which holds a region's
    // announcements back — is not on the one element meant to be heard.
    it('becomes a status that holds its label when it is given one', async () => {
      const screen = await render(<Skeleton label="Loading the report" />);
      const status = screen.getByRole('status');

      await expect.element(status).toHaveTextContent('Loading the report');
      expect(status.element()).not.toHaveAttribute('aria-busy');
      expect(status.element()).not.toHaveAttribute('aria-label');
    });

    it('holds its label beside the bars of a stack', async () => {
      const screen = await render(<Skeleton label="Loading the report" lines={3} />);
      const status = screen.getByRole('status').element();

      expect(status.textContent).toBe('Loading the report');
      expect(status.children).toHaveLength(4);
    });

    it('renders something else through render', async () => {
      const screen = await render(<Skeleton label="Loading" render={<span />} />);

      expect(screen.getByRole('status').element().tagName).toBe('SPAN');
    });
  });

  describe('shape', () => {
    it('is a line by default', async () => {
      const screen = await render(<Skeleton data-testid="bar" />);

      // The type scale as a height: a `md` placeholder occupies the em box of
      // the `md` text that replaces it.
      expect(screen.getByTestId('bar').element()).toHaveClass('h-[0.8125rem]');
    });

    it('draws a block for rect', async () => {
      const screen = await render(<Skeleton data-testid="bar" shape="rect" />);

      expect(screen.getByTestId('bar').element()).toHaveClass('h-20');
      expect(screen.getByTestId('bar').element()).toHaveClass('rounded-(--neba-radius-md)');
    });

    it('draws a circle for circle, on the same ladder an Avatar uses', async () => {
      const screen = await render(<Skeleton data-testid="bar" shape="circle" />);

      expect(screen.getByTestId('bar').element()).toHaveClass('rounded-full');
      expect(screen.getByTestId('bar').element()).toHaveClass('h-8');
      expect(screen.getByTestId('bar').element()).toHaveClass('w-8');
    });

    it('reflects a changed shape on re-render', async () => {
      const screen = await render(<Skeleton data-testid="bar" shape="line" />);

      await screen.rerender(<Skeleton data-testid="bar" shape="circle" />);

      expect(screen.getByTestId('bar').element()).toHaveClass('rounded-full');
    });
  });

  describe('lines', () => {
    it('is one bar and no wrapper at the default', async () => {
      const screen = await render(<Skeleton data-testid="bar" />);

      expect(screen.getByTestId('bar').element().children).toHaveLength(0);
      expect(screen.getByTestId('bar').element()).toHaveClass('neba-skeleton');
    });

    it('stacks one bar per line', async () => {
      const screen = await render(<Skeleton data-testid="bar" lines={4} />);

      expect(screen.getByTestId('bar').element().children).toHaveLength(4);
    });

    // The last line of a paragraph does not reach the margin, so a stack reads
    // as prose rather than as a barcode.
    it('draws the last line short', async () => {
      const screen = await render(<Skeleton data-testid="bar" lines={3} />);
      const bars = Array.from(screen.getByTestId('bar').element().children);

      expect(bars[0]).toHaveClass('w-full');
      expect(bars[2]).toHaveClass('w-3/5');
    });

    it('is ignored by the other shapes', async () => {
      const screen = await render(<Skeleton data-testid="bar" shape="circle" lines={4} />);

      expect(screen.getByTestId('bar').element().children).toHaveLength(0);
    });
  });

  describe('size and colour', () => {
    it('moves the whole ladder with size', async () => {
      const screen = await render(<Skeleton data-testid="bar" size="xl" />);

      expect(screen.getByTestId('bar').element()).toHaveClass('h-[1.0625rem]');
    });

    it('is neutral by default', async () => {
      const screen = await render(<Skeleton data-testid="bar" />);
      const bar = screen.getByTestId('bar').element() as HTMLElement;

      expect(bar.style.getPropertyValue('--n-soft-hover')).toBe('var(--neba-secondary-soft-hover)');
    });

    it('takes a colour family of its own', async () => {
      const screen = await render(<Skeleton data-testid="bar" color="info" />);
      const bar = screen.getByTestId('bar').element() as HTMLElement;

      expect(bar.style.getPropertyValue('--n-soft-hover')).toBe('var(--neba-info-soft-hover)');
    });
  });

  describe('dimensions', () => {
    it('takes a number as pixels', async () => {
      const screen = await render(<Skeleton data-testid="bar" width={240} height={16} />);
      const bar = screen.getByTestId('bar').element() as HTMLElement;

      expect(bar.style.width).toBe('240px');
      expect(bar.style.height).toBe('16px');
    });

    it('takes a string verbatim', async () => {
      const screen = await render(<Skeleton data-testid="bar" width="60%" />);

      expect((screen.getByTestId('bar').element() as HTMLElement).style.width).toBe('60%');
    });

    // A rect only falls back to a thumbnail height when nothing was said.
    it('drops the default block height once a height is given', async () => {
      const screen = await render(<Skeleton data-testid="bar" shape="rect" height={180} />);

      expect(screen.getByTestId('bar').element()).not.toHaveClass('h-20');
      expect((screen.getByTestId('bar').element() as HTMLElement).style.height).toBe('180px');
    });
  });

  describe('animated', () => {
    it('sweeps by default', async () => {
      const screen = await render(<Skeleton data-testid="bar" />);

      expect(screen.getByTestId('bar').element()).toHaveClass('neba-skeleton');
    });

    it('holds still when asked', async () => {
      const screen = await render(<Skeleton data-testid="bar" animated={false} />);

      expect(screen.getByTestId('bar').element()).not.toHaveClass('neba-skeleton');
    });

    it('drops the sweep from every bar of a stack', async () => {
      const screen = await render(<Skeleton data-testid="bar" lines={3} animated={false} />);
      const bars = Array.from(screen.getByTestId('bar').element().children);

      expect(bars.every((bar) => !bar.classList.contains('neba-skeleton'))).toBe(true);
    });
  });
});
