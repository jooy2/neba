import { AnimateMarquee, Chip } from 'neba';

const ITEMS = ['alpha', 'beta', 'gamma', 'delta', 'epsilon'];

export default function AnimateMarqueeSpeed() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-3">
      {[30, 90].map((speed) => (
        <AnimateMarquee key={speed} speed={speed} gap="1rem">
          {ITEMS.map((item) => (
            <Chip key={item} size="sm">
              {`${item} · ${speed}px/s`}
            </Chip>
          ))}
        </AnimateMarquee>
      ))}

      <AnimateMarquee speed={45} gap="1rem" reverse>
        {ITEMS.map((item) => (
          <Chip key={item} size="sm" color="secondary">
            {`${item} · reverse`}
          </Chip>
        ))}
      </AnimateMarquee>
    </div>
  );
}
