import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { VisuallyHidden } from 'neba';

describe('VisuallyHidden', () => {
  it('keeps its content in the accessibility tree', async () => {
    const screen = await render(
      <button type="button">
        <span aria-hidden="true">×</span>
        <VisuallyHidden>Remove</VisuallyHidden>
      </button>
    );

    // The name comes from the hidden span, which is the whole point: `hidden`
    // and `display: none` would have taken it off the tree with the screen.
    await expect.element(screen.getByRole('button', { name: 'Remove' })).toBeInTheDocument();
  });

  it('renders a span by default', async () => {
    const screen = await render(<VisuallyHidden>Status</VisuallyHidden>);

    expect(screen.getByText('Status').element().tagName).toBe('SPAN');
  });

  it('renders something else when told to', async () => {
    const screen = await render(<VisuallyHidden render={<div />}>Status</VisuallyHidden>);

    expect(screen.getByText('Status').element().tagName).toBe('DIV');
  });

  it('drops the hiding when visible', async () => {
    const screen = await render(
      <>
        <VisuallyHidden>Hidden</VisuallyHidden>
        <VisuallyHidden visible>Shown</VisuallyHidden>
      </>
    );

    // No stylesheet is loaded in this run, so the assertion is about the markup
    // that does the hiding rather than about a measured box.
    expect(screen.getByText('Hidden').element().className).toContain('size-px');
    expect(screen.getByText('Shown').element().className).not.toContain('size-px');
  });

  it('keeps a caller-supplied class name beside its own', async () => {
    const screen = await render(<VisuallyHidden className="my-own-class">Status</VisuallyHidden>);
    const element = screen.getByText('Status').element();

    expect(element.className).toContain('my-own-class');
    expect(element.className).toContain('size-px');
  });

  it('passes an unknown prop through', async () => {
    const screen = await render(<VisuallyHidden data-analytics="live">Status</VisuallyHidden>);

    expect(screen.container.querySelector('[data-analytics="live"]')).not.toBeNull();
  });
});
