import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Portal } from 'neba';

describe('Portal', () => {
  it('renders its children outside the tree it was written in', async () => {
    const screen = await render(
      <div data-testid="here">
        <Portal>
          <p>elsewhere</p>
        </Portal>
      </div>
    );

    await expect.element(screen.getByText('elsewhere')).toBeInTheDocument();

    const written = screen.container.querySelector('[data-testid="here"]')!;
    expect(written.textContent).toBe('');
    expect(document.body.contains(screen.getByText('elsewhere').element())).toBe(true);
  });

  it('carries the class a scoped stylesheet finds it by', async () => {
    const screen = await render(
      <Portal>
        <p>content</p>
      </Portal>
    );

    expect(screen.getByText('content').element().closest('.neba-portal')).not.toBeNull();
  });

  it('renders into a container it was given', async () => {
    const target = document.createElement('div');
    target.id = 'portal-target';
    document.body.append(target);

    try {
      const screen = await render(
        <Portal container={() => document.getElementById('portal-target')}>
          <p>aimed</p>
        </Portal>
      );

      await expect.element(screen.getByText('aimed')).toBeInTheDocument();
      expect(target.textContent).toBe('aimed');
    } finally {
      target.remove();
    }
  });

  it('renders in place when disabled, without unmounting anything', async () => {
    const screen = await render(
      <div data-testid="here">
        <Portal disabled>
          <p>in place</p>
        </Portal>
      </div>
    );

    const written = screen.container.querySelector('[data-testid="here"]')!;
    await expect.element(screen.getByText('in place')).toBeInTheDocument();
    expect(written.textContent).toBe('in place');
  });

  /**
   * Pinned deliberately, because the prop's documentation promises it: a
   * portalled subtree and an inline one are different children as far as React
   * is concerned, so flipping `disabled` remounts everything inside. Callers
   * are told to decide it once, and this is the test that keeps the warning
   * true rather than aspirational.
   */
  it('remounts the subtree when disabled is flipped', async () => {
    const screen = await render(
      <Portal disabled>
        <input aria-label="Note" defaultValue="" />
      </Portal>
    );

    await screen.getByRole('textbox').fill('typed');
    await expect.element(screen.getByRole('textbox')).toHaveValue('typed');

    await screen.rerender(
      <Portal>
        <input aria-label="Note" defaultValue="" />
      </Portal>
    );

    await expect.element(screen.getByRole('textbox')).toHaveValue('');
  });

  it('keeps a caller-supplied class name and passes an unknown prop through', async () => {
    const screen = await render(
      <Portal className="my-own-class" data-analytics="overlay">
        <p>content</p>
      </Portal>
    );

    const wrapper = screen.getByText('content').element().parentElement!;
    expect(wrapper.className).toContain('my-own-class');
    expect(wrapper.className).toContain('neba-portal');
    expect(wrapper.getAttribute('data-analytics')).toBe('overlay');
  });
});
