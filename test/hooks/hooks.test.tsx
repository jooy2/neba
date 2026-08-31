/**
 * The hooks the library already runs on, now that a consumer can reach them.
 *
 * They are tested through a component rather than through a renderer helper,
 * because that is the only thing that exercises what they are actually for: a
 * subscription that has to survive a re-render, a ref that has to be attached
 * before the first measurement, and a listener that has to be unbound on
 * unmount.
 */
import { useState } from 'react';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
import {
  useBreakpoint,
  useDisclosure,
  useElementSize,
  useMediaQuery,
  useOnScreen,
  usePrefersReducedMotion,
  useShortcut
} from 'neba/hooks';
import { useDisclosure as useDisclosureFromBarrel } from 'neba';
import { readOS } from '../../src/internal/keys.js';

describe('useDisclosure', () => {
  function Panel() {
    const { open, onOpen, onClose, onToggle } = useDisclosure();

    return (
      <div>
        <button type="button" onClick={onOpen}>
          Open
        </button>
        <button type="button" onClick={onClose}>
          Close
        </button>
        <button type="button" onClick={onToggle}>
          Toggle
        </button>
        <p>{open ? 'showing' : 'hidden'}</p>
      </div>
    );
  }

  it('opens, closes and toggles', async () => {
    const screen = await render(<Panel />);

    await expect.element(screen.getByText('hidden')).toBeInTheDocument();

    await screen.getByRole('button', { name: 'Open' }).click();
    await expect.element(screen.getByText('showing')).toBeInTheDocument();

    await screen.getByRole('button', { name: 'Close' }).click();
    await expect.element(screen.getByText('hidden')).toBeInTheDocument();

    await screen.getByRole('button', { name: 'Toggle' }).click();
    await expect.element(screen.getByText('showing')).toBeInTheDocument();
  });

  it('starts open when told to', async () => {
    function Started() {
      const { open } = useDisclosure(true);
      return <p>{open ? 'showing' : 'hidden'}</p>;
    }

    const screen = await render(<Started />);

    await expect.element(screen.getByText('showing')).toBeInTheDocument();
  });

  it('keeps its callbacks stable across renders', async () => {
    // A toggle closed over a stale render is the bug this hook exists to
    // prevent, and a callback that changes identity every render is what makes
    // passing it to a memoised child pointless.
    const seen = new Set<unknown>();

    function Stable() {
      const { open, onToggle } = useDisclosure();
      seen.add(onToggle);
      return (
        <button type="button" onClick={onToggle}>
          {open ? 'showing' : 'hidden'}
        </button>
      );
    }

    const screen = await render(<Stable />);

    await screen.getByRole('button').click();
    await expect.element(screen.getByRole('button', { name: 'showing' })).toBeInTheDocument();
    await screen.getByRole('button').click();
    await expect.element(screen.getByRole('button', { name: 'hidden' })).toBeInTheDocument();

    expect(seen.size).toBe(1);
  });
});

describe('useMediaQuery and useBreakpoint', () => {
  function Answer({ query }: { query: string }) {
    return <p>{useMediaQuery(query) ? 'yes' : 'no'}</p>;
  }

  it('answers a query the window can settle', async () => {
    const screen = await render(<Answer query="(width >= 0px)" />);

    await expect.element(screen.getByText('yes')).toBeInTheDocument();
  });

  it('answers one it cannot', async () => {
    const screen = await render(<Answer query="(width >= 99999px)" />);

    await expect.element(screen.getByText('no')).toBeInTheDocument();
  });

  it('follows the query when it changes', async () => {
    const screen = await render(<Answer query="(width >= 0px)" />);

    await expect.element(screen.getByText('yes')).toBeInTheDocument();

    await screen.rerender(<Answer query="(width >= 99999px)" />);

    await expect.element(screen.getByText('no')).toBeInTheDocument();
  });

  it('reads a breakpoint the same way a `md:` utility does', async () => {
    function AtLeast() {
      // `xs` is 0rem, so it is the value with no media query around it.
      return <p>{`${useBreakpoint('xs')} ${useBreakpoint('xl')}`}</p>;
    }

    const screen = await render(<AtLeast />);
    const text = screen.getByText(/true|false/).element().textContent ?? '';

    expect(text.startsWith('true ')).toBe(true);
  });
});

describe('usePrefersReducedMotion', () => {
  it('answers without throwing, whichever way this browser is set', async () => {
    function Motion() {
      return <p>{usePrefersReducedMotion() ? 'still' : 'moving'}</p>;
    }

    const screen = await render(<Motion />);

    await expect.element(screen.getByText(/still|moving/)).toBeInTheDocument();
  });
});

