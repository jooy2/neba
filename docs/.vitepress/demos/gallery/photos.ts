/**
 * The set every Gallery demo draws from — twelve pictures with the metadata a
 * gallery actually carries: a title, a line about it, and the proportion the
 * file is in.
 *
 * The proportions are written down rather than measured, which is what lets a
 * masonry and a justified row be right in the first frame. The files are in
 * `docs/public/samples/photos`, which the rest of the documentation draws on
 * too; see the README beside them for where they came from.
 */
import type { NebaGalleryItem } from 'neba';

const base = '/samples/photos';

export const photos: NebaGalleryItem[] = [
  {
    src: `${base}/alpine-lake-dawn.jpg`,
    alt: 'A still alpine lake with the first light on the far ridge',
    title: 'Alpine lake, dawn',
    description: 'Ronda · 05:41',
    ratio: '3 / 2'
  },
  {
    src: `${base}/lighthouse-cliff-wildflowers.jpg`,
    alt: 'A lighthouse on a cliff above a bank of wildflowers',
    title: 'Cliff light',
    description: 'Cape Marren · June',
    ratio: '2 / 3'
  },
  {
    src: `${base}/ceramic-bowl-citrus.jpg`,
    alt: 'Citrus fruit in a glazed ceramic bowl',
    title: 'Citrus, glazed bowl',
    description: 'Studio · still life',
    ratio: '1 / 1'
  },
  {
    src: `${base}/misty-tea-terraces-sunrise.jpg`,
    alt: 'Terraced tea fields under morning mist',
    title: 'Tea terraces',
    description: 'Boseong · sunrise',
    ratio: '3 / 2'
  },
  {
    src: `${base}/greenhouse-fern-shadows.jpg`,
    alt: 'Ferns throwing shadows across a greenhouse wall',
    title: 'Greenhouse ferns',
    description: 'Glasshouse no. 3',
    ratio: '2 / 3'
  },
  {
    src: `${base}/hand-dyed-wool-yarn.jpg`,
    alt: 'Skeins of hand-dyed wool in a row',
    title: 'Hand-dyed skeins',
    description: 'Madder, indigo, weld',
    ratio: '1 / 1'
  },
  {
    src: `${base}/frosted-pinecones-moss.jpg`,
    alt: 'Frosted pine cones lying on moss',
    title: 'Frost on the moss',
    description: 'First cold morning',
    ratio: '3 / 2'
  },
  {
    src: `${base}/concrete-stairway-geometric-shadows.jpg`,
    alt: 'A concrete stairway cut by hard geometric shadows',
    title: 'Stairway, hard light',
    description: 'Civic centre',
    ratio: '2 / 3'
  },
  {
    src: `${base}/vintage-camera-maple-leaves.jpg`,
    alt: 'An old rangefinder camera among fallen maple leaves',
    title: 'Rangefinder, autumn',
    description: 'Borrowed for the week',
    ratio: '1 / 1'
  },
  {
    src: `${base}/rowboat-misty-pond-sunrise.jpg`,
    alt: 'A rowboat moored on a misty pond at sunrise',
    title: 'Moored at sunrise',
    description: 'The far pond',
    ratio: '3 / 2'
  },
  {
    src: `${base}/curved-wood-reading-nook.jpg`,
    alt: 'A curved wooden reading nook lit from one side',
    title: 'Reading nook',
    description: 'Bent ash, one lamp',
    ratio: '2 / 3'
  },
  {
    src: `${base}/artisan-bread-wooden-rack.jpg`,
    alt: 'Loaves of bread cooling on a wooden rack',
    title: 'Cooling rack',
    description: 'Second bake of the day',
    ratio: '3 / 2'
  }
];
