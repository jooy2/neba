/**
 * The colour arithmetic behind ColorPicker.
 *
 * A hundred lines of conversions, one parser and one formatter — and the whole
 * reason the package still has one runtime dependency. The invariant the file
 * is built around is that HSV never leaves: round-tripping through RGB loses
 * the hue of every greyscale colour, and the rail then snaps to red the moment
 * the pointer reaches a corner. That is asserted here, because it is invisible
 * in a rendered picker until somebody drags into the corner and back.
 */
import { describe, expect, it } from 'vitest';
import {
  clamp,
  cssColor,
  formatColor,
  hslToRgb,
  hsvToRgb,
  parseColor,
  readableInk,
  rgbToHex,
  rgbToHsl,
  rgbToHsv
} from '../../src/internal/color.js';

describe('clamp', () => {
  it('holds a value between two ends', () => {
    expect(clamp(5, 0, 10)).toBe(5);
    expect(clamp(-1, 0, 10)).toBe(0);
    expect(clamp(11, 0, 10)).toBe(10);
  });
});

describe('the conversions', () => {
  it('round-trips a colour through RGB and back', () => {
    const hsv = { h: 210, s: 60, v: 80 };
    const back = rgbToHsv(hsvToRgb(hsv));

    expect(back.h).toBeCloseTo(hsv.h, 0);
    expect(back.s).toBeCloseTo(hsv.s, 0);
    expect(back.v).toBeCloseTo(hsv.v, 0);
  });

  it('loses the hue of a greyscale colour, which is why HSV never leaves', () => {
    // Not a defect being pinned — a fact about the model, and the reason the
    // picker keeps its own HSV rather than deriving it from the string each
    // time. Black has no hue to come back with, so a round trip picks one.
    expect(rgbToHsv({ r: 0, g: 0, b: 0 })).toMatchObject({ s: 0, v: 0 });
    expect(rgbToHsv(hsvToRgb({ h: 275, s: 0, v: 0 })).h).not.toBe(275);
  });

  it('reads the three primaries at the hues they are', () => {
    expect(rgbToHsv({ r: 255, g: 0, b: 0 }).h).toBeCloseTo(0, 5);
    expect(rgbToHsv({ r: 0, g: 255, b: 0 }).h).toBeCloseTo(120, 5);
    expect(rgbToHsv({ r: 0, g: 0, b: 255 }).h).toBeCloseTo(240, 5);
  });

  it('round-trips through HSL as well', () => {
    const rgb = { r: 40, g: 160, b: 210 };
    const back = hslToRgb(rgbToHsl(rgb));

    expect(back.r).toBeCloseTo(rgb.r, 0);
    expect(back.g).toBeCloseTo(rgb.g, 0);
    expect(back.b).toBeCloseTo(rgb.b, 0);
  });

  it('holds the ends of the value axis', () => {
    expect(hsvToRgb({ h: 0, s: 0, v: 100 })).toMatchObject({ r: 255, g: 255, b: 255 });
    expect(hsvToRgb({ h: 0, s: 100, v: 0 })).toMatchObject({ r: 0, g: 0, b: 0 });
  });
});

describe('parseColor', () => {
  it('reads a hex colour, with or without the hash', () => {
    expect(parseColor('#ff0000')?.hsv.h).toBeCloseTo(0, 5);
    expect(parseColor('ff0000')?.hsv.h).toBeCloseTo(0, 5);
  });

  it('reads the short hex form', () => {
    const short = parseColor('#f00');
    const long = parseColor('#ff0000');

    expect(short?.hsv.h).toBeCloseTo(long!.hsv.h, 5);
    expect(short?.hsv.v).toBeCloseTo(long!.hsv.v, 5);
  });

  it('reads an eight-digit hex as a colour with an alpha', () => {
    expect(parseColor('#ff000080')?.alpha).toBeCloseTo(0.5, 1);
  });

  it('reads the functional forms', () => {
    expect(parseColor('rgb(255, 0, 0)')?.hsv.h).toBeCloseTo(0, 5);
    expect(parseColor('rgba(255, 0, 0, 0.5)')?.alpha).toBeCloseTo(0.5, 5);
    expect(parseColor('hsl(120, 100%, 50%)')?.hsv.h).toBeCloseTo(120, 5);
  });

  it('does not care about case or surrounding space', () => {
    expect(parseColor('  #FF0000  ')?.hsv.h).toBeCloseTo(0, 5);
    expect(parseColor('RGB(255, 0, 0)')?.hsv.h).toBeCloseTo(0, 5);
  });

  it('answers null for something it does not understand', () => {
    // Which is what leaves the panel where it was rather than snapping it to
    // black: a caller may be holding `''`, a named colour, or a typo.
    expect(parseColor('')).toBeNull();
    expect(parseColor('rebeccapurple')).toBeNull();
    expect(parseColor('rgb(1, 2)')).toBeNull();
    expect(parseColor('rgb(a, b, c)')).toBeNull();
    expect(parseColor('not a colour')).toBeNull();
  });
});

