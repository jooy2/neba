import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Container } from 'neba';

describe('Container', () => {
  describe('rendering', () => {
    it('renders a div holding its children', async () => {
      const screen = await render(<Container>content</Container>);
      const element = screen.getByText('content').element();

      expect(element.tagName).toBe('DIV');
      expect(element.textContent).toBe('content');
    });

    it('renders another element when told to', async () => {
      const screen = await render(<Container render={<main />}>content</Container>);

      expect(screen.getByText('content').element().tagName).toBe('MAIN');
    });

    it('merges its own classes with the ones it is given', async () => {
      const screen = await render(<Container className="my-own-class">content</Container>);
      const element = screen.getByText('content').element();

      expect(element).toHaveClass('my-own-class');
      expect(element).toHaveClass('w-full');
    });

    it('forwards unknown props to the element', async () => {
      const screen = await render(
        <Container id="page" aria-label="Page">
          content
        </Container>
      );
      const element = screen.getByText('content').element();

      expect(element).toHaveAttribute('id', 'page');
      expect(element).toHaveAttribute('aria-label', 'Page');
    });
  });

  describe('padding', () => {
    it('pads horizontally only', async () => {
      const screen = await render(<Container>content</Container>);
      const element = screen.getByText('content').element();

      expect(element).toHaveClass('px-4');
      expect(element.className).not.toContain('py-');
    });

    it('follows the size and density scale', async () => {
      const screen = await render(<Container size="xl">content</Container>);
      const element = screen.getByText('content').element();

      expect(element).toHaveClass('px-6');

      await screen.rerender(
        <Container size="xl" density="compact">
          content
        </Container>
      );

      expect(element).toHaveClass('px-4');
      expect(element).not.toHaveClass('px-6');
    });

    it('drops the padding entirely when padded is false', async () => {
      const screen = await render(<Container padded={false}>content</Container>);
      const element = screen.getByText('content').element();

      expect(element.className).not.toContain('px-');
    });
  });

  describe('measure', () => {
    it('has no width limit by default', async () => {
      // The slot is left unset, so the cascade's own fallback — `none` — is
      // what `max-w-(--n-max-w)` resolves to. That is also why a caller who
      // names only `{ lg: 'xl' }` gets no measure below 64rem rather than a
      // silent one.
      const screen = await render(<Container>content</Container>);
      const element = screen.getByText('content').element();

      expect(element.style.getPropertyValue('--n-max-w-xs')).toBe('');
    });

    it('maps maxWidth onto the measure ladder', async () => {
      const screen = await render(<Container maxWidth="lg">content</Container>);
      const element = screen.getByText('content').element();

      expect(element.style.getPropertyValue('--n-max-w-xs')).toBe('64rem');

      await screen.rerender(<Container maxWidth="sm">content</Container>);

      expect(element.style.getPropertyValue('--n-max-w-xs')).toBe('40rem');
    });

    it('takes a length of its own, and a number as pixels', async () => {
      const screen = await render(<Container maxWidth="60ch">content</Container>);
      const element = screen.getByText('content').element();

      expect(element.style.getPropertyValue('--n-max-w-xs')).toBe('60ch');

      await screen.rerender(<Container maxWidth={640}>content</Container>);

      expect(element.style.getPropertyValue('--n-max-w-xs')).toBe('640px');
    });

    it('changes at a breakpoint, writing only the steps it was given', async () => {
      const screen = await render(
        <Container maxWidth={{ xs: 'none', lg: 'xl' }}>content</Container>
      );
      const element = screen.getByText('content').element();

      expect(element.style.getPropertyValue('--n-max-w-xs')).toBe('none');
      expect(element.style.getPropertyValue('--n-max-w-lg')).toBe('80rem');
      expect(element.style.getPropertyValue('--n-max-w-md')).toBe('');
    });

    it('centres by default and stops on request', async () => {
      const screen = await render(<Container maxWidth="md">content</Container>);
      const element = screen.getByText('content').element();

      expect(element).toHaveClass('mx-auto');

      await screen.rerender(
        <Container maxWidth="md" centered={false}>
          content
        </Container>
      );

      expect(element).not.toHaveClass('mx-auto');
    });
  });
});
