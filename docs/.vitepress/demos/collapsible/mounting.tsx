import { Collapsible, TextField } from 'neba';

export default function CollapsibleMounting() {
  return (
    <div className="w-full max-w-lg">
      <Collapsible title="Delivery note" keepMounted>
        <TextField
          size="sm"
          label="Leave it with"
          placeholder="A neighbour, the porter…"
          fullWidth
        />
      </Collapsible>
    </div>
  );
}
