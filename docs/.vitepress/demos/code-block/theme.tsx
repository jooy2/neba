import { useState } from 'react';
import { CodeBlock, Select } from 'neba';
import type { CodeBlockTheme } from 'neba';

const HOUSE: CodeBlockTheme[] = ['dark', 'light', 'auto', 'mono'];
const PORTS: CodeBlockTheme[] = [
  'one-dark',
  'dracula',
  'monokai',
  'nord',
  'night-owl',
  'gruvbox',
  'github',
  'solarized-light'
];

const source = `/* a queue that never grows past its bound */
export class Ring<T> {
  #items: (T | undefined)[];

  constructor(readonly size = 16) {
    this.#items = new Array(size);
  }

  push(item: T): boolean {
    const at = this.#count % this.size;
    this.#items[at] = item;
    return ++this.#count <= this.size;
  }
}`;

export default function CodeBlockThemes() {
  const [theme, setTheme] = useState<CodeBlockTheme>('dracula');

  return (
    <div className="flex w-full flex-col gap-4">
      <Select
        size="sm"
        label="Theme"
        items={[...HOUSE, ...PORTS].map((name) => ({ value: name, label: name }))}
        value={theme}
        onValueChange={(next) => setTheme(next as CodeBlockTheme)}
      />

      <CodeBlock code={source} language="ts" theme={theme} title={theme} />
    </div>
  );
}
