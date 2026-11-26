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
  Fieldset,
  Flex,
  Form,
  LineChart,
  List,
  ListItem,
  NebaProvider,
  ProgressBox,
  Radio,
  RadioGroup,
  Select,
  TextField,
  Toggle,
  ToggleGroup,
  TreeSelect,
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

  // Both take the axes through a rest spread or a prop handed further down, so
  // only a declaration that named them would have shown they were missed.
  it('reaches a TreeSelect’s variant and density, and a ProgressBox’s locale', async () => {
    const items = [{ value: 'docs', label: 'Docs' }];
    const screen = await render(
      <>
        <NebaProvider defaults={{ variant: 'solid', density: 'compact', locale: 'ar-EG' }}>
          <TreeSelect label="Provided" items={items} />
          <ProgressBox label="Provided upload" value={40} showValue format={{}} />
        </NebaProvider>
        <TreeSelect label="Bare" items={items} />
        <ProgressBox label="Bare upload" value={40} showValue format={{}} />
      </>
    );
    // The variant is drawn on the shell around the trigger, and the density
    // pads it.
    const shellOf = (name: string) =>
      screen.getByRole('button', { name, exact: false }).element().parentElement?.className;

    expect(shellOf('Provided')).not.toBe(shellOf('Bare'));
    await expect.element(screen.getByText('٤٠')).toBeInTheDocument();
    await expect.element(screen.getByText('40', { exact: true })).toBeInTheDocument();
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

  // How far apart a product stands its fields is one decision, made once.
  it('stands the fields of every Form and Fieldset the product’s spacing apart', async () => {
    const screen = await render(
      <NebaProvider defaults={{ spacing: 6 }}>
        <Form aria-label="Sign up" size="xs">
          <TextField label="Email" />
        </Form>
        <Fieldset legend="Address">
          <TextField label="Street" />
        </Fieldset>
      </NebaProvider>
    );
    const form = screen.getByRole('form').element() as HTMLElement;
    const group = screen.getByRole('group', { name: 'Address' }).element() as HTMLElement;

    expect(form.style.gap).toBe('1.5rem');
    expect(form).not.toHaveClass('gap-1.5');
    expect(group.style.gap).toBe('1.5rem');
  });

  it('loses the spacing to the call site', async () => {
    const screen = await render(
      <NebaProvider defaults={{ spacing: 6 }}>
        <Form aria-label="Sign up" spacing={2}>
          <TextField label="Email" />
        </Form>
      </NebaProvider>
    );

    expect((screen.getByRole('form').element() as HTMLElement).style.gap).toBe('0.5rem');
  });

  // The options of one question and the rows of a list are a different
  // distance from two fields, and a layout's gutter is not a form's at all.
  it('leaves radio options, list rows and layout gutters on their own spacing', async () => {
    const screen = await render(
      <>
        <NebaProvider defaults={{ spacing: 6 }}>
          <RadioGroup label="Plan">
            <Radio value="team" label="Team" />
          </RadioGroup>
          <List>
            <ListItem>Production</ListItem>
          </List>
          <Flex data-testid="inside">
            <span>a</span>
          </Flex>
          <Chip>tag</Chip>
        </NebaProvider>
        <Flex data-testid="outside">
          <span>a</span>
        </Flex>
      </>
    );

    expect((screen.getByRole('radiogroup').element() as HTMLElement).style.gap).toBe('');
    expect((screen.getByRole('list').element() as HTMLElement).style.gap).toBe('');
    expect(screen.getByTestId('inside').element().getAttribute('style')).toBe(
      screen.getByTestId('outside').element().getAttribute('style')
    );
    expect(screen.container.querySelector('[spacing]')).toBeNull();
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

  // An inline handler is a new function on every render of whatever renders
  // the provider, and it used to make a new context value with it.
  it('does not re-render its readers for a new inline onColorSchemeChange', async () => {
    let commits = 0;
    const Reader = memo(function Reader() {
      return (
        <Profiler id="reader" onRender={() => (commits += 1)}>
          <Switcher />
        </Profiler>
      );
    });
    const seen: string[] = [];
    const Page = ({ tick }: { tick: number }) => (
      <NebaProvider storageKey={false} onColorSchemeChange={(next) => seen.push(`${tick}:${next}`)}>
        <Reader />
      </NebaProvider>
    );
    const screen = await render(<Page tick={0} />);
    const before = commits;

    await screen.rerender(<Page tick={1} />);

    expect(commits).toBe(before);

    // And the handler a change reaches is still the newest one.
    await screen.getByRole('button', { name: 'Dark' }).click();

    expect(seen).toEqual(['1:dark']);
  });

  describe('when <html> was showing another scheme', () => {
    function watchWarnings() {
      return vi.spyOn(console, 'warn').mockImplementation(() => {});
    }

    const schemeWarnings = (warn: ReturnType<typeof watchWarnings>) =>
      warn.mock.calls.filter(([message]) => String(message).includes('colorSchemeScript()'));

    it('says so when the page shows one scheme and the provider resolves the other', async () => {
      const warn = watchWarnings();

      try {
        root().setAttribute('data-theme', 'light');

        await render(
          <NebaProvider defaultColorScheme="dark">
            <Switcher />
          </NebaProvider>
        );

        await expect.poll(() => root().getAttribute('data-theme')).toBe('dark');
        expect(schemeWarnings(warn)).toHaveLength(1);
        expect(String(schemeWarnings(warn)[0][0])).toContain('shows "light"');
      } finally {
        warn.mockRestore();
      }
    });

    it('says so when the page has no scheme and the provider asks for one', async () => {
      const warn = watchWarnings();

      try {
        await render(
          <NebaProvider defaultColorScheme="dark">
            <Switcher />
          </NebaProvider>
        );

        await expect.poll(() => root().getAttribute('data-theme')).toBe('dark');
        expect(schemeWarnings(warn)).toHaveLength(1);
        expect(String(schemeWarnings(warn)[0][0])).toContain('has no data-theme');
      } finally {
        warn.mockRestore();
      }
    });

    // A page with no scheme of its own follows the system, which is what
    // `system` resolves to.
    it('says nothing for `system` on a page with no scheme of its own', async () => {
      const warn = watchWarnings();

      try {
        await render(
          <NebaProvider>
            <Switcher />
          </NebaProvider>
        );

        await expect.poll(() => root().getAttribute('data-theme')).not.toBeNull();
        expect(schemeWarnings(warn)).toHaveLength(0);
      } finally {
        warn.mockRestore();
      }
    });

    it('says nothing after the script ran with the same options', async () => {
      const warn = watchWarnings();

      try {
        localStorage.setItem('my-key', 'dark');
        // The script as a page inlines it in <head>, run before the provider.
        new Function(colorSchemeScript({ storageKey: 'my-key', defaultColorScheme: 'light' }))();

        const screen = await render(
          <NebaProvider storageKey="my-key" defaultColorScheme="light">
            <Switcher />
          </NebaProvider>
        );

        await expect.element(screen.getByText('dark → dark')).toBeInTheDocument();
        expect(root().getAttribute('data-theme')).toBe('dark');
        expect(schemeWarnings(warn)).toHaveLength(0);
      } finally {
        warn.mockRestore();
      }
    });

    it('asks only when it mounts, not when the reader changes the scheme', async () => {
      const warn = watchWarnings();

      try {
        const screen = await render(
          <NebaProvider defaultColorScheme="light">
            <Switcher />
          </NebaProvider>
        );

        await expect.poll(() => root().getAttribute('data-theme')).toBe('light');
        warn.mockClear();

        await screen.getByRole('button', { name: 'Dark' }).click();

        await expect.poll(() => root().getAttribute('data-theme')).toBe('dark');
        expect(schemeWarnings(warn)).toHaveLength(0);
      } finally {
        warn.mockRestore();
      }
    });
  });
});

describe('direction', () => {
  it('writes it onto the document', async () => {
    // A document with no `dir` of its own is what the warning below is about.
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});

    try {
      await render(
        <NebaProvider direction="rtl">
          <Button>Ship</Button>
        </NebaProvider>
      );

      await expect.poll(() => root().getAttribute('dir')).toBe('rtl');
    } finally {
      warn.mockRestore();
    }
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

  /*
   * `dir` is written once the provider has mounted, so a document that does not
   * already run its way is painted the other way round first, and mirrors when
   * the page hydrates. Only the HTML itself can prevent that, and only the
   * developer can put it there.
   */
  describe('when the document runs the other way', () => {
    function watchWarnings() {
      return vi.spyOn(console, 'warn').mockImplementation(() => {});
    }

    it('says so, and still writes it', async () => {
      const warn = watchWarnings();

      try {
        await render(
          <NebaProvider direction="rtl">
            <Button>Ship</Button>
          </NebaProvider>
        );

        await expect.poll(() => root().getAttribute('dir')).toBe('rtl');
        expect(warn).toHaveBeenCalledTimes(1);
        expect(String(warn.mock.calls[0][0])).toContain('dir="rtl"');
      } finally {
        warn.mockRestore();
      }
    });

    it('says nothing when the document already runs that way', async () => {
      root().setAttribute('dir', 'rtl');
      const warn = watchWarnings();

      try {
        await render(
          <NebaProvider direction="rtl">
            <Button>Ship</Button>
          </NebaProvider>
        );

        await expect.poll(() => root().getAttribute('dir')).toBe('rtl');
        expect(warn).not.toHaveBeenCalled();
      } finally {
        warn.mockRestore();
      }
    });

    // A document with no `dir` already runs left to right, so nothing turns.
    it('says nothing for left to right on a document with no dir', async () => {
      const warn = watchWarnings();

      try {
        await render(
          <NebaProvider direction="ltr">
            <Button>Ship</Button>
          </NebaProvider>
        );

        await expect.poll(() => root().getAttribute('dir')).toBe('ltr');
        expect(warn).not.toHaveBeenCalled();
      } finally {
        warn.mockRestore();
      }
    });

    // A direction changed later is the page being switched, not one that loaded
    // the wrong way round.
    it('asks only when it mounts', async () => {
      root().setAttribute('dir', 'rtl');
      const warn = watchWarnings();

      try {
        const screen = await render(
          <NebaProvider direction="rtl">
            <Button>Ship</Button>
          </NebaProvider>
        );

        await screen.rerender(
          <NebaProvider direction="ltr">
            <Button>Ship</Button>
          </NebaProvider>
        );

        await expect.poll(() => root().getAttribute('dir')).toBe('ltr');
        expect(warn).not.toHaveBeenCalled();
      } finally {
        warn.mockRestore();
      }
    });
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

  it('keeps the outer spacing inside a provider that sets something else', async () => {
    const screen = await render(
      <NebaProvider defaults={{ spacing: 7 }}>
        <NebaProvider defaults={{ size: 'sm' }}>
          <Form aria-label="Sign up">
            <TextField label="Email" />
          </Form>
        </NebaProvider>
      </NebaProvider>
    );

    expect((screen.getByRole('form').element() as HTMLElement).style.gap).toBe('1.75rem');
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
    root().setAttribute('dir', 'rtl');

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
