import { Gallery } from 'neba';
import { photos } from './photos';

export default function GalleryFit() {
  return (
    // Square tiles hold landscapes and portraits alike, so `contain` keeps each
    // whole and `letterbox` fills the space around it with the picture blurred.
    <Gallery
      items={photos.slice(0, 6)}
      columns={{ xs: 2, sm: 3 }}
      ratio={1}
      fit="contain"
      letterbox="blur"
      className="w-full max-w-2xl"
    />
  );
}
