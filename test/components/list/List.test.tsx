import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button, List, ListItem } from 'neba';

describe('List', () => {
  describe('rendering', () => {
    it('renders a list of its items', async () => {
      const screen = await render(
        <List>
          <ListItem>Production</ListItem>
          <ListItem>Staging</ListItem>
        </List>
      );

      await expect.element(screen.getByRole('list')).toBeInTheDocument();
      expect(screen.getByRole('listitem').elements()).toHaveLength(2);
    });

    // Tailwind's reset takes the bullets off every `<ul>`, and Safari takes the
    // list semantics off with them.
    it('says it is a list out loud', async () => {
      const screen = await render(
        <List>
          <ListItem>Production</ListItem>
        </List>
      );

      expect(screen.getByRole('list').element()).toHaveAttribute('role', 'list');
    });

    it('renders something else when asked', async () => {
      const screen = await render(
        <List render={<ol />}>
          <ListItem>First</ListItem>
        </List>
      );

      expect(screen.getByRole('list').element().tagName).toBe('OL');
    });

    it('renders a description under the label', async () => {
      const screen = await render(
        <List>
          <ListItem description="Last deployed 4 minutes ago">Production</ListItem>
        </List>
      );

      await expect.element(screen.getByText('Last deployed 4 minutes ago')).toBeInTheDocument();
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(
        <List>
          <ListItem>Before</ListItem>
        </List>
      );

      await screen.rerender(
        <List>
          <ListItem>After</ListItem>
        </List>
      );

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <List className="my-own-class">
          <ListItem className="my-row-class">Production</ListItem>
        </List>
      );

      expect(screen.getByRole('list').element()).toHaveClass('my-own-class');
      expect(screen.getByRole('listitem').element()).toHaveClass('my-row-class');
    });
  });

  describe('rows that do something', () => {
    it('is an inert li until it is given something to do', async () => {
      const screen = await render(
        <List>
          <ListItem>Production</ListItem>
        </List>
      );

      expect(screen.getByRole('button').query()).toBeNull();
      expect(screen.getByRole('link').query()).toBeNull();
    });

    it('becomes a real button when it can be clicked', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <List>
          <ListItem onClick={onClick}>Production</ListItem>
        </List>
      );

      await screen.getByRole('button', { name: 'Production' }).click();

      expect(onClick).toHaveBeenCalledTimes(1);
    });

    it('becomes a real link when it is given an href', async () => {
      const screen = await render(
        <List>
          <ListItem href="#production">Production</ListItem>
        </List>
      );

      await expect
        .element(screen.getByRole('link', { name: 'Production' }))
        .toHaveAttribute('href', '#production');
    });

    it('stays inert when disabled, even with a click handler', async () => {
      const screen = await render(
        <List>
          <ListItem disabled onClick={() => {}}>
            Production
          </ListItem>
        </List>
      );

      expect(screen.getByRole('button').query()).toBeNull();
      expect(screen.getByRole('listitem').element()).toHaveTextContent('Production');
    });

    // A row that both navigates and holds a switch has two things to press, and
    // one of them cannot be nested inside the other.
    it('keeps the action out of the pressable area', async () => {
      const onClick = vi.fn();
      const onAction = vi.fn();
      const screen = await render(
        <List>
          <ListItem onClick={onClick} action={<Button onClick={onAction}>Redeploy</Button>}>
            Production
          </ListItem>
        </List>
      );

      await screen.getByRole('button', { name: 'Redeploy' }).click();

      expect(onAction).toHaveBeenCalledTimes(1);
      expect(onClick).not.toHaveBeenCalled();
    });
  });

  describe('selection', () => {
    it('marks a selected link as the current page', async () => {
      const screen = await render(
        <List>
          <ListItem selected href="#production">
            Production
          </ListItem>
        </List>
      );

      await expect.element(screen.getByRole('link')).toHaveAttribute('aria-current', 'page');
    });

    it('marks a selected button as the chosen one', async () => {
      const screen = await render(
        <List>
          <ListItem selected onClick={() => {}}>
            Production
          </ListItem>
        </List>
      );

      await expect.element(screen.getByRole('button')).toHaveAttribute('aria-current', 'true');
    });

    it('deepens the surface when selected', async () => {
      const screen = await render(
        <List>
          <ListItem onClick={() => {}}>Production</ListItem>
        </List>
      );

      expect(screen.getByRole('button').element()).not.toHaveClass('bg-(--n-soft-press)');

      await screen.rerender(
        <List>
          <ListItem selected onClick={() => {}}>
            Production
          </ListItem>
        </List>
      );

      expect(screen.getByRole('button').element()).toHaveClass('bg-(--n-soft-press)');
    });
  });

  describe('what the row inherits', () => {
    it('takes its size from the list rather than from itself', async () => {
      const screen = await render(
        <List size="xl">
          <ListItem onClick={() => {}}>Production</ListItem>
        </List>
      );

      expect(screen.getByRole('button').element()).toHaveClass('px-6');
    });

    it('takes its density from the list', async () => {
      const screen = await render(
        <List density="compact">
          <ListItem onClick={() => {}}>Production</ListItem>
        </List>
      );

      expect(screen.getByRole('button').element()).toHaveClass('px-2.5');
    });

    // A row cannot be a floating tile and a ruled line at the same time, so
    // turning the dividers on squares the rows off and drops the sheet's inset.
    it('squares the rows off when the list is ruled', async () => {
      const screen = await render(
        <List>
          <ListItem onClick={() => {}}>Production</ListItem>
        </List>
      );

      expect(screen.getByRole('list').element()).toHaveClass('p-1');
      expect(screen.getByRole('button').element().className).toContain('rounded');

      await screen.rerender(
        <List dividers>
          <ListItem onClick={() => {}}>Production</ListItem>
        </List>
      );

      expect(screen.getByRole('list').element()).not.toHaveClass('p-1');
      expect(screen.getByRole('button').element().className).not.toContain('rounded');
    });
  });

  describe('style props', () => {
    it('keeps the sheet undyed while colouring the edge', async () => {
      const screen = await render(
        <List color="success">
          <ListItem>Production</ListItem>
        </List>
      );
      const element = screen.getByRole('list').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-panel')).toBe('var(--neba-panel)');
      expect(element.style.getPropertyValue('--n-line')).toBe('var(--neba-success-line)');
    });

    it('maps elevation onto the token slots', async () => {
      const screen = await render(
        <List elevation={3}>
          <ListItem>Production</ListItem>
        </List>
      );
      const element = screen.getByRole('list').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-3)');
    });

    it('is an outline list by default', async () => {
      const screen = await render(
        <List>
          <ListItem>Production</ListItem>
        </List>
      );

      expect(screen.getByRole('list').element()).toHaveClass('border');
    });

    it('never applies a transform', async () => {
      const screen = await render(
        <List dividers>
          <ListItem onClick={() => {}} description="Two minutes ago" selected>
            Production
          </ListItem>
        </List>
      );

      expect(screen.getByRole('list').element().outerHTML).not.toContain('translate');
    });
  });
});
