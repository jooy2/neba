import { AnimateSplit } from 'neba';

export default function AnimateSplitHero() {
  return (
    <AnimateSplit
      render={<h3 />}
      className="text-2xl font-semibold text-(--neba-fg)"
      stagger={70}
      distance="0.6em"
    >
      A line arriving a word at a time
    </AnimateSplit>
  );
}
