import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
import { FloatingAction, FloatingActionButton } from 'neba';

describe('FloatingActionButton', () => {
  describe('rendering', () => {
    it('renders a button named by its label', async () => {
      const screen = await render(<FloatingActionButton label="Compose" />);

      await expect.element(screen.getByRole('button', { name: 'Compose' })).toBeInTheDocument();
    });

    it('draws a plus when it is given no glyph', async () => {
      const screen = await render(<FloatingActionButton label="Compose" data-testid="fab" />);

      expect(screen.getByTestId('fab').element().querySelectorAll('svg')).toHaveLength(1);
    });

    it('writes the label on the button when it is extended', async () => {
      const screen = await render(<FloatingActionButton label="Compose" extended />);

      await expect.element(screen.getByText('Compose')).toBeInTheDocument();
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(<FloatingActionButton label="Before" />);

      await screen.rerender(<FloatingActionButton label="After" />);

      await expect.element(screen.getByRole('button', { name: 'After' })).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <FloatingActionButton label="Compose" className="my-own-class" data-testid="fab" />
      );

      expect(screen.getByTestId('fab').element()).toHaveClass('my-own-class');
    });

    it('forwards unknown props to the root', async () => {
      const screen = await render(
        <FloatingActionButton label="Compose" data-testid="fab" id="compose" />
      );

      expect(screen.getByTestId('fab').element()).toHaveAttribute('id', 'compose');
    });

    it('writes the offset into the slot the corner is placed off', async () => {
      const screen = await render(
        <FloatingActionButton label="Compose" offset={24} data-testid="fab" />
      );

      expect(screen.getByTestId('fab').element().style.getPropertyValue('--n-fab-offset')).toBe(
        '24px'
      );
    });
  });

  describe('on its own', () => {
    it('fires its handler when it is pressed', async () => {
      const onClick = vi.fn();
      const screen = await render(<FloatingActionButton label="Compose" onClick={onClick} />);

      await screen.getByRole('button', { name: 'Compose' }).click();

      expect(onClick).toHaveBeenCalledTimes(1);
    });

    it('says nothing about a dial it does not have', async () => {
      const screen = await render(<FloatingActionButton label="Compose" />);

      expect(
        screen.getByRole('button', { name: 'Compose' }).element().getAttribute('aria-expanded')
      ).toBeNull();
    });

    it('stops answering when it is disabled', async () => {
      const screen = await render(<FloatingActionButton label="Compose" disabled />);

      await expect.element(screen.getByRole('button', { name: 'Compose' })).toBeDisabled();
    });
  });

  describe('the dial', () => {
    const dial = (props: Record<string, unknown> = {}) => (
      <FloatingActionButton label="Share" openOnHover={false} {...props}>
        <FloatingAction label="Copy link" />
        <FloatingAction label="Email" />
      </FloatingActionButton>
    );

    it('starts closed and says so', async () => {
      const screen = await render(dial());

      await expect
        .element(screen.getByRole('button', { name: 'Share' }))
        .toHaveAttribute('aria-expanded', 'false');
      expect(screen.getByRole('button', { name: 'Copy link' }).query()).toBeNull();
    });

    it('opens when the button is pressed', async () => {
      const screen = await render(dial());

      await screen.getByRole('button', { name: 'Share' }).click();

      await expect.element(screen.getByRole('button', { name: 'Copy link' })).toBeInTheDocument();
      await expect
        .element(screen.getByRole('button', { name: 'Share' }))
        .toHaveAttribute('aria-expanded', 'true');
    });

    it('reports the new state', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(dial({ onOpenChange }));

      await screen.getByRole('button', { name: 'Share' }).click();

      expect(onOpenChange).toHaveBeenCalledWith(true);
    });

    it('leaves a controlled dial where it was put', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(dial({ open: false, onOpenChange }));

      await screen.getByRole('button', { name: 'Share' }).click();

      expect(onOpenChange).toHaveBeenCalledWith(true);
      expect(screen.getByRole('button', { name: 'Copy link' }).query()).toBeNull();
    });

    it('points at the dial it opened', async () => {
      const screen = await render(dial({ defaultOpen: true }));

      const controls = screen
        .getByRole('button', { name: 'Share' })
        .element()
        .getAttribute('aria-controls');

      expect(controls).not.toBeNull();
      expect(document.getElementById(controls as string)).not.toBeNull();
    });

    /**
     * The dial arrived in one frame, which on a corner of the screen reads as
     * something having gone wrong rather than as something having opened.
     * Opacity and nothing else — these are buttons with words beside them.
     */
    it('fades in rather than switching on', async () => {
      const screen = await render(dial({ defaultOpen: true }));

      const controls = screen
        .getByRole('button', { name: 'Share' })
        .element()
        .getAttribute('aria-controls') as string;
      const panel = document.getElementById(controls) as HTMLElement;

      expect(panel.className).toContain('animation:neba-anim-fade');
      expect(panel.className).not.toContain('translate');
    });

    it('fires an action and puts the dial away', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <FloatingActionButton label="Share" openOnHover={false} defaultOpen>
          <FloatingAction label="Copy link" onClick={onClick} />
        </FloatingActionButton>
      );

      await screen.getByRole('button', { name: 'Copy link' }).click();

      expect(onClick).toHaveBeenCalledTimes(1);
      expect(screen.getByRole('button', { name: 'Copy link' }).query()).toBeNull();
    });

    it('keeps the dial up when it was told to', async () => {
      const screen = await render(
        <FloatingActionButton label="Share" openOnHover={false} closeOnAction={false} defaultOpen>
          <FloatingAction label="Copy link" />
        </FloatingActionButton>
      );

      await screen.getByRole('button', { name: 'Copy link' }).click();

      await expect.element(screen.getByRole('button', { name: 'Copy link' })).toBeInTheDocument();
    });

    it('draws each action’s name beside it, and stops when asked', async () => {
      const screen = await render(dial({ defaultOpen: true }));

      await expect.element(screen.getByText('Copy link')).toBeInTheDocument();

      await screen.rerender(
        <FloatingActionButton label="Share" openOnHover={false} defaultOpen showLabels={false}>
          <FloatingAction label="Copy link" />
        </FloatingActionButton>
      );

      expect(screen.getByText('Copy link').query()).toBeNull();
      // The name is still on the button, which is where it always mattered.
      await expect.element(screen.getByRole('button', { name: 'Copy link' })).toBeInTheDocument();
    });

    it('will not open a dial it has no actions for', async () => {
      const screen = await render(
        <FloatingActionButton label="Share" defaultOpen>
          {false}
        </FloatingActionButton>
      );

      expect(
        screen.getByRole('button', { name: 'Share' }).element().getAttribute('aria-expanded')
      ).toBeNull();
    });

    it('closes on Escape and hands the focus back', async () => {
      const screen = await render(dial());
      const trigger = screen.getByRole('button', { name: 'Share' });

      await trigger.click();
      await expect.element(screen.getByRole('button', { name: 'Copy link' })).toBeInTheDocument();
      // Before pressing a key, wait for the thing being typed at to hold the
      // focus — a key pressed in between lands wherever the focus still was.
      await expect.element(trigger).toHaveFocus();

      await userEvent.keyboard('{Escape}');

      expect(screen.getByRole('button', { name: 'Copy link' }).query()).toBeNull();
      await expect.element(trigger).toHaveFocus();
    });
  });
});
