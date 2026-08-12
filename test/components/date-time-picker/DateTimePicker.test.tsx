import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { DateTimePicker } from 'neba';

const LOCALE = 'en-US';

const JULY_27_1430 = new Date(2026, 6, 27, 14, 30);

describe('DateTimePicker', () => {
  describe('rendering', () => {
    it('renders a button named by its label', async () => {
      const screen = await render(<DateTimePicker locale={LOCALE} label="Runs at" />);

      await expect.element(screen.getByRole('button', { name: 'Runs at' })).toBeInTheDocument();
    });

    it('writes the day and the time in one string', async () => {
      const screen = await render(
        <DateTimePicker locale={LOCALE} label="Runs at" defaultValue={JULY_27_1430} />
      );

      // Matched loosely because what joins the two halves is not ours to pin:
      // `Intl` takes it from the runtime's CLDR data, and en-US glues a medium
      // date to a short time with `, ` in the ICU that Chromium, Firefox and
      // Playwright's Linux and Windows WebKit builds carry, but with ` at ` in
      // the system ICU that WebKit on macOS reads. Both are correct. The claim
      // this test makes is that the day and the time land in one text node.
      await expect.element(screen.getByText(/Jul 27, 2026.+2:30 PM/)).toBeInTheDocument();
    });

    it('opens a calendar and a clock in the same popup', async () => {
      const screen = await render(
        <DateTimePicker locale={LOCALE} label="Runs at" defaultValue={JULY_27_1430} />
      );

      await screen.getByRole('button', { name: 'Runs at' }).click();

      await expect.element(screen.getByRole('grid')).toBeInTheDocument();
      await expect.element(screen.getByRole('listbox', { name: 'Hour' })).toBeInTheDocument();
    });
  });

  describe('choosing', () => {
    it('changes the day and keeps the clock', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <DateTimePicker
          locale={LOCALE}
          label="Runs at"
          defaultValue={JULY_27_1430}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Runs at' }).click();
      await screen.getByRole('gridcell', { name: 'Wednesday, July 15, 2026' }).click();

      expect(onValueChange.mock.calls[0][0]).toEqual(new Date(2026, 6, 15, 14, 30));
    });

    it('changes the clock and keeps the day', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <DateTimePicker
          locale={LOCALE}
          label="Runs at"
          defaultValue={JULY_27_1430}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Runs at' }).click();
      await screen
        .getByRole('listbox', { name: 'Minute' })
        .getByRole('option', { name: '45' })
        .click();

      expect(onValueChange.mock.calls[0][0]).toEqual(new Date(2026, 6, 27, 14, 45));
    });

    it('stays open after a day is chosen, and closes on Done', async () => {
      const screen = await render(
        <DateTimePicker locale={LOCALE} label="Runs at" defaultValue={JULY_27_1430} />
      );

      await screen.getByRole('button', { name: 'Runs at' }).click();
      await screen.getByRole('gridcell', { name: 'Wednesday, July 15, 2026' }).click();

      // A moment is a day *and* a time. Closing on the first of the two would
      // leave the second one unanswered.
      await expect.element(screen.getByRole('listbox', { name: 'Hour' })).toBeInTheDocument();

      await screen.getByRole('button', { name: 'Done' }).click();

      await expect.poll(() => screen.getByRole('grid').query()).toBeNull();
    });
  });

  describe('bounds', () => {
    it('reads minDate at full precision', async () => {
      // The boundary day stays selectable and the hours before the minimum grey
      // out — which is the behaviour a "not before 09:30 on the 27th" rule needs
      // and the one a day-granular check cannot give.
      const screen = await render(
        <DateTimePicker
          locale={LOCALE}
          label="Runs at"
          defaultValue={new Date(2026, 6, 27, 12, 0)}
          minDate={new Date(2026, 6, 27, 9, 30)}
          hour12={false}
        />
      );

      await screen.getByRole('button', { name: 'Runs at' }).click();

      await expect
        .element(screen.getByRole('gridcell', { name: 'Monday, July 27, 2026' }))
        .not.toHaveAttribute('aria-disabled');
      await expect
        .element(screen.getByRole('gridcell', { name: 'Sunday, July 26, 2026' }))
        .toHaveAttribute('aria-disabled', 'true');

      const hours = screen.getByRole('listbox', { name: 'Hour' });
      await expect
        .element(hours.getByRole('option', { name: '08' }))
        .toHaveAttribute('aria-disabled', 'true');
      await expect
        .element(hours.getByRole('option', { name: '09' }))
        .not.toHaveAttribute('aria-disabled');
    });
  });

  describe('states', () => {
    it('submits the value as a local datetime', async () => {
      const screen = await render(
        <DateTimePicker
          locale={LOCALE}
          label="Runs at"
          name="runs_at"
          defaultValue={JULY_27_1430}
        />
      );

      expect(screen.container.querySelector<HTMLInputElement>('input[name="runs_at"]')?.value).toBe(
        '2026-07-27T14:30'
      );
    });

    it('empties the value through the clear button', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <DateTimePicker
          locale={LOCALE}
          label="Runs at"
          placeholder="Pick a moment"
          defaultValue={JULY_27_1430}
          clearable
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Clear' }).click();

      expect(onValueChange).toHaveBeenCalledWith(null);
      await expect.element(screen.getByText('Pick a moment')).toBeInTheDocument();
    });

    it('does not open when read-only', async () => {
      const screen = await render(
        <DateTimePicker locale={LOCALE} label="Runs at" defaultValue={JULY_27_1430} readOnly />
      );

      await screen.getByRole('button', { name: 'Runs at' }).click();

      expect(screen.getByRole('grid').query()).toBeNull();
    });
  });

  describe('forwarded props', () => {
    it('passes an unknown prop to the root', async () => {
      const screen = await render(<DateTimePicker data-analytics="runs-at" />);

      expect(screen.container.querySelector('[data-analytics="runs-at"]')).not.toBeNull();
    });
  });
});
