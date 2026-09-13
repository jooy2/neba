/**
 * A code block's line numbers and prompts, as the accessibility tree meets them.
 *
 * Both are generated content, which a screen reader reads like any other text,
 * so each is given the empty alternative text `content` takes after a slash.
 * Checked through the CSSOM: what matters is that the declaration the browser
 * kept is the one with the alternative.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
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

function ruleFor(selector: string): CSSStyleRule | undefined {
  return [...(sheet.sheet?.cssRules ?? [])].find(
    (rule): rule is CSSStyleRule => rule instanceof CSSStyleRule && rule.selectorText === selector
  );
}

describe('code lines', () => {
  it('gives the line number and the prompt no alternative text to be read', () => {
    for (const selector of [
      '.neba-code-line[data-line]::before',
      '.neba-code-line[data-prompt]::after'
    ]) {
      const content = ruleFor(selector)?.style.getPropertyValue('content');

      expect(content, selector).toMatch(/^attr\(data-(line|prompt)\) \/ (''|"")$/);
    }
  });
});
