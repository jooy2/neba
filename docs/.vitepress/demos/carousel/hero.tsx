import { Carousel, Typography } from 'neba';

const SLIDES = [
  {
    title: 'Ship on Friday',
    body: 'Preview deploys on every push, gone the moment the branch is.'
  },
  {
    title: 'One prop vocabulary',
    body: 'A size of md means the same thing on every control here.'
  },
  { title: 'Dark mode included', body: 'Every token has a second value; nothing to wire up.' }
];

export default function CarouselHero() {
  return (
    <Carousel label="Product highlights" className="w-full">
      {SLIDES.map((slide) => (
        // The arrows are drawn over the frame, so a slide with words in it pads
        // far enough in to clear them. A photograph would not want that.
        <div key={slide.title} className="flex h-44 flex-col justify-center gap-2 px-16 py-8">
          <Typography level="h3">{slide.title}</Typography>
          <Typography level="body">{slide.body}</Typography>
        </div>
      ))}
    </Carousel>
  );
}
