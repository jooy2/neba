import { Button } from 'neba';

export default function ButtonHero() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <Button>Save</Button>
      <Button variant="outline">Cancel</Button>
      <Button variant="text">Details</Button>
      <Button color="danger">Delete</Button>
      <Button loading>Saving</Button>
      <Button disabled>Unavailable</Button>
    </div>
  );
}
