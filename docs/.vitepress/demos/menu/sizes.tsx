import { Button, Menu, MenuItem } from 'neba';

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function MenuSizes() {
  return (
    <div className="flex flex-wrap items-center gap-2">
      {SIZES.map((size) => (
        <Menu
          key={size}
          size={size}
          trigger={
            <Button size={size} variant="outline" color="secondary">
              {size}
            </Button>
          }
        >
          <MenuItem shortcut="⌘E">Rename</MenuItem>
          <MenuItem shortcut="⌘D">Duplicate</MenuItem>
          <MenuItem>Move to archive</MenuItem>
        </Menu>
      ))}
    </div>
  );
}
