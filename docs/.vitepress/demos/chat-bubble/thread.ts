/**
 * A stand-in picture, drawn inline so the docs fetch nothing over the network.
 * In an app this would be a URL.
 */
export function shot(hue: number, label: string): string {
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 180">
    <rect width="320" height="180" fill="hsl(${hue} 48% 62%)"/>
    <circle cx="248" cy="46" r="26" fill="hsl(${hue} 62% 82%)"/>
    <path d="M0 132 78 84l62 34 54-28 126 62v28H0Z" fill="hsl(${hue} 44% 40%)"/>
    <text x="16" y="168" font-family="sans-serif" font-size="15" fill="hsl(${hue} 60% 94%)">${label}</text>
  </svg>`;

  return `data:image/svg+xml,${encodeURIComponent(svg)}`;
}
