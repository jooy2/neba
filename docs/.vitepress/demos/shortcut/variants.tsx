import { Shortcut } from 'neba';

const sizes = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function ShortcutVariants() {
  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-wrap items-center gap-4">
        <Shortcut keys="Mod+K" variant="solid" />
        <Shortcut keys="Mod+K" variant="outline" />
        <Shortcut keys="Mod+K" variant="text" />
        <Shortcut keys="Mod+K" variant="outline" color="primary" />
        <Shortcut keys="Mod+K" variant="solid" color="danger" />
      </div>

      <div className="flex flex-wrap items-center gap-4">
        {sizes.map((size) => (
          <Shortcut key={size} size={size} keys="Mod+K" />
        ))}
      </div>
    </div>
  );
}
