import { describe, expect, it, vi } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { ColorPicker } from 'neba';
import { ko, registerMessages } from 'neba/locales';

/* `parseColor`, counting its calls and otherwise untouched. How often the
   panel parses is what one test below is about, and nothing on screen says. */
const parses = vi.hoisted(() => ({ count: 0 }));

vi.mock('../../../src/internal/color.js', async (importOriginal) => {
  const original = await importOriginal<typeof import('../../../src/internal/color.js')>();

  return {
    ...original,
    parseColor: (...args: Parameters<typeof original.parseColor>) => {
      parses.count += 1;

      return original.parseColor(...args);
    }
  };
});

/* The library ships English; a `locale` prop answers for a language the
   project has registered. These assertions are about the prop, so the
   languages they name are registered here the way a consumer would. */
registerMessages('ko', ko);

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

    it('names and describes an inline picker as one group', async () => {
      const screen = await render(
        <ColorPicker
          inline
          label="Accent"
          description="Used for links and buttons."
          defaultValue="#ff0000"
        />
      );
      const group = screen.getByRole('group', { name: 'Accent' });

      await expect.element(group).toBeInTheDocument();
      await expect.element(group).toHaveAccessibleDescription('Used for links and buttons.');
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

    // The panel renders on every move of a drag, and each render parsed all
    // sixteen swatches again.
    it('parses its swatches once, not on every move of a rail', async () => {
      const screen = await render(<ColorPicker inline defaultValue="#ff0000" />);
      const rail = screen.getByRole('slider', { name: 'Hue' });

      (rail.element() as HTMLElement).focus();

      const before = parses.count;

      await userEvent.keyboard('{ArrowRight}{ArrowRight}{ArrowRight}{ArrowRight}');
      await expect.element(rail).toHaveAttribute('aria-valuenow', '8');

      // The value written back is read once per move; the swatches never are.
      expect(parses.count - before).toBeLessThanOrEqual(4);
    });

    it('takes a bigger step when shift is held', async () => {
      const screen = await render(<ColorPicker inline defaultValue="#ff0000" />);
      const rail = screen.getByRole('slider', { name: 'Hue' });

      (rail.element() as HTMLElement).focus();
      await userEvent.keyboard('{Shift>}{ArrowRight}{/Shift}');

      expect(rail.element()).toHaveAttribute('aria-valuenow', '20');
    });

    // The rails answered the left and right arrows and nothing else, which is
    // not what a screen reader driving a slider sends.
    it('moves a rail with every key a slider answers', async () => {
      const screen = await render(<ColorPicker inline alpha defaultValue="#ff0000" />);
      const hue = screen.getByRole('slider', { name: 'Hue' });
      const alpha = screen.getByRole('slider', { name: 'Opacity' });

      (hue.element() as HTMLElement).focus();
      await userEvent.keyboard('{ArrowUp}');
      expect(hue.element()).toHaveAttribute('aria-valuenow', '2');
      await userEvent.keyboard('{PageUp}');
      expect(hue.element()).toHaveAttribute('aria-valuenow', '22');
      await userEvent.keyboard('{ArrowDown}');
      expect(hue.element()).toHaveAttribute('aria-valuenow', '20');
      await userEvent.keyboard('{End}');
      expect(hue.element()).toHaveAttribute('aria-valuenow', '360');
      await userEvent.keyboard('{Home}');
      expect(hue.element()).toHaveAttribute('aria-valuenow', '0');

      (alpha.element() as HTMLElement).focus();
      await userEvent.keyboard('{PageDown}');
      expect(alpha.element()).toHaveAttribute('aria-valuenow', '90');
      await userEvent.keyboard('{Home}');
      expect(alpha.element()).toHaveAttribute('aria-valuenow', '0');
    });

    // The square read as two bare numbers, the hue as a bare 217 and the
    // opacity as a bare 55, none of which says what it measures.
    it('reads each slider out as what it measures', async () => {
      const screen = await render(<ColorPicker inline alpha defaultValue="#ff000080" />);

      await expect
        .element(screen.getByRole('slider', { name: 'Saturation and brightness' }))
        .toHaveAttribute('aria-valuetext', 'Saturation 100%, brightness 100%');
      await expect
        .element(screen.getByRole('slider', { name: 'Hue' }))
        .toHaveAttribute('aria-valuetext', '0 degrees');
      await expect
        .element(screen.getByRole('slider', { name: 'Opacity' }))
        .toHaveAttribute('aria-valuetext', '50%');
    });

    it('reads the square in the language it was given', async () => {
      const screen = await render(<ColorPicker inline locale="ko" defaultValue="#ff0000" />);

      await expect
        .element(screen.getByRole('slider', { name: '채도와 명도' }))
        .toHaveAttribute('aria-valuetext', '채도 100%, 명도 100%');
    });

    it('moves the square with the keyboard', async () => {
      const screen = await render(<ColorPicker inline defaultValue="#ff0000" />);
      const area = screen.getByRole('slider', { name: 'Saturation and brightness' });

      (area.element() as HTMLElement).focus();
      await userEvent.keyboard('{ArrowLeft}');
      expect(area.element()).toHaveAttribute('aria-valuenow', '99');
      await userEvent.keyboard('{Home}');
      expect(area.element()).toHaveAttribute('aria-valuenow', '0');
      await userEvent.keyboard('{End}{PageDown}');
      expect(area.element()).toHaveAttribute('aria-valuetext', 'Saturation 100%, brightness 90%');
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
    it('takes the focus into the panel when it opens', async () => {
      const screen = await render(<ColorPicker label="Accent" defaultValue="#ff0000" />);
      const trigger = screen.getByRole('button', { name: 'Accent', exact: false });

      (trigger.element() as HTMLElement).focus();
      await userEvent.keyboard('{Enter}');

      await expect
        .element(screen.getByRole('slider', { name: 'Saturation and brightness' }))
        .toHaveFocus();
    });

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

  describe('an inline picker in a form', () => {
    // The popup's shell took a disabled picker out of the form and held an
    // empty required one back; an inline picker draws no shell, and did
    // neither.
    it('is left out of the form when it is disabled', async () => {
      const screen = await render(
        <form data-testid="form">
          <ColorPicker inline disabled name="brand" defaultValue="#ff0000" />
        </form>
      );
      const form = screen.getByTestId('form').element() as HTMLFormElement;

      expect(new FormData(form).has('brand')).toBe(false);
    });

    it('holds an empty required picker back from a submit', async () => {
      const picker = (value: string) => (
        <form data-testid="form">
          <ColorPicker inline required name="brand" value={value} onValueChange={() => {}} />
        </form>
      );
      const screen = await render(picker(''));
      const form = screen.getByTestId('form').element() as HTMLFormElement;

      expect(form.checkValidity()).toBe(false);

      await screen.rerender(picker('#ff0000'));

      expect(form.checkValidity()).toBe(true);
      expect([...new FormData(form).keys()]).toEqual(['brand']);
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

    // The text field was only ever read-only, so a disabled picker still had a
    // stop in the tab order that could do nothing.
    it('takes the text field out of the tab order when disabled', async () => {
      const screen = await render(<ColorPicker inline disabled />);

      expect(screen.container.querySelector('input[type="text"]')).toBeDisabled();
    });

    it('leaves a read-only text field where the keyboard can reach it', async () => {
      const screen = await render(<ColorPicker inline readOnly defaultValue="#ff0000" />);
      const field = screen.container.querySelector('input[type="text"]');

      expect(field).not.toBeDisabled();
      expect(field).toHaveAttribute('readonly');
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

  describe('label placement', () => {
    it('puts a notched label on the trigger', async () => {
      const screen = await render(<ColorPicker labelPlacement="notch" label="Brand" />);

      expect(screen.container.querySelector('.neba-notch label')).toHaveTextContent('Brand');
    });

    // The swatch is where a floating label would rest.
    it('keeps a floating label in the notch beside the swatch', async () => {
      const screen = await render(<ColorPicker labelPlacement="float" label="Brand" />);

      expect(screen.container.querySelector('.neba-notch')).not.toHaveClass('neba-notch-float');
    });

    it('has no trigger to notch when inline', async () => {
      const screen = await render(<ColorPicker inline labelPlacement="notch" label="Brand" />);

      expect(screen.container.querySelector('.neba-notch')).toBeNull();
      await expect.element(screen.getByText('Brand')).toBeInTheDocument();
    });
  });
});
