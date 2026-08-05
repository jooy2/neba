import { AnimateMarquee, Chip } from 'neba';

const CUSTOMERS = ['Northwind', 'Contoso', 'Umbrella', 'Initech', 'Hooli', 'Globex'];

export default function AnimateMarqueeHero() {
  return (
    <AnimateMarquee className="w-full max-w-sm" speed={45} gap="1.5rem">
      {CUSTOMERS.map((name) => (
        <Chip key={name} variant="outline">
          {name}
        </Chip>
      ))}
    </AnimateMarquee>
  );
}
