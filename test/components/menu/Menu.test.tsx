import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
import {
  Button,
  ContextMenu,
  Menu,
  MenuCheckboxItem,
  MenuGroup,
  MenuItem,
  MenuRadioGroup,
  MenuRadioItem,
  MenuSeparator,
  MenuSubmenu
} from 'neba';

describe('Menu', () => {
  describe('rendering', () => {
    it('renders nothing until it is open', async () => {
      const screen = await render(
        <Menu trigger={<Button>Actions</Button>}>
          <MenuItem>Rename</MenuItem>
        </Menu>
      );

      expect(screen.getByRole('menu').query()).toBeNull();
      await expect.element(screen.getByRole('button', { name: 'Actions' })).toBeInTheDocument();
    });

    it('renders a menu of its rows when open', async () => {
      const screen = await render(
        <Menu defaultOpen trigger={<Button>Actions</Button>}>
          <MenuItem>Rename</MenuItem>
          <MenuItem>Duplicate</MenuItem>
        </Menu>
      );

      await expect.element(screen.getByRole('menu')).toBeInTheDocument();
      expect(screen.getByRole('menuitem').elements()).toHaveLength(2);
    });

    it('opens when the trigger is pressed', async () => {
      const screen = await render(
        <Menu trigger={<Button>Actions</Button>}>
          <MenuItem>Rename</MenuItem>
        </Menu>
      );

      await screen.getByRole('button', { name: 'Actions' }).click();

      await expect.element(screen.getByRole('menuitem', { name: 'Rename' })).toBeInTheDocument();
    });

    it('renders without a trigger, for a menu something else opens', async () => {
      const screen = await render(
        <Menu open>
          <MenuItem>Rename</MenuItem>
        </Menu>
      );

      await expect.element(screen.getByRole('menuitem', { name: 'Rename' })).toBeInTheDocument();
      // Asked by tag, not by role: an open Base UI popup lays focus guards
      // around itself, and under WebKit with VoiceOver those guards take
      // `role="button"` so the virtual cursor trips the focus trap. The
      // trigger is the only real `<button>` either way.
      expect(screen.container.querySelector('button')).toBeNull();
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(
        <Menu defaultOpen>
          <MenuItem>Before</MenuItem>
        </Menu>
      );

      await screen.rerender(
        <Menu defaultOpen>
          <MenuItem>After</MenuItem>
        </Menu>
      );

      await expect.element(screen.getByRole('menuitem', { name: 'After' })).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });
  });

  describe('rows', () => {
    it('calls the handler when a row is picked', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <Menu defaultOpen>
          <MenuItem onClick={onClick}>Rename</MenuItem>
        </Menu>
      );

      await screen.getByRole('menuitem', { name: 'Rename' }).click();

      expect(onClick).toHaveBeenCalledTimes(1);
    });

    // A menu of links that are not links cannot be opened in a new tab, cannot
    // be copied, and tells a screen reader the wrong thing about every one.
    it('becomes a real link when it is given an href', async () => {
      const screen = await render(
        <Menu defaultOpen>
          <MenuItem href="#settings">Settings</MenuItem>
        </Menu>
      );

      const item = screen.getByRole('menuitem', { name: 'Settings' }).element();
      expect(item.tagName).toBe('A');
      expect(item).toHaveAttribute('href', '#settings');
    });

    it('marks a disabled row as disabled', async () => {
      const screen = await render(
        <Menu defaultOpen>
          <MenuItem disabled>Rename</MenuItem>
        </Menu>
      );

      await expect
        .element(screen.getByRole('menuitem', { name: 'Rename' }))
        .toHaveAttribute('data-disabled');
    });

    it('does not fire a disabled row', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <Menu defaultOpen>
          <MenuItem disabled onClick={onClick}>
            Rename
          </MenuItem>
        </Menu>
      );

      await screen.getByRole('menuitem', { name: 'Rename' }).click({ force: true });

      expect(onClick).not.toHaveBeenCalled();
    });

    it('renders a shortcut and a description', async () => {
      const screen = await render(
        <Menu defaultOpen>
          <MenuItem shortcut="⌘R" description="Give it another name">
            Rename
          </MenuItem>
        </Menu>
      );

      await expect.element(screen.getByText('⌘R')).toBeInTheDocument();
      await expect.element(screen.getByText('Give it another name')).toBeInTheDocument();
    });

    it('re-points a row at its own colour family', async () => {
      const screen = await render(
        <Menu defaultOpen>
          <MenuItem color="danger">Delete</MenuItem>
        </Menu>
      );
      const item = screen.getByRole('menuitem', { name: 'Delete' }).element() as HTMLElement;

      expect(item.style.getPropertyValue('--n-accent')).toBe('var(--neba-danger-accent)');
    });

    // The slot alone is not enough: an accented row also has to *carry* the
    // accent, and stacking `text-(--n-accent)` next to the default
    // `text-(--neba-fg)` puts two utilities of equal specificity on one element
    // — which of them wins is then decided by the generated stylesheet's order,
    // not by the class attribute's. It lost, and `color` silently did nothing.
    it('carries the accent rather than the default foreground', async () => {
      const screen = await render(
        <Menu defaultOpen>
          <MenuItem color="danger">Delete</MenuItem>
          <MenuItem>Rename</MenuItem>
        </Menu>
      );

      const accented = screen.getByRole('menuitem', { name: 'Delete' }).element();
      const plain = screen.getByRole('menuitem', { name: 'Rename' }).element();

      expect(accented).toHaveClass('text-(--n-accent)');
      expect(accented).not.toHaveClass('text-(--neba-fg)');
      expect(plain).toHaveClass('text-(--neba-fg)');
      expect(plain).not.toHaveClass('text-(--n-accent)');
    });

    it('renders a group with its heading and a separator', async () => {
      const screen = await render(
        <Menu defaultOpen>
          <MenuGroup label="Danger">
            <MenuItem>Delete</MenuItem>
          </MenuGroup>
          <MenuSeparator />
          <MenuItem>Rename</MenuItem>
        </Menu>
      );

      await expect.element(screen.getByRole('group', { name: 'Danger' })).toBeInTheDocument();
      await expect.element(screen.getByRole('separator')).toBeInTheDocument();
    });
  });

  describe('rows that hold state', () => {
    it('ticks and unticks a checkbox row', async () => {
      const onCheckedChange = vi.fn();
      const screen = await render(
        <Menu defaultOpen>
          <MenuCheckboxItem onCheckedChange={onCheckedChange}>Show grid</MenuCheckboxItem>
        </Menu>
      );

      const item = screen.getByRole('menuitemcheckbox', { name: 'Show grid' });
      await expect.element(item).toHaveAttribute('aria-checked', 'false');

      await item.click();

      expect(onCheckedChange).toHaveBeenCalledWith(true);
      await expect.element(item).toHaveAttribute('aria-checked', 'true');
    });

    // A list of things to tick is a list you tick more than one of.
    it('keeps the menu open when a checkbox row is ticked', async () => {
      const screen = await render(
        <Menu defaultOpen>
          <MenuCheckboxItem>Show grid</MenuCheckboxItem>
        </Menu>
      );

      await screen.getByRole('menuitemcheckbox', { name: 'Show grid' }).click();

      await expect.element(screen.getByRole('menu')).toBeInTheDocument();
    });

    it('chooses one radio row out of a set', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Menu defaultOpen>
          <MenuRadioGroup defaultValue="list" onValueChange={onValueChange}>
            <MenuRadioItem value="list">List</MenuRadioItem>
            <MenuRadioItem value="grid">Grid</MenuRadioItem>
          </MenuRadioGroup>
        </Menu>
      );

      await expect
        .element(screen.getByRole('menuitemradio', { name: 'List' }))
        .toHaveAttribute('aria-checked', 'true');

      await screen.getByRole('menuitemradio', { name: 'Grid' }).click();

      expect(onValueChange).toHaveBeenCalledWith('grid');
      await expect
        .element(screen.getByRole('menuitemradio', { name: 'Grid' }))
        .toHaveAttribute('aria-checked', 'true');
    });
  });

  // These all open from a real trigger rather than with `defaultOpen`. A menu
  // that was already open when the page loaded has no anchor to be positioned
  // against, so Base UI leaves it at the origin with nothing to reach into — a
  // submenu hung off that is a submenu nobody can hover.
  describe('submenus', () => {
    it('renders the row that opens a submenu, with the submenu closed', async () => {
      const screen = await render(
        <Menu trigger={<Button>Actions</Button>}>
          <MenuSubmenu label="Share">
            <MenuItem>Copy link</MenuItem>
          </MenuSubmenu>
        </Menu>
      );

      await screen.getByRole('button', { name: 'Actions' }).click();

      await expect.element(screen.getByRole('menuitem', { name: 'Share' })).toBeInTheDocument();
      expect(screen.getByRole('menuitem', { name: 'Copy link' }).query()).toBeNull();
    });

    // Hover, not click: Base UI's submenu trigger opens on hover and ignores
    // the mouse press entirely, which is what makes reaching diagonally into an
    // open submenu work. Clicking one is a no-op by design.
    it('opens a submenu when its row is hovered', async () => {
      const screen = await render(
        <Menu trigger={<Button>Actions</Button>}>
          <MenuSubmenu label="Share">
            <MenuItem>Copy link</MenuItem>
          </MenuSubmenu>
        </Menu>
      );

      await screen.getByRole('button', { name: 'Actions' }).click();
      await screen.getByRole('menuitem', { name: 'Share' }).hover();

      await expect.element(screen.getByRole('menuitem', { name: 'Copy link' })).toBeInTheDocument();
    });

    it('marks the row while its submenu is open', async () => {
      const screen = await render(
        <Menu trigger={<Button>Actions</Button>}>
          <MenuSubmenu label="Share">
            <MenuItem>Copy link</MenuItem>
          </MenuSubmenu>
        </Menu>
      );

      await screen.getByRole('button', { name: 'Actions' }).click();
      await screen.getByRole('menuitem', { name: 'Share' }).hover();

      await expect
        .element(screen.getByRole('menuitem', { name: 'Share' }))
        .toHaveAttribute('data-popup-open');
    });

    // Nesting is unlimited because a submenu's children are just menu rows, and
    // one of them can be another submenu. Nothing new is needed at depth two.
    it('nests a submenu inside a submenu', async () => {
      const screen = await render(
        <Menu trigger={<Button>Actions</Button>}>
          <MenuSubmenu label="Share">
            <MenuSubmenu label="Export">
              <MenuItem>As PDF</MenuItem>
            </MenuSubmenu>
          </MenuSubmenu>
        </Menu>
      );

      await screen.getByRole('button', { name: 'Actions' }).click();
      await screen.getByRole('menuitem', { name: 'Share' }).hover();
      await screen.getByRole('menuitem', { name: 'Export' }).hover();

      await expect.element(screen.getByRole('menuitem', { name: 'As PDF' })).toBeInTheDocument();
    });
  });

  describe('the keyboard', () => {
    /**
     * A key only reaches the menu once the popup holds focus, and Base UI moves
     * focus there in an effect after the popup mounts. Pressing before that
     * lands on whatever the trigger left behind and the menu never sees it —
     * which is what made these tests flake in WebKit. Every keyboard test waits
     * for the focus to arrive rather than for the markup.
     */
    async function menuHasFocus(screen: Awaited<ReturnType<typeof render>>) {
      await expect
        .poll(() => screen.getByRole('menu').query()?.contains(document.activeElement) ?? false)
        .toBe(true);
    }

    it('walks the rows with the arrow keys', async () => {
      const screen = await render(
        <Menu trigger={<Button>Actions</Button>}>
          <MenuItem>Rename</MenuItem>
          <MenuItem>Duplicate</MenuItem>
        </Menu>
      );

      await screen.getByRole('button', { name: 'Actions' }).click();
      await menuHasFocus(screen);
      await userEvent.keyboard('{ArrowDown}');

      await expect
        .element(screen.getByRole('menuitem', { name: 'Rename' }))
        .toHaveAttribute('data-highlighted');

      await userEvent.keyboard('{ArrowDown}');

      await expect
        .element(screen.getByRole('menuitem', { name: 'Duplicate' }))
        .toHaveAttribute('data-highlighted');
    });

    it('picks the highlighted row with Enter', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <Menu trigger={<Button>Actions</Button>}>
          <MenuItem onClick={onClick}>Rename</MenuItem>
          <MenuItem>Duplicate</MenuItem>
        </Menu>
      );

      // Opened from the trigger rather than with `defaultOpen`, because that is
      // what puts focus inside the popup — a menu that was open before anybody
      // pressed anything has nothing to have moved focus away from.
      await screen.getByRole('button', { name: 'Actions' }).click();
      await menuHasFocus(screen);
      await userEvent.keyboard('{ArrowDown}');
      await userEvent.keyboard('{Enter}');

      expect(onClick).toHaveBeenCalledTimes(1);
    });

    it('closes on Escape', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <Menu defaultOpen onOpenChange={onOpenChange}>
          <MenuItem>Rename</MenuItem>
        </Menu>
      );

      await menuHasFocus(screen);
      await userEvent.keyboard('{Escape}');

      expect(onOpenChange).toHaveBeenCalledWith(false);
    });
  });

  describe('what the row inherits', () => {
    it('takes its size from the menu rather than from itself', async () => {
      const screen = await render(
        <Menu defaultOpen size="xl">
          <MenuItem>Rename</MenuItem>
        </Menu>
      );

      expect(screen.getByRole('menuitem', { name: 'Rename' }).element()).toHaveClass('px-3.5');
    });

    it('takes its density from the menu', async () => {
      const screen = await render(
        <Menu defaultOpen density="compact">
          <MenuItem>Rename</MenuItem>
        </Menu>
      );

      expect(screen.getByRole('menuitem', { name: 'Rename' }).element()).toHaveClass('px-2');
    });

    it('keeps the popup undyed while colouring the edge', async () => {
      const screen = await render(
        <Menu defaultOpen color="success">
          <MenuItem>Rename</MenuItem>
        </Menu>
      );
      const popup = screen.getByRole('menu').element() as HTMLElement;

      expect(popup.style.getPropertyValue('--n-panel')).toBe('var(--neba-panel)');
      expect(popup.style.getPropertyValue('--n-line')).toBe('var(--neba-success-line)');
    });

    it('never applies a transform', async () => {
      const screen = await render(
        <Menu defaultOpen>
          <MenuItem shortcut="⌘R">Rename</MenuItem>
        </Menu>
      );

      expect(screen.getByRole('menu').element().outerHTML).not.toContain('translate');
    });
  });
});

describe('ContextMenu', () => {
  it('renders the area it wraps, with the menu closed', async () => {
    const screen = await render(
      <ContextMenu content={<MenuItem>Rename</MenuItem>}>
        <div>Right-click me</div>
      </ContextMenu>
    );

    await expect.element(screen.getByText('Right-click me')).toBeInTheDocument();
    expect(screen.getByRole('menu').query()).toBeNull();
  });

  it('opens on a right-click', async () => {
    const screen = await render(
      <ContextMenu content={<MenuItem>Rename</MenuItem>}>
        <div>Right-click me</div>
      </ContextMenu>
    );

    await screen.getByText('Right-click me').click({ button: 'right' });

    await expect.element(screen.getByRole('menuitem', { name: 'Rename' })).toBeInTheDocument();
  });

  it('hands its size down to the rows, exactly as Menu does', async () => {
    const screen = await render(
      <ContextMenu defaultOpen size="xl" content={<MenuItem>Rename</MenuItem>}>
        <div>Right-click me</div>
      </ContextMenu>
    );

    expect(screen.getByRole('menuitem', { name: 'Rename' }).element()).toHaveClass('px-3.5');
  });
});
