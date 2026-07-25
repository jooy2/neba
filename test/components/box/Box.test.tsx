import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Box } from 'neba';

describe('Box', () => {
  describe('rendering', () => {
    it('renders a div holding its children', async () => {
      const screen = await render(<Box>content</Box>);
      const element = screen.getByText('content').element();

      expect(element.tagName).toBe('DIV');
      expect(element.textContent).toBe('content');
    });

    it('renders another element when told to', async () => {
      const screen = await render(<Box render={<section />}>content</Box>);

      expect(screen.getByText('content').element().tagName).toBe('SECTION');
    });

    it('merges its own classes with the ones it is given', async () => {
      const screen = await render(
        <Box render={<section className="from-render" />} className="my-own-class">
          content
        </Box>
      );
      const element = screen.getByText('content').element();

      expect(element).toHaveClass('my-own-class');
      expect(element).toHaveClass('from-render');
      expect(element).toHaveClass('block');
    });

    it('forwards unknown props to the element', async () => {
      const screen = await render(
        <Box id="panel" role="group" aria-label="Panel">
          content
        </Box>
      );
      const element = screen.getByText('content').element();

      expect(element).toHaveAttribute('id', 'panel');
      expect(element).toHaveAttribute('role', 'group');
      expect(element).toHaveAttribute('aria-label', 'Panel');
    });

    it('reflects changed children on re-render', async () => {
      const screen = await render(<Box>before</Box>);

      await screen.rerender(<Box>after</Box>);

      await expect.element(screen.getByText('after')).toBeInTheDocument();
      expect(screen.getByText('before').query()).toBeNull();
    });
  });

  describe('style props', () => {
    it('maps color onto the token slots the styles read from', async () => {
      const screen = await render(<Box color="success">content</Box>);
      const element = screen.getByText('content').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-success-accent)');
      expect(element.style.getPropertyValue('--n-line')).toBe('var(--neba-success-line)');
    });

    it('leaves the surface undyed whatever the color is', async () => {
      const screen = await render(<Box color="success">content</Box>);
      const element = screen.getByText('content').element() as HTMLElement;

      // A container holds other people's content, so the family stops at the
      // hairline: the two panel slots are the neutral ladder, not the family's.
      expect(element.style.getPropertyValue('--n-panel')).toBe('var(--neba-panel)');
      expect(element.style.getPropertyValue('--n-panel-hover')).toBe('var(--neba-panel-hover)');

      await screen.rerender(<Box color="danger">content</Box>);

      expect(element.style.getPropertyValue('--n-panel')).toBe('var(--neba-panel)');
      expect(element.style.getPropertyValue('--n-line')).toBe('var(--neba-danger-line)');
    });

    it('defaults to the primary color', async () => {
      const screen = await render(<Box>content</Box>);
      const element = screen.getByText('content').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-primary-accent)');
      expect(element.style.getPropertyValue('--n-line')).toBe('var(--neba-primary-line)');
    });

    it('is flat by default and maps elevation onto the shadow scale', async () => {
      const screen = await render(<Box>content</Box>);
      const element = screen.getByText('content').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-0)');

      await screen.rerender(<Box elevation={3}>content</Box>);

      expect(element.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-3)');
    });

    it('keeps caller-supplied inline styles alongside the slots', async () => {
      const screen = await render(<Box style={{ width: '10rem' }}>content</Box>);
      const element = screen.getByText('content').element() as HTMLElement;

      expect(element.style.width).toBe('10rem');
      expect(element.style.getPropertyValue('--n-panel')).toBe('var(--neba-panel)');
    });

    it('changes the radius with size, and nothing else', async () => {
      const screen = await render(<Box size="md">content</Box>);
      const element = screen.getByText('content').element();

      expect(element).toHaveClass('rounded-(--neba-radius-md)');

      await screen.rerender(<Box size="xl">content</Box>);

      expect(element).toHaveClass('rounded-(--neba-radius-xl)');
      expect(element).not.toHaveClass('rounded-(--neba-radius-md)');
    });

    it('changes padding with size and with density', async () => {
      const screen = await render(<Box size="lg">content</Box>);
      const element = screen.getByText('content').element();

      expect(element).toHaveClass('p-5');

      await screen.rerender(
        <Box size="lg" density="compact">
          content
        </Box>
      );

      expect(element).toHaveClass('p-3');
      expect(element).not.toHaveClass('p-5');
    });

    it('drops the padding entirely when padded is false', async () => {
      const screen = await render(<Box padded={false}>content</Box>);
      const element = screen.getByText('content').element();

      expect(element).not.toHaveClass('p-4');
    });

    it('draws a border for the outline variant only', async () => {
      const screen = await render(<Box variant="outline">content</Box>);
      const element = screen.getByText('content').element();

      expect(element).toHaveClass('border');

      await screen.rerender(<Box variant="solid">content</Box>);
      expect(element).not.toHaveClass('border');

      await screen.rerender(<Box variant="text">content</Box>);
      expect(element).not.toHaveClass('border');
    });

    it('gives the text variant no surface and no shadow', async () => {
      const screen = await render(
        <Box variant="text" elevation={3}>
          content
        </Box>
      );
      const element = screen.getByText('content').element();

      expect(element).toHaveClass('bg-transparent');
      // `box-shadow` on its own also appears in the transition property list,
      // so this looks for the declaration rather than the word.
      expect(element.className).not.toContain('[box-shadow:');
      expect(element.className).not.toContain('[backdrop-filter:');
    });

    it('never applies a transform, so nothing in the box can move', async () => {
      const screen = await render(<Box elevation={3}>content</Box>);
      const element = screen.getByText('content').element();

      expect(element.outerHTML).not.toContain('scale');
      expect(element.outerHTML).not.toContain('translate');
    });
  });
});
