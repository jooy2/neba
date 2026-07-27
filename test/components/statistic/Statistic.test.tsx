import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Statistic } from 'neba';

describe('Statistic', () => {
  describe('rendering', () => {
    it('renders its label and its value', async () => {
      const screen = await render(<Statistic label="Active users" value={128} />);

      await expect.element(screen.getByText('Active users')).toBeInTheDocument();
      await expect.element(screen.getByText('128')).toBeInTheDocument();
    });

    it('reflects a changed value on re-render', async () => {
      const screen = await render(<Statistic label="Active users" value={128} />);

      await screen.rerender(<Statistic label="Active users" value={256} />);

      await expect.element(screen.getByText('256')).toBeInTheDocument();
      expect(screen.getByText('128').query()).toBeNull();
    });

    it('prints a string value exactly as given', async () => {
      const screen = await render(<Statistic label="Median build" value="3h 42m" />);

      await expect.element(screen.getByText('3h 42m')).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <Statistic label="Active users" value={1} className="my-own-class" />
      );

      expect(screen.getByText('Active users').element().closest('.my-own-class')).not.toBeNull();
    });
  });

  describe('formatting', () => {
    it('groups a large number rather than printing its digits bare', async () => {
      const screen = await render(<Statistic label="Requests" value={1234567} />);

      // Which separator it is belongs to the reader's locale; that there is one
      // at all is ours.
      expect(screen.getByText('1234567').query()).toBeNull();
      await expect.element(screen.getByText(/^1.234.567$/)).toBeInTheDocument();
    });

    it('passes format straight through to Intl.NumberFormat', async () => {
      const screen = await render(
        <Statistic
          label="Conversion"
          value={0.4237}
          format={{ style: 'percent', maximumFractionDigits: 1 }}
        />
      );

      // The digits and the sign are ours; the space before the `%` is the
      // locale's, and some of them put one there.
      await expect.element(screen.getByText(/^42.4\s?%$/)).toBeInTheDocument();
    });

    it('sets a prefix before the figure and a unit after it', async () => {
      const screen = await render(<Statistic label="Storage" value={42} prefix="~" unit="GB" />);

      await expect.element(screen.getByText('~')).toBeInTheDocument();
      await expect.element(screen.getByText('GB')).toBeInTheDocument();
    });
  });

  describe('comparison', () => {
    it('shows no delta without a previousValue', async () => {
      const screen = await render(<Statistic label="Active users" value={120} />);

      expect(screen.getByText(/%$/).query()).toBeNull();
    });

    it('writes the change as a percentage of the previous figure', async () => {
      const screen = await render(
        <Statistic label="Active users" value={120} previousValue={100} />
      );

      await expect.element(screen.getByText('+20%')).toBeInTheDocument();
    });

    it('writes the difference itself when asked for it', async () => {
      const screen = await render(
        <Statistic label="Active users" value={120} previousValue={100} delta="absolute" />
      );

      await expect.element(screen.getByText('+20')).toBeInTheDocument();
    });

    it('signs a fall and leaves a flat figure unsigned', async () => {
      const screen = await render(
        <Statistic label="Active users" value={80} previousValue={100} />
      );

      await expect.element(screen.getByText('-20%')).toBeInTheDocument();

      await screen.rerender(<Statistic label="Active users" value={100} previousValue={100} />);

      await expect.element(screen.getByText('0%')).toBeInTheDocument();
    });

    it('falls back to the difference when there is no previous figure to divide by', async () => {
      const screen = await render(<Statistic label="Signups" value={12} previousValue={0} />);

      await expect.element(screen.getByText('+12')).toBeInTheDocument();
    });

    it('colours a rise as good by default and as bad when lower is better', async () => {
      const screen = await render(<Statistic label="Churn" value={120} previousValue={100} />);
      const chip = screen.getByText('+20%').element().closest('[style]') as HTMLElement;

      expect(chip.style.getPropertyValue('--n-accent')).toBe('var(--neba-success-accent)');

      await screen.rerender(
        <Statistic label="Churn" value={120} previousValue={100} betterWhen="down" />
      );

      const worse = screen.getByText('+20%').element().closest('[style]') as HTMLElement;
      expect(worse.style.getPropertyValue('--n-accent')).toBe('var(--neba-danger-accent)');
    });

    it('leaves the delta out entirely when told to', async () => {
      const screen = await render(
        <Statistic label="Active users" value={120} previousValue={100} delta="none" />
      );

      expect(screen.getByText('+20%').query()).toBeNull();
    });
  });

  describe('style props', () => {
    it('takes the surface slots of the container it is', async () => {
      const screen = await render(
        <Statistic label="Active users" value={1} color="info" data-testid="stat" />
      );
      const element = screen.getByTestId('stat').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-line')).toBe('var(--neba-info-line)');
      // A container's sheet stays undyed, exactly as on Box.
      expect(element.style.getPropertyValue('--n-panel')).toBe('var(--neba-panel)');
    });

    it('changes only the padding with density', async () => {
      const screen = await render(
        <Statistic label="Active users" value={1} size="md" data-testid="stat" />
      );
      const element = screen.getByTestId('stat').element();

      expect(element).toHaveClass('p-4');

      await screen.rerender(
        <Statistic label="Active users" value={1} size="md" density="compact" data-testid="stat" />
      );

      expect(element).toHaveClass('p-2.5');
    });
  });
});
