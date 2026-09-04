import { Carousel, Image } from 'neba';

const SLIDES = [
  {
    src: '/samples/photos/alpine-lake-dawn.jpg',
    alt: 'A still alpine lake with the first light on the far ridge'
  },
  {
    src: '/samples/photos/misty-tea-terraces-sunrise.jpg',
    alt: 'Terraced tea fields under morning mist'
  },
  {
    src: '/samples/photos/rowboat-misty-pond-sunrise.jpg',
    alt: 'A rowboat moored on a misty pond at sunrise'
  },
  {
    src: '/samples/photos/frosted-pinecones-moss.jpg',
    alt: 'Frosted pine cones lying on moss'
  }
];

/**
 * The other side of the padding rule: a picture fills the frame, so there is
 * nothing to pad in, and the arrows are drawn over the photograph itself.
 */
export default function CarouselPhotos() {
  return (
    <Carousel label="Photographs" className="w-full max-w-lg" indicators>
      {SLIDES.map((slide) => (
        <Image key={slide.src} src={slide.src} alt={slide.alt} ratio="3 / 2" />
      ))}
    </Carousel>
  );
}
