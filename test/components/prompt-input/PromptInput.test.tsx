import * as React from 'react';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PromptInput } from 'neba';

describe('PromptInput', () => {
  describe('rendering', () => {
    it('renders a textarea named by its label', async () => {
      const screen = await render(<PromptInput label="Message" />);

      await expect.element(screen.getByRole('textbox', { name: 'Message' })).toBeInTheDocument();
    });

    it('draws one button, which sends', async () => {
      const screen = await render(<PromptInput label="Message" />);

      await expect.element(screen.getByRole('button', { name: 'Send' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Stop' }).query()).toBeNull();
    });

    // A phone labelled a key that sends as "return".
    it('tells a phone that Enter sends, and only when it does', async () => {
      const screen = await render(<PromptInput label="Message" />);

      await expect.element(screen.getByRole('textbox')).toHaveAttribute('enterkeyhint', 'send');

      await screen.rerender(<PromptInput label="Message" submitKey="Mod+Enter" />);

      await expect.element(screen.getByRole('textbox')).not.toHaveAttribute('enterkeyhint');
    });

    // The textarea took the caller's id and the label kept pointing at the
    // generated one, which named nothing.
    it('keeps its name when it is given an id', async () => {
      const screen = await render(<PromptInput label="Message" id="composer" />);

      await expect
        .element(screen.getByRole('textbox', { name: 'Message' }))
        .toHaveAttribute('id', 'composer');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<PromptInput label="Message" className="my-own-class" />);

      expect(screen.getByRole('textbox').element().closest('.my-own-class')).not.toBeNull();
    });

    it('holds what it was handed above the field', async () => {
      const screen = await render(
        <PromptInput label="Message">
          <span>report.pdf</span>
        </PromptInput>
      );

      await expect.element(screen.getByText('report.pdf')).toBeInTheDocument();
    });

    it('draws the controls it was given on the toolbar', async () => {
      const screen = await render(
        <PromptInput
          label="Message"
          start={<button type="button">Attach</button>}
          end={<span>1.2k</span>}
        />
      );

      await expect.element(screen.getByRole('button', { name: 'Attach' })).toBeInTheDocument();
      await expect.element(screen.getByText('1.2k')).toBeInTheDocument();
    });
  });

  describe('the value', () => {
    it('reports what was typed', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<PromptInput label="Message" onValueChange={onValueChange} />);

      await screen.getByRole('textbox').fill('hello');

      expect(onValueChange).toHaveBeenCalledWith('hello');
    });

    it('shows a value it was handed', async () => {
      const screen = await render(
        <PromptInput label="Message" value="held" onValueChange={() => {}} />
      );

      await expect.element(screen.getByRole('textbox')).toHaveValue('held');
    });

    it('starts from a default', async () => {
      const screen = await render(<PromptInput label="Message" defaultValue="a draft" />);

      await expect.element(screen.getByRole('textbox')).toHaveValue('a draft');
    });
  });

  describe('sending', () => {
    it('sends what is in the field when the button is pressed', async () => {
      const onSubmit = vi.fn();
      const screen = await render(
        <PromptInput label="Message" defaultValue="hello" onSubmit={onSubmit} />
      );

      await screen.getByRole('button', { name: 'Send' }).click();

      expect(onSubmit).toHaveBeenCalledWith('hello');
    });

    it('sends on the key it was told to send on', async () => {
      const onSubmit = vi.fn();
      const screen = await render(
        <PromptInput label="Message" defaultValue="hello" onSubmit={onSubmit} />
      );
      const control = screen.getByRole('textbox');

      await control.click();
      await expect.element(control).toHaveFocus();
      await control.fill('hello');
      await screen.getByRole('textbox').click();
      await control
        .element()
        .dispatchEvent(
          new KeyboardEvent('keydown', { key: 'Enter', bubbles: true, cancelable: true })
        );

      expect(onSubmit).toHaveBeenCalledWith('hello');
    });

    it('breaks the line rather than sending when the modifier is held', async () => {
      const onSubmit = vi.fn();
      const screen = await render(
        <PromptInput label="Message" defaultValue="hello" onSubmit={onSubmit} />
      );

      screen
        .getByRole('textbox')
        .element()
        .dispatchEvent(
          new KeyboardEvent('keydown', {
            key: 'Enter',
            shiftKey: true,
            bubbles: true,
            cancelable: true
          })
        );

      expect(onSubmit).not.toHaveBeenCalled();
    });

    it('sends on Mod+Enter when that is the key', async () => {
      const onSubmit = vi.fn();
      const screen = await render(
        <PromptInput
          label="Message"
          defaultValue="hello"
          submitKey="Mod+Enter"
          onSubmit={onSubmit}
        />
      );
      const control = screen.getByRole('textbox').element();

      control.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'Enter', bubbles: true, cancelable: true })
      );

      expect(onSubmit).not.toHaveBeenCalled();

      /* `Mod` is Command on a Mac and Control everywhere else, and the
         modifiers are matched exactly — so exactly one of these two fires,
         whichever platform the suite is running on. */
      for (const modifier of ['ctrlKey', 'metaKey'] as const) {
        control.dispatchEvent(
          new KeyboardEvent('keydown', {
            key: 'Enter',
            [modifier]: true,
            bubbles: true,
            cancelable: true
          })
        );
      }

      expect(onSubmit).toHaveBeenCalledTimes(1);
      expect(onSubmit).toHaveBeenCalledWith('hello');
    });

    it('never sends an empty field', async () => {
      const onSubmit = vi.fn();
      const screen = await render(<PromptInput label="Message" onSubmit={onSubmit} />);

      await expect.element(screen.getByRole('button', { name: 'Send' })).toBeDisabled();

      screen
        .getByRole('textbox')
        .element()
        .dispatchEvent(
          new KeyboardEvent('keydown', { key: 'Enter', bubbles: true, cancelable: true })
        );

      expect(onSubmit).not.toHaveBeenCalled();
    });

    it('leaves the field alone once it has sent', async () => {
      const onSubmit = vi.fn();
      const screen = await render(
        <PromptInput label="Message" defaultValue="hello" onSubmit={onSubmit} />
      );

      await screen.getByRole('button', { name: 'Send' }).click();

      await expect.element(screen.getByRole('textbox')).toHaveValue('hello');
    });
  });

  describe('stopping', () => {
    it('turns the one button into a stop button', async () => {
      const screen = await render(<PromptInput label="Message" defaultValue="hello" submitting />);

      await expect.element(screen.getByRole('button', { name: 'Stop' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Send' }).query()).toBeNull();
    });

    it('is pressable even with nothing in the field', async () => {
      const onStop = vi.fn();
      const screen = await render(<PromptInput label="Message" submitting onStop={onStop} />);

      await screen.getByRole('button', { name: 'Stop' }).click();

      expect(onStop).toHaveBeenCalled();
    });

    it('does not send while it is writing an answer', async () => {
      const onSubmit = vi.fn();
      const screen = await render(
        <PromptInput label="Message" defaultValue="hello" submitting onSubmit={onSubmit} />
      );

      screen
        .getByRole('textbox')
        .element()
        .dispatchEvent(
          new KeyboardEvent('keydown', { key: 'Enter', bubbles: true, cancelable: true })
        );

      expect(onSubmit).not.toHaveBeenCalled();
    });

    it('does not send what is in the field when stop ends the answer', async () => {
      const onSubmit = vi.fn();
      const onStop = vi.fn();

      function Chat() {
        const [submitting, setSubmitting] = React.useState(true);

        return (
          <PromptInput
            label="Message"
            defaultValue="a follow-up"
            submitting={submitting}
            onSubmit={onSubmit}
            onStop={() => {
              onStop();
              setSubmitting(false);
            }}
          />
        );
      }

      const screen = await render(<Chat />);

      await screen.getByRole('button', { name: 'Stop' }).click();

      await expect.element(screen.getByRole('button', { name: 'Send' })).toBeInTheDocument();
      expect(onStop).toHaveBeenCalledTimes(1);
      expect(onSubmit).not.toHaveBeenCalled();
    });

    it('stops even when the field is required and empty', async () => {
      const onStop = vi.fn();
      const screen = await render(
        <PromptInput label="Message" required submitting onStop={onStop} />
      );

      await screen.getByRole('button', { name: 'Stop' }).click();

      expect(onStop).toHaveBeenCalledTimes(1);
    });
  });

  describe('files', () => {
    /** A DataTransfer carrying one file, and an item that says it is one. */
    function transferWith(file: File): DataTransfer {
      const transfer = new DataTransfer();

      transfer.items.add(file);

      return transfer;
    }

    it('reports what was dropped on it', async () => {
      const onFiles = vi.fn();
      const screen = await render(<PromptInput label="Message" onFiles={onFiles} />);
      const shell = screen.getByRole('textbox').element().parentElement as HTMLElement;
      const file = new File(['hello'], 'note.txt', { type: 'text/plain' });

      shell.dispatchEvent(
        new DragEvent('drop', {
          bubbles: true,
          cancelable: true,
          dataTransfer: transferWith(file)
        })
      );

      expect(onFiles).toHaveBeenCalledTimes(1);
      expect(onFiles.mock.calls[0][0][0].name).toBe('note.txt');
    });

    /** A drag of one file, as each event of it is dispatched. */
    const fileDrag = (type: string) =>
      new DragEvent(type, {
        bubbles: true,
        cancelable: true,
        dataTransfer: transferWith(new File(['hello'], 'note.txt', { type: 'text/plain' }))
      });

    it('takes no drop while it takes no input', async () => {
      const onFiles = vi.fn();
      const screen = await render(<PromptInput label="Message" disabled onFiles={onFiles} />);
      const shell = screen.getByRole('textbox').element().parentElement as HTMLElement;

      shell.dispatchEvent(fileDrag('dragenter'));
      shell.dispatchEvent(fileDrag('drop'));

      expect(onFiles).not.toHaveBeenCalled();
      await expect.poll(() => shell.dataset.dropping).toBeUndefined();

      await screen.rerender(<PromptInput label="Message" readOnly onFiles={onFiles} />);
      shell.dispatchEvent(fileDrag('drop'));

      expect(onFiles).not.toHaveBeenCalled();
    });

    it('is not a drop target at all without a handler', async () => {
      const screen = await render(<PromptInput label="Message" />);
      const shell = screen.getByRole('textbox').element().parentElement as HTMLElement;

      shell.dispatchEvent(fileDrag('dragenter'));

      await expect.poll(() => shell.dataset.dropping).toBeUndefined();
    });

    // `dragleave` bubbles, so a drag crossing onto the field inside the shell
    // fires one the shell would otherwise believe.
    it('stays ready while the drag moves over what is inside it', async () => {
      const screen = await render(<PromptInput label="Message" onFiles={() => {}} />);
      const control = screen.getByRole('textbox').element();
      const shell = control.parentElement as HTMLElement;

      shell.dispatchEvent(fileDrag('dragenter'));
      await expect.poll(() => shell.dataset.dropping).toBe('true');

      control.dispatchEvent(fileDrag('dragenter'));
      control.dispatchEvent(fileDrag('dragleave'));

      await expect.poll(() => shell.dataset.dropping).toBe('true');

      shell.dispatchEvent(fileDrag('dragleave'));

      await expect.poll(() => shell.dataset.dropping).toBeUndefined();
    });

    // Text selected elsewhere and dragged in is the field's to insert. The
    // zone lit up for it, cancelled the insertion and reported no files.
    it('leaves a drag of text to the field', async () => {
      const onFiles = vi.fn();
      const screen = await render(<PromptInput label="Message" onFiles={onFiles} />);
      const control = screen.getByRole('textbox').element();
      const shell = control.parentElement as HTMLElement;
      const text = new DataTransfer();

      text.setData('text/plain', 'a quoted line');

      const enter = new DragEvent('dragenter', {
        bubbles: true,
        cancelable: true,
        dataTransfer: text
      });
      const drop = new DragEvent('drop', { bubbles: true, cancelable: true, dataTransfer: text });

      control.dispatchEvent(enter);
      control.dispatchEvent(drop);

      expect(enter.defaultPrevented).toBe(false);
      expect(drop.defaultPrevented).toBe(false);
      expect(onFiles).not.toHaveBeenCalled();
      await expect.poll(() => shell.dataset.dropping).toBeUndefined();
    });

    // A folder is filtered out of a drop, and a drop of nothing else was
    // still reported, as no files at all.
    it('reports nothing when only a folder was dropped', async () => {
      const onFiles = vi.fn();
      const screen = await render(<PromptInput label="Message" onFiles={onFiles} />);
      const shell = screen.getByRole('textbox').element().parentElement as HTMLElement;
      const real = Object.getOwnPropertyDescriptor(DataTransferItem.prototype, 'webkitGetAsEntry');

      // A synthetic transfer has no filesystem behind it, so the entry is
      // stubbed on the prototype. See the FilePicker's folder test.
      Object.defineProperty(DataTransferItem.prototype, 'webkitGetAsEntry', {
        configurable: true,
        value: () => ({ isFile: false, isDirectory: true })
      });

      try {
        shell.dispatchEvent(
          new DragEvent('drop', {
            bubbles: true,
            cancelable: true,
            dataTransfer: transferWith(new File([], 'photos', { type: '' }))
          })
        );
      } finally {
        if (real) Object.defineProperty(DataTransferItem.prototype, 'webkitGetAsEntry', real);
      }

      expect(onFiles).not.toHaveBeenCalled();
    });

    // Escape cancels a drag, and a drop outside the window ends it somewhere
    // the shell never hears about. Neither fires a `dragleave` on it.
    it('puts the ready state out when a drag is abandoned rather than dropped', async () => {
      const screen = await render(<PromptInput label="Message" onFiles={() => {}} />);
      const shell = screen.getByRole('textbox').element().parentElement as HTMLElement;

      shell.dispatchEvent(fileDrag('dragenter'));
      await expect.poll(() => shell.dataset.dropping).toBe('true');

      document.dispatchEvent(new DragEvent('dragend', { bubbles: true }));

      await expect.poll(() => shell.dataset.dropping).toBeUndefined();
    });
  });

  describe('its own words', () => {
    it('lets a caller write them out', async () => {
      const screen = await render(
        <PromptInput label="Message" labels={{ send: 'Envoyer' }} defaultValue="bonjour" />
      );

      await expect.element(screen.getByRole('button', { name: 'Envoyer' })).toBeInTheDocument();
    });
  });
});
