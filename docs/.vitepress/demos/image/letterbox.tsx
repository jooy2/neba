import { Image } from 'neba';

const LETTERBOXES = ['none', 'rgb(24 24 27)', 'blur'];

export default function ImageLetterbox() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 gap-3 sm:grid-cols-3">
      {LETTERBOXES.map((letterbox) => (
        <figure key={letterbox} className="m-0 flex flex-col gap-1.5">
          {/* `contain` keeps the whole portrait, and `letterbox` says what
              fills the sides it leaves. */}
          <Image
            src="/samples/photos/greenhouse-fern-shadows.jpg"
            alt=""
            height={160}
            fit="contain"
            letterbox={letterbox}
            rounded
          />
          <figcaption className="text-[0.75rem] text-(--neba-muted-fg)">
            letterbox="{letterbox}"
          </figcaption>
        </figure>
      ))}
    </div>
  );
}
