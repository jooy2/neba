/**
 * The three things an `<img>` does not do — hold its space, say it is loading,
 * say it failed — are the three things worth testing here.
 *
 * The sources are data URIs so nothing depends on the network: a 1×1 GIF that
 * always decodes, and a string that never will.
 */
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Image } from 'neba';

const OK = 'data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==';
const BROKEN = 'data:image/gif;base64,not-a-picture';

describe('Image', () => {
  it('renders an img with the alt it was given', async () => {
    const screen = await render(<Image src={OK} alt="A ridge of hills" />);

    await expect.element(screen.getByRole('img', { name: 'A ridge of hills' })).toBeInTheDocument();
  });

  it('reports when the file arrives', async () => {
    const onLoadingStatusChange = vi.fn();
    await render(<Image src={OK} alt="A ridge" onLoadingStatusChange={onLoadingStatusChange} />);

    await vi.waitFor(() => expect(onLoadingStatusChange).toHaveBeenCalledWith('loaded'));
  });

  it('reports and draws a fallback when it does not', async () => {
    const onLoadingStatusChange = vi.fn();
    const screen = await render(
      <Image src={BROKEN} alt="A ridge" onLoadingStatusChange={onLoadingStatusChange} />
    );

    await vi.waitFor(() => expect(onLoadingStatusChange).toHaveBeenCalledWith('failed'));
    // Something rather than nothing: the browser's own torn-page glyph tells a
    // reader the site is broken rather than that one file is missing.
    await expect.element(screen.getByText('A ridge')).toBeInTheDocument();
  });

  it('draws a fallback of its own when given one', async () => {
    const screen = await render(
      <Image src={BROKEN} alt="A ridge" fallback={<span>Could not load</span>} />
    );

    await expect.element(screen.getByText('Could not load')).toBeInTheDocument();
  });

  it('starts over when the src changes', async () => {
    // Without this a second file inherits the first one's success and never
    // shows a placeholder — and a second file that fails inherits it too.
    const onLoadingStatusChange = vi.fn();
    const screen = await render(
      <Image src={OK} alt="A ridge" onLoadingStatusChange={onLoadingStatusChange} />
    );

    await vi.waitFor(() => expect(onLoadingStatusChange).toHaveBeenCalledWith('loaded'));

    await screen.rerender(
      <Image src={BROKEN} alt="A ridge" onLoadingStatusChange={onLoadingStatusChange} />
    );

    await vi.waitFor(() => expect(onLoadingStatusChange).toHaveBeenLastCalledWith('failed'));
  });

  it('stands a placeholder in while the file is arriving', async () => {
    const screen = await render(
      <Image src={BROKEN} alt="A ridge" placeholder={<span>loading…</span>} />
    );

    await expect.element(screen.getByText('loading…')).toBeInTheDocument();
  });

  it('draws no placeholder when told not to', async () => {
    const screen = await render(<Image src={BROKEN} alt="A ridge" placeholder={false} />);

    expect(screen.container.querySelectorAll('[class*="animate"]').length).toBe(0);
  });

  it('reserves a box for a ratio it was given', async () => {
    const screen = await render(<Image src={OK} alt="A ridge" ratio="16 / 9" />);
    const framed = screen.container.querySelector('[style*="aspect-ratio"]');

    expect(framed).not.toBeNull();
  });

  it('becomes a button when it can be previewed', async () => {
    const screen = await render(<Image src={OK} alt="A ridge" preview />);

    // Reachable by keyboard: a picture that only a pointer can enlarge is one
    // half the readers cannot enlarge.
    await expect.element(screen.getByRole('button', { name: 'A ridge' })).toBeInTheDocument();
  });

  it('opens the full picture when previewed', async () => {
    const screen = await render(<Image src={OK} alt="A ridge" preview />);

    await screen.getByRole('button', { name: 'A ridge' }).click();

    await expect.element(screen.getByRole('dialog', { name: 'A ridge' })).toBeInTheDocument();
  });

  it('is not a button without preview', async () => {
    const screen = await render(<Image src={OK} alt="A ridge" />);

    expect(screen.getByRole('button').query()).toBeNull();
  });

  it('keeps the class names it was handed, on the root and on the parts', async () => {
    const screen = await render(
      <Image
        src={OK}
        alt="A ridge"
        className="my-own-class"
        classNames={{ image: 'my-image-class' }}
      />
    );

    expect(screen.container.querySelector('.my-own-class')).not.toBeNull();
    await expect
      .element(screen.getByRole('img', { name: 'A ridge' }))
      .toHaveClass('my-image-class');
  });

  it('passes an unknown prop through to the img', async () => {
    const screen = await render(<Image src={OK} alt="A ridge" data-analytics="hero" />);

    expect(screen.container.querySelector('img[data-analytics="hero"]')).not.toBeNull();
  });
});
