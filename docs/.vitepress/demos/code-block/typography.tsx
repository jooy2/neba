import { CodeBlock } from 'neba';

const source = `.neba-code-line[data-prompt]::after {
  content: attr(data-prompt);
  user-select: none;
}`;

export default function CodeBlockTypography() {
  return (
    <div className="flex w-full flex-col gap-4">
      <CodeBlock code={source} language="css" size="sm" title="size='sm'" />

      <CodeBlock
        code={source}
        language="css"
        title="letterSpacing · lineHeight"
        fontSize={15}
        lineHeight={2}
        letterSpacing="0.04em"
      />
    </div>
  );
}
