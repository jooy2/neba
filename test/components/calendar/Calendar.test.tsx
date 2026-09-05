/**
 * The grid itself is the pickers' and is tested through them. What is new here
 * is the three modes and the value each hands back.
 */
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Calendar } from 'neba';
import { ko, registerMessages } from 'neba/locales';

/* The library ships English; a `locale` prop answers for a language the project
   has registered. These assertions are about the prop, so the language they
   name is registered here the way a consumer would. */
registerMessages('ko', ko);

const LOCALE = 'en-US';
const JULY = new Date(2026, 6, 1);

describe('Calendar', () => {
  it('renders a month inline, with no popup to open', async () => {
    const screen = await render(<Calendar locale={LOCALE} defaultMonth={JULY} />);

    await expect.element(screen.getByRole('grid')).toBeInTheDocument();
    await expect
      .element(screen.getByRole('gridcell', { name: 'Monday, July 27, 2026' }))
      .toBeInTheDocument();
  });

  describe('single', () => {
    it('reports the day that was clicked', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Calendar locale={LOCALE} defaultMonth={JULY} onValueChange={onValueChange} />
      );

      await screen.getByRole('gridcell', { name: 'Wednesday, July 15, 2026' }).click();

      expect(onValueChange).toHaveBeenCalledWith(new Date(2026, 6, 15));
    });

    it('lights the day it is holding', async () => {
      const screen = await render(
        <Calendar locale={LOCALE} defaultValue={new Date(2026, 6, 15)} />
      );

      await expect
        .element(screen.getByRole('gridcell', { name: 'Wednesday, July 15, 2026' }))
        .toHaveAttribute('aria-selected', 'true');
    });

    it('opens on the month of its value', async () => {
      const screen = await render(<Calendar locale={LOCALE} defaultValue={new Date(2019, 2, 4)} />);

      await expect
        .element(screen.getByRole('button', { name: 'Choose a month' }))
        .toHaveTextContent('March');
    });
  });

  describe('multiple', () => {
    it('collects the days that were clicked', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Calendar
          mode="multiple"
          locale={LOCALE}
          defaultMonth={JULY}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('gridcell', { name: 'Wednesday, July 15, 2026' }).click();
      await screen.getByRole('gridcell', { name: 'Friday, July 17, 2026' }).click();

      expect(onValueChange.mock.calls.at(-1)?.[0]).toEqual([
        new Date(2026, 6, 15),
        new Date(2026, 6, 17)
      ]);
    });

    it('takes a day back out when it is clicked again', async () => {
      // The only way a multiple calendar can be undone with the pointer.
      const onValueChange = vi.fn();
      const screen = await render(
        <Calendar
          mode="multiple"
          locale={LOCALE}
          defaultMonth={JULY}
          defaultValue={[new Date(2026, 6, 15)]}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('gridcell', { name: 'Wednesday, July 15, 2026' }).click();

      expect(onValueChange).toHaveBeenCalledWith([]);
    });
  });

  describe('range', () => {
    it('fills the near end and then the far one', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Calendar mode="range" locale={LOCALE} defaultMonth={JULY} onValueChange={onValueChange} />
      );

      await screen.getByRole('gridcell', { name: 'Wednesday, July 15, 2026' }).click();
      expect(onValueChange).toHaveBeenLastCalledWith({ start: new Date(2026, 6, 15), end: null });

      await screen.getByRole('gridcell', { name: 'Monday, July 20, 2026' }).click();
      expect(onValueChange).toHaveBeenLastCalledWith({
        start: new Date(2026, 6, 15),
        end: new Date(2026, 6, 20)
      });
    });

    it('starts again below the start rather than inverting the span', async () => {
      // Inverting is the behaviour that makes a reader believe they mis-clicked.
      const onValueChange = vi.fn();
      const screen = await render(
        <Calendar
          mode="range"
          locale={LOCALE}
          defaultMonth={JULY}
          defaultValue={{ start: new Date(2026, 6, 20), end: null }}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('gridcell', { name: 'Wednesday, July 15, 2026' }).click();

      expect(onValueChange).toHaveBeenLastCalledWith({ start: new Date(2026, 6, 15), end: null });
    });

    it('starts a new span once one is finished', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Calendar
          mode="range"
          locale={LOCALE}
          defaultMonth={JULY}
          defaultValue={{ start: new Date(2026, 6, 10), end: new Date(2026, 6, 20) }}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('gridcell', { name: 'Saturday, July 25, 2026' }).click();

      expect(onValueChange).toHaveBeenLastCalledWith({ start: new Date(2026, 6, 25), end: null });
    });
  });

  it('chooses a whole month at that granularity', async () => {
    const onValueChange = vi.fn();
    const screen = await render(
      <Calendar
        locale={LOCALE}
        granularity="month"
        defaultMonth={JULY}
        onValueChange={onValueChange}
      />
    );

    await screen.getByRole('gridcell', { name: 'November 2026' }).click();

    expect(onValueChange).toHaveBeenCalledWith(new Date(2026, 10, 1));
  });

  it('draws whatever renderDay returns under the number', async () => {
    const screen = await render(
      <Calendar
        locale={LOCALE}
        defaultMonth={JULY}
        renderDay={(date) => (date.getDate() === 4 ? <span>●</span> : null)}
      />
    );

    await expect
      .element(screen.getByRole('gridcell', { name: 'Saturday, July 4, 2026' }))
      .toMatchTextContent('●');
  });

  it('marks days outside the bounds unavailable', async () => {
    const screen = await render(
      <Calendar locale={LOCALE} defaultMonth={JULY} minDate={new Date(2026, 6, 20)} />
    );

    await expect
      .element(screen.getByRole('gridcell', { name: 'Wednesday, July 15, 2026' }))
      .toHaveAttribute('aria-disabled', 'true');
  });

  it('leaves a controlled value alone until the caller changes it', async () => {
    const onValueChange = vi.fn();
    const screen = await render(
      <Calendar
        locale={LOCALE}
        defaultMonth={JULY}
        value={new Date(2026, 6, 15)}
        onValueChange={onValueChange}
      />
    );

    await screen.getByRole('gridcell', { name: 'Monday, July 20, 2026' }).click();

    expect(onValueChange).toHaveBeenCalled();
    await expect
      .element(screen.getByRole('gridcell', { name: 'Wednesday, July 15, 2026' }))
      .toHaveAttribute('aria-selected', 'true');
  });

  /*
   * The twenty strings a picker says that are not dates. They used to be
   * hardcoded English with a `labels` prop as the only way out, which made a
   * Korean product write out all twenty to stop a calendar saying "Previous
   * month" over dates `Intl` had already translated.
   */
  describe('locale', () => {
    it('names its steppers and its footer in the language it was given', async () => {
      const screen = await render(<Calendar locale="ko" defaultMonth={JULY} />);

      await expect.element(screen.getByRole('button', { name: '이전 달' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: '다음 달' })).toBeInTheDocument();
    });

    // `locale` answers the language and `labels` answers the wording, so a
    // caller writing one string keeps the other nineteen translated.
    it('takes a label of its own over the locale, and keeps the rest', async () => {
      const screen = await render(
        <Calendar locale="ko" defaultMonth={JULY} labels={{ previousMonth: 'Back' }} />
      );

      await expect.element(screen.getByRole('button', { name: 'Back' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: '다음 달' })).toBeInTheDocument();
    });
  });

  it('keeps the class name it was handed and passes an unknown prop through', async () => {
    const screen = await render(
      <Calendar locale={LOCALE} className="my-own-class" data-analytics="sheet" />
    );

    expect(screen.container.querySelector('.my-own-class')).not.toBeNull();
    expect(screen.container.querySelector('[data-analytics="sheet"]')).not.toBeNull();
  });
});
