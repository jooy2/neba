import { Spoiler } from 'neba';

/** Drawn inline so the docs fetch nothing over the network. */
const STILL =
  'data:image/svg+xml,' +
  encodeURIComponent(`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 220">
    <rect width="400" height="220" fill="hsl(268 46% 58%)"/>
    <circle cx="308" cy="58" r="34" fill="hsl(268 62% 84%)"/>
    <path d="M0 160 96 96l78 42 68-34 158 78v38H0Z" fill="hsl(268 42% 36%)"/>
  </svg>`);

export default function SpoilerMedia() {
  return (
    <div className="w-full max-w-md">
      <Spoiler padded={false} label="Show the still" description="The last shot">
        <img src={STILL} alt="The final frame" className="block w-full" />
      </Spoiler>
    </div>
  );
}
