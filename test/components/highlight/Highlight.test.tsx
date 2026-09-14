import * as React from 'react';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Highlight } from 'neba';

/** What every `<mark>` in the tree says, in document order. */
function marks(root: Element): string[] {
  return Array.from(root.querySelectorAll('mark')).map((mark) => mark.textContent ?? '');
}

describe('Highlight', () => {
  describe('matching', () => {
    it('marks every occurrence of the term', async () => {
      const screen = await render(
        <Highlight query="the">the quick brown fox and the lazy dog</Highlight>
      );

      expect(marks(screen.container)).toEqual(['the', 'the']);
    });

    it('leaves the text around the matches intact', async () => {
      const screen = await render(<Highlight query="brown">the quick brown fox</Highlight>);

      expect(screen.container.textContent).toBe('the quick brown fox');
    });

    it('marks nothing and changes nothing when there is no match', async () => {
      const screen = await render(<Highlight query="zebra">the quick brown fox</Highlight>);

      expect(marks(screen.container)).toEqual([]);
      expect(screen.container.textContent).toBe('the quick brown fox');
    });

    // An empty search box should leave the text as it was, not mark all of it.
    it('marks nothing for an empty query', async () => {
      const screen = await render(<Highlight query="">the quick brown fox</Highlight>);

      expect(marks(screen.container)).toEqual([]);

      await screen.rerender(<Highlight query={['', '  ']}>the quick brown fox</Highlight>);

      expect(marks(screen.container)).toEqual([]);
    });

    it('takes several terms at once', async () => {
      const screen = await render(
        <Highlight query={['quick', 'dog']}>the quick brown fox and the lazy dog</Highlight>
      );

      expect(marks(screen.container)).toEqual(['quick', 'dog']);
    });

    // Alternation is first-match-wins, so the longest term has to be tried
    // first or `data` would win and leave `base` outside the mark.
    it('prefers the longest term when two overlap', async () => {
      const screen = await render(
        <Highlight query={['data', 'database']}>one database row</Highlight>
      );

      expect(marks(screen.container)).toEqual(['database']);
    });

    it('treats the query as text rather than as a pattern', async () => {
      const screen = await render(<Highlight query="a.c">abc and a.c</Highlight>);

      expect(marks(screen.container)).toEqual(['a.c']);
    });

    it('takes a RegExp as written', async () => {
      const screen = await render(<Highlight query={/\d+/}>Order 66 of 1977</Highlight>);

      expect(marks(screen.container)).toEqual(['66', '1977']);
    });

    // `wholeWord` is documented as ignored for a RegExp, which says its own
    // boundaries; it went on filtering the expression's matches.
    it('ignores wholeWord for a RegExp', async () => {
      const screen = await render(
        <Highlight query={/cat/} wholeWord>
          concatenate cat
        </Highlight>
      );

      expect(marks(screen.container)).toEqual(['cat', 'cat']);
    });

    it('leaves a caller-supplied RegExp alone', async () => {
      // A global expression carries a `lastIndex` that matching moves. The
      // caller may be matching with this one elsewhere, so marking must not
      // reach into it.
      const query = /\d+/g;

      query.lastIndex = 0;
      expect(query.exec('Order 66')?.[0]).toBe('66');

      const resumed = query.lastIndex;
      const screen = await render(<Highlight query={query}>Order 66 of 1977</Highlight>);

      expect(marks(screen.container)).toEqual(['66', '1977']);
      expect(query.lastIndex).toBe(resumed);
    });

    it('does not hang on a pattern that can match nothing', async () => {
      const screen = await render(<Highlight query={/x*/}>abc</Highlight>);

      expect(screen.container.textContent).toBe('abc');
    });

    it('marks numbers in the children as well as strings', async () => {
      const screen = await render(<Highlight query="7">{2007}</Highlight>);

      expect(marks(screen.container)).toEqual(['7']);
    });

    it('re-marks when the query changes', async () => {
      const screen = await render(<Highlight query="quick">the quick brown fox</Highlight>);

      expect(marks(screen.container)).toEqual(['quick']);

      await screen.rerender(<Highlight query="brown">the quick brown fox</Highlight>);

      expect(marks(screen.container)).toEqual(['brown']);
    });
  });

  describe('case', () => {
    it('ignores case by default', async () => {
      const screen = await render(<Highlight query="fox">Fox, FOX and fox</Highlight>);

      expect(marks(screen.container)).toEqual(['Fox', 'FOX', 'fox']);
    });

    it('respects it when asked', async () => {
      const screen = await render(
        <Highlight query="fox" caseSensitive>
          Fox, FOX and fox
        </Highlight>
      );

      expect(marks(screen.container)).toEqual(['fox']);
    });
  });

  // DataTable found `José` for `jose` and Highlight, given the same query,
  // marked nothing in the row it found.
  describe('accents', () => {
    it('marks an accented word for a query without the accent', async () => {
      const screen = await render(<Highlight query="jose">José, JOSÉ and Jose</Highlight>);

      expect(marks(screen.container)).toEqual(['José', 'JOSÉ', 'Jose']);
    });

    it('marks the whole of a decomposed letter, accent included', async () => {
      const screen = await render(<Highlight query="cafe">{'Cafe\u0301 au lait'}</Highlight>);

      expect(marks(screen.container)).toEqual(['Cafe\u0301']);
      expect(screen.container.textContent).toBe('Cafe\u0301 au lait');
    });

    it('marks an unaccented word for a query with the accent', async () => {
      const screen = await render(<Highlight query="résumé">A resume</Highlight>);

      expect(marks(screen.container)).toEqual(['resume']);
    });

    it('does not mark part of a Hangul syllable', async () => {
      const screen = await render(<Highlight query="가">각 가</Highlight>);

      expect(marks(screen.container)).toEqual(['가']);
    });

    it('matches a RegExp as written', async () => {
      const screen = await render(<Highlight query={/jose/i}>José and Jose</Highlight>);

      expect(marks(screen.container)).toEqual(['Jose']);
    });
  });

  describe('whole words', () => {
    it('matches inside a word by default', async () => {
      const screen = await render(<Highlight query="cat">a cat concatenates</Highlight>);

      expect(marks(screen.container)).toEqual(['cat', 'cat']);
    });

    it('matches only whole words when asked', async () => {
      const screen = await render(
        <Highlight query="cat" wholeWord>
          a cat concatenates
        </Highlight>
      );

      expect(marks(screen.container)).toEqual(['cat']);
    });

    // A rejected match is not a claim on the characters inside it. `exec` has
    // already moved past the whole of it by the time the word boundaries are
    // checked, and terms are tried longest first — so `a b` matches at `xa b`,
    // is thrown out for starting mid-word, and takes the whole-word `b` inside
    // it down with it unless the scan is rewound.
    it('finds a whole word that starts inside a rejected match', async () => {
      const screen = await render(
        <Highlight query={['a b', 'b']} wholeWord>
          xa b
        </Highlight>
      );

      expect(marks(screen.container)).toEqual(['b']);
    });

    // A word is a run of letters in any script, so it means what it should for
    // text the ASCII definition would get wrong.
    it('counts accented letters as part of a word', async () => {
      const screen = await render(
        <Highlight query="caf" wholeWord>
          café
        </Highlight>
      );

      expect(marks(screen.container)).toEqual([]);
    });
  });

  describe('nested content', () => {
    // Requiring `children` to be a string is what most libraries do, and it
    // fails on the first search result that has a `<strong>` in it.
    it('walks into elements and marks the text inside them', async () => {
      const screen = await render(
        <Highlight query="fox">
          the quick <strong>brown fox</strong> jumped
        </Highlight>
      );

      expect(marks(screen.container)).toEqual(['fox']);
      expect(screen.container.querySelector('strong')?.textContent).toBe('brown fox');
    });

    it('keeps the marked text inside the element it was in', async () => {
      const screen = await render(
        <Highlight query="fox">
          the quick <em>fox</em>
        </Highlight>
      );

      expect(screen.container.querySelector('em mark')?.textContent).toBe('fox');
    });

    it('keeps a list mounted when a query arrives and leaves', async () => {
      let mounts = 0;

      function Row({ children }: { children: React.ReactNode }) {
        React.useEffect(() => {
          mounts += 1;
        }, []);

        return <li>{children}</li>;
      }

      const list = (query: string) => (
        <Highlight query={query}>
          <ul>
            {['alpha', 'beta', 'gamma'].map((word) => (
              <Row key={word}>{word}</Row>
            ))}
          </ul>
        </Highlight>
      );
      const screen = await render(list(''));

      expect(mounts).toBe(3);

      await screen.rerender(list('a'));
      expect(marks(screen.container)).toEqual(['a', 'a', 'a', 'a', 'a']);

      await screen.rerender(list(''));
      expect(mounts).toBe(3);
    });

    it('asks for no keys the children did not already owe', async () => {
      const error = vi.spyOn(console, 'error').mockImplementation(() => {});

      await render(
        <Highlight query="o">
          one <b>two</b> <i>three</i>
          <p>
            four <b>five</b>
          </p>
        </Highlight>
      );

      const logged = error.mock.calls.flat().join(' ');

      error.mockRestore();
      expect(logged).not.toContain('key');
    });

    it('leaves an element with no children alone', async () => {
      const screen = await render(
        <Highlight query="a">
          a<br />a
        </Highlight>
      );

      expect(marks(screen.container)).toEqual(['a', 'a']);
      expect(screen.container.querySelector('br')?.childNodes).toHaveLength(0);
    });
  });

  describe('style props', () => {
    it('maps color onto the token slots the styles read from', async () => {
      const screen = await render(<Highlight query="a">abc</Highlight>);
      const element = screen.container.firstElementChild as HTMLElement;

      // Warning by default: the one family whose fill is light with dark ink on
      // it, which is what a highlighter pen actually looks like.
      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-warning-fill)');

      await screen.rerender(
        <Highlight query="a" color="primary">
          abc
        </Highlight>
      );

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-primary-fill)');
    });

    // A `<mark>` arrives from the browser's own stylesheet with a yellow
    // background, so "no surface" has to be said out loud.
    it('sets a background on every variant, including the bare one', async () => {
      const screen = await render(
        <Highlight query="a" variant="text">
          abc
        </Highlight>
      );

      expect(screen.container.querySelector('mark')).toHaveClass('bg-transparent');
    });

    it('draws a border for the outline variant only', async () => {
      const screen = await render(
        <Highlight query="a" variant="outline">
          abc
        </Highlight>
      );

      expect(screen.container.querySelector('mark')).toHaveClass('border');

      await screen.rerender(<Highlight query="a">abc</Highlight>);

      expect(screen.container.querySelector('mark')).not.toHaveClass('border');
    });

    // The border is two pixels a mark added to its word's width, so the text
    // after it moved whenever a search found one more. Measured with the
    // stylesheet loaded it is the same width as the unmarked line; no component
    // test loads one, so what is pinned here is that the margin gives it back.
    it('gives the outline border back in its margin', async () => {
      const screen = await render(
        <Highlight query="a" variant="outline">
          abc
        </Highlight>
      );

      expect(screen.container.querySelector('mark')).toHaveClass(
        'px-0.5',
        '-mx-[calc(0.125rem+1px)]'
      );

      await screen.rerender(<Highlight query="a">abc</Highlight>);

      expect(screen.container.querySelector('mark')).toHaveClass('px-0.5', '-mx-0.5');
    });

    it('adds an underline and a weight only when asked', async () => {
      const screen = await render(<Highlight query="a">abc</Highlight>);

      expect(screen.container.querySelector('mark')).not.toHaveClass('underline');

      await screen.rerender(
        <Highlight query="a" underline weight="bold">
          abc
        </Highlight>
      );

      const mark = screen.container.querySelector('mark');
      expect(mark).toHaveClass('underline');
      expect(mark).toHaveClass('font-bold');
    });

    it('keeps caller-supplied class names on the wrapper', async () => {
      const screen = await render(
        <Highlight query="a" className="my-own-class">
          abc
        </Highlight>
      );

      expect(screen.container.firstElementChild).toHaveClass('my-own-class');
    });
  });
});
