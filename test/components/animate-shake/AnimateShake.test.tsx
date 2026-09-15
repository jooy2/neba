import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateShake, Box } from 'neba';

describe('AnimateShake', () => {
  it('renders what it was given and says which effect it is', async () => {
    const screen = await render(<AnimateShake data-testid="s">Wrong</AnimateShake>);

    await expect.element(screen.getByText('Wrong')).toBeInTheDocument();
    expect(screen.getByTestId('s').element()).toHaveAttribute('data-neba-animation', 'shake');
  });

  /*
   * A shake is an answer to something the reader just did, so it waits to be
   * played rather than running on mount. Decoration that moves is what a reader
   * learns to ignore.
   */
  it('waits to be played rather than running on mount', async () => {
    const screen = await render(<AnimateShake data-testid="s">Wrong</AnimateShake>);

    expect(screen.getByTestId('s').element()).toHaveAttribute('data-state', 'paused');
  });

  it('runs when it is played', async () => {
    const screen = await render(
      <AnimateShake play data-testid="s">
        Wrong
      </AnimateShake>
    );

    expect(screen.getByTestId('s').element()).toHaveAttribute('data-state', 'running');
  });

  // A field that shakes on every failed submit holds an Alert that faded in
  // once, and a replay that rewound every animation inside it faded the Alert
  // in again each time.
  it('rewinds only itself when it is played, not an effect inside it', async () => {
    const screen = await render(
      <AnimateShake data-testid="s">
        <Box transition="fade" data-testid="inner">
          Wrong
        </Box>
      </AnimateShake>
    );
    const outer = screen.getByTestId('s').element() as HTMLElement;
    const inner = screen.getByTestId('inner').element() as HTMLElement;
    const records: MutationRecord[] = [];
    const observer = new MutationObserver((list) => records.push(...list));
    const options = { attributes: true, attributeFilter: ['style'], attributeOldValue: true };

    observer.observe(outer, options);
    observer.observe(inner, options);

    await screen.rerender(
      <AnimateShake play data-testid="s">
        <Box transition="fade" data-testid="inner">
          Wrong
        </Box>
      </AnimateShake>
    );

    records.push(...observer.takeRecords());
    observer.disconnect();

    // A rewind clears `animation-name` and puts it back, which leaves a style
    // mutation whose old value still says `none`.
    const rewound = (element: HTMLElement) =>
      records.some(
        (record) => record.target === element && record.oldValue?.includes('animation-name: none')
      );

    expect(rewound(outer)).toBe(true);
    expect(rewound(inner)).toBe(false);
  });

  it('travels as far as it was told', async () => {
    const screen = await render(
      <AnimateShake distance="1rem" data-testid="s">
        Wrong
      </AnimateShake>
    );

    expect(
      (screen.getByTestId('s').element() as HTMLElement).style.getPropertyValue('--n-anim-x')
    ).toBe('1rem');
  });
});
