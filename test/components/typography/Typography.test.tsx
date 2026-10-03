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
      const title = () => screen.getByText('Title').element() as HTMLElement;

      expect(title().style.getPropertyValue('--n-type-size')).toBe('1.875rem');
      expect(title().style.getPropertyValue('--n-type-leading')).toBe('1.2');
      expect(title()).toHaveClass('[&.neba-typography]:text-(length:--n-type-size)');

      await screen.rerender(<Typography level="h3">Title</Typography>);

      expect(title().style.getPropertyValue('--n-type-size')).toBe('1.25rem');
      expect(title().style.getPropertyValue('--n-type-leading')).toBe('1.3');
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
      expect((element as HTMLElement).style.getPropertyValue('--n-type-size')).toBe('1.25rem');
    });
  });

  describe('style props', () => {
    // It was pinned to `--neba-fg`, which the docs said it inherited: dark text
    // on a solid Alert's dark fill.
    it('states no ink when no colour role is asked for, so it inherits', async () => {
      const screen = await render(<Typography>Body</Typography>);
      const element = screen.getByText('Body').element() as HTMLElement;

      // `text-(length:…)` is the size; an ink would be `text-(--…)`.
      expect(element.className).not.toContain('text-(--');
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
      const element = screen.getByText('Quiet heading').element() as HTMLElement;

      expect([...element.classList].filter((name) => name.includes('font-'))).toEqual([
        '[&.neba-typography]:font-(weight:--n-type-weight)'
      ]);
      expect(element.style.getPropertyValue('--n-type-weight')).toBe(
        'var(--font-weight-normal, 400)'
      );
    });

    it('takes the level weight when no override is given', async () => {
      const screen = await render(<Typography level="h2">Heading</Typography>);
      const element = screen.getByText('Heading').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-type-weight')).toBe(
        'var(--font-weight-semibold, 600)'
      );
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

    // Both levels are spans, where `text-align` and a bottom margin do nothing.
    it('makes a quiet level a block when it is aligned or given a gutter', async () => {
      const screen = await render(<Typography level="caption">Note</Typography>);
      const note = () => screen.getByText('Note').element();

      expect(note()).not.toHaveClass('block');

      await screen.rerender(
        <Typography level="caption" align="center">
          Note
        </Typography>
      );
      expect(note()).toHaveClass('block');

      await screen.rerender(
        <Typography level="overline" gutter>
          Note
        </Typography>
      );
      expect(note()).toHaveClass('block');
    });

    // A clamp of two lines or more is its own box, and a `block` beside it
    // took its `display` away whenever the stylesheet put `block` second.
    it('leaves a multi-line clamp its own display', async () => {
      const screen = await render(
        <Typography level="caption" align="center" lines={2}>
          Note
        </Typography>
      );
      const note = screen.getByText('Note').element();

      expect(note).toHaveClass('line-clamp-(--n-lines)');
      expect(note).not.toHaveClass('block');
    });

    it('adds no margin unless asked', async () => {
      const screen = await render(<Typography level="h2">Heading</Typography>);

      const heading = () => screen.getByText('Heading').element() as HTMLElement;

      // Stated rather than left out: inside `.prose` an unstated margin is the
      // article's, not none.
      expect(heading()).toHaveClass('[&.neba-typography]:mt-0');
      expect(heading()).toHaveClass('[&.neba-typography]:mb-(--n-type-gutter)');
      expect(heading().style.getPropertyValue('--n-type-gutter')).toBe('0');

      await screen.rerender(
        <Typography level="h2" gutter>
          Heading
        </Typography>
      );

      expect(heading().style.getPropertyValue('--n-type-gutter')).toBe(
        'calc(var(--spacing, 0.25rem) * 3.5)'
      );
      expect(heading().className).not.toContain('mt-0');
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

  /* The guard outranks a caller's one-class utility as surely as it outranks
     the host, so a property the caller's `className` sets is stated through
     `[:where(&)]` instead. The computed values are in
     `test/styles/class-overrides.test.tsx`; these are the classes that decide
     them. */
  describe('className', () => {
    const guarded = (element: Element) =>
      [...element.classList].filter((name) => name.startsWith('[&.neba-typography]:'));
    const floored = (element: Element) =>
      [...element.classList].filter((name) => name.startsWith('[:where(&)]:'));

    it('moves a property the caller sets from the guard to the floor', async () => {
      const screen = await render(<Typography className="mb-8">Body</Typography>);
      const element = screen.getByText('Body').element();

      expect(element).toHaveClass('[:where(&)]:mb-(--n-type-gutter)');
      expect(element).not.toHaveClass('[&.neba-typography]:mb-(--n-type-gutter)');
      // The top margin is a property of its own, and keeps its guard.
      expect(element).toHaveClass('[&.neba-typography]:mt-0');
      expect(element).toHaveClass('mb-8');
    });

    it('moves every property a run of classes sets, and only those', async () => {
      const screen = await render(
        <Typography level="h1" className="text-[2.5rem] leading-none font-black tracking-tight">
          42
        </Typography>
      );
      const element = screen.getByText('42').element();

      expect(floored(element)).toEqual([
        '[:where(&)]:text-(length:--n-type-size)',
        '[:where(&)]:leading-(--n-type-leading)',
        '[:where(&)]:tracking-(--n-type-tracking)',
        '[:where(&)]:font-(weight:--n-type-weight)'
      ]);
      expect(guarded(element)).toEqual([
        '[&.neba-typography]:mb-(--n-type-gutter)',
        '[&.neba-typography]:mt-0'
      ]);
    });

    // The floor is still there under a class that applies only at a
    // breakpoint, so below it the level keeps its own size.
    it('counts a class behind a variant', async () => {
      const screen = await render(
        <Typography level="h1" className="md:text-5xl">
          Title
        </Typography>
      );
      const element = screen.getByText('Title').element() as HTMLElement;

      expect(element).toHaveClass('[:where(&)]:text-(length:--n-type-size)');
      expect(element.style.getPropertyValue('--n-type-size')).toBe('1.875rem');
    });

    it('moves the muted ink and the accent ink alike', async () => {
      const screen = await render(
        <Typography level="caption" className="text-red-600">
          Note
        </Typography>
      );

      expect(screen.getByText('Note').element()).toHaveClass('[:where(&)]:text-(--neba-muted-fg)');

      await screen.rerender(
        <Typography color="primary" className="text-red-600">
          Note
        </Typography>
      );

      expect(screen.getByText('Note').element()).toHaveClass('[:where(&)]:text-(--n-accent)');
    });

    // `mb-8!` already wins, so a call site written with `!` keeps every guard
    // exactly as it was.
    it('leaves the guard under an important class', async () => {
      const screen = await render(<Typography className="mb-8!">Body</Typography>);
      const element = screen.getByText('Body').element();

      expect(floored(element)).toEqual([]);
      expect(element).toHaveClass('[&.neba-typography]:mb-(--n-type-gutter)');
    });

    it('keeps every guard for a class it does not recognise', async () => {
      const screen = await render(<Typography className="hero-title flex">Body</Typography>);

      expect(floored(screen.getByText('Body').element())).toEqual([]);
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
