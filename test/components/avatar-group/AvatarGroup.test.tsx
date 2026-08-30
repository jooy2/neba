import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Avatar, AvatarGroup } from 'neba';

const PEOPLE = ['Jane Doe', 'Kim Minji', 'Alex Park', 'Sam Lee', 'Noa Cohen'];

function Stack(props: React.ComponentProps<typeof AvatarGroup>) {
  return (
    <AvatarGroup {...props}>
      {PEOPLE.map((person) => (
        <Avatar key={person} name={person} />
      ))}
    </AvatarGroup>
  );
}

describe('AvatarGroup', () => {
  describe('rendering', () => {
    it('draws every avatar it was given', async () => {
      const screen = await render(<Stack data-testid="stack" />);

      expect(screen.getByTestId('stack').element().children).toHaveLength(PEOPLE.length);
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Stack className="my-own-class" data-testid="stack" />);

      expect(screen.getByTestId('stack').element()).toHaveClass('my-own-class');
    });

    it('reflects a changed set on re-render', async () => {
      const screen = await render(
        <AvatarGroup data-testid="stack">
          <Avatar name="Jane Doe" />
        </AvatarGroup>
      );

      await screen.rerender(
        <AvatarGroup data-testid="stack">
          <Avatar name="Jane Doe" />
          <Avatar name="Kim Minji" />
        </AvatarGroup>
      );

      expect(screen.getByTestId('stack').element().children).toHaveLength(2);
    });
  });

  describe('max and total', () => {
    it('draws the count of the ones that did not fit', async () => {
      const screen = await render(<Stack max={3} data-testid="stack" />);

      await expect.element(screen.getByText('+2')).toBeInTheDocument();
      expect(screen.getByTestId('stack').element().children).toHaveLength(4);
    });

    it('counts against total when it was handed only the first few', async () => {
      const screen = await render(<Stack max={3} total={42} data-testid="stack" />);

      await expect.element(screen.getByText('+39')).toBeInTheDocument();
    });

    it('draws no count when everything fits', async () => {
      const screen = await render(<Stack max={PEOPLE.length} />);

      expect(screen.getByText(/^\+/).query()).toBeNull();
    });
  });

  describe('shared props', () => {
    it('sets the size once for the whole stack', async () => {
      const screen = await render(<Stack size="lg" data-testid="stack" />);
      const [first, second] = Array.from(screen.getByTestId('stack').element().children);

      expect(first).toHaveClass('h-10');
      expect(second).toHaveClass('h-10');
    });

    it('lets an avatar override the group', async () => {
      const screen = await render(
        <AvatarGroup size="lg" data-testid="stack">
          <Avatar name="Jane Doe" />
          <Avatar name="Kim Minji" size="sm" />
        </AvatarGroup>
      );
      const [first, second] = Array.from(screen.getByTestId('stack').element().children);

      expect(first).toHaveClass('h-10');
      expect(second).toHaveClass('h-6.5');
    });

    it('passes the shape and the colour down too', async () => {
      const screen = await render(<Stack shape="square" color="danger" data-testid="stack" />);
      const first = screen.getByTestId('stack').element().firstElementChild as HTMLElement;

      expect(first).not.toHaveClass('rounded-full');
      expect(first.style.getPropertyValue('--n-accent')).toBe('var(--neba-danger-accent)');
    });
  });

  describe('overlap', () => {
    it('takes the ladder off size', async () => {
      const screen = await render(<Stack size="xs" data-testid="stack" />);
      const element = screen.getByTestId('stack').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-overlap')).toBe('0.375rem');
    });

    it('takes a length of its own instead', async () => {
      const screen = await render(<Stack overlap={4} data-testid="stack" />);
      const element = screen.getByTestId('stack').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-overlap')).toBe('4px');
    });
  });
});
