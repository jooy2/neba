/**
 * The ink on every solid fill against that fill, in each theme and each state.
 *
 * `styles.css` says the families were verified per step, hover and active
 * included, and the dark theme was the one that had drifted: its primary hover
 * came to 4.45:1 and its warning active to 4.11:1. The check is made on the
 * tokens themselves and in floating point, because a canvas reads a blend back
 * in whole steps of 1/255, which is enough to round 4.45 up to 4.5. Each fill
 * is laid over the theme's surface at the theme's fill alpha, as a solid
 * control is drawn on a plain page.
 */
import { describe, expect, it } from 'vitest';
import tokens from '../../src/styles.css?raw';

type Oklch = [number, number, number];

const FAMILIES = ['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const;
const STATES = ['solid', 'solid-hover', 'solid-active'] as const;

/** The declarations of the first block that opens with `selector {`. */
function block(selector: string): string {
  const start = tokens.indexOf(`${selector} {`);

  expect(start, selector).toBeGreaterThan(-1);

  return tokens.slice(start, tokens.indexOf('\n}', start));
}

function oklch(declarations: string, name: string): Oklch {
  const match = new RegExp(`${name}:\\s*oklch\\(([\\d.]+)%\\s+([\\d.]+)\\s+([\\d.]+)\\)`).exec(
    declarations
  );

  expect(match, name).not.toBeNull();

  return [Number(match![1]) / 100, Number(match![2]), Number(match![3])];
}

function percent(declarations: string, name: string): number {
  const match = new RegExp(`${name}:\\s*([\\d.]+)%`).exec(declarations);

  expect(match, name).not.toBeNull();

  return Number(match![1]) / 100;
}

/** OKLCH to gamma-encoded sRGB, clamped to the gamut as a browser paints it. */
function srgb([l, c, h]: Oklch): number[] {
  const a = c * Math.cos((h * Math.PI) / 180);
  const b = c * Math.sin((h * Math.PI) / 180);
  const lms = [
    (l + 0.3963377774 * a + 0.2158037573 * b) ** 3,
    (l - 0.1055613458 * a - 0.0638541728 * b) ** 3,
    (l - 0.0894841775 * a - 1.291485548 * b) ** 3
  ];
  const linear = [
    4.0767416621 * lms[0] - 3.3077115913 * lms[1] + 0.2309699292 * lms[2],
    -1.2684380046 * lms[0] + 2.6097574011 * lms[1] - 0.3413193965 * lms[2],
    -0.0041960863 * lms[0] - 0.7034186147 * lms[1] + 1.707614701 * lms[2]
  ];

  return linear.map((value) => {
    const v = Math.min(1, Math.max(0, value));
    return v <= 0.0031308 ? 12.92 * v : 1.055 * v ** (1 / 2.4) - 0.055;
  });
}

function luminance(rgb: number[]): number {
  const [r, g, b] = rgb.map((v) => (v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4));
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

function contrast(a: number[], b: number[]): number {
  const [light, dark] = [luminance(a), luminance(b)].sort((x, y) => y - x);
  return (light + 0.05) / (dark + 0.05);
}

const themes = {
  light: block(":root,\n.light,\n[data-theme='light']"),
  dark: block(".dark,\n[data-theme='dark']"),
  'system dark': block("  :root:not(.light):not([data-theme='light'])")
};

describe('the ink on a solid fill', () => {
  for (const [theme, declarations] of Object.entries(themes)) {
    // The system-dark block repeats the dark one, and both are read, since
    // either can be the one a page is drawn in.
    const surface = declarations.includes('--neba-surface:')
      ? oklch(declarations, '--neba-surface')
      : oklch(themes.light, '--neba-surface');
    const alpha = declarations.includes('--neba-fill-alpha:')
      ? percent(declarations, '--neba-fill-alpha')
      : percent(themes.light, '--neba-fill-alpha');
    const page = srgb(surface);

    for (const family of FAMILIES) {
      for (const state of STATES) {
        it(`clears 4.5:1 on ${family} ${state} in the ${theme} theme`, () => {
          const fill = srgb(oklch(declarations, `--neba-${family}-${state}`));
          const ink = srgb(oklch(declarations, `--neba-${family}-on-solid`));
          const laid = fill.map((v, i) => v * alpha + page[i] * (1 - alpha));

          expect(contrast(ink, laid)).toBeGreaterThanOrEqual(4.5);
        });
      }
    }
  }
});
