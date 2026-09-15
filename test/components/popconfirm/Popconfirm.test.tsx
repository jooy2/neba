import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
import { Button, Popconfirm } from 'neba';
import { ko, registerMessages } from 'neba/locales';

registerMessages('ko', ko);

const trigger = <Button>Delete</Button>;

describe('Popconfirm', () => {
  it('renders nothing until the trigger is pressed', async () => {
    const screen = await render(
      <Popconfirm trigger={trigger} title="Delete this row?" onConfirm={() => {}} />
    );

    expect(screen.getByText('Delete this row?').query()).toBeNull();

    await screen.getByRole('button', { name: 'Delete' }).click();

    await expect.element(screen.getByText('Delete this row?')).toBeInTheDocument();
  });

  it('names and describes the bubble by its title and description', async () => {
    const screen = await render(
      <Popconfirm
        trigger={trigger}
        title="Delete this row?"
        description="It cannot be undone."
        onConfirm={() => {}}
      />
    );

    await screen.getByRole('button', { name: 'Delete' }).click();

    const bubble = screen.getByRole('dialog', { name: 'Delete this row?' });

    await expect.element(bubble).toBeInTheDocument();
    await expect.element(bubble).toHaveAccessibleDescription('It cannot be undone.');
    expect(screen.getByText('Delete this row?').element().tagName).toBe('P');
  });

  it('calls onConfirm and closes', async () => {
    const onConfirm = vi.fn();
    const screen = await render(
      <Popconfirm trigger={trigger} title="Delete this row?" onConfirm={onConfirm} />
    );

    await screen.getByRole('button', { name: 'Delete' }).click();
    await screen.getByRole('button', { name: 'Confirm' }).click();

    expect(onConfirm).toHaveBeenCalledTimes(1);
    await expect.poll(() => screen.getByText('Delete this row?').query()).toBeNull();
  });

  it('calls onCancel and closes', async () => {
    const onCancel = vi.fn();
    const onConfirm = vi.fn();
    const screen = await render(
      <Popconfirm
        trigger={trigger}
        title="Delete this row?"
        onConfirm={onConfirm}
        onCancel={onCancel}
      />
    );

    await screen.getByRole('button', { name: 'Delete' }).click();
    await screen.getByRole('button', { name: 'Cancel' }).click();

    expect(onCancel).toHaveBeenCalledTimes(1);
    expect(onConfirm).not.toHaveBeenCalled();
    await expect.poll(() => screen.getByText('Delete this row?').query()).toBeNull();
  });

  it('does not call onCancel when dismissed with Escape', async () => {
    // Dismissing is walking away from the question, which is not the same act
    // as answering no — a caller that undoes something in `onCancel` would undo
    // it every time somebody pressed Escape.
    const onCancel = vi.fn();
    const screen = await render(
      <Popconfirm trigger={trigger} title="Delete this row?" onCancel={onCancel} />
    );

    await screen.getByRole('button', { name: 'Delete' }).click();
    await expect.element(screen.getByText('Delete this row?')).toBeInTheDocument();

    await userEvent.keyboard('{Escape}');

    await expect.poll(() => screen.getByText('Delete this row?').query()).toBeNull();
    expect(onCancel).not.toHaveBeenCalled();
  });

  /**
   * The async case is the reason the bubble closes on the promise rather than
   * on the click: a question that vanished before its answer landed is a
   * question the reader has no way to know was heard.
   */
  it('stays open until an async onConfirm settles', async () => {
    let finish!: () => void;
    const work = new Promise<void>((resolve) => {
      finish = resolve;
    });

    const screen = await render(
      <Popconfirm trigger={trigger} title="Delete this row?" onConfirm={() => work} />
    );

    await screen.getByRole('button', { name: 'Delete' }).click();
    await screen.getByRole('button', { name: 'Confirm' }).click();

    await expect.element(screen.getByText('Delete this row?')).toBeInTheDocument();

    finish();

    await expect.poll(() => screen.getByText('Delete this row?').query()).toBeNull();
  });

  // A rejection is the caller's error. The bubble stays open, the button is
  // ready to try again, and the error is left uncaught for the page to report.
  it('stays open and ready again when onConfirm rejects', async () => {
    const swallow = (event: PromiseRejectionEvent) => event.preventDefault();
    window.addEventListener('unhandledrejection', swallow);

    try {
      const screen = await render(
        <Popconfirm
          trigger={trigger}
          title="Delete this row?"
          onConfirm={() => Promise.reject(new Error('Failed'))}
        />
      );

      await screen.getByRole('button', { name: 'Delete' }).click();
      await screen.getByRole('button', { name: 'Confirm' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Confirm' }))
        .not.toHaveAttribute('aria-busy');
      await expect.element(screen.getByText('Delete this row?')).toBeInTheDocument();
    } finally {
      window.removeEventListener('unhandledrejection', swallow);
    }
  });

  it('takes its own labels and a description', async () => {
    const screen = await render(
      <Popconfirm
        trigger={trigger}
        title="Delete this row?"
        description="It cannot be brought back."
        confirmLabel="Delete it"
        cancelLabel="Keep it"
      />
    );

    await screen.getByRole('button', { name: 'Delete' }).click();

    await expect.element(screen.getByText('It cannot be brought back.')).toBeInTheDocument();
    await expect.element(screen.getByRole('button', { name: 'Delete it' })).toBeInTheDocument();
    await expect.element(screen.getByRole('button', { name: 'Keep it' })).toBeInTheDocument();
  });

  it('says the labels in the registered language', async () => {
    const screen = await render(<Popconfirm trigger={trigger} title="삭제할까요?" locale="ko" />);

    await screen.getByRole('button', { name: 'Delete' }).click();

    await expect.element(screen.getByRole('button', { name: '확인' })).toBeInTheDocument();
    await expect.element(screen.getByRole('button', { name: '취소' })).toBeInTheDocument();
  });

  it('honours a controlled open', async () => {
    const onOpenChange = vi.fn();
    const screen = await render(
      <Popconfirm
        trigger={trigger}
        title="Delete this row?"
        open={false}
        onOpenChange={onOpenChange}
      />
    );

    await screen.getByRole('button', { name: 'Delete' }).click();

    expect(onOpenChange).toHaveBeenCalledWith(true);
    expect(screen.getByText('Delete this row?').query()).toBeNull();
  });

  it('keeps caller-supplied class names on the parts it draws', async () => {
    const screen = await render(
      <Popconfirm
        trigger={trigger}
        title="Delete this row?"
        description="Gone for good."
        classNames={{ title: 'my-title-class', description: 'my-description-class' }}
      />
    );

    await screen.getByRole('button', { name: 'Delete' }).click();

    await expect.element(screen.getByText('Delete this row?')).toHaveClass('my-title-class');
    await expect.element(screen.getByText('Gone for good.')).toHaveClass('my-description-class');
  });
});
