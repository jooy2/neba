import { AnimateCounter, Statistic } from 'neba';

export default function AnimateCounterHero() {
  return (
    <Statistic
      label="Monthly active"
      value={<AnimateCounter value={128400} format={{ notation: 'compact' }} />}
    />
  );
}
