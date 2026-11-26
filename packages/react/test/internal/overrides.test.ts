/**
 * Which properties a caller's `className` sets.
 *
 * Typography and TextLink drop the two-class guard on a property this says the
 * caller set, so a miss here is a caller's utility silently losing, and a false
 * hit is one element losing its guard against a host stylesheet. The cases lean
 * on that asymmetry: anything ambiguous has to come out as a hit.
 */
import { describe, expect, it } from 'vitest';
import {
  COLOR,
  FONT_SIZE,
  FONT_WEIGHT,
  LETTER_SPACING,
  LINE_HEIGHT,
  MARGIN_BOTTOM,
  MARGIN_TOP,
  overriddenBy,
  TEXT_DECORATION_COLOR,
  TEXT_DECORATION_LINE,
  TEXT_DECORATION_THICKNESS,
  TEXT_UNDERLINE_OFFSET,
  TEXT_UNDERLINE_POSITION
} from '../../src/internal/overrides.js';

describe('overriddenBy', () => {
  it('finds nothing in nothing', () => {
    expect(overriddenBy(undefined)).toBe(0);
    expect(overriddenBy('')).toBe(0);
    expect(overriddenBy('  ')).toBe(0);
  });

  it('reads each margin utility as the side it sets', () => {
    expect(overriddenBy('mb-8')).toBe(MARGIN_BOTTOM);
    expect(overriddenBy('mbe-2')).toBe(MARGIN_BOTTOM);
    expect(overriddenBy('mt-4')).toBe(MARGIN_TOP);
    expect(overriddenBy('mbs-2')).toBe(MARGIN_TOP);
    expect(overriddenBy('my-2')).toBe(MARGIN_TOP | MARGIN_BOTTOM);
    expect(overriddenBy('m-0')).toBe(MARGIN_TOP | MARGIN_BOTTOM);
    expect(overriddenBy('-mt-px')).toBe(MARGIN_TOP);
  });

  it('leaves the horizontal margins and look-alike names alone', () => {
    expect(overriddenBy('mx-auto ms-2 me-2 ml-1 mr-1 max-w-prose min-h-0 mask-none')).toBe(0);
  });

  it('reads the text scale as a size, and a modifier as a leading too', () => {
    expect(overriddenBy('text-xl')).toBe(FONT_SIZE);
    expect(overriddenBy('text-9xl')).toBe(FONT_SIZE);
    expect(overriddenBy('text-[2.5rem]')).toBe(FONT_SIZE);
    expect(overriddenBy('text-[clamp(1rem,2vw,2rem)]')).toBe(FONT_SIZE);
    expect(overriddenBy('text-(length:--hero)')).toBe(FONT_SIZE);
    expect(overriddenBy('text-xl/7')).toBe(FONT_SIZE | LINE_HEIGHT);
    expect(overriddenBy('text-[2rem]/[1.1]')).toBe(FONT_SIZE | LINE_HEIGHT);
  });

  it('reads a palette shade, a keyword and a colour value as a colour', () => {
    expect(overriddenBy('text-red-500')).toBe(COLOR);
    expect(overriddenBy('text-red-500/50')).toBe(COLOR);
    expect(overriddenBy('text-white')).toBe(COLOR);
    expect(overriddenBy('text-inherit')).toBe(COLOR);
    expect(overriddenBy('text-[#ff0000]')).toBe(COLOR);
    expect(overriddenBy('text-[oklch(0.6_0.2_30)]')).toBe(COLOR);
    expect(overriddenBy('text-(--brand)')).toBe(COLOR);
    expect(overriddenBy('text-[var(--brand)]')).toBe(COLOR);
    expect(overriddenBy('text-[color:var(--brand)]')).toBe(COLOR);
  });

  // `text-brand` is a colour in one theme and a size in another, and Tailwind
  // reads `text-[large]` as a size and `text-[red]` as a colour.
  it('reads a name it cannot place as both', () => {
    expect(overriddenBy('text-brand')).toBe(COLOR | FONT_SIZE);
    expect(overriddenBy('text-[large]')).toBe(COLOR | FONT_SIZE);
  });

  it('leaves the text utilities that are neither alone', () => {
    expect(
      overriddenBy('text-center text-start text-balance text-nowrap text-ellipsis text-shadow-lg')
    ).toBe(0);
  });

  it('reads the weight, and nothing that is a family or a stretch', () => {
    expect(overriddenBy('font-black')).toBe(FONT_WEIGHT);
    expect(overriddenBy('font-[650]')).toBe(FONT_WEIGHT);
    expect(overriddenBy('font-(--heavy)')).toBe(FONT_WEIGHT);
    expect(overriddenBy('font-display')).toBe(FONT_WEIGHT);
    expect(overriddenBy('font-sans font-mono font-stretch-condensed font-(family:--ui)')).toBe(0);
  });

  it('reads leading, tracking and the line under text', () => {
    expect(overriddenBy('leading-none')).toBe(LINE_HEIGHT);
    expect(overriddenBy('tracking-tight')).toBe(LETTER_SPACING);
    expect(overriddenBy('no-underline')).toBe(TEXT_DECORATION_LINE);
    expect(overriddenBy('line-through')).toBe(TEXT_DECORATION_LINE);
  });

  it('reads the thickness, the colour and the offset of the line', () => {
    expect(overriddenBy('decoration-2')).toBe(TEXT_DECORATION_THICKNESS);
    expect(overriddenBy('decoration-from-font')).toBe(TEXT_DECORATION_THICKNESS);
    expect(overriddenBy('decoration-[3px]')).toBe(TEXT_DECORATION_THICKNESS);
    expect(overriddenBy('decoration-(length:--line)')).toBe(TEXT_DECORATION_THICKNESS);
    expect(overriddenBy('decoration-red-500')).toBe(TEXT_DECORATION_COLOR);
    expect(overriddenBy('decoration-red-500/50')).toBe(TEXT_DECORATION_COLOR);
    expect(overriddenBy('decoration-current')).toBe(TEXT_DECORATION_COLOR);
    expect(overriddenBy('decoration-[#f00]')).toBe(TEXT_DECORATION_COLOR);
    expect(overriddenBy('decoration-(--line)')).toBe(TEXT_DECORATION_COLOR);
    expect(overriddenBy('decoration-brand')).toBe(
      TEXT_DECORATION_THICKNESS | TEXT_DECORATION_COLOR
    );
    expect(overriddenBy('underline-offset-4')).toBe(TEXT_UNDERLINE_OFFSET);
    expect(overriddenBy('decoration-wavy decoration-dotted')).toBe(0);
  });

  it('reads an arbitrary property by its name', () => {
    expect(overriddenBy('[margin-bottom:2rem]')).toBe(MARGIN_BOTTOM);
    expect(overriddenBy('[font:inherit]')).toBe(FONT_SIZE | LINE_HEIGHT | FONT_WEIGHT);
    expect(overriddenBy('[color:red]')).toBe(COLOR);
    expect(overriddenBy('[text-wrap:balance]')).toBe(0);
    expect(overriddenBy('[text-underline-position:under]')).toBe(TEXT_UNDERLINE_POSITION);
    expect(overriddenBy('[text-decoration:none]')).toBe(
      TEXT_DECORATION_LINE | TEXT_DECORATION_THICKNESS | TEXT_DECORATION_COLOR
    );
  });

  it('reads past every variant, including one with a colon inside it', () => {
    expect(overriddenBy('md:mb-4')).toBe(MARGIN_BOTTOM);
    expect(overriddenBy('dark:hover:text-white')).toBe(COLOR);
    expect(overriddenBy('supports-[display:grid]:font-bold')).toBe(FONT_WEIGHT);
    expect(overriddenBy('[&.is-open]:tracking-wide')).toBe(LETTER_SPACING);
  });

  // `mb-8!` wins on its own, and keeping the guard under it is what leaves a
  // call site written with `!` exactly as it was.
  it('does not count an important utility, in either spelling', () => {
    expect(overriddenBy('mb-8!')).toBe(0);
    expect(overriddenBy('md:!text-xl')).toBe(0);
    expect(overriddenBy('mb-8! font-bold')).toBe(FONT_WEIGHT);
  });

  it('adds up every class in the string', () => {
    expect(overriddenBy('text-[2.5rem] leading-none font-black tracking-tight')).toBe(
      FONT_SIZE | LINE_HEIGHT | FONT_WEIGHT | LETTER_SPACING
    );
    expect(overriddenBy('flex gap-2 rounded-md px-3')).toBe(0);
  });
});
