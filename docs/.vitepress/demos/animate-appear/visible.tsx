import { AnimateAppear, Card } from 'neba';

const CARDS = [
  { title: 'Ingest', body: 'Events arrive and are queued.' },
  { title: 'Enrich', body: 'Each event is matched to an account.' },
  { title: 'Store', body: 'Everything lands in the warehouse.' }
];

export default function AnimateAppearVisible() {
  return (
    <div className="h-60 w-full max-w-xs overflow-y-auto">
      <div className="flex h-40 items-center justify-center text-sm text-(--neba-muted-fg)">
        Scroll down
      </div>

      <AnimateAppear trigger="visible" stagger={140} className="flex flex-col gap-2">
        {CARDS.map((card) => (
          <Card key={card.title} title={card.title} size="sm">
            {card.body}
          </Card>
        ))}
      </AnimateAppear>

      <div className="h-40" />
    </div>
  );
}
