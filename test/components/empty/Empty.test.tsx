import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button, Empty } from 'neba';

describe('Empty', () => {
  describe('rendering', () => {
    // A list that empties under the reader has no other way to say so: nothing
    // was removed from the page, something was added to it.
    it('renders a live region with the default headline', async () => {
      const screen = await render(<Empty />);

      await expect.element(screen.getByRole('status')).toHaveTextContent('Nothing here');
    });

    it('renders the detail under the headline', async () => {
      const screen = await render(<Empty title="No results">Try a different search term.</Empty>);

      await expect.element(screen.getByText('No results')).toBeInTheDocument();
      await expect.element(screen.getByText('Try a different search term.')).toBeInTheDocument();
    });

    it('reflects a changed detail on re-render', async () => {
      const screen = await render(<Empty>Before</Empty>);

      await screen.rerender(<Empty>After</Empty>);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('renders something else through render', async () => {
      const screen = await render(<Empty render={<section />} />);

      expect(screen.getByRole('status').element().tagName).toBe('SECTION');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Empty className="my-own-class" />);

      expect(screen.getByRole('status').element()).toHaveClass('my-own-class');
    });

    // A state that is simply part of the page on arrival has nothing to announce.
    it('gives up the live region when the role is cleared', async () => {
      const screen = await render(<Empty role={undefined} data-testid="empty" />);

      expect(screen.getByRole('status').query()).toBeNull();
      await expect.element(screen.getByTestId('empty')).toBeInTheDocument();
    });
  });

  describe('title', () => {
    it('takes a headline of its own', async () => {
      const screen = await render(<Empty title="Your inbox is empty" />);

      await expect.element(screen.getByText('Your inbox is empty')).toBeInTheDocument();
      expect(screen.getByText('Nothing here').query()).toBeNull();
    });

    it('drops the headline when asked', async () => {
      const screen = await render(<Empty title={false}>Nothing matched that filter.</Empty>);

      expect(screen.getByText('Nothing here').query()).toBeNull();
      await expect.element(screen.getByText('Nothing matched that filter.')).toBeInTheDocument();
    });

    it('reflects a changed headline on re-render', async () => {
      const screen = await render(<Empty title="No results" />);

      await screen.rerender(<Empty title="No matches" />);

      await expect.element(screen.getByText('No matches')).toBeInTheDocument();
    });
  });

  describe('locale', () => {
    it('writes the default headline in the language it was given', async () => {
      const screen = await render(<Empty locale="ko" />);

      await expect.element(screen.getByRole('status')).toHaveTextContent('내용이 없습니다');
    });

    it('resolves a regional tag through its language', async () => {
      const screen = await render(<Empty locale="pt-BR" />);

      await expect.element(screen.getByRole('status')).toHaveTextContent('Nada por aqui');
    });

    it('falls back to English for a language it does not have', async () => {
      const screen = await render(<Empty locale="fi" />);

      await expect.element(screen.getByRole('status')).toHaveTextContent('Nothing here');
    });

    it('is ignored once a title is given', async () => {
      const screen = await render(<Empty locale="ko" title="No results" />);

      await expect.element(screen.getByRole('status')).toHaveTextContent('No results');
    });
  });

  describe('icon', () => {
    it('draws a glyph by default', async () => {
      const screen = await render(<Empty />);

      expect(screen.getByRole('status').element().querySelector('svg')).not.toBeNull();
    });

    it('drops the glyph when asked', async () => {
      const screen = await render(<Empty icon={false} />);

      expect(screen.getByRole('status').element().querySelector('svg')).toBeNull();
    });

    it('takes a glyph of its own', async () => {
      const screen = await render(<Empty icon={<span data-testid="my-icon">?</span>} />);

      await expect.element(screen.getByTestId('my-icon')).toBeInTheDocument();
      expect(screen.getByRole('status').element().querySelector('svg')).toBeNull();
    });

    // The glyph names nothing the headline does not already say.
    it('hides the default glyph from the accessibility tree', async () => {
      const screen = await render(<Empty />);

      expect(screen.getByRole('status').element().querySelector('svg')).toHaveAttribute(
        'aria-hidden',
        'true'
      );
    });
  });

  describe('action', () => {
    it('renders what it is given', async () => {
      const screen = await render(<Empty action={<Button>Create a project</Button>} />);

      await expect
        .element(screen.getByRole('button', { name: 'Create a project' }))
        .toBeInTheDocument();
    });

    it('renders nothing when it is not given anything', async () => {
      const screen = await render(<Empty />);

      expect(screen.getByRole('button').query()).toBeNull();
    });

    it('holds more than one', async () => {
      const screen = await render(
        <Empty
          action={
            <>
              <Button>Clear filters</Button>
              <Button variant="text">Learn more</Button>
            </>
          }
        />
      );

      await expect
        .element(screen.getByRole('button', { name: 'Clear filters' }))
        .toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Learn more' })).toBeInTheDocument();
    });
  });

  describe('variant', () => {
    // An empty state is nearly always already inside something, and a second
    // rectangle drawn inside the first is one rectangle too many.
    it('draws no surface by default', async () => {
      const screen = await render(<Empty />);

      expect(screen.getByRole('status').element()).toHaveClass('bg-transparent');
    });

    it('draws a hairline for outline', async () => {
      const screen = await render(<Empty variant="outline" />);

      expect(screen.getByRole('status').element()).toHaveClass('border');
      expect(screen.getByRole('status').element()).toHaveClass('bg-(--n-panel)');
    });

    it('reflects a changed variant on re-render', async () => {
      const screen = await render(<Empty variant="text" />);

      await screen.rerender(<Empty variant="solid" />);

      expect(screen.getByRole('status').element()).toHaveClass('bg-(--n-panel-hover)');
    });
  });

  describe('size and density', () => {
    it('pads on its own vertical ladder', async () => {
      const screen = await render(<Empty />);

      expect(screen.getByRole('status').element()).toHaveClass('py-8');
      expect(screen.getByRole('status').element()).toHaveClass('px-4');
    });

    it('takes the compact track when asked', async () => {
      const screen = await render(<Empty density="compact" />);

      expect(screen.getByRole('status').element()).toHaveClass('py-4');
      expect(screen.getByRole('status').element()).toHaveClass('px-2.5');
    });

    it('reflects a changed size on re-render', async () => {
      const screen = await render(<Empty size="md" />);

      await screen.rerender(<Empty size="lg" />);

      expect(screen.getByRole('status').element()).toHaveClass('py-10');
      expect(screen.getByRole('status').element()).toHaveClass('rounded-(--neba-radius-lg)');
    });
  });

  describe('colour slots', () => {
    // The sheet stays undyed — `action` is somebody else's button and it
    // arrived with its own colours.
    it('points the panel ladder at the neutral steps', async () => {
      const screen = await render(<Empty color="danger" />);
      const style = screen.getByRole('status').element().getAttribute('style') ?? '';

      expect(style).toContain('--n-panel: var(--neba-panel)');
      expect(style).toContain('--n-line: var(--neba-danger-line)');
    });
  });
});
