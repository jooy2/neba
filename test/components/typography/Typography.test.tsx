import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Typography } from 'neba';

describe('Typography', () => {
  describe('levels', () => {
    it('carries the class a host stylesheet reaches it by', async () => {
      // The utilities a level resolves to are not a contract; this is.
      const screen = await render(<Typography>Body copy</Typography>);

      expect(screen.getByText('Body copy').element()).toHaveClass('neba-typography');
    });

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

      expect(element).toHaveClass('[&.neba-typography]:text-[1.875rem]/[1.2]');

      await screen.rerender(<Typography level="h3">Title</Typography>);

      expect(screen.getByText('Title').element()).toHaveClass(
        '[&.neba-typography]:text-[1.25rem]/[1.3]'
      );
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
      expect(element).toHaveClass('[&.neba-typography]:text-[1.25rem]/[1.3]');
    });
  });

  describe('style props', () => {
    // It was pinned to `--neba-fg`, which the docs said it inherited: dark text
    // on a solid Alert's dark fill.
    it('states no ink when no colour role is asked for, so it inherits', async () => {
      const screen = await render(<Typography>Body</Typography>);
      const element = screen.getByText('Body').element() as HTMLElement;

      expect(element.className).not.toContain('text-(');
      expect(element.style.getPropertyValue('--n-accent')).toBe('');
    });

    it('maps a colour role onto the accent slot', async () => {
      const screen = await render(<Typography color="danger">Failed</Typography>);
      const element = screen.getByText('Failed').element() as HTMLElement;

      expect(element).toHaveClass('[&.neba-typography]:text-(--n-accent)');
      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-danger-accent)');
    });

    it('mutes the caption and overline levels', async () => {
      const screen = await render(<Typography level="caption">Note</Typography>);

      expect(screen.getByText('Note').element()).toHaveClass(
        '[&.neba-typography]:text-(--neba-muted-fg)'
      );
    });

    it('emits exactly one font weight class', async () => {
      const screen = await render(
        <Typography level="h2" weight="regular">
          Quiet heading
        </Typography>
      );
      const classes = [...screen.getByText('Quiet heading').element().classList];

      expect(classes.filter((name) => name.includes('font-'))).toEqual([
        '[&.neba-typography]:font-normal'
      ]);
    });

    it('takes the level weight when no override is given', async () => {
      const screen = await render(<Typography level="h2">Heading</Typography>);
      const classes = [...screen.getByText('Heading').element().classList];

      expect(classes.filter((name) => name.includes('font-'))).toEqual([
        '[&.neba-typography]:font-semibold'
      ]);
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

      const element = screen.getByTestId('text').element() as HTMLElement;

      expect(element).toHaveClass('line-clamp-(--n-lines)');
      expect(element).not.toHaveClass('truncate');
      expect(element.style.getPropertyValue('--n-lines')).toBe('3');
    });

    // The classes went up to six, so a larger count clamped at six silently.
    it('clamps to a count past six', async () => {
      const screen = await render(
        <Typography lines={8} data-testid="text" style={{ color: 'red' }}>
          Long
        </Typography>
      );

      const element = screen.getByTestId('text').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-lines')).toBe('8');
      expect(element.style.color).toBe('red');
    });

    it('adds no margin unless asked', async () => {
      const screen = await render(<Typography level="h2">Heading</Typography>);

      // Stated rather than left out: inside `.prose` an unstated margin is the
      // article's, not none.
      expect(screen.getByText('Heading').element()).toHaveClass('[&.neba-typography]:my-0');
      expect(screen.getByText('Heading').element().className).not.toContain('mb-3.5');

      await screen.rerender(
        <Typography level="h2" gutter>
          Heading
        </Typography>
      );

      expect(screen.getByText('Heading').element()).toHaveClass('[&.neba-typography]:mb-3.5');
      expect(screen.getByText('Heading').element().className).not.toContain('my-0');
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

  /* `h1`-`h6` and `p` are the tags a host stylesheet is most certain to have
     styled by name, and `.vp-doc h2` / `.prose h2` reach them at one class plus
     one tag — which a single utility cannot outrank. Everything the scale
     decides is therefore written through `[&.neba-typography]`, which compiles
     to two classes. See the note on `levelClasses`. */
  describe('host specificity', () => {
    it('writes the scale, the weight and the ink through the doubled class', async () => {
      const screen = await render(
        <Typography level="h2" color="primary" gutter>
          Heading
        </Typography>
      );
      const element = screen.getByText('Heading').element();
      const plain = [...element.classList].filter(
        (name) => !name.startsWith('[&.neba-typography]:') && name !== 'neba-typography'
      );

      expect(element).toHaveClass('neba-typography');
      expect(plain).toEqual([]);
    });

    it('leaves align and clamp as plain utilities', async () => {
      // Nothing styles `text-align` or a line clamp on a heading by tag name, so
      // these stay where a one-class `className` can still reach them.
      const screen = await render(
        <Typography level="h2" align="center" lines={2}>
          Heading
        </Typography>
      );
      const classes = [...screen.getByText('Heading').element().classList];

      expect(classes).toContain('text-center');
      expect(classes).toContain('line-clamp-(--n-lines)');
    });
  });

  describe('transition', () => {
    it('takes an entrance animation', async () => {
      const screen = await render(<Typography transition="fade">Body copy</Typography>);
      const element = screen.getByText('Body copy').element() as HTMLElement;

      expect(element).toHaveClass('neba-anim-fade');
    });

    it('keeps the colour slot when it also has an animation', async () => {
      const screen = await render(
        <Typography color="success" transition="fade">
          Body copy
        </Typography>
      );
      const element = screen.getByText('Body copy').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-success-accent)');
      expect(element.style.getPropertyValue('--n-anim-duration')).toBe('320ms');
    });
  });
});
