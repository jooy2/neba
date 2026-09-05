import { afterEach, describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { CodeBlock } from 'neba';
import { ko, registerMessages } from 'neba/locales';

/* The library ships English; a `locale` prop answers for a language the project
   has registered. The one assertion about that prop registers Korean the way a
   consumer would. */
registerMessages('ko', ko);

const SOURCE = `const answer = 42;\nconsole.log(answer);`;

/** Every line the block drew, as the reader would read them. */
const lines = (root: Element) => [...root.querySelectorAll('.neba-code-line')];

describe('CodeBlock', () => {
  describe('rendering', () => {
    it('draws the code it was given', async () => {
      const screen = await render(<CodeBlock code={SOURCE} data-testid="block" />);

      await expect
        .element(screen.getByTestId('block'))
        .toMatchTextContent('const answer = 42;console.log(answer);');
    });

    it('draws one line per line of source', async () => {
      const screen = await render(<CodeBlock code={SOURCE} data-testid="block" />);

      expect(lines(screen.getByTestId('block').element())).toHaveLength(2);
    });

    // A blank line inside a block is a paragraph break in the reader's file, and
    // a viewer that closed it up would be reflowing their code.
    it('keeps a blank line in the middle', async () => {
      const screen = await render(<CodeBlock code={'a\n\nb'} data-testid="block" />);

      expect(lines(screen.getByTestId('block').element())).toHaveLength(3);
    });

    // A template literal is almost always written with a newline before its
    // closing backtick, which would be a blank line at the bottom of every block.
    it('drops trailing blank lines', async () => {
      const screen = await render(<CodeBlock code={'a\nb\n\n\n'} data-testid="block" />);

      expect(lines(screen.getByTestId('block').element())).toHaveLength(2);
    });

    // A `code` prop very often arrives from a file, and a file written on
    // Windows ends every line with a carriage return the reader cannot see.
    it('normalises CRLF line endings', async () => {
      const screen = await render(<CodeBlock code={'a\r\nb'} data-testid="block" />);
      const drawn = lines(screen.getByTestId('block').element());

      expect(drawn).toHaveLength(2);
      expect(drawn[0].textContent).toBe('a');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <CodeBlock code={SOURCE} className="my-own-class" data-testid="block" />
      );

      expect(screen.getByTestId('block').element()).toHaveClass('my-own-class');
      expect(screen.getByTestId('block').element()).toHaveClass('neba-code');
    });

    it('forwards unknown props to the root', async () => {
      const screen = await render(<CodeBlock code={SOURCE} data-testid="block" id="sample" />);

      expect(screen.getByTestId('block').element()).toHaveAttribute('id', 'sample');
    });
  });

  describe('highlighting', () => {
    // The grammar is behind a dynamic import, so the block draws plain first and
    // colours itself when the chunk lands — hence the retrying assertion.
    it('colours the code once the grammar has arrived', async () => {
      const screen = await render(<CodeBlock code={SOURCE} language="ts" data-testid="block" />);

      await expect
        .poll(() => screen.getByTestId('block').element().querySelectorAll('.hljs-keyword').length)
        .toBeGreaterThan(0);
    });

    it('understands an alias for the language', async () => {
      const screen = await render(<CodeBlock code={SOURCE} language="TSX" data-testid="block" />);

      await expect
        .poll(() => screen.getByTestId('block').element().querySelectorAll('.hljs-keyword').length)
        .toBeGreaterThan(0);
    });

    // Nothing is fetched at all with it off, so this is also the assertion that
    // the import is skipped rather than merely ignored.
    it('draws no colour at all when highlight is off', async () => {
      const screen = await render(
        <CodeBlock code={SOURCE} language="ts" highlight={false} data-testid="block" />
      );

      await expect.element(screen.getByTestId('block')).toMatchTextContent('const answer');
      expect(screen.getByTestId('block').element().querySelector('.hljs-keyword')).toBeNull();
    });

    // A language nothing here knows is a block drawn plain, never a block that
    // throws or an empty box.
    it('draws an unknown language plain', async () => {
      const screen = await render(
        <CodeBlock code={SOURCE} language="klingon" data-testid="block" />
      );

      await expect.element(screen.getByTestId('block')).toMatchTextContent('const answer = 42;');
    });

    // A block comment, a template literal and a heredoc all cross lines, so the
    // block is highlighted as a whole and split afterwards.
    it('keeps a token that spans two lines on both of them', async () => {
      const screen = await render(
        <CodeBlock code={'/* one\n   two */\nconst a = 1;'} language="ts" data-testid="block" />
      );

      await expect
        .poll(() => lines(screen.getByTestId('block').element())[1]?.querySelector('.hljs-comment'))
        .not.toBeNull();
    });
  });

  describe('the toolbar', () => {
    it('names the language', async () => {
      const screen = await render(<CodeBlock code={SOURCE} language="yml" />);

      await expect.element(screen.getByText('yaml')).toBeInTheDocument();
    });

    it('draws a title when it is given one', async () => {
      const screen = await render(<CodeBlock code={SOURCE} title="answer.ts" />);

      await expect.element(screen.getByText('answer.ts')).toBeInTheDocument();
    });

    it('leaves the language out when showLanguage is off', async () => {
      const screen = await render(
        <CodeBlock code={SOURCE} language="yml" showLanguage={false} data-testid="block" />
      );

      expect(screen.getByText('yaml').query()).toBeNull();
    });

    it('drops the whole bar when toolbar is off', async () => {
      const screen = await render(
        <CodeBlock code={SOURCE} language="yml" toolbar={false} title="answer.ts" />
      );

      expect(screen.getByRole('button', { name: 'Copy' }).query()).toBeNull();
      expect(screen.getByText('answer.ts').query()).toBeNull();
    });

    it('offers the raw toggle only when it is asked for', async () => {
      const screen = await render(<CodeBlock code={SOURCE} language="ts" />);

      expect(screen.getByRole('button', { name: 'Raw' }).query()).toBeNull();

      await screen.rerender(<CodeBlock code={SOURCE} language="ts" rawToggle />);

      await expect.element(screen.getByRole('button', { name: 'Raw' })).toBeInTheDocument();
    });

    it('drops the colouring while the raw toggle is pressed', async () => {
      const screen = await render(
        <CodeBlock code={SOURCE} language="ts" rawToggle data-testid="block" />
      );

      await expect
        .poll(() => screen.getByTestId('block').element().querySelectorAll('.hljs-keyword').length)
        .toBeGreaterThan(0);

      await screen.getByRole('button', { name: 'Raw' }).click();

      await expect
        .poll(() => screen.getByTestId('block').element().querySelectorAll('.hljs-keyword').length)
        .toBe(0);
    });
  });

  describe('copying', () => {
    /*
      The clipboard is stubbed rather than driven, and that is the boundary the
      rest of the suite keeps too: what belongs to CodeBlock is *what* it hands
      over and what it says afterwards, not whether Chromium's own permission
      prompt cleared. Driving the real one is also not available here —
      `writeText` waits for the document to hold the focus, and a test frame in
      a headless run does not.
    */
    const stubClipboard = (writeText: (text: string) => Promise<void>) => {
      const spy = vi.fn(writeText);

      // Defined on the instance rather than spied on: `clipboard` is a getter on
      // `Navigator.prototype`, and an own property is what shadows it.
      Object.defineProperty(navigator, 'clipboard', {
        value: { writeText: spy },
        configurable: true
      });

      return spy;
    };

    afterEach(() => {
      Reflect.deleteProperty(navigator, 'clipboard');
      vi.restoreAllMocks();
    });

    it('puts the code on the clipboard and says so', async () => {
      const writeText = stubClipboard(() => Promise.resolve());
      const onCopy = vi.fn();
      const screen = await render(<CodeBlock code={SOURCE} onCopy={onCopy} />);

      await screen.getByRole('button', { name: 'Copy' }).click();

      await expect.element(screen.getByRole('button', { name: 'Copied' })).toBeInTheDocument();
      expect(writeText).toHaveBeenCalledWith(SOURCE);
      expect(onCopy).toHaveBeenCalledWith(SOURCE);
    });

    // A page served over plain HTTP has no clipboard at all, and the fallback
    // can fail too. Saying nothing would leave the reader pressing again.
    it('says so when the clipboard refuses', async () => {
      stubClipboard(() => Promise.reject(new Error('denied')));
      vi.spyOn(document, 'execCommand').mockReturnValue(false);

      const onCopy = vi.fn();
      const screen = await render(<CodeBlock code={SOURCE} onCopy={onCopy} />);

      await screen.getByRole('button', { name: 'Copy' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Could not copy' }))
        .toBeInTheDocument();
      expect(onCopy).not.toHaveBeenCalled();
    });

    it('leaves the button out when copyable is off', async () => {
      const screen = await render(<CodeBlock code={SOURCE} copyable={false} language="ts" />);

      expect(screen.getByRole('button', { name: 'Copy' }).query()).toBeNull();
    });

    // The symbol is decoration, not code: it is generated content off a
    // `data-prompt` attribute, so it never reaches the clipboard.
    it('copies the code without the prompt symbols', async () => {
      const writeText = stubClipboard(() => Promise.resolve());
      const screen = await render(<CodeBlock code={'npm install\nnpm test'} prompt="$" />);

      await screen.getByRole('button', { name: 'Copy' }).click();

      await expect.poll(() => writeText.mock.calls[0]?.[0]).toBe('npm install\nnpm test');
    });
  });

  describe('line numbers and prompts', () => {
    it('numbers the lines from one', async () => {
      const screen = await render(<CodeBlock code={SOURCE} lineNumbers data-testid="block" />);
      const drawn = lines(screen.getByTestId('block').element());

      expect(drawn.map((line) => line.getAttribute('data-line'))).toEqual(['1', '2']);
    });

    it('starts an excerpt where it actually starts', async () => {
      const screen = await render(
        <CodeBlock code={SOURCE} lineNumbers startLine={286} data-testid="block" />
      );
      const drawn = lines(screen.getByTestId('block').element());

      expect(drawn.map((line) => line.getAttribute('data-line'))).toEqual(['286', '287']);
    });

    // The gutter is sized for the last number so it does not step as the block
    // scrolls: two digits at line 99, three at 100.
    it('sizes the gutter for the last number', async () => {
      const screen = await render(
        <CodeBlock code={'a\nb'} lineNumbers startLine={99} data-testid="block" />
      );

      expect(
        (screen.getByTestId('block').element() as HTMLElement).style.getPropertyValue(
          '--n-code-gutter'
        )
      ).toBe('3ch');
    });

    it('draws no numbers unless it is asked to', async () => {
      const screen = await render(<CodeBlock code={SOURCE} data-testid="block" />);

      expect(lines(screen.getByTestId('block').element())[0]).not.toHaveAttribute('data-line');
    });

    it('marks every line that has something on it with the prompt', async () => {
      const screen = await render(<CodeBlock code={'a\nb'} prompt="$" data-testid="block" />);
      const drawn = lines(screen.getByTestId('block').element());

      expect(drawn.map((line) => line.getAttribute('data-prompt'))).toEqual(['$', '$']);
    });

    // A `$` on a line with nothing after it is a prompt for a command that was
    // never typed.
    it('leaves a blank line without one', async () => {
      const screen = await render(<CodeBlock code={'a\n\nb'} prompt="$" data-testid="block" />);
      const drawn = lines(screen.getByTestId('block').element());

      expect(drawn[1]).not.toHaveAttribute('data-prompt');
    });

    // Generated content is not a text node, so it is not in `textContent` — which
    // is the whole reason a prompt is drawn this way rather than as a `<span>`.
    it('keeps the prompt out of the text', async () => {
      const screen = await render(<CodeBlock code={'a'} prompt="$" data-testid="block" />);

      expect(screen.getByTestId('block').element().textContent).not.toContain('$');
    });
  });

  describe('marked lines', () => {
    const marks = (root: Element) =>
      [...root.querySelectorAll('.neba-code-line')].map((line) => line.hasAttribute('data-mark'));

    it('marks one line from a number', async () => {
      const screen = await render(
        <CodeBlock code={'a\nb\nc'} highlightLines={2} data-testid="block" />
      );

      expect(marks(screen.getByTestId('block').element())).toEqual([false, true, false]);
    });

    it('marks a range from a string', async () => {
      const screen = await render(
        <CodeBlock code={'a\nb\nc\nd'} highlightLines="2-3" data-testid="block" />
      );

      expect(marks(screen.getByTestId('block').element())).toEqual([false, true, true, false]);
    });

    it('takes a list of lines and ranges', async () => {
      const screen = await render(
        <CodeBlock code={'a\nb\nc\nd\ne'} highlightLines="1,3-4" data-testid="block" />
      );

      expect(marks(screen.getByTestId('block').element())).toEqual([
        true,
        false,
        true,
        true,
        false
      ]);
    });

    it('takes an array mixing the two', async () => {
      const screen = await render(
        <CodeBlock code={'a\nb\nc\nd'} highlightLines={[1, '3-4']} data-testid="block" />
      );

      expect(marks(screen.getByTestId('block').element())).toEqual([true, false, true, true]);
    });

    // The reader who typed `3-2` meant the same two lines.
    it('reads a backwards range the way it was meant', async () => {
      const screen = await render(
        <CodeBlock code={'a\nb\nc'} highlightLines="3-2" data-testid="block" />
      );

      expect(marks(screen.getByTestId('block').element())).toEqual([false, true, true]);
    });

    // A marked line is an annotation, and a typo in one should cost the
    // annotation rather than the code.
    it('drops what it cannot read rather than throwing', async () => {
      const screen = await render(
        <CodeBlock code={'a\nb'} highlightLines="two, 2" data-testid="block" />
      );

      expect(marks(screen.getByTestId('block').element())).toEqual([false, true]);
    });

    // They are counted the way the gutter counts, or an excerpt starting at 286
    // would need its marks written in a numbering nobody can see.
    it('counts from startLine', async () => {
      const screen = await render(
        <CodeBlock
          code={'a\nb\nc'}
          lineNumbers
          startLine={286}
          highlightLines={287}
          data-testid="block"
        />
      );

      expect(marks(screen.getByTestId('block').element())).toEqual([false, true, false]);
    });

    it('marks nothing when it is not asked to', async () => {
      const screen = await render(<CodeBlock code={'a\nb'} data-testid="block" />);

      expect(marks(screen.getByTestId('block').element())).toEqual([false, false]);
    });
  });

  /** The current selection, with the line endings every browser agrees on. */
  function selection(): string {
    return String(window.getSelection()).replace(/\r\n/g, '\n').replace(/\n$/, '');
  }

  describe('selecting', () => {
    /*
      A reader who tabbed to a code block and pressed the shortcut every editor
      has meant *this* code, not the article around it — so the block answers
      the key itself and stops the browser selecting the page.
    */
    it('selects the code and nothing else on Ctrl+A', async () => {
      const screen = await render(<CodeBlock code={'const a = 1;\nconst b = 2;'} />);
      const region = screen.getByRole('region', { name: 'Code' }).element() as HTMLElement;

      region.focus();

      const event = new KeyboardEvent('keydown', {
        key: 'a',
        ctrlKey: true,
        bubbles: true,
        cancelable: true
      });

      region.dispatchEvent(event);

      expect(event.defaultPrevented).toBe(true);
      // Normalised, because what is being claimed is *which* text ended up
      // selected and not how a browser spells the gap between two block-level
      // lines while stringifying a range: WebKit puts a newline after the last
      // one and Firefox on Windows separates them with CRLF.
      expect(selection()).toBe('const a = 1;\nconst b = 2;');
    });

    it('leaves a plain A alone', async () => {
      const screen = await render(<CodeBlock code="const a = 1;" />);
      const region = screen.getByRole('region', { name: 'Code' }).element() as HTMLElement;

      region.focus();
      window.getSelection()?.removeAllRanges();

      const event = new KeyboardEvent('keydown', { key: 'a', bubbles: true, cancelable: true });
      region.dispatchEvent(event);

      expect(event.defaultPrevented).toBe(false);
      expect(String(window.getSelection())).toBe('');
    });
  });

  describe('appearance', () => {
    it('wears the theme it was given', async () => {
      const screen = await render(<CodeBlock code={SOURCE} data-testid="block" />);

      expect(screen.getByTestId('block').element()).toHaveAttribute('data-code-theme', 'dark');

      await screen.rerender(<CodeBlock code={SOURCE} theme="dracula" data-testid="block" />);

      expect(screen.getByTestId('block').element()).toHaveAttribute('data-code-theme', 'dracula');
    });

    // A theme is a set of custom properties under a `[data-code-theme]`
    // selector and nothing else, so a name the library never heard of is a name
    // the consumer's own stylesheet can answer.
    it('passes a name of its own through', async () => {
      const screen = await render(<CodeBlock code={SOURCE} theme="ours" data-testid="block" />);

      expect(screen.getByTestId('block').element()).toHaveAttribute('data-code-theme', 'ours');
    });

    it('marks itself as wrapping only when it is', async () => {
      const screen = await render(<CodeBlock code={SOURCE} data-testid="block" />);

      expect(screen.getByTestId('block').element()).not.toHaveAttribute('data-code-wrap');

      await screen.rerender(<CodeBlock code={SOURCE} wrap data-testid="block" />);

      expect(screen.getByTestId('block').element()).toHaveAttribute('data-code-wrap', 'true');
    });

    it('takes the type settings it was handed', async () => {
      const screen = await render(
        <CodeBlock
          code={SOURCE}
          fontFamily="Iosevka"
          fontSize={15}
          lineHeight={2}
          letterSpacing="0.04em"
          data-testid="block"
        />
      );
      const root = screen.getByTestId('block').element() as HTMLElement;

      expect(root.style.fontFamily).toBe('Iosevka');
      expect(root.style.fontSize).toBe('15px');
      expect(root.style.lineHeight).toBe('2');
      expect(root.style.letterSpacing).toBe('0.04em');
    });

    it('bounds its height when it is told to', async () => {
      const screen = await render(<CodeBlock code={SOURCE} maxHeight={120} data-testid="block" />);
      const region = screen.getByTestId('block').element().querySelector('[role="region"]');

      expect((region as HTMLElement).style.maxHeight).toBe('120px');
    });
  });

  describe('accessibility', () => {
    // A region that scrolls has to be reachable by a keyboard with no pointer to
    // drag with, and a focusable region has to have a name.
    it('names the scrollable region after the title', async () => {
      const screen = await render(<CodeBlock code={SOURCE} title="answer.ts" />);
      const region = screen.getByRole('region', { name: 'answer.ts' });

      await expect.element(region).toHaveAttribute('tabindex', '0');
    });

    it('falls back to the language, and then to the word for code', async () => {
      const screen = await render(<CodeBlock code={SOURCE} language="ts" />);

      await expect.element(screen.getByRole('region', { name: 'typescript' })).toBeInTheDocument();

      await screen.rerender(<CodeBlock code={SOURCE} />);

      await expect.element(screen.getByRole('region', { name: 'Code' })).toBeInTheDocument();
    });

    it('says the raw toggle is pressed while it is', async () => {
      const screen = await render(<CodeBlock code={SOURCE} language="ts" rawToggle />);
      const toggle = screen.getByRole('button', { name: 'Raw' });

      await expect.element(toggle).toHaveAttribute('aria-pressed', 'false');

      await toggle.click();

      await expect.element(toggle).toHaveAttribute('aria-pressed', 'true');
    });

    it('says its own words in the locale it was given', async () => {
      const screen = await render(<CodeBlock code={SOURCE} locale="ko" />);

      await expect.element(screen.getByRole('button', { name: '복사' })).toBeInTheDocument();
    });

    it('takes a label written out over the locale', async () => {
      const screen = await render(<CodeBlock code={SOURCE} copyLabel="Grab it" />);

      await expect.element(screen.getByRole('button', { name: 'Grab it' })).toBeInTheDocument();
    });
  });
});
