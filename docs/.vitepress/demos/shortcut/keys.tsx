import { Shortcut } from 'neba';

const examples: { label: string; keys: string | string[] }[] = [
  { label: 'A single letter', keys: 'K' },
  { label: 'A named key', keys: 'Escape' },
  { label: 'Arrows, on every platform', keys: ['ArrowUp', 'ArrowDown'] },
  { label: 'A key that is itself a plus', keys: ['Mod', '+'] },
  { label: 'Three modifiers', keys: 'Mod+Alt+Shift+Delete' },
  { label: 'A function key', keys: 'F12' }
];

export default function ShortcutKeys() {
  return (
    <div className="flex w-full max-w-md flex-col gap-3">
      {examples.map((example) => (
        <div
          key={example.label}
          className="flex items-center justify-between gap-4 text-[0.8125rem]"
        >
          <span>{example.label}</span>
          <Shortcut keys={example.keys} />
        </div>
      ))}
    </div>
  );
}
