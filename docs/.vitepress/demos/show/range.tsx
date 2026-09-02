import { Chip, Show } from 'neba';

export default function ShowRange() {
  return (
    <div className="flex w-full max-w-2xl flex-wrap gap-2">
      <Show below="sm">
        <Chip color="secondary">xs — under 40rem</Chip>
      </Show>
      <Show above="sm" below="lg">
        <Chip color="primary">sm and md — 40rem to 64rem</Chip>
      </Show>
      <Show above="lg">
        <Chip color="success">lg and up — 64rem and over</Chip>
      </Show>
    </div>
  );
}
