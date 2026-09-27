import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Checkbox, ColorPicker, Fieldset, FilePicker, Select, Switch, TextField } from 'neba';

describe('Fieldset', () => {
  describe('rendering', () => {
    it('renders a group named by its legend', async () => {
      const screen = await render(
        <Fieldset legend="Billing address">
          <TextField label="Street" />
        </Fieldset>
      );

      await expect
        .element(screen.getByRole('group', { name: 'Billing address' }))
        .toBeInTheDocument();
    });

    it('renders a real fieldset, named by the legend it points at', async () => {
      const screen = await render(
        <Fieldset legend="Billing address">
          <TextField label="Street" />
        </Fieldset>
      );
      const element = screen.getByRole('group').element();

      expect(element.tagName).toBe('FIELDSET');
      expect(element).toHaveAttribute('aria-labelledby');
    });

    it('renders the description under the legend', async () => {
      const screen = await render(
        <Fieldset legend="Billing address" description="Where the card statement goes.">
          <TextField label="Street" />
        </Fieldset>
      );

      await expect.element(screen.getByText('Where the card statement goes.')).toBeInTheDocument();
    });

    it('describes the group by the description and leaves it out of the name', async () => {
      const screen = await render(
        <Fieldset
          legend="Billing address"
          description="Where the card statement goes."
          aria-describedby="note"
        >
          <TextField label="Street" />
          <p id="note">Required.</p>
        </Fieldset>
      );
      const group = screen.getByRole('group', { name: 'Billing address' });

      await expect.element(group).toBeInTheDocument();
      await expect
        .element(group)
        .toHaveAccessibleDescription('Required. Where the card statement goes.');
    });

    it('draws no legend when there is nothing to put in one', async () => {
      const screen = await render(
        <Fieldset>
          <TextField label="Street" />
        </Fieldset>
      );

      expect(screen.getByRole('group').element()).not.toHaveAttribute('aria-labelledby');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <Fieldset legend="Address" className="my-own-class">
          <TextField label="Street" />
        </Fieldset>
      );

      expect(screen.getByRole('group').element()).toHaveClass('my-own-class');
    });

    it('reflects a changed legend on re-render', async () => {
      const screen = await render(<Fieldset legend="Before">body</Fieldset>);

      await screen.rerender(<Fieldset legend="After">body</Fieldset>);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
    });
  });

  describe('disabled', () => {
    it('disables every control inside at once', async () => {
      const screen = await render(
        <Fieldset legend="Address" disabled>
          <TextField label="Street" />
          <TextField label="City" />
        </Fieldset>
      );

      await expect.element(screen.getByLabelText('Street')).toBeDisabled();
      await expect.element(screen.getByLabelText('City')).toBeDisabled();
    });

    // Base UI stopped them answering, and each drew itself from its own
    // `disabled` prop, so a disabled group of fields looked available.
    it('draws every field inside it disabled', async () => {
      const screen = await render(
        <Fieldset legend="Address" disabled>
          <TextField label="Street" />
          <Checkbox label="Save it" />
          <Switch label="Default" />
          <Select label="Country" items={[{ value: 'kr', label: 'Korea' }]} />
        </Fieldset>
      );

      for (const text of ['Street', 'Save it', 'Default', 'Country']) {
        await expect
          .element(screen.getByText(text, { exact: true }).first())
          .toHaveClass('text-(--neba-disabled-fg)');
      }
    });

    // Neither is a control Base UI's Fieldset knows about, so the drop zone and
    // the colour square went on taking input, and looked as if they would.
    it('takes no dropped file and no colour inside it', async () => {
      const onFilesChange = vi.fn();
      const onValueChange = vi.fn();
      const screen = await render(
        <Fieldset legend="Brand" disabled>
          <FilePicker onFilesChange={onFilesChange} />
          <ColorPicker inline label="Accent" onValueChange={onValueChange} />
        </Fieldset>
      );
      const zone = screen.getByRole('button', { name: /Drop files here/ }).element();
      const transfer = new DataTransfer();

      transfer.items.add(new File(['x'], 'logo.svg', { type: 'image/svg+xml' }));
      zone.dispatchEvent(
        new DragEvent('drop', { bubbles: true, cancelable: true, dataTransfer: transfer })
      );
      screen
        .getByRole('slider')
        .first()
        .element()
        .dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true }));
      await new Promise((resolve) => setTimeout(resolve, 0));

      expect(onFilesChange).not.toHaveBeenCalled();
      expect(onValueChange).not.toHaveBeenCalled();
      await expect
        .element(screen.getByText('Accent', { exact: true }))
        .toHaveClass('text-(--neba-disabled-fg)');
    });

    it('leaves them alone when it is not', async () => {
      const screen = await render(
        <Fieldset legend="Address">
          <TextField label="Street" />
        </Fieldset>
      );

      await expect.element(screen.getByLabelText('Street')).not.toBeDisabled();
    });
  });
});
