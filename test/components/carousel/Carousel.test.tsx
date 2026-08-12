import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Carousel } from 'neba';

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

  describe('locale', () => {
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
