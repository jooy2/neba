import { ContextWindow } from 'neba';

export default function ContextWindowHero() {
  return (
    <div className="w-full max-w-sm">
      <ContextWindow
        max={200_000}
        tokens={{ input: 94_200, output: 12_400, reasoning: 8_100, cached: 61_000 }}
        cost={0.42}
        thresholds={[
          { from: 140_000, color: 'warning' },
          { from: 180_000, color: 'danger' }
        ]}
      />
    </div>
  );
}
