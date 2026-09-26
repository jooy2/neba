/**
 * The three jobs, tested one at a time: the prop values a product sets once,
 * the colour scheme a reader chooses, and the direction the document runs in.
 */
import { Component, memo, Profiler, type ReactNode } from 'react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { renderToString } from 'react-dom/server';
import { hydrateRoot } from 'react-dom/client';
import { render } from 'vitest-browser-react';
import { useDirection } from '@base-ui/react/direction-provider';
import {
  Alert,
  Button,
  ButtonGroup,
  Chip,
  colorSchemeScript,
  DatePicker,
  LineChart,
  NebaProvider,
  Select,
  TextField,
  Toggle,
  ToggleGroup,
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

  it('does not re-render its readers when the page above it re-renders', async () => {
    let commits = 0;
    // Memoised, so the only thing that can reach the Button inside is the
    // context it reads — and the Profiler counts every commit that does.
    const Reader = memo(function Reader() {
      return (
        <Profiler id="reader" onRender={() => (commits += 1)}>
          <Button>Save</Button>
        </Profiler>
      );
    });
    const Page = ({ tick }: { tick: number }) => (
      <NebaProvider defaults={{ size: 'sm' }} storageKey={false}>
        <span>{tick}</span>
        <Reader />
      </NebaProvider>
    );
    const screen = await render(<Page tick={0} />);
    const before = commits;

    await screen.rerender(<Page tick={1} />);

    expect(commits).toBe(before);
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

  // The provider was filled in before the group was read, so it beat the group.
  it('loses to a group around the call site', async () => {
    const screen = await render(
      <>
        <NebaProvider defaults={{ size: 'xs', variant: 'text' }}>
          <ButtonGroup size="xl" variant="solid" aria-label="Provided">
            <Button>Grouped</Button>
            <Toggle>Pinned</Toggle>
          </ButtonGroup>
        </NebaProvider>
        <Button size="xl">Bare</Button>
      </>
    );
    const bare = heightOf(screen.getByRole('button', { name: 'Bare' }).element());

    expect(heightOf(screen.getByRole('button', { name: 'Grouped' }).element())).toBe(bare);
    expect(heightOf(screen.getByRole('button', { name: 'Pinned' }).element())).toBe(bare);
  });

  // The same again for the other group, which reads the same context.
  it('loses to a toggle group around the call site', async () => {
    const screen = await render(
      <>
        <NebaProvider defaults={{ size: 'xs' }}>
          <ToggleGroup size="xl" aria-label="Provided">
            <Toggle value="bold">Bold</Toggle>
          </ToggleGroup>
        </NebaProvider>
        <Toggle size="xl">Bare</Toggle>
      </>
    );

    expect(heightOf(screen.getByRole('button', { name: 'Bold' }).element())).toBe(
      heightOf(screen.getByRole('button', { name: 'Bare' }).element())
    );
  });

  // A chart asked nothing of the provider: its size came from its own default.
  it('reaches a chart', async () => {
    const chart = (
      <LineChart label="Visits" categories={['a', 'b']} series={[{ name: 'x', data: [1, 2] }]} />
    );
    const screen = await render(
      <>
        <NebaProvider defaults={{ size: 'xl' }}>
          <div data-testid="provided">{chart}</div>
        </NebaProvider>
        <div data-testid="bare">{chart}</div>
      </>
    );
    const heightIn = (id: string) =>
      screen.getByTestId(id).element().querySelector('svg')?.getAttribute('height');

    await expect.poll(() => heightIn('bare')).toBeTruthy();
    await expect.poll(() => heightIn('provided')).toBeTruthy();
    expect(heightIn('provided')).not.toBe(heightIn('bare'));
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

  // Where a form's labels go is a decision about the whole product: fields that
  // put them in two places look like two forms stacked on each other.
  it('puts every field-shaped label where the product put them', async () => {
    const screen = await render(
      <NebaProvider defaults={{ labelPlacement: 'notch' }}>
        <TextField label="Name" />
        <Select items={[{ value: 'a', label: 'A' }]} label="Plan" />
        <DatePicker label="Starts" />
      </NebaProvider>
    );

    expect(screen.container.querySelectorAll('.neba-notch label')).toHaveLength(3);
    await expect.element(screen.getByRole('textbox', { name: 'Name' })).toBeInTheDocument();
    await expect.element(screen.getByRole('combobox', { name: 'Plan' })).toBeInTheDocument();
  });

  it('loses the label placement to the call site', async () => {
    const screen = await render(
      <NebaProvider defaults={{ labelPlacement: 'float' }}>
        <TextField label="Name" labelPlacement="top" />
      </NebaProvider>
    );

    expect(screen.container.querySelector('.neba-notch')).toBeNull();
    await expect.element(screen.getByRole('textbox', { name: 'Name' })).toBeInTheDocument();
  });

  // A component with no `labelPlacement` must not have it spread onto a node.
  it('leaves the label placement off a component that has none', async () => {
    const screen = await render(
      <NebaProvider defaults={{ labelPlacement: 'notch' }}>
        <Chip>tag</Chip>
      </NebaProvider>
    );

    expect(screen.container.querySelector('[labelPlacement], [labelplacement]')).toBeNull();
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

  // The server has no `localStorage`, so it rendered the default while the
  // hydrating client rendered the stored scheme, and React reported the mismatch.
  it('reads the stored scheme after hydrating, so the two renders agree', async () => {
    const tree = (
      <NebaProvider defaultColorScheme="light">
        <Switcher />
      </NebaProvider>
    );
    const container = document.createElement('div');

    document.body.append(container);
    container.innerHTML = renderToString(tree);
    localStorage.setItem('neba-color-scheme', 'dark');

    const onRecoverableError = vi.fn();
    const hydrated = hydrateRoot(container, tree, { onRecoverableError });

    try {
      await expect.poll(() => container.querySelector('p')?.textContent).toBe('dark → dark');
      expect(onRecoverableError).not.toHaveBeenCalled();
      await expect.poll(() => root().getAttribute('data-theme')).toBe('dark');
    } finally {
      hydrated.unmount();
      container.remove();
    }
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

describe('nesting', () => {
  const heightOf = (element: Element) =>
    [...element.classList].find((name) => /^h-\d/.test(name)) ?? '';

  function Direction() {
    return <output>{useDirection()}</output>;
  }

  // An inner `defaults={{ density: 'compact' }}` replaced the outer object
  // whole, so the outer `size` was lost inside it.
  it("merges an inner provider's defaults over the outer ones", async () => {
    const screen = await render(
      <>
        <NebaProvider defaults={{ size: 'xs' }}>
          <NebaProvider defaults={{ density: 'compact' }}>
            <Button>Inner</Button>
          </NebaProvider>
        </NebaProvider>
        <NebaProvider defaults={{ size: 'xs' }}>
          <Button>Outer</Button>
        </NebaProvider>
      </>
    );

    expect(heightOf(screen.getByRole('button', { name: 'Inner' }).element())).toBe(
      heightOf(screen.getByRole('button', { name: 'Outer' }).element())
    );
  });

  it('keeps the outer label placement inside a provider that sets something else', async () => {
    const screen = await render(
      <NebaProvider defaults={{ labelPlacement: 'notch' }}>
        <NebaProvider defaults={{ size: 'sm' }}>
          <TextField label="Name" />
        </NebaProvider>
      </NebaProvider>
    );

    expect(screen.container.querySelector('.neba-notch label')).toHaveTextContent('Name');
  });

  // The merge has to keep both halves: the outer size and the inner density.
  it('takes the inner density together with the outer size', async () => {
    const paddingOf = (element: Element) =>
      [...element.classList].find((name) => /^px-/.test(name)) ?? '';

    const screen = await render(
      <>
        <NebaProvider defaults={{ size: 'xs' }}>
          <NebaProvider defaults={{ density: 'compact' }}>
            <Button>Nested</Button>
          </NebaProvider>
        </NebaProvider>
        <Button size="xs" density="compact">
          Spelled out
        </Button>
      </>
    );
    const nested = screen.getByRole('button', { name: 'Nested' }).element();
    const spelled = screen.getByRole('button', { name: 'Spelled out' }).element();

    expect(paddingOf(nested)).not.toBe('');
    expect(paddingOf(nested)).toBe(paddingOf(spelled));
    expect(heightOf(nested)).toBe(heightOf(spelled));
  });

  // A provider with no `direction` forced left-to-right inside a right-to-left tree.
  it('keeps the outer direction when it has none of its own', async () => {
    const screen = await render(
      <NebaProvider direction="rtl">
        <NebaProvider defaults={{ size: 'sm' }}>
          <Direction />
        </NebaProvider>
      </NebaProvider>
    );

    await expect.element(screen.getByText('rtl')).toBeInTheDocument();
  });

  // Every provider wrote `<html>`, so a nested preview fought the page's toggle.
  it('leaves the scheme on <html> to the outermost provider', async () => {
    await render(
      <NebaProvider defaultColorScheme="light" storageKey={false}>
        <NebaProvider defaultColorScheme="dark" storageKey={false}>
          <Button>Preview</Button>
        </NebaProvider>
      </NebaProvider>
    );

    await expect.poll(() => root().getAttribute('data-theme')).toBe('light');
  });
});

describe('colorSchemeScript', () => {
  it('reads the same key and writes the same attribute the provider does', () => {
    const script = colorSchemeScript({ storageKey: 'my-key', defaultColorScheme: 'dark' });

    expect(script).toContain('"my-key"');
    expect(script).toContain('data-theme');
    expect(script).toContain('prefers-color-scheme: dark');
  });

  it('turns the browser\u2019s own furniture over with the scheme, as the provider does', () => {
    new Function(colorSchemeScript({ defaultColorScheme: 'dark', storageKey: 'my-key' }))();

    expect(root()).toHaveAttribute('data-theme', 'dark');
    expect(root().style.colorScheme).toBe('dark');
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
