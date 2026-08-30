/**
 * highlight.js's markup, as the lines of coloured runs a CodeBlock draws.
 *
 * `tokenize` is the reason nothing in this library ever writes
 * `dangerouslySetInnerHTML`, and it is a string walk with two cases that a
 * `split('\n')` cannot do: a span that crosses a newline, and a span nested
 * inside another. Both are one call here and a whole grammar chunk away through
 * a rendered CodeBlock.
 */
import { describe, expect, it } from 'vitest';
import { canonicalLanguage, plainLines, tokenize } from '../../src/internal/highlight.js';

/** Every line as its plain text, which is what the clipboard and a select get. */
const text = (lines: ReturnType<typeof tokenize>) =>
  lines.map((line) => line.map((run) => run.text).join(''));

describe('tokenize', () => {
  it('reads a run with no colour on it', () => {
    expect(tokenize('const x')).toEqual([[{ text: 'const x' }]]);
  });

  it('keeps the class highlight.js put on a run', () => {
    expect(tokenize('<span class="hljs-keyword">const</span> x')).toEqual([
      [{ text: 'const', token: 'hljs-keyword' }, { text: ' x' }]
    ]);
  });

  it('splits at a newline', () => {
    expect(text(tokenize('one\ntwo'))).toEqual(['one', 'two']);
  });

  it('carries an open class across a newline and reopens it', () => {
    // A block comment, a template literal and a heredoc all do this, which is
    // why the whole block is highlighted at once and split afterwards.
    const lines = tokenize('<span class="hljs-comment">/* one\ntwo */</span>');

    expect(text(lines)).toEqual(['/* one', 'two */']);
    expect(lines[0][0].token).toBe('hljs-comment');
    expect(lines[1][0].token).toBe('hljs-comment');
  });

  it('keeps only the innermost class of a nesting', () => {
    // In the browser that is the one on the element the text actually sits in,
    // so it is the one whose colour applies. Keeping the ancestors would put
    // two equally specific rules on one run and let stylesheet order decide.
    const lines = tokenize('<span class="hljs-title"><span class="hljs-name">div</span></span>');

    expect(lines[0][0]).toEqual({ text: 'div', token: 'hljs-name' });
  });

  it('goes back to the outer class after a nesting closes', () => {
    const lines = tokenize('<span class="hljs-string">"<span class="hljs-subst">x</span>"</span>');

    expect(lines[0].map((run) => run.token)).toEqual(['hljs-string', 'hljs-subst', 'hljs-string']);
  });

  it('decodes the five entities highlight.js writes, and no others', () => {
    expect(text(tokenize('&lt;a&gt; &amp;&amp; &quot;x&quot; &#x27;y&#x27;'))).toEqual([
      '<a> && "x" \'y\''
    ]);
    // Anything else came out of the source and is text, not an entity.
    expect(text(tokenize('&nbsp;'))).toEqual(['&nbsp;']);
  });

  it('keeps a blank line as a line', () => {
    // A line is what carries a number, a prompt and a place in a scroll, so a
    // block that loses its empty lines loses its numbering too.
    expect(tokenize('one\n\ntwo')).toHaveLength(3);
    expect(tokenize('one\n\ntwo')[1]).toEqual([]);
  });

  it('answers one empty line for an empty block', () => {
    expect(tokenize('')).toEqual([[]]);
  });

  it('keeps a trailing newline as a line of its own', () => {
    expect(tokenize('one\n')).toHaveLength(2);
  });
});

describe('plainLines', () => {
  it('is the same shape with no colour in it', () => {
    expect(plainLines('one\ntwo')).toEqual([[{ text: 'one' }], [{ text: 'two' }]]);
  });

  it('agrees with `tokenize` about how many lines there are', () => {
    for (const source of ['', 'one', 'one\n', 'one\n\ntwo']) {
      expect(plainLines(source)).toHaveLength(tokenize(source).length);
    }
  });
});

describe('canonicalLanguage', () => {
  it('resolves an alias to the grammar behind it', () => {
    expect(canonicalLanguage('ts')).toBe('typescript');
    expect(canonicalLanguage('js')).toBe('javascript');
    expect(canonicalLanguage('sh')).toBe('bash');
  });

  it('does not care about case or surrounding space', () => {
    expect(canonicalLanguage('  TypeScript ')).toBe('typescript');
  });

  it('hands back a name it has never heard of, rather than nothing', () => {
    // Whether the grammar can be loaded is a later question. This one is only
    // what the caller's spelling means.
    expect(canonicalLanguage('elixir')).toBe('elixir');
  });

  it('answers null for no language at all', () => {
    expect(canonicalLanguage(undefined)).toBeNull();
    expect(canonicalLanguage('')).toBeNull();
    expect(canonicalLanguage('   ')).toBeNull();
  });
});
