import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Toggle, ToggleGroup } from 'neba';

function Marks() {
  return (
    <>
      <Toggle value="bold">Bold</Toggle>
      <Toggle value="italic">Italic</Toggle>
      <Toggle value="underline">Underline</Toggle>
    </>
  );
}

describe('ToggleGroup', () => {
  describe('rendering', () => {
    it('renders every toggle it was given', async () => {
      const screen = await render(
        <ToggleGroup>
          <Marks />
        </ToggleGroup>
      );

      await expect.element(screen.getByRole('button', { name: 'Bold' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Underline' })).toBeInTheDocument();
    });

    it('starts with the default value pressed', async () => {
      const screen = await render(
        <ToggleGroup defaultValue={['italic']}>
          <Marks />
        </ToggleGroup>
      );

      await expect
        .element(screen.getByRole('button', { name: 'Italic' }))
        .toHaveAttribute('aria-pressed', 'true');
      await expect
        .element(screen.getByRole('button', { name: 'Bold' }))
        .toHaveAttribute('aria-pressed', 'false');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <ToggleGroup className="my-own-class">
          <Marks />
        </ToggleGroup>
      );

      expect(screen.getByRole('group').element()).toHaveClass('my-own-class');
    });

    it('turns the row on its side when vertical', async () => {
      const screen = await render(
        <ToggleGroup orientation="vertical">
          <Marks />
        </ToggleGroup>
      );

      expect(screen.getByRole('group').element()).toHaveClass('flex-col');
    });
  });

  describe('selection', () => {
    it('replaces the pressed toggle by default', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <ToggleGroup defaultValue={['bold']} onValueChange={onValueChange}>
          <Marks />
        </ToggleGroup>
      );

      await screen.getByRole('button', { name: 'Italic' }).click();

      expect(onValueChange).toHaveBeenCalledWith(['italic']);
      await expect
        .element(screen.getByRole('button', { name: 'Bold' }))
        .toHaveAttribute('aria-pressed', 'false');
    });

    it('keeps both when multiple is on', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <ToggleGroup multiple defaultValue={['bold']} onValueChange={onValueChange}>
          <Marks />
        </ToggleGroup>
      );

      await screen.getByRole('button', { name: 'Italic' }).click();

      expect(onValueChange).toHaveBeenCalledWith(['bold', 'italic']);
      await expect
        .element(screen.getByRole('button', { name: 'Bold' }))
        .toHaveAttribute('aria-pressed', 'true');
    });

    it('stays where the controlled value puts it', async () => {
      const screen = await render(
        <ToggleGroup value={['bold']}>
          <Marks />
        </ToggleGroup>
      );

      await screen.getByRole('button', { name: 'Italic' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Italic' }))
        .toHaveAttribute('aria-pressed', 'false');
    });
  });

  describe('shared props', () => {
    it('sets the size once for the whole set', async () => {
      const screen = await render(
        <ToggleGroup size="lg">
          <Marks />
        </ToggleGroup>
      );

      expect(screen.getByRole('button', { name: 'Bold' }).element()).toHaveClass('h-10');
      expect(screen.getByRole('button', { name: 'Italic' }).element()).toHaveClass('h-10');
    });

    it('disables every toggle at once', async () => {
      const screen = await render(
        <ToggleGroup disabled>
          <Marks />
        </ToggleGroup>
      );

      await expect.element(screen.getByRole('button', { name: 'Bold' })).toBeDisabled();
      await expect.element(screen.getByRole('button', { name: 'Italic' })).toBeDisabled();
    });
  });
});
