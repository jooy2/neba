import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Flex } from 'neba';

/**
 * The responsive props resolve in CSS, so what is asserted here is the slots
 * the component writes rather than the layout they produce — no stylesheet is
 * loaded in this suite, and the widths the cascade branches at belong to
 * Tailwind's theme. `standalone.test.tsx` is where a slot is followed all the
 * way to a computed value.
 */
describe('Flex', () => {
  const slot = (element: HTMLElement, name: string) => element.style.getPropertyValue(name);

  it('is a row by default', async () => {
    const screen = await render(<Flex>content</Flex>);
    const element = screen.getByText('content').element() as HTMLElement;

    expect(element).toHaveClass('flex', 'neba-flex');
    expect(slot(element, '--n-flex-dir-xs')).toBe('row');
  });

  it('maps direction onto the axis CSS names', async () => {
    const screen = await render(<Flex direction="vertical">content</Flex>);
    const element = screen.getByText('content').element() as HTMLElement;

    expect(slot(element, '--n-flex-dir-xs')).toBe('column');

    await screen.rerender(<Flex direction="horizontal">content</Flex>);

    expect(slot(element, '--n-flex-dir-xs')).toBe('row');
  });

  it('changes direction at a breakpoint, keeping the baseline', async () => {
    // The map names only `md`, and `withBaseline` is what stops the column
    // below it from falling through to the CSS fallback instead of the
    // documented default.
    const screen = await render(<Flex direction={{ md: 'horizontal' }}>content</Flex>);
    const element = screen.getByText('content').element() as HTMLElement;

    expect(slot(element, '--n-flex-dir-xs')).toBe('row');
    expect(slot(element, '--n-flex-dir-md')).toBe('row');

    await screen.rerender(<Flex direction={{ xs: 'vertical', md: 'horizontal' }}>content</Flex>);

    expect(slot(element, '--n-flex-dir-xs')).toBe('column');
    expect(slot(element, '--n-flex-dir-md')).toBe('row');
    expect(slot(element, '--n-flex-dir-lg')).toBe('');
  });

  it('turns every breakpoint around at once when reversed', async () => {
    const screen = await render(
      <Flex direction={{ xs: 'vertical', md: 'horizontal' }} reverse>
        content
      </Flex>
    );
    const element = screen.getByText('content').element() as HTMLElement;

    expect(slot(element, '--n-flex-dir-xs')).toBe('column-reverse');
    expect(slot(element, '--n-flex-dir-md')).toBe('row-reverse');
  });

  it('has no gutter until one is asked for', async () => {
    const screen = await render(<Flex>content</Flex>);
    const element = screen.getByText('content').element() as HTMLElement;

    expect(slot(element, '--n-gap-x-xs')).toBe('0rem');

    await screen.rerender(<Flex spacing={3}>content</Flex>);

    expect(slot(element, '--n-gap-x-xs')).toBe('0.75rem');
    expect(slot(element, '--n-gap-y-xs')).toBe('0.75rem');
  });

  it('splits the two gutters when they are given apart', async () => {
    const screen = await render(
      <Flex spacing={2} columnSpacing={{ md: 6 }}>
        content
      </Flex>
    );
    const element = screen.getByText('content').element() as HTMLElement;

    expect(slot(element, '--n-gap-x-xs')).toBe('0.5rem');
    expect(slot(element, '--n-gap-x-md')).toBe('1.5rem');
    expect(slot(element, '--n-gap-y-xs')).toBe('0.5rem');
    expect(slot(element, '--n-gap-y-md')).toBe('');
  });

  it('does not wrap unless told to', async () => {
    const screen = await render(<Flex>content</Flex>);
    const element = screen.getByText('content').element();

    expect(element).toHaveClass('flex-nowrap');

    await screen.rerender(<Flex wrap>content</Flex>);

    expect(element).toHaveClass('flex-wrap');
  });

  it('maps the alignment props onto their utilities', async () => {
    const screen = await render(
      <Flex justifyContent="space-between" alignItems="center" alignContent="end">
        content
      </Flex>
    );
    const element = screen.getByText('content').element();

    expect(element).toHaveClass('justify-between', 'items-center', 'content-end');
  });

  it('lays out inline on request', async () => {
    const screen = await render(<Flex inline>content</Flex>);
    const element = screen.getByText('content').element();

    expect(element).toHaveClass('inline-flex');
    expect(element).not.toHaveClass('flex ');
  });

  it('renders the element it was told to', async () => {
    const screen = await render(<Flex render={<nav />}>content</Flex>);

    expect(screen.getByText('content').element().tagName).toBe('NAV');
  });

  it('keeps the className and the style it was handed', async () => {
    const screen = await render(
      <Flex spacing={2} className="custom" style={{ color: 'rgb(1, 2, 3)' }}>
        content
      </Flex>
    );
    const element = screen.getByText('content').element() as HTMLElement;

    expect(element).toHaveClass('custom');
    expect(element.style.color).toBe('rgb(1, 2, 3)');
    expect(slot(element, '--n-gap-x-xs')).toBe('0.5rem');
  });
});
