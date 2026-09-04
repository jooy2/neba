import { Gallery } from 'neba';
import { photos } from './photos';

export default function GalleryHero() {
  return (
    <Gallery
      className="w-full max-w-3xl"
      items={photos.slice(0, 8)}
      layout="justified"
      rowHeight={160}
      caption="hover"
      hover="zoom"
      preview
      label="Field notes"
    />
  );
}
