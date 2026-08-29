import { useState } from 'react';
import { CodeBlock, Checkbox } from 'neba';

const source = `docker build -t neba/docs:latest .
docker run --rm -p 8080:80 neba/docs:latest`;

export default function CodeBlockChrome() {
  const [toolbar, setToolbar] = useState(true);
  const [showLanguage, setShowLanguage] = useState(true);
  const [copyable, setCopyable] = useState(true);
  const [rawToggle, setRawToggle] = useState(true);
  const [lineNumbers, setLineNumbers] = useState(false);

  return (
    <div className="flex w-full flex-col gap-4">
      <div className="flex flex-wrap gap-x-5 gap-y-2">
        <Checkbox size="sm" checked={toolbar} onCheckedChange={setToolbar} label="toolbar" />
        <Checkbox
          size="sm"
          checked={showLanguage}
          onCheckedChange={setShowLanguage}
          label="showLanguage"
        />
        <Checkbox size="sm" checked={copyable} onCheckedChange={setCopyable} label="copyable" />
        <Checkbox size="sm" checked={rawToggle} onCheckedChange={setRawToggle} label="rawToggle" />
        <Checkbox
          size="sm"
          checked={lineNumbers}
          onCheckedChange={setLineNumbers}
          label="lineNumbers"
        />
      </div>

      <CodeBlock
        code={source}
        language="bash"
        toolbar={toolbar}
        showLanguage={showLanguage}
        copyable={copyable}
        rawToggle={rawToggle}
        lineNumbers={lineNumbers}
      />
    </div>
  );
}
