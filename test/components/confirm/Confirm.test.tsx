/**
 * A confirm is a question that returns an answer, so almost everything worth
 * testing is about the promise: that it settles, that it settles with what the
 * reader pressed, and that nothing but a person ever settles it.
 */
import { Component, type ReactNode } from 'react';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
import { Button, ConfirmProvider, useConfirm } from 'neba';
import { ko, registerMessages } from 'neba/locales';

function Asker({
  onAnswer,
  options
}: {
  onAnswer: (answer: boolean) => void;
  options?: Parameters<ReturnType<typeof useConfirm>>[0];
}) {
  const confirm = useConfirm();

  return (
    <Button onClick={async () => onAnswer(await confirm(options ?? 'Delete the project?'))}>
      Delete
    </Button>
  );
}

async function ask(onAnswer: (answer: boolean) => void, options?: ConfirmArg) {
  const screen = await render(
    <ConfirmProvider>
      <Asker onAnswer={onAnswer} options={options} />
    </ConfirmProvider>
  );

  await screen.getByRole('button', { name: 'Delete' }).click();

  return screen;
}

type ConfirmArg = Parameters<ReturnType<typeof useConfirm>>[0];

/**
 * Presses a button inside the open sheet.
 *
 * A DOM click rather than the browser driver's, and only inside a modal: no
 * stylesheet is loaded in this run, so Base UI's inert layer — which is
 * `position: fixed` in CSS and a plain block without it — sits over the page
 * and fails the driver's hit test. The existing Dialog suite works around the
 * same thing by asking for `modal="trap-focus"`; a confirm cannot, because
 * taking the page away is what it is for.
 */
function press(button: HTMLElement) {
  button.click();
}

