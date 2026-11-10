/**
 * Rings and floated labels against the boxes that clip them, measured with the
 * stylesheet on.
 *
 * A box with `overflow` other than `visible` clips at its padding box, and two
 * things are drawn past an element's own edge: a focus ring, and a label
 * floated onto a field's top edge. A component that clips tighter than the
 * inset it draws cuts both off, and only the stylesheet shows it.
 */
import * as React from 'react';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Accordion, AccordionItem, Collapsible, Reasoning, TextField, ToolCall } from 'neba';
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

type Side = 'top' | 'right' | 'bottom' | 'left';

/**
 * The sides on which `rect`, grown by `by`, crosses the clip edge of a box
 * around `element`. A scrolling box is measured against what it scrolls, a
 * clipping one against what it shows.
 */
function clippedSides(element: Element, rect: DOMRect, by: number, sides: Side[]): string[] {
  const found: string[] = [];

  for (let box = element.parentElement; box && box !== document.body; box = box.parentElement) {
    const style = getComputedStyle(box);
    const x = style.overflowX !== 'visible';
    const y = style.overflowY !== 'visible';

    if (!x && !y) {
      continue;
    }

    const scrolls = (value: string) => value === 'auto' || value === 'scroll';
    const edges = box.getBoundingClientRect();
    const top = edges.top + box.clientTop - box.scrollTop;
    const left = edges.left + box.clientLeft - box.scrollLeft;
    const bottom = top + (scrolls(style.overflowY) ? box.scrollHeight : box.clientHeight);
    const right = left + (scrolls(style.overflowX) ? box.scrollWidth : box.clientWidth);
    const crossed: Record<Side, boolean> = {
      top: y && rect.top - by < top - 0.5,
      bottom: y && rect.bottom + by > bottom + 0.5,
      left: x && rect.left - by < left - 0.5,
      right: x && rect.right + by > right + 0.5
    };

    for (const side of sides) {
      if (crossed[side]) {
        found.push(`${side} by ${box.className.slice(0, 60)}`);
      }
    }
  }

  return found;
}

/** The floated label of the field on the page, against everything above it. */
function labelClipping(): string[] {
  const label = document.querySelector('.neba-notch-label')!;

  return clippedSides(label, label.getBoundingClientRect(), 0, ['top']);
}

const field = <TextField label="Name" labelPlacement="float" defaultValue="Draft" fullWidth />;

/** Lets a panel finish opening, which is when its clip settles. */
const settle = () => new Promise((resolve) => setTimeout(resolve, 400));

describe('a floated label at the top of a disclosure panel', () => {
  const panels: Record<string, () => React.ReactElement> = {
    Collapsible: () => (
      <Collapsible title="Shipping" defaultOpen>
        {field}
      </Collapsible>
    ),
    Accordion: () => (
      <Accordion defaultValue={['a']}>
        <AccordionItem value="a" title="Shipping">
          {field}
        </AccordionItem>
      </Accordion>
    ),
    Reasoning: () => <Reasoning defaultOpen>{field}</Reasoning>,
    ToolCall: () => (
      <ToolCall name="search" status="success" defaultOpen>
        {field}
      </ToolCall>
    )
  };

  it.each(Object.keys(panels))('is not clipped in a %s', async (name) => {
    await render(panels[name]!());
    await settle();

    expect(labelClipping()).toEqual([]);
  });

  /**
   * The room above the body lies over the bottom of the trigger, and the panel
   * lets the pointer through it, or the trigger would lose its clicks there.
   */
  it.each(Object.keys(panels))('leaves the whole of a %s trigger to the pointer', async (name) => {
    await render(panels[name]!());
    await settle();
    const trigger = document.querySelector<HTMLElement>('[aria-expanded="true"]')!;
    const rect = trigger.getBoundingClientRect();
    const hit = document.elementFromPoint(rect.left + rect.width / 2, rect.bottom - 2);

    expect(trigger.contains(hit)).toBe(true);
  });
});
