import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { GridContainer } from 'neba';

describe('GridContainer', () => {
  describe('rendering', () => {
    it('renders a div holding its children', async () => {
      const screen = await render(<GridContainer>content</GridContainer>);
      const element = screen.getByText('content').element();

      expect(element.tagName).toBe('DIV');
      expect(element).toHaveClass('neba-grid');
    });

    it('renders another element when told to', async () => {
      const screen = await render(<GridContainer render={<section />}>content</GridContainer>);

      expect(screen.getByText('content').element().tagName).toBe('SECTION');
    });

    it('merges its own classes with the ones it is given', async () => {
      const screen = await render(<GridContainer className="my-own-class">content</GridContainer>);
      const element = screen.getByText('content').element();

      expect(element).toHaveClass('my-own-class');
      expect(element).toHaveClass('neba-grid');
    });

    it('forwards unknown props to the element', async () => {
      const screen = await render(
        <GridContainer id="layout" role="group" aria-label="Layout">
          content
        </GridContainer>
      );
      const element = screen.getByText('content').element();

      expect(element).toHaveAttribute('id', 'layout');
      expect(element).toHaveAttribute('role', 'group');
    });
  });

  describe('columns', () => {
    it('divides a row into twelve by default', async () => {
      const screen = await render(<GridContainer>content</GridContainer>);
      const element = screen.getByText('content').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-cols-xs')).toBe('12');
    });

    it('takes a column count of its own', async () => {
      const screen = await render(<GridContainer columns={24}>content</GridContainer>);
      const element = screen.getByText('content').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-cols-xs')).toBe('24');

      await screen.rerender(<GridContainer columns={5}>content</GridContainer>);

      expect(element.style.getPropertyValue('--n-cols-xs')).toBe('5');
    });

    it('rounds a column count and never lets it reach zero', async () => {
      const screen = await render(<GridContainer columns={0}>content</GridContainer>);
      const element = screen.getByText('content').element() as HTMLElement;

      // The value ends up as a divisor in `calc()`, so zero would take the
      // whole width declaration down with it.
      expect(element.style.getPropertyValue('--n-cols-xs')).toBe('1');

      await screen.rerender(<GridContainer columns={12.4}>content</GridContainer>);

      expect(element.style.getPropertyValue('--n-cols-xs')).toBe('12');
    });

    it('emits one slot per named breakpoint, and keeps the default below them', async () => {
      const screen = await render(
        <GridContainer columns={{ md: 24, xl: 36 }}>content</GridContainer>
      );
      const element = screen.getByText('content').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-cols-md')).toBe('24');
      expect(element.style.getPropertyValue('--n-cols-xl')).toBe('36');
      // A map narrows some breakpoints; it does not drop the rest.
      expect(element.style.getPropertyValue('--n-cols-xs')).toBe('12');
      expect(element.style.getPropertyValue('--n-cols-sm')).toBe('');
      expect(element.style.getPropertyValue('--n-cols-lg')).toBe('');
    });
  });

  describe('spacing', () => {
    it('puts two steps between items by default', async () => {
      const screen = await render(<GridContainer>content</GridContainer>);
      const element = screen.getByText('content').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-gap-x-xs')).toBe('0.5rem');
      expect(element.style.getPropertyValue('--n-gap-y-xs')).toBe('0.5rem');
    });

    it('sets both gutters from spacing, on the Tailwind scale', async () => {
      const screen = await render(<GridContainer spacing={4}>content</GridContainer>);
      const element = screen.getByText('content').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-gap-x-xs')).toBe('1rem');
      expect(element.style.getPropertyValue('--n-gap-y-xs')).toBe('1rem');
    });

    it('accepts a fraction', async () => {
      const screen = await render(<GridContainer spacing={1.5}>content</GridContainer>);
      const element = screen.getByText('content').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-gap-x-xs')).toBe('0.375rem');

      await screen.rerender(<GridContainer spacing={0.5}>content</GridContainer>);

      expect(element.style.getPropertyValue('--n-gap-x-xs')).toBe('0.125rem');
    });

    it('lets rowSpacing and columnSpacing each override spacing', async () => {
      const screen = await render(
        <GridContainer spacing={4} rowSpacing={8}>
          content
        </GridContainer>
      );
      const element = screen.getByText('content').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-gap-y-xs')).toBe('2rem');
      expect(element.style.getPropertyValue('--n-gap-x-xs')).toBe('1rem');

      await screen.rerender(
        <GridContainer spacing={4} columnSpacing={0}>
          content
        </GridContainer>
      );

      expect(element.style.getPropertyValue('--n-gap-x-xs')).toBe('0rem');
      expect(element.style.getPropertyValue('--n-gap-y-xs')).toBe('1rem');
    });

    it('keeps the default gutter below a breakpoint the map does not name', async () => {
      const screen = await render(<GridContainer spacing={{ md: 6 }}>content</GridContainer>);
      const element = screen.getByText('content').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-gap-x-md')).toBe('1.5rem');
      expect(element.style.getPropertyValue('--n-gap-x-xs')).toBe('0.5rem');
    });

    it('reads the gutters through the slots rather than a fixed length', async () => {
      const screen = await render(<GridContainer>content</GridContainer>);
      const element = screen.getByText('content').element();

      // A media query can change the slot without React hearing about it, so
      // the class has to point at the variable and not at a number.
      expect(element).toHaveClass('gap-x-(--n-gap-x)');
      expect(element).toHaveClass('gap-y-(--n-gap-y)');
    });
  });

  describe('layout props', () => {
    it('maps justifyContent, alignItems and alignContent onto classes', async () => {
      const screen = await render(
        <GridContainer justifyContent="space-between" alignItems="center" alignContent="end">
          content
        </GridContainer>
      );
      const element = screen.getByText('content').element();

      expect(element).toHaveClass('justify-between');
      expect(element).toHaveClass('items-center');
      expect(element).toHaveClass('content-end');
    });

    it('applies no alignment class when none was asked for', async () => {
      const screen = await render(<GridContainer>content</GridContainer>);
      const element = screen.getByText('content').element();

      expect(element.className).not.toContain('justify-');
      expect(element.className).not.toContain('items-');
    });

    it('wraps by default and stops on request', async () => {
      const screen = await render(<GridContainer>content</GridContainer>);
      const element = screen.getByText('content').element();

      expect(element).toHaveClass('flex-wrap');

      await screen.rerender(<GridContainer wrap={false}>content</GridContainer>);

      expect(element).toHaveClass('flex-nowrap');
      expect(element).not.toHaveClass('flex-wrap');
    });
  });

  describe('padding', () => {
    it('pads on the size and density scale', async () => {
      const screen = await render(<GridContainer size="lg">content</GridContainer>);
      const element = screen.getByText('content').element();

      expect(element).toHaveClass('p-5');

      await screen.rerender(
        <GridContainer size="lg" density="compact">
          content
        </GridContainer>
      );

      expect(element).toHaveClass('p-3');
      expect(element).not.toHaveClass('p-5');
    });

    it('drops the padding entirely when padded is false', async () => {
      const screen = await render(<GridContainer padded={false}>content</GridContainer>);
      const element = screen.getByText('content').element();

      expect(element).not.toHaveClass('p-4');
    });
  });
});
