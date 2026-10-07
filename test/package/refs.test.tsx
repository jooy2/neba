import * as React from 'react';
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  AnimateHeadline,
  AnimateMarquee,
  AnimateTyping,
  BottomNavigationItem,
  FloatingActionButton,
  FloatingBottomNavigation,
  Footer,
  Header,
  Image,
  InlineCitation,
  Mockup,
  PageLayout,
  Pane,
  Panes,
  PromptInput,
  ScrollZone,
  Segment,
  SegmentedButton,
  Sidebar,
  Tab,
  TabPanel,
  Tabs,
  TextField,
  TreeItem,
  TreeView,
  WindowPane
} from 'neba';

/*
 * Every component that hands its node to a caller's ref and keeps it for
 * itself as well, which it does through `internal/refs.ts`. A ref passed
 * straight to an element or to Base UI is React's or Base UI's to get right,
 * and is not in here.
 *
 * Each case names the file that does the merging, so the table cannot fall
 * behind the source: the last test below fails on a file that merges a ref and
 * has no case.
 */

const PIXEL = 'data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==';

interface Case {
  name: string;
  /** The module whose merge the case exercises. */
  file: string;
  render: (ref: React.Ref<any>) => React.ReactElement;
}

const cases: Case[] = [
  {
    name: 'Header',
    file: 'header/Header.tsx',
    render: (ref) => <Header ref={ref}>Docs</Header>
  },
  {
    name: 'Footer',
    file: 'footer/Footer.tsx',
    render: (ref) => <Footer ref={ref}>Footer</Footer>
  },
  {
    name: 'PageLayout',
    file: 'page-layout/PageLayout.tsx',
    render: (ref) => <PageLayout ref={ref}>Page</PageLayout>
  },
  {
    name: 'Sidebar',
    file: 'sidebar/Sidebar.tsx',
    render: (ref) => <Sidebar ref={ref}>Navigation</Sidebar>
  },
  {
    name: 'Tabs',
    file: 'tabs/Tabs.tsx',
    render: (ref) => (
      <Tabs ref={ref} defaultValue="one">
        <Tab value="one">One</Tab>
        <TabPanel value="one">Panel</TabPanel>
      </Tabs>
    )
  },
  {
    name: 'AnimateTyping',
    file: 'animate-typing/AnimateTyping.tsx',
    render: (ref) => <AnimateTyping ref={ref}>Hello</AnimateTyping>
  },
  {
    name: 'AnimateMarquee',
    file: 'animate-marquee/AnimateMarquee.tsx',
    render: (ref) => (
      <AnimateMarquee ref={ref}>
        <span>Alpha</span>
      </AnimateMarquee>
    )
  },
  {
    name: 'AnimateHeadline',
    file: 'animate-headline/AnimateHeadline.tsx',
    render: (ref) => (
      <AnimateHeadline ref={ref}>
        {[<span key="a">Faster</span>, <span key="b">Simpler</span>]}
      </AnimateHeadline>
    )
  },
  {
    name: 'WindowPane',
    file: 'window-pane/WindowPane.tsx',
    render: (ref) => <WindowPane ref={ref} title="Finder" />
  },
  {
    name: 'Image',
    file: 'image/Image.tsx',
    render: (ref) => <Image ref={ref} src={PIXEL} alt="A pixel" />
  },
  {
    name: 'FloatingBottomNavigation',
    file: 'floating-bottom-navigation/FloatingBottomNavigation.tsx',
    render: (ref) => (
      <FloatingBottomNavigation ref={ref} label="Main">
        <BottomNavigationItem value="home">Home</BottomNavigationItem>
      </FloatingBottomNavigation>
    )
  },
  {
    name: 'SegmentedButton',
    file: 'segmented-button/SegmentedButton.tsx',
    render: (ref) => (
      <SegmentedButton ref={ref} aria-label="Range" defaultValue="day">
        <Segment value="day">Day</Segment>
        <Segment value="week">Week</Segment>
      </SegmentedButton>
    )
  },
  {
    name: 'PromptInput',
    file: 'prompt-input/PromptInput.tsx',
    render: (ref) => <PromptInput ref={ref} label="Message" />
  },
  {
    name: 'FloatingActionButton',
    file: 'floating-action-button/FloatingActionButton.tsx',
    render: (ref) => <FloatingActionButton ref={ref} label="Compose" />
  },
  {
    name: 'Panes',
    file: 'panes/Panes.tsx',
    render: (ref) => (
      <Panes ref={ref}>
        <Pane>One</Pane>
        <Pane>Two</Pane>
      </Panes>
    )
  },
  {
    name: 'TextField',
    file: 'text-field/TextField.tsx',
    render: (ref) => <TextField ref={ref} label="Email" />
  },
  {
    name: 'TextField, multiline',
    file: 'text-field/TextField.tsx',
    render: (ref) => <TextField ref={ref} label="Notes" multiline />
  },
  {
    name: 'TreeView',
    file: 'tree-view/TreeView.tsx',
    render: (ref) => (
      <TreeView ref={ref} label="Files">
        <TreeItem value="readme" label="README.md" />
      </TreeView>
    )
  },
  {
    name: 'TreeItem',
    file: 'tree-view/TreeView.tsx',
    render: (ref) => (
      <TreeView label="Files">
        <TreeItem ref={ref} value="readme" label="README.md" />
      </TreeView>
    )
  },
  {
    name: 'Mockup',
    file: 'mockup/Mockup.tsx',
    render: (ref) => (
      <Mockup ref={ref} device="mobile">
        <span>App</span>
      </Mockup>
    )
  },
  {
    name: 'ScrollZone, scrollerRef',
    file: 'scroll-zone/ScrollZone.tsx',
    render: (ref) => (
      <ScrollZone scrollerRef={ref}>
        <div>One</div>
        <div>Two</div>
      </ScrollZone>
    )
  },
  {
    name: 'InlineCitation',
    file: 'inline-citation/InlineCitation.tsx',
    render: (ref) => <InlineCitation ref={ref} index={1} />
  }
];

