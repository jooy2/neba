import { AnimateHeadline, Chip } from 'neba';

const STORIES = [
  'Markets close higher for the third day running',
  'Storm warning lifted across the north coast',
  'Transit strike suspended pending talks'
];

export default function AnimateHeadlineBreaking() {
  return (
    <div className="flex w-full max-w-sm items-center gap-3">
      <Chip color="danger" variant="solid" size="sm">
        Live
      </Chip>

      <AnimateHeadline interval={2200} duration={420} className="min-w-0 flex-1 text-sm">
        {STORIES.map((story) => (
          <span key={story} className="block truncate">
            {story}
          </span>
        ))}
      </AnimateHeadline>
    </div>
  );
}
