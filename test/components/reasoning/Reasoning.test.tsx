import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Reasoning } from 'neba';

describe('Reasoning', () => {
  describe('the header', () => {
    it('says it is thinking while the stream runs', async () => {
      const screen = await render(<Reasoning streaming>Weighing two options.</Reasoning>);

      await expect.element(screen.getByRole('button', { name: 'Thinking…' })).toBeInTheDocument();
    });

    it('reports how long it took once the stream has stopped', async () => {
      const screen = await render(<Reasoning duration={4200}>Weighing two options.</Reasoning>);

      await expect
        .element(screen.getByRole('button', { name: 'Thought for 4.2s' }))
        .toBeInTheDocument();
    });

    it('says so in words when nothing timed it', async () => {
      const screen = await render(<Reasoning>Weighing two options.</Reasoning>);

      await expect
        .element(screen.getByRole('button', { name: 'Finished thinking' }))
        .toBeInTheDocument();
    });

    it('takes a label of its own over any of them', async () => {
      const screen = await render(
        <Reasoning streaming label="Planning the change">
          Weighing two options.
        </Reasoning>
      );

      await expect
        .element(screen.getByRole('button', { name: 'Planning the change' }))
        .toBeInTheDocument();
    });

    it('marks itself busy while the stream runs', async () => {
      await render(<Reasoning streaming>Thinking.</Reasoning>);

      expect(document.querySelector('[data-streaming][aria-busy="true"]')).not.toBeNull();
    });
  });

  describe('the panel', () => {
    it('is closed before any stream has run', async () => {
      const screen = await render(<Reasoning>Weighing two options.</Reasoning>);

      expect(screen.getByText('Weighing two options.').query()).toBeNull();
    });

    it('opens when the stream starts', async () => {
      const screen = await render(<Reasoning>Weighing two options.</Reasoning>);

      await screen.rerender(<Reasoning streaming>Weighing two options.</Reasoning>);

      await expect.element(screen.getByText('Weighing two options.')).toBeInTheDocument();
    });

    it('folds itself away when the stream ends', async () => {
      const screen = await render(<Reasoning streaming>Weighing two options.</Reasoning>);

      await expect.element(screen.getByText('Weighing two options.')).toBeInTheDocument();

      await screen.rerender(<Reasoning duration={900}>Weighing two options.</Reasoning>);

      await expect.element(screen.getByText('Weighing two options.')).not.toBeInTheDocument();
    });

    it('stays where the reader put it when autoOpen is off', async () => {
      const screen = await render(<Reasoning autoOpen={false}>Weighing two options.</Reasoning>);

      await screen.rerender(
        <Reasoning autoOpen={false} streaming>
          Weighing two options.
        </Reasoning>
      );

      expect(screen.getByText('Weighing two options.').query()).toBeNull();
    });

    it('leaves a controlled Reasoning where its caller put it', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <Reasoning open={false} onOpenChange={onOpenChange}>
          Weighing two options.
        </Reasoning>
      );

      await screen.rerender(
        <Reasoning open={false} onOpenChange={onOpenChange} streaming>
          Weighing two options.
        </Reasoning>
      );

      expect(screen.getByText('Weighing two options.').query()).toBeNull();
      expect(onOpenChange).not.toHaveBeenCalled();
    });

    it('answers a press whichever way the stream left it', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <Reasoning onOpenChange={onOpenChange}>Weighing two options.</Reasoning>
      );

      await screen.getByRole('button').click();

      expect(onOpenChange).toHaveBeenCalledWith(true);
      await expect.element(screen.getByText('Weighing two options.')).toBeInTheDocument();
    });
  });

  describe('rendering', () => {
    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Reasoning className="my-own-class">Thinking.</Reasoning>);

      expect(screen.getByRole('button').element().closest('.my-own-class')).not.toBeNull();
    });

    it('lets a caller write its sentences out', async () => {
      const screen = await render(
        <Reasoning streaming labels={{ thinking: 'Réflexion…' }}>
          Thinking.
        </Reasoning>
      );

      await expect.element(screen.getByRole('button', { name: 'Réflexion…' })).toBeInTheDocument();
    });
  });
});
