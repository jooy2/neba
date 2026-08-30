import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Menubar, MenubarMenu, MenuItem, MenuSeparator } from 'neba';

function Bar({ onNew = () => {} }: { onNew?: () => void }) {
  return (
    <Menubar aria-label="Application">
      <MenubarMenu label="File">
        <MenuItem onClick={onNew}>New file</MenuItem>
        <MenuSeparator />
        <MenuItem>Open…</MenuItem>
      </MenubarMenu>
      <MenubarMenu label="Edit">
        <MenuItem>Undo</MenuItem>
      </MenubarMenu>
      <MenubarMenu label="Help" disabled>
        <MenuItem>About</MenuItem>
      </MenubarMenu>
    </Menubar>
  );
}

describe('Menubar', () => {
  describe('rendering', () => {
    it('renders a menubar of words', async () => {
      const screen = await render(<Bar />);

      await expect
        .element(screen.getByRole('menubar', { name: 'Application' }))
        .toBeInTheDocument();
      await expect.element(screen.getByRole('menuitem', { name: 'File' })).toBeInTheDocument();
      await expect.element(screen.getByRole('menuitem', { name: 'Edit' })).toBeInTheDocument();
    });

    it('opens nothing until a word is pressed', async () => {
      const screen = await render(<Bar />);

      expect(screen.getByRole('menuitem', { name: 'New file' }).query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <Menubar aria-label="Application" className="my-own-class">
          <MenubarMenu label="File">
            <MenuItem>New file</MenuItem>
          </MenubarMenu>
        </Menubar>
      );

      expect(screen.getByRole('menubar').element()).toHaveClass('my-own-class');
    });

    it('turns the strip on its side when vertical', async () => {
      const screen = await render(
        <Menubar aria-label="Application" orientation="vertical">
          <MenubarMenu label="File">
            <MenuItem>New file</MenuItem>
          </MenubarMenu>
        </Menubar>
      );

      expect(screen.getByRole('menubar').element()).toHaveClass('flex-col');
    });
  });

  describe('behaviour', () => {
    it('opens the rows behind a word', async () => {
      const screen = await render(<Bar />);

      await screen.getByRole('menuitem', { name: 'File' }).click();

      await expect.element(screen.getByRole('menuitem', { name: 'New file' })).toBeInTheDocument();
    });

    it('runs a row and closes', async () => {
      const onNew = vi.fn();
      const screen = await render(<Bar onNew={onNew} />);

      await screen.getByRole('menuitem', { name: 'File' }).click();
      await screen.getByRole('menuitem', { name: 'New file' }).click();

      expect(onNew).toHaveBeenCalledTimes(1);
    });

    it('leaves a disabled word unopenable', async () => {
      const screen = await render(<Bar />);
      const help = screen.getByRole('menuitem', { name: 'Help' });

      await expect.element(help).toBeDisabled();

      await help.click({ force: true });

      expect(screen.getByRole('menuitem', { name: 'About' }).query()).toBeNull();
    });
  });

  describe('shared props', () => {
    it('sets the size once for every word on the bar', async () => {
      const screen = await render(
        <Menubar aria-label="Application" size="xl">
          <MenubarMenu label="File">
            <MenuItem>New file</MenuItem>
          </MenubarMenu>
          <MenubarMenu label="Edit">
            <MenuItem>Undo</MenuItem>
          </MenubarMenu>
        </Menubar>
      );

      expect(screen.getByRole('menuitem', { name: 'File' }).element()).toHaveClass('h-10');
      expect(screen.getByRole('menuitem', { name: 'Edit' }).element()).toHaveClass('h-10');
    });

    it('maps color onto the bar slots', async () => {
      const screen = await render(
        <Menubar aria-label="Application" color="secondary">
          <MenubarMenu label="File">
            <MenuItem>New file</MenuItem>
          </MenubarMenu>
        </Menubar>
      );
      const element = screen.getByRole('menubar').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-secondary-accent)');
    });

    it('disables every menu on the bar at once', async () => {
      const screen = await render(
        <Menubar aria-label="Application" disabled>
          <MenubarMenu label="File">
            <MenuItem>New file</MenuItem>
          </MenubarMenu>
        </Menubar>
      );

      await expect.element(screen.getByRole('menuitem', { name: 'File' })).toBeDisabled();
    });
  });
});
