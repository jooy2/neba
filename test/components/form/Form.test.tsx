import * as React from 'react';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  Button,
  ColorPicker,
  DatePicker,
  DateRangePicker,
  Form,
  TextField,
  TreeSelect,
  type TreeSelectItem
} from 'neba';

describe('Form', () => {
  describe('rendering', () => {
    it('renders a real form', async () => {
      const screen = await render(
        <Form aria-label="Sign up">
          <TextField label="Email" name="email" />
        </Form>
      );
      const element = screen.getByRole('form', { name: 'Sign up' }).element();

      expect(element.tagName).toBe('FORM');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <Form aria-label="Sign up" className="my-own-class">
          <TextField label="Email" name="email" />
        </Form>
      );

      expect(screen.getByRole('form').element()).toHaveClass('my-own-class');
    });

    it('stacks its children on the size ladder', async () => {
      const screen = await render(
        <Form aria-label="Sign up" size="xl">
          <TextField label="Email" name="email" />
        </Form>
      );

      expect(screen.getByRole('form').element()).toHaveClass('gap-4');
    });

    it('stands its children `spacing` apart instead', async () => {
      const screen = await render(
        <Form aria-label="Sign up" spacing={8}>
          <TextField label="Email" name="email" />
        </Form>
      );
      const element = screen.getByRole('form').element() as HTMLElement;

      expect(element.style.gap).toBe('2rem');
      expect(element).not.toHaveClass('gap-4');
    });

    it('takes a spacing of 0, and keeps the style it was handed beside the gap', async () => {
      const screen = await render(
        <Form aria-label="Sign up" spacing={0} style={{ paddingTop: '3px' }}>
          <TextField label="Email" name="email" />
        </Form>
      );
      const element = screen.getByRole('form').element() as HTMLElement;

      expect(element.style.gap).toBe('0rem');
      expect(element.style.paddingTop).toBe('3px');
    });

    it('leaves `spacing` off the element', async () => {
      const screen = await render(
        <Form aria-label="Sign up" spacing={5}>
          <TextField label="Email" name="email" />
        </Form>
      );

      expect(screen.getByRole('form').element()).not.toHaveAttribute('spacing');
    });
  });

  describe('submitting', () => {
    it('hands the values over and navigates nowhere', async () => {
      const onSubmit = vi.fn();
      const screen = await render(
        <Form aria-label="Sign up" onSubmit={onSubmit}>
          <TextField label="Email" name="email" defaultValue="a@b.com" />
          <Button type="submit">Sign up</Button>
        </Form>
      );

      await screen.getByRole('button', { name: 'Sign up' }).click();

      expect(onSubmit).toHaveBeenCalledTimes(1);
      expect(onSubmit.mock.calls[0][0]).toMatchObject({ email: 'a@b.com' });
    });

    // A function `action` is React 19's. React 18 drops it, and the submit
    // then navigates the test frame away.
    it.skipIf(React.version.startsWith('18.'))(
      'lets an action run when there is no onSubmit',
      async () => {
        const action = vi.fn();
        const screen = await render(
          <Form aria-label="Sign up" action={action}>
            <TextField label="Email" name="email" defaultValue="a@b.com" />
            <Button type="submit">Sign up</Button>
          </Form>
        );

        await screen.getByRole('button', { name: 'Sign up' }).click();

        await expect.poll(() => action.mock.calls.length).toBe(1);
        expect((action.mock.calls[0][0] as FormData).get('email')).toBe('a@b.com');
      }
    );

    it('keeps an action from running while a required field is empty', async () => {
      const action = vi.fn();
      const screen = await render(
        <Form aria-label="Sign up" action={action}>
          <TextField label="Email" name="email" required />
          <Button type="submit">Sign up</Button>
        </Form>
      );

      await screen.getByRole('button', { name: 'Sign up' }).click();
      await new Promise((resolve) => setTimeout(resolve, 50));

      expect(action).not.toHaveBeenCalled();
    });

    it('does not submit while a required field is empty', async () => {
      const onSubmit = vi.fn();
      const screen = await render(
        <Form aria-label="Sign up" onSubmit={onSubmit}>
          <TextField label="Email" name="email" required />
          <Button type="submit">Sign up</Button>
        </Form>
      );

      await screen.getByRole('button', { name: 'Sign up' }).click();

      expect(onSubmit).not.toHaveBeenCalled();
    });
  });

  // A picker's trigger is a button, which registers nothing with Base UI's
  // Form: its value was missing from `onSubmit`, a required one let the form
  // submit empty, and an error under its `name` never showed.
  describe('pickers', () => {
    const REGIONS: TreeSelectItem[] = [
      { value: 'kr', label: 'Korea' },
      { value: 'jp', label: 'Japan' },
      { value: 'fr', label: 'France' }
    ];

    it('hands a picker\u2019s value to onSubmit under its name', async () => {
      const onSubmit = vi.fn();
      const screen = await render(
        <Form aria-label="Trip" onSubmit={onSubmit}>
          <DatePicker label="Departure" name="departure" defaultValue={new Date(2026, 8, 28)} />
          <ColorPicker label="Tag" name="tag" defaultValue="#336699" />
          <TreeSelect label="Region" name="region" items={REGIONS} defaultValue="jp" />
          <Button type="submit">Save</Button>
        </Form>
      );

      await screen.getByRole('button', { name: 'Save' }).click();

      expect(onSubmit).toHaveBeenCalledTimes(1);
      expect(onSubmit.mock.calls[0][0]).toMatchObject({
        departure: '2026-09-28',
        tag: '#336699',
        region: 'jp'
      });
    });

    it('hands a range\u2019s two ends and a multiple choice over as arrays', async () => {
      const onSubmit = vi.fn();
      const screen = await render(
        <Form aria-label="Trip" onSubmit={onSubmit}>
          <DateRangePicker
            label="Stay"
            name="stay"
            defaultValue={{ start: new Date(2026, 8, 1), end: new Date(2026, 8, 5) }}
          />
          <TreeSelect
            label="Regions"
            name="regions"
            items={REGIONS}
            multiple
            defaultValue={['kr', 'fr']}
          />
          <Button type="submit">Save</Button>
        </Form>
      );

      await screen.getByRole('button', { name: 'Save' }).click();

      expect(onSubmit.mock.calls[0][0]).toMatchObject({
        stay: ['2026-09-01', '2026-09-05'],
        regions: ['kr', 'fr']
      });
    });

    it('holds the submit while a required picker is empty, and focuses it', async () => {
      const onSubmit = vi.fn();
      const screen = await render(
        <Form aria-label="Trip" onSubmit={onSubmit}>
          <DatePicker label="Departure" name="departure" required />
          <Button type="submit">Save</Button>
        </Form>
      );

      await screen.getByRole('button', { name: 'Save' }).click();

      expect(onSubmit).not.toHaveBeenCalled();
      await expect.element(screen.getByRole('button', { name: /^Departure/ })).toHaveFocus();
    });

    it('shows an error from outside on the picker it names', async () => {
      const screen = await render(
        <Form aria-label="Trip" errors={{ departure: 'No flights that day.' }}>
          <DatePicker label="Departure" name="departure" />
        </Form>
      );

      await expect.element(screen.getByText('No flights that day.')).toBeInTheDocument();
    });

    it('still submits the same fields natively', async () => {
      const screen = await render(
        <form aria-label="Trip">
          <DateRangePicker
            label="Stay"
            name="stay"
            defaultValue={{ start: new Date(2026, 8, 1), end: new Date(2026, 8, 5) }}
          />
          <DatePicker label="Departure" name="departure" defaultValue={new Date(2026, 8, 28)} />
        </form>
      );
      const data = new FormData(screen.getByRole('form').element() as HTMLFormElement);

      expect(data.getAll('stay')).toEqual(['2026-09-01', '2026-09-05']);
      expect(data.getAll('departure')).toEqual(['2026-09-28']);
    });
  });

  describe('errors', () => {
    it('puts an error from outside onto the field it belongs to', async () => {
      const screen = await render(
        <Form aria-label="Sign up" errors={{ email: 'That address is already taken.' }}>
          <TextField label="Email" name="email" />
        </Form>
      );

      await expect.element(screen.getByText('That address is already taken.')).toBeInTheDocument();
    });

    // The message is on its way out rather than gone: Base UI keeps the node
    // mounted while an exit transition might still run, so the field's own
    // validity is what says the error has been cleared.
    it('drops it again once the field changes', async () => {
      const screen = await render(
        <Form aria-label="Sign up" errors={{ email: 'That address is already taken.' }}>
          <TextField label="Email" name="email" />
        </Form>
      );
      const field = screen.getByLabelText('Email');

      await expect.element(field).toHaveAttribute('aria-invalid', 'true');

      await field.fill('someone@else.com');

      await expect.element(field).not.toHaveAttribute('aria-invalid');
    });
  });
});
