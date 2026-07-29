import { Shortcut } from 'neba';

export default function ShortcutHero() {
  return (
    <div className="flex w-full max-w-md flex-col gap-4">
      <div className="flex items-center justify-between gap-4 text-[0.8125rem]">
        <span>Open the command palette</span>
        <Shortcut keys="Mod+K" />
      </div>
      <div className="flex items-center justify-between gap-4 text-[0.8125rem]">
        <span>Save</span>
        <Shortcut keys="Mod+S" />
      </div>
      <div className="flex items-center justify-between gap-4 text-[0.8125rem]">
        <span>Close the tab</span>
        <Shortcut keys="Mod+Shift+W" />
      </div>
    </div>
  );
}
