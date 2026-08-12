import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { TimePicker } from 'neba';

/** Pinned, so the columns are a 12-hour dial and the trigger writes `2:30 PM`. */
const LOCALE = 'en-US';

const HALF_TWO = new Date(2026, 6, 27, 14, 30);

describe('TimePicker', () => {
  describe('rendering', () => {
    it('renders a button named by its label', async () => {
      const screen = await render(<TimePicker locale={LOCALE} label="Starts at" />);

      await expect.element(screen.getByRole('button', { name: 'Starts at' })).toBeInTheDocument();
    });

    it('shows the placeholder while nothing is chosen', async () => {
      const screen = await render(
        <TimePicker locale={LOCALE} label="Starts at" placeholder="Pick a time" />
      );

      await expect.element(screen.getByText('Pick a time')).toBeInTheDocument();
    });

    it('writes the chosen time through Intl', async () => {
      const screen = await render(
        <TimePicker locale={LOCALE} label="Starts at" defaultValue={HALF_TWO} />
      );

      await expect.element(screen.getByText('2:30 PM')).toBeInTheDocument();
    });

    it('adds the seconds to the trigger when the column is shown', async () => {
      const screen = await render(
        <TimePicker
          locale={LOCALE}
          label="Starts at"
          defaultValue={new Date(2026, 6, 27, 14, 30, 5)}
          showSeconds
        />
      );

      await expect.element(screen.getByText('2:30:05 PM')).toBeInTheDocument();
    });
  });

  describe('the columns', () => {
    it('offers hours, minutes and a meridiem on a 12-hour locale', async () => {
      const screen = await render(
        <TimePicker locale={LOCALE} label="Starts at" defaultValue={HALF_TWO} />
      );

      await screen.getByRole('button', { name: 'Starts at' }).click();

      await expect.element(screen.getByRole('listbox', { name: 'Hour' })).toBeInTheDocument();
      await expect.element(screen.getByRole('listbox', { name: 'Minute' })).toBeInTheDocument();
      await expect.element(screen.getByRole('listbox', { name: 'AM/PM' })).toBeInTheDocument();
      expect(screen.getByRole('listbox', { name: 'Second' }).query()).toBeNull();
      // 12, 1, 2 … 11 — the order a 12-hour dial is read in.
      expect(
        screen.getByRole('listbox', { name: 'Hour' }).getByRole('option').elements()
      ).toHaveLength(12);
    });

    it('drops the meridiem and runs to 24 when hour12 is off', async () => {
      const screen = await render(
        <TimePicker locale={LOCALE} label="Starts at" defaultValue={HALF_TWO} hour12={false} />
      );

      await screen.getByRole('button', { name: 'Starts at' }).click();

      expect(screen.getByRole('listbox', { name: 'AM/PM' }).query()).toBeNull();
      expect(
        screen.getByRole('listbox', { name: 'Hour' }).getByRole('option').elements()
      ).toHaveLength(24);
    });

    it('thins the minute column out by minuteStep', async () => {
      const screen = await render(
        <TimePicker locale={LOCALE} label="Starts at" defaultValue={HALF_TWO} minuteStep={15} />
      );

      await screen.getByRole('button', { name: 'Starts at' }).click();

      expect(
        screen.getByRole('listbox', { name: 'Minute' }).getByRole('option').elements()
      ).toHaveLength(4);
    });

    it('marks the row the value is on', async () => {
      const screen = await render(
        <TimePicker locale={LOCALE} label="Starts at" defaultValue={HALF_TWO} />
      );

      await screen.getByRole('button', { name: 'Starts at' }).click();

      await expect
        .element(
          screen.getByRole('listbox', { name: 'Minute' }).getByRole('option', { name: '30' })
        )
        .toHaveAttribute('aria-selected', 'true');
      await expect
        .element(screen.getByRole('listbox', { name: 'AM/PM' }).getByRole('option', { name: 'PM' }))
        .toHaveAttribute('aria-selected', 'true');
    });
  });

  describe('choosing a time', () => {
    it('reports the hour that was clicked and keeps the rest', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <TimePicker
          locale={LOCALE}
          label="Starts at"
          defaultValue={HALF_TWO}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Starts at' }).click();
      await screen
        .getByRole('listbox', { name: 'Hour' })
        .getByRole('option', { name: '5' })
        .click();

      // 5 on a PM dial is 17:00, and the minutes are untouched.
      expect(onValueChange.mock.calls[0][0]).toEqual(new Date(2026, 6, 27, 17, 30));
    });

    it('moves the whole time across the meridiem', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <TimePicker
          locale={LOCALE}
          label="Starts at"
          defaultValue={HALF_TWO}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Starts at' }).click();
      await screen
        .getByRole('listbox', { name: 'AM/PM' })
        .getByRole('option', { name: 'AM' })
        .click();

      expect(onValueChange.mock.calls[0][0]).toEqual(new Date(2026, 6, 27, 2, 30));
    });

    it('stays open while the columns are read, and closes on Done', async () => {
      const screen = await render(
        <TimePicker locale={LOCALE} label="Starts at" defaultValue={HALF_TWO} />
      );

      await screen.getByRole('button', { name: 'Starts at' }).click();
      await screen
        .getByRole('listbox', { name: 'Hour' })
        .getByRole('option', { name: '5' })
        .click();

      await expect.element(screen.getByRole('listbox', { name: 'Minute' })).toBeInTheDocument();

      await screen.getByRole('button', { name: 'Done' }).click();

      await expect.poll(() => screen.getByRole('listbox', { name: 'Minute' }).query()).toBeNull();
    });

    it('writes onto the day referenceDate names', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <TimePicker
          locale={LOCALE}
          label="Starts at"
          referenceDate={new Date(2026, 0, 2)}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Starts at' }).click();
      await screen
        .getByRole('listbox', { name: 'Minute' })
        .getByRole('option', { name: '45' })
        .click();

      const next: Date = onValueChange.mock.calls[0][0];
      expect(next.getFullYear()).toBe(2026);
      expect(next.getMonth()).toBe(0);
      expect(next.getDate()).toBe(2);
      expect(next.getMinutes()).toBe(45);
    });
  });

  describe('bounds', () => {
    it('keeps an hour that still contains an allowed minute', async () => {
      // The detail that separates a working time picker from a frustrating one:
      // 09:30 as a minimum leaves the hour 9 available and greys out the minutes
      // before half past, rather than hiding the 9 and making 9:30 unreachable.
      const screen = await render(
        <TimePicker
          locale={LOCALE}
          label="Starts at"
          defaultValue={new Date(2026, 6, 27, 9, 45)}
          minTime={new Date(2026, 6, 27, 9, 30)}
          hour12={false}
        />
      );

      await screen.getByRole('button', { name: 'Starts at' }).click();

      const hours = screen.getByRole('listbox', { name: 'Hour' });
      await expect
        .element(hours.getByRole('option', { name: '09' }))
        .not.toHaveAttribute('aria-disabled');
      await expect
        .element(hours.getByRole('option', { name: '08' }))
        .toHaveAttribute('aria-disabled', 'true');

      const minutes = screen.getByRole('listbox', { name: 'Minute' });
      await expect
        .element(minutes.getByRole('option', { name: '15' }))
        .toHaveAttribute('aria-disabled', 'true');
      await expect
        .element(minutes.getByRole('option', { name: '30' }))
        .not.toHaveAttribute('aria-disabled');
    });

    it('blocks what shouldDisableTime rejects', async () => {
      const screen = await render(
        <TimePicker
          locale={LOCALE}
          label="Starts at"
          defaultValue={HALF_TWO}
          hour12={false}
          shouldDisableTime={(value, unit) => unit === 'hour' && value.getHours() === 13}
        />
      );

      await screen.getByRole('button', { name: 'Starts at' }).click();

      await expect
        .element(screen.getByRole('listbox', { name: 'Hour' }).getByRole('option', { name: '13' }))
        .toHaveAttribute('aria-disabled', 'true');
    });
  });

  describe('states', () => {
    it('empties the value through the clear button', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <TimePicker
          locale={LOCALE}
          label="Starts at"
          placeholder="Pick a time"
          defaultValue={HALF_TWO}
          clearable
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Clear' }).click();

      expect(onValueChange).toHaveBeenCalledWith(null);
      await expect.element(screen.getByText('Pick a time')).toBeInTheDocument();
    });

    it('does not open when read-only', async () => {
      const screen = await render(
        <TimePicker locale={LOCALE} label="Starts at" defaultValue={HALF_TWO} readOnly />
      );

      await screen.getByRole('button', { name: 'Starts at' }).click();

      expect(screen.getByRole('listbox', { name: 'Hour' }).query()).toBeNull();
    });

    it('submits the value as HH:MM', async () => {
      const screen = await render(
        <TimePicker locale={LOCALE} label="Starts at" name="starts_at" defaultValue={HALF_TWO} />
      );

      expect(
        screen.container.querySelector<HTMLInputElement>('input[name="starts_at"]')?.value
      ).toBe('14:30');
    });

    it('submits the seconds too when the column is shown', async () => {
      const screen = await render(
        <TimePicker
          locale={LOCALE}
          label="Starts at"
          name="starts_at"
          showSeconds
          defaultValue={new Date(2026, 6, 27, 14, 30, 5)}
        />
      );

      expect(
        screen.container.querySelector<HTMLInputElement>('input[name="starts_at"]')?.value
      ).toBe('14:30:05');
    });
  });

  describe('forwarded props', () => {
    it('passes an unknown prop to the root', async () => {
      const screen = await render(<TimePicker data-analytics="starts-at" />);

      expect(screen.container.querySelector('[data-analytics="starts-at"]')).not.toBeNull();
    });
  });
});
