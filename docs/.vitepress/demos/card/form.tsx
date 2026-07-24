import { Button, Card, TextField } from 'neba';

export default function CardForm() {
  return (
    <Card
      className="w-full max-w-md"
      size="lg"
      dividers
      title={<h2>Invite a teammate</h2>}
      subtitle="They will get an email with a link."
      footer={
        <>
          <Button variant="text" color="secondary">
            Cancel
          </Button>
          <Button className="ml-auto">Send invite</Button>
        </>
      }
    >
      <div className="flex flex-col gap-3">
        <TextField label="Email" placeholder="jane@example.com" fullWidth />
        <TextField label="Note" multiline rows={2} placeholder="Optional" fullWidth />
      </div>
    </Card>
  );
}
