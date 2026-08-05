import { describe, expect, it, vi } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { ColorPicker } from 'neba';

/** The trigger form needs its popup opened before the panel exists. */
async function openPanel(screen: Awaited<ReturnType<typeof render>>) {
  await screen.getByRole('button', { name: /#|Choose/ }).click();
}

describe('ColorPicker', () => {
  describe('rendering', () => {
    it('renders a trigger showing the current colour', async () => {
      const screen = await render(<ColorPicker defaultValue="#ff0000" />);

      await expect.element(screen.getByRole('button', { name: '#ff0000' })).toBeInTheDocument();
    });

    it('renders the panel in the page when inline', async () => {
      const screen = await render(<ColorPicker inline defaultValue="#ff0000" />);

      await expect
        .element(screen.getByRole('slider', { name: 'Saturation and brightness' }))
        .toBeInTheDocument();
      await expect.element(screen.getByRole('slider', { name: 'Hue' })).toBeInTheDocument();
    });

    it('has no opacity rail until it is asked for', async () => {
      const screen = await render(<ColorPicker inline defaultValue="#ff0000" />);

      expect(screen.getByRole('slider', { name: 'Opacity' }).query()).toBeNull();

      await screen.rerender(<ColorPicker inline alpha defaultValue="#ff0000" />);

      await expect.element(screen.getByRole('slider', { name: 'Opacity' })).toBeInTheDocument();
    });

    it('names its parts in the locale it was given', async () => {
      const screen = await render(<ColorPicker inline locale="ko" defaultValue="#ff0000" />);

      await expect.element(screen.getByRole('slider', { name: '색상' })).toBeInTheDocument();
    });

    it('takes one label at a time as an override', async () => {
      const screen = await render(
        <ColorPicker inline labels={{ hue: 'Colour wheel' }} defaultValue="#ff0000" />
      );

      await expect
        .element(screen.getByRole('slider', { name: 'Colour wheel' }))
        .toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <ColorPicker inline className="my-own-class" data-testid="picker" />
      );

      expect(screen.getByTestId('picker').element()).toHaveClass('my-own-class');
    });
  });

  describe('reading the value', () => {
    it('places the hue rail from the value it was given', async () => {
      const screen = await render(<ColorPicker inline defaultValue="#00ff00" />);

      expect(screen.getByRole('slider', { name: 'Hue' }).element()).toHaveAttribute(
        'aria-valuenow',
        '120'
      );
    });

    it('accepts rgb() as readily as hex', async () => {
      const screen = await render(<ColorPicker inline defaultValue="rgb(0, 0, 255)" />);

      expect(screen.getByRole('slider', { name: 'Hue' }).element()).toHaveAttribute(
        'aria-valuenow',
        '240'
      );
    });

    it('accepts hsl() too', async () => {
      const screen = await render(<ColorPicker inline defaultValue="hsl(60, 100%, 50%)" />);

      expect(screen.getByRole('slider', { name: 'Hue' }).element()).toHaveAttribute(
        'aria-valuenow',
        '60'
      );
    });

    it('follows a controlled value', async () => {
      const screen = await render(<ColorPicker inline value="#ff0000" onValueChange={() => {}} />);

      expect(screen.getByRole('slider', { name: 'Hue' }).element()).toHaveAttribute(
        'aria-valuenow',
        '0'
      );

      await screen.rerender(<ColorPicker inline value="#00ffff" onValueChange={() => {}} />);

      expect(screen.getByRole('slider', { name: 'Hue' }).element()).toHaveAttribute(
        'aria-valuenow',
        '180'
      );
    });
  });

  describe('choosing', () => {
    it('reports the swatch that was pressed', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <ColorPicker inline swatches={['#ff0000', '#00ff00']} onValueChange={onValueChange} />
      );

      await screen.getByRole('button', { name: '#00ff00' }).click();

      expect(onValueChange).toHaveBeenCalledWith('#00ff00');
    });

    it('marks the swatch that is currently chosen', async () => {
      const screen = await render(
        <ColorPicker inline swatches={['#ff0000', '#00ff00']} defaultValue="#00ff00" />
      );

      expect(screen.getByRole('button', { name: '#00ff00' }).element()).toHaveAttribute(
        'aria-pressed',
        'true'
      );
      expect(screen.getByRole('button', { name: '#ff0000' }).element()).toHaveAttribute(
        'aria-pressed',
        'false'
      );
    });

    it('moves the hue with the arrow keys', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <ColorPicker inline defaultValue="#ff0000" onValueChange={onValueChange} />
      );
      const rail = screen.getByRole('slider', { name: 'Hue' });

      // Focused rather than clicked: a click would first set the hue to
      // wherever in the rail it landed, and the assertion would be about the
      // click rather than about the key.
      (rail.element() as HTMLElement).focus();
      await userEvent.keyboard('{ArrowRight}');

      expect(onValueChange).toHaveBeenCalled();
      expect(rail.element()).toHaveAttribute('aria-valuenow', '2');
    });

    it('takes a bigger step when shift is held', async () => {
      const screen = await render(<ColorPicker inline defaultValue="#ff0000" />);
      const rail = screen.getByRole('slider', { name: 'Hue' });

      (rail.element() as HTMLElement).focus();
      await userEvent.keyboard('{Shift>}{ArrowRight}{/Shift}');

      expect(rail.element()).toHaveAttribute('aria-valuenow', '20');
    });

    it('writes the value back in the notation it was asked for', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <ColorPicker inline format="rgb" swatches={['#ff0000']} onValueChange={onValueChange} />
      );

      await screen.getByRole('button', { name: '#ff0000' }).click();

      expect(onValueChange).toHaveBeenCalledWith('rgb(255, 0, 0)');
    });

    it('carries the fourth channel only when alpha is on', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <ColorPicker
          inline
          alpha
          format="rgb"
          swatches={['rgba(255, 0, 0, 0.5)']}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'rgba(255, 0, 0, 0.5)' }).click();

      expect(onValueChange).toHaveBeenCalledWith('rgba(255, 0, 0, 0.5)');
    });

    it('takes a colour typed into the field', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<ColorPicker inline onValueChange={onValueChange} />);

      await screen.getByRole('textbox', { name: 'Colour value' }).fill('#123456');

      expect(onValueChange).toHaveBeenLastCalledWith('#123456');
    });

    it('leaves the model alone while half a colour is typed', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <ColorPicker inline defaultValue="#00ff00" onValueChange={onValueChange} />
      );

      await screen.getByRole('textbox', { name: 'Colour value' }).fill('#12');

      expect(onValueChange).not.toHaveBeenCalled();
      expect(screen.getByRole('slider', { name: 'Hue' }).element()).toHaveAttribute(
        'aria-valuenow',
        '120'
      );
    });
  });

  describe('the popup form', () => {
    it('opens the panel when the trigger is pressed', async () => {
      const screen = await render(<ColorPicker defaultValue="#ff0000" />);

      expect(screen.getByRole('slider', { name: 'Hue' }).query()).toBeNull();

      await openPanel(screen);

      await expect.element(screen.getByRole('slider', { name: 'Hue' })).toBeInTheDocument();
    });

    it('reads the placeholder while it is empty', async () => {
      const screen = await render(<ColorPicker value="" onValueChange={() => {}} />);

      await expect
        .element(screen.getByRole('button', { name: 'Choose a colour' }))
        .toBeInTheDocument();
    });

    it('submits under the name it was given', async () => {
      const screen = await render(<ColorPicker name="brand" defaultValue="#ff0000" />);
      const field = screen.container.querySelector('input[name="brand"]');

      expect(field).toHaveValue('#ff0000');
    });
  });

  describe('inert states', () => {
    it('takes the panel out of the tab order when disabled', async () => {
      const screen = await render(<ColorPicker inline disabled />);

      expect(screen.getByRole('slider', { name: 'Hue' }).element()).toHaveAttribute(
        'tabindex',
        '-1'
      );
    });

    it('ignores the arrow keys when read-only', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <ColorPicker inline readOnly defaultValue="#ff0000" onValueChange={onValueChange} />
      );

      screen
        .getByRole('slider', { name: 'Hue' })
        .element()
        .dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true }));

      expect(onValueChange).not.toHaveBeenCalled();
    });
  });
});
