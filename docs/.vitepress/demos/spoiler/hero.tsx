import { Spoiler, Typography } from 'neba';

export default function SpoilerHero() {
  return (
    <div className="w-full max-w-lg">
      <Spoiler>
        <Typography>
          Rosebud was the name of the sled. It is in the last shot of the film, going into the
          furnace with everything else nobody wanted.
        </Typography>
      </Spoiler>
    </div>
  );
}
