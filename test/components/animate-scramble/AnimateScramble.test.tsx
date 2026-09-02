import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateScramble } from 'neba';

function shown(root: Element): string {
  return root.querySelector('[aria-hidden="true"]')?.textContent ?? '';
}

describe('AnimateScramble', () => {
  it('settles on the text it was given', async () => {
    const screen = await render(<AnimateScramble text="NEBA" duration={80} data-testid="s" />);

    await expect.poll(() => shown(screen.getByTestId('s').element())).toBe('NEBA');
  });

  // The box never changes size, which is the whole reason to reach for this
  // rather than for a typewriter.
  it('is the finished length from the first frame', async () => {
    const screen = await render(<AnimateScramble text="NEBA UI" duration={4000} data-testid="s" />);

    expect(shown(screen.getByTestId('s').element())).toHaveLength(7);
  });

  /* A space that flickered into a letter would read as the words having moved. */
  it('never scrambles whitespace', async () => {
    const screen = await render(<AnimateScramble text="AB CD" duration={4000} data-testid="s" />);

    expect(shown(screen.getByTestId('s').element())[2]).toBe(' ');
  });

  it('draws the noise from the pool it was given', async () => {
    const screen = await render(
      <AnimateScramble text="ABCD" characters="#" duration={4000} data-testid="s" />
    );

    expect(shown(screen.getByTestId('s').element())).toBe('####');
  });

  it('tells a screen reader the finished text', async () => {
    const screen = await render(<AnimateScramble text="NEBA" duration={4000} data-testid="s" />);

    expect(screen.getByTestId('s').element().children[0].textContent).toBe('NEBA');
  });

  it('takes the text from its children too', async () => {
    const screen = await render(
      <AnimateScramble duration={60} data-testid="s">
        Hello
      </AnimateScramble>
    );

    await expect.poll(() => shown(screen.getByTestId('s').element())).toBe('Hello');
  });
});
