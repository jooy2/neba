/**
 * The forced-colours block, checked against the rules and the parts they reach.
 *
 * No runner here puts a browser in a forced palette, so this asserts what can
 * be seen from outside it: that the rules exist behind the media query, and
 * that the parts they name carry the hooks the rules select on — a hook a
 * component stopped writing would leave a rule that never matches anything.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  BottomNavigation,
  BottomNavigationItem,
  Button,
  Calendar,
  ProgressLinear,
  Radio,
  RadioGroup,
  Segment,
  SegmentedButton,
  Slider,
  Switch,
  Toggle
} from 'neba';
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

/** Every style rule under a grouping rule, however deeply it is nested. */
function styleRulesIn(rules: CSSRuleList): CSSStyleRule[] {
  return [...rules].flatMap((rule) =>
    rule instanceof CSSStyleRule
      ? [rule]
      : rule instanceof CSSGroupingRule
        ? styleRulesIn(rule.cssRules)
        : []
  );
}

function forcedRules(): CSSStyleRule[] {
  return [...(sheet.sheet?.cssRules ?? [])]
    .filter(
      (rule): rule is CSSMediaRule =>
        rule instanceof CSSMediaRule && rule.conditionText.includes('forced-colors')
    )
    .flatMap((media) => styleRulesIn(media.cssRules));
}

describe('forced colours', () => {
  it('gives every part that says something by colour or shadow a rule of its own', async () => {
    const rules = forcedRules();
    const screen = await render(
      <>
        <Button>Save</Button>
        <Switch aria-label="Wi-Fi" defaultChecked />
        <ProgressLinear aria-label="Upload" value={40} />
        <Slider aria-label="Volume" defaultValue={40} />
      </>
    );
    const root = screen.container;

    const parts = [
      root.querySelector('button'),
      root.querySelector('[role="switch"]'),
      root.querySelector('[role="switch"] > *'),
      root.querySelector('.neba-progress-indicator'),
      root.querySelector('.neba-progress-track'),
      root.querySelector('.neba-slider-indicator'),
      root.querySelector('.neba-slider-rail'),
      root.querySelector('.neba-slider-thumb')
    ];

    for (const part of parts) {
      expect(part, 'a part the block names').not.toBeNull();
      expect(
        rules.some((rule) => part!.matches(rule.selectorText)),
        part!.outerHTML.slice(0, 80)
      ).toBe(true);
    }
  });

  // Each said which option was chosen only through a fill, which a forced
  // palette repaints the colour of everything around it.
  it('marks the chosen option of a set in the system highlight', async () => {
    const rules = forcedRules();
    const screen = await render(
      <>
        <RadioGroup aria-label="Plan" defaultValue="pro">
          <Radio value="free" label="Free" />
          <Radio value="pro" label="Pro" />
        </RadioGroup>
        <SegmentedButton aria-label="View" defaultValue="grid">
          <Segment value="list">List</Segment>
          <Segment value="grid">Grid</Segment>
        </SegmentedButton>
        <Toggle defaultPressed>Bold</Toggle>
        <Calendar defaultValue={new Date(2026, 8, 14)} defaultMonth={new Date(2026, 8, 1)} />
        <BottomNavigation label="Main" defaultValue="home">
          <BottomNavigationItem value="home">Home</BottomNavigationItem>
          <BottomNavigationItem value="search">Search</BottomNavigationItem>
        </BottomNavigation>
      </>
    );
    const highlighted = (element: Element) =>
      rules.some(
        (rule) =>
          element.matches(rule.selectorText) &&
          rule.style.getPropertyValue('background-color') === 'highlight'
      );

    await expect.element(screen.getByRole('radio', { name: 'Pro' })).toBeInTheDocument();

    const parts = [
      screen.container.querySelector('.neba-radio-dot'),
      screen.getByRole('radio', { name: 'Grid' }).element(),
      screen.getByRole('button', { name: 'Bold' }).element(),
      screen.container.querySelector('[role="gridcell"][aria-selected="true"]'),
      screen.getByRole('button', { name: 'Home' }).element()
    ];

    for (const part of parts) {
      expect(part, 'a chosen part').not.toBeNull();
      expect(highlighted(part!), part!.outerHTML.slice(0, 80)).toBe(true);
    }

    // And only the chosen one.
    expect(highlighted(screen.getByRole('radio', { name: 'List' }).element())).toBe(false);
    expect(highlighted(screen.getByRole('button', { name: 'Search' }).element())).toBe(false);
  });
});
