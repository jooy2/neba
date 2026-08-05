import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateMarquee } from 'neba';

describe('AnimateMarquee', () => {
  describe('rendering', () => {
    it('says which effect it is running', async () => {
      const screen = await render(
        <AnimateMarquee data-testid="marquee">
          <span>Alpha</span>
        </AnimateMarquee>
      );

      expect(screen.getByTestId('marquee').element()).toHaveAttribute(
        'data-neba-animation',
        'marquee'
      );
    });

    // Two copies is what makes the loop seamless: when the first has travelled
    // its own length the second is standing exactly where it began.
    it('lays the content down twice by default', async () => {
      const screen = await render(
        <AnimateMarquee data-testid="marquee">
          <span>Alpha</span>
        </AnimateMarquee>
      );
      const tracks = screen
        .getByTestId('marquee')
        .element()
        .querySelectorAll('.neba-marquee-track');

      expect(tracks).toHaveLength(2);
    });

    it('lays it down as many times as it was asked to', async () => {
      const screen = await render(
        <AnimateMarquee copies={4} data-testid="marquee">
          <span>Alpha</span>
        </AnimateMarquee>
      );
      const tracks = screen
        .getByTestId('marquee')
        .element()
        .querySelectorAll('.neba-marquee-track');

      expect(tracks).toHaveLength(4);
    });

    // Otherwise a screen reader announces the whole strip as many times as it
    // was laid down.
    it('reads only the first copy out', async () => {
      const screen = await render(
        <AnimateMarquee data-testid="marquee">
          <span>Alpha</span>
        </AnimateMarquee>
      );
      const tracks = screen
        .getByTestId('marquee')
        .element()
        .querySelectorAll('.neba-marquee-track');

      expect(tracks[0]).not.toHaveAttribute('aria-hidden');
      expect(tracks[1]).toHaveAttribute('aria-hidden', 'true');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <AnimateMarquee className="my-own-class" data-testid="marquee">
          <span>Alpha</span>
        </AnimateMarquee>
      );
      const element = screen.getByTestId('marquee').element();

      expect(element).toHaveClass('my-own-class');
      expect(element).toHaveClass('neba-marquee');
    });
  });

  describe('settings', () => {
    it('runs down the page when vertical', async () => {
      const screen = await render(
        <AnimateMarquee orientation="vertical" data-testid="marquee">
          <span>Alpha</span>
        </AnimateMarquee>
      );

      expect(screen.getByTestId('marquee').element()).toHaveClass('neba-marquee-vertical');
    });

    it('puts the gap where both the layout and the loop can read it', async () => {
      const screen = await render(
        <AnimateMarquee gap={40} data-testid="marquee">
          <span>Alpha</span>
        </AnimateMarquee>
      );
      const element = screen.getByTestId('marquee').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-gap')).toBe('40px');
    });

    it('runs the other way when reversed', async () => {
      const screen = await render(
        <AnimateMarquee reverse data-testid="marquee">
          <span>Alpha</span>
        </AnimateMarquee>
      );
      const element = screen.getByTestId('marquee').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-direction')).toBe('reverse');
    });

    // A link inside a strip that never stops is a link nobody can follow.
    it('stops under the pointer unless that is turned off', async () => {
      const screen = await render(
        <AnimateMarquee data-testid="marquee">
          <span>Alpha</span>
        </AnimateMarquee>
      );

      expect(screen.getByTestId('marquee').element()).toHaveAttribute('data-pause-on-hover');

      await screen.rerender(
        <AnimateMarquee pauseOnHover={false} data-testid="marquee">
          <span>Alpha</span>
        </AnimateMarquee>
      );

      expect(screen.getByTestId('marquee').element()).not.toHaveAttribute('data-pause-on-hover');
    });

    it('takes an explicit duration over the measured one', async () => {
      const screen = await render(
        <AnimateMarquee duration={5000} data-testid="marquee">
          <span>Alpha</span>
        </AnimateMarquee>
      );
      const element = screen.getByTestId('marquee').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-duration')).toBe('5000ms');
    });

    // A speed rather than a duration, so a long strip and a short one move at
    // the same pace instead of in the same time. No stylesheet is loaded here,
    // so the track is a plain block and its width is the box's — which is
    // exactly the measurement being asserted on.
    it('works its own duration out from the speed and the width', async () => {
      const screen = await render(
        <AnimateMarquee speed={100} gap={0} style={{ width: 300 }} data-testid="marquee">
          <span>Alpha</span>
        </AnimateMarquee>
      );

      await expect
        .poll(() =>
          (screen.getByTestId('marquee').element() as HTMLElement).style.getPropertyValue(
            '--n-anim-duration'
          )
        )
        .toBe('3000ms');
    });
  });
});
