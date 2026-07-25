import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button, ButtonGroup } from 'neba';

describe('ButtonGroup', () => {
  describe('rendering', () => {
    it('renders a group around its buttons', async () => {
      const screen = await render(
        <ButtonGroup>
          <Button>One</Button>
          <Button>Two</Button>
        </ButtonGroup>
      );

      await expect.element(screen.getByRole('group')).toBeInTheDocument();
      expect(screen.getByRole('group').element().children).toHaveLength(2);
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <ButtonGroup className="my-own-class">
          <Button>One</Button>
        </ButtonGroup>
      );

      expect(screen.getByRole('group').element()).toHaveClass('my-own-class');
    });

    it('squares off the corners that face a neighbour', async () => {
      const screen = await render(
        <ButtonGroup>
          <Button>One</Button>
        </ButtonGroup>
      );
      const element = screen.getByRole('group').element();

      expect(element).toHaveClass('[&>*:not(:first-child)]:rounded-s-none');
      expect(element).toHaveClass('[&>*:not(:last-child)]:rounded-e-none');
    });

    it('flattens the other pair of corners when vertical', async () => {
      const screen = await render(
        <ButtonGroup orientation="vertical">
          <Button>One</Button>
        </ButtonGroup>
      );
      const element = screen.getByRole('group').element();

      expect(element).toHaveClass('flex-col');
      expect(element).toHaveClass('[&>*:not(:first-child)]:rounded-t-none');
      expect(element).not.toHaveClass('[&>*:not(:first-child)]:rounded-s-none');
    });

    it('collapses the shared hairline for outline groups only', async () => {
      const screen = await render(
        <ButtonGroup variant="outline">
          <Button>One</Button>
        </ButtonGroup>
      );

      expect(screen.getByRole('group').element()).toHaveClass('[&>*:not(:first-child)]:-ms-px');

      await screen.rerender(
        <ButtonGroup variant="solid">
          <Button>One</Button>
        </ButtonGroup>
      );

      expect(screen.getByRole('group').element()).not.toHaveClass('[&>*:not(:first-child)]:-ms-px');
    });

    it('divides the width evenly when full width', async () => {
      const screen = await render(
        <ButtonGroup fullWidth>
          <Button>One</Button>
        </ButtonGroup>
      );
      const element = screen.getByRole('group').element();

      expect(element).toHaveClass('w-full');
      expect(element).toHaveClass('[&>*]:flex-1');
    });
  });

  describe('shared props', () => {
    it('sets size, colour and density for every button in the set', async () => {
      const screen = await render(
        <ButtonGroup size="lg" color="danger" density="compact">
          <Button>One</Button>
          <Button>Two</Button>
        </ButtonGroup>
      );

      for (const name of ['One', 'Two']) {
        const element = screen.getByRole('button', { name }).element() as HTMLElement;

        expect(element).toHaveClass('h-10');
        expect(element).toHaveClass('px-3');
        expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-danger-fill)');
      }
    });

    it('sets the variant for every button in the set', async () => {
      const screen = await render(
        <ButtonGroup variant="outline">
          <Button>One</Button>
        </ButtonGroup>
      );

      expect(screen.getByRole('button', { name: 'One' }).element()).toHaveClass('border');
    });

    it('lets a button override the group', async () => {
      const screen = await render(
        <ButtonGroup color="secondary">
          <Button>Keep</Button>
          <Button color="danger">Delete</Button>
        </ButtonGroup>
      );
      const keep = screen.getByRole('button', { name: 'Keep' }).element() as HTMLElement;
      const remove = screen.getByRole('button', { name: 'Delete' }).element() as HTMLElement;

      expect(keep.style.getPropertyValue('--n-fill')).toBe('var(--neba-secondary-fill)');
      expect(remove.style.getPropertyValue('--n-fill')).toBe('var(--neba-danger-fill)');
    });

    it('disables the whole set at once', async () => {
      const screen = await render(
        <ButtonGroup disabled>
          <Button>One</Button>
          <Button>Two</Button>
        </ButtonGroup>
      );

      expect(screen.getByRole('button', { name: 'One' }).element()).toBeDisabled();
      expect(screen.getByRole('button', { name: 'Two' }).element()).toBeDisabled();
    });

    it('reaches a button that is not a direct child', async () => {
      const screen = await render(
        <ButtonGroup size="xl">
          <span>
            <Button>Wrapped</Button>
          </span>
        </ButtonGroup>
      );

      expect(screen.getByRole('button', { name: 'Wrapped' }).element()).toHaveClass('h-12');
    });

    it('leaves a button entirely alone when the group specifies nothing', async () => {
      const screen = await render(
        <ButtonGroup>
          <Button>One</Button>
        </ButtonGroup>
      );
      const element = screen.getByRole('button', { name: 'One' }).element() as HTMLElement;

      expect(element).toHaveClass('h-8');
      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-primary-fill)');
      expect(element).not.toHaveClass('border');
    });

    it('reflects a changed group prop on re-render', async () => {
      const screen = await render(
        <ButtonGroup size="sm">
          <Button>One</Button>
        </ButtonGroup>
      );

      expect(screen.getByRole('button', { name: 'One' }).element()).toHaveClass('h-6.5');

      await screen.rerender(
        <ButtonGroup size="lg">
          <Button>One</Button>
        </ButtonGroup>
      );

      expect(screen.getByRole('button', { name: 'One' }).element()).toHaveClass('h-10');
    });
  });
});
