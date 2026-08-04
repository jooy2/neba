import { AspectRatio } from 'neba';
import { photo } from './photo';

export default function AspectRatioHero() {
  return (
    <AspectRatio ratio={16 / 9} rounded className="max-w-96">
      <img src={photo(212)} alt="A ridge of hills under a low sun" />
    </AspectRatio>
  );
}
