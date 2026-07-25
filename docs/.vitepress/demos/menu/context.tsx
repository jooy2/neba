import { ContextMenu, MenuItem, MenuSeparator, MenuSubmenu } from 'neba';

/**
 * The same rows, opened by a right-click or a long press instead of by a button.
 * It takes the rows as `content` and the area as `children` — Tooltip's shape
 * rather than Menu's, because the trigger here is a region rather than an
 * element you hand over.
 */
export default function MenuContext() {
  return (
    <ContextMenu
      content={
        <>
          <MenuItem shortcut="⌘X">Cut</MenuItem>
          <MenuItem shortcut="⌘C">Copy</MenuItem>
          <MenuItem shortcut="⌘V">Paste</MenuItem>
          <MenuSeparator />
          <MenuSubmenu label="Transform">
            <MenuItem>To uppercase</MenuItem>
            <MenuItem>To lowercase</MenuItem>
          </MenuSubmenu>
          <MenuSeparator />
          <MenuItem color="danger">Delete</MenuItem>
        </>
      }
    >
      <div className="flex h-32 items-center justify-center rounded-(--neba-radius-md) border border-dashed border-(--n-line) text-[0.8125rem] text-(--neba-muted-fg) select-none">
        Right-click anywhere in this box
      </div>
    </ContextMenu>
  );
}
