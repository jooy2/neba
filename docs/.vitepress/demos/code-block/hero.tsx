import { CodeBlock } from 'neba';

const source = `import { createServer } from 'node:http';

const server = createServer((request, response) => {
  response.writeHead(200, { 'content-type': 'application/json' });
  response.end(JSON.stringify({ ok: true, path: request.url }));
});

server.listen(3000, () => console.log('listening on :3000'));`;

export default function CodeBlockHero() {
  return <CodeBlock code={source} language="ts" title="server.ts" lineNumbers />;
}