describe('useElementSize', () => {
  it('measures the element the ref is on, and follows it', async () => {
    function Measured({ width }: { width: number }) {
      const [ref, size] = useElementSize<HTMLDivElement>();

      return (
        <div>
          <div ref={ref} style={{ width, height: 40 }} />
          <p>{Math.round(size.width)}</p>
        </div>
      );
    }

    const screen = await render(<Measured width={120} />);

    await expect.element(screen.getByText('120')).toBeInTheDocument();

    await screen.rerender(<Measured width={200} />);

    await expect.element(screen.getByText('200')).toBeInTheDocument();
  });

  it('measures on mount rather than waiting to be told', async () => {
    // A `ResizeObserver` reports its first entry a task later, and a component
    // that renders `0 × 0` until then is a component that lays out twice.
    function Measured() {
      const [ref, size] = useElementSize<HTMLDivElement>();
      return (
        <div>
          <div ref={ref} style={{ width: 64, height: 64 }} />
          <p>{size.width === 0 ? 'unmeasured' : 'measured'}</p>
        </div>
      );
    }

    const screen = await render(<Measured />);

    await expect.element(screen.getByText('measured')).toBeInTheDocument();
  });
});

describe('useOnScreen', () => {
  it('reports an element that is on screen', async () => {
    function Watched() {
      const [ref, visible] = useOnScreen<HTMLDivElement>();
      return (
        <div>
          <div ref={ref}>watched</div>
          <p>{visible ? 'seen' : 'unseen'}</p>
        </div>
      );
    }

    const screen = await render(<Watched />);

    await expect.element(screen.getByText('seen')).toBeInTheDocument();
  });
});

describe('useShortcut', () => {
  it('runs on the combination it was given', async () => {
    const run = vi.fn();

    function Bound() {
      useShortcut('Mod+Shift+P', run);
      return <p>bound</p>;
    }

    await render(<Bound />);
    const mac = readOS() === 'mac';

    await userEvent.keyboard(
      mac ? '{Meta>}{Shift>}P{/Shift}{/Meta}' : '{Control>}{Shift>}P{/Shift}{/Control}'
    );

    expect(run).toHaveBeenCalledTimes(1);
  });

  it('stays quiet while the reader is typing', async () => {
    const run = vi.fn();

    function Bound() {
      useShortcut('/', run);
      return <input aria-label="Search" />;
    }

    const screen = await render(<Bound />);

    await screen.getByRole('textbox').click();
    await userEvent.keyboard('/');

    // A bare-letter shortcut that fires inside a field eats what was written.
    expect(run).not.toHaveBeenCalled();
    expect((screen.getByRole('textbox').element() as HTMLInputElement).value).toBe('/');
  });

  it('can be turned off without unmounting', async () => {
    const run = vi.fn();

    function Bound() {
      const [enabled, setEnabled] = useState(true);
      useShortcut('Alt+G', run, { enabled });
      return (
        <button type="button" onClick={() => setEnabled(false)}>
          Disable
        </button>
      );
    }

    const screen = await render(<Bound />);

    await userEvent.keyboard('{Alt>}g{/Alt}');
    expect(run).toHaveBeenCalledTimes(1);

    await screen.getByRole('button').click();
    await userEvent.keyboard('{Alt>}g{/Alt}');
    expect(run).toHaveBeenCalledTimes(1);
  });

  it('unbinds on unmount', async () => {
    const run = vi.fn();

    function Bound() {
      useShortcut('Alt+U', run);
      return <p>bound</p>;
    }

    const screen = await render(<Bound />);
    await userEvent.keyboard('{Alt>}u{/Alt}');
    expect(run).toHaveBeenCalledTimes(1);

    await screen.rerender(<p>gone</p>);
    await userEvent.keyboard('{Alt>}u{/Alt}');
    expect(run).toHaveBeenCalledTimes(1);
  });

  it('sees the newest handler without re-binding the listener', async () => {
    const seen: number[] = [];

    function Counting() {
      const [count, setCount] = useState(0);
      useShortcut('Alt+C', () => seen.push(count));
      return (
        <button type="button" onClick={() => setCount((n) => n + 1)}>
          {count}
        </button>
      );
    }

    const screen = await render(<Counting />);

    await screen.getByRole('button').click();
    await screen.getByRole('button').click();
    await expect.element(screen.getByRole('button', { name: '2' })).toBeInTheDocument();

    await userEvent.keyboard('{Alt>}c{/Alt}');

    expect(seen).toEqual([2]);
  });
});

describe('the barrel', () => {
  it('offers the hooks from the entry point as well as from `neba/hooks`', () => {
    expect(useDisclosureFromBarrel).toBe(useDisclosure);
  });
});
