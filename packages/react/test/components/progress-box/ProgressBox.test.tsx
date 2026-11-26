import * as React from 'react';
import { describe, expect, it } from 'vitest';
import { renderToString } from 'react-dom/server';
import { render } from 'vitest-browser-react';
import { ProgressBox } from 'neba';

/**
 * The plates: the children of the track.
 *
 * The track is the last thing the component renders, but not the last child of
 * the root — Base UI appends a visually hidden span of its own after it, which
 * is why this filters the presentational children out rather than just taking
 * `lastElementChild`.
 */
function plates(root: Element): HTMLElement[] {
  const own = Array.from(root.children).filter(
    (child) => child.getAttribute('role') !== 'presentation'
  );

  return Array.from(own[own.length - 1]?.children ?? []) as HTMLElement[];
}

describe('ProgressBox', () => {
  describe('rendering', () => {
    it('draws one plate for a count that is not a finite number', async () => {
      const screen = await render(<ProgressBox value={50} count={Number.POSITIVE_INFINITY} />);

      await expect.element(screen.getByRole('progressbar')).toBeInTheDocument();

      await screen.rerender(<ProgressBox value={50} count={Number.NaN} />);

      expect(
        screen.getByRole('progressbar').element().querySelectorAll('.bg-\\(--n-soft\\)').length
      ).toBe(1);
    });

    it('renders a progress bar', async () => {
      const screen = await render(<ProgressBox value={40} />);

      await expect.element(screen.getByRole('progressbar')).toBeInTheDocument();
    });

    it('draws four plates by default', async () => {
      const screen = await render(<ProgressBox value={40} />);

      expect(plates(screen.getByRole('progressbar').element())).toHaveLength(4);
    });

    it('draws as many plates as it is asked for', async () => {
      const screen = await render(<ProgressBox value={40} count={7} />);

      expect(plates(screen.getByRole('progressbar').element())).toHaveLength(7);
    });

    it('never draws a row of none', async () => {
      const screen = await render(<ProgressBox value={40} count={0} />);

      expect(plates(screen.getByRole('progressbar').element())).toHaveLength(1);
    });

    it('is named by its label', async () => {
      const screen = await render(<ProgressBox value={40} label="Building" />);

      await expect
        .element(screen.getByRole('progressbar', { name: 'Building' }))
        .toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<ProgressBox value={40} className="my-own-class" />);

      expect(screen.getByRole('progressbar').element()).toHaveClass('my-own-class');
    });
  });

  describe('the fill', () => {
    // Four plates could only ever show 0, 25, 50, 75 or 100 if a plate were
    // all-or-nothing, so the leading one is part full instead.
    it('fills the leading plate partially', async () => {
      const screen = await render(<ProgressBox value={30} count={4} />);
      const fills = plates(screen.getByRole('progressbar').element()).map(
        (plate) => (plate.firstElementChild as HTMLElement).style.width
      );

      expect(fills).toEqual(['100%', '20%', '0%', '0%']);
    });

    it('fills every plate at the top of the range', async () => {
      const screen = await render(<ProgressBox value={100} count={3} />);
      const fills = plates(screen.getByRole('progressbar').element()).map(
        (plate) => (plate.firstElementChild as HTMLElement).style.width
      );

      expect(fills).toEqual(['100%', '100%', '100%']);
    });

    it('shows the value as a percentage of the range', async () => {
      const screen = await render(<ProgressBox value={2} min={0} max={4} showValue />);

      await expect.element(screen.getByText('50%')).toBeInTheDocument();
    });
  });

  describe('indeterminate', () => {
    it('is indeterminate by default', async () => {
      const screen = await render(<ProgressBox />);

      expect(screen.getByRole('progressbar').element()).not.toHaveAttribute('aria-valuenow');
    });

    it('cycles the plates instead of filling them', async () => {
      const screen = await render(<ProgressBox />);
      const waving = plates(screen.getByRole('progressbar').element());

      expect(waving).toHaveLength(4);
      expect(waving.every((plate) => plate.classList.contains('neba-plate-wave'))).toBe(true);
    });

    it('holds each plate back by its own index', async () => {
      const screen = await render(<ProgressBox />);
      const indexes = plates(screen.getByRole('progressbar').element()).map((plate) =>
        plate.style.getPropertyValue('--n-i')
      );

      expect(indexes).toEqual(['0', '1', '2', '3']);
    });

    it('stops cycling once it is given a value', async () => {
      const screen = await render(<ProgressBox />);

      await screen.rerender(<ProgressBox value={40} />);

      expect(
        screen.getByRole('progressbar').element().querySelector('.neba-plate-wave')
      ).toBeNull();
    });
  });

  describe('style props', () => {
    it('maps colour onto the token slots', async () => {
      const screen = await render(<ProgressBox value={40} color="info" />);
      const element = screen.getByRole('progressbar').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-info-fill)');
    });

    it('grows the plates with size', async () => {
      const screen = await render(<ProgressBox value={40} size="xl" />);

      expect(plates(screen.getByRole('progressbar').element())[0]).toHaveClass('size-5');
    });
  });

  describe('forwarded props', () => {
    it('takes an accessible name of its own', async () => {
      const screen = await render(<ProgressBox value={40} aria-label="Uploading" />);

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
      const html = renderToString(<ProgressBox value={2} max={5} label="Steps" />);
      const page = new DOMParser().parseFromString(html, 'text/html');
      const root = page.querySelector('[role="progressbar"]')!;
      const label = page.getElementById(root.getAttribute('aria-labelledby') ?? '');

      expect(label?.textContent).toBe('Steps');
    });

    it('is named by its label in the commit it mounts in', async () => {
      let commits = 0;
      const screen = await render(
        <React.Profiler id="ProgressBox" onRender={() => (commits += 1)}>
          <ProgressBox value={2} max={5} label="Steps" />
        </React.Profiler>
      );

      await expect.element(screen.getByRole('progressbar', { name: 'Steps' })).toBeInTheDocument();
      expect(commits).toBe(1);
    });

    it("leaves an aria-labelledby of the caller's in place", async () => {
      const screen = await render(
        <ProgressBox value={2} max={5} label="Steps" aria-labelledby="elsewhere" />
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
        [<ProgressBox value={2} max={5} label="Steps" />, 'data-progressing'],
        [<ProgressBox value={5} max={5} label="Steps" />, 'data-complete'],
        [<ProgressBox value={null} label="Steps" />, 'data-indeterminate']
      ] as const) {
        const screen = await render(element);
        const root = screen.getByRole('progressbar').element();

        expect(root).toHaveAttribute(attribute, '');
        expect(screen.getByText('Steps').element()).toHaveAttribute(attribute, '');
        await screen.unmount();
      }
    });
  });
});
