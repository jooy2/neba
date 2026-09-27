/**
 * The chevron on a disclosure's trigger, checked against the compiled sheet.
 *
 * Base UI writes `data-panel-open` on the trigger and on nothing under it, so a
 * chevron that reads the attribute off itself never turns — and no component
 * test loads CSS, so nothing else notices. Five components draw one.
 */
import type * as React from 'react';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Accordion, AccordionItem, Collapsible, Reasoning, Sources, ToolCall } from 'neba';
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

/** The chevron is the last glyph on the trigger, after any status mark. */
function chevronOf(trigger: Element): Element {
  const glyphs = trigger.querySelectorAll('svg');

  return glyphs[glyphs.length - 1].parentElement!;
}

const cases: [string, React.ReactElement][] = [
  [
    'an Accordion',
    <Accordion key="accordion">
      <AccordionItem title="Billing">How we charge.</AccordionItem>
    </Accordion>
  ],
  ['a Collapsible', <Collapsible key="collapsible" title="Advanced" />],
  ['a ToolCall', <ToolCall key="tool" name="search_docs" status="success" result="4 hits" />],
  ['a Reasoning', <Reasoning key="reasoning">Weighing two options.</Reasoning>],
  ['Sources', <Sources key="sources" items={[{ title: 'Design language' }]} />]
];

describe('a disclosure chevron', () => {
  it.each(cases)('turns on %s when its panel opens', async (_, element) => {
    const screen = await render(element);
    const trigger = screen.getByRole('button').first();

    await expect.element(trigger).toHaveAttribute('aria-expanded', 'false');

    const chevron = chevronOf(trigger.element());

    expect(getComputedStyle(chevron).rotate).toBe('none');

    await trigger.click();

    await expect.element(trigger).toHaveAttribute('aria-expanded', 'true');
    await expect.poll(() => getComputedStyle(chevron).rotate).toBe('180deg');
  });
});
