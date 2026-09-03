import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
import { Button, TreeItem, TreeView } from 'neba';

/** The three-level tree most of these tests walk. */
function Sample(props: React.ComponentProps<typeof TreeView>) {
  return (
    <TreeView label="Files" {...props}>
      <TreeItem value="src" label="src">
        <TreeItem value="components" label="components">
          <TreeItem value="button" label="Button.tsx" />
        </TreeItem>
        <TreeItem value="index" label="index.ts" />
      </TreeItem>
      <TreeItem value="readme" label="README.md" />
    </TreeView>
  );
}

describe('TreeView', () => {
  describe('rendering', () => {
    it('renders a tree of treeitems', async () => {
      const screen = await render(<Sample />);

      await expect.element(screen.getByRole('tree', { name: 'Files' })).toBeInTheDocument();
      expect(screen.getByRole('treeitem').elements()).toHaveLength(2);
    });

    it('shows the branches that start open', async () => {
      const screen = await render(<Sample defaultExpanded={['src']} />);

      await expect.element(screen.getByRole('treeitem', { name: /index\.ts/ })).toBeInTheDocument();
    });

    it('marks a row with children as expandable and a leaf as neither', async () => {
      const screen = await render(<Sample />);

      await expect
        .element(screen.getByRole('treeitem', { name: /src/ }))
        .toHaveAttribute('aria-expanded', 'false');
      expect(
        screen
          .getByRole('treeitem', { name: /README/ })
          .element()
          .getAttribute('aria-expanded')
      ).toBeNull();
    });

    it('draws the arrow on a row that has no children yet', async () => {
      const screen = await render(
        <TreeView>
          <TreeItem value="remote" label="Remote" expandable />
        </TreeView>
      );

      await expect
        .element(screen.getByRole('treeitem', { name: 'Remote' }))
        .toHaveAttribute('aria-expanded', 'false');
    });

    it('renders a row as a link when it is given an href', async () => {
      const screen = await render(
        <TreeView>
          <TreeItem value="docs" label="Docs" href="/docs" />
        </TreeView>
      );

      await expect
        .element(screen.getByRole('link', { name: 'Docs' }))
        .toHaveAttribute('href', '/docs');
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(
        <TreeView>
          <TreeItem value="a" label="Before" />
        </TreeView>
      );

      await screen.rerender(
        <TreeView>
          <TreeItem value="a" label="After" />
        </TreeView>
      );

      await expect.element(screen.getByRole('treeitem', { name: 'After' })).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <TreeView className="my-own-class">
          <TreeItem value="a" label="One" className="my-row-class" />
        </TreeView>
      );

      expect(screen.container.querySelector('.my-own-class')).not.toBeNull();
      expect(screen.container.querySelector('.my-row-class')).not.toBeNull();
    });
  });

  describe('opening and shutting', () => {
    it('opens a branch when its row is pressed', async () => {
      const screen = await render(<Sample />);
      const row = screen.getByRole('treeitem', { name: /src/ });

      // The label rather than the row: a click on the row's own box would land
      // on the disclosure arrow as often as not, and the arrow is a target of
      // its own with different behaviour.
      await screen.getByText('src').click();

      await expect.element(row).toHaveAttribute('aria-expanded', 'true');
      await expect.element(screen.getByRole('treeitem', { name: /index\.ts/ })).toBeInTheDocument();
    });

    it('reports which branches are open', async () => {
      const onExpandedChange = vi.fn();
      const screen = await render(<Sample onExpandedChange={onExpandedChange} />);

      await screen.getByText('src').click();

      expect(onExpandedChange).toHaveBeenCalledWith(['src']);
    });

    /*
     * Off the page for good, not hidden. It is held for as long as the collapse
     * runs — no test loads CSS, so here that is no time at all — and then it
     * goes, which is what keeps a shut branch out of the document order the
     * arrow keys read.
     */
    it('takes a shut branch off the page rather than hiding it', async () => {
      const screen = await render(<Sample defaultExpanded={['src']} />);

      await screen.getByText('src').click();

      expect(screen.getByRole('treeitem', { name: /index\.ts/ }).query()).toBeNull();
    });

    /**
     * A branch used to be there on one frame and gone on the next, which on a
     * tree deep enough to need one is the whole page jumping. It opens at a
     * height now, the way an Accordion's panel does — a grid row from `0fr` to
     * `1fr`, so nothing has to be measured and a nested branch opening inside
     * this one is carried by the same track.
     */
    it('opens and shuts a branch at a height', async () => {
      const screen = await render(<Sample defaultExpanded={['src']} />);

      const group = screen.container.querySelector('[role="group"]') as HTMLElement;
      const track = group.parentElement as HTMLElement;

      expect(track.className).toContain('transition:grid-template-rows');
      expect(track).toHaveClass('[grid-template-rows:1fr]');
      // The clipped half of the pair. Without it the rows are drawn at full
      // height inside a track that says they are not.
      expect(group).toHaveClass('overflow-hidden');
      expect(group).toHaveClass('min-h-0');
    });

    it('stays shut when the caller controls it and does not answer', async () => {
      const screen = await render(<Sample expanded={[]} />);

      await screen.getByText('src').click();

      await expect
        .element(screen.getByRole('treeitem', { name: /src/ }))
        .toHaveAttribute('aria-expanded', 'false');
    });
  });

  describe('choosing', () => {
    it('marks the row that was pressed', async () => {
      const screen = await render(<Sample />);
      const row = screen.getByRole('treeitem', { name: /README/ });

      await row.click();

      await expect.element(row).toHaveAttribute('aria-selected', 'true');
    });

    it('reports the chosen row', async () => {
      const onSelectedChange = vi.fn();
      const screen = await render(<Sample onSelectedChange={onSelectedChange} />);

      await screen.getByRole('treeitem', { name: /README/ }).click();

      expect(onSelectedChange).toHaveBeenCalledWith(['readme']);
    });

    // Single select replaces; that is the difference between the two modes, and
    // it is the one a caller is most likely to get wrong by hand.
    it('replaces the chosen row when only one may be chosen', async () => {
      const screen = await render(<Sample defaultSelected={['src']} />);

      await screen.getByRole('treeitem', { name: /README/ }).click();

      expect(
        screen.getByRole('treeitem', { name: /^src/ }).element().getAttribute('aria-selected')
      ).toBeNull();
      await expect
        .element(screen.getByRole('treeitem', { name: /README/ }))
        .toHaveAttribute('aria-selected', 'true');
    });

    it('adds to the chosen rows when multiple is set', async () => {
      const onSelectedChange = vi.fn();
      const screen = await render(
        <Sample multiple defaultSelected={['src']} onSelectedChange={onSelectedChange} />
      );

      await screen.getByRole('treeitem', { name: /README/ }).click();

      expect(onSelectedChange).toHaveBeenCalledWith(['src', 'readme']);
    });

    it('says out loud that more than one row may be chosen', async () => {
      const screen = await render(<Sample multiple />);

      await expect
        .element(screen.getByRole('tree'))
        .toHaveAttribute('aria-multiselectable', 'true');
    });

    it('does not answer a disabled row', async () => {
      const onSelectedChange = vi.fn();
      const screen = await render(
        <TreeView onSelectedChange={onSelectedChange}>
          <TreeItem value="a" label="Locked" disabled />
        </TreeView>
      );

      // `force`, because the row says `aria-disabled` and the driver will not
      // press something that says it is unavailable — which is the point being
      // tested: a caller's own code could still get a click through.
      await screen.getByRole('treeitem', { name: 'Locked' }).click({ force: true });

      expect(onSelectedChange).not.toHaveBeenCalled();
    });
  });

  describe('the keyboard', () => {
    /** The tree hands its tab stop out in an effect, so wait for it to land. */
    async function treeHasFocus(screen: Awaited<ReturnType<typeof render>>) {
      await expect
        .poll(() => screen.getByRole('tree').query()?.contains(document.activeElement) ?? false)
        .toBe(true);
    }

    it('holds exactly one tab stop however many rows there are', async () => {
      const screen = await render(<Sample defaultExpanded={['src']} />);

      const stops = screen
        .getByRole('treeitem')
        .elements()
        .filter((row) => row.getAttribute('tabindex') === '0');

      expect(stops).toHaveLength(1);
    });

    // The tab stop cannot stay on a row that has gone. It is checked against
    // the rows that registered themselves rather than by querying the tree, so
    // the case that matters is a branch shutting under the stop — and it is
    // shut from outside here, so nothing else is moving the stop as a side
    // effect of the press that did it.
    it('moves the tab stop off a row a shut branch took away', async () => {
      const stop = () =>
        screen
          .getByRole('treeitem')
          .elements()
          .filter((row) => row.getAttribute('tabindex') === '0')
          .map((row) => row.getAttribute('data-neba-value'));

      const screen = await render(<Sample expanded={['src', 'components']} />);

      await screen
        .getByRole('treeitem', { name: /^components/ })
        .element()
        .focus();
      await treeHasFocus(screen);
      await userEvent.keyboard('{ArrowDown}');

      await expect.poll(stop).toEqual(['button']);

      await screen.rerender(<Sample expanded={[]} />);

      await expect.poll(stop).toEqual(['src']);
      expect(screen.getByRole('treeitem', { name: /Button\.tsx/ }).query()).toBeNull();
    });

    it('walks the visible rows with the arrow keys', async () => {
      const screen = await render(<Sample defaultExpanded={['src']} />);

      await screen.getByRole('treeitem', { name: /^src/ }).element().focus();
      await treeHasFocus(screen);

      await userEvent.keyboard('{ArrowDown}');
      await expect
        .poll(() => document.activeElement?.getAttribute('data-neba-value'))
        .toBe('components');

      await userEvent.keyboard('{ArrowUp}');
      await expect.poll(() => document.activeElement?.getAttribute('data-neba-value')).toBe('src');
    });

    it('opens a shut branch with the forward arrow and steps into an open one', async () => {
      const screen = await render(<Sample />);

      await screen.getByRole('treeitem', { name: /^src/ }).element().focus();
      await treeHasFocus(screen);

      await userEvent.keyboard('{ArrowRight}');
      await expect
        .element(screen.getByRole('treeitem', { name: /^src/ }))
        .toHaveAttribute('aria-expanded', 'true');

      await userEvent.keyboard('{ArrowRight}');
      await expect
        .poll(() => document.activeElement?.getAttribute('data-neba-value'))
        .toBe('components');
    });

    // Walking a tree is not picking things out of it: the arrows open and shut,
    // and Enter is what chooses.
    it('opens with the forward arrow without choosing the row', async () => {
      const onSelectedChange = vi.fn();
      const screen = await render(<Sample onSelectedChange={onSelectedChange} />);

      await screen.getByRole('treeitem', { name: /^src/ }).element().focus();
      await treeHasFocus(screen);

      await userEvent.keyboard('{ArrowRight}');

      await expect
        .element(screen.getByRole('treeitem', { name: /^src/ }))
        .toHaveAttribute('aria-expanded', 'true');
      expect(onSelectedChange).not.toHaveBeenCalled();
    });

    it('shuts an open branch with the back arrow and climbs out of a leaf', async () => {
      const screen = await render(<Sample defaultExpanded={['src']} />);

      await screen
        .getByRole('treeitem', { name: /index\.ts/ })
        .element()
        .focus();
      await treeHasFocus(screen);

      await userEvent.keyboard('{ArrowLeft}');
      await expect.poll(() => document.activeElement?.getAttribute('data-neba-value')).toBe('src');

      await userEvent.keyboard('{ArrowLeft}');
      await expect
        .element(screen.getByRole('treeitem', { name: /^src/ }))
        .toHaveAttribute('aria-expanded', 'false');
    });

    it('jumps to the ends with Home and End', async () => {
      const screen = await render(<Sample defaultExpanded={['src']} />);

      await screen.getByRole('treeitem', { name: /^src/ }).element().focus();
      await treeHasFocus(screen);

      await userEvent.keyboard('{End}');
      await expect
        .poll(() => document.activeElement?.getAttribute('data-neba-value'))
        .toBe('readme');

      await userEvent.keyboard('{Home}');
      await expect.poll(() => document.activeElement?.getAttribute('data-neba-value')).toBe('src');
    });

    it('chooses the focused row with Enter', async () => {
      const onSelectedChange = vi.fn();
      const screen = await render(<Sample onSelectedChange={onSelectedChange} />);

      await screen
        .getByRole('treeitem', { name: /README/ })
        .element()
        .focus();
      await treeHasFocus(screen);

      await userEvent.keyboard('{Enter}');

      expect(onSelectedChange).toHaveBeenCalledWith(['readme']);
    });
  });

  describe('the row', () => {
    it('puts an action outside the pressable area', async () => {
      const onSelectedChange = vi.fn();
      const onAction = vi.fn();
      const screen = await render(
        <TreeView onSelectedChange={onSelectedChange}>
          <TreeItem value="a" label="Report" action={<Button size="xs">Share</Button>} />
        </TreeView>
      );

      await screen.getByRole('button', { name: 'Share' }).click();

      expect(onAction).not.toHaveBeenCalled();
      expect(onSelectedChange).not.toHaveBeenCalled();
    });

    it('fires the row handler before it opens', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <TreeView>
          <TreeItem value="a" label="src" onClick={onClick}>
            <TreeItem value="b" label="index.ts" />
          </TreeItem>
        </TreeView>
      );

      await screen.getByText('src').click();

      expect(onClick).toHaveBeenCalledTimes(1);
    });
  });
});
