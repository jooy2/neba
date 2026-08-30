import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button, Form, TextField } from 'neba';

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