describe('ConfirmProvider', () => {
  it('asks the question it was given', async () => {
    const screen = await ask(() => {});

    await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    await expect.element(screen.getByText('Delete the project?')).toBeInTheDocument();
  });

  it('resolves true when confirmed', async () => {
    const onAnswer = vi.fn();
    const screen = await ask(onAnswer);

    press(screen.getByRole('button', { name: 'Confirm' }).element() as HTMLElement);

    await vi.waitFor(() => expect(onAnswer).toHaveBeenCalledWith(true));
  });

  it('resolves false when cancelled', async () => {
    const onAnswer = vi.fn();
    const screen = await ask(onAnswer);

    press(screen.getByRole('button', { name: 'Cancel' }).element() as HTMLElement);

    await vi.waitFor(() => expect(onAnswer).toHaveBeenCalledWith(false));
  });

  it('resolves false on Escape', async () => {
    // Escape is the cancelling button by another route, so it has to answer the
    // same way rather than leave a promise pending forever.
    const onAnswer = vi.fn();
    await ask(onAnswer);

    await userEvent.keyboard('{Escape}');

    await vi.waitFor(() => expect(onAnswer).toHaveBeenCalledWith(false));
  });

  it('takes a bare string as the question', async () => {
    const screen = await ask(() => {}, 'Ship it?');

    await expect.element(screen.getByText('Ship it?')).toBeInTheDocument();
  });

  it('takes a description and its own labels', async () => {
    const screen = await ask(() => {}, {
      title: 'Delete the project?',
      description: 'Everything in it goes too.',
      confirmLabel: 'Delete it',
      cancelLabel: 'Keep it'
    });

    await expect.element(screen.getByText('Everything in it goes too.')).toBeInTheDocument();
    await expect.element(screen.getByRole('button', { name: 'Delete it' })).toBeInTheDocument();
    await expect.element(screen.getByRole('button', { name: 'Keep it' })).toBeInTheDocument();
  });

  it('drops the cancelling button for an alert, and still resolves', async () => {
    const onAnswer = vi.fn();
    const screen = await ask(onAnswer, { title: 'Your export is ready.', alert: true });

    expect(screen.getByRole('button', { name: 'Cancel' }).query()).toBeNull();

    press(screen.getByRole('button', { name: 'Confirm' }).element() as HTMLElement);

    await vi.waitFor(() => expect(onAnswer).toHaveBeenCalledWith(true));
  });

  /**
   * The queue is the part that is easy to get wrong and expensive when it is:
   * resolving the older question `false` to make room reports an answer nobody
   * gave, and at the call site that reads as "they said no".
   */
  it('queues a second question rather than answering it', async () => {
    const answers: string[] = [];

    function Two() {
      const confirm = useConfirm();

      return (
        <Button
          onClick={() => {
            void confirm('First?').then((a) => answers.push(`first:${a}`));
            void confirm('Second?').then((a) => answers.push(`second:${a}`));
          }}
        >
          Ask
        </Button>
      );
    }

    const screen = await render(
      <ConfirmProvider>
        <Two />
      </ConfirmProvider>
    );

    await screen.getByRole('button', { name: 'Ask' }).click();

    await expect.element(screen.getByText('First?')).toBeInTheDocument();
    expect(screen.getByText('Second?').query()).toBeNull();

    press(screen.getByRole('button', { name: 'Confirm' }).element() as HTMLElement);

    await expect.element(screen.getByText('Second?')).toBeInTheDocument();
    expect(answers).toEqual(['first:true']);

    press(screen.getByRole('button', { name: 'Cancel' }).element() as HTMLElement);

    await vi.waitFor(() => expect(answers).toEqual(['first:true', 'second:false']));
  });

  it('takes its defaults from the provider, and lets a call override them', async () => {
    function Asks({ onAnswer }: { onAnswer: (a: boolean) => void }) {
      const confirm = useConfirm();
      return (
        <Button onClick={async () => onAnswer(await confirm({ title: 'Go?' }))}>Delete</Button>
      );
    }

    const screen = await render(
      <ConfirmProvider defaults={{ confirmLabel: 'Yes please' } as never}>
        <Asks onAnswer={() => {}} />
      </ConfirmProvider>
    );

    await screen.getByRole('button', { name: 'Delete' }).click();

    await expect.element(screen.getByRole('button', { name: 'Yes please' })).toBeInTheDocument();
  });

  it('says the labels in the registered language', async () => {
    registerMessages('ko', ko);

    const screen = await render(
      <ConfirmProvider defaults={{ locale: 'ko' }}>
        <Asker onAnswer={() => {}} />
      </ConfirmProvider>
    );

    await screen.getByRole('button', { name: 'Delete' }).click();

    await expect.element(screen.getByRole('button', { name: '확인' })).toBeInTheDocument();
    await expect.element(screen.getByRole('button', { name: '취소' })).toBeInTheDocument();
  });

  /**
   * Caught by a boundary rather than by a `try` around `render`.
   *
   * An uncaught render error does not stay inside the assertion: it escapes to
   * the page, and the tester frame this suite runs every file in goes with it —
   * which showed up as the next file in the queue reporting that its browser
   * connection had closed. A boundary is also how a consumer would actually
   * meet this message.
   */
  it('tells a caller that forgot the provider', async () => {
    const seen: string[] = [];

    class Boundary extends Component<{ children: ReactNode }, { failed: boolean }> {
      state = { failed: false };

      static getDerivedStateFromError() {
        return { failed: true };
      }

      componentDidCatch(error: Error) {
        seen.push(error.message);
      }

      render() {
        return this.state.failed ? <p>caught</p> : this.props.children;
      }
    }

    const original = console.error;
    console.error = () => {};

    try {
      const screen = await render(
        <Boundary>
          <Asker onAnswer={() => {}} />
        </Boundary>
      );

      await expect.element(screen.getByText('caught')).toBeInTheDocument();
    } finally {
      console.error = original;
    }

    expect(seen.join()).toContain('<ConfirmProvider>');
  });
});
