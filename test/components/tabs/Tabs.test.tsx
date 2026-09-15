import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
import { Tab, TabPanel, Tabs } from 'neba';

function Basic(props: React.ComponentProps<typeof Tabs>) {
  return (
    <Tabs {...props}>
      <Tab value="overview">Overview</Tab>
      <Tab value="usage">Usage</Tab>
      <Tab value="billing">Billing</Tab>
      <TabPanel value="overview">What this project is.</TabPanel>
      <TabPanel value="usage">How much you used.</TabPanel>
      <TabPanel value="billing">What you owe.</TabPanel>
    </Tabs>
  );
}

describe('Tabs', () => {
  describe('rendering', () => {
    // A panel inside a Fragment failed the type check and was put into the tab
    // list, inside `role="tablist"`.
    it('finds a panel inside a Fragment', async () => {
      const screen = await render(
        <Tabs defaultValue="overview">
          <Tab value="overview">Overview</Tab>
          <>
            <TabPanel value="overview">What this project is.</TabPanel>
          </>
        </Tabs>
      );
      const panel = screen.getByText('What this project is.').element();

      expect(screen.getByRole('tablist').element().contains(panel)).toBe(false);
    });

    it('renders a tablist of its tabs', async () => {
      const screen = await render(<Basic defaultValue="overview" />);

      await expect.element(screen.getByRole('tablist')).toBeInTheDocument();
      expect(screen.getByRole('tab').elements()).toHaveLength(3);
    });

    // Everything between the tags is either a tab or a panel, and the two go in
    // different boxes — sorted here rather than made the caller's problem.
    it('puts the panels outside the tablist', async () => {
      const screen = await render(<Basic defaultValue="overview" />);
      const list = screen.getByRole('tablist').element();

      expect(list.querySelector('[role="tabpanel"]')).toBeNull();
      await expect.element(screen.getByRole('tabpanel')).toBeInTheDocument();
    });

    it('shows only the chosen panel', async () => {
      const screen = await render(<Basic defaultValue="usage" />);

      await expect.element(screen.getByText('How much you used.')).toBeInTheDocument();
      expect(screen.getByText('What this project is.').query()).toBeNull();
    });

    it('marks the chosen tab as selected', async () => {
      const screen = await render(<Basic defaultValue="usage" />);

      await expect
        .element(screen.getByRole('tab', { name: 'Usage' }))
        .toHaveAttribute('aria-selected', 'true');
      await expect
        .element(screen.getByRole('tab', { name: 'Overview' }))
        .toHaveAttribute('aria-selected', 'false');
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(
        <Tabs defaultValue="a">
          <Tab value="a">Before</Tab>
          <TabPanel value="a">Body</TabPanel>
        </Tabs>
      );

      await screen.rerender(
        <Tabs defaultValue="a">
          <Tab value="a">After</Tab>
          <TabPanel value="a">Body</TabPanel>
        </Tabs>
      );

      await expect.element(screen.getByRole('tab', { name: 'After' })).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <Tabs defaultValue="a" className="my-own-class">
          <Tab value="a" className="my-tab-class">
            Overview
          </Tab>
          <TabPanel value="a" className="my-panel-class">
            Body
          </TabPanel>
        </Tabs>
      );

      expect(screen.container.querySelector('.my-own-class')).not.toBeNull();
      expect(screen.getByRole('tab').element()).toHaveClass('my-tab-class');
      expect(screen.getByRole('tabpanel').element()).toHaveClass('my-panel-class');
    });
  });

  describe('choosing', () => {
    it('switches the panel when a tab is pressed', async () => {
      const screen = await render(<Basic defaultValue="overview" />);

      await screen.getByRole('tab', { name: 'Billing' }).click();

      await expect.element(screen.getByText('What you owe.')).toBeInTheDocument();
      // Retried rather than queried once: the panel being left keeps its node
      // for as long as Base UI thinks an exit transition might run — it is
      // already `inert` and marked `data-ending-style` by then — and in WebKit
      // that outlasts the assertion that the new panel is up.
      await expect.element(screen.getByText('What this project is.')).not.toBeInTheDocument();
    });

    /**
     * The indicator under the bar already travels; the content under it changed
     * in a single frame. The arriving panel fades up now — and only the arriving
     * one, because a leaving panel is still in the flow and fading it out would
     * put both in the layout for the length of it.
     */
    it('fades the arriving panel up, and gives the leaving one nothing to wait for', async () => {
      const screen = await render(<Basic defaultValue="overview" />);
      const panel = screen.getByRole('tabpanel').element();

      expect(panel.className).toContain('transition:opacity');
      expect(panel).toHaveClass('data-[starting-style]:opacity-0');
      expect(panel.className).not.toContain('data-[ending-style]');
    });

    it('reports the chosen value', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<Basic defaultValue="overview" onValueChange={onValueChange} />);

      await screen.getByRole('tab', { name: 'Billing' }).click();

      expect(onValueChange).toHaveBeenCalledWith('billing');
    });

    it('follows a controlled value', async () => {
      const screen = await render(<Basic value="overview" />);

      await expect.element(screen.getByText('What this project is.')).toBeInTheDocument();

      await screen.rerender(<Basic value="billing" />);

      await expect.element(screen.getByText('What you owe.')).toBeInTheDocument();
    });

    it('does not choose a disabled tab', async () => {
      const screen = await render(
        <Tabs defaultValue="a">
          <Tab value="a">Overview</Tab>
          <Tab value="b" disabled>
            Usage
          </Tab>
          <TabPanel value="a">First</TabPanel>
          <TabPanel value="b">Second</TabPanel>
        </Tabs>
      );

      await screen.getByRole('tab', { name: 'Usage' }).click({ force: true });

      await expect.element(screen.getByText('First')).toBeInTheDocument();
    });

    it('unmounts a hidden panel unless it is told to keep it', async () => {
      const screen = await render(
        <Tabs defaultValue="a">
          <Tab value="a">Overview</Tab>
          <Tab value="b">Usage</Tab>
          <TabPanel value="a">First</TabPanel>
          <TabPanel value="b" keepMounted>
            Second
          </TabPanel>
        </Tabs>
      );

      expect(screen.container.innerHTML).toContain('Second');
    });
  });

  describe('the keyboard', () => {
    // The whole bar is one tab stop, and the arrow keys walk it. That is the
    // difference between a tab bar and a row of buttons.
    it('walks the tabs with the arrow keys', async () => {
      const screen = await render(<Basic defaultValue="overview" />);

      await screen.getByRole('tab', { name: 'Overview' }).click();
      await userEvent.keyboard('{ArrowRight}');
      await userEvent.keyboard('{Enter}');

      await expect
        .element(screen.getByRole('tab', { name: 'Usage' }))
        .toHaveAttribute('aria-selected', 'true');
    });

    // Automatic activation is only kind when every panel is already on the page.
    it('does not choose on arrow alone by default', async () => {
      const screen = await render(<Basic defaultValue="overview" />);

      await screen.getByRole('tab', { name: 'Overview' }).click();
      await userEvent.keyboard('{ArrowRight}');

      await expect
        .element(screen.getByRole('tab', { name: 'Overview' }))
        .toHaveAttribute('aria-selected', 'true');
    });

    it('chooses on arrow when activateOnFocus is set', async () => {
      const screen = await render(<Basic defaultValue="overview" activateOnFocus />);

      await screen.getByRole('tab', { name: 'Overview' }).click();
      await userEvent.keyboard('{ArrowRight}');

      await expect
        .element(screen.getByRole('tab', { name: 'Usage' }))
        .toHaveAttribute('aria-selected', 'true');
    });
  });

  describe('orientation', () => {
    // `aria-orientation` is only spelled out for the vertical case — horizontal
    // is a tablist's implied default, and saying it out loud adds nothing.
    it('runs horizontally by default', async () => {
      const screen = await render(<Basic defaultValue="overview" />);

      await expect
        .element(screen.getByRole('tab', { name: 'Overview' }))
        .toHaveAttribute('data-orientation', 'horizontal');
      expect(screen.getByRole('tablist').element()).not.toHaveClass('flex-col');
    });

    it('runs vertically when asked, and tells a reader so', async () => {
      const screen = await render(<Basic defaultValue="overview" orientation="vertical" />);

      await expect
        .element(screen.getByRole('tablist'))
        .toHaveAttribute('aria-orientation', 'vertical');
      expect(screen.getByRole('tablist').element()).toHaveClass('flex-col');
    });

    it('puts the panel beside the bar when vertical', async () => {
      const screen = await render(
        <Basic defaultValue="overview" orientation="vertical" className="probe" />
      );

      expect(screen.container.querySelector('.probe')).toHaveClass('flex-row');
    });
  });

  describe('more tabs than room', () => {
    /*
     * A bar that overflows already scrolled; what it had no way of saying was
     * that it had. The scrollbar is hidden — a horizontal rail under a tab bar
     * is furniture on Windows and invisible on macOS — so the ends fade instead,
     * through the same two masks ScrollArea uses.
     */
    it('stays one line and scrolls by default', async () => {
      const screen = await render(<Basic defaultValue="overview" />);
      const list = screen.getByRole('tablist').element();

      expect(list).toHaveClass('overflow-x-auto');
      expect(list).toHaveClass('neba-scroll-fade');
      expect(list).not.toHaveClass('flex-wrap');
    });

    it('wraps when it is told to, and stops scrolling sideways', async () => {
      const screen = await render(<Basic defaultValue="overview" overflow="wrap" />);
      const list = screen.getByRole('tablist').element();

      expect(list).toHaveClass('flex-wrap');
      expect(list).not.toHaveClass('overflow-x-auto');
    });

    // The cap is in rows, and a row is the control height ladder — the same one
    // a `md` tab and a `md` Button share.
    it('caps a wrapping bar at the number of rows it was given', async () => {
      const screen = await render(
        <Basic defaultValue="overview" overflow="wrap" lines={2} variant="text" />
      );
      const list = screen.getByRole('tablist').element() as HTMLElement;

      expect(list.style.maxHeight).toBe('calc(4rem)');
      expect(list).toHaveClass('overflow-y-auto');
    });

    // The outline bar's 1px rule was left out of the cap, so the rows it named
    // did not fit and the bar scrolled by a pixel.
    it('counts the rule under an outline bar into the cap', async () => {
      const screen = await render(
        <Basic defaultValue="overview" overflow="wrap" lines={2} variant="outline" />
      );
      const list = screen.getByRole('tablist').element() as HTMLElement;

      expect(list.style.maxHeight).toBe('calc(1px + 4rem)');
    });

    it('ignores lines on a bar that does not wrap', async () => {
      const screen = await render(<Basic defaultValue="overview" lines={2} />);
      const list = screen.getByRole('tablist').element() as HTMLElement;

      expect(list.style.maxHeight).toBe('');
    });

    // `bottom-0` is the bottom of the list, which is the bottom of the active
    // tab only while there is one row.
    it('moves the rule onto the active tab when the bar wraps', async () => {
      const screen = await render(<Basic defaultValue="overview" overflow="wrap" />);
      const indicator = screen.getByRole('tablist').element().lastElementChild;

      expect(indicator).toHaveClass('border-b-2');
      expect(indicator).not.toHaveClass('bottom-0');
    });
  });

  describe('style props', () => {
    it('gives the bar a trough when solid', async () => {
      const screen = await render(<Basic defaultValue="overview" variant="solid" />);

      expect(screen.getByRole('tablist').element()).toHaveClass('bg-(--n-panel)');
    });

    it('gives the bar a rule when outline', async () => {
      const screen = await render(<Basic defaultValue="overview" variant="outline" />);

      expect(screen.getByRole('tablist').element()).toHaveClass('border-b');
    });

    it('takes its size from the set rather than from the tab', async () => {
      const screen = await render(<Basic defaultValue="overview" size="xl" />);

      expect(screen.getByRole('tab', { name: 'Overview' }).element()).toHaveClass('h-12');
    });

    it('takes its density from the set', async () => {
      const screen = await render(<Basic defaultValue="overview" density="compact" />);

      expect(screen.getByRole('tab', { name: 'Overview' }).element()).toHaveClass('px-2.5');
    });

    it('shares the bar between the tabs when fullWidth', async () => {
      const screen = await render(<Basic defaultValue="overview" fullWidth />);

      expect(screen.getByRole('tab', { name: 'Overview' }).element()).toHaveClass('flex-1');
    });

    it('maps its colour onto the token slots', async () => {
      const screen = await render(
        <Basic defaultValue="overview" color="success" className="probe" />
      );
      const element = screen.container.querySelector('.probe') as HTMLElement;

      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-success-accent)');
    });

    // The indicator moves by animating left/top and width/height, which is a
    // layout animation on an empty box — never a transform on a label.
    it('never applies a transform', async () => {
      const screen = await render(<Basic defaultValue="usage" variant="solid" />);

      expect(screen.getByRole('tablist').element().outerHTML).not.toContain('translate');
    });
  });

  /*
   * A wheel is dispatched rather than rolled, for the reason ScrollZone's own
   * tests give: `page.mouse.wheel` scrolls the frame, and what is asserted here
   * is what the bar did with the event.
   */
  describe('the wheel', () => {
    function Crowded(props: React.ComponentProps<typeof Tabs>) {
      return (
        <Tabs defaultValue="t0" {...props}>
          {Array.from({ length: 12 }, (_, index) => (
            <Tab key={index} value={`t${index}`}>{`Section ${index}`}</Tab>
          ))}
          <TabPanel value="t0">The first one.</TabPanel>
        </Tabs>
      );
    }

    /*
     * The bar's overflow is made here rather than left to the component,
     * because no component test loads CSS: `overflow-x-auto` and the flex row
     * are class names that resolve to nothing, so twelve tabs wrap onto twelve
     * lines and the bar is exactly as wide as its box. What the handler reads
     * is the geometry, so the geometry is what the test has to supply.
     */
    function crowd(screen: Awaited<ReturnType<typeof render>>) {
      const list = screen.getByRole('tablist').element() as HTMLElement;

      list.style.width = '120px';
      list.style.overflowX = 'auto';
      list.style.whiteSpace = 'nowrap';

      return list;
    }

    function roll(box: HTMLElement, init: WheelEventInit) {
      const event = new WheelEvent('wheel', { bubbles: true, cancelable: true, ...init });
      box.dispatchEvent(event);

      return event;
    }

    it('turns a wheel rolled down the page into travel along the bar', async () => {
      const screen = await render(<Crowded />);
      const list = crowd(screen);
      const scrollBy = vi.spyOn(list, 'scrollBy');

      expect(roll(list, { deltaY: 120 }).defaultPrevented).toBe(true);
      expect(scrollBy).toHaveBeenCalledWith(expect.objectContaining({ left: 120 }));
    });

    // The bar is at its start, so there is nothing behind it — and the page
    // still does not get the wheel, because the pointer is over the bar.
    it('holds the wheel at the end of the bar', async () => {
      const screen = await render(<Crowded />);
      const list = crowd(screen);

      expect(roll(list, { deltaY: -120 }).defaultPrevented).toBe(true);
    });

    // Which is what makes it safe to leave on: three tabs in a row are not a
    // scroll container as far as the reader is concerned.
    it('holds nothing on a bar that fits', async () => {
      const screen = await render(<Basic defaultValue="overview" />);
      const list = screen.getByRole('tablist').element() as HTMLElement;
      const scrollBy = vi.spyOn(list, 'scrollBy');

      expect(roll(list, { deltaY: 120 }).defaultPrevented).toBe(false);
      expect(scrollBy).not.toHaveBeenCalled();
    });

    it('leaves a sideways wheel to the browser, which already scrolls the bar', async () => {
      const screen = await render(<Crowded />);
      const list = crowd(screen);
      const scrollBy = vi.spyOn(list, 'scrollBy');

      expect(roll(list, { deltaX: 120, deltaY: 4 }).defaultPrevented).toBe(false);
      expect(scrollBy).not.toHaveBeenCalled();
    });

    it('leaves the wheel alone when it is turned off', async () => {
      const screen = await render(<Crowded wheel={false} />);
      const list = crowd(screen);
      const scrollBy = vi.spyOn(list, 'scrollBy');

      expect(roll(list, { deltaY: 120 }).defaultPrevented).toBe(false);
      expect(scrollBy).not.toHaveBeenCalled();
    });
  });
});
