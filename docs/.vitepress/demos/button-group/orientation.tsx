import { Button, ButtonGroup } from 'neba';

export default function ButtonGroupOrientation() {
  return (
    <div className="flex flex-wrap items-start gap-8">
      <ButtonGroup orientation="horizontal" variant="outline">
        <Button>Left</Button>
        <Button>Centre</Button>
        <Button>Right</Button>
      </ButtonGroup>

      <ButtonGroup orientation="vertical" variant="outline">
        <Button>Top</Button>
        <Button>Middle</Button>
        <Button>Bottom</Button>
      </ButtonGroup>
    </div>
  );
}
