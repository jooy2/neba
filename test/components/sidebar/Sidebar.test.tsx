import { afterAll, beforeEach, describe, expect, it, vi } from 'vitest';
import { page, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PageLayout, Sidebar, SidebarTrigger } from 'neba';
import { ko, registerMessages } from 'neba/locales';

registerMessages('ko', ko);

/* Wide enough that nothing collapses, which is the state every test here starts
   in. The few that are about collapsing narrow the window themselves. */
const WIDE = 1280;
const NARROW = 480;

async function widen(width: number) {
  await page.viewport(width, 800);
}

beforeEach(async () => {
  await widen(WIDE);
});

afterAll(async () => {
  await widen(WIDE);
});

describe('Sidebar', () => {
  describe('rendering', () => {
    it('renders a complementary landmark', async () => {
      const screen = await render(<Sidebar>Navigation</Sidebar>);
      const element = screen.getByRole('complementary').element();

      expect(element.tagName).toBe('ASIDE');
    });

    // A page with two sidebars offers a screen reader two regions, and two
    // regions called "complementary" name neither of them.
    it('names itself, so a page with two of them can tell them apart', async () => {
      const screen = await render(<Sidebar label="Sections">Navigation</Sidebar>);

      await expect
        .element(screen.getByRole('complementary', { name: 'Sections' }))
        .toBeInTheDocument();
    });

    it('falls back to the locale word for a sidebar', async () => {
      const screen = await render(<Sidebar locale="ko">탐색</Sidebar>);

      await expect
        .element(screen.getByRole('complementary', { name: '사이드바' }))
        .toBeInTheDocument();
    });

    it('draws whatever it was handed', async () => {
      const screen = await render(
        <Sidebar>
          <a href="/docs">Docs</a>
        </Sidebar>
      );

      await expect.element(screen.getByRole('link', { name: 'Docs' })).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Sidebar className="my-own-class" />);

      expect(screen.getByRole('complementary').element()).toHaveClass('my-own-class');
    });
  });

  describe('width', () => {
    it('takes the width its size implies', async () => {
      const screen = await render(<Sidebar />);
      const element = screen.getByRole('complementary').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-sidebar-w')).toBe('16rem');
    });

    it('takes a number as pixels', async () => {
      const screen = await render(<Sidebar width={220} />);
      const element = screen.getByRole('complementary').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-sidebar-w')).toBe('220px');
    });

    it('takes a CSS length as it was written', async () => {
      const screen = await render(<Sidebar width="18rem" />);
      const element = screen.getByRole('complementary').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-sidebar-w')).toBe('18rem');
    });
  });

  describe('resizable', () => {
    it('draws no handle unless it is asked for one', async () => {
      const screen = await render(<Sidebar />);

      expect(screen.getByRole('separator').query()).toBeNull();
    });

    it('draws a focusable separator on the inner edge', async () => {
      const screen = await render(<Sidebar resizable />);
      const handle = screen.getByRole('separator').element();

      expect(handle).toHaveAttribute('aria-orientation', 'vertical');
      expect(handle).toHaveAttribute('tabindex', '0');
    });

    it('names the handle so a keyboard reader knows what it does', async () => {
      const screen = await render(<Sidebar resizable locale="ko" />);

      await expect
        .element(screen.getByRole('separator', { name: '사이드바 크기 조절' }))
        .toBeInTheDocument();
    });

    it('widens the column on an arrow key, and says so', async () => {
      const onResizeEnd = vi.fn();
      const screen = await render(
        <Sidebar resizable width={220} style={{ width: 220 }} onResizeEnd={onResizeEnd} />
      );
      const element = screen.getByRole('complementary').element() as HTMLElement;

      await screen
        .getByRole('separator')
        .element()
        .dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true }));

      expect(element.style.getPropertyValue('--n-sidebar-w')).toBe('236px');
      expect(onResizeEnd).toHaveBeenCalledWith(236);
    });

    it('refuses to be dragged past its bounds', async () => {
      const screen = await render(
        <Sidebar resizable width={170} minWidth={168} style={{ width: 170 }} />
      );
      const element = screen.getByRole('complementary').element() as HTMLElement;
      const handle = screen.getByRole('separator').element();

      handle.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowLeft', bubbles: true }));

      expect(element.style.getPropertyValue('--n-sidebar-w')).toBe('168px');
    });
  });

  describe('holding its place', () => {
    it('is a sticky column that starts below the header', async () => {
      const screen = await render(<Sidebar />);

      expect(screen.getByRole('complementary').element()).toHaveClass(
        'sticky',
        '[top:var(--n-layout-header,0px)]'
      );
    });

    it('scrolls away with the page when it is told not to hold', async () => {
      const screen = await render(<Sidebar sticky={false} />);

      expect(screen.getByRole('complementary').element()).not.toHaveClass('sticky');
    });
  });

  describe('collapsing', () => {
    it('stays a column at every width outside a layout', async () => {
      await widen(NARROW);
      const screen = await render(<Sidebar>Navigation</Sidebar>);

      await expect.element(screen.getByRole('complementary')).toBeInTheDocument();
    });

    it('becomes a drawer once the window is too narrow for a column', async () => {
      await widen(NARROW);
      const screen = await render(
        <Sidebar collapseBelow="md" defaultOpen>
          Navigation
        </Sidebar>
      );

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
      expect(screen.getByRole('complementary').query()).toBeNull();
    });

    it('is closed until something opens it', async () => {
      await widen(NARROW);
      const screen = await render(<Sidebar collapseBelow="md">Navigation</Sidebar>);

      expect(screen.getByRole('dialog').query()).toBeNull();
      expect(screen.getByRole('complementary').query()).toBeNull();
    });

    // The children exist once whichever shape the sidebar is in: rendering both
    // and hiding one is what makes a screen reader read a navigation twice.
    it('holds its content in one place, not two', async () => {
      await widen(NARROW);
      const screen = await render(
        <Sidebar collapseBelow="md" defaultOpen>
          <a href="/docs">Docs</a>
        </Sidebar>
      );

      await expect.element(screen.getByRole('link', { name: 'Docs' })).toBeInTheDocument();
      expect(screen.getByRole('link', { name: 'Docs' }).elements()).toHaveLength(1);
    });

    it('goes back to being a column when the window is wide enough again', async () => {
      await widen(NARROW);
      const screen = await render(
        <Sidebar collapseBelow="md" defaultOpen>
          Navigation
        </Sidebar>
      );

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();

      await widen(WIDE);

      await expect.element(screen.getByRole('complementary')).toBeInTheDocument();
    });

    /**
     * The worst shape a dropped prop takes: it survives on the wide screen the
     * component was developed against and vanishes on the narrow one. The
     * column spread what it was handed and the drawer did not, so a caller's
     * `id`, `data-*` or `aria-*` was there until the window got small.
     */
    it('carries the props it was handed into the drawer, as the column does', async () => {
      await widen(WIDE);
      const screen = await render(
        <Sidebar collapseBelow="md" defaultOpen id="nav" data-analytics="sidebar">
          Navigation
        </Sidebar>
      );

      await expect.element(screen.getByRole('complementary')).toHaveAttribute('id', 'nav');

      await widen(NARROW);

      await expect.element(screen.getByRole('dialog')).toHaveAttribute('id', 'nav');
      expect(screen.getByRole('dialog').element()).toHaveAttribute('data-analytics', 'sidebar');
    });

    it('reports the drawer opening and closing', async () => {
      await widen(NARROW);
      const onOpenChange = vi.fn();
      const screen = await render(
        <Sidebar collapseBelow="md" defaultOpen onOpenChange={onOpenChange}>
          Navigation
        </Sidebar>
      );

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
      await userEvent.keyboard('{Escape}');

      expect(onOpenChange).toHaveBeenCalledWith(false);
    });
  });

  describe('inside a layout', () => {
    it('takes the side it was handed to, without being told twice', async () => {
      const screen = await render(
        <PageLayout collapseBelow="none" endSidebar={<Sidebar label="Contents" />}>
          Page
        </PageLayout>
      );

      expect(screen.getByRole('complementary', { name: 'Contents' }).element()).toHaveClass(
        'border-s'
      );
    });

    it('opens from a trigger anywhere on the page', async () => {
      await widen(NARROW);
      const screen = await render(
        <PageLayout
          collapseBelow="md"
          header={<SidebarTrigger />}
          sidebar={<Sidebar>Navigation</Sidebar>}
        >
          Page
        </PageLayout>
      );

      expect(screen.getByRole('dialog').query()).toBeNull();

      await screen.getByRole('button', { name: 'Open sidebar' }).click();

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    });

    it('inherits the layout language', async () => {
      await widen(NARROW);
      const screen = await render(
        <PageLayout collapseBelow="md" locale="ko" header={<SidebarTrigger />}>
          Page
        </PageLayout>
      );

      await expect
        .element(screen.getByRole('button', { name: '사이드바 열기' }))
        .toBeInTheDocument();
    });
  });
});

describe('SidebarTrigger', () => {
  it('renders nothing outside a layout, having nothing to open', async () => {
    const screen = await render(<SidebarTrigger />);

    expect(screen.getByRole('button').query()).toBeNull();
  });

  // A trigger whose presence depended on `matchMedia` would be absent from the
  // markup a server sends and would pop into the header a moment later.
  it('is hidden above the breakpoint by a class rather than by being absent', async () => {
    const screen = await render(
      <PageLayout collapseBelow="md" header={<SidebarTrigger />}>
        Page
      </PageLayout>
    );

    expect(screen.getByRole('button').element()).toHaveClass('md:hidden');
  });

  it('says whether the sidebar it opens is open', async () => {
    await page.viewport(NARROW, 800);
    const screen = await render(
      <PageLayout
        collapseBelow="md"
        header={<SidebarTrigger data-testid="trigger" />}
        sidebar={<Sidebar>Nav</Sidebar>}
      >
        Page
      </PageLayout>
    );

    const trigger = screen.getByTestId('trigger');

    await expect.element(trigger).toHaveAttribute('aria-expanded', 'false');
    await trigger.click();

    await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    await expect.element(trigger).toHaveAttribute('aria-expanded', 'true');

    await page.viewport(WIDE, 800);
  });
});
