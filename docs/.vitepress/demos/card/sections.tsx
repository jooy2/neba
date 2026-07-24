import { Button, Card } from 'neba';

export default function CardSections() {
  return (
    <Card
      className="w-full max-w-md"
      title="Title"
      subtitle="Subtitle"
      headerAction={
        <Button size="xs" variant="text" color="secondary" aria-label="More">
          ⋯
        </Button>
      }
      footer={
        <>
          <Button size="sm" variant="text" color="secondary">
            Cancel
          </Button>
          <Button size="sm" className="ml-auto">
            Confirm
          </Button>
        </>
      }
    >
      The body. A slot you do not pass is not rendered, so a card with only a title has no empty
      header sitting above it.
    </Card>
  );
}
