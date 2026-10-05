import type { ComponentProps } from 'react';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button, Checkbox, CheckboxGroup, Fieldset, Form, NebaProvider } from 'neba';

function Alerts(props: ComponentProps<typeof CheckboxGroup>) {
  return (
    <CheckboxGroup label="Email me about" {...props}>
      <Checkbox value="deploys" label="Deploys" />
      <Checkbox value="members" label="New members" />
      <Checkbox value="digest" label="The weekly digest" />
    </CheckboxGroup>
  );
}

/** Every `--n-fill` the ticks were given, in order. */
const fills = (container: HTMLElement) =>
  [...container.querySelectorAll<HTMLElement>('[style*="--n-fill"]')].map((element) =>
    element.style.getPropertyValue('--n-fill')
  );

describe('CheckboxGroup', () => {
  describe('rendering', () => {
    it('renders a group named by its label, holding its checkboxes', async () => {
      const screen = await render(<Alerts />);

      await expect
        .element(screen.getByRole('group', { name: 'Email me about' }))
        .toBeInTheDocument();
      await expect.element(screen.getByRole('checkbox', { name: 'Deploys' })).toBeInTheDocument();
      expect(screen.getByRole('checkbox').elements()).toHaveLength(3);
    });

    it('describes the group by its description', async () => {
      const screen = await render(<Alerts description="Sent from noreply@example.com." />);

      await expect
        .element(screen.getByRole('group', { name: 'Email me about' }))
        .toHaveAccessibleDescription('Sent from noreply@example.com.');
    });

    it('stacks the checkboxes vertically by default and in a row on request', async () => {
      const screen = await render(<Alerts />);

      expect(screen.getByRole('group').element()).toHaveClass('flex-col', 'gap-3');

      await screen.rerender(<Alerts orientation="horizontal" />);

      expect(screen.getByRole('group').element()).toHaveClass('flex-row', 'gap-x-5', 'gap-y-3');

      await screen.rerender(<Alerts size="xs" />);

      expect(screen.getByRole('group').element()).toHaveClass('gap-1.5');
    });

    it('stands the checkboxes `spacing` apart on both axes', async () => {
      const screen = await render(<Alerts spacing={3} />);
      const group = screen.getByRole('group').element() as HTMLElement;

      expect(group.style.gap).toBe('0.75rem');
      expect(group).not.toHaveClass('gap-3');
      expect(group).not.toHaveAttribute('spacing');
    });

    it('takes no spacing from a provider', async () => {
      const screen = await render(
        <NebaProvider defaults={{ spacing: 8 }}>
          <Alerts />
        </NebaProvider>
      );

      expect((screen.getByRole('group').element() as HTMLElement).style.gap).toBe('');
    });

    it('keeps caller-supplied class names and slots where they belong', async () => {
      const screen = await render(
        <Alerts
          className="my-own-class"
          style={{ paddingTop: '3px' }}
          classNames={{ label: 'my-label', control: 'my-control', error: 'my-error' }}
          error="Pick at least one."
        />
      );
      const root = screen.getByText('Email me about').element().closest('.my-own-class');

      expect(root).not.toBeNull();
      expect((root as HTMLElement).style.paddingTop).toBe('3px');
      expect(screen.getByText('Email me about').element()).toHaveClass('my-label');
      expect(screen.getByRole('group').element()).toHaveClass('my-control');
      expect(screen.getByText('Pick at least one.').element()).toHaveClass('my-error');
    });
  });

  // The ticks render at zero size with no stylesheet loaded, so every click
  // goes through a label, as it does in Checkbox's own tests.
  describe('the value', () => {
    it('ticks what defaultValue names and reports the new array', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Alerts defaultValue={['digest']} onValueChange={onValueChange} />
      );

      await expect
        .element(screen.getByRole('checkbox', { name: 'The weekly digest' }))
        .toBeChecked();
      await expect.element(screen.getByRole('checkbox', { name: 'Deploys' })).not.toBeChecked();

      await screen.getByText('Deploys').click();

      expect(onValueChange).toHaveBeenCalledTimes(1);
      expect(onValueChange.mock.calls[0][0]).toEqual(['digest', 'deploys']);
      await expect.element(screen.getByRole('checkbox', { name: 'Deploys' })).toBeChecked();
    });

    it('follows a controlled value', async () => {
      const screen = await render(<Alerts value={['members']} onValueChange={() => {}} />);

      await expect.element(screen.getByRole('checkbox', { name: 'New members' })).toBeChecked();

      await screen.rerender(<Alerts value={['deploys']} onValueChange={() => {}} />);

      await expect.element(screen.getByRole('checkbox', { name: 'New members' })).not.toBeChecked();
      await expect.element(screen.getByRole('checkbox', { name: 'Deploys' })).toBeChecked();
    });

    it('ticks every option from a parent checkbox, and draws the parent half-ticked', async () => {
      const values = ['deploys', 'members', 'digest'];
      const screen = await render(
        <CheckboxGroup label="Email me about" allValues={values} defaultValue={['digest']}>
          <Checkbox parent label="Everything" />
          <Checkbox value="deploys" label="Deploys" />
          <Checkbox value="members" label="New members" />
          <Checkbox value="digest" label="The weekly digest" />
        </CheckboxGroup>
      );
      const parent = screen.getByRole('checkbox', { name: 'Everything' });

      await expect.element(parent).toHaveAttribute('aria-checked', 'mixed');
      // The mark follows the state Base UI settled on: a dash, not a tick.
      expect(parent.element().querySelector('path')).toHaveAttribute('d', 'M2.5 6h7');

      await screen.getByText('Everything').click();

      await expect.element(parent).toBeChecked();
      for (const name of ['Deploys', 'New members', 'The weekly digest']) {
        await expect.element(screen.getByRole('checkbox', { name })).toBeChecked();
      }
    });
  });

  describe('what each checkbox inherits', () => {
    it('sizes every checkbox from the group, unless one sets its own', async () => {
      const screen = await render(
        <CheckboxGroup label="Size" size="xl">
          <Checkbox value="a" label="Inherited" />
          <Checkbox value="b" label="Own" size="xs" />
        </CheckboxGroup>
      );

      expect(screen.getByRole('checkbox', { name: 'Inherited' }).element()).toHaveClass('size-6');
      expect(screen.getByRole('checkbox', { name: 'Own' }).element()).not.toHaveClass('size-6');
    });

    it('beats the provider’s size with its own', async () => {
      const screen = await render(
        <NebaProvider defaults={{ size: 'xs' }}>
          <CheckboxGroup label="Size" size="xl">
            <Checkbox value="a" label="Inherited" />
          </CheckboxGroup>
        </NebaProvider>
      );

      expect(screen.getByRole('checkbox', { name: 'Inherited' }).element()).toHaveClass('size-6');
    });

    it('colours every checkbox from the group, and turns all of them danger when invalid', async () => {
      const screen = await render(
        <CheckboxGroup label="Colour" color="success">
          <Checkbox value="a" label="Inherited" />
          <Checkbox value="b" label="Own" color="info" />
        </CheckboxGroup>
      );

      expect(fills(screen.container)).toEqual([
        'var(--neba-success-fill)',
        'var(--neba-info-fill)'
      ]);

      await screen.rerender(
        <CheckboxGroup label="Colour" color="success" error="Pick one.">
          <Checkbox value="a" label="Inherited" />
          <Checkbox value="b" label="Own" color="info" />
        </CheckboxGroup>
      );

      expect(fills(screen.container)).toEqual([
        'var(--neba-danger-fill)',
        'var(--neba-danger-fill)'
      ]);
      await expect.element(screen.getByText('Pick one.')).toBeInTheDocument();
    });

    it('disables every checkbox, and draws them disabled', async () => {
      const screen = await render(<Alerts disabled />);
      const deploys = screen.getByRole('checkbox', { name: 'Deploys' });

      await expect.element(deploys).toBeDisabled();
      expect(deploys.element()).toHaveClass('cursor-not-allowed');
    });

    it('is disabled inside a disabled Fieldset', async () => {
      const screen = await render(
        <Fieldset legend="Settings" disabled>
          <Alerts />
        </Fieldset>
      );

      expect(screen.getByRole('checkbox', { name: 'Deploys' }).element()).toHaveClass(
        'cursor-not-allowed'
      );
    });

    it('holds every checkbox read-only', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Alerts readOnly defaultValue={['digest']} onValueChange={onValueChange} />
      );

      await screen.getByText('Deploys').click();

      expect(onValueChange).not.toHaveBeenCalled();
      await expect.element(screen.getByRole('checkbox', { name: 'Deploys' })).not.toBeChecked();
      await expect
        .element(screen.getByRole('checkbox', { name: 'Deploys' }))
        .toHaveAttribute('aria-readonly', 'true');
    });
  });

  describe('submitting', () => {
    it('submits one entry per ticked checkbox under the group’s name', async () => {
      const screen = await render(
        <form aria-label="Settings">
          <Alerts name="alerts" defaultValue={['deploys', 'digest']} />
        </form>
      );
      const data = new FormData(screen.getByRole('form').element() as HTMLFormElement);

      expect(data.getAll('alerts')).toEqual(['deploys', 'digest']);
    });

    it('hands a Form’s onSubmit the ticked values as an array', async () => {
      const onSubmit = vi.fn();
      const screen = await render(
        <Form aria-label="Settings" onSubmit={onSubmit}>
          <Alerts name="alerts" defaultValue={['members']} />
          <Button type="submit">Save</Button>
        </Form>
      );

      await screen.getByText('Deploys').click();
      await screen.getByRole('button', { name: 'Save' }).click();

      expect(onSubmit).toHaveBeenCalledTimes(1);
      expect(onSubmit.mock.calls[0][0]).toMatchObject({ alerts: ['members', 'deploys'] });
    });

    it('shows an error a Form puts on its name', async () => {
      const screen = await render(
        <Form aria-label="Settings" errors={{ alerts: 'Choose at least one.' }}>
          <Alerts name="alerts" />
        </Form>
      );

      await expect.element(screen.getByText('Choose at least one.')).toBeInTheDocument();
    });
  });
});
