import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button, Spoiler } from 'neba';

describe('Spoiler', () => {
  describe('rendering', () => {
    it('holds the content it covers', async () => {
      const screen = await render(<Spoiler>He was the killer</Spoiler>);

      await expect.element(screen.getByText('He was the killer')).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <Spoiler className="my-own-class" data-testid="spoiler">
          Secret
        </Spoiler>
      );

      expect(screen.getByTestId('spoiler').element()).toHaveClass('my-own-class');
    });

    it('forwards unknown props to the root', async () => {
      const screen = await render(
        <Spoiler data-testid="spoiler" id="ending">
          Secret
        </Spoiler>
      );

      expect(screen.getByTestId('spoiler').element()).toHaveAttribute('id', 'ending');
    });
  });

  describe('covering', () => {
    // Blur alone is not cover: the content has to be out of the tab order, off
    // the accessibility tree and out of a select-all as well.
    it('makes the covered content inert', async () => {
      const screen = await render(<Spoiler data-testid="spoiler">Secret</Spoiler>);
      const content = screen.getByTestId('spoiler').element().firstElementChild;

      expect(content).toHaveAttribute('inert');
    });

    it('blurs the covered content', async () => {
      const screen = await render(<Spoiler data-testid="spoiler">Secret</Spoiler>);
      const content = screen.getByTestId('spoiler').element().firstElementChild as HTMLElement;

      expect(content.style.filter).toBe('blur(10px)');
    });

    it('blurs it as hard as it was told to', async () => {
      const screen = await render(
        <Spoiler blur={24} data-testid="spoiler">
          Secret
        </Spoiler>
      );
      const content = screen.getByTestId('spoiler').element().firstElementChild as HTMLElement;

      expect(content.style.filter).toBe('blur(24px)');
    });

    it('clamps the covered box to maxHeight and lets go on reveal', async () => {
      const screen = await render(
        <Spoiler maxHeight={120} data-testid="spoiler">
          Secret
        </Spoiler>
      );
      const content = screen.getByTestId('spoiler').element().firstElementChild as HTMLElement;

      expect(content.style.maxHeight).toBe('120px');

      await screen.getByRole('button', { name: 'Reveal' }).click();

      expect(content.style.maxHeight).toBe('');
    });
  });

  describe('revealing', () => {
    it('uncovers the content when the button is pressed', async () => {
      const screen = await render(<Spoiler data-testid="spoiler">Secret</Spoiler>);

      await screen.getByRole('button', { name: 'Reveal' }).click();

      const content = screen.getByTestId('spoiler').element().firstElementChild as HTMLElement;

      expect(content).not.toHaveAttribute('inert');
      expect(content.style.filter).toBe('');
    });

    it('takes the button away once the content is out', async () => {
      const screen = await render(<Spoiler>Secret</Spoiler>);

      await screen.getByRole('button', { name: 'Reveal' }).click();

      expect(screen.getByRole('button', { name: 'Reveal' }).query()).toBeNull();
    });

    it('starts uncovered when it is told to', async () => {
      const screen = await render(<Spoiler defaultRevealed>Secret</Spoiler>);

      expect(screen.getByRole('button', { name: 'Reveal' }).query()).toBeNull();
    });

    it('reports the change', async () => {
      const onRevealedChange = vi.fn();
      const screen = await render(<Spoiler onRevealedChange={onRevealedChange}>Secret</Spoiler>);

      await screen.getByRole('button', { name: 'Reveal' }).click();

      expect(onRevealedChange).toHaveBeenCalledWith(true);
    });

    // Controlled: the prop decides, and a press that the owner does not act on
    // leaves the content covered.
    it('stays covered while revealed says so', async () => {
      const onRevealedChange = vi.fn();
      const screen = await render(
        <Spoiler revealed={false} onRevealedChange={onRevealedChange} data-testid="spoiler">
          Secret
        </Spoiler>
      );

      await screen.getByRole('button', { name: 'Reveal' }).click();

      expect(onRevealedChange).toHaveBeenCalledWith(true);
      expect(screen.getByTestId('spoiler').element().firstElementChild).toHaveAttribute('inert');
    });

    it('covers it again when reversible', async () => {
      const screen = await render(
        <Spoiler reversible data-testid="spoiler">
          Secret
        </Spoiler>
      );

      await screen.getByRole('button', { name: 'Reveal' }).click();
      await screen.getByRole('button', { name: 'Hide' }).click();

      expect(screen.getByTestId('spoiler').element().firstElementChild).toHaveAttribute('inert');
    });

    it('offers no way back when it is not reversible', async () => {
      const screen = await render(<Spoiler>Secret</Spoiler>);

      await screen.getByRole('button', { name: 'Reveal' }).click();

      expect(screen.getByRole('button', { name: 'Hide' }).query()).toBeNull();
    });

    it('points the button at the content it uncovers', async () => {
      const screen = await render(<Spoiler data-testid="spoiler">Secret</Spoiler>);
      const content = screen.getByTestId('spoiler').element().firstElementChild;
      const button = screen.getByRole('button', { name: 'Reveal' }).element();

      expect(button).toHaveAttribute('aria-controls', content?.id);
      expect(button).toHaveAttribute('aria-expanded', 'false');
    });
  });

  describe('words', () => {
    it('writes its label and notice in English by default', async () => {
      const screen = await render(<Spoiler>Secret</Spoiler>);

      await expect.element(screen.getByRole('button', { name: 'Reveal' })).toBeInTheDocument();
      await expect.element(screen.getByText('This may contain spoilers')).toBeInTheDocument();
    });

    it('writes them in the language it was given', async () => {
      const screen = await render(<Spoiler locale="ko">비밀</Spoiler>);

      await expect.element(screen.getByRole('button', { name: '내용 보기' })).toBeInTheDocument();
      await expect
        .element(screen.getByText('스포일러가 포함되어 있을 수 있습니다'))
        .toBeInTheDocument();
    });

    it('resolves a script subtag', async () => {
      const screen = await render(<Spoiler locale="zh-Hant">祕密</Spoiler>);

      await expect.element(screen.getByRole('button', { name: '顯示內容' })).toBeInTheDocument();
    });

    it('falls back to English for a language it does not know', async () => {
      const screen = await render(<Spoiler locale="xx">Secret</Spoiler>);

      await expect.element(screen.getByRole('button', { name: 'Reveal' })).toBeInTheDocument();
    });

    it('takes words of its own over the locale', async () => {
      const screen = await render(
        <Spoiler locale="ko" label="Show the ending" description="Season 2, episode 6">
          비밀
        </Spoiler>
      );

      await expect
        .element(screen.getByRole('button', { name: 'Show the ending' }))
        .toBeInTheDocument();
      await expect.element(screen.getByText('Season 2, episode 6')).toBeInTheDocument();
      expect(screen.getByText('스포일러가 포함되어 있을 수 있습니다').query()).toBeNull();
    });

    it('writes nothing above the button when description is false', async () => {
      const screen = await render(<Spoiler description={false}>Secret</Spoiler>);

      expect(screen.getByText('This may contain spoilers').query()).toBeNull();
      await expect.element(screen.getByRole('button', { name: 'Reveal' })).toBeInTheDocument();
    });

    it('names the hide button in the same language', async () => {
      const screen = await render(
        <Spoiler locale="ko" reversible defaultRevealed>
          비밀
        </Spoiler>
      );

      await expect.element(screen.getByRole('button', { name: '숨기기' })).toBeInTheDocument();
    });
  });

  describe('action', () => {
    it('replaces the default button with the one it is handed', async () => {
      const onRevealedChange = vi.fn();
      const screen = await render(
        <Spoiler
          revealed={false}
          onRevealedChange={onRevealedChange}
          action={
            <Button variant="text" onClick={() => onRevealedChange(true)}>
              I can take it
            </Button>
          }
        >
          Secret
        </Spoiler>
      );

      expect(screen.getByRole('button', { name: 'Reveal' }).query()).toBeNull();

      await screen.getByRole('button', { name: 'I can take it' }).click();

      expect(onRevealedChange).toHaveBeenCalledWith(true);
    });
  });

  describe('style props', () => {
    it('maps color onto the token slots the styles read from', async () => {
      const screen = await render(
        <Spoiler color="warning" data-testid="spoiler">
          Secret
        </Spoiler>
      );
      const element = screen.getByTestId('spoiler').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-warning-accent)');
      expect(element.style.getPropertyValue('--n-line')).toBe('var(--neba-warning-line)');
    });

    // A container keeps the neutral panel ladder: what it holds arrives with its
    // own colours, and tinting the sheet under them puts every one on a
    // background it was not chosen against.
    it('leaves the panel ladder undyed', async () => {
      const screen = await render(
        <Spoiler color="warning" data-testid="spoiler">
          Secret
        </Spoiler>
      );
      const element = screen.getByTestId('spoiler').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-panel')).toBe('var(--neba-panel)');
    });
  });
});
