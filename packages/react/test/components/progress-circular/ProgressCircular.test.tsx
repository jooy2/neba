import * as React from 'react';
import { describe, expect, it } from 'vitest';
import { renderToString } from 'react-dom/server';
import { render } from 'vitest-browser-react';
import { ProgressCircular } from 'neba';

describe('ProgressCircular', () => {
  describe('rendering', () => {
    it('renders a progress bar', async () => {
      const screen = await render(<ProgressCircular value={40} />);

      await expect.element(screen.getByRole('progressbar')).toBeInTheDocument();
    });

    it('is named by its label', async () => {
      const screen = await render(<ProgressCircular value={40} label="Saving" />);

      await expect.element(screen.getByRole('progressbar', { name: 'Saving' })).toBeInTheDocument();
    });

    it('hides the drawing from a screen reader, which reads the role instead', async () => {
      const screen = await render(<ProgressCircular value={40} />);
      const svg = screen.getByRole('progressbar').element().querySelector('svg');

      expect(svg).toHaveAttribute('aria-hidden', 'true');
    });

    it('reflects a changed value on re-render', async () => {
      const screen = await render(<ProgressCircular value={10} showValue />);

      await expect.element(screen.getByText('10%')).toBeInTheDocument();

      await screen.rerender(<ProgressCircular value={90} showValue />);

      await expect.element(screen.getByText('90%')).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<ProgressCircular value={40} className="my-own-class" />);

      expect(screen.getByRole('progressbar').element()).toHaveClass('my-own-class');
    });
  });

  describe('the arc', () => {
    // The ring is one circle with a dash pattern on it, so the only thing that
    // distinguishes 0% from 100% is the offset. Getting the direction backwards
    // is the classic bug here, and it looks plausible either way.
    it('closes the gap as the value climbs', async () => {
      const screen = await render(<ProgressCircular value={0} />);
      const arc = () =>
        screen.getByRole('progressbar').element().querySelectorAll('circle')[1] as SVGCircleElement;

      const empty = Number(arc().getAttribute('stroke-dashoffset'));

      await screen.rerender(<ProgressCircular value={100} />);
      const full = Number(arc().getAttribute('stroke-dashoffset'));

      expect(empty).toBeGreaterThan(0);
      expect(full).toBe(0);
    });

    it('starts at the top of the ring rather than at three o’clock', async () => {
      const screen = await render(<ProgressCircular value={50} />);
      const arc = screen.getByRole('progressbar').element().querySelectorAll('circle')[1];

      expect(arc.getAttribute('transform')).toContain('rotate(-90');
    });

    it('grows with size', async () => {
      const screen = await render(<ProgressCircular value={40} size="xs" />);
      const small = screen.getByRole('progressbar').element().querySelector('svg');

      expect(small).toHaveAttribute('width', '14');

      await screen.rerender(<ProgressCircular value={40} size="xl" />);

      expect(screen.getByRole('progressbar').element().querySelector('svg')).toHaveAttribute(
        'width',
        '32'
      );
    });
  });

  describe('thickness', () => {
    it('takes a stroke of its own over the step it would have had', async () => {
      const screen = await render(<ProgressCircular value={40} size="xl" thickness={6} />);
      const ring = screen.getByRole('progressbar').element().querySelector('circle');

      expect(ring).toHaveAttribute('stroke-width', '6');
    });

    // Held to the whole radius, a `md` ring given a thick stroke filled in to a
    // disc, although the JSDoc and the page promised half the radius.
    it('holds the stroke to half the radius, so a hole remains', async () => {
      const screen = await render(<ProgressCircular value={40} size="md" thickness={400} />);
      const ring = screen.getByRole('progressbar').element().querySelector('circle');

      expect(ring).toHaveAttribute('stroke-width', '5');
      expect(Number(ring?.getAttribute('r'))).toBe(7.5);
    });
  });

  describe('indeterminate', () => {
    it('is indeterminate by default', async () => {
      const screen = await render(<ProgressCircular />);

      expect(screen.getByRole('progressbar').element()).not.toHaveAttribute('aria-valuenow');
    });

    it('turns instead of filling', async () => {
      const screen = await render(<ProgressCircular />);

      expect(
        screen.getByRole('progressbar').element().querySelector('.neba-ring-spin')
      ).not.toBeNull();
    });

    it('stops turning once it is given a value', async () => {
      const screen = await render(<ProgressCircular />);

      await screen.rerender(<ProgressCircular value={40} />);

      expect(screen.getByRole('progressbar').element().querySelector('.neba-ring-spin')).toBeNull();
    });
  });

  describe('style props', () => {
    it('maps colour onto the token slots', async () => {
      const screen = await render(<ProgressCircular value={40} color="danger" />);
      const element = screen.getByRole('progressbar').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-danger-accent)');
    });
  });

  describe('forwarded props', () => {
    it('takes an accessible name of its own', async () => {
      const screen = await render(<ProgressCircular value={40} aria-label="Uploading" />);

      await expect
        .element(screen.getByRole('progressbar', { name: 'Uploading' }))
        .toBeInTheDocument();
    });
  });

  /*
   * Base UI's label part told the root its id from a layout effect, so the
   * root was named only in a second commit after every mount and every
   * hydration, and a server render named nothing.
   */
  describe('label', () => {
    it('is named by its label in the server render', () => {
      const html = renderToString(<ProgressCircular value={40} label="Sync" />);
      const page = new DOMParser().parseFromString(html, 'text/html');
      const root = page.querySelector('[role="progressbar"]')!;
      const label = page.getElementById(root.getAttribute('aria-labelledby') ?? '');

      expect(label?.textContent).toBe('Sync');
    });

    it('is named by its label in the commit it mounts in', async () => {
      let commits = 0;
      const screen = await render(
        <React.Profiler id="ProgressCircular" onRender={() => (commits += 1)}>
          <ProgressCircular value={40} label="Sync" />
        </React.Profiler>
      );

      await expect.element(screen.getByRole('progressbar', { name: 'Sync' })).toBeInTheDocument();
      expect(commits).toBe(1);
    });

    it("leaves an aria-labelledby of the caller's in place", async () => {
      const screen = await render(
        <ProgressCircular value={40} label="Sync" aria-labelledby="elsewhere" />
      );

      expect(screen.container.querySelector('[role="progressbar"]')).toHaveAttribute(
        'aria-labelledby',
        'elsewhere'
      );
    });

    // Base UI's label part carried the root's status, and the label drawn in
    // its place carries the same one.
    it('carries the status the root carries', async () => {
      for (const [element, attribute] of [
        [<ProgressCircular value={40} label="Sync" />, 'data-progressing'],
        [<ProgressCircular value={100} label="Sync" />, 'data-complete'],
        [<ProgressCircular value={null} label="Sync" />, 'data-indeterminate']
      ] as const) {
        const screen = await render(element);
        const root = screen.getByRole('progressbar').element();

        expect(root).toHaveAttribute(attribute, '');
        expect(screen.getByText('Sync').element()).toHaveAttribute(attribute, '');
        await screen.unmount();
      }
    });
  });
});
