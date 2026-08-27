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

    it('carries the hook a host stylesheet can exempt', async () => {
      const screen = await render(<TextLink href="/docs">Docs</TextLink>);

      expect(screen.getByRole('link').element()).toHaveClass('neba-link');
    });
  });
});
