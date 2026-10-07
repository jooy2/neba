import * as React from 'react';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Header } from 'neba';
import {
  PageLayoutContext,
  PageLayoutSlotContext,
  headerFloorSteps,
  type PageLayoutContextValue
} from '../../../src/internal/page-layout.js';

describe('Header', () => {
  describe('rendering', () => {
    it('renders a banner landmark', async () => {
      const screen = await render(<Header>Docs</Header>);
      const element = screen.getByRole('banner').element();

      expect(element.tagName).toBe('HEADER');
    });

    it('names the landmark when it is given a label', async () => {
      const screen = await render(<Header label="Site" />);

      await expect.element(screen.getByRole('banner', { name: 'Site' })).toBeInTheDocument();
    });

    // Inside an article a `<header>` is the article's own, and a second banner
    // would be a second top of the page in a screen reader's list of landmarks.
    it('is not a banner inside an article', async () => {
      const screen = await render(
        <article>
          <Header>Post</Header>
        </article>
      );

      await expect.element(screen.getByText('Post')).toBeInTheDocument();
      expect(screen.getByRole('banner').query()).toBeNull();
    });

    it('draws all three slots', async () => {
      const screen = await render(
        <Header brand={<span>Neba</span>} actions={<button type="button">Sign in</button>}>
          <a href="/docs">Docs</a>
        </Header>
      );

      await expect.element(screen.getByText('Neba')).toBeInTheDocument();
      await expect.element(screen.getByRole('link', { name: 'Docs' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Sign in' })).toBeInTheDocument();
    });

    it('draws nothing for a slot it was given nothing for', async () => {
      const screen = await render(<Header data-testid="bar">Docs</Header>);
      const row = screen.getByTestId('bar').element().firstElementChild as HTMLElement;

      expect(row.children).toHaveLength(1);
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Header className="my-own-class" />);

      expect(screen.getByRole('banner').element()).toHaveClass('my-own-class');
    });

    it('renders as another element when `render` says so', async () => {
      const screen = await render(<Header render={<div />} data-testid="bar" />);

      expect(screen.getByTestId('bar').element().tagName).toBe('DIV');
    });
  });

  describe('align', () => {
    // Centring the middle in the space *left over* puts it wherever the brand
    // happens to end, so both ends are given equal shares instead.
    it('gives both ends an equal share so the middle lands on the midline', async () => {
      const screen = await render(
        <Header align="center" brand={<span>Neba</span>} actions={<span>Sign in</span>}>
          Docs
        </Header>
      );

      const row = screen.getByRole('banner').element().firstElementChild as HTMLElement;
      const [start, , end] = Array.from(row.children) as HTMLElement[];

      expect(start.getBoundingClientRect().width).toBeCloseTo(end.getBoundingClientRect().width, 0);
    });

    it('keeps the ends in place even when one of them is empty', async () => {
      const screen = await render(
        <Header align="center" actions={<span>Sign in</span>}>
          Docs
        </Header>
      );

      const row = screen.getByRole('banner').element().firstElementChild as HTMLElement;

      expect(row.children).toHaveLength(3);
    });

    it('packs the middle against the brand by default', async () => {
      const screen = await render(<Header brand={<span>Neba</span>}>Docs</Header>);
      const row = screen.getByRole('banner').element().firstElementChild as HTMLElement;

      expect(row.children[0]).toHaveClass('shrink-0');
    });
  });

  describe('position', () => {
    it('is sticky against the top of the window by default', async () => {
      const screen = await render(<Header />);

      expect(screen.getByRole('banner').element()).toHaveClass('sticky', 'top-0');
    });

    it('scrolls away with the page when it is static', async () => {
      const screen = await render(<Header position="static" />);
      const element = screen.getByRole('banner').element();

      expect(element).not.toHaveClass('sticky');
      expect(element).not.toHaveClass('fixed');
    });

    it('leaves the flow when it is fixed', async () => {
      const screen = await render(<Header position="fixed" />);

      expect(screen.getByRole('banner').element()).toHaveClass('fixed', 'top-0');
    });

    // A PageLayout reserves a fixed bar's floor before it has measured the bar,
    // out of a table of its own, so the bar has to stand on the same floor.
    it('stands on the floor a layout reserves for it at every size', async () => {
      const sizes = Object.keys(headerFloorSteps) as (keyof typeof headerFloorSteps)[];
      const screen = await render(
        <>
          {sizes.map((size) => (
            <Header key={size} size={size} position="fixed" label={size} />
          ))}
        </>
      );

      for (const size of sizes) {
        const row = screen.getByRole('banner', { name: size }).element().firstElementChild;

        expect(row).toHaveClass(`min-h-${headerFloorSteps[size]}`);
      }
    });
  });

  describe('appearance', () => {
    it('draws a hairline along the bottom edge by default', async () => {
      const screen = await render(<Header />);

      expect(screen.getByRole('banner').element()).toHaveClass('border-b');
    });

    it('drops the hairline when it is turned off', async () => {
      const screen = await render(<Header divider={false} />);

      expect(screen.getByRole('banner').element()).not.toHaveClass('border-b');
    });

    it('holds the row to a measure without narrowing the sheet', async () => {
      const screen = await render(<Header maxWidth="lg" />);
      const element = screen.getByRole('banner').element();
      const row = element.firstElementChild as HTMLElement;

      expect(element).toHaveClass('w-full');
      expect(row).toHaveClass('max-w-(--n-max-w)', 'mx-auto');
      expect(row.style.getPropertyValue('--n-max-w-xs')).toBe('64rem');
    });

    it('carries the colour family in its slots rather than in its fill', async () => {
      const screen = await render(<Header color="success" />);
      const element = screen.getByRole('banner').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-line')).toBe('var(--neba-success-line)');
      expect(element.style.getPropertyValue('--n-panel')).toBe('var(--neba-panel)');
    });
  });

  describe('ref', () => {
    /** A layout of the test's own, whose `register` can be counted. */
    function Slotted({
      register,
      children
    }: {
      register: PageLayoutContextValue['register'];
      children: React.ReactNode;
    }) {
      const value = React.useMemo(
        () => ({
          present: true,
          register,
          collapseBelow: 'none' as const,
          open: { start: false, end: false },
          setOpen: () => {},
          scroll: 'page' as const
        }),
        [register]
      );

      return (
        <PageLayoutContext.Provider value={value}>
          <PageLayoutSlotContext.Provider value="header">{children}</PageLayoutSlotContext.Provider>
        </PageLayoutContext.Provider>
      );
    }

    // Each registration restarts the layout's observers and rewrites its
    // height on the layout's root, which invalidates the style of the page.
    it('registers with the layout once, however often an inline ref changes', async () => {
      const register = vi.fn();
      const nodes: (HTMLElement | null)[] = [];
      const page = (count: number) => (
        <Slotted register={register}>
          <Header ref={(node) => void nodes.push(node)}>{count}</Header>
        </Slotted>
      );
      const screen = await render(page(0));

      await screen.rerender(page(1));
      await screen.rerender(page(2));

      const bar = screen.getByRole('banner').element();

      expect(register.mock.calls).toEqual([['header', bar]]);
      // Every new ref is still handed the bar, and every old one let go of it.
      expect(nodes).toEqual([bar, null, bar, null, bar]);
    });

    it('moves the bar from one ref to the next, and lets go of it on unmount', async () => {
      const first = React.createRef<HTMLElement>();
      const second = React.createRef<HTMLElement>();
      const screen = await render(<Header ref={first} />);
      const bar = screen.getByRole('banner').element();

      expect(first.current).toBe(bar);

      await screen.rerender(<Header ref={second} />);

      expect(first.current).toBeNull();
      expect(second.current).toBe(bar);

      await screen.unmount();

      expect(second.current).toBeNull();
    });

    it('registers again when `position` changes, so the room for it is measured again', async () => {
      const register = vi.fn();
      const screen = await render(
        <Slotted register={register}>
          <Header />
        </Slotted>
      );

      await screen.rerender(
        <Slotted register={register}>
          <Header position="fixed" />
        </Slotted>
      );

      const bar = screen.getByRole('banner').element();

      expect(register.mock.calls).toEqual([
        ['header', bar],
        ['header', null],
        ['header', bar]
      ]);
    });
  });
});
