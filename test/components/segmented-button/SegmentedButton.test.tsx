import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Segment, SegmentedButton } from 'neba';

function Basic(props: React.ComponentProps<typeof SegmentedButton>) {
  return (
    <SegmentedButton aria-label="Range" {...props}>
      <Segment value="day">Day</Segment>
      <Segment value="week">Week</Segment>
      <Segment value="month">Month</Segment>
    </SegmentedButton>
  );
}

/**
 * The tile. Every radio brings a visually hidden `<input>` of its own, so this
 * has to be the `<span>` the trough itself owns rather than the first hidden
 * thing in the box.
 */
function tile(root: Element): HTMLElement | null {
  return root.querySelector(':scope > span[aria-hidden="true"]');
}

describe('SegmentedButton', () => {
  describe('rendering', () => {
    // A segmented button *is* "exactly one of these", so it is a radio group —
    // a row of aria-pressed toggles would announce three independent switches.
    it('renders a radiogroup of radios', async () => {
      const screen = await render(<Basic defaultValue="day" />);

      await expect.element(screen.getByRole('radiogroup')).toBeInTheDocument();
      expect(screen.getByRole('radio').elements()).toHaveLength(3);
    });

    it('takes its accessible name from the caller', async () => {
      const screen = await render(<Basic defaultValue="day" />);

      await expect.element(screen.getByRole('radiogroup', { name: 'Range' })).toBeInTheDocument();
    });

    it('marks the chosen segment as checked', async () => {
      const screen = await render(<Basic defaultValue="week" />);

      await expect
        .element(screen.getByRole('radio', { name: 'Week' }))
        .toHaveAttribute('aria-checked', 'true');
      await expect
        .element(screen.getByRole('radio', { name: 'Day' }))
        .toHaveAttribute('aria-checked', 'false');
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(
        <SegmentedButton defaultValue="a" aria-label="Set">
          <Segment value="a">Before</Segment>
        </SegmentedButton>
      );

      await screen.rerender(
        <SegmentedButton defaultValue="a" aria-label="Set">
          <Segment value="a">After</Segment>
        </SegmentedButton>
      );

      await expect.element(screen.getByRole('radio', { name: 'After' })).toBeInTheDocument();
      expect(screen.getByRole('radio', { name: 'Before' }).query()).toBeNull();
    });

    it('places startIcon before and endIcon after the label', async () => {
      const screen = await render(
        <SegmentedButton defaultValue="a" aria-label="Set">
          <Segment value="a" startIcon={<span>[</span>} endIcon={<span>]</span>}>
            Day
          </Segment>
        </SegmentedButton>
      );

      expect(screen.getByRole('radio').element().textContent).toBe('[Day]');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Basic defaultValue="day" className="my-own-class" />);

      expect(screen.getByRole('radiogroup').element()).toHaveClass('my-own-class');
    });
  });

  describe('choosing', () => {
    it('changes the chosen segment when one is pressed, uncontrolled', async () => {
      const screen = await render(<Basic defaultValue="day" />);

      await screen.getByRole('radio', { name: 'Month' }).click();

      await expect
        .element(screen.getByRole('radio', { name: 'Month' }))
        .toHaveAttribute('aria-checked', 'true');
    });

    it('reports the chosen value', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<Basic defaultValue="day" onValueChange={onValueChange} />);

      await screen.getByRole('radio', { name: 'Week' }).click();

      expect(onValueChange).toHaveBeenCalledWith('week');
    });

    it('leaves a controlled set where the caller put it', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<Basic value="day" onValueChange={onValueChange} />);

      await screen.getByRole('radio', { name: 'Week' }).click();

      expect(onValueChange).toHaveBeenCalledWith('week');
      await expect
        .element(screen.getByRole('radio', { name: 'Day' }))
        .toHaveAttribute('aria-checked', 'true');
    });

    it('follows a controlled value it is given', async () => {
      const screen = await render(<Basic value="day" />);

      await screen.rerender(<Basic value="month" />);

      await expect
        .element(screen.getByRole('radio', { name: 'Month' }))
        .toHaveAttribute('aria-checked', 'true');
    });

    it('starts with nothing chosen when no value is given', async () => {
      const screen = await render(<Basic />);

      for (const radio of screen.getByRole('radio').elements()) {
        expect(radio).toHaveAttribute('aria-checked', 'false');
      }
    });

    it('does not answer a press when disabled', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Basic defaultValue="day" disabled onValueChange={onValueChange} />
      );

      await screen.getByRole('radio', { name: 'Week' }).click({ force: true });

      expect(onValueChange).not.toHaveBeenCalled();
    });

    it('shows the chosen one but does not change it when read-only', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Basic defaultValue="day" readOnly onValueChange={onValueChange} />
      );

      await screen.getByRole('radio', { name: 'Week' }).click({ force: true });

      expect(onValueChange).not.toHaveBeenCalled();
      await expect
        .element(screen.getByRole('radio', { name: 'Day' }))
        .toHaveAttribute('aria-checked', 'true');
    });

    it('leaves one disabled segment out without disabling the set', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <SegmentedButton defaultValue="day" aria-label="Set" onValueChange={onValueChange}>
          <Segment value="day">Day</Segment>
          <Segment value="week" disabled>
            Week
          </Segment>
        </SegmentedButton>
      );

      await screen.getByRole('radio', { name: 'Week' }).click({ force: true });
      expect(onValueChange).not.toHaveBeenCalled();
    });
  });

  describe('the tile', () => {
    it('is not drawn until something is chosen', async () => {
      const screen = await render(<Basic />);
      const group = screen.getByRole('radiogroup').element();

      expect(tile(group)).toBeNull();

      await screen.rerender(<Basic value="week" />);

      expect(tile(group)).not.toBeNull();
    });

    it('is measured onto the chosen segment', async () => {
      const screen = await render(<Basic value="week" />);
      const group = screen.getByRole('radiogroup').element();
      const week = screen.getByRole('radio', { name: 'Week' }).element() as HTMLElement;
      const box = tile(group) as HTMLElement;

      expect(box.style.getPropertyValue('--n-seg-x')).toBe(`${week.offsetLeft}px`);
      expect(box.style.getPropertyValue('--n-seg-w')).toBe(`${week.offsetWidth}px`);
      expect(box.style.getPropertyValue('--n-seg-h')).toBe(`${week.offsetHeight}px`);
    });

    it('follows the choice to another segment', async () => {
      const screen = await render(<Basic value="day" />);
      const group = screen.getByRole('radiogroup').element();
      const box = tile(group) as HTMLElement;
      const before = box.style.getPropertyValue('--n-seg-x');

      await screen.rerender(<Basic value="month" />);

      const month = screen.getByRole('radio', { name: 'Month' }).element() as HTMLElement;
      expect(box.style.getPropertyValue('--n-seg-x')).toBe(`${month.offsetLeft}px`);
      expect(box.style.getPropertyValue('--n-seg-x')).not.toBe(before);
    });

    // The whole point of the component moves, and it moves without a transform:
    // the tile is an empty box, so no label is ever resampled.
    it('never applies a transform', async () => {
      const screen = await render(<Basic value="week" />);
      const box = tile(screen.getByRole('radiogroup').element()) as HTMLElement;

      expect(box.className).not.toContain('translate');
      expect(box.className).not.toContain('scale');
    });
  });

  describe('style props', () => {
    it('maps color onto the token slots the styles read from', async () => {
      const screen = await render(<Basic defaultValue="day" color="success" />);
      const element = screen.getByRole('radiogroup').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-success-fill)');
      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-success-accent)');
    });

    it('changes segment height with size but not with density', async () => {
      const screen = await render(<Basic defaultValue="day" size="lg" />);
      const day = screen.getByRole('radio', { name: 'Day' }).element();

      expect(day).toHaveClass('h-10');

      await screen.rerender(<Basic defaultValue="day" size="lg" density="compact" />);

      expect(day).toHaveClass('h-10');
      expect(day).toHaveClass('px-3');
    });

    it('draws a trough for solid and outline and none for text', async () => {
      const screen = await render(<Basic defaultValue="day" variant="outline" />);
      const group = screen.getByRole('radiogroup').element();

      expect(group).toHaveClass('border');

      await screen.rerender(<Basic defaultValue="day" variant="text" />);

      expect(group).not.toHaveClass('border');
      expect(group).not.toHaveClass('p-1');
    });

    it('stretches and divides the width when fullWidth is set', async () => {
      const screen = await render(<Basic defaultValue="day" fullWidth />);

      expect(screen.getByRole('radiogroup').element()).toHaveClass('w-full');
      expect(screen.getByRole('radio', { name: 'Day' }).element()).toHaveClass('flex-1');
    });
  });
});
