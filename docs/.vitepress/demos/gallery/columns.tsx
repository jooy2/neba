import { Gallery } from 'neba';
import { photos } from './photos';

export default function GalleryColumns() {
  return (
    <div className="flex w-full max-w-3xl flex-col gap-6">
      <Gallery
        items={photos.slice(0, 6)}
        columns={{ xs: 2, sm: 4, lg: 6 }}
        gap="xs"
        ratio="3 / 2"
      />
      <Gallery items={photos.slice(0, 6)} columns={3} gap={20} ratio="3 / 2" />
    </div>
  );
}
