import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button } from 'neba';

describe('Button', () => {
  it('renders the given text', async () => {
    const screen = await render(<Button text="Save" />);

    await expect.element(screen.getByRole('button', { name: 'Save' })).toBeInTheDocument();
  });

  it('renders an interactive native button rather than a generic element', async () => {
    const screen = await render(<Button text="Save" />);
    const element = screen.getByRole('button').element();

    expect(element.tagName).toBe('BUTTON');
    expect(element).toBeEnabled();
  });

  it('reflects a changed text prop on re-render', async () => {
    const screen = await render(<Button text="Before" />);

    await screen.rerender(<Button text="After" />);

    await expect.element(screen.getByRole('button', { name: 'After' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Before' }).query()).toBeNull();
  });

  it('lets click events reach a parent handler', async () => {
    const onClick = vi.fn();
    const screen = await render(
      <div onClick={onClick}>
        <Button text="Click me" />
      </div>
    );

    await screen.getByRole('button', { name: 'Click me' }).click();

    expect(onClick).toHaveBeenCalledTimes(1);
  });
});