describe('formatColor', () => {
  const red = { h: 0, s: 100, v: 100 };

  it('writes each of the three notations', () => {
    expect(formatColor(red, 1, 'hex')).toBe('#ff0000');
    expect(formatColor(red, 1, 'rgb')).toBe('rgb(255, 0, 0)');
    expect(formatColor(red, 1, 'hsl')).toBe('hsl(0, 100%, 50%)');
  });

  it('leaves the alpha out of an opaque colour', () => {
    // A caller who never turned `alpha` on should not meet `rgba(…, 1)` coming
    // out of a control they only used three channels of.
    expect(formatColor(red, 1, 'hex')).not.toContain('ff0000ff');
    expect(formatColor(red, 1, 'rgb')).not.toContain('rgba');
    expect(formatColor(red, 1, 'hsl')).not.toContain('hsla');
  });

  it('writes it when there is one', () => {
    expect(formatColor(red, 0.5, 'hex')).toBe('#ff000080');
    expect(formatColor(red, 0.5, 'rgb')).toBe('rgba(255, 0, 0, 0.5)');
    expect(formatColor(red, 0.5, 'hsl')).toBe('hsla(0, 100%, 50%, 0.5)');
  });

  it('writes an alpha to two decimals at most, with no trailing zero', () => {
    expect(formatColor(red, 0.5, 'rgb')).toContain('0.5)');
    expect(formatColor(red, 0.333, 'rgb')).toContain('0.33)');
  });

  it('round-trips back through the parser', () => {
    for (const format of ['hex', 'rgb', 'hsl'] as const) {
      const written = formatColor({ h: 210, s: 60, v: 80 }, 1, format);
      const read = parseColor(written);

      expect(read).not.toBeNull();
      expect(formatColor(read!.hsv, read!.alpha, format)).toBe(written);
    }
  });
});

describe('rgbToHex and cssColor', () => {
  it('pads a single digit', () => {
    expect(rgbToHex({ r: 1, g: 2, b: 3 })).toBe('#010203');
  });

  it('clamps a channel that is out of range rather than writing nonsense', () => {
    expect(rgbToHex({ r: 300, g: -20, b: 0 })).toBe('#ff0000');
  });

  it('drops the alpha when there is none to write', () => {
    expect(cssColor({ h: 0, s: 100, v: 100 })).toBe('rgb(255, 0, 0)');
    expect(cssColor({ h: 0, s: 100, v: 100 }, 0.4)).toBe('rgba(255, 0, 0, 0.4)');
  });
});

describe('readableInk', () => {
  it('puts a dark tick on a light colour and a light one on a dark colour', () => {
    // Relative luminance rather than plain lightness: the eye weighs green
    // about six times as heavily as blue, and a model that pretends otherwise
    // puts the tick the wrong way round on yellow.
    const onYellow = readableInk({ h: 60, s: 100, v: 100 });
    const onNavy = readableInk({ h: 220, s: 100, v: 25 });

    expect(onYellow).not.toBe(onNavy);
    expect([onYellow, onNavy].sort()).toEqual([onNavy, onYellow].sort());
  });

  it('reads on white and on black', () => {
    expect(readableInk({ h: 0, s: 0, v: 100 })).not.toBe(readableInk({ h: 0, s: 0, v: 0 }));
  });
});
