import { Image } from 'neba';

const RIDGE =
  'data:image/svg+xml,' +
  encodeURIComponent(
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 180">
      <defs><linearGradient id="s" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0" stop-color="#f5b971"/><stop offset="1" stop-color="#d96e5a"/>
      </linearGradient></defs>
      <rect width="320" height="180" fill="url(#s)"/>
      <circle cx="232" cy="58" r="22" fill="#fff3d6"/>
      <path d="M0 140 L74 92 L128 128 L196 74 L262 118 L320 88 L320 180 L0 180 Z" fill="#7a3f52"/>
      <path d="M0 162 L92 122 L164 156 L240 118 L320 148 L320 180 L0 180 Z" fill="#4a2740"/>
    </svg>`
  );

export default function ImageHero() {
  return (
    <div className="grid w-full max-w-lg grid-cols-2 gap-4">
      <Image src={RIDGE} alt="A ridge of hills under a low sun" ratio="16 / 9" rounded />
      <Image
        src="/does-not-exist.png"
        alt="A photograph that did not load"
        ratio="16 / 9"
        rounded
      />
    </div>
  );
}
