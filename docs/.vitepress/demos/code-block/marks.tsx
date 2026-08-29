import { CodeBlock } from 'neba';

const source = `export function middleware(request: Request) {
  const token = request.headers.get('authorization');

  if (!token) {
    return new Response('Unauthorized', { status: 401 });
  }

  return NextResponse.next();
}`;

export default function CodeBlockMarks() {
  return (
    <div className="flex w-full flex-col gap-4">
      <CodeBlock
        code={source}
        language="ts"
        lineNumbers
        highlightLines="4-6"
        title="highlightLines='4-6'"
      />

      <CodeBlock
        code={source}
        language="ts"
        lineNumbers
        highlightLines={[2, '4-6', 9]}
        theme="one-dark"
        title="highlightLines={[2, '4-6', 9]}"
      />
    </div>
  );
}
