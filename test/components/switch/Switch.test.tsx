import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Switch } from 'neba';

describe('Switch', () => {
  describe('rendering', () => {
    it('renders a switch named by its label', async () => {
      const screen = await render(<Switch label="Email alerts" />);

      await expect
        .element(screen.getByRole('switch', { name: 'Email alerts' }))
        .toBeInTheDocument();
    });

    it('renders without a label', async () => {
      const screen = await render(<Switch aria-label="Dark mode" />);

      await expect.element(screen.getByRole('switch', { name: 'Dark mode' })).toBeInTheDocument();
    });

    it('renders the description', async () => {
      const screen = await render(<Switch label="Alerts" description="Sent immediately." />);

      await expect.element(screen.getByText('Sent immediately.')).toBeInTheDocument();
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(<Switch label="Before" />);

      await screen.rerender(<Switch label="After" />);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('puts the label after the track by default and before it on request', async () => {
      const screen = await render(<Switch label="Alerts" />);

      expect(
        screen
          .getByRole('switch')
          .element()
          .compareDocumentPosition(screen.getByText('Alerts').element()) &
          Node.DOCUMENT_POSITION_FOLLOWING
      ).toBeTruthy();

      await screen.rerender(<Switch label="Alerts" labelPlacement="start" />);

      expect(
        screen
          .getByRole('switch')
          .element()
          .compareDocumentPosition(screen.getByText('Alerts').element()) &
          Node.DOCUMENT_POSITION_PRECEDING
      ).toBeTruthy();
    });
  });

  // Nothing loads Tailwind into the test run, so the track renders at zero size.
  // The label is both the reachable target and the real user path.
  describe('behaviour', () => {
    it('turns on when its label is clicked', async () => {
      const screen = await render(<Switch label="Email alerts" />);
      const control = screen.getByRole('switch');

      await expect.element(control).not.toBeChecked();

      await screen.getByText('Email alerts').click();

      await expect.element(control).toBeChecked();
    });

    it('reports the new state', async () => {
      const onCheckedChange = vi.fn();
      const screen = await render(<Switch label="Alerts" onCheckedChange={onCheckedChange} />);

      await screen.getByText('Alerts').click();

      expect(onCheckedChange).toHaveBeenCalledTimes(1);
      expect(onCheckedChange.mock.calls[0][0]).toBe(true);
    });

    it('honours a controlled checked prop', async () => {
      const screen = await render(<Switch label="Alerts" checked onCheckedChange={() => {}} />);

      await expect.element(screen.getByRole('switch')).toBeChecked();

      await screen.rerender(<Switch label="Alerts" checked={false} onCheckedChange={() => {}} />);

      await expect.element(screen.getByRole('switch')).not.toBeChecked();
    });

    it('does not move when read-only', async () => {
      const onCheckedChange = vi.fn();
      const screen = await render(
        <Switch label="Alerts" readOnly onCheckedChange={onCheckedChange} />
      );

      await screen.getByText('Alerts').click();

      expect(onCheckedChange).not.toHaveBeenCalled();
    });

    it('is out of reach when disabled', async () => {
      const screen = await render(<Switch label="Alerts" disabled />);

      await expect.element(screen.getByRole('switch')).toBeDisabled();
    });
  });

  describe('style props', () => {
    it('maps colour onto the token slots', async () => {
      const screen = await render(<Switch label="Alerts" color="success" />);
      const root = screen.getByText('Alerts').element().closest('[style]') as HTMLElement;

      expect(root.style.getPropertyValue('--n-fill')).toBe('var(--neba-success-fill)');
      expect(root.style.getPropertyValue('--n-ring')).toBe('var(--neba-success-ring)');
    });

    it('re-points the colour family at danger when invalid', async () => {
      const screen = await render(<Switch label="Alerts" color="info" error="Pick one" />);
      const root = screen.getByText('Alerts').element().closest('[style]') as HTMLElement;

      expect(root.style.getPropertyValue('--n-fill')).toBe('var(--neba-danger-fill)');
      await expect.element(screen.getByText('Pick one')).toBeInTheDocument();
    });

    it('scales the track with size', async () => {
      const screen = await render(<Switch label="Alerts" size="xl" />);
      const track = screen.getByRole('switch').element();

      expect(track).toHaveClass('h-7');
      expect(track).toHaveClass('w-13');
    });

    /** The same flattening a Checkbox's tick and a Radio's dot take. */
    it('wears no plate on the track, on or off', async () => {
      const screen = await render(<Switch label="Alerts" defaultChecked />);
      const track = screen.getByRole('switch').element();

      expect(track.className).not.toContain('neba-plate');
      expect(track.className).toContain('backdrop-filter');
    });

    it('moves the thumb with left rather than a transform', async () => {
      const screen = await render(<Switch label="Alerts" checked onCheckedChange={() => {}} />);
      const thumb = screen.getByRole('switch').element().firstElementChild as HTMLElement;

      expect(thumb).toHaveClass('data-[checked]:left-[calc(100%-1.125rem)]');
      expect(thumb.outerHTML).not.toContain('translate');
      expect(thumb.outerHTML).not.toContain('scale');
    });
  });
});
