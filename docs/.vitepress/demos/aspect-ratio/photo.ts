/**
 * A stand-in photograph, drawn inline so the docs fetch nothing over the
 * network. In an app this would be a URL.
 *
 * Deliberately taller than it is wide (3:4), because that is what makes `fit`
 * legible: a portrait image dropped into a square box has to be cropped,
 * letterboxed or squashed, and the three values are exactly those three answers.
 */
export function photo(hue: number): string {
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 400">
    <rect width="300" height="400" fill="hsl(${hue} 46% 68%)"/>
    <circle cx="222" cy="78" r="34" fill="hsl(${hue} 64% 88%)"/>
    <path d="M0 292 84 206l58 52 62-40 96 74v108H0Z" fill="hsl(${hue} 42% 42%)"/>
    <path d="M0 340 62 300l70 40 68-26 100 46v40H0Z" fill="hsl(${hue} 38% 30%)"/>
  </svg>`;

  return `data:image/svg+xml,${encodeURIComponent(svg)}`;
}
