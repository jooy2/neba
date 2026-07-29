import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Shortcut } from 'neba';

/** The visible text, with the screen-reader-only names left out. */
function visibleText(root: Element): string {
  return Array.from(root.querySelectorAll('kbd'))
    .map((key) => {
      const shown = key.querySelector('[aria-hidden="true"]');
      return (shown ?? key).textContent ?? '';
    })
    .join(' ');
}

describe('Shortcut', () => {
  describe('rendering', () => {
    it('renders one kbd per key', async () => {
      const screen = await render(<Shortcut os="windows" keys="Ctrl+Shift+P" />);

      expect(screen.container.querySelectorAll('kbd')).toHaveLength(3);
    });

    it('splits the string form on plus signs', async () => {
      const screen = await render(<Shortcut os="windows" keys="Ctrl+K" />);

      expect(visibleText(screen.container)).toBe('Ctrl K');
    });

    it('takes the array form for a key that is itself a plus', async () => {
      const screen = await render(<Shortcut os="windows" keys={['Ctrl', '+']} />);

      expect(screen.container.querySelectorAll('kbd')).toHaveLength(2);
      expect(visibleText(screen.container)).toBe('Ctrl +');
    });

    it('capitalises a single letter and leaves longer tokens alone', async () => {
      const screen = await render(<Shortcut os="windows" keys={['k', 'F5', 'Slash']} />);

      expect(visibleText(screen.container)).toBe('K F5 Slash');
    });

    it('reflects changed keys on re-render', async () => {
      const screen = await render(<Shortcut os="windows" keys="Ctrl+K" />);

      await screen.rerender(<Shortcut os="windows" keys="Ctrl+Shift+P" />);

      expect(screen.container.querySelectorAll('kbd')).toHaveLength(3);
      expect(visibleText(screen.container)).toBe('Ctrl Shift P');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Shortcut keys="A" className="my-own-class" />);

      expect(screen.container.firstElementChild).toHaveClass('my-own-class');
    });
  });

  describe('platforms', () => {
    // The whole reason `Mod` exists: `Ctrl+K` is wrong for every Mac reader and
    // `⌘K` is wrong for everybody else.
    it('resolves Mod to Command on a Mac and Ctrl everywhere else', async () => {
      const screen = await render(<Shortcut os="mac" keys="Mod+K" />);

      expect(visibleText(screen.container)).toBe('⌘ K');

      await screen.rerender(<Shortcut os="windows" keys="Mod+K" />);
      expect(visibleText(screen.container)).toBe('Ctrl K');

      await screen.rerender(<Shortcut os="linux" keys="Mod+K" />);
      expect(visibleText(screen.container)).toBe('Ctrl K');
    });

    it('separates Meta from Mod, which are the same key only on a Mac', async () => {
      const screen = await render(<Shortcut os="windows" keys="Meta+K" />);

      expect(visibleText(screen.container)).toBe('Win K');

      await screen.rerender(<Shortcut os="linux" keys="Meta+K" />);
      expect(visibleText(screen.container)).toBe('Super K');
    });

    it('accepts the several names one key already has', async () => {
      const screen = await render(<Shortcut os="mac" keys="Cmd+Option+Esc" />);

      expect(visibleText(screen.container)).toBe('⌘ ⌥ ⎋');
    });

    it('draws the Mac modifiers as glyphs and the others as words', async () => {
      const screen = await render(<Shortcut os="mac" keys="Ctrl+Alt+Shift+Delete" />);

      expect(visibleText(screen.container)).toBe('⌃ ⌥ ⇧ ⌦');

      await screen.rerender(<Shortcut os="windows" keys="Ctrl+Alt+Shift+Delete" />);
      expect(visibleText(screen.container)).toBe('Ctrl Alt Shift Del');
    });

    it('draws the arrows as arrows on every platform', async () => {
      const screen = await render(<Shortcut os="windows" keys={['ArrowUp', 'Left']} />);

      expect(visibleText(screen.container)).toBe('↑ ←');
    });

    it('renders without an explicit os', async () => {
      const screen = await render(<Shortcut keys="Mod+K" />);

      expect(screen.container.querySelectorAll('kbd')).toHaveLength(2);
    });
  });

  describe('the separator', () => {
    // macOS writes a shortcut as a run of symbols; the other two join theirs.
    it('is a plus off a Mac and nothing on one', async () => {
      const screen = await render(<Shortcut os="windows" keys="Ctrl+K" />);

      expect(screen.container.textContent).toContain('+');

      await screen.rerender(<Shortcut os="mac" keys="Mod+K" />);
      expect(screen.container.textContent).not.toContain('+');
    });

    it('takes a separator of the caller’s own on either platform', async () => {
      const screen = await render(<Shortcut os="mac" keys="Mod+K" separator="then" />);

      expect(screen.container.textContent).toContain('then');
    });

    it('draws no separator before the first key', async () => {
      const screen = await render(<Shortcut os="windows" keys="Ctrl+Shift+P" />);

      expect(screen.container.textContent?.indexOf('+')).toBeGreaterThan(0);
      expect(screen.container.textContent?.split('+')).toHaveLength(3);
    });
  });

  describe('accessibility', () => {
    // `⌘` is announced as "place of interest sign", which is not a key anybody
    // has on their keyboard.
    it('gives every glyph key its name for a screen reader', async () => {
      const screen = await render(<Shortcut os="mac" keys="Mod+K" />);
      const command = screen.container.querySelectorAll('kbd')[0];

      expect(command.querySelector('[aria-hidden="true"]')?.textContent).toBe('⌘');
      expect(command.textContent).toContain('Command');
    });

    it('adds nothing for a key whose glyph is already its name', async () => {
      const screen = await render(<Shortcut os="windows" keys="Ctrl" />);
      const key = screen.container.querySelector('kbd');

      expect(key?.textContent).toBe('Ctrl');
      expect(key?.querySelector('span')).toBeNull();
    });

    it('hides the separator from the accessibility tree', async () => {
      const screen = await render(<Shortcut os="windows" keys="Ctrl+K" />);
      const separator = screen.container.querySelector('span > span[aria-hidden="true"]');

      expect(separator?.textContent).toBe('+');
    });
  });

  describe('style props', () => {
    it('maps color onto the token slots the styles read from', async () => {
      const screen = await render(<Shortcut keys="A" color="danger" />);
      const element = screen.container.firstElementChild as HTMLElement;

      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-danger-accent)');
    });

    it('defaults to the secondary family, because a key cap is chrome', async () => {
      const screen = await render(<Shortcut keys="A" />);
      const element = screen.container.firstElementChild as HTMLElement;

      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-secondary-accent)');
    });

    // A key cap sits one step down the control ladder, exactly as a Chip does.
    it('draws a md key at the sm control height', async () => {
      const screen = await render(<Shortcut keys="A" size="md" />);

      expect(screen.container.querySelector('kbd')).toHaveClass('h-6.5');
    });

    it('changes padding with density but not height', async () => {
      const screen = await render(<Shortcut keys="A" size="md" density="default" />);
      const key = screen.container.querySelector('kbd');

      expect(key).toHaveClass('px-3');
      expect(key).toHaveClass('h-6.5');

      await screen.rerender(<Shortcut keys="A" size="md" density="compact" />);

      expect(key).toHaveClass('px-2');
      expect(key).toHaveClass('h-6.5');
    });

    it('draws a border for the outline variant only', async () => {
      const screen = await render(<Shortcut keys="A" />);
      const key = screen.container.querySelector('kbd');

      expect(key).toHaveClass('border');

      await screen.rerender(<Shortcut keys="A" variant="text" />);
      expect(key).not.toHaveClass('border');
    });
  });
});