/**
 * A ref written for React 19: it returns what lets go of the node. Each node
 * it is handed is recorded, and so is each node a cleanup let go of.
 */
function cleanupRef() {
  const handed: (Element | null)[] = [];
  const released: Element[] = [];
  const ref = (node: Element | null) => {
    handed.push(node);

    return () => {
      released.push(node as Element);
    };
  };

  return { ref, handed, released };
}

describe('a ref forwarded to a component that keeps the node too', () => {
  // React 18 has no ref cleanups. It ignores what a ref returns and calls it
  // with `null` when the node goes, by design, so there is nothing of 19's
  // behaviour to check there; the object ref and the plain callback below
  // cover 18.
  describe.skipIf(React.version.startsWith('18.'))('a React 19 cleanup', () => {
    it.each(cases)('runs on unmount, and $name never hands the ref `null`', async (entry) => {
      const { ref, handed, released } = cleanupRef();
      const screen = await render(entry.render(ref));

      await expect.poll(() => handed.length).toBeGreaterThan(0);
      expect(handed[0]).toBeInstanceOf(HTMLElement);

      await screen.unmount();

      expect(handed).not.toContain(null);
      expect(released).toEqual(handed);
    });

    // The mark is drawn again inside the card's trigger once the card's
    // chunk has arrived, so the ref moves from one element to another.
    it('follows an InlineCitation across the swap to the card trigger', async () => {
      const { ref, handed, released } = cleanupRef();
      const screen = await render(
        <InlineCitation ref={ref} index={1} href="https://example.com/a" title="A source" />
      );
      const first = screen.getByRole('link').element() as HTMLElement;

      first.focus();

      await expect.poll(() => handed.length).toBe(2);
      expect(released).toEqual([first]);

      await screen.unmount();

      expect(handed).not.toContain(null);
      expect(released).toEqual(handed);
    });
  });

  it.each(cases)('hands $name an object ref the node and clears it on unmount', async (entry) => {
    const ref = React.createRef<HTMLElement>();
    const screen = await render(entry.render(ref));

    await expect.poll(() => ref.current).toBeInstanceOf(HTMLElement);

    await screen.unmount();

    expect(ref.current).toBeNull();
  });

  it.each(cases)(
    'hands $name a callback ref that returns nothing the node, then `null`',
    async (entry) => {
      const handed: (Element | null)[] = [];
      const ref = (node: Element | null) => {
        handed.push(node);
      };
      const screen = await render(entry.render(ref));

      await expect.poll(() => handed.length).toBeGreaterThan(0);

      await screen.unmount();

      expect(handed.at(-1)).toBeNull();
      expect(handed.filter((node) => node !== null)).toHaveLength(
        handed.filter((node) => node === null).length
      );
    }
  );

  it('has a case for every component that merges a ref by hand', () => {
    const sources = import.meta.glob('../../src/components/**/*.tsx', {
      query: '?raw',
      import: 'default',
      eager: true
    }) as Record<string, string>;
    const merging = Object.entries(sources)
      .filter(([, source]) => /\buse(?:MergedRef|BarRef)(?:<[^>]*>)?\(/.test(source))
      .map(([path]) => path.replace('../../src/components/', ''))
      .sort();

    expect([...new Set(cases.map((entry) => entry.file))].sort()).toEqual(merging);
  });
});
