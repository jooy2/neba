import { afterAll, beforeEach, describe, expect, it, vi } from 'vitest';
import { page } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { Footer, Header, PageLayout, Sidebar, SidebarTrigger } from 'neba';
import { ko, registerMessages } from 'neba/locales';

registerMessages('ko', ko);

const WIDE = 1280;
const NARROW = 480;

beforeEach(async () => {
  await page.viewport(WIDE, 800);
});

afterAll(async () => {
  await page.viewport(WIDE, 800);
});

/** The band between the header and the footer: sidebars, then the content column. */
function band(root: HTMLElement) {
  return Array.from(root.children).find((child) => child.querySelector('main')) as HTMLElement;
}

describe('PageLayout', () => {
  describe('landmarks', () => {
    it('puts the page in a main landmark', async () => {
      const screen = await render(<PageLayout>Everything</PageLayout>);
      const element = screen.getByRole('main').element();

      expect(element.tagName).toBe('MAIN');
      expect(element).toHaveTextContent('Everything');
    });

    it('gives the main an id for the skip link to reach', async () => {
      const screen = await render(<PageLayout>Page</PageLayout>);

      expect(screen.getByRole('main').element()).toHaveAttribute('id', 'main');
    });

    it('takes an id of its own', async () => {
      const screen = await render(<PageLayout mainId="content">Page</PageLayout>);

      expect(screen.getByRole('main').element()).toHaveAttribute('id', 'content');
      await expect
        .element(screen.getByRole('link', { name: 'Skip to content' }))
        .toHaveAttribute('href', '#content');
    });

    it('renders every slot it was handed', async () => {
      const screen = await render(
        <PageLayout
          collapseBelow="none"
          header={<Header>Site</Header>}
          footer={<Footer>© Neba</Footer>}
          sidebar={<Sidebar label="Sections" />}
          endSidebar={<Sidebar label="Contents" />}
        >
          Page
        </PageLayout>
      );

      await expect.element(screen.getByRole('banner')).toBeInTheDocument();
      await expect.element(screen.getByRole('contentinfo')).toBeInTheDocument();
      await expect
        .element(screen.getByRole('complementary', { name: 'Sections' }))
        .toBeInTheDocument();
      await expect
        .element(screen.getByRole('complementary', { name: 'Contents' }))
        .toBeInTheDocument();
    });

    it('renders nothing for a slot it was given nothing for', async () => {
      const screen = await render(<PageLayout data-testid="root">Page</PageLayout>);

      expect(screen.getByRole('banner').query()).toBeNull();
      expect(screen.getByRole('contentinfo').query()).toBeNull();
      expect(screen.getByRole('complementary').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<PageLayout className="my-own-class" data-testid="root" />);

      expect(screen.getByTestId('root').element()).toHaveClass('my-own-class');
    });
  });

  describe('the skip link', () => {
    // A keyboard reader arriving on a page whose navigation holds forty links
    // has to walk past all forty on every page before reaching the article.
    it('is the first thing in the document', async () => {
      const screen = await render(
        <PageLayout data-testid="root" header={<Header>Site</Header>}>
          Page
        </PageLayout>
      );

      const first = screen.getByTestId('root').element().firstElementChild as HTMLElement;

      expect(first.tagName).toBe('A');
      expect(first).toHaveAttribute('href', '#main');
    });

    it('says it in the layout language', async () => {
      const screen = await render(<PageLayout locale="ko">Page</PageLayout>);

      await expect
        .element(screen.getByRole('link', { name: '본문으로 건너뛰기' }))
        .toBeInTheDocument();
    });

    it('takes a word of its own', async () => {
      const screen = await render(<PageLayout skipLabel="Jump to the article">Page</PageLayout>);

      await expect
        .element(screen.getByRole('link', { name: 'Jump to the article' }))
        .toBeInTheDocument();
    });

    it('can be turned off', async () => {
      const screen = await render(<PageLayout skipLink={false}>Page</PageLayout>);

      expect(screen.getByRole('link').query()).toBeNull();
    });
  });

  describe('headerSpan', () => {
    it('puts the header above the sidebars by default', async () => {
      const screen = await render(
        <PageLayout
          data-testid="root"
          collapseBelow="none"
          header={<Header>Site</Header>}
          sidebar={<Sidebar label="Sections" />}
        >
          Page
        </PageLayout>
      );

      const root = screen.getByTestId('root').element() as HTMLElement;
      const header = screen.getByRole('banner').element();

      expect(header.parentElement).toBe(root);
      expect(band(root).contains(header)).toBe(false);
    });

    it('puts the header beside the sidebars when it only spans the content', async () => {
      const screen = await render(
        <PageLayout
          data-testid="root"
          collapseBelow="none"
          headerSpan="content"
          header={<Header>Site</Header>}
          sidebar={<Sidebar label="Sections" />}
        >
          Page
        </PageLayout>
      );

      const root = screen.getByTestId('root').element() as HTMLElement;
      const header = screen.getByRole('banner').element();

      expect(band(root).contains(header)).toBe(true);
      expect(header.parentElement).toBe(screen.getByRole('main').element().parentElement);
    });

    it('answers the same question separately for the footer', async () => {
      const screen = await render(
        <PageLayout
          data-testid="root"
          collapseBelow="none"
          footerSpan="content"
          footer={<Footer>© Neba</Footer>}
          sidebar={<Sidebar label="Sections" />}
        >
          Page
        </PageLayout>
      );

      const root = screen.getByTestId('root').element() as HTMLElement;

      expect(band(root).contains(screen.getByRole('contentinfo').element())).toBe(true);
    });
  });

  describe('measuring the bars', () => {
    // A column that holds its place has to start below a bar whose height only
    // the bar knows, and whether it has to at all is read off the bar's own
    // `position` rather than plumbed through a prop.
    /* The bar's own `position` is what decides this, and a component test loads
       no CSS — so the two tests that are about being pinned write the property
       inline, which is what the stylesheet would have done. */
    it('writes a sticky header height onto the root for the sidebars to read', async () => {
      const screen = await render(
        <PageLayout
          data-testid="root"
          collapseBelow="none"
          header={<Header style={{ position: 'sticky' }}>Site</Header>}
        >
          Page
        </PageLayout>
      );

      const root = screen.getByTestId('root').element() as HTMLElement;
      const bar = screen.getByRole('banner').element() as HTMLElement;

      expect(root.style.getPropertyValue('--n-layout-header')).toBe(`${bar.offsetHeight}px`);
      // Sticky is still in the flow, so there is nothing to reserve for it.
      expect(root.style.getPropertyValue('--n-layout-header-inset')).toBe('0px');
    });

    it('reserves the height of a header that has left the flow', async () => {
      const screen = await render(
        <PageLayout
          data-testid="root"
          collapseBelow="none"
          header={<Header style={{ position: 'fixed' }}>Site</Header>}
        >
          Page
        </PageLayout>
      );

      const root = screen.getByTestId('root').element() as HTMLElement;
      const bar = screen.getByRole('banner').element() as HTMLElement;

      expect(root.style.getPropertyValue('--n-layout-header-inset')).toBe(`${bar.offsetHeight}px`);
    });

    it('takes nothing off the top of a sidebar the header sits beside', async () => {
      const screen = await render(
        <PageLayout
          data-testid="root"
          collapseBelow="none"
          headerSpan="content"
          header={<Header style={{ position: 'sticky' }}>Site</Header>}
        >
          Page
        </PageLayout>
      );

      const root = screen.getByTestId('root').element() as HTMLElement;

      expect(root.style.getPropertyValue('--n-layout-header')).toBe('0px');
    });

    it('reports nothing for a slot that is not filled', async () => {
      const screen = await render(<PageLayout data-testid="root">Page</PageLayout>);
      const root = screen.getByTestId('root').element() as HTMLElement;

      expect(root.style.getPropertyValue('--n-layout-header')).toBe('0px');
      expect(root.style.getPropertyValue('--n-layout-footer')).toBe('0px');
    });

    it('a static footer takes nothing, because it scrolls away', async () => {
      const screen = await render(
        <PageLayout data-testid="root" footer={<Footer>© Neba</Footer>}>
          Page
        </PageLayout>
      );

      const root = screen.getByTestId('root').element() as HTMLElement;

      expect(root.style.getPropertyValue('--n-layout-footer')).toBe('0px');
      expect(root.style.getPropertyValue('--n-layout-footer-inset')).toBe('0px');
    });
  });

  describe('scroll', () => {
    it('lets the document scroll by default', async () => {
      const screen = await render(<PageLayout data-testid="root">Page</PageLayout>);

      expect(screen.getByTestId('root').element()).toHaveClass('min-h-dvh');
      expect(screen.getByRole('main').element()).not.toHaveClass('overflow-y-auto');
    });

    it('pins the layout to the window and scrolls only the content', async () => {
      const screen = await render(
        <PageLayout data-testid="root" scroll="content">
          Page
        </PageLayout>
      );

      expect(screen.getByTestId('root').element()).toHaveClass('h-dvh', 'overflow-hidden');
      expect(screen.getByRole('main').element()).toHaveClass('overflow-y-auto');
    });
  });

  describe('the sidebars', () => {
    it('owns the open state, so a trigger anywhere can reach it', async () => {
      await page.viewport(NARROW, 800);
      const onSidebarOpenChange = vi.fn();
      const screen = await render(
        <PageLayout
          collapseBelow="md"
          onSidebarOpenChange={onSidebarOpenChange}
          header={<Header brand={<SidebarTrigger />} />}
          sidebar={<Sidebar>Navigation</Sidebar>}
        >
          Page
        </PageLayout>
      );

      await screen.getByRole('button', { name: 'Open sidebar' }).click();

      expect(onSidebarOpenChange).toHaveBeenCalledWith(true);
      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    });

    it('holds the two sidebars apart', async () => {
      await page.viewport(NARROW, 800);
      const screen = await render(
        <PageLayout
          collapseBelow="md"
          header={
            <Header
              brand={<SidebarTrigger data-testid="start" />}
              actions={<SidebarTrigger side="end" data-testid="end" />}
            />
          }
          sidebar={<Sidebar>Navigation</Sidebar>}
          endSidebar={<Sidebar title="Contents">On this page</Sidebar>}
        >
          Page
        </PageLayout>
      );

      await screen.getByTestId('end').click();

      await expect.element(screen.getByRole('dialog', { name: 'Contents' })).toBeInTheDocument();
      await expect.element(screen.getByTestId('start')).toHaveAttribute('aria-expanded', 'false');
    });

    it('stays shut when the caller controls it and says so', async () => {
      await page.viewport(NARROW, 800);
      const screen = await render(
        <PageLayout
          collapseBelow="md"
          sidebarOpen={false}
          header={<SidebarTrigger data-testid="trigger" />}
          sidebar={<Sidebar>Navigation</Sidebar>}
        >
          Page
        </PageLayout>
      );

      await screen.getByTestId('trigger').click();

      expect(screen.getByRole('dialog').query()).toBeNull();
    });
  });
});
