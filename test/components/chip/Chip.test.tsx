import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Chip } from 'neba';

describe('Chip', () => {
  describe('rendering', () => {
    it('renders its label', async () => {
      const screen = await render(<Chip>Draft</Chip>);

      await expect.element(screen.getByText('Draft')).toBeInTheDocument();
    });

    it('is an inert span until it is given something to do', async () => {
      const screen = await render(<Chip data-testid="chip">Draft</Chip>);

      expect(screen.getByTestId('chip').element().tagName).toBe('SPAN');
      expect(screen.getByRole('button').query()).toBeNull();
    });

    it('becomes a real button when it can be clicked', async () => {
      const screen = await render(<Chip onClick={() => {}}>Draft</Chip>);
      const element = screen.getByRole('button', { name: 'Draft' }).element();

      expect(element.tagName).toBe('BUTTON');
      expect(element).toHaveAttribute('type', 'button');
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(<Chip>Before</Chip>);

      await screen.rerender(<Chip>After</Chip>);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <Chip className="my-own-class" data-testid="chip">
          Draft
        </Chip>
      );

      expect(screen.getByTestId('chip').element()).toHaveClass('my-own-class');
    });
  });

  describe('count', () => {
    it('renders a count beside the label', async () => {
      const screen = await render(<Chip count={12}>Errors</Chip>);

      await expect.element(screen.getByText('12')).toBeInTheDocument();
    });

    it('renders a count of zero rather than dropping it', async () => {
      const screen = await render(<Chip count={0}>Errors</Chip>);

      await expect.element(screen.getByText('0')).toBeInTheDocument();
    });

    it('leaves the count out when there is none', async () => {
      const screen = await render(<Chip data-testid="chip">Errors</Chip>);

      expect(screen.getByTestId('chip').element().children).toHaveLength(1);
    });
  });

  describe('delete', () => {
    it('shows the delete button only when onDelete is given', async () => {
      const screen = await render(<Chip>Draft</Chip>);

      expect(screen.getByRole('button', { name: 'Remove' }).query()).toBeNull();

      await screen.rerender(<Chip onDelete={() => {}}>Draft</Chip>);

      await expect.element(screen.getByRole('button', { name: 'Remove' })).toBeInTheDocument();
    });

    it('calls onDelete when pressed', async () => {
      const onDelete = vi.fn();
      const screen = await render(<Chip onDelete={onDelete}>Draft</Chip>);

      await screen.getByRole('button', { name: 'Remove' }).click();

      expect(onDelete).toHaveBeenCalledTimes(1);
    });

    it('does not also fire the chip when the chip is clickable', async () => {
      const onClick = vi.fn();
      const onDelete = vi.fn();
      const screen = await render(
        <Chip onClick={onClick} onDelete={onDelete}>
          Draft
        </Chip>
      );

      await screen.getByRole('button', { name: 'Remove' }).click();

      expect(onDelete).toHaveBeenCalledTimes(1);
      expect(onClick).not.toHaveBeenCalled();
    });

    it('takes a custom accessible name for the delete button', async () => {
      const screen = await render(
        <Chip onDelete={() => {}} deleteLabel="Remove tag">
          Draft
        </Chip>
      );

      await expect.element(screen.getByRole('button', { name: 'Remove tag' })).toBeInTheDocument();
    });
  });

  describe('state', () => {
    it('marks a selected chip as pressed', async () => {
      const screen = await render(
        <Chip selected onClick={() => {}}>
          Draft
        </Chip>
      );

      expect(screen.getByRole('button', { name: 'Draft' }).element()).toHaveAttribute(
        'aria-pressed',
        'true'
      );
    });

    it('deepens the surface when selected without changing the colour family', async () => {
      const screen = await render(
        <Chip data-testid="chip" color="success">
          Draft
        </Chip>
      );
      const element = screen.getByTestId('chip').element() as HTMLElement;

      expect(element).not.toHaveClass('bg-(--n-panel-press)');

      await screen.rerender(
        <Chip data-testid="chip" color="success" selected>
          Draft
        </Chip>
      );

      expect(element).toHaveClass('bg-(--n-panel-press)');
      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-success-accent)');
    });

    it('drops the colour family when disabled', async () => {
      const screen = await render(
        <Chip disabled data-testid="chip">
          Draft
        </Chip>
      );

      expect(screen.getByTestId('chip').element()).toHaveClass('text-(--neba-disabled-fg)');
    });

    it('stays a span when disabled even with a click handler', async () => {
      const screen = await render(
        <Chip disabled onClick={() => {}} data-testid="chip">
          Draft
        </Chip>
      );

      expect(screen.getByTestId('chip').element().tagName).toBe('SPAN');
    });
  });

  describe('style props', () => {
    it('maps colour and elevation onto the token slots', async () => {
      const screen = await render(
        <Chip color="warning" elevation={2} data-testid="chip">
          Draft
        </Chip>
      );
      const element = screen.getByTestId('chip').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-warning-fill)');
      expect(element.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-2)');
    });

    it('sits one step down the control ladder from a Button of the same size', async () => {
      const screen = await render(<Chip data-testid="chip">Draft</Chip>);

      expect(screen.getByTestId('chip').element()).toHaveClass('h-6.5');
    });

    // The shell once used `items-stretch` so the pressable label could fill the
    // chip's height, which knocked the icon, the count plate and the × off the
    // centre line. The label asks for the height itself instead.
    it('centres every part of the chip on one line', async () => {
      const screen = await render(
        <Chip data-testid="chip" count={3} onDelete={() => {}}>
          Draft
        </Chip>
      );

      expect(screen.getByTestId('chip').element()).toHaveClass('items-center');
    });

    it('stretches the pressable label to the full height of the chip', async () => {
      const screen = await render(
        <Chip data-testid="chip" onClick={() => {}}>
          Draft
        </Chip>
      );
      const shell = screen.getByTestId('chip').element();
      const label = screen.getByRole('button', { name: 'Draft' }).element();

      expect(shell).toHaveClass('items-center');
      expect(label).toHaveClass('self-stretch');
    });

    it('changes padding with density but not height', async () => {
      const screen = await render(
        <Chip data-testid="chip" density="compact">
          Draft
        </Chip>
      );
      const element = screen.getByTestId('chip').element();

      expect(element).toHaveClass('h-6.5');
      expect(element).toHaveClass('px-2');
    });

    it('is an outline chip by default', async () => {
      const screen = await render(<Chip data-testid="chip">Draft</Chip>);

      expect(screen.getByTestId('chip').element()).toHaveClass('border');
    });

    it('never applies a transform', async () => {
      const screen = await render(
        <Chip data-testid="chip" onClick={() => {}} count={3} onDelete={() => {}}>
          Draft
        </Chip>
      );
      const element = screen.getByTestId('chip').element();

      expect(element.outerHTML).not.toContain('scale');
      expect(element.outerHTML).not.toContain('translate');
    });
  });

  describe('transition', () => {
    it('takes an entrance animation', async () => {
      const screen = await render(
        <Chip transition="zoom" data-testid="chip">
          Draft
        </Chip>
      );
      const element = screen.getByTestId('chip').element() as HTMLElement;

      expect(element).toHaveClass('neba-anim-scale');
      expect(element.style.getPropertyValue('--n-anim-scale')).toBe('0.4');
    });
  });
});
