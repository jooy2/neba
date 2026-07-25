import { Button, ButtonGroup } from 'neba';

export default function ButtonGroupFullWidth() {
  return (
    <div className="w-full max-w-md">
      <ButtonGroup fullWidth variant="outline" color="secondary">
        <Button>Cancel</Button>
        <Button>Save draft</Button>
        <Button>Publish</Button>
      </ButtonGroup>
    </div>
  );
}
