import { Shortcut } from 'neba';

/**
 * The same three shortcuts, named for three keyboards. `Mod` is the token that
 * changes meaning rather than spelling: Command on a Mac, Control everywhere
 * else — which is the whole reason writing `Ctrl` and hoping is wrong.
 */
export default function ShortcutPlatforms() {
  return (
    <div className="grid grid-cols-[auto_1fr_1fr_1fr] items-center gap-x-6 gap-y-3 text-[0.8125rem]">
      <span />
      <span className="text-[0.75rem] text-(--vp-c-text-3)">macOS</span>
      <span className="text-[0.75rem] text-(--vp-c-text-3)">Windows</span>
      <span className="text-[0.75rem] text-(--vp-c-text-3)">Linux</span>

      <span>Save</span>
      <Shortcut os="mac" keys="Mod+S" />
      <Shortcut os="windows" keys="Mod+S" />
      <Shortcut os="linux" keys="Mod+S" />

      <span>Search</span>
      <Shortcut os="mac" keys="Mod+Shift+F" />
      <Shortcut os="windows" keys="Mod+Shift+F" />
      <Shortcut os="linux" keys="Mod+Shift+F" />

      <span>Lock</span>
      <Shortcut os="mac" keys="Meta+Ctrl+Q" />
      <Shortcut os="windows" keys="Meta+L" />
      <Shortcut os="linux" keys="Meta+L" />
    </div>
  );
}
