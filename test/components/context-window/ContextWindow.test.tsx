import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { ContextWindow, NebaProvider } from 'neba';

describe('ContextWindow', () => {
  describe('rendering', () => {
    it('renders a meter carrying its value and range', async () => {
      const screen = await render(<ContextWindow max={200_000} used={124_000} />);
      const meter = screen.getByRole('meter');

      await expect.element(meter).toHaveAttribute('aria-valuenow', '124000');
      await expect.element(meter).toHaveAttribute('aria-valuemin', '0');
      await expect.element(meter).toHaveAttribute('aria-valuemax', '200000');
    });

    it('writes the counts compactly', async () => {
      const screen = await render(<ContextWindow max={200_000} used={124_000} />);

      await expect.element(screen.getByText('124K of 200K')).toBeInTheDocument();
    });

    it('announces the same sentence it draws', async () => {
      const screen = await render(<ContextWindow max={200_000} used={124_000} />);

      await expect
        .element(screen.getByRole('meter'))
        .toHaveAttribute('aria-valuetext', '124K of 200K');
    });

    it('names itself when it was not given a name', async () => {
      const screen = await render(<ContextWindow max={1000} used={100} />);

      await expect.element(screen.getByText('Context')).toBeInTheDocument();
    });

    it('takes a name of its own', async () => {
      const screen = await render(<ContextWindow max={1000} used={100} label="This thread" />);

      await expect.element(screen.getByText('This thread')).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<ContextWindow max={1000} used={100} className="my-own-class" />);

      expect(screen.getByRole('meter').element()).toHaveClass('my-own-class');
    });

    it('follows a value that changes on re-render', async () => {
      const screen = await render(<ContextWindow max={200_000} used={10_000} />);

      await screen.rerender(<ContextWindow max={200_000} used={190_000} />);

      await expect.element(screen.getByRole('meter')).toHaveAttribute('aria-valuenow', '190000');
    });
  });

  describe('the split', () => {
    it('adds the parts up when it was not told a total', async () => {
      const screen = await render(
        <ContextWindow max={100_000} tokens={{ input: 40_000, output: 10_000 }} />
      );

      await expect.element(screen.getByRole('meter')).toHaveAttribute('aria-valuenow', '50000');
    });

    it('draws a row per part it was told about', async () => {
      const screen = await render(
        <ContextWindow max={100_000} tokens={{ input: 40_000, output: 10_000 }} />
      );

      await expect.element(screen.getByText('Input')).toBeInTheDocument();
      await expect.element(screen.getByText('Output')).toBeInTheDocument();
      expect(screen.getByText('Cached').query()).toBeNull();
    });

    it('draws a part that is zero, which is not the same as one that was not reported', async () => {
      const screen = await render(<ContextWindow max={100_000} tokens={{ cached: 0 }} />);

      await expect.element(screen.getByText('Cached')).toBeInTheDocument();
    });

    it('leaves the split out when it is turned off', async () => {
      const screen = await render(
        <ContextWindow max={100_000} tokens={{ input: 40_000 }} breakdown={false} />
      );

      expect(screen.getByText('Input').query()).toBeNull();
    });
  });

  describe('cost', () => {
    it('writes the money in the currency it was given', async () => {
      const screen = await render(
        <ContextWindow max={100_000} used={10_000} cost={0.42} currency="USD" />
      );

      await expect.element(screen.getByText('$0.42')).toBeInTheDocument();
      await expect.element(screen.getByText('Estimated cost')).toBeInTheDocument();
    });

    it('says nothing about money when there is none to say', async () => {
      const screen = await render(<ContextWindow max={100_000} used={10_000} />);

      expect(screen.getByText('Estimated cost').query()).toBeNull();
    });
  });

  describe('thresholds', () => {
    const thresholds = [
      { from: 70_000, color: 'warning' },
      { from: 90_000, color: 'danger' }
    ] as const;

    it('keeps its own colour below every threshold', async () => {
      const screen = await render(
        <ContextWindow max={100_000} used={40_000} thresholds={thresholds} />
      );
      const element = screen.getByRole('meter').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-primary-fill)');
    });

    it('takes the family of the last one it has reached', async () => {
      const screen = await render(
        <ContextWindow max={100_000} used={95_000} thresholds={thresholds} />
      );
      const element = screen.getByRole('meter').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-danger-fill)');
    });
  });

  describe('locale', () => {
    it('writes the counts in the language it was given', async () => {
      const screen = await render(<ContextWindow max={200_000} used={124_000} locale="de-DE" />);

      await expect.element(screen.getByText('124.000 of 200.000')).toBeInTheDocument();
    });

    it('takes the locale from a provider', async () => {
      const screen = await render(
        <NebaProvider defaults={{ locale: 'de-DE' }}>
          <ContextWindow max={100_000} used={10_000} cost={0.42} currency="EUR" />
        </NebaProvider>
      );

      await expect.element(screen.getByText('0,42 €')).toBeInTheDocument();
    });
  });
});
