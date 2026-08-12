import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { DateRangePicker } from 'neba';

const LOCALE = 'en-US';

const JULY = new Date(2026, 6, 1);

describe('DateRangePicker', () => {
  describe('rendering', () => {
    it('renders a button named by its label', async () => {
      const screen = await render(<DateRangePicker locale={LOCALE} label="Stay" />);

      await expect.element(screen.getByRole('button', { name: 'Stay' })).toBeInTheDocument();
    });

    it('shows a placeholder for each end while it is unchosen', async () => {
      const screen = await render(
        <DateRangePicker
          locale={LOCALE}
          label="Stay"
          startPlaceholder="Check in"
          endPlaceholder="Check out"
        />
      );

      await expect.element(screen.getByText('Check in')).toBeInTheDocument();
      await expect.element(screen.getByText('Check out')).toBeInTheDocument();
    });

    it('writes both ends when it has them', async () => {
      const screen = await render(
        <DateRangePicker
          locale={LOCALE}
          label="Stay"
          defaultValue={{ start: new Date(2026, 6, 3), end: new Date(2026, 6, 9) }}
        />
      );

      await expect.element(screen.getByText('Jul 3, 2026')).toBeInTheDocument();
      await expect.element(screen.getByText('Jul 9, 2026')).toBeInTheDocument();
    });

    it('opens two months side by side', async () => {
      const screen = await render(
        <DateRangePicker locale={LOCALE} label="Stay" defaultMonth={JULY} />
      );

      await screen.getByRole('button', { name: 'Stay' }).click();

      expect(screen.getByRole('grid').elements()).toHaveLength(2);
      await expect
        .element(screen.getByRole('gridcell', { name: 'Saturday, August 1, 2026' }))
        .toBeInTheDocument();
    });

    it('opens one month when asked for one', async () => {
      const screen = await render(
        <DateRangePicker locale={LOCALE} label="Stay" defaultMonth={JULY} monthCount={1} />
      );

      await screen.getByRole('button', { name: 'Stay' }).click();

      expect(screen.getByRole('grid').elements()).toHaveLength(1);
    });
  });

  describe('choosing a range', () => {
    it('takes the two ends in two clicks and closes', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <DateRangePicker
          locale={LOCALE}
          label="Stay"
          defaultMonth={JULY}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Stay' }).click();
      await screen.getByRole('gridcell', { name: 'Friday, July 3, 2026' }).click();

      // Half a range: the first end is reported, the second is still open.
      expect(onValueChange.mock.calls[0][0]).toEqual({ start: new Date(2026, 6, 3), end: null });
      await expect.element(screen.getByRole('grid').first()).toBeInTheDocument();

      await screen.getByRole('gridcell', { name: 'Thursday, July 9, 2026' }).click();

      expect(onValueChange.mock.calls[1][0]).toEqual({
        start: new Date(2026, 6, 3),
        end: new Date(2026, 6, 9)
      });
      await expect.poll(() => screen.getByRole('grid').query()).toBeNull();
    });

    it('accepts the two ends in either order', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <DateRangePicker
          locale={LOCALE}
          label="Stay"
          defaultMonth={JULY}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Stay' }).click();
      await screen.getByRole('gridcell', { name: 'Thursday, July 9, 2026' }).click();
      await screen.getByRole('gridcell', { name: 'Friday, July 3, 2026' }).click();

      // Clicking backwards is not a mistake to be rejected — it is the same
      // range typed in the other order.
      expect(onValueChange.mock.calls[1][0]).toEqual({
        start: new Date(2026, 6, 3),
        end: new Date(2026, 6, 9)
      });
    });

    it('spans the two months on screen', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <DateRangePicker
          locale={LOCALE}
          label="Stay"
          defaultMonth={JULY}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Stay' }).click();
      await screen.getByRole('gridcell', { name: 'Monday, July 27, 2026' }).click();
      await screen.getByRole('gridcell', { name: 'Monday, August 3, 2026' }).click();

      expect(onValueChange.mock.calls[1][0]).toEqual({
        start: new Date(2026, 6, 27),
        end: new Date(2026, 7, 3)
      });
    });

    it('marks both ends as chosen', async () => {
      const screen = await render(
        <DateRangePicker
          locale={LOCALE}
          label="Stay"
          defaultMonth={JULY}
          defaultValue={{ start: new Date(2026, 6, 3), end: new Date(2026, 6, 9) }}
        />
      );

      await screen.getByRole('button', { name: 'Stay' }).click();

      await expect
        .element(screen.getByRole('gridcell', { name: 'Friday, July 3, 2026' }))
        .toHaveAttribute('aria-selected', 'true');
      await expect
        .element(screen.getByRole('gridcell', { name: 'Thursday, July 9, 2026' }))
        .toHaveAttribute('aria-selected', 'true');
      await expect
        .element(screen.getByRole('gridcell', { name: 'Monday, July 6, 2026' }))
        .toHaveAttribute('aria-selected', 'false');
    });

    it('starts a new range on the click after a finished one', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <DateRangePicker
          locale={LOCALE}
          label="Stay"
          defaultMonth={JULY}
          closeOnSelect={false}
          defaultValue={{ start: new Date(2026, 6, 3), end: new Date(2026, 6, 9) }}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Stay' }).click();
      await screen.getByRole('gridcell', { name: 'Monday, July 20, 2026' }).click();

      expect(onValueChange.mock.calls[0][0]).toEqual({ start: new Date(2026, 6, 20), end: null });
    });
  });

  describe('presets', () => {
    it('applies a preset and closes', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <DateRangePicker
          locale={LOCALE}
          label="Stay"
          defaultMonth={JULY}
          onValueChange={onValueChange}
          presets={[
            {
              label: 'First week',
              value: { start: new Date(2026, 6, 1), end: new Date(2026, 6, 7) }
            }
          ]}
        />
      );

      await screen.getByRole('button', { name: 'Stay' }).click();
      await screen.getByRole('button', { name: 'First week' }).click();

      expect(onValueChange).toHaveBeenCalledWith({
        start: new Date(2026, 6, 1),
        end: new Date(2026, 6, 7)
      });
    });

    it('calls a preset that is a function, so it is computed when pressed', async () => {
      const onValueChange = vi.fn();
      const build = vi.fn(() => ({ start: new Date(2026, 6, 1), end: new Date(2026, 6, 7) }));
      const screen = await render(
        <DateRangePicker
          locale={LOCALE}
          label="Stay"
          defaultMonth={JULY}
          onValueChange={onValueChange}
          presets={[{ label: 'Last 7 days', value: build }]}
        />
      );

      await screen.getByRole('button', { name: 'Stay' }).click();

      expect(build).not.toHaveBeenCalled();

      await screen.getByRole('button', { name: 'Last 7 days' }).click();

      expect(build).toHaveBeenCalledTimes(1);
      expect(onValueChange).toHaveBeenCalled();
    });
  });

  describe('states', () => {
    it('marks days outside the bounds unavailable in both panels', async () => {
      const screen = await render(
        <DateRangePicker
          locale={LOCALE}
          label="Stay"
          defaultMonth={JULY}
          minDate={new Date(2026, 6, 10)}
          maxDate={new Date(2026, 7, 5)}
        />
      );

      await screen.getByRole('button', { name: 'Stay' }).click();

      await expect
        .element(screen.getByRole('gridcell', { name: 'Friday, July 3, 2026' }))
        .toHaveAttribute('aria-disabled', 'true');
      await expect
        .element(screen.getByRole('gridcell', { name: 'Monday, August 10, 2026' }))
        .toHaveAttribute('aria-disabled', 'true');
      await expect
        .element(screen.getByRole('gridcell', { name: 'Monday, July 20, 2026' }))
        .not.toHaveAttribute('aria-disabled');
    });

    it('empties both ends through the clear button', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <DateRangePicker
          locale={LOCALE}
          label="Stay"
          startPlaceholder="Check in"
          defaultValue={{ start: new Date(2026, 6, 3), end: new Date(2026, 6, 9) }}
          clearable
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Clear' }).click();

      expect(onValueChange).toHaveBeenCalledWith({ start: null, end: null });
      await expect.element(screen.getByText('Check in')).toBeInTheDocument();
    });

    it('submits the two ends under one name', async () => {
      const screen = await render(
        <DateRangePicker
          locale={LOCALE}
          label="Stay"
          name="stay"
          defaultValue={{ start: new Date(2026, 6, 3), end: new Date(2026, 6, 9) }}
        />
      );

      const values = [
        ...screen.container.querySelectorAll<HTMLInputElement>('input[name="stay"]')
      ].map((input) => input.value);

      expect(values).toEqual(['2026-07-03', '2026-07-09']);
    });

    it('does not open when read-only', async () => {
      const screen = await render(
        <DateRangePicker
          locale={LOCALE}
          label="Stay"
          defaultValue={{ start: new Date(2026, 6, 3), end: new Date(2026, 6, 9) }}
          readOnly
        />
      );

      await screen.getByRole('button', { name: 'Stay' }).click();

      expect(screen.getByRole('grid').query()).toBeNull();
    });
  });

  describe('forwarded props', () => {
    it('passes an unknown prop to the root', async () => {
      const screen = await render(<DateRangePicker data-analytics="span" />);

      expect(screen.container.querySelector('[data-analytics="span"]')).not.toBeNull();
    });
  });
});
