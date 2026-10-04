export { CodeBlock } from './CodeBlock.js';
// Not through `CodeBlock.tsx`: a Server Component could not call it from there.
export { registerLanguage } from '../../internal/highlight.js';
export type { CodeBlockProps, CodeBlockTheme } from './CodeBlock.js';
