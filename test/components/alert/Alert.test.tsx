import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Alert, Button } from 'neba';
import { ko, registerMessages } from 'neba/locales';

/* The library ships English; a `locale` prop answers for a language the
   project has registered. These assertions are about the prop, so the
   languages they name are registered here the way a consumer would. */
registerMessages('ko', ko);

describe('Alert', () => {
  describe('rendering', () => {
    it('renders its message in a live region', async () => {
      const screen = await render(<Alert>Everything is fine.</Alert>);

      await expect.element(screen.getByRole('status')).toHaveTextContent('Everything is fine.');
    });

    it('renders a title above the message', async () => {
      const screen = await render(<Alert title="Deploy failed">The build exited with 1.</Alert>);

      await expect.element(screen.getByText('Deploy failed')).toBeInTheDocument();
      await expect.element(screen.getByText('The build exited with 1.')).toBeInTheDocument();
    });

    it('reflects a changed message on re-render', async () => {
      const screen = await render(<Alert>Before</Alert>);

      await screen.rerender(<Alert>After</Alert>);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Alert className="my-own-class">Saved</Alert>);

      expect(screen.getByRole('status').element()).toHaveClass('my-own-class');
    });
  });

  describe('icon', () => {
    it('draws a glyph by default', async () => {
      const screen = await render(<Alert>Saved</Alert>);

      expect(screen.getByRole('status').element().querySelector('svg')).not.toBeNull();
    });

    it('drops the glyph when asked', async () => {
      const screen = await render(<Alert icon={false}>Saved</Alert>);

      expect(screen.getByRole('status').element().querySelector('svg')).toBeNull();
    });

    it('takes a glyph of its own', async () => {
      const screen = await render(<Alert icon={<span data-testid="my-icon">!</span>}>Saved</Alert>);

      await expect.element(screen.getByTestId('my-icon')).toBeInTheDocument();
    });

    // The severity has to be in the shape as well as in the colour: an alert
    // that says "this went wrong" only in red says it only to some readers.
    it('draws a different glyph per severity', async () => {
      const screen = await render(<Alert color="success">Saved</Alert>);
      const success = screen.getByRole('status').element().querySelector('svg')?.innerHTML;

      // The role changes with the severity — that is the next test's subject —
      // so the danger alert has to be found as the alert it now is.
      await screen.rerender(<Alert color="danger">Saved</Alert>);
      const danger = screen.getByRole('alert').element().querySelector('svg')?.innerHTML;

      expect(success).toBeTruthy();
      expect(success).not.toEqual(danger);
    });
  });

  describe('live region', () => {
    it('waits for a pause on an informational alert', async () => {
      const screen = await render(<Alert color="info">Saved</Alert>);

      await expect.element(screen.getByRole('status')).toBeInTheDocument();
    });

    it('interrupts on a warning or an error', async () => {
      const screen = await render(<Alert color="danger">It broke</Alert>);

      await expect.element(screen.getByRole('alert')).toBeInTheDocument();

      await screen.rerender(<Alert color="warning">Careful</Alert>);

      await expect.element(screen.getByRole('alert')).toBeInTheDocument();
    });

    it('lets the caller override the role', async () => {
      const screen = await render(
        <Alert color="danger" role="status">
          It broke
        </Alert>
      );

      await expect.element(screen.getByRole('status')).toBeInTheDocument();
      expect(screen.getByRole('alert').query()).toBeNull();
    });
  });

  describe('dismissing', () => {
    it('shows the dismiss button only when onClose is given', async () => {
      const screen = await render(<Alert>Saved</Alert>);

      expect(screen.getByRole('button', { name: 'Dismiss' }).query()).toBeNull();

      await screen.rerender(<Alert onClose={() => {}}>Saved</Alert>);

      await expect.element(screen.getByRole('button', { name: 'Dismiss' })).toBeInTheDocument();
    });

    it('calls onClose when pressed', async () => {
      const onClose = vi.fn();
      const screen = await render(<Alert onClose={onClose}>Saved</Alert>);

      await screen.getByRole('button', { name: 'Dismiss' }).click();

      expect(onClose).toHaveBeenCalledTimes(1);
    });

    it('takes a custom accessible name for the dismiss button', async () => {
      const screen = await render(
        <Alert onClose={() => {}} closeLabel="Hide this notice">
          Saved
        </Alert>
      );

      await expect
        .element(screen.getByRole('button', { name: 'Hide this notice' }))
        .toBeInTheDocument();
    });
  });

  describe('action', () => {
    it('renders the action beside the message', async () => {
      const onRetry = vi.fn();
      const screen = await render(
        <Alert action={<Button onClick={onRetry}>Retry</Button>}>It failed</Alert>
      );

      await screen.getByRole('button', { name: 'Retry' }).click();

      expect(onRetry).toHaveBeenCalledTimes(1);
    });
  });

  describe('style props', () => {
    it('maps colour and elevation onto the token slots', async () => {
      const screen = await render(
        <Alert color="warning" elevation={2}>
          Careful
        </Alert>
      );
      const element = screen.getByRole('alert').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-warning-fill)');
      expect(element.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-2)');
    });

    it('is an outline alert by default', async () => {
      const screen = await render(<Alert>Saved</Alert>);

      expect(screen.getByRole('status').element()).toHaveClass('border');
    });

    it('changes padding with density', async () => {
      const screen = await render(<Alert density="compact">Saved</Alert>);

      expect(screen.getByRole('status').element()).toHaveClass('p-2.5');
    });

    it('never applies a transform', async () => {
      const screen = await render(
        <Alert title="Deploy failed" onClose={() => {}} action={<Button>Retry</Button>}>
          The build exited with 1.
        </Alert>
      );
      const html = screen.getByRole('status').element().outerHTML;

      expect(html).not.toContain('scale');
      expect(html).not.toContain('translate');
    });
  });

  describe('transition', () => {
    it('takes an entrance animation', async () => {
      const screen = await render(
        <Alert transition="slide" data-testid="alert">
          Saved
        </Alert>
      );
      const element = screen.getByTestId('alert').element() as HTMLElement;

      expect(element).toHaveClass('neba-anim-slide');
      expect(element.style.getPropertyValue('--n-anim-y')).toBe('100%');
    });
  });

  describe('locale', () => {
    it('names the dismiss button in the language it was given', async () => {
      const screen = await render(
        <Alert locale="ko" onClose={vi.fn()}>
          저장하지 못했습니다
        </Alert>
      );

      await expect.element(screen.getByRole('button', { name: '알림 닫기' })).toBeInTheDocument();
    });

    it('takes a word of its own over the locale', async () => {
      const screen = await render(
        <Alert locale="ko" closeLabel="Dismiss" onClose={vi.fn()}>
          저장하지 못했습니다
        </Alert>
      );

      await expect.element(screen.getByRole('button', { name: 'Dismiss' })).toBeInTheDocument();
    });
  });
});
