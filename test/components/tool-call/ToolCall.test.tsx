import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { NebaProvider, ToolCall } from 'neba';

describe('ToolCall', () => {
  describe('rendering', () => {
    it('draws the name it was given', async () => {
      const screen = await render(<ToolCall name="search_docs" />);

      await expect.element(screen.getByText('search_docs')).toBeInTheDocument();
    });

    it('says the status in words as well as in a shape', async () => {
      const screen = await render(<ToolCall name="search_docs" status="running" />);

      await expect.element(screen.getByText('Running')).toBeInTheDocument();
    });

    it('marks the root with its status', async () => {
      const screen = await render(<ToolCall name="search_docs" status="success" result="4 hits" />);

      await expect
        .element(screen.getByRole('button', { name: 'search_docs', exact: false }))
        .toBeInTheDocument();
      expect(document.querySelector('[data-status="success"]')).not.toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<ToolCall name="run" className="my-own-class" />);

      expect(screen.getByText('run').element().closest('.my-own-class')).not.toBeNull();
    });

    it('follows a status that changes on re-render', async () => {
      const screen = await render(<ToolCall name="run" status="pending" />);

      await screen.rerender(<ToolCall name="run" status="success" />);

      await expect.element(screen.getByText('Finished')).toBeInTheDocument();
    });
  });

  describe('the panel', () => {
    it('is not a disclosure at all when there is nothing to disclose', async () => {
      const screen = await render(<ToolCall name="ping" status="success" />);

      expect(screen.getByRole('button').query()).toBeNull();
    });

    it('stays closed until the header is pressed', async () => {
      const screen = await render(
        <ToolCall name="search_docs" status="success" args="{ q: 'acrylic' }" result="4 hits" />
      );

      expect(screen.getByText('4 hits').query()).toBeNull();

      await screen.getByRole('button', { name: 'search_docs', exact: false }).click();

      await expect.element(screen.getByText('4 hits')).toBeInTheDocument();
      await expect.element(screen.getByText("{ q: 'acrylic' }")).toBeInTheDocument();
    });

    it('shows the error in place of the result when the call failed', async () => {
      const screen = await render(
        <ToolCall
          name="search_docs"
          status="error"
          result="4 hits"
          error="Rate limit exceeded"
          defaultOpen
        />
      );

      await expect.element(screen.getByText('Rate limit exceeded')).toBeInTheDocument();
      expect(screen.getByText('4 hits').query()).toBeNull();
    });

    // A reader should not have to go looking for the reason something did not
    // work, which is the one case the component decides for itself.
    it('opens itself when a running call fails', async () => {
      const screen = await render(
        <ToolCall name="deploy" status="running" args="{ env: 'prod' }" />
      );

      expect(screen.getByText("{ env: 'prod' }").query()).toBeNull();

      await screen.rerender(
        <ToolCall name="deploy" status="error" args="{ env: 'prod' }" error="No such environment" />
      );

      await expect.element(screen.getByText('No such environment')).toBeInTheDocument();
    });

    it('leaves a controlled ToolCall where its caller put it', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <ToolCall
          name="deploy"
          status="running"
          args="{ env: 'prod' }"
          open={false}
          onOpenChange={onOpenChange}
        />
      );

      await screen.rerender(
        <ToolCall
          name="deploy"
          status="error"
          args="{ env: 'prod' }"
          error="No such environment"
          open={false}
          onOpenChange={onOpenChange}
        />
      );

      expect(screen.getByText('No such environment').query()).toBeNull();
      expect(onOpenChange).not.toHaveBeenCalled();
    });

    it('reports a press to its caller', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <ToolCall name="deploy" result="done" onOpenChange={onOpenChange} />
      );

      await screen.getByRole('button', { name: 'deploy', exact: false }).click();

      expect(onOpenChange).toHaveBeenCalledWith(true);
    });
  });

  describe('duration', () => {
    it('writes a sub-second call in milliseconds', async () => {
      const screen = await render(<ToolCall name="ping" status="success" duration={340} />);

      await expect.element(screen.getByText('340ms')).toBeInTheDocument();
    });

    it('writes a longer one in seconds, to one decimal place', async () => {
      const screen = await render(<ToolCall name="build" status="success" duration={4200} />);

      await expect.element(screen.getByText('4.2s')).toBeInTheDocument();
    });

    it('drops the decimal place past ten seconds', async () => {
      const screen = await render(<ToolCall name="build" status="success" duration={247_300} />);

      await expect.element(screen.getByText('247s')).toBeInTheDocument();
    });

    it('says nothing at all when it has not been told one', async () => {
      const screen = await render(<ToolCall name="ping" status="success" />);

      expect(screen.getByText('340ms').query()).toBeNull();
    });
  });

  describe('locale', () => {
    it('says the status in the language it was given', async () => {
      const screen = await render(
        <ToolCall name="ping" status="running" labels={{ running: 'En cours' }} />
      );

      await expect.element(screen.getByText('En cours')).toBeInTheDocument();
    });

    it('takes the locale from a provider', async () => {
      const screen = await render(
        <NebaProvider defaults={{ locale: 'de-DE' }}>
          <ToolCall name="build" status="success" duration={4200} />
        </NebaProvider>
      );

      await expect.element(screen.getByText('4,2 Sek.')).toBeInTheDocument();
    });
  });
});
