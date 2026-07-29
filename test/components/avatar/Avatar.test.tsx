import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Avatar } from 'neba';

/**
 * A 1×1 transparent GIF. Inline so nothing here depends on the network — a test
 * that waits on a real URL is a test that fails in CI for reasons of its own.
 */
const PIXEL = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7';

describe('Avatar', () => {
  describe('rendering', () => {
    it('draws a silhouette when it is given nothing at all', async () => {
      const screen = await render(<Avatar data-testid="avatar" />);

      await expect.element(screen.getByTestId('avatar')).toBeInTheDocument();
      expect(screen.getByTestId('avatar').element().querySelector('svg')).not.toBeNull();
    });

    it('renders the picture it is given', async () => {
      const screen = await render(<Avatar src={PIXEL} alt="Jane Doe" />);

      await expect.element(screen.getByRole('img', { name: 'Jane Doe' })).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Avatar name="Jane Doe" className="my-own-class" />);

      expect(screen.container.querySelector('.my-own-class')).not.toBeNull();
    });

    it('reflects a changed name on re-render', async () => {
      const screen = await render(<Avatar name="Jane Doe" />);

      await screen.rerender(<Avatar name="Sam Park" />);

      await expect.element(screen.getByText('SP')).toBeInTheDocument();
      expect(screen.getByText('JD').query()).toBeNull();
    });
  });

  describe('initials', () => {
    it('takes the first letter of the first and last word', async () => {
      const screen = await render(<Avatar name="Jane Doe" />);

      await expect.element(screen.getByText('JD')).toBeInTheDocument();
    });

    it('skips the middle names', async () => {
      const screen = await render(<Avatar name="Jane Miriam van Doe" />);

      await expect.element(screen.getByText('JD')).toBeInTheDocument();
    });

    // A CJK name is one token, and two of its characters at 32px is a smudge
    // where one is a name.
    it('takes one character from a single word', async () => {
      const screen = await render(<Avatar name="홍길동" />);

      await expect.element(screen.getByText('홍', { exact: true })).toBeInTheDocument();
    });

    it('uppercases what it derives', async () => {
      const screen = await render(<Avatar name="jane doe" />);

      await expect.element(screen.getByText('JD')).toBeInTheDocument();
    });

    // A decomposed name — what a macOS filename and a good many APIs hand you —
    // must not yield a bare `A`.
    it('keeps a decomposed accent on the letter it belongs to', async () => {
      const screen = await render(<Avatar name={'Ängela'} />);

      await expect.element(screen.getByText('Ä')).toBeInTheDocument();
    });

    it('does not cut a character outside the basic plane in half', async () => {
      const screen = await render(<Avatar name="𝒥ane" />);

      await expect.element(screen.getByText('𝒥', { exact: true })).toBeInTheDocument();
    });

    it('prefers explicit initials over the derived ones', async () => {
      const screen = await render(<Avatar name="Jane Doe" initials="vD" />);

      await expect.element(screen.getByText('vD')).toBeInTheDocument();
      expect(screen.getByText('JD').query()).toBeNull();
    });

    it('prefers children over the initials', async () => {
      const screen = await render(<Avatar name="Jane Doe">🐈</Avatar>);

      await expect.element(screen.getByText('🐈')).toBeInTheDocument();
      expect(screen.getByText('JD').query()).toBeNull();
    });

    it('ignores a name that is only whitespace', async () => {
      const screen = await render(<Avatar name="   " data-testid="avatar" />);

      expect(screen.getByTestId('avatar').element().querySelector('svg')).not.toBeNull();
    });
  });

  describe('the picture', () => {
    it('names the picture with the name when there is no alt', async () => {
      const screen = await render(<Avatar src={PIXEL} name="Jane Doe" />);

      await expect.element(screen.getByRole('img', { name: 'Jane Doe' })).toBeInTheDocument();
    });

    // An avatar next to the person's own name is decoration, and an absent alt
    // is what makes a screen reader read the file name out instead.
    it('gives the picture an empty alt when there is nothing to say', async () => {
      const screen = await render(<Avatar src={PIXEL} data-testid="avatar" />);
      const image = screen.getByTestId('avatar').element().querySelector('img');

      expect(image).toHaveAttribute('alt', '');
    });

    it('reports the loading status', async () => {
      const onLoadingStatusChange = vi.fn();
      await render(
        <Avatar src={PIXEL} name="Jane Doe" onLoadingStatusChange={onLoadingStatusChange} />
      );

      await vi.waitFor(() => expect(onLoadingStatusChange).toHaveBeenCalledWith('loaded'));
    });

    it('passes the rest of the img attributes through', async () => {
      const screen = await render(
        <Avatar src={PIXEL} name="Jane Doe" imageProps={{ loading: 'lazy' }} data-testid="avatar" />
      );

      expect(screen.getByTestId('avatar').element().querySelector('img')).toHaveAttribute(
        'loading',
        'lazy'
      );
    });

    it('falls back to the initials when the picture fails', async () => {
      const screen = await render(<Avatar src="/does-not-exist.png" name="Jane Doe" />);

      await expect.element(screen.getByText('JD')).toBeInTheDocument();
    });
  });

  describe('accessibility', () => {
    // `JD` read out loud is two letters, not a person.
    it('reads the name instead of the initials', async () => {
      const screen = await render(<Avatar name="Jane Doe" data-testid="avatar" />);
      const initials = screen.getByText('JD').element();

      expect(initials.closest('[aria-hidden="true"]')).not.toBeNull();
      await expect.element(screen.getByText('Jane Doe')).toBeInTheDocument();
    });

    it('says nothing when there is nothing to say', async () => {
      const screen = await render(<Avatar data-testid="avatar" />);

      expect(screen.getByTestId('avatar').element().querySelector('[aria-hidden="true"]')).toBe(
        screen.getByTestId('avatar').element().querySelector('svg')
      );
    });
  });

  describe('style props', () => {
    it('maps its colour onto the token slots', async () => {
      const screen = await render(<Avatar name="Jane Doe" color="danger" data-testid="avatar" />);
      const element = screen.getByTestId('avatar').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-danger-fill)');
    });

    it('maps elevation onto the token slots', async () => {
      const screen = await render(<Avatar name="Jane Doe" elevation={2} data-testid="avatar" />);
      const element = screen.getByTestId('avatar').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-2)');
    });

    it('is round by default', async () => {
      const screen = await render(<Avatar name="Jane Doe" data-testid="avatar" />);

      expect(screen.getByTestId('avatar').element()).toHaveClass('rounded-full');
    });

    // ~28% of the box, not the control ladder's ~45%: on something as wide as it
    // is tall, 45% is a circle and the prop would do nothing.
    it('cuts the corners rather than rounding them off when squared', async () => {
      const screen = await render(<Avatar name="Jane Doe" shape="square" data-testid="avatar" />);
      const element = screen.getByTestId('avatar').element();

      expect(element).not.toHaveClass('rounded-full');
      expect(element).toHaveClass('rounded-[0.5625rem]');
    });

    it('sits on the control height ladder', async () => {
      const screen = await render(<Avatar name="Jane Doe" size="lg" data-testid="avatar" />);
      const element = screen.getByTestId('avatar').element();

      expect(element).toHaveClass('h-10');
      expect(element).toHaveClass('w-10');
    });

    // State is colour and depth; a control that moves under the cursor is what
    // reads as cheap.
    it('never applies a transform', async () => {
      const screen = await render(<Avatar name="Jane Doe" variant="solid" data-testid="avatar" />);

      expect(screen.getByTestId('avatar').element().outerHTML).not.toContain('translate');
      expect(screen.getByTestId('avatar').element().outerHTML).not.toContain('scale-');
    });
  });
});
