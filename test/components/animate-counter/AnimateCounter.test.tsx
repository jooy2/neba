import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateCounter } from 'neba';

/** What a sighted reader sees. */
function shown(root: Element): string {
  return root.querySelector('[aria-hidden="true"]')?.textContent ?? '';
}

/** What a screen reader is told. */
function announced(root: Element): string {
  return root.children[0]?.textContent ?? '';
}

describe('AnimateCounter', () => {
  it('lands on its value', async () => {
    const screen = await render(<AnimateCounter value={42} duration={60} data-testid="c" />);

    await expect.poll(() => shown(screen.getByTestId('c').element())).toBe('42');
  });

  it('starts from where it was told', async () => {
    const screen = await render(
      <AnimateCounter value={100} from={90} duration={4000} data-testid="c" />
    );
    const seen = Number(shown(screen.getByTestId('c').element()));

    expect(seen).toBeGreaterThanOrEqual(90);
    expect(seen).toBeLessThan(100);
  });

  /*
   * The answer is in the document from the first frame, in a clipped box: a
   * screen reader is told the number rather than a hundred intermediate ones.
   */
  it('tells a screen reader the answer and hides the count', async () => {
    const screen = await render(
      <AnimateCounter value={1234} from={0} duration={4000} data-testid="c" />
    );
    const root = screen.getByTestId('c').element();

    expect(announced(root)).toBe('1,234');
    expect(root.querySelector('[aria-hidden="true"]')).not.toBeNull();
  });

  // Intl rather than a `format` callback, so a currency is a prop.
  it('writes the number the way it was told to', async () => {
    const screen = await render(
      <AnimateCounter
        value={1234.5}
        duration={60}
        locale="en-US"
        format={{ style: 'currency', currency: 'USD' }}
        data-testid="c"
      />
    );

    await expect.poll(() => shown(screen.getByTestId('c').element())).toBe('$1,234.50');
  });

  it('jumps straight there when there is no duration', async () => {
    const screen = await render(<AnimateCounter value={7} from={0} duration={0} data-testid="c" />);

    expect(shown(screen.getByTestId('c').element())).toBe('7');
  });

  it('waits for play when the trigger is manual', async () => {
    const screen = await render(
      <AnimateCounter value={50} from={0} trigger="manual" duration={4000} data-testid="c" />
    );

    expect(shown(screen.getByTestId('c').element())).toBe('0');
  });
});
