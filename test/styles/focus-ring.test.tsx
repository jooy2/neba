/**
 * The focus ring's contrast against the sheet it is drawn on.
 *
 * A ring sits 2px off its control, so the colour beside it is the page. WCAG
 * 1.4.11 asks 3:1 of a focus indicator, and on a Button or a Chip's × the ring
 * is the only one there is. The colours are resolved and composited by a
 * canvas, which is the same sRGB blend the browser paints with.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import standaloneCss from '../../src/standalone.css?inline';

const FAMILIES = ['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const;

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

describe('focus ring', () => {
  for (const theme of ['light', 'dark'] as const) {
    it(`clears 3:1 against the ${theme} sheet in every family`, () => {
      const root = document.createElement('div');
      root.setAttribute('data-theme', theme);
      document.body.append(root);

      try {
        const probe = document.createElement('div');
        root.append(probe);
        probe.style.backgroundColor = 'var(--neba-surface)';
        const surface = getComputedStyle(probe).backgroundColor;

        for (const family of FAMILIES) {
          probe.style.color = `var(--neba-${family}-ring)`;
          const ring = getComputedStyle(probe).color;
          const bed = paint(surface);
          const drawn = paint(surface, ring);

          expect(contrast(drawn, bed), family).toBeGreaterThanOrEqual(3);
        }
      } finally {
        root.remove();
      }
    });
  }
});
