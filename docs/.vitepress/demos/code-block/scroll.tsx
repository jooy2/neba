import { useState } from 'react';
import { CodeBlock, Segment, SegmentedButton } from 'neba';

const source = `{
  "name": "neba",
  "type": "module",
  "sideEffects": ["**/*.css"],
  "exports": {
    ".": { "types": "./dist/index.d.ts", "default": "./dist/index.js" },
    "./locales": { "types": "./dist/locales/index.d.ts", "default": "./dist/locales/index.js" },
    "./styles.css": "./dist/styles.css",
    "./*": { "types": "./dist/components/*/index.d.ts", "default": "./dist/components/*/index.js" }
  },
  "dependencies": { "@base-ui/react": "^1.7.0", "highlight.js": "^11.12.0" }
}`;

export default function CodeBlockScroll() {
  const [wrap, setWrap] = useState(false);

  return (
    <div className="flex w-full flex-col gap-4">
      <SegmentedButton
        size="sm"
        value={wrap ? 'wrap' : 'scroll'}
        onValueChange={(next) => setWrap(next === 'wrap')}
      >
        <Segment value="scroll">scroll</Segment>
        <Segment value="wrap">wrap</Segment>
      </SegmentedButton>

      <CodeBlock
        code={source}
        language="json"
        wrap={wrap}
        maxHeight={200}
        lineNumbers
        title="package.json"
      />
    </div>
  );
}
