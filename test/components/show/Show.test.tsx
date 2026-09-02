import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Show } from 'neba';

/**
 * `Show` decides in CSS, so what a test in this suite can check is the decision
 * rather than its effect: no stylesheet is loaded here, and the widths the
 * classes stand for belong to Tailwind's theme rather than to the component.
 *
 * What matters is that the children are always in the document — that is the
 * whole difference between this and `useBreakpoint`, and the reason it survives
 * a server render — and that the two props map onto the pair of variants that
 * cover every width exactly once.
 */
describe('Show', () => {
  function marker(screen: Awaited<ReturnType<typeof render>>) {
    return screen.getByTestId('content').element().parentElement as HTMLElement;
  }

  it('renders its children whatever the width is', async () => {
    const screen = await render(
      <Show above="lg">
        <span data-testid="content">Desktop</span>
      </Show>
    );

    await expect.element(screen.getByTestId('content')).toBeInTheDocument();
  });

  it('adds no box of its own', async () => {
    const screen = await render(
      <Show>
        <span data-testid="content">Always</span>
      </Show>
    );

    expect(marker(screen).className).toContain('contents');
  });

  it('hides below the floor it was given', async () => {
    const screen = await render(
      <Show above="md">
        <span data-testid="content">Wide</span>
      </Show>
    );

    expect(marker(screen).classList.contains('max-md:hidden')).toBe(true);
    // And not the other half of the pair: `max-md:hidden` contains the string
    // `md:hidden`, so this only means anything read class by class.
    expect(marker(screen).classList.contains('md:hidden')).toBe(false);
  });

  it('hides at and above the ceiling it was given', async () => {
    const screen = await render(
      <Show below="md">
        <span data-testid="content">Narrow</span>
      </Show>
    );

    expect(marker(screen).className).toContain('md:hidden');
  });

  it('takes a floor and a ceiling together', async () => {
    const screen = await render(
      <Show above="sm" below="lg">
        <span data-testid="content">Middle</span>
      </Show>
    );

    expect(marker(screen).className).toContain('max-sm:hidden');
    expect(marker(screen).className).toContain('lg:hidden');
  });

  it('treats xs as a floor of zero and therefore as always', async () => {
    const screen = await render(
      <Show above="xs">
        <span data-testid="content">Everywhere</span>
      </Show>
    );

    expect(marker(screen).className).not.toContain('hidden');
  });

  it('draws nothing below xs, because there is nothing below it', async () => {
    const screen = await render(
      <Show below="xs">
        <span data-testid="content">Nowhere</span>
      </Show>
    );

    expect(marker(screen).className).toContain('hidden');
  });

  it('follows a change of props', async () => {
    const screen = await render(
      <Show above="md">
        <span data-testid="content">Wide</span>
      </Show>
    );

    await screen.rerender(
      <Show above="xl">
        <span data-testid="content">Wide</span>
      </Show>
    );

    expect(marker(screen).className).toContain('max-xl:hidden');
    expect(marker(screen).className).not.toContain('max-md:hidden');
  });

  it('renders the element it was told to', async () => {
    const screen = await render(
      <table>
        <tbody>
          <tr>
            <Show above="md" render={<td />}>
              <span data-testid="content">Cell</span>
            </Show>
          </tr>
        </tbody>
      </table>
    );

    expect(marker(screen).tagName).toBe('TD');
  });

  it('keeps the className and the style it was handed', async () => {
    const screen = await render(
      <Show above="md" className="custom" style={{ color: 'rgb(1, 2, 3)' }}>
        <span data-testid="content">Wide</span>
      </Show>
    );

    expect(marker(screen).className).toContain('custom');
    expect(marker(screen).style.color).toBe('rgb(1, 2, 3)');
  });
});
