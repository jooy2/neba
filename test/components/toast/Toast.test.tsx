import { useState } from 'react';
import * as React from 'react';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button, ToastProvider, useToast, type ToastOptions, type ToastProviderProps } from 'neba';
import { ko, registerMessages } from 'neba/locales';

/* The library ships English; a `locale` prop answers for a language the
   project has registered. These assertions are about the prop, so the
   languages they name are registered here the way a consumer would. */
registerMessages('ko', ko);

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

    // A toast past the limit is kept and marked rather than thrown away, so it
    // can come back as the stack drains.
    it('marks the toasts past the limit rather than dropping them', async () => {
      function Three() {
        const toast = useToast();

        return (
          <Button
            onClick={() => {
              toast.add({ title: 'One', timeout: 0 });
              toast.add({ title: 'Two', timeout: 0 });
              toast.add({ title: 'Three', timeout: 0 });
            }}
          >
            Raise
          </Button>
        );
      }

      const screen = await render(
        <ToastProvider limit={2}>
          <Three />
        </ToastProvider>
      );

      await screen.getByRole('button', { name: 'Raise' }).click();
      await expect.element(screen.getByText('Three')).toBeInTheDocument();

      const limited = [...document.querySelectorAll('[data-limited]')];

      expect(limited).toHaveLength(1);
      expect(limited[0].textContent).toContain('One');
    });

    // The shape a caller reaches for to follow a job: raise it once, then say
    // how it went under the same id.
    it('changes the toast it has when one is raised with the same id', async () => {
      function Sync() {
        const toast = useToast();

        return (
          <>
            <Button onClick={() => toast.add({ id: 'sync', title: 'Syncing', timeout: 0 })}>
              Start
            </Button>
            <Button onClick={() => toast.add({ id: 'sync', title: 'Synced', timeout: 0 })}>
              Finish
            </Button>
          </>
        );
      }

      const screen = await render(
        <ToastProvider>
          <Sync />
        </ToastProvider>
      );

      await screen.getByRole('button', { name: 'Start' }).click();
      await expect.element(screen.getByText('Syncing')).toBeInTheDocument();

      await screen.getByRole('button', { name: 'Finish' }).click();

      await expect.element(screen.getByText('Synced')).toBeInTheDocument();
      expect(screen.getByText('Syncing').query()).toBeNull();
      expect(screen.getByText('Synced').elements()).toHaveLength(1);
    });
  });

  describe('the hook', () => {
    // The shape a caller reaches for: raise a toast when something goes wrong.
    // With an `add` that changed whenever the list did, this raised one toast,
    // got a new `add` and ran again, without end.
    it('keeps add stable, so an effect that raises a toast runs once', async () => {
      function Watcher() {
        const { add } = useToast();

        React.useEffect(() => {
          add({ title: 'Connection lost', timeout: 0 });
        }, [add]);

        return null;
      }

      const screen = await render(
        <ToastProvider>
          <Watcher />
        </ToastProvider>
      );

      await expect.element(screen.getByText('Connection lost')).toBeInTheDocument();
      await new Promise((resolve) => setTimeout(resolve, 100));

      expect(screen.getByText('Connection lost').elements()).toHaveLength(1);
    });

    // Only the toast list changes when one is raised, and the four methods are
    // what a caller holds on to — an effect keyed on one of them runs again
    // every time its identity moves.
    it('keeps every method it hands back while the stack changes', async () => {
      const seen: Array<Record<string, unknown>> = [];

      function Watcher() {
        const toast = useToast();

        seen.push({
          add: toast.add,
          close: toast.close,
          update: toast.update,
          promise: toast.promise
        });

        return <Button onClick={() => toast.add({ title: 'Saved', timeout: 0 })}>Raise</Button>;
      }

      const screen = await render(
        <ToastProvider>
          <Watcher />
        </ToastProvider>
      );

      await screen.getByRole('button', { name: 'Raise' }).click();
      await expect.element(screen.getByText('Saved')).toBeInTheDocument();

      expect(seen.length).toBeGreaterThan(1);

      for (const name of ['add', 'close', 'update', 'promise']) {
        expect(new Set(seen.map((methods) => methods[name])).size, name).toBe(1);
      }
    });
  });

  describe('following a promise', () => {
    it('shows the loading message, then the success', async () => {
      let settle!: (value: string) => void;
      const promise = new Promise<string>((resolve) => {
        settle = resolve;
      });

      function Run() {
        const toast = useToast();

        return (
          <Button
            onClick={() =>
              toast.promise(promise, {
                loading: { title: 'Saving' },
                success: (value) => ({ title: value, timeout: 0 }),
                error: { title: 'Failed', timeout: 0 }
              })
            }
          >
            Save
          </Button>
        );
      }

      const screen = await render(
        <ToastProvider>
          <Run />
        </ToastProvider>
      );

      await screen.getByRole('button', { name: 'Save' }).click();
      await expect.element(screen.getByText('Saving')).toBeInTheDocument();

      settle('Saved');

      await expect.element(screen.getByText('Saved')).toBeInTheDocument();
      await expect.element(screen.getByText('Saving')).not.toBeInTheDocument();
    });

    it('shows the error when the promise does not keep', async () => {
      let fail!: (reason: Error) => void;
      const promise = new Promise<string>((_, reject) => {
        fail = reject;
      });

      function Run() {
        const toast = useToast();

        return (
          <Button
            onClick={() =>
              void Promise.resolve(
                toast.promise(promise, {
                  loading: { title: 'Saving' },
                  success: { title: 'Saved', timeout: 0 },
                  error: (reason) => ({ title: (reason as Error).message, timeout: 0 })
                })
              ).catch(() => {})
            }
          >
            Save
          </Button>
        );
      }

      const screen = await render(
        <ToastProvider>
          <Run />
        </ToastProvider>
      );

      await screen.getByRole('button', { name: 'Save' }).click();
      await expect.element(screen.getByText('Saving')).toBeInTheDocument();

      fail(new Error('Offline'));

      await expect.element(screen.getByText('Offline')).toBeInTheDocument();
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

    it('closes every toast at once when close is called with nothing', async () => {
      function Two() {
        const toast = useToast();

        return (
          <>
            <Button
              onClick={() => {
                toast.add({ title: 'One', timeout: 0 });
                toast.add({ title: 'Two', timeout: 0 });
              }}
            >
              Raise
            </Button>
            <Button onClick={() => toast.close()}>Clear</Button>
          </>
        );
      }

      const screen = await render(
        <ToastProvider>
          <Two />
        </ToastProvider>
      );

      await screen.getByRole('button', { name: 'Raise' }).click();
      await expect.element(screen.getByText('Two')).toBeInTheDocument();

      await screen.getByRole('button', { name: 'Clear' }).click();

      // The retrying form: a toast on its way out stays mounted while its exit
      // transition might still run.
      await expect.element(screen.getByText('One')).not.toBeInTheDocument();
      await expect.element(screen.getByText('Two')).not.toBeInTheDocument();
    });

    it('takes a custom accessible name for the × button', async () => {
      const screen = await render(
        <Harness closeLabel="Dismiss" options={{ title: 'Saved', timeout: 0 }} />
      );

      await screen.getByRole('button', { name: 'Raise' }).click();
      await screen.getByText('Saved').hover();

      await expect.element(screen.getByRole('button', { name: 'Dismiss' })).toBeInTheDocument();
    });

    // Two things make this one awkward, and both are about the timer rather
    // than about the toast. Asserting it is on screen first would race the very
    // timeout under test — a query round trip in Firefox outlasts a short one,
    // which is how this failed in CI — so the tests above are what cover a
    // toast appearing, and this one only watches it leave. And Base UI pauses
    // the timer while the window is blurred, which a test file running in a
    // sibling frame is free to cause at any moment, so each poll hands the
    // focus back. Resuming a timer that never paused is a no-op, and a paused
    // one resumes with the time it had left rather than with a fresh timeout.
    it('dismisses itself once its timeout has run out', async () => {
      const screen = await render(<Harness options={{ title: 'Saved', timeout: 200 }} />);

      await screen.getByRole('button', { name: 'Raise' }).click();

      await expect
        .poll(
          () => {
            window.dispatchEvent(new FocusEvent('focus'));

            return screen.getByText('Saved').query();
          },
          { timeout: 5000 }
        )
        .toBeNull();
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
    // An update wrote `data` and `actionProps` even when they were not given,
    // which took the colour and the action button off the toast.
    it('keeps what an update does not mention', async () => {
      function Updater() {
        const toast = useToast();
        const [id, setId] = useState<string | null>(null);

        return (
          <>
            <Button
              onClick={() =>
                setId(
                  toast.add({ title: 'Upload', color: 'danger', actionLabel: 'Retry', timeout: 0 })
                )
              }
            >
              Raise
            </Button>
            <Button onClick={() => id && toast.update(id, { description: 'Halfway' })}>
              Update
            </Button>
          </>
        );
      }

      const screen = await render(
        <ToastProvider>
          <Updater />
        </ToastProvider>
      );

      await screen.getByRole('button', { name: 'Raise' }).click();
      await expect.element(screen.getByText('Upload')).toBeInTheDocument();
      await screen.getByRole('button', { name: 'Update' }).click();
      await expect.element(screen.getByText('Halfway')).toBeInTheDocument();

      const toast = screen.getByText('Upload').element().closest('[style]') as HTMLElement;

      expect(toast.style.getPropertyValue('--n-fill')).toBe('var(--neba-danger-fill)');
      await expect.element(screen.getByRole('button', { name: 'Retry' })).toBeInTheDocument();
    });

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

  describe('locale', () => {
    it('names every toast’s × in the language it was given', async () => {
      const screen = await render(
        <Harness locale="ko" options={{ title: '저장됨', timeout: 0 }} />
      );

      await screen.getByRole('button', { name: 'Raise' }).click();
      await screen.getByText('저장됨').hover();

      await expect.element(screen.getByRole('button', { name: '닫기' })).toBeInTheDocument();
    });

    it('names the region the stack lives in, in the language it was given', async () => {
      const screen = await render(
        <Harness locale="ko" options={{ title: '저장됨', timeout: 0 }} />
      );

      await screen.getByRole('button', { name: 'Raise' }).click();

      await expect.element(screen.getByRole('region', { name: '알림' })).toBeInTheDocument();
    });

    it('takes a region name of its own over the locale', async () => {
      const screen = await render(
        <Harness locale="ko" label="Updates" options={{ title: '저장됨', timeout: 0 }} />
      );

      await screen.getByRole('button', { name: 'Raise' }).click();

      await expect.element(screen.getByRole('region', { name: 'Updates' })).toBeInTheDocument();
    });

    it('takes a word of its own over the locale', async () => {
      const screen = await render(
        <Harness locale="ko" closeLabel="Dismiss" options={{ title: '저장됨', timeout: 0 }} />
      );

      await screen.getByRole('button', { name: 'Raise' }).click();
      await screen.getByText('저장됨').hover();

      await expect.element(screen.getByRole('button', { name: 'Dismiss' })).toBeInTheDocument();
    });
  });
  describe('slots', () => {
    it('puts a class name on every part it was given one for', async () => {
      const screen = await render(
        <Harness
          options={{ title: 'Saved', description: 'The change is live.', actionLabel: 'Undo' }}
          classNames={{
            viewport: 'slot-viewport',
            toast: 'slot-toast',
            title: 'slot-title',
            description: 'slot-description',
            action: 'slot-action',
            close: 'slot-close'
          }}
        />
      );

      await screen.getByRole('button', { name: 'Raise' }).click();

      const toast = screen.getByText('Saved').element().closest('.slot-toast');

      expect(toast).not.toBeNull();
      expect(toast?.closest('.slot-viewport')).not.toBeNull();
      expect(screen.getByText('Saved').element()).toHaveClass('slot-title');
      expect(screen.getByText('The change is live.').element()).toHaveClass('slot-description');
      expect(screen.getByRole('button', { name: 'Undo' }).element()).toHaveClass('slot-action');
      expect(toast?.querySelector('.slot-close')).not.toBeNull();
    });

    it("keeps the part's own class names alongside the one it was handed", async () => {
      const screen = await render(
        <Harness options={{ title: 'Saved' }} classNames={{ toast: 'slot-toast' }} />
      );

      await screen.getByRole('button', { name: 'Raise' }).click();

      const toast = screen.getByText('Saved').element().closest('.slot-toast');

      expect(toast).toHaveClass('pointer-events-auto');
    });
  });
});
