import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button, Menu, MenuItem, Segment, SegmentedButton, TextField } from 'neba';

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

    it('gives a field the spotlight and no flash', async () => {
      const screen = await render(<TextField label="Email" />);
      const shell = screen.getByRole('textbox').element().parentElement as HTMLElement;
      const root = shell.parentElement as HTMLElement;

      // The inline style rather than the computed one: no stylesheet is loaded
      // here, so `var(--n-soft)` has nothing to resolve against.
      expect(root.style.getPropertyValue('--n-glow')).toBe('var(--n-soft)');
      expect(root.style.getPropertyValue('--n-flash')).toBe('');
    });
  });
});
