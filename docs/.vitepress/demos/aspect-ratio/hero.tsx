import { AspectRatio } from 'neba';

export default function AspectRatioHero() {
  return (
    <AspectRatio ratio={16 / 9} rounded className="max-w-96">
      <img
        src="/samples/photos/alpine-lake-dawn.jpg"
        alt="A still alpine lake with the first light on the far ridge"
      />
    </AspectRatio>
  );
}
