import { describe, expect, it } from 'vitest';
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
});
