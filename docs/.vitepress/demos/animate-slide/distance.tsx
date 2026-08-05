import { AnimateSlide, Chip } from 'neba';

/* A short distance is a nudge; the default is the element's own size, which
   starts it exactly out of frame. */
export default function AnimateSlideDistance() {
  return (
    <div className="flex items-center gap-3">
      <AnimateSlide distance={8} duration={1200} repeat="infinite" alternate fade={false}>
        <Chip>8px</Chip>
      </AnimateSlide>

      <AnimateSlide distance="4rem" duration={1200} repeat="infinite" alternate>
        <Chip color="info">4rem</Chip>
      </AnimateSlide>
    </div>
  );
}
