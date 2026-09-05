/**
 * The three jobs, tested one at a time: the prop values a product sets once,
 * the colour scheme a reader chooses, and the direction the document runs in.
 */
import { Component, type ReactNode } from 'react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  Alert,
  Button,
  Chip,
  colorSchemeScript,
  NebaProvider,
  TextField,
  useColorScheme
} from 'neba';

const root = () => document.documentElement;

afterEach(() => {
  root().removeAttribute('data-theme');
  root().removeAttribute('dir');
  root().style.colorScheme = '';
  try {
    localStorage.removeItem('neba-color-scheme');
    localStorage.removeItem('my-key');
  } catch {
    // Storage denied. Nothing to clean.
  }
});

describe('defaults', () => {
  const heightOf = (element: Element) =>
    [...element.classList].find((name) => /^h-\d/.test(name)) ?? '';

  it('fills in the size a call site left out', async () => {
    // Both in one render, and named apart: two renders in one test leave two
    // buttons in the document and a name query has two to choose from.
    const screen = await render(
      <>
        <NebaProvider defaults={{ size: 'xs' }}>
          <Button>Provided</Button>
        </NebaProvider>
        <Button>Bare</Button>
      </>
    );

    const provided = heightOf(screen.getByRole('button', { name: 'Provided' }).element());
    const bare = heightOf(screen.getByRole('button', { name: 'Bare' }).element());

    expect(provided).not.toBe('');
    expect(provided).not.toBe(bare);
  });

  it('loses to the call site', async () => {
    const screen = await render(
      <>
        <NebaProvider defaults={{ size: 'xs' }}>
          <Button size="xl">Provided</Button>
        </NebaProvider>
        <Button size="xl">Bare</Button>
      </>
    );

    expect(heightOf(screen.getByRole('button', { name: 'Provided' }).element())).toBe(
      heightOf(screen.getByRole('button', { name: 'Bare' }).element())
    );
  });

  it('reaches a component that takes the axis and skips one that does not', async () => {
    // `density` is filled only where a component destructures it; anywhere else
    // it would ride the props spread onto a DOM node as a stray attribute.
    const screen = await render(
      <NebaProvider defaults={{ density: 'compact' }}>
        <Chip>tag</Chip>
      </NebaProvider>
    );

    expect(screen.container.querySelector('[density]')).toBeNull();
  });

  it('does not repaint a colour a component chose for meaning', async () => {
    // `color` is deliberately not defaultable: an Alert is `info` because that
    // is what it means, and a global override would say something else.
    const screen = await render(
      <NebaProvider defaults={{ size: 'sm' }}>
        <Alert title="Deploy finished" />
      </NebaProvider>
    );

    await expect.element(screen.getByText('Deploy finished')).toBeInTheDocument();
  });

  it('carries the locale to the words a component says on its own behalf', async () => {
    const screen = await render(
      <NebaProvider defaults={{ locale: 'ko' }}>
        <TextField label="Note" />
      </NebaProvider>
    );

    await expect.element(screen.getByRole('textbox', { name: 'Note' })).toBeInTheDocument();
  });
});

