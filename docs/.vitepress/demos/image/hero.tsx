import { Image } from 'neba';

export default function ImageHero() {
  return (
    <div className="grid w-full max-w-lg grid-cols-2 gap-4">
      <Image
        src="/samples/photos/misty-tea-terraces-sunrise.jpg"
        alt="Terraced tea fields under morning mist"
        ratio="16 / 9"
        rounded
      />
      <Image
        src="/does-not-exist.png"
        alt="A photograph that did not load"
        ratio="16 / 9"
        rounded
      />
    </div>
  );
}
