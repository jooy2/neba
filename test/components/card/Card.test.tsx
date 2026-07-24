import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Card } from 'neba';

describe('Card', () => {
  describe('structure', () => {
    it('renders the title, the subtitle, the body and the footer', async () => {
      const screen = await render(
        <Card title="Invoice" subtitle="March 2026" footer={<span>Paid</span>}>
          Twelve seats
        </Card>
      );

      await expect.element(screen.getByText('Invoice')).toBeInTheDocument();
      await expect.element(screen.getByText('March 2026')).toBeInTheDocument();
      await expect.element(screen.getByText('Twelve seats')).toBeInTheDocument();
      await expect.element(screen.getByText('Paid')).toBeInTheDocument();
    });

    it('lays the sections out in order', async () => {
      const screen = await render(
        <Card title="Invoice" footer="Footer" data-testid="card">
          Body
        </Card>
      );
      const sections = [...screen.getByTestId('card').element().children];

      expect(sections.map((section) => section.textContent)).toEqual(['Invoice', 'Body', 'Footer']);
    });

    it('leaves out the sections it was given nothing for', async () => {
      const screen = await render(<Card data-testid="card">Body only</Card>);
      const root = screen.getByTestId('card').element();

      expect(root.children).toHaveLength(1);
      expect(root.textContent).toBe('Body only');
    });

    it('renders a header with no body and no footer', async () => {
      const screen = await render(<Card title="Alone" data-testid="card" />);
      const root = screen.getByTestId('card').element();

      expect(root.children).toHaveLength(1);
      expect(root.textContent).toBe('Alone');
    });

    it('places headerAction at the end of the header row', async () => {
      const screen = await render(
        <Card title="Invoice" headerAction={<button type="button">Menu</button>} data-testid="card">
          Body
        </Card>
      );
      const header = screen.getByTestId('card').element().children[0];

      expect(header.textContent).toBe('InvoiceMenu');
      expect(header.lastElementChild?.textContent).toBe('Menu');
    });

    it('renders a header made only of a headerAction', async () => {
      const screen = await render(<Card headerAction={<span>Only</span>} data-testid="card" />);
      const root = screen.getByTestId('card').element();

      expect(root.children).toHaveLength(1);
      expect(root.textContent).toBe('Only');
    });

    it('reflects a changed title on re-render', async () => {
      const screen = await render(<Card title="Before" />);

      await screen.rerender(<Card title="After" />);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('takes a heading element as the title without it landing in the title attribute', async () => {
      const screen = await render(<Card title={<h2>Invoice</h2>} data-testid="card" />);
      const root = screen.getByTestId('card').element();

      await expect.element(screen.getByRole('heading', { name: 'Invoice' })).toBeInTheDocument();
      expect(root.hasAttribute('title')).toBe(false);
    });

    it('lays the footer out as a row', async () => {
      const screen = await render(
        <Card footer={<span>Action</span>} data-testid="card">
          Body
        </Card>
      );
      const footer = screen.getByTestId('card').element().children[1];

      expect(footer).toHaveClass('flex');
      expect(footer.textContent).toBe('Action');
    });
  });

  describe('dividers', () => {
    it('separates the sections with space by default', async () => {
      const screen = await render(
        <Card title="Invoice" footer="Footer" data-testid="card">
          Body
        </Card>
      );
      const root = screen.getByTestId('card').element();

      expect(root).toHaveClass('py-4');
      expect(root).toHaveClass('gap-3');
      expect([...root.children].every((section) => !section.classList.contains('border-t'))).toBe(
        true
      );
    });

    it('draws a hairline between the sections, but not above the first', async () => {
      const screen = await render(
        <Card title="Invoice" footer="Footer" dividers data-testid="card">
          Body
        </Card>
      );
      const sections = [...screen.getByTestId('card').element().children];

      expect(sections[0]).not.toHaveClass('border-t');
      expect(sections[1]).toHaveClass('border-t');
      expect(sections[2]).toHaveClass('border-t');
    });

    it('moves the vertical padding from the sheet onto the sections', async () => {
      const screen = await render(
        <Card title="Invoice" data-testid="card">
          Body
        </Card>
      );
      const root = screen.getByTestId('card').element();

      expect(root).toHaveClass('py-4');
      expect(root.children[0]).toHaveClass('px-4');
      expect(root.children[0]).not.toHaveClass('py-4');

      await screen.rerender(
        <Card title="Invoice" dividers data-testid="card">
          Body
        </Card>
      );

      expect(root).not.toHaveClass('py-4');
      expect(root.children[0]).toHaveClass('px-4');
      expect(root.children[0]).toHaveClass('py-4');
    });
  });

  describe('style props', () => {
    it('passes the box style props through to the sheet', async () => {
      const screen = await render(
        <Card color="danger" elevation={2} variant="solid" data-testid="card" />
      );
      const root = screen.getByTestId('card').element() as HTMLElement;

      expect(root.style.getPropertyValue('--n-panel-hover')).toBe('var(--neba-danger-panel-hover)');
      expect(root.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-2)');
      expect(root).not.toHaveClass('border');
    });

    it('is an outline sheet by default', async () => {
      const screen = await render(<Card data-testid="card" />);

      expect(screen.getByTestId('card').element()).toHaveClass('border');
    });

    it('scales the padding with size and density', async () => {
      const screen = await render(
        <Card title="Invoice" size="xl" data-testid="card">
          Body
        </Card>
      );
      const root = screen.getByTestId('card').element();

      expect(root).toHaveClass('py-6');
      expect(root.children[0]).toHaveClass('px-6');

      await screen.rerender(
        <Card title="Invoice" size="xl" density="compact" data-testid="card">
          Body
        </Card>
      );

      expect(root).toHaveClass('py-4');
      expect(root.children[0]).toHaveClass('px-4');
    });

    it('keeps caller-supplied class names on the sheet alongside its own', async () => {
      const screen = await render(<Card className="my-own-class" data-testid="card" />);
      const root = screen.getByTestId('card').element();

      expect(root).toHaveClass('my-own-class');
      expect(root).toHaveClass('flex-col');
    });

    it('never applies a transform, so nothing in the card can move', async () => {
      const screen = await render(
        <Card title="Invoice" subtitle="March 2026" elevation={3} dividers data-testid="card">
          Body
        </Card>
      );
      const root = screen.getByTestId('card').element();

      expect(root.outerHTML).not.toContain('scale');
      expect(root.outerHTML).not.toContain('translate');
    });
  });
});
