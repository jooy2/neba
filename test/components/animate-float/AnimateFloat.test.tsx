import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateFloat } from 'neba';

function slot(element: Element, name: string): string {
  return (element as HTMLElement).style.getPropertyValue(name);
}

describe('AnimateFloat', () => {
  it('renders what it was given and says which effect it is', async () => {
    const screen = await render(<AnimateFloat data-testid="f">Drifting</AnimateFloat>);

    await expect.element(screen.getByText('Drifting')).toBeInTheDocument();
    expect(screen.getByTestId('f').element()).toHaveAttribute('data-neba-animation', 'float');
  });

  // A drift that stopped would be a nudge, and one that only went one way would
  // be a slide.
  it('runs for ever and turns round at both ends', async () => {
    const screen = await render(<AnimateFloat data-testid="f">A</AnimateFloat>);
    const element = screen.getByTestId('f').element();

    expect(slot(element, '--n-anim-repeat')).toBe('infinite');
    expect(slot(element, '--n-anim-direction')).toBe('alternate');
  });

  it('drifts the way and the distance it was told', async () => {
    const screen = await render(
      <AnimateFloat from="left" distance={20} data-testid="f">
        A
      </AnimateFloat>
    );
    const element = screen.getByTestId('f').element();

    expect(slot(element, '--n-anim-x')).toBe('-20px');
    expect(slot(element, '--n-anim-y')).toBe('0px');
  });

  it('drifts upward by default', async () => {
    const screen = await render(<AnimateFloat data-testid="f">A</AnimateFloat>);

    expect(slot(screen.getByTestId('f').element(), '--n-anim-y')).toBe('calc(-1 * 0.5rem)');
  });
});
