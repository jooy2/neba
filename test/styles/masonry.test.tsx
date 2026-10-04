/**
 * A server-rendered masonry, checked against the stylesheet.
 *
 * Until hydration a masonry draws one deal for every width its columns change
 * at, and only the classes `Show` uses keep all but one of them off the page.
 * A lane is a flex column, so the question is whether those classes beat its
 * own `display` at every width — which no component test can see, since none
 * of them loads CSS.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { renderToString } from 'react-dom/server';
import { Gallery, type NebaGalleryItem } from 'neba';
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

const items: NebaGalleryItem[] = Array.from({ length: 8 }, (_, index) => ({
  src: `/photo-${index}.jpg`,
  alt: `Photo ${index}`,
  ratio: index % 2 ? 2 / 3 : 3 / 2
}));

describe('a server-rendered masonry under the stylesheet', () => {
  it('shows exactly one deal, with as many lanes as the width calls for', () => {
    const host = document.createElement('div');

    host.innerHTML = renderToString(
      <Gallery items={items} layout="masonry" columns={{ xs: 2, md: 3, lg: 4 }} />
    );
    document.body.append(host);

    try {
      const shown = [...host.querySelectorAll(':scope > ul > li')].filter(
        (lane) => getComputedStyle(lane).display !== 'none'
      );
      const expected = matchMedia('(min-width: 64rem)').matches
        ? 4
        : matchMedia('(min-width: 48rem)').matches
          ? 3
          : 2;

      expect(shown).toHaveLength(expected);
    } finally {
      host.remove();
    }
  });
});
