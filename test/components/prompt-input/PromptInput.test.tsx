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
