import { AnimateLighting, Card } from 'neba';

export default function AnimateLightingHero() {
  return (
    <AnimateLighting size="md" className="w-full max-w-xs">
      <Card title="Analysing 4,281 rows" size="md">
        This usually takes about a minute.
      </Card>
    </AnimateLighting>
  );
}
