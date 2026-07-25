import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button, ToastProvider, useToast, type ToastOptions, type ToastProviderProps } from 'neba';

/**
 * A toast has no markup until something raises one, so every test needs the
 * same two things: a provider and a button that calls `add`.
 */
function Raise({ options, children = 'Raise' }: { options: ToastOptions; children?: string }) {
  const toast = useToast();

  return <Button onClick={() => toast.add(options)}>{children}</Button>;
}

function Harness({
  options,
  ...provider
}: { options: ToastOptions } & Omit<ToastProviderProps, 'children'>) {
  return (
    <ToastProvider {...provider}>
      <Raise options={options} />
    </ToastProvider>
  );
}

describe('Toast', () => {
  describe('raising one', () => {
    it('renders nothing until something raises a toast', async () => {
      const screen = await render(<Harness options={{ title: 'Saved' }} />);

      expect(screen.getByText('Saved').query()).toBeNull();
    });

    it('shows the title and the description', async () => {
      const screen = await render(
        <Harness options={{ title: 'Deploy failed', description: 'The build exited with 1.' }} />
      );

      await screen.getByRole('button', { name: 'Raise' }).click();

      await expect.element(screen.getByText('Deploy failed')).toBeInTheDocument();
      await expect.element(screen.getByText('The build exited with 1.')).toBeInTheDocument();
    });

    it('shows a description-only toast', async () => {
      const screen = await render(<Harness options={{ description: 'Copied to clipboard' }} />);

      await screen.getByRole('button', { name: 'Raise' }).click();

      await expect.element(screen.getByText('Copied to clipboard')).toBeInTheDocument();
    });

    it('stacks more than one', async () => {
      const screen = await render(<Harness options={{ title: 'Saved', timeout: 0 }} />);
      const raise = screen.getByRole('button', { name: 'Raise' });

      await raise.click();
      await raise.click();

      await expect.element(screen.getByText('Saved').first()).toBeInTheDocument();
      expect(screen.getByText('Saved').elements()).toHaveLength(2);
    });
  });

  describe('dismissing', () => {
    // Base UI keeps the × out of the accessibility tree until the stack is
    // hovered or focused, so that a toast is announced as one message rather
    // than as a message and a button. Hovering it first is what a pointer user
    // does anyway, and it is the only way to name the button in a query.
    it('closes from its × button', async () => {
      const screen = await render(<Harness options={{ title: 'Saved', timeout: 0 }} />);

      await screen.getByRole('button', { name: 'Raise' }).click();
      await expect.element(screen.getByText('Saved')).toBeInTheDocument();

      await screen.getByText('Saved').hover();
      await screen.getByRole('button', { name: 'Close' }).click();

      await expect.element(screen.getByText('Saved')).not.toBeInTheDocument();
    });

    it('takes a custom accessible name for the × button', async () => {
      const screen = await render(
        <Harness closeLabel="Dismiss" options={{ title: 'Saved', timeout: 0 }} />
      );

      await screen.getByRole('button', { name: 'Raise' }).click();
      await screen.getByText('Saved').hover();

      await expect.element(screen.getByRole('button', { name: 'Dismiss' })).toBeInTheDocument();
    });

    it('dismisses itself once its timeout has run out', async () => {
      const screen = await render(<Harness options={{ title: 'Saved', timeout: 80 }} />);

      await screen.getByRole('button', { name: 'Raise' }).click();
      await expect.element(screen.getByText('Saved')).toBeInTheDocument();

      await expect.element(screen.getByText('Saved')).not.toBeInTheDocument();
    });

    it('stays up when its timeout is zero', async () => {
      const screen = await render(
        <Harness timeout={60} options={{ title: 'Saved', timeout: 0 }} />
      );

      await screen.getByRole('button', { name: 'Raise' }).click();
      await expect.element(screen.getByText('Saved')).toBeInTheDocument();

      await new Promise((resolve) => setTimeout(resolve, 200));

      await expect.element(screen.getByText('Saved')).toBeInTheDocument();
    });
  });

  describe('the action', () => {
    it('shows the action only when it is given a label', async () => {
      const screen = await render(<Harness options={{ title: 'Deleted', timeout: 0 }} />);

      await screen.getByRole('button', { name: 'Raise' }).click();

      expect(screen.getByRole('button', { name: 'Undo' }).query()).toBeNull();
    });

    it('calls onAction when the action is pressed', async () => {
      const onAction = vi.fn();
      const screen = await render(
        <Harness options={{ title: 'Deleted', timeout: 0, actionLabel: 'Undo', onAction }} />
      );

      await screen.getByRole('button', { name: 'Raise' }).click();
      await screen.getByRole('button', { name: 'Undo' }).click();

      expect(onAction).toHaveBeenCalledTimes(1);
    });
  });

  describe('style props', () => {
    it('takes its colour from the provider', async () => {
      const screen = await render(
        <Harness color="success" options={{ title: 'Saved', timeout: 0 }} />
      );

      await screen.getByRole('button', { name: 'Raise' }).click();
      const toast = screen.getByText('Saved').element().closest('[style]') as HTMLElement;

      expect(toast.style.getPropertyValue('--n-fill')).toBe('var(--neba-success-fill)');
    });

    it('lets a single toast override the provider', async () => {
      const screen = await render(
        <Harness color="success" options={{ title: 'Failed', color: 'danger', timeout: 0 }} />
      );

      await screen.getByRole('button', { name: 'Raise' }).click();
      const toast = screen.getByText('Failed').element().closest('[style]') as HTMLElement;

      expect(toast.style.getPropertyValue('--n-fill')).toBe('var(--neba-danger-fill)');
    });

    it('draws the severity glyph', async () => {
      const screen = await render(<Harness options={{ title: 'Saved', timeout: 0 }} />);

      await screen.getByRole('button', { name: 'Raise' }).click();
      const toast = screen.getByText('Saved').element().closest('[role]') as HTMLElement;

      // Two: the glyph and the × next to it.
      expect(toast.querySelectorAll('svg')).toHaveLength(2);
    });

    it('drops the glyph when asked', async () => {
      const screen = await render(
        <Harness options={{ title: 'Saved', timeout: 0, icon: false }} />
      );

      await screen.getByRole('button', { name: 'Raise' }).click();
      const toast = screen.getByText('Saved').element().closest('[role]') as HTMLElement;

      expect(toast.querySelectorAll('svg')).toHaveLength(1);
    });

    it('pins the stack where it is told to', async () => {
      const screen = await render(
        <Harness position="top-center" options={{ title: 'Saved', timeout: 0 }} />
      );

      await screen.getByRole('button', { name: 'Raise' }).click();
      const viewport = screen.getByText('Saved').element().closest('.neba-portal') as HTMLElement;

      expect(viewport).toHaveClass('top-0');
      expect(viewport).toHaveClass('items-center');
    });

    it('lets the whole strip be clicked through', async () => {
      const screen = await render(<Harness options={{ title: 'Saved', timeout: 0 }} />);

      await screen.getByRole('button', { name: 'Raise' }).click();
      const viewport = screen.getByText('Saved').element().closest('.neba-portal') as HTMLElement;

      expect(viewport).toHaveClass('pointer-events-none');
    });
  });
});
