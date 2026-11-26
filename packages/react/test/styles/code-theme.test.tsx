/**
 * CodeBlock's `auto` theme, checked against the stylesheet. It has to follow the
 * nearest theme root, and no component test loads CSS.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { CodeBlock } from 'neba';
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

describe('CodeBlock theme="auto"', () => {
  // It followed a dark ancestor through a descendant selector, so a light panel
  // inside a dark page drew a dark block in it.
  it('takes the palette of the nearest theme root', async () => {
    const screen = await render(
      <div className="dark">
        <CodeBlock code="const a = 1" theme="auto" data-testid="outer" />
        <div className="light">
          <CodeBlock code="const a = 1" theme="auto" data-testid="inner" />
        </div>
      </div>
    );
    const ground = (id: string) =>
      getComputedStyle(screen.getByTestId(id).element()).getPropertyValue('--n-code-bg').trim();

    expect(ground('inner')).toBe('oklch(98.4% 0.003 262)');
    expect(ground('outer')).toBe('oklch(19.5% 0.014 262)');
  });
});
