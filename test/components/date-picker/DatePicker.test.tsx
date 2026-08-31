import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
import { DatePicker } from 'neba';

/**
 * Every test pins `locale` to `en-US`. The component reads month names, weekday
 * names, the header's word order and the trigger's format out of `Intl`, so a
 * test that let the browser choose would assert one thing on a developer's
 * machine and another in CI.
 */
const LOCALE = 'en-US';

/** A Monday, chosen so the grid's leading and trailing weeks are both non-empty. */
const JULY_27 = new Date(2026, 6, 27);

describe('DatePicker', () => {
  describe('rendering', () => {
    it('renders a button named by its label', async () => {
      const screen = await render(<DatePicker locale={LOCALE} label="Ships on" />);

      await expect.element(screen.getByRole('button', { name: 'Ships on' })).toBeInTheDocument();
    });

    it('shows the placeholder while nothing is chosen', async () => {
      const screen = await render(
        <DatePicker locale={LOCALE} label="Ships on" placeholder="Pick a day" />
      );

      await expect.element(screen.getByText('Pick a day')).toBeInTheDocument();
    });

    it('writes the chosen day through Intl', async () => {
      const screen = await render(
        <DatePicker locale={LOCALE} label="Ships on" defaultValue={JULY_27} />
      );

      await expect.element(screen.getByText('Jul 27, 2026')).toBeInTheDocument();
    });

    it('honours a format', async () => {
      const screen = await render(
        <DatePicker
          locale={LOCALE}
          label="Ships on"
          defaultValue={JULY_27}
          format={{ dateStyle: 'full' }}
        />
      );

      await expect.element(screen.getByText('Monday, July 27, 2026')).toBeInTheDocument();
    });

    it('renders the description', async () => {
      const screen = await render(
        <DatePicker locale={LOCALE} label="Ships on" description="Local time." />
      );

      await expect.element(screen.getByText('Local time.')).toBeInTheDocument();
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(<DatePicker locale={LOCALE} label="Before" />);

      await screen.rerender(<DatePicker locale={LOCALE} label="After" />);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names on the field wrapper', async () => {
      const screen = await render(
        <DatePicker locale={LOCALE} label="Ships on" className="my-own-class" />
      );

      expect(screen.getByText('Ships on').element().closest('.my-own-class')).not.toBeNull();
    });

    it('renders nothing of the calendar until it is open', async () => {
      const screen = await render(<DatePicker locale={LOCALE} label="Ships on" />);

      expect(screen.getByRole('grid').query()).toBeNull();
    });
  });

  describe('choosing a day', () => {
    it('opens the calendar on the month of the value', async () => {
      const screen = await render(
        <DatePicker locale={LOCALE} label="Ships on" defaultValue={JULY_27} />
      );

      await screen.getByRole('button', { name: 'Ships on' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Choose a month' }))
        .toHaveTextContent('July');
      await expect
        .element(screen.getByRole('gridcell', { name: 'Monday, July 27, 2026' }))
        .toHaveAttribute('aria-selected', 'true');
    });

    it('reports the day that was clicked and closes', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <DatePicker
          locale={LOCALE}
          label="Ships on"
          defaultValue={JULY_27}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Ships on' }).click();
      await screen.getByRole('gridcell', { name: 'Wednesday, July 15, 2026' }).click();

      expect(onValueChange).toHaveBeenCalledTimes(1);
      expect(onValueChange.mock.calls[0][0]).toEqual(new Date(2026, 6, 15));
      await expect.element(screen.getByText('Jul 15, 2026')).toBeInTheDocument();
      await expect.poll(() => screen.getByRole('grid').query()).toBeNull();
    });

    it('stays open when closeOnSelect is off', async () => {
      const screen = await render(
        <DatePicker locale={LOCALE} label="Ships on" defaultValue={JULY_27} closeOnSelect={false} />
      );

      await screen.getByRole('button', { name: 'Ships on' }).click();
      await screen.getByRole('gridcell', { name: 'Wednesday, July 15, 2026' }).click();

      await expect.element(screen.getByRole('grid')).toBeInTheDocument();
    });

    it('keeps the time of day the value already carried', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <DatePicker
          locale={LOCALE}
          label="Ships on"
          defaultValue={new Date(2026, 6, 27, 14, 30)}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Ships on' }).click();
      await screen.getByRole('gridcell', { name: 'Wednesday, July 15, 2026' }).click();

      expect(onValueChange.mock.calls[0][0]).toEqual(new Date(2026, 6, 15, 14, 30));
    });

    it('leaves a controlled value alone until the caller changes it', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <DatePicker
          locale={LOCALE}
          label="Ships on"
          value={JULY_27}
          onValueChange={onValueChange}
          closeOnSelect={false}
        />
      );

      await screen.getByRole('button', { name: 'Ships on' }).click();
      await screen.getByRole('gridcell', { name: 'Wednesday, July 15, 2026' }).click();

      expect(onValueChange).toHaveBeenCalled();
      await expect.element(screen.getByText('Jul 27, 2026')).toBeInTheDocument();
    });
  });

  describe('reaching another month and year', () => {
    it('steps a month with the header arrows', async () => {
      const screen = await render(
        <DatePicker locale={LOCALE} label="Ships on" defaultValue={JULY_27} />
      );

      await screen.getByRole('button', { name: 'Ships on' }).click();
      await screen.getByRole('button', { name: 'Next month' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Choose a month' }))
        .toHaveTextContent('August');
    });

    it('opens the month grid and picks a month', async () => {
      const screen = await render(
        <DatePicker locale={LOCALE} label="Ships on" defaultValue={JULY_27} />
      );

      await screen.getByRole('button', { name: 'Ships on' }).click();
      await screen.getByRole('button', { name: 'Choose a month' }).click();
      await screen.getByRole('gridcell', { name: 'November 2026' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Choose a month' }))
        .toHaveTextContent('November');
      // Back in day view, so the days of November are on screen.
      await expect
        .element(screen.getByRole('gridcell', { name: 'Sunday, November 1, 2026' }))
        .toBeInTheDocument();
    });

    it('opens the year grid and picks a year', async () => {
      const screen = await render(
        <DatePicker locale={LOCALE} label="Ships on" defaultValue={JULY_27} />
      );

      await screen.getByRole('button', { name: 'Ships on' }).click();
      await screen.getByRole('button', { name: 'Choose a year' }).click();

      await expect.element(screen.getByRole('gridcell', { name: '2020' })).toBeInTheDocument();

      await screen.getByRole('gridcell', { name: '2020' }).click();

      // Year view hands over to month view rather than all the way back to days:
      // having just said which year, the next question is which month.
      await expect
        .element(screen.getByRole('button', { name: 'Choose a year' }))
        .toHaveTextContent('2020');
      await expect
        .element(screen.getByRole('gridcell', { name: 'March 2020' }))
        .toBeInTheDocument();
    });
  });

  /**
   * The header's month and year grids were only ever a way of reaching a day.
   * `granularity` makes one of them the answer: the calendar opens on that grid
   * and a click there commits rather than descending. Everything the picker
   * says about the value follows it — the trigger's format, the footer's
   * shortcut, the hidden input, and the unit the bounds are read at.
   */
  describe('granularity', () => {
    it('opens on the month grid and commits the 1st of the month it was given', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <DatePicker
          locale={LOCALE}
          label="Ships in"
          granularity="month"
          defaultValue={JULY_27}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Ships in' }).click();

      // No day view to be seen: the months are what is on screen.
      await expect
        .element(screen.getByRole('gridcell', { name: 'November 2026' }))
        .toBeInTheDocument();
      expect(screen.getByRole('gridcell', { name: 'Monday, July 27, 2026' }).query()).toBeNull();

      await screen.getByRole('gridcell', { name: 'November 2026' }).click();

      expect(onValueChange).toHaveBeenCalledTimes(1);
      expect(onValueChange.mock.calls[0][0]).toEqual(new Date(2026, 10, 1));
      await expect.poll(() => screen.getByRole('grid').query()).toBeNull();
    });

    it('opens on the year grid and commits the 1st of January', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <DatePicker
          locale={LOCALE}
          label="Vintage"
          granularity="year"
          defaultValue={JULY_27}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Vintage' }).click();
      await screen.getByRole('gridcell', { name: '2020' }).click();

      expect(onValueChange.mock.calls[0][0]).toEqual(new Date(2020, 0, 1));
    });

    it('still climbs to the year grid, and comes back without committing', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <DatePicker
          locale={LOCALE}
          label="Ships in"
          granularity="month"
          defaultValue={JULY_27}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Ships in' }).click();
      await screen.getByRole('button', { name: 'Choose a year' }).click();
      await screen.getByRole('gridcell', { name: '2020' }).click();

      // A year is one half of the answer, so it hands back to the month grid.
      expect(onValueChange).not.toHaveBeenCalled();
      await expect
        .element(screen.getByRole('gridcell', { name: 'March 2020' }))
        .toBeInTheDocument();

      await screen.getByRole('gridcell', { name: 'March 2020' }).click();

      expect(onValueChange.mock.calls[0][0]).toEqual(new Date(2020, 2, 1));
    });

    it('writes the trigger at the unit it asked for', async () => {
      const screen = await render(
        <DatePicker locale={LOCALE} label="Ships in" granularity="month" defaultValue={JULY_27} />
      );

      await expect.element(screen.getByText('July 2026')).toBeInTheDocument();

      await screen.rerender(
        <DatePicker locale={LOCALE} label="Ships in" granularity="year" defaultValue={JULY_27} />
      );

      await expect.element(screen.getByText('2026')).toBeInTheDocument();
    });

    it('lets a format override the unit default', async () => {
      const screen = await render(
        <DatePicker
          locale={LOCALE}
          label="Ships in"
          granularity="month"
          defaultValue={JULY_27}
          format={{ year: 'numeric', month: 'short' }}
        />
      );

      await expect.element(screen.getByText('Jul 2026')).toBeInTheDocument();
    });

    it('names the footer shortcut after the unit', async () => {
      const screen = await render(
        <DatePicker locale={LOCALE} label="Ships in" granularity="month" />
      );

      await screen.getByRole('button', { name: 'Ships in' }).click();

      await expect.element(screen.getByRole('button', { name: 'This month' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Today' }).query()).toBeNull();
    });

    it('commits the current month from the footer shortcut', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <DatePicker
          locale={LOCALE}
          label="Ships in"
          granularity="month"
          defaultMonth={JULY_27}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Ships in' }).click();
      await screen.getByRole('button', { name: 'This month' }).click();

      const now = new Date();
      expect(onValueChange.mock.calls[0][0]).toEqual(
        new Date(now.getFullYear(), now.getMonth(), 1)
      );
    });

    it('submits YYYY-MM and YYYY rather than a day nobody chose', async () => {
      const screen = await render(
        <DatePicker
          locale={LOCALE}
          label="Ships in"
          granularity="month"
          name="ships_in"
          defaultValue={JULY_27}
        />
      );

      const named = () =>
        screen.container.querySelector<HTMLInputElement>('input[name="ships_in"]');
      expect(named()?.value).toBe('2026-07');

      await screen.rerender(
        <DatePicker
          locale={LOCALE}
          label="Ships in"
          granularity="year"
          name="ships_in"
          defaultValue={JULY_27}
        />
      );

      expect(named()?.value).toBe('2026');
    });

    it('reads the bounds at the unit, so a month a minimum starts inside stays open', async () => {
      const screen = await render(
        <DatePicker
          locale={LOCALE}
          label="Ships in"
          granularity="month"
          defaultValue={JULY_27}
          minDate={new Date(2026, 6, 20)}
        />
      );

      await screen.getByRole('button', { name: 'Ships in' }).click();

      // July has days left after the 20th, so July is still an answer.
      await expect
        .element(screen.getByRole('gridcell', { name: 'July 2026' }))
        .not.toHaveAttribute('aria-disabled');
      await expect
        .element(screen.getByRole('gridcell', { name: 'June 2026' }))
        .toHaveAttribute('aria-disabled', 'true');
    });

    it('hands shouldDisableDate the 1st of each month, and only at that unit', async () => {
      const seen: Date[] = [];
      const screen = await render(
        <DatePicker
          locale={LOCALE}
          label="Ships in"
          granularity="month"
          defaultValue={JULY_27}
          shouldDisableDate={(date) => {
            seen.push(date);
            return date.getMonth() === 10;
          }}
        />
      );

      await screen.getByRole('button', { name: 'Ships in' }).click();

      await expect
        .element(screen.getByRole('gridcell', { name: 'November 2026' }))
        .toHaveAttribute('aria-disabled', 'true');
      await expect
        .element(screen.getByRole('gridcell', { name: 'July 2026' }))
        .not.toHaveAttribute('aria-disabled');
      expect(seen.every((date) => date.getDate() === 1)).toBe(true);
    });
  });

  describe('bounds', () => {
    it('marks days before minDate unavailable', async () => {
      const screen = await render(
        <DatePicker
          locale={LOCALE}
          label="Ships on"
          defaultValue={JULY_27}
          minDate={new Date(2026, 6, 20)}
        />
      );

      await screen.getByRole('button', { name: 'Ships on' }).click();

      await expect
        .element(screen.getByRole('gridcell', { name: 'Wednesday, July 15, 2026' }))
        .toHaveAttribute('aria-disabled', 'true');
      await expect
        .element(screen.getByRole('gridcell', { name: 'Monday, July 20, 2026' }))
        .not.toHaveAttribute('aria-disabled');
    });

    it('blocks the days shouldDisableDate rejects and leaves the rest alone', async () => {
      const screen = await render(
        <DatePicker
          locale={LOCALE}
          label="Ships on"
          defaultValue={JULY_27}
          shouldDisableDate={(date) => date.getDay() === 3}
        />
      );

      await screen.getByRole('button', { name: 'Ships on' }).click();

      await expect
        .element(screen.getByRole('gridcell', { name: 'Wednesday, July 15, 2026' }))
        .toHaveAttribute('aria-disabled', 'true');
      await expect
        .element(screen.getByRole('gridcell', { name: 'Friday, July 3, 2026' }))
        .not.toHaveAttribute('aria-disabled');
    });

    it('keeps a blocked day in the arrow-key path rather than in a hole', async () => {
      // A blocked cell carries `aria-disabled`, never the `disabled` attribute:
      // a disabled button leaves the tab order and the grid's arrow-key path
      // with it, so a reader would fall into a hole at every blocked day.
      const screen = await render(
        <DatePicker
          locale={LOCALE}
          label="Ships on"
          defaultValue={JULY_27}
          shouldDisableDate={(date) => date.getDay() === 3}
        />
      );

      await screen.getByRole('button', { name: 'Ships on' }).click();

      const cell = screen.getByRole('gridcell', { name: 'Wednesday, July 15, 2026' });
      await expect.element(cell).toHaveAttribute('aria-disabled', 'true');
      expect(cell.element().hasAttribute('disabled')).toBe(false);
    });
  });

  describe('states', () => {
    it('empties the value through the clear button', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <DatePicker
          locale={LOCALE}
          label="Ships on"
          placeholder="Pick a day"
          defaultValue={JULY_27}
          clearable
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Clear' }).click();

      expect(onValueChange).toHaveBeenCalledWith(null);
      await expect.element(screen.getByText('Pick a day')).toBeInTheDocument();
    });

    it('does not open when read-only', async () => {
      const screen = await render(
        <DatePicker locale={LOCALE} label="Ships on" defaultValue={JULY_27} readOnly />
      );

      await screen.getByRole('button', { name: 'Ships on' }).click();

      expect(screen.getByRole('grid').query()).toBeNull();
    });

    it('does not open when disabled', async () => {
      const screen = await render(
        <DatePicker locale={LOCALE} label="Ships on" defaultValue={JULY_27} disabled />
      );

      await expect.element(screen.getByRole('button', { name: 'Ships on' })).toBeDisabled();
      expect(screen.getByRole('grid').query()).toBeNull();
    });

    it('turns the field invalid when there is an error', async () => {
      const screen = await render(
        <DatePicker locale={LOCALE} label="Ships on" error="Pick a weekday." />
      );

      await expect.element(screen.getByText('Pick a weekday.')).toBeInTheDocument();
      await expect
        .element(screen.getByRole('button', { name: 'Ships on' }))
        .toHaveAttribute('aria-invalid', 'true');
    });

    it('submits the value as YYYY-MM-DD', async () => {
      const screen = await render(
        <DatePicker locale={LOCALE} label="Ships on" name="ships_on" defaultValue={JULY_27} />
      );

      const hidden = screen.container.querySelector<HTMLInputElement>('input[name="ships_on"]');
      expect(hidden?.value).toBe('2026-07-27');
    });
  });

  describe('keyboard', () => {
    it('walks the grid with the arrow keys and follows into the next month', async () => {
      const screen = await render(
        <DatePicker locale={LOCALE} label="Ships on" defaultValue={new Date(2026, 6, 30)} />
      );

      await screen.getByRole('button', { name: 'Ships on' }).click();

      // The calendar takes the focus itself, on the chosen day. Waiting for the
      // focus rather than for the markup: a key pressed before it lands goes
      // wherever the focus still was.
      await expect
        .poll(() => document.activeElement?.getAttribute('aria-label'))
        .toBe('Thursday, July 30, 2026');

      await userEvent.keyboard('{ArrowDown}');

      await expect
        .poll(() => document.activeElement?.getAttribute('aria-label'))
        .toBe('Thursday, August 6, 2026');
      await expect
        .element(screen.getByRole('button', { name: 'Choose a month' }))
        .toHaveTextContent('August');
    });
  });

  /**
   * A picker that is not `fullWidth` is sized by what it currently says, and
   * `Jul 1, 2026` is fourteen pixels narrower than `Sep 28, 2026` — so the field
   * jumped every time a date was chosen, taking the row beside it along. The
   * trigger holds every date it could show, laid out and shown to nobody.
   *
   * Nothing here measures a width: no stylesheet is loaded in this run, so the
   * assertions are about the markup that does the reserving.
   */
  describe('width', () => {
    const sizerOf = (root: HTMLElement) =>
      root.querySelector('[aria-hidden="true"].invisible') as HTMLElement;

    const samplesOf = (root: HTMLElement) =>
      [...sizerOf(root).children].map((child) => child.getAttribute('data-sample'));

    it('reserves room for every month name and a two-digit day', async () => {
      const screen = await render(<DatePicker locale={LOCALE} label="Ships on" />);
      const samples = samplesOf(
        screen.getByRole('button', { name: 'Ships on' }).element() as HTMLElement
      );

      for (const month of ['Jan', 'Feb', 'Sep', 'Nov', 'Dec']) {
        expect(samples.some((sample) => sample?.startsWith(month))).toBe(true);
      }
      expect(samples.every((sample) => /\d{2},/.test(sample ?? ''))).toBe(true);
    });

    it('reserves room for the placeholder too', async () => {
      const screen = await render(
        <DatePicker locale={LOCALE} label="Ships on" placeholder="Pick a departure date" />
      );

      expect(
        samplesOf(screen.getByRole('button', { name: 'Ships on' }).element() as HTMLElement)
      ).toContain('Pick a departure date');
    });

    /**
     * Generated content off a data attribute rather than text nodes: it lays out
     * identically, so it reserves the same width — and it leaves nothing for a
     * `getByText` or a find-in-page to trip over, which is what would otherwise
     * make every query for the chosen date ambiguous.
     */
    it('reserves the width without putting the dates in the document', async () => {
      const screen = await render(
        <DatePicker locale={LOCALE} label="Ships on" defaultValue={new Date(2026, 6, 30)} />
      );
      const trigger = screen.getByRole('button', { name: 'Ships on' }).element() as HTMLElement;

      expect(trigger.textContent).toBe('Jul 30, 2026');
      expect([...sizerOf(trigger).children].every((child) => child.textContent === '')).toBe(true);
    });

    it('keeps the sizer out of the accessible name', async () => {
      const screen = await render(
        <DatePicker locale={LOCALE} label="Ships on" defaultValue={new Date(2026, 6, 30)} />
      );

      await expect.element(screen.getByRole('button', { name: 'Ships on' })).toBeInTheDocument();
      expect(
        sizerOf(screen.getByRole('button', { name: 'Ships on' }).element() as HTMLElement)
      ).toHaveAttribute('aria-hidden', 'true');
    });
  });

  describe('forwarded props', () => {
    it('passes an unknown prop to the root', async () => {
      const screen = await render(<DatePicker data-analytics="due" />);

      expect(screen.container.querySelector('[data-analytics="due"]')).not.toBeNull();
    });
  });
});
