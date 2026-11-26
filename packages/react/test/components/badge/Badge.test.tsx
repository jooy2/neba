import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Badge, Button } from 'neba';

describe('Badge', () => {
  describe('rendering', () => {
    it('renders its content', async () => {
      const screen = await render(<Badge content={4} />);

      await expect.element(screen.getByText('4')).toBeInTheDocument();
    });

    it('wraps the anchor it is given', async () => {
      const screen = await render(
        <Badge content={4}>
          <Button>Inbox</Button>
        </Badge>
      );

      await expect.element(screen.getByRole('button', { name: 'Inbox' })).toBeInTheDocument();
      await expect.element(screen.getByText('4')).toBeInTheDocument();
    });

    it('reflects a changed count on re-render', async () => {
      const screen = await render(<Badge content={4} />);

      await screen.rerender(<Badge content={5} />);

      await expect.element(screen.getByText('5')).toBeInTheDocument();
      expect(screen.getByText('4').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Badge content={4} className="my-own-class" />);

      expect(screen.getByText('4').element().closest('.my-own-class')).not.toBeNull();
    });
  });

  describe('what the number says', () => {
    it('caps a number past max and adds a plus', async () => {
      const screen = await render(<Badge content={120} />);

      await expect.element(screen.getByText('99+')).toBeInTheDocument();
    });

    it('takes the cap from max', async () => {
      const screen = await render(<Badge content={120} max={9} />);

      await expect.element(screen.getByText('9+')).toBeInTheDocument();
    });

    it('leaves a number at the cap alone', async () => {
      const screen = await render(<Badge content={99} />);

      await expect.element(screen.getByText('99')).toBeInTheDocument();
    });

    // A badge cannot know how to truncate a word, so it does not try.
    it('never caps text', async () => {
      const screen = await render(<Badge content="NEW" max={1} />);

      await expect.element(screen.getByText('NEW')).toBeInTheDocument();
    });
  });

  describe('when there is nothing to report', () => {
    // Zero unread messages is not news, and a badge that never goes away stops
    // meaning anything.
    it('hides a count of zero', async () => {
      const screen = await render(<Badge content={0} />);

      expect(screen.getByText('0').query()).toBeNull();
    });

    it('shows a count of zero when asked', async () => {
      const screen = await render(<Badge content={0} showZero />);

      await expect.element(screen.getByText('0')).toBeInTheDocument();
    });

    // The dot was drawn `invisible`, and this test only looked for its radius,
    // so it passed on a marker nobody could see.
    it('draws a visible dot when there is no content at all', async () => {
      const screen = await render(
        <Badge>
          <Button>Inbox</Button>
        </Badge>
      );
      const marker = screen.getByRole('button').element().nextElementSibling as HTMLElement;

      expect(marker.className).toContain('rounded-full');
      expect(marker).not.toHaveClass('invisible');
      // Nothing to read, so nothing is read.
      expect(marker).toHaveAttribute('aria-hidden', 'true');
    });

    it('reads a label on a dot that has no content', async () => {
      const screen = await render(<Badge label="Online" />);

      await expect.element(screen.getByText('Online')).toBeInTheDocument();
    });

    it('keeps the count in the DOM under a dot, for a reader', async () => {
      const screen = await render(<Badge dot content={4} />);

      await expect.element(screen.getByText('4')).toBeInTheDocument();
    });

    // Visibility, not opacity: a half-faded badge is a badge you have to squint
    // at to find out whether it is there. The marker keeps its box either way,
    // so nothing around it moves when it comes back.
    it('hides without unmounting when invisible', async () => {
      const screen = await render(
        <Badge invisible content={4}>
          <Button>Inbox</Button>
        </Badge>
      );

      expect(screen.container.querySelector('.invisible')).not.toBeNull();
      expect(screen.getByText('4').query()).toBeNull();
    });
  });

  describe('accessibility', () => {
    it('reads the label instead of the raw number', async () => {
      const screen = await render(<Badge content={3} label="3 unread notifications" />);

      await expect.element(screen.getByText('3 unread notifications')).toBeInTheDocument();
    });

    it('reads the label instead of the clipped count on a dot', async () => {
      const screen = await render(<Badge dot content={3} label="3 unread notifications" />);

      await expect.element(screen.getByText('3 unread notifications')).toBeInTheDocument();
      expect(screen.getByText('3', { exact: true }).query()).toBeNull();
    });

    it('describes a control that points at it by id with the sentence alone', async () => {
      const screen = await render(
        <Badge id="unread" content={3} label="3 unread notifications">
          <Button aria-label="Notifications" aria-describedby="unread" />
        </Badge>
      );

      await expect
        .element(screen.getByRole('button', { name: 'Notifications' }))
        .toHaveAccessibleDescription('3 unread notifications');
    });

    it('takes a hidden badge out of the accessibility tree', async () => {
      const screen = await render(<Badge invisible content={4} />);

      expect(screen.container.querySelector('.invisible')).toHaveAttribute('aria-hidden', 'true');
    });
  });

  describe('style props', () => {
    it('maps its colour onto the token slots', async () => {
      const screen = await render(<Badge content={4} color="danger" />);
      const element = screen.getByText('4').element().closest('span[style]') as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-danger-fill)');
    });

    it('maps elevation onto the token slots', async () => {
      const screen = await render(<Badge content={4} elevation={2} />);
      const element = screen.getByText('4').element().closest('span[style]') as HTMLElement;

      expect(element.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-2)');
    });

    it('pins itself to the corner it is told to', async () => {
      const screen = await render(
        <Badge content={4} placement="bottom-start">
          <Button>Inbox</Button>
        </Badge>
      );
      const marker = screen.getByText('4').element().closest('span[class*="absolute"]');

      expect(marker).toHaveClass('bottom-0');
      expect(marker).toHaveClass('start-0');
    });

    it('lays out inline when it has nothing to hang off', async () => {
      const screen = await render(<Badge content={4} />);
      const marker = screen.getByText('4').element().closest('span[style]');

      expect(marker).not.toHaveClass('absolute');
      expect(marker).toHaveClass('relative');
    });

    // A badged icon button has to measure exactly like a bare one.
    it('never applies a transform', async () => {
      const screen = await render(
        <Badge content={120} overlap="circle" placement="top-end">
          <Button>Inbox</Button>
        </Badge>
      );

      expect(screen.getByRole('button').element().parentElement?.outerHTML).not.toContain(
        'translate'
      );
    });
  });

  /* `--n-soft*` is a wash, and this is a mark a caller drops *inside* other
     things: on a filled surface the wash let the fill through and the label read
     1.45:1. The `text` plate carries its own bed instead — see
     `tintPlateClasses`. */
  describe('the `text` plate', () => {
    it('carries its own bed rather than the surface it was dropped on', async () => {
      const screen = await render(<Badge variant="text">7</Badge>);

      expect(screen.container.querySelector('.neba-tint-plate')).not.toBeNull();
    });
  });
});
