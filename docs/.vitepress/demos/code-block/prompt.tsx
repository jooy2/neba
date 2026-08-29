import { CodeBlock } from 'neba';

export default function CodeBlockPrompt() {
  return (
    <div className="flex w-full flex-col gap-4">
      <CodeBlock
        code={'npm install neba\nnpm run build'}
        language="bash"
        prompt="$"
        showLanguage={false}
        title="a user's shell"
      />

      <CodeBlock
        code={'apt-get update\napt-get install -y build-essential'}
        language="bash"
        prompt="#"
        showLanguage={false}
        title="root"
      />

      <CodeBlock
        code={'cd C:\\projects\\neba\nnpm run docs:dev'}
        language="powershell"
        prompt={'C:\\>'}
        showLanguage={false}
        title="PowerShell"
      />
    </div>
  );
}
