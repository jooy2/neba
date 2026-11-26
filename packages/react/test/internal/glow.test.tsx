import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button, Menu, MenuItem, Pill, Segment, SegmentedButton, Tab, Tabs, TextField } from 'neba';

/** A pointer event carrying a place, since the components read one off it. */
function movePointer(element: Element, clientX: number, clientY: number) {
  element.dispatchEvent(new PointerEvent('pointermove', { clientX, clientY, bubbles: true }));
}

describe('the pointer light', () => {
  describe('the two slots', () => {
    it('writes the pointer onto the surface it is over', async () => {
      const screen = await render(<Button>Press</Button>);
      const button = screen.getByRole('button').element() as HTMLElement;
      const box = button.getBoundingClientRect();

      movePointer(button, box.left + 12, box.top + 5);

      expect(button.style.getPropertyValue('--n-mx')).toBe('12px');
      expect(button.style.getPropertyValue('--n-my')).toBe('5px');
    });

    /*
     * `offsetX` is measured from the *target*, so a label in an element of its
     * own reported a place inside that element rather than inside the button.
     */
    it('measures from the surface even when the pointer is over a child', async () => {
      const screen = await render(
        <Button>
          <span data-label>Press</span>
        </Button>
      );
      const button = screen.getByRole('button').element() as HTMLElement;
      const label = button.querySelector('[data-label]') as HTMLElement;
      const box = button.getBoundingClientRect();

      movePointer(label, box.left + 20, box.top + 7);

      expect(button.style.getPropertyValue('--n-mx')).toBe('20px');
      expect(button.style.getPropertyValue('--n-my')).toBe('7px');
    });

    it('leaves an unlit surface alone', async () => {
      const screen = await render(<Button disabled>Press</Button>);
      const button = screen.getByRole('button').element() as HTMLElement;

      movePointer(button, 10, 10);

      expect(button.style.getPropertyValue('--n-mx')).toBe('');
    });

    it('still calls the handler it was given', async () => {
      const onPointerMove = vi.fn();
      const screen = await render(<Button onPointerMove={onPointerMove}>Press</Button>);

      movePointer(screen.getByRole('button').element(), 10, 10);

      expect(onPointerMove).toHaveBeenCalled();
    });
  });

  describe('which surfaces carry it', () => {
    it('lights a field shell', async () => {
      const screen = await render(<TextField label="Email" />);
      const shell = screen.getByRole('textbox').element().parentElement as HTMLElement;

      expect(shell).toHaveClass('neba-glow');
    });

    it('does not light a read-only one', async () => {
      const screen = await render(<TextField label="Email" readOnly />);
      const shell = screen.getByRole('textbox').element().parentElement as HTMLElement;

      expect(shell).not.toHaveClass('neba-glow');
    });

    it('lights a segment', async () => {
      const screen = await render(
        <SegmentedButton aria-label="Range" defaultValue="day">
          <Segment value="day">Day</Segment>
        </SegmentedButton>
      );

      expect(screen.getByRole('radio', { name: 'Day' }).element()).toHaveClass('neba-glow');
    });

    it('lights a tab, and follows the pointer across it', async () => {
      const screen = await render(
        <Tabs defaultValue="overview">
          <Tab value="overview">Overview</Tab>
        </Tabs>
      );
      const tab = screen.getByRole('tab', { name: 'Overview' }).element() as HTMLElement;
      const box = tab.getBoundingClientRect();

      expect(tab).toHaveClass('neba-glow');

      movePointer(tab, box.left + 9, box.top + 4);

      expect(tab.style.getPropertyValue('--n-mx')).toBe('9px');
      expect(tab.style.getPropertyValue('--n-my')).toBe('4px');
    });

    it('leaves a disabled tab dark', async () => {
      const screen = await render(
        <Tabs defaultValue="overview">
          <Tab value="overview">Overview</Tab>
          <Tab value="usage" disabled>
            Usage
          </Tab>
        </Tabs>
      );
      const tab = screen.getByRole('tab', { name: 'Usage' }).element() as HTMLElement;

      expect(tab).not.toHaveClass('neba-glow');

      movePointer(tab, 10, 10);

      expect(tab.style.getPropertyValue('--n-mx')).toBe('');
    });

    // A Pill that does nothing when pressed is a label, and a label is not lit.
    // One that can be pressed is lit on its button, which is what a press
    // presses, and not on the shell around its end icon and its details.
    it('lights a Pill that can be pressed, and only its button', async () => {
      const screen = await render(
        <>
          <Pill data-testid="static">Recording</Pill>
          <Pill data-testid="pressable" onClick={() => {}}>
            Live
          </Pill>
        </>
      );
      const still = screen.getByTestId('static').element() as HTMLElement;
      const shell = screen.getByTestId('pressable').element() as HTMLElement;
      const button = screen.getByRole('button', { name: 'Live' }).element() as HTMLElement;
      const box = button.getBoundingClientRect();

      movePointer(still, 10, 10);
      movePointer(button, box.left + 6, box.top + 3);

      expect(still).not.toHaveClass('neba-glow');
      expect(still.style.getPropertyValue('--n-mx')).toBe('');
      expect(shell).not.toHaveClass('neba-glow');
      expect(button).toHaveClass('neba-glow');
      expect(button.style.getPropertyValue('--n-mx')).toBe('6px');
      expect(button.style.getPropertyValue('--n-my')).toBe('3px');
    });

    it('leaves a disabled menu row dark', async () => {
      const screen = await render(
        <Menu trigger={<Button>Actions</Button>}>
          <MenuItem disabled>Rename</MenuItem>
        </Menu>
      );

      await screen.getByRole('button', { name: 'Actions' }).click();

      await expect
        .element(screen.getByRole('menuitem', { name: 'Rename' }))
        .not.toHaveClass('neba-glow');
    });

    it('lights a menu row', async () => {
      const screen = await render(
        <Menu trigger={<Button>Actions</Button>}>
          <MenuItem>Rename</MenuItem>
        </Menu>
      );

      await screen.getByRole('button', { name: 'Actions' }).click();

      await expect
        .element(screen.getByRole('menuitem', { name: 'Rename' }))
        .toHaveClass('neba-glow');
    });
  });

  /*
   * A press is answered by a flash that drains for the best part of a second.
   * A field is entered rather than pressed, so it takes the spotlight and
   * leaves `--n-flash` unset — which is what makes the afterglow transparent.
   */
  describe('pressed against entered', () => {
    it('gives a pressed control both layers', async () => {
      const screen = await render(<Button>Press</Button>);
      const button = screen.getByRole('button').element() as HTMLElement;

      expect(button.style.getPropertyValue('--n-glow')).not.toBe('');
      expect(button.style.getPropertyValue('--n-flash')).not.toBe('');
    });

    it('gives a field half the spotlight and no flash', async () => {
      const screen = await render(<TextField label="Email" />);
      const shell = screen.getByRole('textbox').element().parentElement as HTMLElement;
      const root = shell.parentElement as HTMLElement;

      // The inline style rather than the computed one: no stylesheet is loaded
      // here, so `var(--n-soft)` has nothing to resolve against. Half of it,
      // because what the reader looks at next is their own text over the patch
      // the bloom is brightest on.
      expect(root.style.getPropertyValue('--n-glow')).toBe(
        'color-mix(in srgb, var(--n-soft) 50%, transparent)'
      );
      expect(root.style.getPropertyValue('--n-flash')).toBe('');
    });

    it('gives a menu row the whole spotlight, which is not a field', async () => {
      const screen = await render(
        <Menu trigger={<Button>Actions</Button>}>
          <MenuItem>Rename</MenuItem>
        </Menu>
      );

      await screen.getByRole('button', { name: 'Actions' }).click();

      const row = screen.getByRole('menuitem', { name: 'Rename' });

      await expect.element(row).toBeInTheDocument();
      expect((row.element() as HTMLElement).style.getPropertyValue('--n-glow')).toBe(
        'var(--n-soft)'
      );
    });
  });

  /*
   * The bloom is drawn where the pointer is, and a pointer resting on a field
   * is over the text the reader is about to change — so the one moment it is
   * least wanted is the one moment it cannot move out of the way on its own.
   */
  describe('typing', () => {
    it('marks the field shell on a key and unmarks it on the next move', async () => {
      const screen = await render(<TextField label="Email" />);
      const input = screen.getByRole('textbox').element() as HTMLElement;
      const shell = input.parentElement as HTMLElement;

      input.dispatchEvent(new KeyboardEvent('keydown', { key: 'a', bubbles: true }));

      expect(shell.hasAttribute('data-typing')).toBe(true);

      movePointer(shell, 10, 10);

      expect(shell.hasAttribute('data-typing')).toBe(false);
    });

    it('marks it for a key that writes nothing, which is still reading it', async () => {
      const screen = await render(<TextField label="Email" />);
      const input = screen.getByRole('textbox').element() as HTMLElement;

      input.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowLeft', bubbles: true }));

      expect((input.parentElement as HTMLElement).hasAttribute('data-typing')).toBe(true);
    });

    it('marks nothing on a shell with no light on it', async () => {
      const screen = await render(<TextField label="Email" disabled />);
      const input = screen.getByRole('textbox').element() as HTMLElement;

      input.dispatchEvent(new KeyboardEvent('keydown', { key: 'a', bubbles: true }));

      expect((input.parentElement as HTMLElement).hasAttribute('data-typing')).toBe(false);
    });
  });
});
