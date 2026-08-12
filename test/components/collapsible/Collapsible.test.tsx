import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button, Collapsible, Switch } from 'neba';

describe('Collapsible', () => {
  describe('rendering', () => {
    it('renders a trigger carrying the title', async () => {
      const screen = await render(<Collapsible title="Advanced">Everything else.</Collapsible>);

      await expect.element(screen.getByRole('button', { name: 'Advanced' })).toBeInTheDocument();
    });

    it('renders a subtitle under the title', async () => {
      const screen = await render(<Collapsible title="Advanced" subtitle="Rarely needed" />);

      await expect.element(screen.getByText('Rarely needed')).toBeInTheDocument();
    });

    it('starts closed', async () => {
      const screen = await render(<Collapsible title="Advanced">Everything else.</Collapsible>);

      await expect
        .element(screen.getByRole('button', { name: 'Advanced' }))
        .toHaveAttribute('aria-expanded', 'false');
      expect(screen.getByText('Everything else.').query()).toBeNull();
    });

    it('shows the body when it starts open', async () => {
      const screen = await render(
        <Collapsible title="Advanced" defaultOpen>
          Everything else.
        </Collapsible>
      );

      await expect.element(screen.getByText('Everything else.')).toBeInTheDocument();
      await expect
        .element(screen.getByRole('button', { name: 'Advanced' }))
        .toHaveAttribute('aria-expanded', 'true');
    });

    it('reflects a changed title on re-render', async () => {
      const screen = await render(<Collapsible title="Before" />);

      await screen.rerender(<Collapsible title="After" />);

      await expect.element(screen.getByRole('button', { name: 'After' })).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <Collapsible title="Advanced" className="my-own-class" data-testid="collapsible" />
      );

      expect(screen.getByTestId('collapsible').element()).toHaveClass('my-own-class');
    });

    it('forwards unknown props to the root', async () => {
      const screen = await render(
        <Collapsible title="Advanced" data-testid="collapsible" id="advanced" />
      );

      expect(screen.getByTestId('collapsible').element()).toHaveAttribute('id', 'advanced');
    });
  });

  describe('folding', () => {
    it('opens when the trigger is pressed', async () => {
      const screen = await render(<Collapsible title="Advanced">Everything else.</Collapsible>);

      await screen.getByRole('button', { name: 'Advanced' }).click();

      await expect.element(screen.getByText('Everything else.')).toBeInTheDocument();
    });

    it('closes again on a second press', async () => {
      const screen = await render(
        <Collapsible title="Advanced" defaultOpen>
          Everything else.
        </Collapsible>
      );

      await screen.getByRole('button', { name: 'Advanced' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Advanced' }))
        .toHaveAttribute('aria-expanded', 'false');
    });

    it('reports the new state', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <Collapsible title="Advanced" onOpenChange={onOpenChange}>
          Everything else.
        </Collapsible>
      );

      await screen.getByRole('button', { name: 'Advanced' }).click();

      expect(onOpenChange).toHaveBeenCalledWith(true);
    });

    it('leaves a controlled Collapsible where it was put', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <Collapsible title="Advanced" open={false} onOpenChange={onOpenChange}>
          Everything else.
        </Collapsible>
      );

      await screen.getByRole('button', { name: 'Advanced' }).click();

      expect(onOpenChange).toHaveBeenCalledWith(true);
      await expect
        .element(screen.getByRole('button', { name: 'Advanced' }))
        .toHaveAttribute('aria-expanded', 'false');
    });

    it('stops answering when it is disabled', async () => {
      const screen = await render(
        <Collapsible title="Advanced" disabled>
          Everything else.
        </Collapsible>
      );

      await expect.element(screen.getByRole('button', { name: 'Advanced' })).toBeDisabled();
    });

    it('keeps a closed panel in the document when it is asked to', async () => {
      const screen = await render(
        <Collapsible title="Advanced" keepMounted>
          Everything else.
        </Collapsible>
      );

      await expect.element(screen.getByText('Everything else.')).toBeInTheDocument();
    });
  });

  describe('slots', () => {
    it('draws the chevron by default and drops it on request', async () => {
      const screen = await render(
        <Collapsible title="Advanced" data-testid="collapsible">
          Everything else.
        </Collapsible>
      );

      expect(screen.getByTestId('collapsible').element().querySelectorAll('svg')).toHaveLength(1);

      await screen.rerender(
        <Collapsible title="Advanced" indicator={false} data-testid="collapsible">
          Everything else.
        </Collapsible>
      );

      expect(screen.getByTestId('collapsible').element().querySelectorAll('svg')).toHaveLength(0);
    });

    it('keeps an action out of the trigger, so it can be pressed on its own', async () => {
      const screen = await render(
        <Collapsible title="Notifications" action={<Switch label="On" />}>
          How we reach you.
        </Collapsible>
      );

      const trigger = screen.getByRole('button', { name: 'Notifications' }).element();

      expect(trigger.querySelector('input')).toBeNull();
      await expect.element(screen.getByRole('switch')).toBeInTheDocument();
    });

    it('lets a caller replace the header with a control of their own', async () => {
      const screen = await render(
        <Collapsible variant="text" trigger={<Button>Show more</Button>}>
          Everything else.
        </Collapsible>
      );

      const trigger = screen.getByRole('button', { name: 'Show more' });

      await expect.element(trigger).toHaveAttribute('aria-expanded', 'false');
      await trigger.click();
      await expect.element(screen.getByText('Everything else.')).toBeInTheDocument();
    });
  });
});
