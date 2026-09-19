import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { InlineCitation } from 'neba';

describe('InlineCitation', () => {
  describe('the mark', () => {
    it('draws the number it was given', async () => {
      const screen = await render(<InlineCitation index={3} />);

      await expect.element(screen.getByText('3')).toBeInTheDocument();
    });

    it('is named in words, since the mark itself only says a number', async () => {
      const screen = await render(<InlineCitation index={3} />);

      await expect.element(screen.getByLabelText('Source 3')).toBeInTheDocument();
    });

    it('links where it was pointed', async () => {
      const screen = await render(<InlineCitation index={1} href="https://example.com/a" />);

      await expect
        .element(screen.getByLabelText('Source 1'))
        .toHaveAttribute('href', 'https://example.com/a');
    });

    it('refuses an address whose scheme is not one of the four', async () => {
      const screen = await render(<InlineCitation index={1} href="javascript:alert(1)" />);

      await expect.element(screen.getByLabelText('Source 1')).not.toHaveAttribute('href');
    });

    it('protects a link that leaves the tab', async () => {
      const screen = await render(
        <InlineCitation index={1} href="https://example.com/a" target="_blank" />
      );

      await expect
        .element(screen.getByLabelText('Source 1'))
        .toHaveAttribute('rel', 'noopener noreferrer');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<InlineCitation index={1} className="my-own-class" />);

      expect(screen.getByLabelText('Source 1').element()).toHaveClass('my-own-class');
    });
  });

  describe('the preview', () => {
    it('uncovers the source when the pointer rests on the mark', async () => {
      const screen = await render(
        <InlineCitation
          index={2}
          title="Design language"
          site="example.com"
          description="A Neba surface is a sheet of cut acrylic."
          href="https://example.com/design"
        />
      );

      await screen.getByLabelText('Source 2').hover();

      await expect.element(screen.getByText('Design language')).toBeInTheDocument();
    });

    it('is a bare mark when there is nothing to preview', async () => {
      const screen = await render(<InlineCitation index={2} href="https://example.com/a" />);

      await screen.getByLabelText('Source 2').hover();

      expect(screen.getByRole('dialog').query()).toBeNull();
    });

    it('is a bare mark when the preview is turned off', async () => {
      const screen = await render(
        <InlineCitation index={2} title="Design language" preview={false} />
      );

      await screen.getByLabelText('Source 2').hover();

      expect(screen.getByText('Design language').query()).toBeNull();
    });
  });
});
