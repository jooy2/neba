import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Blockquote } from 'neba';

describe('Blockquote', () => {
  describe('rendering', () => {
    it('renders its children inside a real blockquote', async () => {
      const screen = await render(<Blockquote>Design is how it works.</Blockquote>);
      const quote = screen.container.querySelector('blockquote');

      expect(quote).not.toBeNull();
      expect(quote?.textContent).toContain('Design is how it works.');
    });

    it('is a plain wrapper with no attribution and a figure with one', async () => {
      const screen = await render(<Blockquote>Design is how it works.</Blockquote>);

      expect(screen.container.querySelector('figure')).toBeNull();

      await screen.rerender(<Blockquote author="Steve Jobs">Design is how it works.</Blockquote>);

      expect(screen.container.querySelector('figure')).not.toBeNull();
    });

    // The spec is explicit that the attribution goes outside the quote: a name
    // inside it claims the speaker said their own name.
    it('keeps the attribution out of the blockquote', async () => {
      const screen = await render(
        <Blockquote author="Steve Jobs" source="Wired, 1996">
          Design is how it works.
        </Blockquote>
      );
      const quote = screen.container.querySelector('blockquote');

      expect(quote?.textContent).not.toContain('Steve Jobs');
      expect(screen.container.querySelector('figcaption')?.textContent).toContain('Steve Jobs');
    });

    it('renders the source in a cite element and the author outside one', async () => {
      const screen = await render(
        <Blockquote author="Steve Jobs" source="Wired, 1996">
          Design is how it works.
        </Blockquote>
      );
      const cite = screen.container.querySelector('cite');

      expect(cite?.textContent).toBe('Wired, 1996');
      expect(cite?.textContent).not.toContain('Steve Jobs');
    });

    it('becomes a figure for a source with no author', async () => {
      const screen = await render(<Blockquote source="RFC 2119">MUST, SHOULD, MAY.</Blockquote>);

      expect(screen.container.querySelector('figure')).not.toBeNull();
    });

    it('puts cite on the blockquote where the spec asks for it', async () => {
      const screen = await render(
        <Blockquote cite="https://example.com/talk">Design is how it works.</Blockquote>
      );

      expect(screen.container.querySelector('blockquote')).toHaveAttribute(
        'cite',
        'https://example.com/talk'
      );
    });

    it('reflects changed children on re-render', async () => {
      const screen = await render(<Blockquote>Before</Blockquote>);

      await screen.rerender(<Blockquote>After</Blockquote>);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Blockquote className="my-own-class">Quoted</Blockquote>);

      expect(screen.container.firstElementChild).toHaveClass('my-own-class');
    });
  });

  describe('the mark', () => {
    it('draws the house glyph by default', async () => {
      const screen = await render(<Blockquote>Quoted</Blockquote>);

      expect(screen.container.querySelector('svg')).not.toBeNull();
    });

    it('takes it away for icon={false}', async () => {
      const screen = await render(<Blockquote icon={false}>Quoted</Blockquote>);

      expect(screen.container.querySelector('svg')).toBeNull();
    });

    it('replaces it with a node', async () => {
      const screen = await render(<Blockquote icon={<span>MARK</span>}>Quoted</Blockquote>);

      expect(screen.container.querySelector('svg')).toBeNull();
      await expect.element(screen.getByText('MARK')).toBeInTheDocument();
    });
  });

  describe('style props', () => {
    it('maps color onto the token slots the styles read from', async () => {
      const screen = await render(<Blockquote color="danger">Quoted</Blockquote>);
      const element = screen.container.firstElementChild as HTMLElement;

      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-danger-accent)');
    });

    // A quote holds somebody else's words, so the sheet under them is never
    // dyed — the family shows up in the rule and the mark instead.
    it('leaves the panel ladder undyed', async () => {
      const screen = await render(<Blockquote color="danger">Quoted</Blockquote>);
      const element = screen.container.firstElementChild as HTMLElement;

      expect(element.style.getPropertyValue('--n-panel')).toBe('var(--neba-panel)');
    });

    it('keeps the accent rule in every variant', async () => {
      const screen = await render(<Blockquote>Quoted</Blockquote>);
      const element = screen.container.firstElementChild as HTMLElement;

      expect(element).toHaveClass('border-s-2');

      await screen.rerender(<Blockquote variant="solid">Quoted</Blockquote>);
      expect(element).toHaveClass('border-s-2');

      await screen.rerender(<Blockquote variant="outline">Quoted</Blockquote>);
      expect(element).toHaveClass('border-s-2');
    });

    it('draws no sheet for the default text variant', async () => {
      const screen = await render(<Blockquote>Quoted</Blockquote>);
      const element = screen.container.firstElementChild as HTMLElement;

      expect(element).toHaveClass('bg-transparent');
      expect(element).not.toHaveClass('border');
    });

    it('is flat by default and maps elevation onto the shadow scale', async () => {
      const screen = await render(<Blockquote variant="solid">Quoted</Blockquote>);
      const element = screen.container.firstElementChild as HTMLElement;

      expect(element.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-0)');

      await screen.rerender(
        <Blockquote variant="solid" elevation={2}>
          Quoted
        </Blockquote>
      );

      expect(element.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-2)');
    });

    it('changes padding with density but not the type scale', async () => {
      const screen = await render(<Blockquote size="lg">Quoted</Blockquote>);
      const element = screen.container.firstElementChild as HTMLElement;
      const quote = screen.container.querySelector('blockquote');

      expect(element).toHaveClass('p-5');
      expect(quote).toHaveClass('text-[1.0625rem]/[1.875rem]');

      await screen.rerender(
        <Blockquote size="lg" density="compact">
          Quoted
        </Blockquote>
      );

      expect(element).toHaveClass('p-3');
      expect(quote).toHaveClass('text-[1.0625rem]/[1.875rem]');
    });
  });

  describe('transition', () => {
    it('takes an entrance animation', async () => {
      const screen = await render(
        <Blockquote transition="fade" data-testid="quote">
          Rosebud
        </Blockquote>
      );

      expect(screen.getByTestId('quote').element()).toHaveClass('neba-anim-fade');
    });
  });
});
