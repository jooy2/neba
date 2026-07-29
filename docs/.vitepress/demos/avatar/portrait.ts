/**
 * A stand-in portrait, drawn inline so the docs fetch nothing over the network.
 * In an app this would be a URL.
 */
export function portrait(hue: number): string {
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
    <rect width="64" height="64" fill="hsl(${hue} 52% 60%)"/>
    <circle cx="32" cy="25" r="11" fill="hsl(${hue} 58% 90%)"/>
    <path d="M32 39c-12 0-21 7-21 16v9h42v-9c0-9-9-16-21-16Z" fill="hsl(${hue} 58% 90%)"/>
  </svg>`;

  return `data:image/svg+xml,${encodeURIComponent(svg)}`;
}
