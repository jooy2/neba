import { Button, ButtonGroup } from 'neba';

export default function ButtonGroupShared() {
  return (
    <div className="flex flex-col items-start gap-4">
      {/* Set once for the whole group. */}
      <ButtonGroup size="sm" variant="outline" color="secondary">
        <Button>Copy</Button>
        <Button>Duplicate</Button>
        <Button>Archive</Button>
      </ButtonGroup>

      {/* A button can still override what the group said. */}
      <ButtonGroup size="sm" variant="outline" color="secondary">
        <Button>Copy</Button>
        <Button>Duplicate</Button>
        <Button color="danger">Delete</Button>
      </ButtonGroup>
    </div>
  );
}
