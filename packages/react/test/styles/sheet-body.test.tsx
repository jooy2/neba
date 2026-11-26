/**
 * The scrolling body of a Dialog and a Drawer, measured with the stylesheet on.
 *
 * A scroll container clips at its padding box, and a field whose label floats
 * on its top edge draws that label half its line box above the field. The body
 * had 4px of room above its first child, which is enough for a focus ring and
 * not for a floated label: at `lg` the label rose 7.5px and lost the top 3.5px.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Dialog, Drawer, TextField } from 'neba';
import type { NebaSize } from 'neba';
import standaloneCss from '../../src/standalone.css?inline';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

const sizes: NebaSize[] = ['xs', 'sm', 'md', 'lg', 'xl'];

/** The floated label of the first field on the page, and the body it sits in. */
function labelAndBody(): { label: DOMRect; body: DOMRect; header: DOMRect | null } {
  const label = document.querySelector<HTMLElement>('.neba-notch-label')!;
  let body = label.parentElement!;
  while (getComputedStyle(body).overflowY !== 'auto') {
    body = body.parentElement!;
  }
  const header = body.previousElementSibling;

  return {
    label: label.getBoundingClientRect(),
    body: body.getBoundingClientRect(),
    header: header ? header.getBoundingClientRect() : null
  };
}

const field = (size: NebaSize) => (
  <TextField size={size} label="Name" labelPlacement="float" defaultValue="Draft" />
);

describe('a floated label at the top of a sheet body', () => {
  describe.each(sizes)('at %s', (size) => {
    it('is not clipped by a Dialog body under a header', async () => {
      const screen = await render(
        <Dialog open title="Save template" description="Name it." size={size}>
          {field(size)}
        </Dialog>
      );
      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
      const { label, body, header } = labelAndBody();

      expect(label.top).toBeGreaterThanOrEqual(body.top);
      // The room is taken back out of the gap under the header, never out of
      // the header itself, or the body would cover the header's last pixels.
      expect(body.top).toBeGreaterThanOrEqual(header!.bottom);
    });

    it('is not clipped by a Dialog body with no header', async () => {
      const screen = await render(
        <Dialog open showClose={false} size={size}>
          {field(size)}
        </Dialog>
      );
      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
      const { label, body } = labelAndBody();

      expect(label.top).toBeGreaterThanOrEqual(body.top);
    });

    it('is not clipped by a Dialog body with dividers', async () => {
      const screen = await render(
        <Dialog open title="Save template" dividers size={size} density="compact">
          {field(size)}
        </Dialog>
      );
      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
      const { label, body } = labelAndBody();

      expect(label.top).toBeGreaterThanOrEqual(body.top);
    });

    it('is not clipped by an overlay Drawer body under a header', async () => {
      const screen = await render(
        <Drawer open title="Save template" description="Name it." size={size}>
          {field(size)}
        </Drawer>
      );
      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
      const { label, body, header } = labelAndBody();

      expect(label.top).toBeGreaterThanOrEqual(body.top);
      expect(body.top).toBeGreaterThanOrEqual(header!.bottom);
    });

    it('is not clipped by an inline Drawer body with no header', async () => {
      await render(
        <Drawer mode="inline" size={size}>
          {field(size)}
        </Drawer>
      );
      const { label, body } = labelAndBody();

      expect(label.top).toBeGreaterThanOrEqual(body.top);
    });
  });

  it('leaves the field where it was', async () => {
    const screen = await render(
      <Dialog open title="Save template" size="lg">
        {field('lg')}
      </Dialog>
    );
    const popup = screen.getByRole('dialog');
    await expect.element(popup).toBeInTheDocument();
    const { header } = labelAndBody();
    const shell = document.querySelector<HTMLElement>('.neba-notch')!.getBoundingClientRect();
    const gap = parseFloat(getComputedStyle(popup.element()).rowGap);

    // The room above the body is handed back in full, so the sheet's own gap
    // is all that stands between the header and the field.
    expect(gap).toBeGreaterThan(0);
    expect(shell.top - header!.bottom).toBeCloseTo(gap, 1);
  });
});
