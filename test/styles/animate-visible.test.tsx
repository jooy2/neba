/**
 * A `trigger="visible"` entrance under the stylesheet, which is where its first
 * frame comes from.
 *
 * The observer that starts it measures the element as drawn, and a waiting
 * entrance is drawn on its first frame: a slide a full width to one side, a
 * fade at an opacity of `0` over a box taller than the screen. No component
 * test loads the stylesheet, so none of them can see an element that never
 * starts.
 */
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateFade, AnimateSlide, AnimateZoom } from 'neba';
import standaloneCss from '../../src/standalone.css?inline';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

// A test that scrolls leaves the next one starting wherever it stopped.
afterEach(() => {
  window.scrollTo(0, 0);
});

const content = <div style={{ height: 40 }}>Content</div>;

describe('a visible trigger under the stylesheet', () => {
  it('starts a full-width slide from either side once its own box is in view', async () => {
    const screen = await render(
      <>
        <AnimateSlide from="left" trigger="visible" data-testid="left">
          {content}
        </AnimateSlide>
        <AnimateSlide from="right" trigger="visible" data-testid="right">
          {content}
        </AnimateSlide>
      </>
    );

    await expect.element(screen.getByTestId('left')).toHaveAttribute('data-state', 'running');
    await expect.element(screen.getByTestId('right')).toHaveAttribute('data-state', 'running');
  });

  // The arrangement the component documents for a panel coming in from behind
  // an edge. The clip hid the whole first frame from the observer.
  it('starts a slide inside a box that clips it', async () => {
    const screen = await render(
      <div style={{ overflow: 'hidden' }}>
        <AnimateSlide from="bottom" trigger="visible" data-testid="slide">
          {content}
        </AnimateSlide>
      </div>
    );

    await expect.element(screen.getByTestId('slide')).toHaveAttribute('data-state', 'running');
  });

  // A slide that does not fade is seen on its first frame, so it keeps it, and
  // the screen it is measured against moves instead. That cannot be shown here:
  // these tests run in a frame, whose edge clips a first frame drawn outside it
  // before any margin on the root applies. `test/internal/animate.test.ts`
  // checks the margin.

  // A fifth of something six screens tall is more than a screen can show. A
  // zoom waits shrunk to the middle of its box, so the top of the box can be on
  // screen with none of the first frame anywhere near it.
  it('starts an element taller than the screen', async () => {
    const screen = await render(
      <>
        <AnimateFade trigger="visible" data-testid="fade">
          <div style={{ height: '600vh' }} />
        </AnimateFade>
        <AnimateZoom trigger="visible" data-testid="zoom">
          <div style={{ height: '300vh' }} />
        </AnimateZoom>
      </>
    );

    await expect.element(screen.getByTestId('fade')).toHaveAttribute('data-state', 'running');

    window.scrollTo(0, (screen.getByTestId('zoom').element() as HTMLElement).offsetTop);

    await expect.element(screen.getByTestId('zoom')).toHaveAttribute('data-state', 'running');
  });

  it('leaves one that is still below the fold waiting', async () => {
    const screen = await render(
      <>
        <div style={{ height: '150vh' }} />
        <AnimateSlide from="left" trigger="visible" data-testid="below">
          {content}
        </AnimateSlide>
        <AnimateSlide from="left" fade={false} trigger="visible" data-testid="still">
          {content}
        </AnimateSlide>
      </>
    );

    await new Promise((resolve) => setTimeout(resolve, 200));

    expect(screen.getByTestId('below').element()).toHaveAttribute('data-state', 'paused');
    expect(screen.getByTestId('still').element()).toHaveAttribute('data-state', 'paused');

    screen.getByTestId('below').element().scrollIntoView();

    await expect.element(screen.getByTestId('below')).toHaveAttribute('data-state', 'running');
  });

  // Only while the first frame cannot be seen, and only until it starts.
  it('holds the box in place only while an unseen first frame waits', async () => {
    const screen = await render(
      <>
        <div style={{ height: '150vh' }} />
        <AnimateSlide from="left" trigger="visible" data-testid="unseen">
          {content}
        </AnimateSlide>
        <AnimateSlide from="left" fade={false} trigger="visible" data-testid="seen">
          {content}
        </AnimateSlide>
      </>
    );
    const unseen = screen.getByTestId('unseen').element() as HTMLElement;
    const seen = screen.getByTestId('seen').element() as HTMLElement;

    expect(unseen).toHaveAttribute('data-waiting');
    expect(getComputedStyle(unseen).translate).toMatch(/^(none|0px)$/);
    expect(seen).not.toHaveAttribute('data-waiting');

    unseen.scrollIntoView();

    await expect.element(unseen).toHaveAttribute('data-state', 'running');
    expect(unseen).not.toHaveAttribute('data-waiting');
  });
});
