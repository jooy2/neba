import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button, Spoiler } from 'neba';
import { ko, zhHant, registerMessages } from 'neba/locales';

/* The library ships English; a `locale` prop answers for a language the
   project has registered. These assertions are about the prop, so the
   languages they name are registered here the way a consumer would. */
registerMessages('ko', ko);
registerMessages('zh-hant', zhHant);

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

    /*
     * The cover keeps its place in the grid once it is uncovered, and only
     * gives up the paint and the tab stop. A cover is a notice and a button and
     * is routinely taller than the line it covers, so one that leaves takes its
     * own height with it — and the box shrinks under the press that revealed
     * it, moving every word on the page below.
     *
     * Structure rather than pixels, for the reason the way-back lane below
     * gives: a component test loads no CSS, so `invisible` does nothing here
     * and only `inert` is observable.
     */
    it('holds the cover in place once the content is out', async () => {
      const screen = await render(<Spoiler data-testid="spoiler">Secret</Spoiler>);
      const root = screen.getByTestId('spoiler').element();
      const cover = root.lastElementChild;

      expect(cover).not.toHaveClass('invisible');
      expect(cover).not.toHaveAttribute('inert');

      await screen.getByRole('button', { name: 'Reveal' }).click();

      expect(root.lastElementChild).toBe(cover);
      expect(cover).toHaveClass('invisible');
      expect(cover).toHaveAttribute('inert');
    });

    it('starts uncovered when it is told to', async () => {
      const screen = await render(
        <Spoiler defaultRevealed data-testid="spoiler">
          Secret
        </Spoiler>
      );
      const root = screen.getByTestId('spoiler').element();

      expect(root.firstElementChild).not.toHaveAttribute('inert');
      expect(root.lastElementChild).toHaveAttribute('inert');
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

    /*
     * The way back is drawn from the start and only kept out of sight, so the
     * box is the same height covered and uncovered. A row that arrived with the
     * reveal grew the box by a whole button at the moment of the press, and
     * everything below it on the page moved — twice, for anyone who covered it
     * again.
     *
     * Structure rather than pixels: a component test loads no CSS, so the
     * `invisible` class does nothing here and only `inert` is observable. The
     * heights were measured against the real stylesheet by hand.
     */
    it('holds the way back open while the content is still covered', async () => {
      const screen = await render(
        <Spoiler reversible data-testid="spoiler">
          Secret
        </Spoiler>
      );
      const root = screen.getByTestId('spoiler').element();
      const lane = root.children[1];

      expect(lane).toHaveClass('invisible');
      expect(lane).toHaveAttribute('inert');

      await screen.getByRole('button', { name: 'Reveal' }).click();

      expect(root.children[1]).toBe(lane);
      expect(lane).not.toHaveClass('invisible');
      expect(lane).not.toHaveAttribute('inert');
    });

    // The cover is a grid item over every row rather than an `absolute inset-0`
    // layer, so a cover taller than what it covers pushes the box out instead of
    // losing its own button off the bottom edge.
    it('lays the cover out in the grid rather than over it', async () => {
      const screen = await render(
        <Spoiler reversible data-testid="spoiler">
          Secret
        </Spoiler>
      );
      const root = screen.getByTestId('spoiler').element() as HTMLElement;
      const cover = root.lastElementChild as HTMLElement;

      expect(root).toHaveClass('grid');
      expect(cover).not.toHaveClass('absolute');
      expect(cover.style.gridRow).toBe('1 / -1');
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