describe('colour scheme', () => {
  function Switcher() {
    const { colorScheme, resolvedColorScheme, setColorScheme, toggleColorScheme } =
      useColorScheme();

    return (
      <div>
        <p>{`${colorScheme} → ${resolvedColorScheme}`}</p>
        <Button onClick={() => setColorScheme('dark')}>Dark</Button>
        <Button onClick={() => setColorScheme('light')}>Light</Button>
        <Button onClick={() => setColorScheme('system')}>System</Button>
        <Button onClick={toggleColorScheme}>Toggle</Button>
      </div>
    );
  }

  it('writes the scheme onto the document', async () => {
    const screen = await render(
      <NebaProvider defaultColorScheme="light">
        <Switcher />
      </NebaProvider>
    );

    await expect.poll(() => root().getAttribute('data-theme')).toBe('light');

    await screen.getByRole('button', { name: 'Dark' }).click();

    await expect.poll(() => root().getAttribute('data-theme')).toBe('dark');
  });

  it("turns the browser's own furniture over with it", async () => {
    // Without `color-scheme` a dark page keeps a white scrollbar down its side.
    const screen = await render(
      <NebaProvider defaultColorScheme="light">
        <Switcher />
      </NebaProvider>
    );

    await screen.getByRole('button', { name: 'Dark' }).click();

    await expect.poll(() => root().style.colorScheme).toBe('dark');
  });

  it('keeps `system` as its own answer rather than collapsing it', async () => {
    // A three-way switch has to show `system` as a position of its own; only
    // `resolvedColorScheme` is allowed to be one of the two.
    const screen = await render(
      <NebaProvider defaultColorScheme="system">
        <Switcher />
      </NebaProvider>
    );

    await expect.element(screen.getByText(/^system → (light|dark)$/)).toBeInTheDocument();
  });

  it('toggles to the opposite of what is showing', async () => {
    const screen = await render(
      <NebaProvider defaultColorScheme="dark">
        <Switcher />
      </NebaProvider>
    );

    await screen.getByRole('button', { name: 'Toggle' }).click();

    await expect.element(screen.getByText('light → light')).toBeInTheDocument();
  });

  it('remembers the choice, and reads it back on the next visit', async () => {
    const first = await render(
      <NebaProvider>
        <Switcher />
      </NebaProvider>
    );

    await first.getByRole('button', { name: 'Dark' }).click();
    expect(localStorage.getItem('neba-color-scheme')).toBe('dark');

    const second = await render(
      <NebaProvider>
        <Switcher />
      </NebaProvider>
    );

    await expect.element(second.getByText('dark → dark').first()).toBeInTheDocument();
  });

  it('forgets it when told to', async () => {
    const screen = await render(
      <NebaProvider storageKey={false}>
        <Switcher />
      </NebaProvider>
    );

    await screen.getByRole('button', { name: 'Dark' }).click();

    expect(localStorage.getItem('neba-color-scheme')).toBeNull();
    await expect.poll(() => root().getAttribute('data-theme')).toBe('dark');
  });

  it('honours a controlled scheme', async () => {
    const onColorSchemeChange = vi.fn();
    const screen = await render(
      <NebaProvider colorScheme="light" onColorSchemeChange={onColorSchemeChange}>
        <Switcher />
      </NebaProvider>
    );

    await screen.getByRole('button', { name: 'Dark' }).click();

    expect(onColorSchemeChange).toHaveBeenCalledWith('dark');
    await expect.element(screen.getByText('light → light')).toBeInTheDocument();
  });

  it('tells a caller that forgot the provider', async () => {
    const seen: string[] = [];

    class Boundary extends Component<{ children: ReactNode }, { failed: boolean }> {
      state = { failed: false };
      static getDerivedStateFromError() {
        return { failed: true };
      }
      componentDidCatch(error: Error) {
        seen.push(error.message);
      }
      render() {
        return this.state.failed ? <p>caught</p> : this.props.children;
      }
    }

    const original = console.error;
    console.error = () => {};

    try {
      const screen = await render(
        <Boundary>
          <Switcher />
        </Boundary>
      );

      await expect.element(screen.getByText('caught')).toBeInTheDocument();
    } finally {
      console.error = original;
    }

    expect(seen.join()).toContain('<NebaProvider>');
  });
});

describe('direction', () => {
  it('writes it onto the document', async () => {
    await render(
      <NebaProvider direction="rtl">
        <Button>Ship</Button>
      </NebaProvider>
    );

    await expect.poll(() => root().getAttribute('dir')).toBe('rtl');
  });

  it('leaves a document that already sets its own alone', async () => {
    root().setAttribute('dir', 'rtl');

    await render(
      <NebaProvider>
        <Button>Ship</Button>
      </NebaProvider>
    );

    expect(root().getAttribute('dir')).toBe('rtl');
  });
});

describe('colorSchemeScript', () => {
  it('reads the same key and writes the same attribute the provider does', () => {
    const script = colorSchemeScript({ storageKey: 'my-key', defaultColorScheme: 'dark' });

    expect(script).toContain('"my-key"');
    expect(script).toContain('data-theme');
    expect(script).toContain('prefers-color-scheme: dark');
  });

  it('runs without throwing where storage is denied', () => {
    // It is inlined above everything, so anything it throws is the page.
    expect(() => new Function(colorSchemeScript())()).not.toThrow();
    root().removeAttribute('data-theme');
  });

  /*
   * The string is written inside a `<script>` element, and a browser stops
   * parsing that element at the first `</script` in it however the JavaScript
   * around it is quoted. `JSON.stringify` closes the quotes and does not touch
   * that, so the `<` is escaped separately — and the escape has to read back as
   * the same character, or the key the script looks up would not be the key the
   * provider writes.
   */
  it('cannot end the script element it is written into', () => {
    const script = colorSchemeScript({ storageKey: 'a</script><img src=x>' });

    expect(script).not.toContain('</script');
    expect(script).toContain('\\u003c');
  });

  it('still reads back as the key it was given', () => {
    const key = 'a<b';
    const script = colorSchemeScript({ storageKey: key });
    const literal = script.slice(
      script.indexOf('localStorage.getItem(') + 'localStorage.getItem('.length,
      script.indexOf(')||')
    );

    expect(new Function(`return ${literal}`)()).toBe(key);
  });
});
