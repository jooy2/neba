/**
 * The transition a chart's marks share, checked against the compiled sheet.
 *
 * A class Tailwind cannot read whole in the source is never generated, and
 * nothing fails: the mark simply snaps. No component test loads CSS, so this
 * is the one place that notices.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { markTransitionClasses } from '../../src/internal/chart-frame.js';
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

describe('a chart mark', () => {
  // Written in three string pieces, the class never reached the sheet, and
  // every mark but a pie's and a heatmap's snapped under the crosshair.
  it('moves on opacity, radius and scale', () => {
    const mark = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
    const host = document.createElementNS('http://www.w3.org/2000/svg', 'svg');

    mark.setAttribute('class', markTransitionClasses);
    host.append(mark);
    document.body.append(host);

    try {
      const moved = getComputedStyle(mark).transitionProperty.split(', ');

      expect(moved).toEqual(['opacity', 'r', 'scale']);
    } finally {
      host.remove();
    }
  });
});
