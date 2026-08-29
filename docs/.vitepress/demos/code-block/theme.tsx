import { CodeBlock } from 'neba';
import type { CodeBlockTheme } from 'neba';

const source = `/* a queue that never grows past its bound */
export class Ring<T> {
  #items: (T | undefined)[];

  constructor(readonly size = 16) {
    this.#items = new Array(size);
  }
}`;

export default function CodeBlockTheme() {
  return (
    <div className="flex w-full flex-col gap-4">
      {(['dark', 'light', 'auto', 'mono'] as CodeBlockTheme[]).map((theme) => (
        <CodeBlock key={theme} code={source} language="ts" theme={theme} title={theme} size="sm" />
      ))}
    </div>
  );
}
