import { Button } from 'neba';

export default function ButtonVariants() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <Button variant="solid">Save</Button>
      <Button variant="outline">Cancel</Button>
      <Button variant="text">Details</Button>
    </div>
  );
}
