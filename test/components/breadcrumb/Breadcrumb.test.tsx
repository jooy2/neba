import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Breadcrumb, BreadcrumbItem } from 'neba';

describe('Breadcrumb', () => {
  describe('rendering', () => {
    it('renders a navigation landmark holding a list', async () => {
      const screen = await render(
        <Breadcrumb>
          <BreadcrumbItem href="/">Home</BreadcrumbItem>
          <BreadcrumbItem>Billing</BreadcrumbItem>
        </Breadcrumb>
      );

      await expect
        .element(screen.getByRole('navigation', { name: 'Breadcrumb' }))
        .toBeInTheDocument();
      await expect.element(screen.getByRole('list')).toBeInTheDocument();
    });

    it('takes the name it is announced by', async () => {
      const screen = await render(
        <Breadcrumb label="Where you are">
          <BreadcrumbItem>Billing</BreadcrumbItem>
        </Breadcrumb>
      );

      await expect
        .element(screen.getByRole('navigation', { name: 'Where you are' }))
        .toBeInTheDocument();
    });

    it('renders a step with an href as a link', async () => {
      const screen = await render(
        <Breadcrumb>
          <BreadcrumbItem href="/settings">Settings</BreadcrumbItem>
          <BreadcrumbItem>Billing</BreadcrumbItem>
        </Breadcrumb>
      );

      await expect
        .element(screen.getByRole('link', { name: 'Settings' }))
        .toHaveAttribute('href', '/settings');
    });

    it('renders a step with a handler as a button', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <Breadcrumb>
          <BreadcrumbItem onClick={onClick}>Settings</BreadcrumbItem>
          <BreadcrumbItem>Billing</BreadcrumbItem>
        </Breadcrumb>
      );

      await screen.getByRole('button', { name: 'Settings' }).click();

      expect(onClick).toHaveBeenCalledTimes(1);
    });

    it('reflects a changed step on re-render', async () => {
      const screen = await render(
        <Breadcrumb>
          <BreadcrumbItem href="/">Home</BreadcrumbItem>
          <BreadcrumbItem>Before</BreadcrumbItem>
        </Breadcrumb>
      );

      await screen.rerender(
        <Breadcrumb>
          <BreadcrumbItem href="/">Home</BreadcrumbItem>
          <BreadcrumbItem>After</BreadcrumbItem>
        </Breadcrumb>
      );

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <Breadcrumb className="my-own-class">
          <BreadcrumbItem className="my-step-class">Home</BreadcrumbItem>
        </Breadcrumb>
      );

      expect(screen.container.querySelector('.my-own-class')).not.toBeNull();
      expect(screen.container.querySelector('.my-step-class')).not.toBeNull();
    });
  });

  describe('the current step', () => {
    // The page you are already on is not somewhere to go, so the last step is
    // not a link even when it is given an href.
    it('marks the last step as the page you are on', async () => {
      const screen = await render(
        <Breadcrumb>
          <BreadcrumbItem href="/">Home</BreadcrumbItem>
          <BreadcrumbItem href="/billing">Billing</BreadcrumbItem>
        </Breadcrumb>
      );

      await expect.element(screen.getByText('Billing')).toBeInTheDocument();
      expect(screen.getByRole('link', { name: 'Billing' }).query()).toBeNull();
      expect(screen.container.querySelector('[aria-current="page"]')).not.toBeNull();
    });

    it('lets a step say it is the current one instead', async () => {
      const screen = await render(
        <Breadcrumb>
          <BreadcrumbItem href="/" current>
            Home
          </BreadcrumbItem>
          <BreadcrumbItem href="/billing">Billing</BreadcrumbItem>
        </Breadcrumb>
      );

      expect(screen.getByRole('link', { name: 'Home' }).query()).toBeNull();
      await expect.element(screen.getByRole('link', { name: 'Billing' })).toBeInTheDocument();
    });

    it('does not answer a disabled step', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <Breadcrumb>
          <BreadcrumbItem onClick={onClick} disabled>
            Settings
          </BreadcrumbItem>
          <BreadcrumbItem>Billing</BreadcrumbItem>
        </Breadcrumb>
      );

      await expect.element(screen.getByText('Settings')).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Settings' }).query()).toBeNull();
      expect(onClick).not.toHaveBeenCalled();
    });
  });

  describe('separators', () => {
    it('draws one separator fewer than there are steps', async () => {
      const screen = await render(
        <Breadcrumb separator="slash">
          <BreadcrumbItem href="/">Home</BreadcrumbItem>
          <BreadcrumbItem href="/settings">Settings</BreadcrumbItem>
          <BreadcrumbItem>Billing</BreadcrumbItem>
        </Breadcrumb>
      );

      await expect
        .poll(() => screen.container.querySelectorAll('li[aria-hidden="true"]').length)
        .toBe(2);
    });

    it('draws whatever it is given', async () => {
      const screen = await render(
        <Breadcrumb separator="»">
          <BreadcrumbItem href="/">Home</BreadcrumbItem>
          <BreadcrumbItem>Billing</BreadcrumbItem>
        </Breadcrumb>
      );

      await expect.poll(() => screen.container.textContent).toContain('»');
    });

    it('draws no separator for a trail of one', async () => {
      const screen = await render(
        <Breadcrumb>
          <BreadcrumbItem>Billing</BreadcrumbItem>
        </Breadcrumb>
      );

      await expect.element(screen.getByText('Billing')).toBeInTheDocument();
      expect(screen.container.querySelectorAll('li[aria-hidden="true"]').length).toBe(0);
    });
  });

  describe('folding', () => {
    it('leaves a short trail alone', async () => {
      const screen = await render(
        <Breadcrumb maxItems={4}>
          <BreadcrumbItem href="/">Home</BreadcrumbItem>
          <BreadcrumbItem href="/a">Projects</BreadcrumbItem>
          <BreadcrumbItem>Billing</BreadcrumbItem>
        </Breadcrumb>
      );

      await expect.element(screen.getByText('Projects')).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Show hidden steps' }).query()).toBeNull();
    });

    it('folds the middle away when the trail is too long', async () => {
      const screen = await render(
        <Breadcrumb maxItems={3}>
          <BreadcrumbItem href="/">Home</BreadcrumbItem>
          <BreadcrumbItem href="/a">Projects</BreadcrumbItem>
          <BreadcrumbItem href="/b">Neba</BreadcrumbItem>
          <BreadcrumbItem href="/c">Settings</BreadcrumbItem>
          <BreadcrumbItem>Billing</BreadcrumbItem>
        </Breadcrumb>
      );

      await expect.element(screen.getByText('Home')).toBeInTheDocument();
      await expect.element(screen.getByText('Billing')).toBeInTheDocument();
      expect(screen.getByText('Neba').query()).toBeNull();
    });

    it('puts the middle back when the fold is pressed', async () => {
      const screen = await render(
        <Breadcrumb maxItems={3}>
          <BreadcrumbItem href="/">Home</BreadcrumbItem>
          <BreadcrumbItem href="/a">Projects</BreadcrumbItem>
          <BreadcrumbItem href="/b">Neba</BreadcrumbItem>
          <BreadcrumbItem>Billing</BreadcrumbItem>
        </Breadcrumb>
      );

      await screen.getByRole('button', { name: 'Show hidden steps' }).click();

      await expect.element(screen.getByText('Projects')).toBeInTheDocument();
      await expect.element(screen.getByText('Neba')).toBeInTheDocument();
    });

    it('keeps the ends the caller asked for', async () => {
      const screen = await render(
        <Breadcrumb maxItems={3} itemsBeforeCollapse={2} itemsAfterCollapse={1}>
          <BreadcrumbItem href="/">Home</BreadcrumbItem>
          <BreadcrumbItem href="/a">Projects</BreadcrumbItem>
          <BreadcrumbItem href="/b">Neba</BreadcrumbItem>
          <BreadcrumbItem href="/c">Settings</BreadcrumbItem>
          <BreadcrumbItem>Billing</BreadcrumbItem>
        </Breadcrumb>
      );

      await expect.element(screen.getByText('Projects')).toBeInTheDocument();
      await expect.element(screen.getByText('Billing')).toBeInTheDocument();
      expect(screen.getByText('Neba').query()).toBeNull();
      expect(screen.getByText('Settings').query()).toBeNull();
    });

    it('leaves the fold as a mark when it does not unfold', async () => {
      const screen = await render(
        <Breadcrumb maxItems={3} expandable={false}>
          <BreadcrumbItem href="/">Home</BreadcrumbItem>
          <BreadcrumbItem href="/a">Projects</BreadcrumbItem>
          <BreadcrumbItem href="/b">Neba</BreadcrumbItem>
          <BreadcrumbItem>Billing</BreadcrumbItem>
        </Breadcrumb>
      );

      await expect.element(screen.getByText('Billing')).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Show hidden steps' }).query()).toBeNull();
    });

    // The fold has to remove more than it replaces, or the trail gets longer.
    it('does not fold a single step away', async () => {
      const screen = await render(
        <Breadcrumb maxItems={2}>
          <BreadcrumbItem href="/">Home</BreadcrumbItem>
          <BreadcrumbItem href="/a">Projects</BreadcrumbItem>
          <BreadcrumbItem>Billing</BreadcrumbItem>
        </Breadcrumb>
      );

      await expect.element(screen.getByText('Projects')).toBeInTheDocument();
    });

    it('marks the last visible step as the current one when folded', async () => {
      const screen = await render(
        <Breadcrumb maxItems={3}>
          <BreadcrumbItem href="/">Home</BreadcrumbItem>
          <BreadcrumbItem href="/a">Projects</BreadcrumbItem>
          <BreadcrumbItem href="/b">Neba</BreadcrumbItem>
          <BreadcrumbItem href="/c">Billing</BreadcrumbItem>
        </Breadcrumb>
      );

      await expect.element(screen.getByText('Billing')).toBeInTheDocument();
      expect(screen.getByRole('link', { name: 'Billing' }).query()).toBeNull();
    });
  });

  describe('locale', () => {
    it('names the trail in the language it was given', async () => {
      const screen = await render(
        <Breadcrumb locale="ko">
          <BreadcrumbItem href="/">홈</BreadcrumbItem>
          <BreadcrumbItem>설정</BreadcrumbItem>
        </Breadcrumb>
      );

      await expect
        .element(screen.getByRole('navigation', { name: '탐색 경로' }))
        .toBeInTheDocument();
    });

    it('names the fold in the language it was given', async () => {
      const screen = await render(
        <Breadcrumb locale="ko" maxItems={3}>
          <BreadcrumbItem href="/">홈</BreadcrumbItem>
          <BreadcrumbItem href="/a">하나</BreadcrumbItem>
          <BreadcrumbItem href="/b">둘</BreadcrumbItem>
          <BreadcrumbItem href="/c">셋</BreadcrumbItem>
          <BreadcrumbItem>넷</BreadcrumbItem>
        </Breadcrumb>
      );

      await expect
        .element(screen.getByRole('button', { name: '숨겨진 단계 보기' }))
        .toBeInTheDocument();
    });

    it('takes a word of its own over the locale', async () => {
      const screen = await render(
        <Breadcrumb locale="ko" label="Trail">
          <BreadcrumbItem href="/">홈</BreadcrumbItem>
          <BreadcrumbItem>설정</BreadcrumbItem>
        </Breadcrumb>
      );

      await expect.element(screen.getByRole('navigation', { name: 'Trail' })).toBeInTheDocument();
    });
  });

  describe('structuredData', () => {
    /** The JSON-LD the trail emitted, parsed. */
    function listData(screen: { container: HTMLElement }) {
      const script = screen.container.querySelector('script[type="application/ld+json"]');

      return script ? JSON.parse(script.textContent ?? '{}') : null;
    }

    it('emits nothing unless it is asked to', async () => {
      const screen = await render(
        <Breadcrumb>
          <BreadcrumbItem href="/">Home</BreadcrumbItem>
          <BreadcrumbItem>Button</BreadcrumbItem>
        </Breadcrumb>
      );

      expect(listData(screen)).toBeNull();
    });

    it('emits a BreadcrumbList with one entry per step', async () => {
      const screen = await render(
        <Breadcrumb structuredData>
          <BreadcrumbItem href="/">Home</BreadcrumbItem>
          <BreadcrumbItem href="/docs">Docs</BreadcrumbItem>
          <BreadcrumbItem>Button</BreadcrumbItem>
        </Breadcrumb>
      );

      expect(listData(screen)).toEqual({
        '@context': 'https://schema.org',
        '@type': 'BreadcrumbList',
        itemListElement: [
          { '@type': 'ListItem', position: 1, name: 'Home', item: '/' },
          { '@type': 'ListItem', position: 2, name: 'Docs', item: '/docs' },
          // No `item`: the step the reader is on has nowhere to point.
          { '@type': 'ListItem', position: 3, name: 'Button' }
        ]
      });
    });

    it('resolves a relative href against baseUrl', async () => {
      const screen = await render(
        <Breadcrumb structuredData baseUrl="https://example.com">
          <BreadcrumbItem href="/">Home</BreadcrumbItem>
          <BreadcrumbItem href="/docs">Docs</BreadcrumbItem>
        </Breadcrumb>
      );

      expect(listData(screen).itemListElement.map((entry: { item: string }) => entry.item)).toEqual(
        ['https://example.com/', 'https://example.com/docs']
      );
    });

    it('leaves an href that is already absolute alone', async () => {
      const screen = await render(
        <Breadcrumb structuredData baseUrl="https://example.com">
          <BreadcrumbItem href="https://docs.example.org/guide">Guide</BreadcrumbItem>
        </Breadcrumb>
      );

      expect(listData(screen).itemListElement[0].item).toBe('https://docs.example.org/guide');
    });

    // What a fold hides is a matter of how much room the row has. The path is
    // the path, so every step is in the data even when three are behind a `…`.
    it('includes the steps a fold is hiding', async () => {
      const screen = await render(
        <Breadcrumb structuredData maxItems={3}>
          <BreadcrumbItem href="/">Home</BreadcrumbItem>
          <BreadcrumbItem href="/a">One</BreadcrumbItem>
          <BreadcrumbItem href="/b">Two</BreadcrumbItem>
          <BreadcrumbItem href="/c">Three</BreadcrumbItem>
          <BreadcrumbItem>Four</BreadcrumbItem>
        </Breadcrumb>
      );

      expect(screen.getByRole('button', { name: 'Show hidden steps' }).query()).not.toBeNull();
      expect(listData(screen).itemListElement.map((entry: { name: string }) => entry.name)).toEqual(
        ['Home', 'One', 'Two', 'Three', 'Four']
      );
    });

    it('reads a step whose label is a node, ignoring its icon', async () => {
      const screen = await render(
        <Breadcrumb structuredData>
          <BreadcrumbItem href="/" startIcon={<svg />}>
            <span>Home</span>
          </BreadcrumbItem>
        </Breadcrumb>
      );

      expect(listData(screen).itemListElement[0].name).toBe('Home');
    });

    // The JSON goes inside a `<script>`, so a label holding a closing tag would
    // otherwise end it and spill the rest of the data onto the page as markup.
    it('escapes a label that could close the script tag', async () => {
      const screen = await render(
        <Breadcrumb structuredData>
          <BreadcrumbItem href="/">{'</script><b>x'}</BreadcrumbItem>
        </Breadcrumb>
      );
      const raw = screen.container.querySelector('script')!.textContent ?? '';

      expect(raw).not.toContain('</script>');
      expect(listData(screen).itemListElement[0].name).toBe('</script><b>x');
    });
  });
});
