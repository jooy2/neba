import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Grid, GridContainer } from 'neba';

describe('Grid', () => {
  describe('rendering', () => {
    it('renders a div holding its children', async () => {
      const screen = await render(
        <GridContainer>
          <Grid>content</Grid>
        </GridContainer>
      );
      const element = screen.getByText('content').element();

      expect(element.tagName).toBe('DIV');
      expect(element).toHaveClass('neba-grid-item');
    });

    it('renders another element when told to', async () => {
      const screen = await render(
        <GridContainer render={<ul />}>
          <Grid render={<li />}>content</Grid>
        </GridContainer>
      );

      expect(screen.getByText('content').element().tagName).toBe('LI');
    });

    it('merges its own classes with the ones it is given', async () => {
      const screen = await render(<Grid className="my-own-class">content</Grid>);
      const element = screen.getByText('content').element();

      expect(element).toHaveClass('my-own-class');
      expect(element).toHaveClass('neba-grid-item');
    });

    it('forwards unknown props to the element', async () => {
      const screen = await render(
        <Grid id="cell" role="listitem">
          content
        </Grid>
      );
      const element = screen.getByText('content').element();

      expect(element).toHaveAttribute('id', 'cell');
      expect(element).toHaveAttribute('role', 'listitem');
    });
  });

  describe('span', () => {
    it('sets no slot at all when no span was given', async () => {
      const screen = await render(<Grid>content</Grid>);
      const element = screen.getByText('content').element() as HTMLElement;

      // The stylesheet falls back to the container's column count, which is a
      // full row. Writing that number here would freeze it at one breakpoint.
      expect(element.style.getPropertyValue('--n-span-xs')).toBe('');
    });

    it('maps a plain span onto the xs slot', async () => {
      const screen = await render(<Grid span={6}>content</Grid>);
      const element = screen.getByText('content').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-span-xs')).toBe('6');

      await screen.rerender(<Grid span={4}>content</Grid>);

      expect(element.style.getPropertyValue('--n-span-xs')).toBe('4');
    });

    it('emits one slot per named breakpoint and leaves the rest to the cascade', async () => {
      const screen = await render(<Grid span={{ xs: 12, md: 6, lg: 4 }}>content</Grid>);
      const element = screen.getByText('content').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-span-xs')).toBe('12');
      expect(element.style.getPropertyValue('--n-span-md')).toBe('6');
      expect(element.style.getPropertyValue('--n-span-lg')).toBe('4');
      expect(element.style.getPropertyValue('--n-span-sm')).toBe('');
      expect(element.style.getPropertyValue('--n-span-xl')).toBe('');
    });

    it('drops a breakpoint from the slots when it is dropped from the map', async () => {
      const screen = await render(<Grid span={{ xs: 12, md: 6 }}>content</Grid>);
      const element = screen.getByText('content').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-span-md')).toBe('6');

      await screen.rerender(<Grid span={{ xs: 12 }}>content</Grid>);

      expect(element.style.getPropertyValue('--n-span-md')).toBe('');
    });

    it('rounds a span and never lets it reach zero', async () => {
      const screen = await render(<Grid span={0}>content</Grid>);
      const element = screen.getByText('content').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-span-xs')).toBe('1');

      await screen.rerender(<Grid span={6.4}>content</Grid>);

      expect(element.style.getPropertyValue('--n-span-xs')).toBe('6');
    });
  });

  describe('offset', () => {
    it('sets no slot at all when no offset was given', async () => {
      const screen = await render(<Grid span={6}>content</Grid>);
      const element = screen.getByText('content').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-offset-xs')).toBe('');
    });

    it('maps an offset onto its own slots', async () => {
      const screen = await render(
        <Grid span={4} offset={{ xs: 0, md: 4 }}>
          content
        </Grid>
      );
      const element = screen.getByText('content').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-offset-xs')).toBe('0');
      expect(element.style.getPropertyValue('--n-offset-md')).toBe('4');
    });

    it('allows zero but not a negative offset', async () => {
      const screen = await render(<Grid offset={0}>content</Grid>);
      const element = screen.getByText('content').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-offset-xs')).toBe('0');

      await screen.rerender(<Grid offset={-3}>content</Grid>);

      expect(element.style.getPropertyValue('--n-offset-xs')).toBe('0');
    });
  });

  describe('alignSelf', () => {
    it('maps onto a class, and applies none when unset', async () => {
      const screen = await render(<Grid>content</Grid>);
      const element = screen.getByText('content').element();

      expect(element.className).not.toContain('self-');

      await screen.rerender(<Grid alignSelf="center">content</Grid>);

      expect(element).toHaveClass('self-center');
    });
  });

  describe('keeping caller styles', () => {
    it('keeps caller-supplied inline styles alongside the slots', async () => {
      const screen = await render(
        <Grid span={6} style={{ minHeight: '4rem' }}>
          content
        </Grid>
      );
      const element = screen.getByText('content').element() as HTMLElement;

      expect(element.style.minHeight).toBe('4rem');
      expect(element.style.getPropertyValue('--n-span-xs')).toBe('6');
    });

    it('never applies a transform', async () => {
      const screen = await render(<Grid span={6}>content</Grid>);
      const element = screen.getByText('content').element();

      expect(element.outerHTML).not.toContain('scale');
      expect(element.outerHTML).not.toContain('translate');
    });
  });
});
