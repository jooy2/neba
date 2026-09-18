import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AgentStep, AgentSteps } from 'neba';

describe('AgentSteps', () => {
  describe('rendering', () => {
    it('renders a list of the steps it was given', async () => {
      const screen = await render(
        <AgentSteps>
          <AgentStep title="Read the request" />
          <AgentStep title="Search the docs" status="running" />
        </AgentSteps>
      );

      const list = screen.getByRole('list');

      await expect.element(list).toBeInTheDocument();
      await expect.element(screen.getByText('Read the request')).toBeInTheDocument();
      await expect.element(screen.getByText('Search the docs')).toBeInTheDocument();
    });

    it('says each step’s status in words', async () => {
      const screen = await render(
        <AgentSteps>
          <AgentStep title="Read the request" />
          <AgentStep title="Search the docs" status="error" />
        </AgentSteps>
      );

      await expect.element(screen.getByText('Finished')).toBeInTheDocument();
      await expect.element(screen.getByText('Failed')).toBeInTheDocument();
    });

    it('marks the step that is happening now', async () => {
      await render(
        <AgentSteps>
          <AgentStep title="Read the request" />
          <AgentStep title="Search the docs" status="running" />
        </AgentSteps>
      );

      const current = document.querySelector('[aria-current="step"]');

      expect(current?.textContent).toContain('Search the docs');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <AgentSteps className="my-own-class">
          <AgentStep title="One" className="my-step-class" />
        </AgentSteps>
      );

      expect(screen.getByRole('list').element()).toHaveClass('my-own-class');
      expect(screen.getByRole('listitem').element()).toHaveClass('my-step-class');
    });

    it('holds whatever a step did under its title', async () => {
      const screen = await render(
        <AgentSteps>
          <AgentStep title="Search the docs">query: acrylic surface</AgentStep>
        </AgentSteps>
      );

      await expect.element(screen.getByText('query: acrylic surface')).toBeInTheDocument();
    });

    it('renders on its own outside a chain', async () => {
      const screen = await render(<AgentStep title="On its own" />);

      await expect.element(screen.getByText('On its own')).toBeInTheDocument();
    });
  });

  describe('growing', () => {
    it('takes a step that was appended after the first render', async () => {
      const screen = await render(
        <AgentSteps>
          <AgentStep title="Read the request" />
        </AgentSteps>
      );

      await screen.rerender(
        <AgentSteps>
          <AgentStep title="Read the request" />
          <AgentStep title="Search the docs" status="running" />
        </AgentSteps>
      );

      await expect.element(screen.getByText('Search the docs')).toBeInTheDocument();
    });

    // The step has no name yet, which is the whole reason it is a prop on the
    // chain rather than one more `AgentStep`.
    it('draws one more marker while there is more to come', async () => {
      const screen = await render(
        <AgentSteps running>
          <AgentStep title="Read the request" />
        </AgentSteps>
      );

      const items = screen.getByRole('listitem').all();

      expect(items).toHaveLength(2);
      // No visible label: the turning ring has said it, and the status is read
      // out. A word beside it would be the same thing twice.
      expect(items[1].element().textContent).toBe('Running');
    });

    it('labels that marker with whatever it was handed', async () => {
      const screen = await render(
        <AgentSteps running="Deciding what to do next">
          <AgentStep title="Read the request" />
        </AgentSteps>
      );

      await expect.element(screen.getByText('Deciding what to do next')).toBeInTheDocument();
    });

    it('draws nothing extra when the chain has finished', async () => {
      const screen = await render(
        <AgentSteps>
          <AgentStep title="Read the request" />
        </AgentSteps>
      );

      expect(screen.getByRole('listitem').all()).toHaveLength(1);
    });
  });

  describe('duration', () => {
    it('writes the time a step took', async () => {
      const screen = await render(
        <AgentSteps>
          <AgentStep title="Search the docs" duration={1500} />
        </AgentSteps>
      );

      await expect.element(screen.getByText('1.5s')).toBeInTheDocument();
    });

    it('says nothing when it was not told one', async () => {
      const screen = await render(
        <AgentSteps>
          <AgentStep title="Search the docs" />
        </AgentSteps>
      );

      expect(screen.getByText('1.5s').query()).toBeNull();
    });
  });

  describe('colour', () => {
    it('gives a failed step the danger family whatever the chain says', async () => {
      const screen = await render(
        <AgentSteps color="info">
          <AgentStep title="Search the docs" status="error" />
        </AgentSteps>
      );

      const element = screen.getByRole('listitem').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-danger-accent)');
    });

    it('gives a running step the chain’s own', async () => {
      const screen = await render(
        <AgentSteps color="info">
          <AgentStep title="Search the docs" status="running" />
        </AgentSteps>
      );

      const element = screen.getByRole('listitem').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-info-accent)');
    });
  });
});
