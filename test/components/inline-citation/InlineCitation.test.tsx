import type * as React from 'react';
import { describe, expect, it, vi } from 'vitest';
import { renderToString } from 'react-dom/server';
import { render } from 'vitest-browser-react';
import { InlineCitation } from 'neba';
import { hoverCardChunk } from '../../../src/components/inline-citation/InlineCitation.js';

describe('InlineCitation', () => {
  describe('the mark', () => {
    it('draws the number it was given', async () => {
      const screen = await render(<InlineCitation index={3} />);

      await expect.element(screen.getByText('3')).toBeInTheDocument();
    });

    it('is named in words, since the mark itself only says a number', async () => {
      const screen = await render(<InlineCitation index={3} href="https://example.com/a" />);

      await expect.element(screen.getByRole('link', { name: 'Source 3' })).toBeInTheDocument();
    });

    // An `<a>` with no `href` is not a link: it takes no focus, and its
    // `aria-label` is one a screen reader may not read.
    it('says its name in text when there is no link', async () => {
      const screen = await render(<InlineCitation index={3} data-testid="mark" />);
      const mark = screen.getByTestId('mark').element();

      expect(mark.tagName).toBe('SPAN');
      expect(mark.textContent).toContain('Source 3');
      expect(mark.querySelector('[aria-hidden="true"]')?.textContent).toBe('3');
    });

    it('takes the focus without a link only when it has a preview to open', async () => {
      const screen = await render(<InlineCitation index={3} data-testid="mark" />);

      expect(screen.getByTestId('mark').element()).not.toHaveAttribute('tabindex');

      await screen.rerender(
        <InlineCitation index={3} title="Design language" data-testid="mark" />
      );

      expect(screen.getByTestId('mark').element()).toHaveAttribute('tabindex', '0');
    });

    it('links where it was pointed', async () => {
      const screen = await render(<InlineCitation index={1} href="https://example.com/a" />);

      await expect
        .element(screen.getByLabelText('Source 1'))
        .toHaveAttribute('href', 'https://example.com/a');
    });

    it('refuses an address whose scheme is not one of the four', async () => {
      const screen = await render(<InlineCitation index={1} href="javascript:alert(1)" />);

      await expect.element(screen.getByText('Source 1')).toBeInTheDocument();
      expect(screen.container.querySelector('a')).toBeNull();
    });

    it('protects a link that leaves the tab', async () => {
      const screen = await render(
        <InlineCitation index={1} href="https://example.com/a" target="_blank" />
      );

      await expect
        .element(screen.getByLabelText('Source 1 (opens in a new tab)'))
        .toHaveAttribute('rel', 'noopener noreferrer');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <InlineCitation index={1} className="my-own-class" data-testid="mark" />
      );

      expect(screen.getByTestId('mark').element()).toHaveClass('my-own-class');
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

    it('opens its preview from the keyboard when there is no link', async () => {
      const screen = await render(
        <InlineCitation index={2} title="Design language" data-testid="mark" />
      );

      (screen.getByTestId('mark').element() as HTMLElement).focus();

      await expect.element(screen.getByText('Design language')).toBeInTheDocument();
    });

    it('is a bare mark when there is nothing to preview', async () => {
      const screen = await render(<InlineCitation index={2} href="https://example.com/a" />);

      await screen.getByLabelText('Source 2').hover();

      expect(screen.getByRole('dialog').query()).toBeNull();
    });

    it('is a bare mark when the preview is turned off', async () => {
      const screen = await render(
        <InlineCitation index={2} title="Design language" preview={false} data-testid="mark" />
      );

      await screen.getByTestId('mark').hover();

      expect(screen.getByText('Design language').query()).toBeNull();
    });

    it('opens its preview from the keyboard on a link too', async () => {
      const screen = await render(
        <InlineCitation index={2} title="Design language" href="https://example.com/design" />
      );

      (screen.getByLabelText('Source 2').element() as HTMLElement).focus();

      await expect.element(screen.getByText('Design language')).toBeInTheDocument();
    });
  });

  /*
   * The card was most of what a citation weighed, carried by every answer with
   * a footnote whether anybody reached for one or not. It is fetched on the
   * first reach, and the mark is bare until then.
   */
  describe("the preview's chunk", () => {
    // Out from under wherever an earlier test left the pointer, which a mark
    // drawn there would take for a pointer arriving.
    const below = (child: React.ReactNode) => <div style={{ paddingTop: 320 }}>{child}</div>;

    it('is asked for when a pointer arrives over the mark, and not before', async () => {
      const load = vi.spyOn(hoverCardChunk, 'load');

      try {
        const screen = await render(
          below(<InlineCitation index={2} title="Design language" data-testid="mark" />)
        );
        const mark = screen.getByTestId('mark');

        await new Promise(requestAnimationFrame);
        expect(load).not.toHaveBeenCalled();

        await mark.hover();
        expect(load).toHaveBeenCalled();
      } finally {
        load.mockRestore();
      }
    });

    it('is asked for when the focus reaches the mark', async () => {
      const load = vi.spyOn(hoverCardChunk, 'load');

      try {
        const screen = await render(
          <InlineCitation index={2} title="Design language" data-testid="mark" />
        );

        (screen.getByTestId('mark').element() as HTMLElement).focus();

        expect(load).toHaveBeenCalled();
      } finally {
        load.mockRestore();
      }
    });

    it('is never asked for by a mark with nothing to preview', async () => {
      const load = vi.spyOn(hoverCardChunk, 'load');

      try {
        const screen = await render(
          below(<InlineCitation index={2} href="https://example.com/a" />)
        );

        await screen.getByLabelText('Source 2').hover();

        expect(load).not.toHaveBeenCalled();
      } finally {
        load.mockRestore();
      }
    });

    it('is not asked for by a server render, which draws the bare mark', () => {
      const load = vi.spyOn(hoverCardChunk, 'load');

      try {
        const html = renderToString(
          <InlineCitation index={2} title="Design language" href="https://example.com/design" />
        );

        expect(load).not.toHaveBeenCalled();
        expect(html).not.toContain('<!--$');
        expect(html).toContain('href="https://example.com/design"');
      } finally {
        load.mockRestore();
      }
    });

    // The card's trigger takes the bare mark's place, and the focus that was
    // on the mark would otherwise fall to the body.
    it('keeps the focus on the mark when the card arrives', async () => {
      const screen = await render(
        <InlineCitation index={2} title="Design language" href="https://example.com/design" />
      );

      (screen.getByLabelText('Source 2').element() as HTMLElement).focus();

      await expect.element(screen.getByText('Design language')).toBeInTheDocument();
      expect(document.activeElement).toBe(screen.getByLabelText('Source 2').element());
    });

    it("hands the caller's ref the mark it ends up on", async () => {
      const ref = { current: null as HTMLElement | null };
      const screen = await render(
        below(
          <InlineCitation
            ref={ref}
            index={2}
            title="Design language"
            href="https://example.com/design"
          />
        )
      );

      await screen.getByLabelText('Source 2').hover();
      await expect
        .element(screen.getByText('Design language'), { timeout: 3000 })
        .toBeInTheDocument();

      expect(ref.current).toBe(screen.getByLabelText('Source 2').element());
    });
  });
});
