import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Fieldset, TextField } from 'neba';

describe('Fieldset', () => {
  describe('rendering', () => {
    it('renders a group named by its legend', async () => {
      const screen = await render(
        <Fieldset legend="Billing address">
          <TextField label="Street" />
        </Fieldset>
      );

      await expect
        .element(screen.getByRole('group', { name: /Billing address/ }))
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
