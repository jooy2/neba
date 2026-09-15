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

    // The title was always cut to one line, so a title that is a question lost
    // its end on a narrow screen. It wraps unless `lines` says otherwise.
    it('wraps the title and the subtitle unless lines cuts them', async () => {
      const screen = await render(<Collapsible title="Advanced" subtitle="Rarely needed" />);

      expect(screen.getByText('Advanced').element()).not.toHaveClass('truncate');
      expect(screen.getByText('Rarely needed').element()).not.toHaveClass('truncate');

      await screen.rerender(<Collapsible title="Advanced" subtitle="Rarely needed" lines={1} />);

      expect(screen.getByText('Advanced').element()).toHaveClass('truncate');
    });

    it('starts closed', async () => {
      const screen = await render(<Collapsible title="Advanced">Everything else.</Collapsible>);

      await expect
        .element(screen.getByRole('button', { name: 'Advanced' }))
        .toHaveAttribute('aria-expanded', 'false');
      await expect.element(screen.getByText('Everything else.')).not.toBeVisible();
    });

    // In the markup, and so in a server render and a crawler's index, but
    // hidden until the browser's page search finds something in it.
    it('keeps a closed panel in the document, hidden until it is found', async () => {
      const screen = await render(<Collapsible title="Advanced">Everything else.</Collapsible>);
      const body = screen.getByText('Everything else.').element();

      expect(body.closest('[hidden]')).toHaveAttribute('hidden', 'until-found');
    });

    it('leaves a closed panel out of the document when it is not to be found', async () => {
      const screen = await render(
        <Collapsible title="Advanced" hiddenUntilFound={false}>
          Everything else.
        </Collapsible>
      );

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
      // And looks it: the trigger stays focusable, so no `disabled:` class matched.
      expect(screen.getByRole('button', { name: 'Advanced' }).element()).toHaveClass(
        'text-(--neba-disabled-fg)'
      );
      expect(screen.getByRole('button', { name: 'Advanced' }).element()).not.toHaveClass(
        'hover:bg-(--n-soft)'
      );
    });

    it('keeps a closed panel in the document when it is asked to', async () => {
      const screen = await render(
        <Collapsible title="Advanced" hiddenUntilFound={false} keepMounted>
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
