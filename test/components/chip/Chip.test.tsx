import * as React from 'react';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Chip } from 'neba';
import { ko, registerMessages } from 'neba/locales';

/* The library ships English; a `locale` prop answers for a language the
   project has registered. These assertions are about the prop, so the
   languages they name are registered here the way a consumer would. */
registerMessages('ko', ko);

describe('Chip', () => {
  describe('rendering', () => {
    it('renders its label', async () => {
      const screen = await render(<Chip>Draft</Chip>);

      await expect.element(screen.getByText('Draft')).toBeInTheDocument();
    });

    it('is an inert span until it is given something to do', async () => {
      const screen = await render(<Chip data-testid="chip">Draft</Chip>);

      expect(screen.getByTestId('chip').element().tagName).toBe('SPAN');
      expect(screen.getByRole('button').query()).toBeNull();
    });

    it('becomes a real button when it can be clicked', async () => {
      const screen = await render(<Chip onClick={() => {}}>Draft</Chip>);
      const element = screen.getByRole('button', { name: 'Draft' }).element();

      expect(element.tagName).toBe('BUTTON');
      expect(element).toHaveAttribute('type', 'button');
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(<Chip>Before</Chip>);

      await screen.rerender(<Chip>After</Chip>);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <Chip className="my-own-class" data-testid="chip">
          Draft
        </Chip>
      );

      expect(screen.getByTestId('chip').element()).toHaveClass('my-own-class');
    });
  });

  describe('count', () => {
    it('renders a count beside the label', async () => {
      const screen = await render(<Chip count={12}>Errors</Chip>);

      await expect.element(screen.getByText('12')).toBeInTheDocument();
    });

    it('renders a count of zero rather than dropping it', async () => {
      const screen = await render(<Chip count={0}>Errors</Chip>);

      await expect.element(screen.getByText('0')).toBeInTheDocument();
    });

    it('leaves the count out when there is none', async () => {
      const screen = await render(<Chip data-testid="chip">Errors</Chip>);

      expect(screen.getByTestId('chip').element().children).toHaveLength(1);
    });
  });

  describe('delete', () => {
    it('shows the delete button only when onDelete is given', async () => {
      const screen = await render(<Chip>Draft</Chip>);

      expect(screen.getByRole('button', { name: 'Remove Draft' }).query()).toBeNull();

      await screen.rerender(<Chip onDelete={() => {}}>Draft</Chip>);

      await expect
        .element(screen.getByRole('button', { name: 'Remove Draft' }))
        .toBeInTheDocument();
    });

    it('calls onDelete when pressed', async () => {
      const onDelete = vi.fn();
      const screen = await render(<Chip onDelete={onDelete}>Draft</Chip>);

      await screen.getByRole('button', { name: 'Remove Draft' }).click();

      expect(onDelete).toHaveBeenCalledTimes(1);
    });

    it('does not also fire the chip when the chip is clickable', async () => {
      const onClick = vi.fn();
      const onDelete = vi.fn();
      const screen = await render(
        <Chip onClick={onClick} onDelete={onDelete}>
          Draft
        </Chip>
      );

      await screen.getByRole('button', { name: 'Remove Draft' }).click();

      expect(onDelete).toHaveBeenCalledTimes(1);
      expect(onClick).not.toHaveBeenCalled();
    });

    it('takes a custom accessible name for the delete button', async () => {
      const screen = await render(
        <Chip onDelete={() => {}} deleteLabel="Remove tag">
          Draft
        </Chip>
      );

      await expect.element(screen.getByRole('button', { name: 'Remove tag' })).toBeInTheDocument();
    });

    // Every delete button was named "Remove", so a row of chips was a row of
    // buttons a screen reader could not tell apart.
    it('names the delete button after a label that is a string', async () => {
      const screen = await render(
        <>
          <Chip onDelete={() => {}}>Draft</Chip>
          <Chip onDelete={() => {}}>Urgent</Chip>
        </>
      );

      await expect
        .element(screen.getByRole('button', { name: 'Remove Draft' }))
        .toBeInTheDocument();
      await expect
        .element(screen.getByRole('button', { name: 'Remove Urgent' }))
        .toBeInTheDocument();
    });

    it('falls back to the bare word for a label that is not a string', async () => {
      const screen = await render(
        <Chip onDelete={() => {}}>
          <strong>Draft</strong>
        </Chip>
      );

      await expect.element(screen.getByRole('button', { name: 'Remove' })).toBeInTheDocument();
    });
  });

  describe('state', () => {
    it('marks a selected chip as pressed', async () => {
      const screen = await render(
        <Chip selected onClick={() => {}}>
          Draft
        </Chip>
      );

      expect(screen.getByRole('button', { name: 'Draft' }).element()).toHaveAttribute(
        'aria-pressed',
        'true'
      );
    });

    it('is a plain button when it is pressable and says nothing about being on', async () => {
      const screen = await render(<Chip onClick={() => {}}>Draft</Chip>);

      expect(screen.getByRole('button', { name: 'Draft' }).element()).not.toHaveAttribute(
        'aria-pressed'
      );

      await screen.rerender(
        <Chip selected={false} onClick={() => {}}>
          Draft
        </Chip>
      );

      expect(screen.getByRole('button', { name: 'Draft' }).element()).toHaveAttribute(
        'aria-pressed',
        'false'
      );
    });

    it('deepens the surface when selected without changing the colour family', async () => {
      const screen = await render(
        <Chip data-testid="chip" color="success">
          Draft
        </Chip>
      );
      const element = screen.getByTestId('chip').element() as HTMLElement;

      expect(element).not.toHaveClass('bg-(--n-panel-press)');

      await screen.rerender(
        <Chip data-testid="chip" color="success" selected>
          Draft
        </Chip>
      );

      expect(element).toHaveClass('bg-(--n-panel-press)');
      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-success-accent)');
    });

    it('drops the colour family when disabled', async () => {
      const screen = await render(
        <Chip disabled data-testid="chip">
          Draft
        </Chip>
      );

      expect(screen.getByTestId('chip').element()).toHaveClass('text-(--neba-disabled-fg)');
    });

    it('stays a span when disabled even with a click handler', async () => {
      const screen = await render(
        <Chip disabled onClick={() => {}} data-testid="chip">
          Draft
        </Chip>
      );

      expect(screen.getByTestId('chip').element().tagName).toBe('SPAN');
    });
  });

  // A chip that leads somewhere was a button with an `onClick`, which a
  // crawler cannot follow and a reader cannot open in a new tab.
  describe('href', () => {
    it('makes the label a link to the address', async () => {
      const screen = await render(<Chip href="/tags/react">React</Chip>);
      const link = screen.getByRole('link', { name: 'React' });

      await expect.element(link).toHaveAttribute('href', '/tags/react');
      expect(screen.getByRole('button').query()).toBeNull();
    });

    it('answers the pointer the way a pressable chip does', async () => {
      const screen = await render(
        <Chip href="/tags/react" data-testid="chip">
          React
        </Chip>
      );

      expect(screen.getByTestId('chip').element().className).toContain('hover:');
    });

    it('keeps the delete button beside the link rather than inside it', async () => {
      const onDelete = vi.fn();
      const screen = await render(
        <Chip href="/tags/react" onDelete={onDelete}>
          React
        </Chip>
      );
      const link = screen.getByRole('link', { name: 'React' }).element();
      const remove = screen.getByRole('button', { name: 'Remove React' }).element();

      expect(link.contains(remove)).toBe(false);
      expect(link.parentElement).toBe(remove.parentElement);

      await screen.getByRole('button', { name: 'Remove React' }).click();

      expect(onDelete).toHaveBeenCalledTimes(1);
    });

    it('opens a new tab safely, and says that it does', async () => {
      const screen = await render(
        <Chip href="https://react.dev" target="_blank" rel="tag">
          React
        </Chip>
      );
      const link = screen.getByRole('link', { name: 'React (opens in a new tab)' });

      await expect.element(link).toHaveAttribute('target', '_blank');
      await expect.element(link).toHaveAttribute('rel', 'tag noopener noreferrer');
    });

    it('leaves rel as it was given for a link that opens here', async () => {
      const screen = await render(
        <Chip href="/tags/react" rel="tag">
          React
        </Chip>
      );

      await expect
        .element(screen.getByRole('link', { name: 'React' }))
        .toHaveAttribute('rel', 'tag');
    });

    it('is the current one of its set, not a pressed button, when selected', async () => {
      const screen = await render(
        <Chip href="/tags/react" selected>
          React
        </Chip>
      );
      const link = screen.getByRole('link', { name: 'React' });

      await expect.element(link).toHaveAttribute('aria-current', 'true');
      await expect.element(link).not.toHaveAttribute('aria-pressed');
    });

    it('is not a link while disabled', async () => {
      const screen = await render(
        <Chip href="/tags/react" disabled data-testid="chip">
          React
        </Chip>
      );

      await expect.element(screen.getByText('React')).toBeInTheDocument();
      expect(screen.getByRole('link').query()).toBeNull();
      expect(screen.getByTestId('chip').element()).toHaveAttribute('aria-disabled', 'true');
    });

    it('drops an address with a scheme that runs code', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <Chip href="javascript:alert(1)" onClick={onClick}>
          React
        </Chip>
      );

      expect(screen.getByRole('link').query()).toBeNull();
      await expect.element(screen.getByRole('button', { name: 'React' })).toBeInTheDocument();
    });

    it('renders the link through render, keeping the href', async () => {
      const screen = await render(
        <Chip href="/tags/react" render={<a data-router="" />}>
          React
        </Chip>
      );
      const link = screen.getByRole('link', { name: 'React' });

      await expect.element(link).toHaveAttribute('data-router', '');
      await expect.element(link).toHaveAttribute('href', '/tags/react');
    });

    it('hands a router link everything an anchor gets, and keeps the delete button beside it', async () => {
      const RouterLink = React.forwardRef<HTMLAnchorElement, React.ComponentPropsWithoutRef<'a'>>(
        function RouterLink(props, ref) {
          return <a ref={ref} data-router="" {...props} />;
        }
      );
      const screen = await render(
        <Chip
          href="https://react.dev"
          target="_blank"
          rel="tag"
          selected
          onDelete={() => {}}
          render={<RouterLink />}
        >
          React
        </Chip>
      );
      const link = screen.getByRole('link', { name: 'React (opens in a new tab)' });
      const remove = screen.getByRole('button', { name: 'Remove React' }).element();

      await expect.element(link).toHaveAttribute('data-router', '');
      await expect.element(link).toHaveAttribute('rel', 'tag noopener noreferrer');
      await expect.element(link).toHaveAttribute('aria-current', 'true');
      expect(link.element().contains(remove)).toBe(false);
      expect(link.element().parentElement).toBe(remove.parentElement);
    });

    it('drops an address with a scheme that runs code even through render', async () => {
      const screen = await render(
        <Chip href="javascript:alert(1)" render={<a data-router="" />}>
          React
        </Chip>
      );

      await expect.element(screen.getByText('React')).toBeInTheDocument();
      expect(document.querySelector('[data-router]')?.hasAttribute('href')).toBe(false);
    });

    it('is not a link while disabled, whatever render says', async () => {
      const screen = await render(
        <Chip href="/tags/react" render={<a data-router="" />} disabled>
          React
        </Chip>
      );

      await expect.element(screen.getByText('React')).toBeInTheDocument();
      expect(screen.getByRole('link').query()).toBeNull();
      expect(document.querySelector('[data-router]')).toBeNull();
    });

    it('still calls onClick, for a router that takes the navigation over', async () => {
      const onClick = vi.fn((event: React.MouseEvent) => event.preventDefault());
      const screen = await render(
        <Chip href="/tags/react" onClick={onClick}>
          React
        </Chip>
      );

      await screen.getByRole('link', { name: 'React' }).click();

      expect(onClick).toHaveBeenCalledTimes(1);
    });
  });

  describe('style props', () => {
    it('maps colour and elevation onto the token slots', async () => {
      const screen = await render(
        <Chip color="warning" elevation={2} data-testid="chip">
          Draft
        </Chip>
      );
      const element = screen.getByTestId('chip').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-warning-fill)');
      expect(element.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-2)');
    });

    it('sits one step down the control ladder from a Button of the same size', async () => {
      const screen = await render(<Chip data-testid="chip">Draft</Chip>);

      expect(screen.getByTestId('chip').element()).toHaveClass('h-6.5');
    });

    // The shell once used `items-stretch` so the pressable label could fill the
    // chip's height, which knocked the icon, the count plate and the × off the
    // centre line. The label asks for the height itself instead.
    it('centres every part of the chip on one line', async () => {
      const screen = await render(
        <Chip data-testid="chip" count={3} onDelete={() => {}}>
          Draft
        </Chip>
      );

      expect(screen.getByTestId('chip').element()).toHaveClass('items-center');
    });

    it('stretches the pressable label to the full height of the chip', async () => {
      const screen = await render(
        <Chip data-testid="chip" onClick={() => {}}>
          Draft
        </Chip>
      );
      const shell = screen.getByTestId('chip').element();
      const label = screen.getByRole('button', { name: 'Draft' }).element();

      expect(shell).toHaveClass('items-center');
      expect(label).toHaveClass('self-stretch');
    });

    it('changes padding with density but not height', async () => {
      const screen = await render(
        <Chip data-testid="chip" density="compact">
          Draft
        </Chip>
      );
      const element = screen.getByTestId('chip').element();

      expect(element).toHaveClass('h-6.5');
      expect(element).toHaveClass('px-2');
    });

    it('is an outline chip by default', async () => {
      const screen = await render(<Chip data-testid="chip">Draft</Chip>);

      expect(screen.getByTestId('chip').element()).toHaveClass('border');
    });

    it('never applies a transform', async () => {
      const screen = await render(
        <Chip data-testid="chip" onClick={() => {}} count={3} onDelete={() => {}}>
          Draft
        </Chip>
      );
      const element = screen.getByTestId('chip').element();

      expect(element.outerHTML).not.toContain('scale');
      expect(element.outerHTML).not.toContain('translate');
    });
  });

  describe('transition', () => {
    it('takes an entrance animation', async () => {
      const screen = await render(
        <Chip transition="zoom" data-testid="chip">
          Draft
        </Chip>
      );
      const element = screen.getByTestId('chip').element() as HTMLElement;

      expect(element).toHaveClass('neba-anim-scale');
      expect(element.style.getPropertyValue('--n-anim-scale')).toBe('0.4');
    });
  });

  describe('locale', () => {
    it('names the delete button in the language it was given', async () => {
      const screen = await render(
        <Chip locale="ko" onDelete={vi.fn()}>
          디자인
        </Chip>
      );

      await expect.element(screen.getByRole('button', { name: '디자인 삭제' })).toBeInTheDocument();
    });

    it('takes a word of its own over the locale', async () => {
      const screen = await render(
        <Chip locale="ko" deleteLabel="Remove tag" onDelete={vi.fn()}>
          디자인
        </Chip>
      );

      await expect.element(screen.getByRole('button', { name: 'Remove tag' })).toBeInTheDocument();
    });
  });

  /* The count plate carries its own bed rather than another wash on top of the
     chip's: `--n-on-tint` is solved for one wash, and a count on a selected chip
     was reading 3.5:1. */
  describe('the count plate', () => {
    it('is a fill of its own on a chip that is not filled', async () => {
      const screen = await render(
        <Chip variant="text" count={12}>
          Errors
        </Chip>
      );

      expect(screen.getByText('12').element()).toHaveClass('bg-(--n-fill)');
      expect(screen.getByText('12').element()).toHaveClass('text-(--n-on-solid)');
    });

    it('is a hole punched in the fill on one that is', async () => {
      const screen = await render(
        <Chip variant="solid" count={12}>
          Errors
        </Chip>
      );

      expect(screen.getByText('12').element()).toHaveClass('bg-(--neba-glow-on-fill)');
    });
  });
});
