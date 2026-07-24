import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button } from 'neba';

describe('Button', () => {
  describe('rendering', () => {
    it('renders its children as the accessible name', async () => {
      const screen = await render(<Button>Save</Button>);

      await expect.element(screen.getByRole('button', { name: 'Save' })).toBeInTheDocument();
    });

    it('renders an interactive native button rather than a generic element', async () => {
      const screen = await render(<Button>Save</Button>);
      const element = screen.getByRole('button').element();

      expect(element.tagName).toBe('BUTTON');
      expect(element).toBeEnabled();
    });

    it('reflects changed children on re-render', async () => {
      const screen = await render(<Button>Before</Button>);

      await screen.rerender(<Button>After</Button>);

      await expect.element(screen.getByRole('button', { name: 'After' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Before' }).query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Button className="my-own-class">Save</Button>);

      expect(screen.getByRole('button').element()).toHaveClass('my-own-class');
    });

    it('forwards unknown props to the underlying button', async () => {
      const screen = await render(<Button type="submit">Save</Button>);

      expect(screen.getByRole('button').element()).toHaveAttribute('type', 'submit');
    });
  });

  describe('style props', () => {
    it('maps color onto the token slots the styles read from', async () => {
      const screen = await render(<Button color="danger">Delete</Button>);
      const element = screen.getByRole('button').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-danger-fill)');
      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-danger-accent)');
    });

    it('defaults to the primary color', async () => {
      const screen = await render(<Button>Save</Button>);
      const element = screen.getByRole('button').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-primary-fill)');
    });

    it('changes height with size but not with density', async () => {
      const screen = await render(<Button size="md">Save</Button>);
      const element = screen.getByRole('button').element();

      expect(element).toHaveClass('h-8');

      await screen.rerender(
        <Button size="md" density="compact">
          Save
        </Button>
      );

      expect(element).toHaveClass('h-8');
    });

    it('changes horizontal padding with density', async () => {
      const screen = await render(<Button size="lg">Save</Button>);
      const element = screen.getByRole('button').element();

      expect(element).toHaveClass('px-5');

      await screen.rerender(
        <Button size="lg" density="compact">
          Save
        </Button>
      );

      expect(element).toHaveClass('px-3');
      expect(element).not.toHaveClass('px-5');
    });

    it('is flat by default and maps elevation onto the shadow scale', async () => {
      const screen = await render(<Button>Save</Button>);
      const element = screen.getByRole('button').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-0)');
      // A flat button still has somewhere to go on hover, and nowhere to sink to.
      expect(element.style.getPropertyValue('--n-elev-hover')).toBe('var(--neba-shadow-1)');
      expect(element.style.getPropertyValue('--n-elev-press')).toBe('var(--neba-shadow-0)');

      await screen.rerender(<Button elevation={2}>Save</Button>);

      expect(element.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-2)');
      expect(element.style.getPropertyValue('--n-elev-hover')).toBe('var(--neba-shadow-3)');
      expect(element.style.getPropertyValue('--n-elev-press')).toBe('var(--neba-shadow-1)');
    });

    it('carries the interaction light only while it can be interacted with', async () => {
      const screen = await render(<Button>Save</Button>);
      const element = screen.getByRole('button').element();

      expect(element).toHaveClass('neba-glow');

      await screen.rerender(<Button disabled>Save</Button>);
      expect(element).not.toHaveClass('neba-glow');

      await screen.rerender(<Button readOnly>Save</Button>);
      expect(element).not.toHaveClass('neba-glow');

      await screen.rerender(<Button loading>Save</Button>);
      expect(element).not.toHaveClass('neba-glow');
    });

    it('writes the pointer position onto the element without re-rendering', async () => {
      const screen = await render(<Button size="xl">Save</Button>);
      const locator = screen.getByRole('button');
      const element = locator.element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-mx')).toBe('');

      await locator.hover();

      expect(element.style.getPropertyValue('--n-mx')).toMatch(/^[\d.]+px$/);
      expect(element.style.getPropertyValue('--n-my')).toMatch(/^[\d.]+px$/);
    });

    it('never applies a transform, so the label cannot move', async () => {
      const screen = await render(<Button elevation={3}>Save</Button>);

      expect(screen.getByRole('button').element().className).not.toContain('scale');
    });

    it('draws a border for the outline variant only', async () => {
      const screen = await render(<Button variant="outline">Save</Button>);
      const element = screen.getByRole('button').element();

      expect(element).toHaveClass('border');

      await screen.rerender(<Button variant="text">Save</Button>);

      expect(element).not.toHaveClass('border');
    });

    it('stretches to the container when fullWidth is set', async () => {
      const screen = await render(<Button fullWidth>Save</Button>);

      expect(screen.getByRole('button').element()).toHaveClass('w-full');
    });

    it('renders as a square when there is no label', async () => {
      const screen = await render(<Button size="md" aria-label="Add" startIcon={<svg />} />);
      const element = screen.getByRole('button', { name: 'Add' }).element();

      expect(element).toHaveClass('w-8');
      expect(element).toHaveClass('px-0');
    });
  });

  describe('icons', () => {
    it('places startIcon before and endIcon after the label', async () => {
      const screen = await render(
        <Button startIcon={<span>[</span>} endIcon={<span>]</span>}>
          Save
        </Button>
      );

      expect(screen.getByRole('button').element().textContent).toBe('[Save]');
    });
  });

  describe('states', () => {
    it('fires onClick when idle', async () => {
      const onClick = vi.fn();
      const screen = await render(<Button onClick={onClick}>Save</Button>);

      await screen.getByRole('button').click();

      expect(onClick).toHaveBeenCalledTimes(1);
    });

    it('lets click events reach a parent handler', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <div onClick={onClick}>
          <Button>Click me</Button>
        </div>
      );

      await screen.getByRole('button', { name: 'Click me' }).click();

      expect(onClick).toHaveBeenCalledTimes(1);
    });

    it('does not fire onClick when disabled', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <Button disabled onClick={onClick}>
          Save
        </Button>
      );
      const element = screen.getByRole('button').element();

      expect(element).toBeDisabled();

      await screen.getByRole('button').click({ force: true });

      expect(onClick).not.toHaveBeenCalled();
    });

    it('marks itself busy and swaps in a spinner while loading', async () => {
      const screen = await render(<Button loading>Save</Button>);
      const element = screen.getByRole('button').element();

      expect(element).toHaveAttribute('aria-busy', 'true');
      expect(element).toHaveAttribute('aria-disabled', 'true');
      expect(element.querySelector('svg')).not.toBeNull();
    });

    it('replaces startIcon with the spinner while loading', async () => {
      const screen = await render(
        <Button loading startIcon={<span>ICON</span>}>
          Save
        </Button>
      );

      expect(screen.getByRole('button').element().textContent).toBe('Save');
    });

    it('stays focusable but does not fire onClick while loading', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <Button loading onClick={onClick}>
          Save
        </Button>
      );
      const element = screen.getByRole('button').element();

      // Not natively disabled, so it keeps its place in the tab order.
      expect(element.hasAttribute('disabled')).toBe(false);

      // `force` because the driver refuses to click an `aria-disabled` element;
      // the point of the test is that our own handler is what blocks it.
      await screen.getByRole('button').click({ force: true });

      expect(onClick).not.toHaveBeenCalled();
    });

    it('does not fire onClick when read-only', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <Button readOnly onClick={onClick}>
          Save
        </Button>
      );
      const element = screen.getByRole('button').element();

      expect(element).toHaveAttribute('aria-disabled', 'true');
      expect(element).not.toHaveAttribute('aria-busy');

      await screen.getByRole('button').click({ force: true });

      expect(onClick).not.toHaveBeenCalled();
    });

    it('keeps its color but goes flat and desaturated when read-only', async () => {
      const screen = await render(<Button elevation={2}>Save</Button>);
      const element = screen.getByRole('button').element() as HTMLElement;

      expect(element).toHaveClass('[box-shadow:var(--n-elev),var(--neba-plate-solid)]');
      expect(element).not.toHaveClass('[filter:saturate(0.55)]');

      await screen.rerender(
        <Button elevation={2} readOnly>
          Save
        </Button>
      );

      // Still the same color family, still the same acrylic edge...
      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-primary-fill)');
      expect(element).toHaveClass('[box-shadow:var(--neba-plate-solid)]');
      // ...but no elevation layer and most of the saturation gone.
      expect(element).not.toHaveClass('[box-shadow:var(--n-elev),var(--neba-plate-solid)]');
      expect(element).toHaveClass('[filter:saturate(0.55)]');
    });

    it('does not let a read-only click reach a parent handler', async () => {
      const onParentClick = vi.fn();
      const screen = await render(
        <div onClick={onParentClick}>
          <Button readOnly>Save</Button>
        </div>
      );

      await screen.getByRole('button').click({ force: true });

      expect(onParentClick).not.toHaveBeenCalled();
    });
  });
});
