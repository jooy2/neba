/**
 * An empty star's contrast against the sheet a Rating sits on.
 *
 * On a Rating a reader sets, the empty stars are the state of a control, and
 * WCAG 1.4.11 asks 3:1 of that. The colours are resolved and composited by a
 * canvas, which is the same sRGB blend the browser paints with.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Rating } from 'neba';
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

/** Paints the given colours over each other and reads back the pixel. */
function paint(...colors: string[]): [number, number, number] {
  const canvas = document.createElement('canvas');
  canvas.width = 1;
  canvas.height = 1;
  const context = canvas.getContext('2d')!;

  for (const color of colors) {
    context.fillStyle = color;
    context.fillRect(0, 0, 1, 1);
  }

  const [r, g, b] = context.getImageData(0, 0, 1, 1).data;
  return [r, g, b];
}

function luminance(rgb: [number, number, number]): number {
  const [r, g, b] = rgb.map((channel) => {
    const value = channel / 255;
    return value <= 0.04045 ? value / 12.92 : ((value + 0.055) / 1.055) ** 2.4;
  });
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

function contrast(a: [number, number, number], b: [number, number, number]): number {
  const [light, dark] = [luminance(a), luminance(b)].sort((x, y) => y - x);
  return (light + 0.05) / (dark + 0.05);
}

describe('an empty star', () => {
  for (const theme of ['light', 'dark'] as const) {
    // At 40% of the muted ink it came to 1.7:1 on a white page.
    it(`clears 3:1 against the ${theme} sheet on a Rating a reader sets`, async () => {
      const screen = await render(
        <div data-theme={theme} style={{ background: 'var(--neba-surface)' }}>
          <Rating defaultValue={0} data-testid="rating" />
        </div>
      );
      const root = screen.getByTestId('rating').element();
      const star = root.querySelector('svg')!.parentElement as HTMLElement;
      const surface = getComputedStyle(root.parentElement!).backgroundColor;
      const ink = getComputedStyle(star).color;

      expect(contrast(paint(surface, ink), paint(surface))).toBeGreaterThanOrEqual(3);
    });
  }
});
