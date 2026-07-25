import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Typography } from 'neba';

describe('Typography', () => {
  describe('levels', () => {
    it('renders a paragraph by default', async () => {
      const screen = await render(<Typography>Body copy</Typography>);
      const element = screen.getByText('Body copy').element();

      expect(element.tagName).toBe('P');
    });

    it('renders the matching heading element for a heading level', async () => {
      const screen = await render(<Typography level="h2">Invoices</Typography>);

      await expect
        .element(screen.getByRole('heading', { level: 2, name: 'Invoices' }))
        .toBeInTheDocument();
    });

    it('renders a span for the two quiet levels', async () => {
      const screen = await render(<Typography level="caption">Updated today</Typography>);

      expect(screen.getByText('Updated today').element().tagName).toBe('SPAN');
    });

    it('gives each level its own type scale', async () => {
      const screen = await render(<Typography level="h1">Title</Typography>);
      const element = screen.getByText('Title').element();

      expect(element).toHaveClass('text-[1.875rem]/[2.25rem]');

      await screen.rerender(<Typography level="h3">Title</Typography>);

      expect(screen.getByText('Title').element()).toHaveClass('text-[1.25rem]/[1.625rem]');
    });

    it('changes the element as well as the scale on re-render', async () => {
      const screen = await render(<Typography level="body">Text</Typography>);

      expect(screen.getByText('Text').element().tagName).toBe('P');

      await screen.rerender(<Typography level="h4">Text</Typography>);

      expect(screen.getByText('Text').element().tagName).toBe('H4');
    });
  });

  describe('render prop', () => {
    it('keeps the type scale while changing the element', async () => {
      const screen = await render(
        <Typography level="h3" render={<p />}>
          Looks like a heading
        </Typography>
      );
      const element = screen.getByText('Looks like a heading').element();

      expect(element.tagName).toBe('P');
      expect(element).toHaveClass('text-[1.25rem]/[1.625rem]');
    });
  });

  describe('style props', () => {
    it('inherits the page foreground when no colour role is asked for', async () => {
      const screen = await render(<Typography>Body</Typography>);
      const element = screen.getByText('Body').element() as HTMLElement;

      expect(element).toHaveClass('text-(--neba-fg)');
      expect(element.style.getPropertyValue('--n-accent')).toBe('');
    });

    it('maps a colour role onto the accent slot', async () => {
      const screen = await render(<Typography color="danger">Failed</Typography>);
      const element = screen.getByText('Failed').element() as HTMLElement;

      expect(element).toHaveClass('text-(--n-accent)');
      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-danger-accent)');
    });

    it('mutes the caption and overline levels', async () => {
      const screen = await render(<Typography level="caption">Note</Typography>);

      expect(screen.getByText('Note').element()).toHaveClass('text-(--neba-muted-fg)');
    });

    it('emits exactly one font weight class', async () => {
      const screen = await render(
        <Typography level="h2" weight="regular">
          Quiet heading
        </Typography>
      );
      const classes = [...screen.getByText('Quiet heading').element().classList];

      expect(classes.filter((name) => name.startsWith('font-'))).toEqual(['font-normal']);
    });

    it('takes the level weight when no override is given', async () => {
      const screen = await render(<Typography level="h2">Heading</Typography>);
      const classes = [...screen.getByText('Heading').element().classList];

      expect(classes.filter((name) => name.startsWith('font-'))).toEqual(['font-semibold']);
    });

    it('truncates to one line and clamps to more', async () => {
      const screen = await render(
        <Typography lines={1} data-testid="text">
          Long
        </Typography>
      );

      expect(screen.getByTestId('text').element()).toHaveClass('truncate');

      await screen.rerender(
        <Typography lines={3} data-testid="text">
          Long
        </Typography>
      );

      expect(screen.getByTestId('text').element()).toHaveClass('line-clamp-3');
    });

    it('adds no margin unless asked', async () => {
      const screen = await render(<Typography level="h2">Heading</Typography>);

      expect(screen.getByText('Heading').element()).not.toHaveClass('mb-3.5');

      await screen.rerender(
        <Typography level="h2" gutter>
          Heading
        </Typography>
      );

      expect(screen.getByText('Heading').element()).toHaveClass('mb-3.5');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Typography className="my-own-class">Body</Typography>);

      expect(screen.getByText('Body').element()).toHaveClass('my-own-class');
    });

    it('forwards unknown props to the element', async () => {
      const screen = await render(<Typography id="lede">Body</Typography>);

      expect(screen.getByText('Body').element()).toHaveAttribute('id', 'lede');
    });
  });
});
