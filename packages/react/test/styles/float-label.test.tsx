/**
 * A `float` label at rest, measured with the stylesheet on.
 *
 * A resting label is set in the control's own text, where the value would be,
 * and it was bounded only by the notch's grid: it ran under a chevron, a pair
 * of steppers or an end icon, and in a field only as wide as its label it was
 * cut to "…" the moment it came down, since the field had been sized by the
 * label at the smaller size it has on the edge.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Combobox, NumberField, TextField } from 'neba';
import standaloneCss from '../../src/standalone.css?inline';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

const LONG = 'The postal code of the delivery address';

/** The label on the notch, which is what a resting label is. */
function labelOf(container: HTMLElement): HTMLElement {
  return container.querySelector<HTMLElement>('.neba-notch-label')!;
}

describe('a float label at rest', () => {
  it('stops short of a TextField’s end icon', async () => {
    const screen = await render(
      <div style={{ width: 200 }}>
        <TextField
          label={LONG}
          labelPlacement="float"
          fullWidth
          endIcon={<svg data-testid="end" viewBox="0 0 10 10" />}
        />
      </div>
    );
    const end = screen.getByTestId('end').element().getBoundingClientRect();

    expect(labelOf(screen.container).getBoundingClientRect().right).toBeLessThanOrEqual(
      end.left + 0.5
    );
  });

  it('stops short of a NumberField’s steppers', async () => {
    const screen = await render(
      <div style={{ width: 200 }}>
        <NumberField label={LONG} labelPlacement="float" fullWidth />
      </div>
    );
    const stepper = screen.container.querySelector('button')!;

    expect(labelOf(screen.container).getBoundingClientRect().right).toBeLessThanOrEqual(
      stepper.getBoundingClientRect().left + 0.5
    );
  });

  it('stops short of a Combobox’s chevron', async () => {
    const screen = await render(
      <div style={{ width: 200 }}>
        <Combobox
          label={LONG}
          labelPlacement="float"
          fullWidth
          items={[{ value: 'seoul', label: 'Seoul' }]}
        />
      </div>
    );
    const chevron = screen.container.querySelector('svg')!.getBoundingClientRect();

    expect(labelOf(screen.container).getBoundingClientRect().right).toBeLessThanOrEqual(
      chevron.left + 0.5
    );
  });

  it('keeps a field that is as wide as its label wide enough to hold it at rest', async () => {
    const screen = await render(
      <TextField label="Postal code of the delivery address" labelPlacement="float" />
    );
    const label = labelOf(screen.container);

    // A pixel for rounding: `scrollWidth` is a whole number and the column is not.
    expect(label.scrollWidth).toBeLessThanOrEqual(label.clientWidth + 1);
  });
});
