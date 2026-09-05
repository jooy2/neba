import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Carousel } from 'neba';
import { ko, registerMessages } from 'neba/locales';

/* The library ships English; a `locale` prop answers for a language the
   project has registered. These assertions are about the prop, so the
   languages they name are registered here the way a consumer would. */
registerMessages('ko', ko);

/** Three slides with something findable in each. */
const slides = [<p key="a">Alpha</p>, <p key="b">Bravo</p>, <p key="c">Charlie</p>];

describe('Carousel', () => {
  describe('rendering', () => {
    it('renders a named carousel region', async () => {
      const screen = await render(<Carousel label="Gallery">{slides}</Carousel>);

      await expect.element(screen.getByRole('region', { name: 'Gallery' })).toBeInTheDocument();
    });

    it('wraps every top-level child in a slide of its own', async () => {
      const screen = await render(<Carousel>{slides}</Carousel>);

      await expect.element(screen.getByRole('group', { name: 'Slide 1 of 3' })).toBeInTheDocument();
      await expect.element(screen.getByRole('group', { name: 'Slide 3 of 3' })).toBeInTheDocument();
    });

    it('keeps every slide in the document, so nothing is unreachable', async () => {
      const screen = await render(<Carousel>{slides}</Carousel>);

      await expect.element(screen.getByText('Alpha')).toBeInTheDocument();
      await expect.element(screen.getByText('Charlie')).toBeInTheDocument();
    });

    it('reflects a changed set of slides on re-render', async () => {
      const screen = await render(<Carousel>{slides}</Carousel>);

      await screen.rerender(
        <Carousel>
          <p>Delta</p>
        </Carousel>
      );

      await expect.element(screen.getByText('Delta')).toBeInTheDocument();
      expect(screen.getByText('Alpha').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Carousel className="my-own-class">{slides}</Carousel>);

      expect(screen.getByRole('region').element()).toHaveClass('my-own-class');
    });

    it('names each slide through slideLabel', async () => {
      const screen = await render(
        <Carousel slideLabel={(index, count) => `${index}/${count}`}>{slides}</Carousel>
      );

      await expect.element(screen.getByRole('group', { name: '2/3' })).toBeInTheDocument();
    });
  });

  describe('chrome', () => {
    it('draws arrows and dots by default', async () => {
      const screen = await render(<Carousel>{slides}</Carousel>);

      await expect
        .element(screen.getByRole('button', { name: 'Previous slide' }))
        .toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Next slide' })).toBeInTheDocument();
      await expect
        .element(screen.getByRole('button', { name: 'Slide 2 of 3' }))
        .toBeInTheDocument();
    });

    it('drops them when asked', async () => {
      const screen = await render(
        <Carousel arrows={false} indicators={false}>
          {slides}
        </Carousel>
      );

      expect(screen.getByRole('button', { name: 'Next slide' }).query()).toBeNull();
      expect(screen.getByRole('button', { name: 'Slide 2 of 3' }).query()).toBeNull();
    });

    it('has nothing to steer with a single slide', async () => {
      const screen = await render(
        <Carousel>
          <p>Only</p>
        </Carousel>
      );

      expect(screen.getByRole('button', { name: 'Next slide' }).query()).toBeNull();
    });
  });

  describe('navigation', () => {
    it('moves to the next slide and marks its dot as current', async () => {
      const screen = await render(<Carousel>{slides}</Carousel>);

      await expect
        .element(screen.getByRole('button', { name: 'Slide 1 of 3' }))
        .toHaveAttribute('aria-current', 'true');

      await screen.getByRole('button', { name: 'Next slide' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Slide 2 of 3' }))
        .toHaveAttribute('aria-current', 'true');
    });

    it('jumps straight to a slide from its dot', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<Carousel onValueChange={onValueChange}>{slides}</Carousel>);

      await screen.getByRole('button', { name: 'Slide 3 of 3' }).click();

      expect(onValueChange).toHaveBeenLastCalledWith(2);
    });

    it('wraps at the ends while looping', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<Carousel onValueChange={onValueChange}>{slides}</Carousel>);

      await screen.getByRole('button', { name: 'Previous slide' }).click();

      expect(onValueChange).toHaveBeenLastCalledWith(2);
    });

    it('goes inert at the ends when it does not loop', async () => {
      const screen = await render(<Carousel loop={false}>{slides}</Carousel>);

      await expect.element(screen.getByRole('button', { name: 'Previous slide' })).toBeDisabled();
      await expect.element(screen.getByRole('button', { name: 'Next slide' })).toBeEnabled();
    });

    it('honours a controlled value and does not move on its own', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Carousel value={1} onValueChange={onValueChange}>
          {slides}
        </Carousel>
      );

      await expect
        .element(screen.getByRole('button', { name: 'Slide 2 of 3' }))
        .toHaveAttribute('aria-current', 'true');

      await screen.getByRole('button', { name: 'Next slide' }).click();

      expect(onValueChange).toHaveBeenLastCalledWith(2);
      // The parent said 1 and never said otherwise, so 1 is where it stays.
      await expect
        .element(screen.getByRole('button', { name: 'Slide 2 of 3' }))
        .toHaveAttribute('aria-current', 'true');
    });

    it('starts on defaultValue', async () => {
      const screen = await render(<Carousel defaultValue={2}>{slides}</Carousel>);

      await expect
        .element(screen.getByRole('button', { name: 'Slide 3 of 3' }))
        .toHaveAttribute('aria-current', 'true');
    });
  });

  describe('style props', () => {
    it('maps color and elevation onto the surface slots', async () => {
      const screen = await render(
        <Carousel color="success" elevation={2}>
          {slides}
        </Carousel>
      );
      const element = screen.getByRole('region').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-line')).toBe('var(--neba-success-line)');
      expect(element.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-2)');
    });

    it('never applies a transform, so no slide is resampled', async () => {
      const screen = await render(<Carousel>{slides}</Carousel>);

      expect(screen.getByRole('region').element().innerHTML).not.toContain('translate-x');
    });
  });

  /*
   * WCAG 2.2.2 asks for a mechanism to stop anything that starts moving on its
   * own, and hover and focus are not one: neither exists for a reader holding a
   * phone, and a magnified reader may never put the pointer over the strip at
   * all. So `autoPlay` draws a button, and the button is the first thing in the
   * frame.
   */
  describe('autoPlay', () => {
    it('draws no rotation control when it is not rotating', async () => {
      const screen = await render(<Carousel>{slides}</Carousel>);

      expect(screen.getByRole('button', { name: 'Pause slide show' }).query()).toBeNull();
    });

    // A strip of one has nowhere to go, so a button claiming to stop it would
    // have nothing behind it.
    it('draws none for a single slide', async () => {
      const screen = await render(<Carousel autoPlay>{slides.slice(0, 1)}</Carousel>);

      expect(screen.getByRole('button', { name: 'Pause slide show' }).query()).toBeNull();
    });

    it('draws one that says what it will do', async () => {
      const screen = await render(<Carousel autoPlay>{slides}</Carousel>);

      await expect
        .element(screen.getByRole('button', { name: 'Pause slide show' }))
        .toBeInTheDocument();
    });

    it('swaps its name once the slides have been stopped', async () => {
      const screen = await render(<Carousel autoPlay>{slides}</Carousel>);

      await screen.getByRole('button', { name: 'Pause slide show' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Play slide show' }))
        .toBeInTheDocument();
    });

    /*
     * First in the frame and therefore first in the tab order, so a reader on a
     * keyboard meets the way to stop the slides before they meet the slides.
     * Read off DOM order rather than by tabbing, since the strip's own arrows
     * sit between the two.
     */
    it('puts the control before the strip', async () => {
      const screen = await render(<Carousel autoPlay>{slides}</Carousel>);

      const control = screen.getByRole('button', { name: 'Pause slide show' }).element();
      const strip = screen.getByRole('group', { name: 'Carousel' }).element();

      expect(control.compareDocumentPosition(strip)).toBe(Node.DOCUMENT_POSITION_FOLLOWING);
    });

    /*
     * The pointer and the focus each pause the strip on their own, so a test
     * about the timer has to keep both off it — including after the click that
     * stops it, which puts both back. The button beside the carousel is
     * somewhere to park them; without it this passes whether or not the control
     * does anything, because a carousel under the pointer was never advancing.
     */
    /*
     * The control is positioned by a wrapper, and it has to be. Every Button
     * root carries `relative`, Tailwind emits `.relative` after `.absolute`,
     * and two utilities of equal specificity are decided by the stylesheet
     * rather than by the class attribute — so an `absolute` written on the
     * button itself loses, and loses silently: the control stays in the flow
     * and pushes the whole strip down by its own height.
     */
    it('positions the control from a wrapper and not from the button', async () => {
      const screen = await render(<Carousel autoPlay>{slides}</Carousel>);

      const control = screen.getByRole('button', { name: 'Pause slide show' }).element();

      expect(control.className).not.toContain('absolute');
      expect(control.parentElement?.className).toContain('absolute');
    });

    it('advances on its own, and stops for good when it is told to', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <>
          <button type="button">Away</button>
          <Carousel autoPlay interval={80} onValueChange={onValueChange}>
            {slides}
          </Carousel>
        </>
      );

      const away = screen.getByRole('button', { name: 'Away' });

      await away.click();
      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalled());

      await screen.getByRole('button', { name: 'Pause slide show' }).click();
      await away.click();
      onValueChange.mockClear();

      await new Promise((resolve) => setTimeout(resolve, 260));

      expect(onValueChange).not.toHaveBeenCalled();
    });

    // The live region is silent while the slides move on their own, because one
    // that names a slide every five seconds is what makes a page unusable with a
    // screen reader. Stopping them is what turns it back on.
    it('starts announcing the slide again once it is stopped', async () => {
      const screen = await render(<Carousel autoPlay>{slides}</Carousel>);

      const region = screen.getByRole('region').element();
      const live = () => region.querySelector('[aria-live]');

      expect(live()?.getAttribute('aria-live')).toBe('off');

      await screen.getByRole('button', { name: 'Pause slide show' }).click();

      expect(live()?.getAttribute('aria-live')).toBe('polite');
    });

    it('takes words of its own over the locale', async () => {
      const screen = await render(
        <Carousel autoPlay locale="ko" pauseLabel="Hold">
          {slides}
        </Carousel>
      );

      await expect.element(screen.getByRole('button', { name: 'Hold' })).toBeInTheDocument();
    });
  });

  describe('locale', () => {
    it('names the control in the language it was given', async () => {
      const screen = await render(
        <Carousel autoPlay locale="ko">
          {slides}
        </Carousel>
      );

      await expect
        .element(screen.getByRole('button', { name: '슬라이드 쇼 일시정지' }))
        .toBeInTheDocument();
    });

    it('names the region, the arrows and every slide in the language it was given', async () => {
      const screen = await render(<Carousel locale="ko">{slides}</Carousel>);

      await expect.element(screen.getByRole('region', { name: '캐러셀' })).toBeInTheDocument();
      await expect
        .element(screen.getByRole('group', { name: '전체 3장 중 1장' }))
        .toBeInTheDocument();
      await expect
        .element(screen.getByRole('button', { name: '이전 슬라이드' }))
        .toBeInTheDocument();
    });

    it('takes words of its own over the locale', async () => {
      const screen = await render(
        <Carousel locale="ko" label="Gallery" slideLabel={(index) => `Photo ${index}`}>
          {slides}
        </Carousel>
      );

      await expect.element(screen.getByRole('region', { name: 'Gallery' })).toBeInTheDocument();
      await expect.element(screen.getByRole('group', { name: 'Photo 1' })).toBeInTheDocument();
    });
  });
});
