import { describe, expect, it, vi } from 'vitest';
import { renderToString } from 'react-dom/server';
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

  describe('its clock', () => {
    /** Streams for `millis` on a fake clock, then stops. */
    async function thinkFor(millis: number) {
      vi.useFakeTimers();

      try {
        const screen = await render(<Reasoning streaming>Weighing two options.</Reasoning>);

        await vi.advanceTimersByTimeAsync(millis);
        await screen.rerender(<Reasoning>Weighing two options.</Reasoning>);

        return screen.getByRole('button').element().textContent;
      } finally {
        vi.useRealTimers();
      }
    }

    // The clock ticks once a second, and the total was whichever tick came
    // last: 4.9 seconds read "4s".
    it('reports the time it took rather than the last whole second', async () => {
      expect(await thinkFor(4900)).toBe('Thought for 4.9s');
    });

    // And a run shorter than the first tick said nothing at all.
    it('reports a run under a second', async () => {
      expect(await thinkFor(900)).toBe('Thought for 900ms');
    });
  });

  describe('the panel', () => {
    /** Where the thinking is drawn, open or not: a closed panel keeps it, hidden. */
    function hiddenAround(screen: Awaited<ReturnType<typeof render>>) {
      return screen.getByText('Weighing two options.').element().closest('[hidden]');
    }

    it('is closed before any stream has run', async () => {
      const screen = await render(<Reasoning>Weighing two options.</Reasoning>);

      await expect.element(screen.getByRole('button')).toHaveAttribute('aria-expanded', 'false');
      expect(hiddenAround(screen)).not.toBeNull();
    });

    // In the markup, and so in a server render and a crawler's index, but
    // hidden until the browser's page search finds something in it.
    it('keeps a closed panel in the document, hidden until it is found', async () => {
      const screen = await render(<Reasoning>Weighing two options.</Reasoning>);

      expect(hiddenAround(screen)).toHaveAttribute('hidden', 'until-found');
      expect(renderToString(<Reasoning>Weighing two options.</Reasoning>)).toContain(
        'Weighing two options.'
      );
    });

    it('leaves a closed panel out of the document when it is not to be found', async () => {
      const screen = await render(
        <Reasoning hiddenUntilFound={false}>Weighing two options.</Reasoning>
      );

      await expect.element(screen.getByRole('button')).toHaveAttribute('aria-expanded', 'false');
      expect(screen.getByText('Weighing two options.').query()).toBeNull();
      expect(
        renderToString(<Reasoning hiddenUntilFound={false}>Weighing two options.</Reasoning>)
      ).not.toContain('Weighing two options.');
    });

    it('opens when the stream starts', async () => {
      const screen = await render(<Reasoning>Weighing two options.</Reasoning>);

      await screen.rerender(<Reasoning streaming>Weighing two options.</Reasoning>);

      await expect.element(screen.getByRole('button')).toHaveAttribute('aria-expanded', 'true');
      await expect.element(screen.getByText('Weighing two options.')).toBeVisible();
      expect(hiddenAround(screen)).toBeNull();
    });

    it('shows what the stream adds while it is open', async () => {
      const screen = await render(<Reasoning streaming>Weighing</Reasoning>);

      await screen.rerender(<Reasoning streaming>Weighing two options.</Reasoning>);

      await expect.element(screen.getByText('Weighing two options.')).toBeVisible();
    });

    it('folds itself away when the stream ends', async () => {
      const screen = await render(<Reasoning streaming>Weighing two options.</Reasoning>);

      await expect.element(screen.getByText('Weighing two options.')).toBeVisible();

      await screen.rerender(<Reasoning duration={900}>Weighing two options.</Reasoning>);

      await expect.element(screen.getByRole('button')).toHaveAttribute('aria-expanded', 'false');
      await expect.poll(() => hiddenAround(screen)).not.toBeNull();
    });

    // A panel that folds itself away moves the answer under it up the page with
    // nobody having pressed anything.
    it('stays open after the stream ends when autoClose is off', async () => {
      const screen = await render(
        <Reasoning streaming autoClose={false}>
          Weighing two options.
        </Reasoning>
      );

      await expect.element(screen.getByRole('button')).toHaveAttribute('aria-expanded', 'true');

      await screen.rerender(
        <Reasoning duration={900} autoClose={false}>
          Weighing two options.
        </Reasoning>
      );

      await expect
        .element(screen.getByRole('button', { name: 'Thought for 900ms' }))
        .toHaveAttribute('aria-expanded', 'true');
      await expect.element(screen.getByText('Weighing two options.')).toBeVisible();
    });

    it('still opens when the stream starts with autoClose off', async () => {
      const screen = await render(<Reasoning autoClose={false}>Weighing two options.</Reasoning>);

      await screen.rerender(
        <Reasoning streaming autoClose={false}>
          Weighing two options.
        </Reasoning>
      );

      await expect.element(screen.getByRole('button')).toHaveAttribute('aria-expanded', 'true');
    });

    it('closes when the reader presses it after the stream with autoClose off', async () => {
      const screen = await render(
        <Reasoning streaming autoClose={false}>
          Weighing two options.
        </Reasoning>
      );

      await screen.rerender(<Reasoning autoClose={false}>Weighing two options.</Reasoning>);
      await screen.getByRole('button').click();

      await expect.element(screen.getByRole('button')).toHaveAttribute('aria-expanded', 'false');
    });

    it('stays where the reader put it when autoOpen is off', async () => {
      const screen = await render(<Reasoning autoOpen={false}>Weighing two options.</Reasoning>);

      await screen.rerender(
        <Reasoning autoOpen={false} streaming>
          Weighing two options.
        </Reasoning>
      );

      await expect.element(screen.getByRole('button')).toHaveAttribute('aria-expanded', 'false');
      expect(hiddenAround(screen)).not.toBeNull();
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

      await expect.element(screen.getByRole('button')).toHaveAttribute('aria-expanded', 'false');
      expect(hiddenAround(screen)).not.toBeNull();
      expect(onOpenChange).not.toHaveBeenCalled();
    });

    // The stream moves an uncontrolled panel on its own, and that is not a
    // change the caller has to be told about.
    it('does not report a panel the stream opened and closed', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <Reasoning onOpenChange={onOpenChange}>Weighing two options.</Reasoning>
      );

      await screen.rerender(
        <Reasoning onOpenChange={onOpenChange} streaming>
          Weighing two options.
        </Reasoning>
      );
      await expect.element(screen.getByRole('button')).toHaveAttribute('aria-expanded', 'true');

      await screen.rerender(
        <Reasoning onOpenChange={onOpenChange}>Weighing two options.</Reasoning>
      );
      await expect.element(screen.getByRole('button')).toHaveAttribute('aria-expanded', 'false');

      expect(onOpenChange).not.toHaveBeenCalled();
    });

    it('answers a press whichever way the stream left it', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <Reasoning onOpenChange={onOpenChange}>Weighing two options.</Reasoning>
      );

      await screen.getByRole('button').click();

      expect(onOpenChange).toHaveBeenCalledWith(true);
      await expect.element(screen.getByRole('button')).toHaveAttribute('aria-expanded', 'true');
      await expect.element(screen.getByText('Weighing two options.')).toBeVisible();
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
