import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Avatar, Stack } from 'neba';

/** The wrappers a Stack draws, one per item. */
function items(container: HTMLElement): HTMLElement[] {
  return [...container.querySelectorAll<HTMLElement>('[data-neba-stack-item]')];
}

/** The box inside each one that carries the depth cue. */
function depth(item: HTMLElement): HTMLElement {
  return item.firstElementChild as HTMLElement;
}

/**
 * A margin as the browser resolves it.
 *
 * The inline value is a `calc()` over a length the caller wrote, and a browser
 * is free to serialize `calc(12px * -1)` back as `calc(-12px)`. The computed
 * value is the same number in all three.
 */
function margin(item: HTMLElement, side: 'marginInlineStart' | 'marginBlockStart'): string {
  return getComputedStyle(item)[side];
}

const NAMES = ['Ada', 'Bo', 'Cai'];

function Faces(props: React.ComponentProps<typeof Stack>) {
  return (
    <Stack data-testid="stack" {...props}>
      {NAMES.map((name) => (
        <Avatar key={name} name={name} />
      ))}
    </Stack>
  );
}

describe('Stack', () => {
  describe('rendering', () => {
    it('draws one wrapper per child, with the child inside it', async () => {
      const screen = await render(<Faces />);
      const drawn = items(screen.container);

      expect(drawn).toHaveLength(3);
      expect(drawn.every((item) => depth(item).children.length === 1)).toBe(true);
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Faces className="my-own-class" />);

      expect(screen.getByTestId('stack').element()).toHaveClass('my-own-class');
    });

    it('forwards unknown props to the root', async () => {
      const screen = await render(<Faces id="team" />);

      expect(screen.getByTestId('stack').element()).toHaveAttribute('id', 'team');
    });

    // Cloning would need every child to accept a className and a style, which a
    // Tooltip around an avatar is under no obligation to do.
    it('does not write its own layout onto the children', async () => {
      const screen = await render(<Faces ring transition="fade" scaleStep={0.9} />);
      const child = depth(items(screen.container)[1]).firstElementChild as HTMLElement;

      expect(child.style.scale).toBe('');
      expect(child.style.marginInlineStart).toBe('');
      expect(child.className).not.toContain('neba-anim');
    });
  });

  describe('the pile', () => {
    it('pulls every item but the first back along the inline axis', async () => {
      const screen = await render(<Faces overlap={12} />);
      const [first, second] = items(screen.container);

      expect(margin(first, 'marginInlineStart')).toBe('0px');
      expect(margin(second, 'marginInlineStart')).toBe('-12px');
    });

    it('runs down the page when it is vertical', async () => {
      const screen = await render(<Faces direction="vertical" overlap={12} />);
      const [, second] = items(screen.container);

      expect(margin(second, 'marginBlockStart')).toBe('-12px');
      expect(margin(second, 'marginInlineStart')).toBe('0px');
      expect(screen.getByTestId('stack').element()).toHaveClass('flex-col');
    });

    // The flow only overlaps on the axis it runs along, so the other one is a
    // margin multiplied out per item.
    it('flows sideways and falls as it goes when it is diagonal', async () => {
      const screen = await render(<Faces direction="diagonal" overlap={12} drop={5} />);
      const [first, second, third] = items(screen.container);

      expect(margin(first, 'marginBlockStart')).toBe('0px');
      expect(margin(second, 'marginBlockStart')).toBe('5px');
      expect(margin(third, 'marginBlockStart')).toBe('10px');
      expect(margin(second, 'marginInlineStart')).toBe('-12px');
    });

    it('takes the overlap from size when it was not given one', async () => {
      const screen = await render(<Faces size="xs" />);

      expect(margin(items(screen.container)[1], 'marginInlineStart')).toBe('-6px');
    });

    it('puts the first child at the front, and the last when asked', async () => {
      const first = await render(<Faces />);

      expect(items(first.container).map((item) => item.style.zIndex)).toEqual(['3', '2', '1']);

      const last = await render(<Faces front="last" />);

      expect(items(last.container).map((item) => item.style.zIndex)).toEqual(['1', '2', '3']);
    });
  });

  describe('depth', () => {
    // `scale` is the individual property rather than a `transform`, so an
    // entrance animating the shorthand on the wrapper above composes with it.
    it('shrinks each item against the one in front', async () => {
      const screen = await render(<Faces scaleStep={0.9} />);

      expect(items(screen.container).map((item) => depth(item).style.scale)).toEqual([
        '1',
        '0.9',
        '0.81'
      ]);
    });

    it('fades each item against the one in front', async () => {
      const screen = await render(<Faces opacityStep={0.5} />);

      expect(items(screen.container).map((item) => depth(item).style.opacity)).toEqual([
        '1',
        '0.5',
        '0.25'
      ]);
    });

    it('writes neither while the steps are one', async () => {
      const screen = await render(<Faces />);
      const box = depth(items(screen.container)[1]);

      expect(box.style.scale).toBe('');
      expect(box.style.opacity).toBe('');
    });
  });

  describe('the ones that did not fit', () => {
    it('draws every child when there is no max', async () => {
      const screen = await render(<Faces />);

      expect(items(screen.container)).toHaveLength(3);
    });

    it('stops at max and hands the rest to overflow', async () => {
      const screen = await render(
        <Faces max={2} overflow={(hidden) => <Avatar initials={`+${hidden}`} />} />
      );

      expect(items(screen.container)).toHaveLength(3);
      await expect.element(screen.getByText('+1')).toBeInTheDocument();
    });

    it('counts against total when it was handed only the first few', async () => {
      const screen = await render(
        <Faces max={2} total={40} overflow={(hidden) => <Avatar initials={`+${hidden}`} />} />
      );

      await expect.element(screen.getByText('+38')).toBeInTheDocument();
    });

    it('draws nothing extra when everything fits', async () => {
      const screen = await render(
        <Faces max={5} overflow={(hidden) => <Avatar initials={`+${hidden}`} />} />
      );

      expect(items(screen.container)).toHaveLength(3);
    });
  });

  describe('arriving', () => {
    it('gives each item the effect it was asked for', async () => {
      const screen = await render(<Faces transition="fade" />);

      expect(items(screen.container).every((item) => item.classList.contains('neba-anim'))).toBe(
        true
      );
      expect(items(screen.container)[0]).toHaveClass('neba-anim-fade');
    });

    it('deals the pile when there is a stagger', async () => {
      const screen = await render(<Faces transition="fade" stagger={70} />);

      expect(
        items(screen.container).map((item) => item.style.getPropertyValue('--n-anim-delay'))
      ).toEqual(['0ms', '70ms', '140ms']);
    });

    it('deals it from the back when reversed', async () => {
      const screen = await render(<Faces transition="fade" stagger={70} reverse />);

      expect(
        items(screen.container).map((item) => item.style.getPropertyValue('--n-anim-delay'))
      ).toEqual(['140ms', '70ms', '0ms']);
    });

    it('lengthens each item by durationStep, and never past zero', async () => {
      const screen = await render(
        <Faces transition={{ type: 'fade', duration: 200 }} durationStep={-150} />
      );

      expect(
        items(screen.container).map((item) => item.style.getPropertyValue('--n-anim-duration'))
      ).toEqual(['200ms', '50ms', '0ms']);
    });

    it('writes no animation class when it was given no transition', async () => {
      const screen = await render(<Faces />);

      expect(items(screen.container)[0].className).toBe('');
    });
  });
});
