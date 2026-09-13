import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
import { OtpField } from 'neba';
import { ko, registerMessages } from 'neba/locales';

registerMessages('ko', ko);

/**
 * The slot inputs, in the order they are typed into.
 *
 * `[data-length]` is what marks a slot: Base UI also renders a clipped input
 * carrying the whole value, which is what a form submits and what a phone
 * autofills into, and it is an `<input>` like any other.
 */
function slots(screen: Awaited<ReturnType<typeof render>>) {
  return Array.from(screen.container.querySelectorAll<HTMLInputElement>('input[data-length]'));
}

describe('OtpField', () => {
  describe('rendering', () => {
    it('renders one slot per character', async () => {
      const screen = await render(<OtpField length={6} />);

      await expect.poll(() => slots(screen)).toHaveLength(6);
    });

    it('clamps the length to what a code can be', async () => {
      const short = await render(<OtpField length={1} />);
      await expect.poll(() => slots(short)).toHaveLength(2);

      const long = await render(<OtpField length={40} />);
      await expect.poll(() => slots(long)).toHaveLength(12);
    });

    it('renders six slots when no length is given', async () => {
      const screen = await render(<OtpField />);

      await expect.poll(() => slots(screen)).toHaveLength(6);
    });

    it('names the field by its label', async () => {
      const screen = await render(<OtpField label="Verification code" />);

      await expect.element(screen.getByText('Verification code')).toBeInTheDocument();
    });

    // Six boxes all called "Verification code" say nothing about which one the
    // caret is in.
    it('names every slot after the first by its place in the code', async () => {
      const screen = await render(<OtpField label="Verification code" length={4} />);

      await expect.poll(() => slots(screen)).toHaveLength(4);
      const [first, second, , last] = slots(screen);

      await expect.element(first).toHaveAccessibleName('Verification code');
      await expect.element(second).toHaveAccessibleName('Character 2 of 4');
      await expect.element(last).toHaveAccessibleName('Character 4 of 4');
    });

    it('names the slots in the language it was given, or in words of its own', async () => {
      const screen = await render(<OtpField label="코드" length={4} locale="ko" />);

      await expect.poll(() => slots(screen)).toHaveLength(4);
      await expect.element(slots(screen)[1]).toHaveAccessibleName('4자리 중 2번째');

      await screen.rerender(
        <OtpField label="코드" length={4} locale="ko" slotLabel={(index) => `Digit ${index}`} />
      );

      await expect.element(slots(screen)[1]).toHaveAccessibleName('Digit 2');
    });

    // iOS zooms the page in on a field under 16px; only the two steps set
    // below that carry the hook the stylesheet raises them through.
    it('marks the slots set under 16px for the iOS size floor', async () => {
      const screen = await render(<OtpField size="sm" length={4} />);

      await expect.poll(() => slots(screen)).toHaveLength(4);
      expect(slots(screen)[0]).toHaveClass('neba-input');

      await screen.rerender(<OtpField size="lg" length={4} />);

      expect(slots(screen)[0]).not.toHaveClass('neba-input');
    });

    it('shows the description and the error under the row', async () => {
      const screen = await render(
        <OtpField description="Sent to your phone" error="That code has expired" />
      );

      await expect.element(screen.getByText('Sent to your phone')).toBeInTheDocument();
      await expect.element(screen.getByText('That code has expired')).toBeInTheDocument();
    });

    it('spreads a value it starts with across the slots', async () => {
      const screen = await render(<OtpField length={4} defaultValue="1234" />);

      await expect
        .poll(() => slots(screen).map((slot) => slot.value))
        .toEqual(['1', '2', '3', '4']);
    });

    it('reflects a controlled value on re-render', async () => {
      const screen = await render(<OtpField length={4} value="12" />);

      await screen.rerender(<OtpField length={4} value="1234" />);

      await expect
        .poll(() => slots(screen).map((slot) => slot.value))
        .toEqual(['1', '2', '3', '4']);
    });

    it('draws a separator every groupSize slots', async () => {
      const screen = await render(<OtpField length={6} groupSize={3} separator="/" />);

      await expect.poll(() => screen.container.textContent).toContain('/');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<OtpField className="my-own-class" />);

      expect(screen.container.querySelector('.my-own-class')).not.toBeNull();
    });
  });

  describe('typing', () => {
    it('moves to the next slot as each character lands', async () => {
      const screen = await render(<OtpField length={4} />);

      await expect.poll(() => slots(screen)).toHaveLength(4);
      slots(screen)[0].focus();
      await userEvent.keyboard('12');

      await expect.poll(() => slots(screen).map((slot) => slot.value)).toEqual(['1', '2', '', '']);
      await expect.poll(() => document.activeElement).toBe(slots(screen)[2]);
    });

    it('reports the value as it is typed', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<OtpField length={4} onValueChange={onValueChange} />);

      await expect.poll(() => slots(screen)).toHaveLength(4);
      slots(screen)[0].focus();
      await userEvent.keyboard('12');

      expect(onValueChange).toHaveBeenLastCalledWith('12');
    });

    it('says when the code is complete', async () => {
      const onComplete = vi.fn();
      const screen = await render(<OtpField length={4} onComplete={onComplete} />);

      await expect.poll(() => slots(screen)).toHaveLength(4);
      slots(screen)[0].focus();
      await userEvent.keyboard('1234');

      await expect.poll(() => onComplete.mock.calls.at(-1)?.[0]).toBe('1234');
    });

    it('drops characters the charset rejects', async () => {
      const onValueInvalid = vi.fn();
      const screen = await render(
        <OtpField length={4} charset="numeric" onValueInvalid={onValueInvalid} />
      );

      await expect.poll(() => slots(screen)).toHaveLength(4);
      slots(screen)[0].focus();
      await userEvent.keyboard('a1');

      await expect.poll(() => slots(screen).map((slot) => slot.value)).toEqual(['1', '', '', '']);
      expect(onValueInvalid).toHaveBeenCalled();
    });

    it('accepts letters when the charset allows them', async () => {
      const screen = await render(<OtpField length={4} charset="alphanumeric" />);

      await expect.poll(() => slots(screen)).toHaveLength(4);
      slots(screen)[0].focus();
      await userEvent.keyboard('a1');

      await expect.poll(() => slots(screen).map((slot) => slot.value)).toEqual(['a', '1', '', '']);
    });

    it('steps back over the previous character on backspace', async () => {
      const screen = await render(<OtpField length={4} defaultValue="12" />);

      await expect.poll(() => slots(screen)).toHaveLength(4);
      slots(screen)[2].focus();
      await userEvent.keyboard('{Backspace}');

      await expect.poll(() => slots(screen).map((slot) => slot.value)).toEqual(['1', '', '', '']);
    });

    it('does not answer when it is read-only', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<OtpField length={4} readOnly onValueChange={onValueChange} />);

      await expect.poll(() => slots(screen)).toHaveLength(4);
      slots(screen)[0].focus();
      await userEvent.keyboard('1');

      expect(onValueChange).not.toHaveBeenCalled();
    });

    it('does not answer when it is disabled', async () => {
      const screen = await render(<OtpField length={4} disabled />);

      await expect.poll(() => slots(screen).every((slot) => slot.disabled)).toBe(true);
    });

    it('stays where the caller put it when the value is controlled', async () => {
      const screen = await render(<OtpField length={4} value="99" />);

      await expect.poll(() => slots(screen)).toHaveLength(4);
      slots(screen)[2].focus();
      await userEvent.keyboard('1');

      await expect.poll(() => slots(screen).map((slot) => slot.value)).toEqual(['9', '9', '', '']);
    });
  });
});
