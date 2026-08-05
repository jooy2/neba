import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Mockup } from 'neba';

/** The root, and the glass inside it. */
function parts(root: HTMLElement) {
  return {
    root,
    screen: root.querySelector('.neba-mockup-screen') as HTMLElement,
    cutout: root.querySelector('.neba-mockup-cutout') as HTMLElement | null
  };
}

describe('Mockup', () => {
  describe('rendering', () => {
    it('renders a div with its children on the screen', async () => {
      const screen = await render(
        <Mockup data-testid="mockup" device="mobile">
          <span>App</span>
        </Mockup>
      );
      const root = screen.getByTestId('mockup').element() as HTMLElement;

      expect(root.tagName).toBe('DIV');
      await expect.element(screen.getByText('App')).toBeInTheDocument();
      expect(parts(root).screen.contains(screen.getByText('App').element())).toBe(true);
    });

    it('renders something else through render', async () => {
      const screen = await render(
        <Mockup data-testid="mockup" device="mobile" render={<figure />} />
      );

      expect((screen.getByTestId('mockup').element() as HTMLElement).tagName).toBe('FIGURE');
    });

    it('passes native attributes through', async () => {
      const screen = await render(<Mockup data-testid="mockup" device="tablet" id="preview" />);

      expect((screen.getByTestId('mockup').element() as HTMLElement).id).toBe('preview');
    });

    it('keeps a caller class alongside its own', async () => {
      const screen = await render(
        <Mockup data-testid="mockup" device="mobile" className="mx-auto" />
      );
      const root = screen.getByTestId('mockup').element();

      expect(root).toHaveClass('mx-auto');
      expect(root).toHaveClass('neba-mockup');
    });
  });

  describe('the screen', () => {
    it('is laid out at the resolution it was given', async () => {
      const screen = await render(
        <Mockup data-testid="mockup" device="mobile" resolution={{ width: 400, height: 800 }} />
      );

      expect(parts(screen.getByTestId('mockup').element() as HTMLElement).screen.style.width).toBe(
        '400px'
      );
    });

    it('takes a step of the ladder when no resolution is given', async () => {
      const screen = await render(<Mockup data-testid="mockup" device="mobile" size="md" />);
      const md = parts(screen.getByTestId('mockup').element() as HTMLElement).screen.style.width;

      await screen.rerender(<Mockup data-testid="mockup" device="mobile" size="xl" />);
      const xl = parts(screen.getByTestId('mockup').element() as HTMLElement).screen.style.width;

      expect(md).not.toBe(xl);
      expect(parseInt(xl, 10)).toBeGreaterThan(parseInt(md, 10));
    });

    it('swaps its axes in landscape', async () => {
      const screen = await render(
        <Mockup
          data-testid="mockup"
          device="mobile"
          orientation="landscape"
          resolution={{ width: 400, height: 800 }}
        />
      );
      const glass = parts(screen.getByTestId('mockup').element() as HTMLElement).screen;

      expect(glass.style.width).toBe('800px');
      expect(glass.style.height).toBe('400px');
    });

    it('leaves a desktop alone, whose stand does not turn with it', async () => {
      const screen = await render(
        <Mockup
          data-testid="mockup"
          device="desktop"
          orientation="landscape"
          resolution={{ width: 1200, height: 800 }}
        />
      );

      expect(parts(screen.getByTestId('mockup').element() as HTMLElement).screen.style.width).toBe(
        '1200px'
      );
    });

    it('reflects a changed resolution on re-render', async () => {
      const screen = await render(
        <Mockup data-testid="mockup" device="tablet" resolution={{ width: 800, height: 1200 }} />
      );

      await screen.rerender(
        <Mockup data-testid="mockup" device="tablet" resolution={{ width: 900, height: 1200 }} />
      );

      expect(parts(screen.getByTestId('mockup').element() as HTMLElement).screen.style.width).toBe(
        '900px'
      );
    });

    it('is a container, so content can answer to the device rather than the window', async () => {
      const screen = await render(
        <Mockup data-testid="mockup" device="mobile">
          <span>App</span>
        </Mockup>
      );
      const content = screen.getByText('App').element().parentElement as HTMLElement;

      expect(content.style.containerName).toBe('neba-screen');
    });
  });

  describe('the frame', () => {
    // With no hardware the frame *is* the screen, which is the one case where
    // the proportion can be asserted without pinning a bezel table.
    it('is the screen itself when there is no hardware', async () => {
      const screen = await render(
        <Mockup
          data-testid="mockup"
          device="mobile"
          bezel="none"
          resolution={{ width: 400, height: 800 }}
        />
      );

      expect((screen.getByTestId('mockup').element() as HTMLElement).style.aspectRatio).toBe(
        '400 / 800'
      );
    });

    it('grows around the screen once there is a bezel', async () => {
      const screen = await render(
        <Mockup
          data-testid="mockup"
          device="mobile"
          bezel="thick"
          resolution={{ width: 400, height: 800 }}
        />
      );

      expect((screen.getByTestId('mockup').element() as HTMLElement).style.aspectRatio).not.toBe(
        '400 / 800'
      );
    });

    it('is a different shape on a laptop than on a monitor', async () => {
      const screen = await render(
        <Mockup data-testid="mockup" device="desktop" hardware="monitor" />
      );
      const monitor = (screen.getByTestId('mockup').element() as HTMLElement).style.aspectRatio;

      await screen.rerender(<Mockup data-testid="mockup" device="desktop" hardware="laptop" />);

      expect((screen.getByTestId('mockup').element() as HTMLElement).style.aspectRatio).not.toBe(
        monitor
      );
    });

    it('ignores hardware on a handheld, which holds itself up', async () => {
      const screen = await render(
        <Mockup data-testid="mockup" device="mobile" hardware="monitor" />
      );
      const monitor = (screen.getByTestId('mockup').element() as HTMLElement).style.aspectRatio;

      await screen.rerender(<Mockup data-testid="mockup" device="mobile" hardware="laptop" />);

      expect((screen.getByTestId('mockup').element() as HTMLElement).style.aspectRatio).toBe(
        monitor
      );
    });
  });

  describe('the cut-out', () => {
    it('is a dynamic island on an iOS phone', async () => {
      const screen = await render(<Mockup data-testid="mockup" device="mobile" os="ios" />);

      expect(parts(screen.getByTestId('mockup').element() as HTMLElement).cutout).not.toBeNull();
    });

    it('is nothing on a tablet', async () => {
      const screen = await render(<Mockup data-testid="mockup" device="tablet" />);

      expect(parts(screen.getByTestId('mockup').element() as HTMLElement).cutout).toBeNull();
    });

    it('is turned off by notch="none"', async () => {
      const screen = await render(
        <Mockup data-testid="mockup" device="mobile" os="android" notch="none" />
      );

      expect(parts(screen.getByTestId('mockup').element() as HTMLElement).cutout).toBeNull();
    });

    // Hardware, not chrome: hiding the status bar does not fill in the hole the
    // camera sits in.
    it('stays when the system UI is turned off', async () => {
      const screen = await render(
        <Mockup data-testid="mockup" device="mobile" notch="notch" systemUi={false} />
      );

      expect(parts(screen.getByTestId('mockup').element() as HTMLElement).cutout).not.toBeNull();
    });
  });

  describe('the system UI', () => {
    it('draws a clock by default', async () => {
      const screen = await render(<Mockup device="mobile" />);

      await expect.element(screen.getByText('9:41')).toBeInTheDocument();
    });

    it('takes the time as a prop', async () => {
      const screen = await render(<Mockup device="desktop" os="windows" time="11:30" />);

      await expect.element(screen.getByText('11:30')).toBeInTheDocument();
    });

    it('draws nothing when it is turned off', async () => {
      const screen = await render(<Mockup device="mobile" systemUi={false} />);

      expect(screen.getByText('9:41').query()).toBeNull();
    });

    it('gives the whole screen to the content when it is off', async () => {
      const screen = await render(
        <Mockup data-testid="mockup" device="mobile" systemUi={false} notch="none">
          <span>App</span>
        </Mockup>
      );
      const root = screen.getByTestId('mockup').element() as HTMLElement;
      const content = screen.getByText('App').element().parentElement as HTMLElement;

      expect(content.parentElement?.parentElement).toBe(parts(root).screen);
      expect(parts(root).screen.children.length).toBe(1);
    });

    // A phone does not run Windows, so it gets its own system rather than a
    // taskbar — and a phone's clock is in a bar at the top of the screen.
    it('falls back to the device’s own system', async () => {
      const screen = await render(
        <Mockup data-testid="mockup" device="mobile" os="windows" time="11:30" />
      );
      const glass = parts(screen.getByTestId('mockup').element() as HTMLElement).screen;

      expect(glass.firstElementChild?.contains(screen.getByText('11:30').element())).toBe(true);
    });

    it('reads ios on a tablet as the tablet one', async () => {
      const screen = await render(<Mockup data-testid="mockup" device="tablet" os="ios" />);
      const glass = parts(screen.getByTestId('mockup').element() as HTMLElement).screen;

      await expect.element(screen.getByText('9:41')).toBeInTheDocument();
      expect(glass.firstElementChild?.contains(screen.getByText('9:41').element())).toBe(true);
    });
  });

  describe('scroll', () => {
    it('clips what does not fit by default', async () => {
      const screen = await render(
        <Mockup device="mobile">
          <span>App</span>
        </Mockup>
      );

      expect(screen.getByText('App').element().parentElement).toHaveClass('overflow-hidden');
    });

    it('scrolls when asked', async () => {
      const screen = await render(
        <Mockup device="mobile" scroll>
          <span>App</span>
        </Mockup>
      );

      expect(screen.getByText('App').element().parentElement).toHaveClass('overflow-auto');
    });
  });

  describe('the surface', () => {
    it('takes any CSS background as a wallpaper', async () => {
      const screen = await render(
        <Mockup data-testid="mockup" device="mobile" wallpaper="rgb(255, 0, 0)" />
      );

      expect(
        parts(screen.getByTestId('mockup').element() as HTMLElement).screen.style.background
      ).toBe('rgb(255, 0, 0)');
    });

    it('draws no shadow at elevation 0', async () => {
      const screen = await render(<Mockup data-testid="mockup" device="mobile" />);

      expect((screen.getByTestId('mockup').element() as HTMLElement).style.filter).toBe('none');
    });

    it('draws one as a silhouette when raised', async () => {
      const screen = await render(<Mockup data-testid="mockup" device="mobile" elevation={2} />);

      expect((screen.getByTestId('mockup').element() as HTMLElement).style.filter).toContain(
        'drop-shadow'
      );
    });

    it('lets an inline style override its own', async () => {
      const screen = await render(
        <Mockup data-testid="mockup" device="mobile" style={{ width: '200px' }} />
      );

      expect((screen.getByTestId('mockup').element() as HTMLElement).style.width).toBe('200px');
    });
  });
});
