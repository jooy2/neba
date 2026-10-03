import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { TextLink } from 'neba';
import { ko, zhHant, registerMessages } from 'neba/locales';

/* The library ships English; a `locale` prop answers for a language the
   project has registered. These assertions are about the prop, so the
   languages they name are registered here the way a consumer would. */
registerMessages('ko', ko);
registerMessages('zh-hant', zhHant);

describe('TextLink', () => {
  describe('rendering', () => {
    it('renders an anchor carrying its href', async () => {
      const screen = await render(<TextLink href="/docs">Docs</TextLink>);
      const element = screen.getByRole('link', { name: 'Docs' }).element();

      expect(element.tagName).toBe('A');
      expect(element).toHaveAttribute('href', '/docs');
    });

    it('reflects a changed href on re-render', async () => {
      const screen = await render(<TextLink href="/one">Go</TextLink>);

      await screen.rerender(<TextLink href="/two">Go</TextLink>);

      expect(screen.getByRole('link').element()).toHaveAttribute('href', '/two');
    });

    it('writes no href whose scheme could run a script', async () => {
      const screen = await render(<TextLink href="JavaScript:alert(1)">Go</TextLink>);

      await expect.element(screen.getByText('Go')).toBeInTheDocument();
      expect(screen.container.querySelector('a')).not.toHaveAttribute('href');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <TextLink href="/docs" className="my-own-class">
          Docs
        </TextLink>
      );

      expect(screen.getByRole('link').element()).toHaveClass('my-own-class');
    });

    it('forwards unknown props to the anchor', async () => {
      const screen = await render(
        <TextLink href="/docs" download="notes.txt">
          Docs
        </TextLink>
      );

      expect(screen.getByRole('link').element()).toHaveAttribute('download', 'notes.txt');
    });

    it('renders something else entirely through render', async () => {
      const screen = await render(
        <TextLink href="/docs" render={<button type="button" />}>
          Docs
        </TextLink>
      );

      expect(screen.getByRole('button', { name: 'Docs' }).element().tagName).toBe('BUTTON');
    });
  });

  describe('newTab', () => {
    it('opens in a new tab with the rel that closes window.opener', async () => {
      const screen = await render(
        <TextLink href="https://example.com" newTab>
          Example
        </TextLink>
      );
      const element = screen.getByRole('link').element();

      expect(element).toHaveAttribute('target', '_blank');
      expect(element.getAttribute('rel')).toContain('noopener');
    });

    /*
     * `rel="nofollow"` beside `newTab` is a normal thing to write — it is an SEO
     * decision, not a security one — and as a plain override it would take
     * `noopener` off a link that still opens a new window.
     */
    it('keeps noopener when the caller writes a rel of their own', async () => {
      const screen = await render(
        <TextLink href="https://example.com" newTab rel="nofollow">
          Example
        </TextLink>
      );
      const rel = screen.getByRole('link').element().getAttribute('rel') ?? '';

      expect(rel.split(' ').sort()).toEqual(['nofollow', 'noopener', 'noreferrer']);
    });

    it('does not repeat a token the caller already wrote', async () => {
      const screen = await render(
        <TextLink href="https://example.com" newTab rel="noopener sponsored">
          Example
        </TextLink>
      );
      const rel = screen.getByRole('link').element().getAttribute('rel') ?? '';

      expect(rel.split(' ').sort()).toEqual(['noopener', 'noreferrer', 'sponsored']);
    });

    it('protects a target written by hand as it does newTab', async () => {
      const screen = await render(
        <TextLink href="https://example.com" target="_blank" rel="nofollow">
          Example
        </TextLink>
      );
      const element = screen.getByRole('link').element();
      const rel = element.getAttribute('rel') ?? '';

      expect(element).toHaveAttribute('target', '_blank');
      expect(rel.split(' ').sort()).toEqual(['nofollow', 'noopener', 'noreferrer']);
    });

    it('leaves a rel alone on a link that stays in the tab', async () => {
      const screen = await render(
        <TextLink href="/docs" rel="nofollow">
          Docs
        </TextLink>
      );

      expect(screen.getByRole('link').element()).toHaveAttribute('rel', 'nofollow');
    });

    it('sets neither target nor rel by default', async () => {
      const screen = await render(<TextLink href="/docs">Docs</TextLink>);
      const element = screen.getByRole('link').element();

      expect(element).not.toHaveAttribute('target');
      expect(element).not.toHaveAttribute('rel');
    });

    it('says so where only a screen reader will hear it', async () => {
      const screen = await render(
        <TextLink href="https://example.com" newTab>
          Example
        </TextLink>
      );

      await expect.element(screen.getByText('(opens in a new tab)')).toBeInTheDocument();
    });

    it('says so for a target written by hand, without drawing the glyph', async () => {
      const screen = await render(
        <TextLink href="https://example.com" target="_blank">
          Example
        </TextLink>
      );

      await expect
        .element(screen.getByRole('link', { name: 'Example (opens in a new tab)' }))
        .toBeInTheDocument();
      expect(screen.getByRole('link').element().querySelector('svg')).toBeNull();
    });

    it('says nothing for a target that stays in the tab', async () => {
      const screen = await render(
        <TextLink href="/docs" target="_self">
          Docs
        </TextLink>
      );

      await expect.element(screen.getByRole('link', { name: 'Docs' })).toBeInTheDocument();
    });

    it('says so in the language it was given', async () => {
      const screen = await render(
        <TextLink href="https://example.com" newTab locale="ko">
          예시
        </TextLink>
      );

      await expect.element(screen.getByText('(새 창에서 열림)')).toBeInTheDocument();
    });

    it('falls back to English for a language it does not know', async () => {
      const screen = await render(
        <TextLink href="https://example.com" newTab locale="xx-YY">
          Example
        </TextLink>
      );

      await expect.element(screen.getByText('(opens in a new tab)')).toBeInTheDocument();
    });

    it('resolves a regional tag to its language', async () => {
      const screen = await render(
        <TextLink href="https://example.com" newTab locale="ko-KR">
          예시
        </TextLink>
      );

      await expect.element(screen.getByText('(새 창에서 열림)')).toBeInTheDocument();
    });

    it('tells the two Chinese scripts apart by region alone', async () => {
      const screen = await render(
        <TextLink href="https://example.com" newTab locale="zh-TW">
          範例
        </TextLink>
      );

      await expect.element(screen.getByText('(在新分頁中開啟)')).toBeInTheDocument();
    });

    /*
     * The space between the label and the note has to be inside the hidden
     * span. Left as a text node of the link's own, it is laid out after the
     * glyph and the next word of the sentence lands a space away from the link.
     */
    it.each([
      ['newTab', { newTab: true }],
      ['newTab without the glyph', { newTab: true, icon: false }],
      ['a target written by hand', { target: '_blank' }]
    ])('leaves no space of its own after the label for %s', async (_, extra) => {
      const screen = await render(
        <TextLink href="https://example.com" data-testid="link" {...extra}>
          Example
        </TextLink>
      );
      const loose = Array.from(screen.getByTestId('link').element().childNodes).filter(
        (node) => node.nodeType === Node.TEXT_NODE && node.textContent?.trim() === ''
      );

      expect(loose).toHaveLength(0);
    });

    it('keeps the label and the note two words apart', async () => {
      const screen = await render(
        <>
          <TextLink href="https://example.com" newTab>
            Example
          </TextLink>
          <TextLink href="https://example.com" newTab locale="ko">
            예시
          </TextLink>
        </>
      );

      await expect
        .element(screen.getByRole('link', { name: 'Example (opens in a new tab)' }))
        .toBeInTheDocument();
      await expect
        .element(screen.getByRole('link', { name: '예시 (새 창에서 열림)' }))
        .toBeInTheDocument();
    });
  });

  describe('icon', () => {
    it('draws a glyph for a link that opens a new tab', async () => {
      const screen = await render(
        <TextLink href="https://example.com" newTab data-testid="link">
          Example
        </TextLink>
      );

      expect(screen.getByTestId('link').element().querySelector('svg')).not.toBeNull();
    });

    it('draws none for an ordinary link', async () => {
      const screen = await render(
        <TextLink href="/docs" data-testid="link">
          Docs
        </TextLink>
      );

      expect(screen.getByTestId('link').element().querySelector('svg')).toBeNull();
    });

    it('can be asked for without a new tab', async () => {
      const screen = await render(
        <TextLink href="/docs" icon data-testid="link">
          Docs
        </TextLink>
      );

      expect(screen.getByTestId('link').element().querySelector('svg')).not.toBeNull();
    });

    it('can be turned off on a new-tab link', async () => {
      const screen = await render(
        <TextLink href="https://example.com" newTab icon={false} data-testid="link">
          Example
        </TextLink>
      );

      expect(screen.getByTestId('link').element().querySelector('svg')).toBeNull();
    });

    it('takes a glyph of its own', async () => {
      const screen = await render(
        <TextLink href="/docs" icon={<span data-testid="mark">↗</span>}>
          Docs
        </TextLink>
      );

      await expect.element(screen.getByTestId('mark')).toBeInTheDocument();
    });
  });

  describe('style props', () => {
    it('takes no colour family unless one is asked for', async () => {
      const screen = await render(<TextLink href="/docs">Docs</TextLink>);
      const element = screen.getByRole('link').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-accent')).toBe('');
      expect(element).toHaveClass('[&.neba-link]:text-inherit');
    });

    it('maps color onto the accent slot', async () => {
      const screen = await render(
        <TextLink href="/docs" color="danger">
          Docs
        </TextLink>
      );
      const element = screen.getByRole('link').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-danger-accent)');
      expect(element.style.getPropertyValue('--n-ring')).toBe('var(--neba-danger-ring)');
    });

    // The ring is written as the `outline` shorthand, and an undefined `var()`
    // inside one makes the browser drop the whole declaration — an uncoloured
    // link would lose its focus ring rather than fall back to something plainer.
    it('keeps a focus ring colour even with no colour family', async () => {
      const screen = await render(<TextLink href="/docs">Docs</TextLink>);
      const element = screen.getByRole('link').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-ring')).toBe('var(--neba-primary-ring)');
    });

    // The utilities are written through `[&.neba-link]` on purpose: a host
    // stylesheet's `a` rule is a class plus a type, which outranks a plain
    // one-class utility, and colour and underline are the whole of what a
    // TextLink is.
    it('underlines by default and drops the line when told to', async () => {
      const screen = await render(<TextLink href="/docs">Docs</TextLink>);

      expect(screen.getByRole('link').element()).toHaveClass('[&.neba-link]:underline');

      await screen.rerender(
        <TextLink href="/docs" underline="none">
          Docs
        </TextLink>
      );

      expect(screen.getByRole('link').element()).toHaveClass('[&.neba-link]:no-underline');
    });

    // The guard outranks a caller's one-class utility as surely as it does the
    // host, so what the caller's `className` sets is stated at zero specificity
    // instead. Measured in `test/styles/class-overrides.test.tsx`.
    it('moves the colour and the line a caller sets off the guard', async () => {
      const screen = await render(
        <TextLink href="/docs" className="text-red-600 no-underline">
          Docs
        </TextLink>
      );
      const element = screen.getByRole('link').element();

      expect(element).toHaveClass('[:where(&)]:text-inherit');
      expect(element).toHaveClass('[:where(&)]:underline');
      expect(element).not.toHaveClass('[&.neba-link]:text-inherit');
      expect(element).not.toHaveClass('[&.neba-link]:underline');

      await screen.rerender(
        <TextLink href="/docs" color="primary" underline="hover" className="hover:text-red-600">
          Docs
        </TextLink>
      );

      expect(element).toHaveClass('[:where(&)]:text-(--n-accent)');
      // The line was not touched, so it keeps its guard.
      expect(element).toHaveClass('[&.neba-link]:hover:underline');
    });

    it('moves the weight and the shape of the line a caller sets off the guard', async () => {
      const screen = await render(<TextLink href="/docs">Docs</TextLink>);
      const link = () => screen.getByRole('link').element();

      expect(link()).toHaveClass('[&.neba-link]:[font-weight:inherit]');
      expect(link()).toHaveClass('[&.neba-link]:underline-offset-[0.2em]');
      expect(link()).toHaveClass('[&.neba-link]:decoration-(--n-underline)');

      await screen.rerender(
        <TextLink href="/docs" className="font-medium decoration-2 underline-offset-4">
          Docs
        </TextLink>
      );

      expect(link()).toHaveClass('[:where(&)]:[font-weight:inherit]');
      expect(link()).toHaveClass('[:where(&)]:[text-decoration-thickness:max(1px,0.055em)]');
      expect(link()).toHaveClass('[:where(&)]:underline-offset-[0.2em]');
      // The colour of the line was not touched, so it keeps its guard.
      expect(link()).toHaveClass('[&.neba-link]:decoration-(--n-underline)');
    });

    it('keeps the guard under an important class', async () => {
      const screen = await render(
        <TextLink href="/docs" className="text-red-600!">
          Docs
        </TextLink>
      );

      expect(screen.getByRole('link').element()).toHaveClass('[&.neba-link]:text-inherit');
    });

    it('carries the hook a host stylesheet can exempt', async () => {
      const screen = await render(<TextLink href="/docs">Docs</TextLink>);

      expect(screen.getByRole('link').element()).toHaveClass('neba-link');
    });
  });
});
